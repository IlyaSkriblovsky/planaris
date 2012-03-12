TaskTreeModel model;
Gtk.TreeModelFilter filter;
Gtk.TreeView view;


void add_root()
{
    model.root.add_child(new Task(0, "Root"));
//    Gtk.TreeIter iter;
//    model.append(out iter, null);
//    model.set(iter, 0, "Root");
}


void add_child()
{
    Gtk.TreeIter iter;
    view.get_selection().get_selected(null, out iter);

    Gtk.TreeIter model_iter;
    filter.convert_iter_to_child_iter(out model_iter, iter);


    model.task(model_iter).add_child(new Task(0, "Child"));
//    Gtk.TreeIter child_iter;
//    model.append(out child_iter, model_iter);
//    model.set(child_iter, 0, "Child");
}


void add_bug()
{
    var aaa = new Task(0, "aaa");
    var bbb = new Task(0, "bbb");
    model.root.add_child(aaa);
    aaa.add_child(bbb);
    view.expand_all();
}


public void main(string[] args)
{
    Gtk.init(ref args);

    var window = new Gtk.Window(Gtk.WindowType.TOPLEVEL);

    model = new TaskTreeModel();

    filter = new Gtk.TreeModelFilter(model, null);

    view = new Gtk.TreeView.with_model(filter);
    view.insert_column(new Gtk.TreeViewColumn.with_attributes("Name", new TaskCellRenderer(), "text", 0), -1);

    var btnaddroot = new Gtk.Button.with_label("Add root");
    btnaddroot.clicked.connect(add_root);

    var btnaddchild = new Gtk.Button.with_label("Add child");
    btnaddchild.clicked.connect(add_child);

    var btnaddbug = new Gtk.Button.with_label("Add bug");
    btnaddbug.clicked.connect(add_bug);

    var vbox = new Gtk.VBox(false, 0);
    vbox.pack_start(view, true, true, 0);
    vbox.pack_start(btnaddroot, false, false, 0);
    vbox.pack_start(btnaddchild, false, false, 0);
    vbox.pack_start(btnaddbug, false, false, 0);
    window.add(vbox);

    window.destroy.connect(Gtk.main_quit);
    window.set_default_size(500, 500);
    window.show_all();

    Gtk.main();
}
