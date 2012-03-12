class WaitWindow: Gtk.Window
{
    Gtk.ProgressBar progress_bar;
    int cnt;

    public WaitWindow()
    {
        set_default_size(300, 300);

        progress_bar = new Gtk.ProgressBar();

        var btn = new Gtk.Button.with_label("Click me");

        var vbox = new Gtk.VBox(false, 10);
        vbox.add(progress_bar);
        vbox.add(btn);
        add(vbox);

        btn.clicked.connect(on_button);
    }

    void on_button()
    {
        try
        {
            Thread.create(thread_body, true);
        }
        catch (ThreadError e)
        {
            stdout.printf("Exception: %s\n", e.message);
        }
    }

    void* thread_body()
    {
        for (cnt = 0; cnt < 10; cnt++)
        {
            stdout.printf("%d\n", cnt);
            Thread.usleep(500000);

            Gdk.threads_add_idle(() => {
                progress_bar.set_fraction(((double)cnt) / 10.0);
                return false;
            });
        }
        stdout.printf("fire!\n");

        return null;
    }
}

public void main(string[] args)
{
    Gtk.init(ref args);

    var window = new WaitWindow();
    window.destroy.connect(Gtk.main_quit);
    window.show_all();

    Gtk.main();
}
