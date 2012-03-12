namespace HildonMime
{
    int open_file(DBus.RawConnection con, string file);
    int open_file_with_mime_type(DBus.RawConnection con, string file, string mime_type);
}
