// $Id: TaskDialog.vala 91 2010-11-24 12:44:17Z mitrandir $

string progress_text(double progress)
{
    return "%ld%%".printf(GLib.Math.lrint(progress * 100));
}


public class TaskDialog: Gtk.Dialog
{
    public enum Response
    {
        OK = Gtk.ResponseType.OK,
        CANCEL = Gtk.ResponseType.CANCEL,
        DELETE = 1
    }


    private Gtk.Widget *ok_button;

    private Task _task;

    private Gtk.Entry _name_entry;
    private Gtk.RadioButton _type_auto;
    private Gtk.RadioButton _type_check;
    private Gtk.RadioButton _type_progress;



    private double _progress;

    #if FREMANTLE
        private Hildon.CheckButton _done;
        private Hildon.Button _progress_button;
        private Hildon.CheckButton _auto_progress;
    #else
        private Gtk.CheckButton _done;
        private Gtk.Button _progress_button;
        private Gtk.CheckButton _auto_progress;
    #endif


    public TaskDialog(Gtk.Window? window, Task task, string title = _("Modify Task"), bool show_delete_button = true)
    {
        _task = task;

        set_transient_for(window);
        set_modal(true);
        this.title = title;
        ok_button = add_button(Gtk.STOCK_OK, Response.OK);
        add_button(Gtk.STOCK_CANCEL, Response.CANCEL);
        set_default_response(Response.OK);

        if (show_delete_button)
            add_button(Gtk.STOCK_DELETE, Response.DELETE);


        var title_size_group = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);


        #if ! FREMANTLE
            _name_entry = new Gtk.Entry();
            var name_title = new Gtk.Label(_("Title") + ": ");
            var _name_label = GtkUtil.make_hbox(
                name_title, false, false,
                _name_entry, true, true
            );

            title_size_group.add_widget(name_title);
        #else
            _name_entry = new Hildon.Entry(Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT);
            var _name_label = new Hildon.Caption(title_size_group, _("Title"), _name_entry, (Gtk.Widget)null, Hildon.CaptionStatus.OPTIONAL);
        #endif

        _name_entry.set_text(_task.name);
        _name_entry.set_activates_default(true);
        _name_entry.changed.connect(update_ok_sensivity);
        update_ok_sensivity();


        #if ! FREMANTLE
            _type_auto = new Gtk.RadioButton.with_label(null, _("Auto"));
            _type_check = new Gtk.RadioButton.with_label_from_widget(_type_auto, _("Check"));
            _type_progress = new Gtk.RadioButton.with_label_from_widget(_type_auto, _("Progress"));
        #else
            _type_auto = (Gtk.RadioButton)Hildon.gtk_radio_button_new(Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT, (GLib.SList)null);
            _type_auto.add(new Gtk.Label(_("Auto")));
            _type_check = (Gtk.RadioButton)Hildon.gtk_radio_button_new_from_widget(Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT, _type_auto);
            _type_check.add(new Gtk.Label(_("Check")));
            _type_progress = (Gtk.RadioButton)Hildon.gtk_radio_button_new_from_widget(Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT, _type_auto);
            _type_progress.add(new Gtk.Label(_("Progress")));
        #endif

        _type_auto.set_mode(false);
        _type_check.set_mode(false);
        _type_progress.set_mode(false);

        _type_auto.toggled.connect(update_value_widget_from_type);
        _type_check.toggled.connect(update_value_widget_from_type);
        _type_progress.toggled.connect(update_value_widget_from_type);



        _progress = _task.progress;

        #if FREMANTLE
            _done = new Hildon.CheckButton(
                Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT
            );
            _done.set_label(_("Done"));

            _progress_button = new Hildon.Button(
                Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT,
                Hildon.ButtonArrangement.VERTICAL
            );
            _progress_button.title = _("%s done").printf(progress_text(_progress));

            _auto_progress = new Hildon.CheckButton(
                Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT
            );
            _auto_progress.set_label(_("Calculate progress from childs"));
        #else
            _done = new Gtk.CheckButton.with_label(_("Done"));
            _progress_button = new Gtk.Button.with_label(_("%s done").printf(progress_text(_progress)));
            _auto_progress = new Gtk.CheckButton.with_label(_("Calculate progress from childs"));
        #endif

        _done.set_active(_task.done);
        _done.toggled.connect(on_done_toggled);
        _progress_button.clicked.connect(on_progress_button_clicked);

