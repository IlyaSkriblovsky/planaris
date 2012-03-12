public void main(string[] args)
{
    Gtk.init(ref args);

    var window = new Hildon.Window();

    var action = new Gtk.Action("New", "New", "Tooltip", Gtk.STOCK_REFRESH);
    action.set("stock_id", null);
    action.set("icon_name", "qgn_toolb_gene_refresh");

    var toolbar = new Gtk.Toolbar();
    toolbar.insert(action.create_tool_item() as Gtk.ToolItem, -1);

    window.add_toolbar(toolbar);

    window.destroy += Gtk.main_quit;

    window.show_all();

    Gtk.main();
}
