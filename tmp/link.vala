static DBus.RawConnection dbus_connection = null;
void uri_hook(Gtk.LinkButton button, string uri)
{

    if (dbus_connection == null)
    {
        DBus.RawError error = DBus.RawError();
        dbus_connection = DBus.RawBus.get(DBus.BusType.SESSION, ref error);
    }

    HildonMime.open_file_with_mime_type(dbus_connection, "http://bash.org.ru/", "text/html");
}

public void main(string[] args)
{
    Gtk.init(ref args);

    var window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);

    Gtk.LinkButton.set_uri_hook(uri_hook);

    var link = new Gtk.LinkButton("http://google.com");
    window.add(link);

    window.destroy.connect(Gtk.main_quit);
    window.show_all();

    Gtk.main();
}
