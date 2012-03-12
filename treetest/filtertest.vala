bool visible(Gtk.TreeModel model, Gtk.TreeIter iter)
{
    stdout.printf("%d\n", (model is Gtk.TreeStore) ? 1 : 0);
    string name;
    model.get(iter, 0, out name);
    stdout.printf("%s\n", name);
    if (name.contains("1"))
        return false;
    return true;
}

public void main(string[] args)
{
    Gtk.init(ref args);

    var model = new Gtk.TreeStore(1, typeof(string));
    var filter = new Gtk.TreeModelFilter(model, null);
    filter.set_visible_func(visible);



    Gtk.TreeIter root;
    Gtk.TreeIter iter;
    Gtk.TreeIter a;
    model.append(out root, null);
    model.set(root, 0, "Root");
    model.append(out iter, root);
    model.set(iter, 0, "One");
    model.append(out a, root);
    model.set(a, 0, "Two");
    model.append(out iter, a);
    model.set(iter, 0, "Two .1");
    model.append(out iter, a);
    model.set(iter, 0, "Two .2");
    model.append(out iter, root);
    model.set(iter, 0, "Three");



    var window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);
    var view = new Gtk.TreeView.with_model(filter);

    view.insert_column(new Gtk.TreeViewColumn.with_attributes("Name", new Gtk.CellRendererText(), "text", 0), -1);
    view.expand_all();

    window.add(view);
    window.set_default_size(400, 400);
    window.destroy.connect(Gtk.main_quit);
    window.show_all();

    Gtk.main();
}
