// $Id: TaskTreeModel.vala 86 2010-11-23 16:56:31Z mitrandir $

public class TaskTreeModel: GLib.Object, Gtk.TreeModel
{
    private int _stamp;

    private Task _root = null;


    public Task root
    {
        get { return _root; }
    }


    public enum Column
    {
        NAME = 0,
        TASK_TYPE,
        PROGRESS,
        DONE,
        TOTAL
    }


    public TaskTreeModel()
    {
        _stamp = (int)GLib.Random.next_int();

        _root = create_root();
    }

    public TaskTreeModel.with_root(Task? root)
    {
        _stamp = (int)GLib.Random.next_int();

        _root = create_root(root);
    }


    private Task create_root(Task? existing = null)
    {
        Task root;
        if (existing != null)
            root = existing;
        else
            root = new Task(0, "<root>");

        root.subtree_added.connect(on_subtree_added);
        root.subtree_removing.connect(on_subtree_removing);
        root.subtree_removed.connect(on_subtree_removed);
        root.subtree_changed.connect(on_subtree_changed);
        return root;
    }


    public void task_iter(out Gtk.TreeIter iter, Task task)
    {
        iter.stamp = _stamp;
        iter.user_data = task;
        iter.user_data2 = null;
        iter.user_data3 = null;
    }

    public Gtk.TreePath task_path(Task task)
    {
        Gtk.TreeIter iter;
        task_iter(out iter, task);
        return get_path(iter);
    }

    public unowned Task task(Gtk.TreeIter iter)
    {
        return (Task)iter.user_data;
    }

    public unowned Task task_from_path(Gtk.TreePath path)
    {
        Gtk.TreeIter iter;
        get_iter(out iter, path);
        return (Task)iter.user_data;
    }


// Private methods

    private void on_subtree_added(Task child)
    {
        Gtk.TreeIter child_iter;
        task_iter(out child_iter, child);
        var child_path = get_path(child_iter);
        row_inserted(child_path, child_iter);

        if (child.parent.n_childs == 1 && child.parent != _root)
        {
            Gtk.TreeIter parent_iter;
            task_iter(out parent_iter, child.parent);
            var parent_path = get_path(parent_iter);
            row_has_child_toggled(parent_path, parent_iter);
        }
    }

    private void on_subtree_removing(Task child)
    {
        Gtk.TreeIter child_iter;
        task_iter(out child_iter, child);
        row_deleted(get_path(child_iter));
    }

    private void on_subtree_removed(Task root, Task was_parent, Task child)
    {
        if (was_parent.n_childs == 0 && child.parent != _root)
        {
            Gtk.TreeIter parent_iter;
            task_iter(out parent_iter, was_parent);
            var parent_path = get_path(parent_iter);
            row_has_child_toggled(parent_path, parent_iter);
        }
    }

    private void on_subtree_changed(Task task)
    {
        if (task == _root)
            return;

        Gtk.TreeIter iter;
        task_iter(out iter, task);
        row_changed(get_path(iter), iter);
    }

// TreeModel implementation

    public GLib.Type get_column_type(int index)
    {

        switch (index)
        {
            case Column.NAME: return typeof(string);
            case Column.TASK_TYPE: return typeof(Task.TaskType);
            case Column.PROGRESS: return typeof(double);
            case Column.DONE: return typeof(bool);

            default: return typeof(int);
        }
    }

    public Gtk.TreeModelFlags get_flags()
    {
        return 0;
    }

    public bool get_iter(out Gtk.TreeIter iter, Gtk.TreePath path)
    {
        unowned int[] indices = path.get_indices();

        var task = _root;

        for (int level = 0; level < path.get_depth(); level++)
        {
            task = task.nth_child(indices[level]);

            if (task == null)
                return false;
        }

        task_iter(out iter, task);

        return true;
    }

    public int get_n_columns()
    {
        return Column.TOTAL;
    }

    public Gtk.TreePath get_path(Gtk.TreeIter iter)
    {
        var path = new Gtk.TreePath();
        var task = (Task)iter.user_data;

        while (task.parent != null)
        {
            path.prepend_index(task.parent.childs.index(task));
            task = task.parent;
        }

        return path;
    }

    public void get_value(Gtk.TreeIter iter, int column, out GLib.Value value)
    {
        var task = (Task)iter.user_data;

        switch (column)
        {
            case Column.NAME: value = task.name; break;
            case Column.TASK_TYPE: value = task.task_type; break;
            case Column.PROGRESS: value = task.progress; break;
            case Column.DONE: value = task.done; break;

            default: value = 0; break;
        }
    }

    public bool iter_children(out Gtk.TreeIter iter, Gtk.TreeIter? parent)
    {
        Task task = _root;
        if (parent != null)
            task = (Task)parent.user_data;

        if (task.n_childs == 0)
            return false;
        else
        {
            task_iter(out iter, task.childs.data);
            return true;
        }
    }

    public bool iter_has_child(Gtk.TreeIter iter)
    {
        var task = (Task)iter.user_data;
        return task.n_childs > 0;
    }

    public int iter_n_children(Gtk.TreeIter? iter)
    {
        var task = iter == null ? _root : (Task)iter.user_data;
        return task.n_childs;
    }

    public bool iter_next(ref Gtk.TreeIter iter)
    {
        var task = (Task)iter.user_data;

        int i = task.parent.childs.index(task) + 1;
        if (task.parent.n_childs > i)
        {
            task_iter(out iter, task.parent.childs.nth_data(i));
            return true;
        }
        else
            return false;
    }

    public bool iter_nth_child(out Gtk.TreeIter iter, Gtk.TreeIter? parent, int n)
    {
        var task = parent == null ? _root : (Task)parent.user_data;

        if (n >= 0 && n < task.n_childs)
        {
            task_iter(out iter, task.childs.nth_data(n));
            return true;
        }
        else
            return false;
    }

    public bool iter_parent(out Gtk.TreeIter iter, Gtk.TreeIter child)
    {
        var task = (Task)child.user_data;

        if (task.parent != null)
        {
            task_iter(out iter, task.parent);
            return true;
        }
        else
            return false;
    }

    public void ref_node(Gtk.TreeIter iter)
    {
    }

    public void unref_node(Gtk.TreeIter iter)
    {
    }
}
