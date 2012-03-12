// $Id: GtkUtil.vala 43 2010-11-13 09:32:38Z mitrandir $

namespace GtkUtil
{
    public static void error_message(Gtk.Window window, string text)
    {
        #if MAEMO
            var dialog = new Hildon.Note.information(window, text);
        #else
            var dialog = new Gtk.MessageDialog.with_markup(
                window,
                0,
                Gtk.MessageType.ERROR,
                Gtk.ButtonsType.CLOSE,
                text
            );
        #endif

        dialog.run();
        dialog.destroy();
    }



    // Of course, this must be implementing using varargs, but unfortunately,
    // Diablo's vala 0.7.9 doesn't support varargs yet :(
    public Gtk.Box make_hbox(
        Gtk.Widget? widget1, bool expand1, bool fill1,
        Gtk.Widget? widget2 = null, bool expand2 = true, bool fill2 = true,
        Gtk.Widget? widget3 = null, bool expand3 = true, bool fill3 = true,
        Gtk.Widget? widget4 = null, bool expand4 = true, bool fill4 = true
    )
    {
        var box = new Gtk.HBox(false, 0);

        if (widget1 != null) box.pack_start(widget1, expand1, fill1, 0);
        if (widget2 != null) box.pack_start(widget2, expand2, fill2, 0);
        if (widget3 != null) box.pack_start(widget3, expand3, fill3, 0);
        if (widget4 != null) box.pack_start(widget4, expand4, fill4, 0);

        return box;
    }

    public Gtk.Box make_vbox(
        Gtk.Widget? widget1, bool expand1, bool fill1,
        Gtk.Widget? widget2 = null, bool expand2 = true, bool fill2 = true,
        Gtk.Widget? widget3 = null, bool expand3 = true, bool fill3 = true,
        Gtk.Widget? widget4 = null, bool expand4 = true, bool fill4 = true
    )
    {
        var box = new Gtk.VBox(false, 0);

        if (widget1 != null) box.pack_start(widget1, expand1, fill1, 0);
        if (widget2 != null) box.pack_start(widget2, expand2, fill2, 0);
        if (widget3 != null) box.pack_start(widget3, expand3, fill3, 0);
        if (widget4 != null) box.pack_start(widget4, expand4, fill4, 0);

        return box;
    }


    #if MAEMO
        static DBus.RawConnection hildon_dbus_connection = null;
        void hildon_uri_hook(Gtk.LinkButton button, string uri)
        {
            HildonMime.open_file_with_mime_type(hildon_dbus_connection, uri, "text/html");
        }

        public void set_hildon_uri_hook()
        {
            DBus.RawError error = DBus.RawError();
            hildon_dbus_connection = DBus.RawBus.get(DBus.BusType.SESSION, ref error);

            Gtk.LinkButton.set_uri_hook(hildon_uri_hook);
        }
    #endif
}