        _auto_progress.set_active(_task.auto_progress);
        _auto_progress.toggled.connect(set_progress_sensitivity);
        set_progress_sensitivity();



        vbox.add(GtkUtil.make_hbox(
            _name_label, true, true,
            _done, false, false,
            _progress_button, false, false
        ));


        var type_title = new Gtk.Label(_("Type") + ": ");
        title_size_group.add_widget(type_title);

        var type_buttons_box = GtkUtil.make_hbox(
            _type_auto, true, true,
            _type_check, true, true,
            _type_progress, true, true
        );

        #if FREMANTLE
            vbox.add(new Hildon.Caption(
                title_size_group, _("Type"), type_buttons_box, (Gtk.Widget)null,
                Hildon.CaptionStatus.OPTIONAL
            ));
        #else
            vbox.add(GtkUtil.make_hbox(
                type_title, false, false,
                type_buttons_box, true, true
            ));
        #endif

        vbox.add(_auto_progress);


        vbox.show_all();


        update_value_widget_from_type();


        if (_task.auto_type)
            _type_auto.active = true;
        else
            switch (_task.task_type)
            {
                case Task.TaskType.CHECK:    _type_check.active = true; break;
                case Task.TaskType.PROGRESS: _type_progress.active = true; break;
            }
    }


    public override void response(int response_id)
    {
        if (response_id == Response.OK)
        {
            _task.name = _name_entry.get_text();

            _task.auto_progress = _auto_progress.get_active();

            if (_type_auto.active)
                _task.auto_type = true;
            else
            {
                _task.auto_type = false;
                if (_type_check.active) _task.task_type = Task.TaskType.CHECK;
                if (_type_progress.active) _task.task_type = Task.TaskType.PROGRESS;
            }

            if (_task.task_type == Task.TaskType.CHECK)
                _task.progress = _progress == 1.0 ? 1.0 : 0.0;
            else
                _task.progress = _progress;
        }
    }



    void set_progress(double progress)
    {
        // _done.set_active can call set_progress again with 0 as argument
        // Due to this, we set _progress after call to set_active
        _done.set_active(progress == 1.0);
        _progress = progress;

        #if FREMANTLE
            _progress_button.title = _("%s done").printf(progress_text(_progress));
        #else
            _progress_button.set_label(_("%s done").printf(progress_text(_progress)));
        #endif
    }



    void on_done_toggled()
    {
        set_progress(_done.get_active() ? 1.0 : 0.0);
    }



    void update_ok_sensivity()
    {
        ok_button->set_sensitive(_name_entry.get_text().length != 0);
    }



    void update_value_widget_from_type()
    {
        bool show_check = true;

        if (_type_check.active)
            show_check = true;
        else if (_type_progress.active)
            show_check = false;
        else if (_type_auto.active)
        {
            if (_task.has_childs && _auto_progress.get_active())
                show_check = false;
            else
                show_check = true;
        }


        if (show_check)
        {
            _done.show();
            _progress_button.hide();
        }
        else
        {
            _done.hide();
            _progress_button.show();
        }
    }

    void on_progress_button_clicked()
    {
        var dialog = new ProgressDialog(_progress);
        if (dialog.run() == Gtk.ResponseType.OK)
            set_progress(dialog.progress);
        dialog.destroy();
    }


    void set_progress_sensitivity()
    {
        bool sensitive = ! (_auto_progress.get_active() && _task.has_childs);
        _done.set_sensitive(sensitive);
        _progress_button.set_sensitive(sensitive);

        update_value_widget_from_type();

        if (_auto_progress.get_active() && _task.has_childs)
            set_progress(_task.calc_child_progress());
    }
}



class ProgressDialog: Gtk.Dialog
{
    public double progress { get; set; }

    private Gtk.HScale _scale;

    public ProgressDialog(double progress)
    {
        this.progress = progress;

        title = _("Task Progress");
        add_button(Gtk.STOCK_OK, Gtk.ResponseType.OK);
        add_button(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL);


        var adj = new Gtk.Adjustment(
            _progress,
            0, 1,
            0.1, 0.1,
            0
        );
        _scale = new Gtk.HScale(adj);
        _scale.set_value(progress);
        _scale.value_changed.connect(on_value_changed);
        _scale.format_value.connect((value) => {
            return progress_text(value);
        });

        vbox.add(_scale);
        vbox.show_all();
    }


    private void on_value_changed()
    {
        progress = _scale.get_value();
    }
}
