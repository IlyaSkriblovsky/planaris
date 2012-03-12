// $Id: LoginDialog.vala 91 2010-11-24 12:44:17Z mitrandir $

public class LoginDialog: Gtk.Dialog
{
    Gtk.Entry _login_entry;
    Gtk.Entry _password_entry;

    public string login { get { return _login_entry.text; } }
    public string password { get { return _password_entry.text; } }

    public LoginDialog(Gtk.Window? window)
    {
        title = _("Login");
        set_transient_for(window);
        set_modal(true);
        add_button(Gtk.STOCK_OK, Gtk.ResponseType.OK);
        add_button(Gtk.STOCK_CANCEL, Gtk.ResponseType.CANCEL);
        set_default_response(Gtk.ResponseType.OK);

        var _entry_size_group = new Gtk.SizeGroup(Gtk.SizeGroupMode.HORIZONTAL);

        var description = new Gtk.Label(
            _("In order to use online synchronization, you must register at " +
            "planaris web site and specify your login and password:")
        );
        description.wrap = true;
        vbox.add(description);
        vbox.add(
            new Gtk.LinkButton(Config.Url.REGISTRATION)
        );

        #if ! FREMANTLE
            _login_entry = new Gtk.Entry();
            var _login_label = new Gtk.Label(_("Login") + ": ");
            var _login_box = GtkUtil.make_hbox(
                _login_label, false, false,
                _login_entry, true, true
            );

            _password_entry = new Gtk.Entry();
            var _password_label = new Gtk.Label(_("Password") + ": ");
            var _password_box = GtkUtil.make_hbox(
                _password_label, false, false,
                _password_entry, true, true
            );
            _password_entry.visibility = false;

            _entry_size_group.add_widget(_login_label);
            _entry_size_group.add_widget(_password_label);
        #else
            _login_entry = new Hildon.Entry(Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT);
            var _login_box = new Hildon.Caption(
                _entry_size_group, _("Login"), _login_entry,
                (Gtk.Widget)null, Hildon.CaptionStatus.OPTIONAL
            );

            _password_entry = new Hildon.Entry(Hildon.SizeType.AUTO_WIDTH | Hildon.SizeType.FINGER_HEIGHT);
            var _password_box = new Hildon.Caption(
                _entry_size_group, _("Password"), _password_entry,
                (Gtk.Widget)null, Hildon.CaptionStatus.OPTIONAL
            );
            _password_entry.visibility = false;
        #endif
        _password_entry.set_activates_default(true);

        #if MAEMO
            Hildon.gtk_entry_set_input_mode(
                _login_entry,
                Hildon.GtkInputMode.FULL
            );
            Hildon.gtk_entry_set_input_mode(
                _password_entry,
                Hildon.GtkInputMode.FULL | Hildon.GtkInputMode.INVISIBLE
            );
        #endif

        show.connect(() => {
            _login_entry.grab_focus();
        });

        vbox.add(_login_box);
        vbox.add(_password_box);

        vbox.show_all();
    }
}
