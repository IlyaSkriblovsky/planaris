// $Id: Sync.vala 91 2010-11-24 12:44:17Z mitrandir $

errordomain SyncError
{
    CLIENT_FAIL,
    SERVER_FAIL,
    CANNOT_LOAD,
    CANNOT_SAVE,
    CANNOT_CREATE_THREAD
}

public class Sync
{
    SyncDialog dialog;

    public void sync_with_progressbar(Gtk.Window window, PlanSet plan_set)
        throws SyncError
    {
        dialog = new SyncDialog(window);
        dialog.show_all();
        dialog.start();

        try
        {
            Thread.create(() => {
                SyncError? error = null;
                try
                {
                    sync(plan_set);
                }
                catch (SyncError e)
                {
                    error = e;
                }

                stdout.printf(_("Sync done\n"));
                if (error != null)
                    stdout.printf(_("Error: %s\n"), error.message);

                Gdk.threads_enter();
                    dialog.stop();
                Gdk.threads_leave();

                return null;
            }, true);
        }
        catch (ThreadError e)
        {
            throw new SyncError.CANNOT_CREATE_THREAD(e.message);
        }

        while (dialog.run() != Gtk.ResponseType.OK)
        {
        }

        dialog.destroy();
    }


    public void sync(PlanSet plan_set)
        throws SyncError
    {
        #if ! WINDOWS
            string tmp_dir = (Environment.get_tmp_dir() + Path.DIR_SEPARATOR_S + "planaris-XXXXXX").dup();
            DirUtils.mkdtemp(tmp_dir); // this modifies tmp_dir
            tmp_dir += Path.DIR_SEPARATOR_S;
        #else
            var random_string = "";
            for (var i = 0; i < 10; i++)
                random_string = random_string + Random.int_range(0, 9).to_string();
            string tmp_dir = Environment.get_tmp_dir() + Path.DIR_SEPARATOR_S + "planaris-" + random_string;
            tmp_dir += Path.DIR_SEPARATOR_S;
            DirUtils.create(tmp_dir, 0700);
        #endif
        stdout.printf("temp: %s\n", tmp_dir);


        var my_db_filename = tmp_dir + "my.sqlite";
        var new_db_filename = tmp_dir + "new.sqlite";

        try
        {
            var curl = new Curl.Easy();
            curl.setopt(Curl.Opt.URL, Config.Url.SYNC);

            var output = FileStream.open(new_db_filename, "wb");
            curl.setopt(Curl.Opt.WRITEDATA, output);

            Curl.HttpPost *first = null;
            Curl.HttpPost *last = null;
            Curl.HttpPost.formadd(&first, &last,
                Curl.FormOption.COPYNAME, "my",
                Curl.FormOption.FILE, my_db_filename
            );
            curl.setopt(Curl.Opt.HTTPPOST, first);

            plan_set.save(my_db_filename);

            var res = curl.perform();
            Curl.HttpPost.formfree(first);

            if (res == Curl.Code.OK)
            {
                long http_code;
                curl.getinfo(Curl.Info.RESPONSE_CODE, out http_code);
                output.flush();

                if (http_code != 200)
                {
                    var input = FileStream.open(new_db_filename, "r");
                    var s = input.read_line();
                    throw new SyncError.SERVER_FAIL("%ld: %s".printf(http_code, s));
                }
                else
                {
                    // Need to lock GDK because load() will emit signals which calls
                    // GDK functions
                    Gdk.threads_enter();
                    plan_set.load(new_db_filename);
                    Gdk.threads_leave();
                }
            }
            else
                throw new SyncError.CLIENT_FAIL(_("Curl failed"));
        }
        catch (SaverError e)
        {
            throw new SyncError.CANNOT_SAVE(_("Cannot save plan: %s").printf(e.message));
        }
        catch (LoaderError e)
        {
            throw new SyncError.CANNOT_LOAD(_("Cannot load plan: %s").printf(e.message));
        }
        finally
        {
            FileUtils.unlink(new_db_filename);
            FileUtils.unlink(my_db_filename);
            DirUtils.remove(tmp_dir);
        }
    }
}


class SyncDialog: Gtk.Dialog
{
    Gtk.ProgressBar progress_bar;
    bool stopped = false;

    public SyncDialog(Gtk.Window window)
    {
        title = _("Syncing...");
        set_transient_for(window);

        progress_bar = new Gtk.ProgressBar();
        vbox.add(progress_bar);
    }

    ~SyncDialog()
    {
        stdout.printf("~SyncDialog\n");
    }

    public void start()
    {
        stopped = false;
        Timeout.add(100, on_timeout);
    }

    public void stop()
    {
        stopped = true;
        response(Gtk.ResponseType.OK);
    }


    bool on_timeout()
    {
        progress_bar.pulse();
        return !stopped;
    }
}
