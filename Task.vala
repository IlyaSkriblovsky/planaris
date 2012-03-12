// $Id: Task.vala 37 2010-11-10 13:53:43Z mitrandir $

public class Task
{
    public int id { get; private set; }

    public enum TaskType
    {
        CHECK,
        PROGRESS
    }

    private string _name;
    public string name
    {
        get { return _name; }
        set
        {
            _name = value;
            notify_subtree_changed(this);
        }
    }

    private bool _auto_type = true;
    public bool auto_type
    {
        get { return _auto_type; }
        set { _auto_type = value; }
    }

    private TaskType _task_type = TaskType.CHECK;
    public TaskType task_type
    {
        get
        {
            if (auto_type)
                if (auto_progress && has_childs)
                    return TaskType.PROGRESS;
                else
                    return TaskType.CHECK;
            else
                return _task_type;
        }
        set
        {
            _task_type = value;

            notify_subtree_changed(this);
        }
    }

    private double _progress = 0.0;
    public double progress
    {
        get
        {
            return _progress;
        }
        set
        {
            if (! (auto_progress && has_childs))
            {
                if (_progress != value)
                {
                    _progress = value;
                    notify_subtree_changed(this);
                }
            }
        }
    }

    public bool done
    {
        get { return progress == 1.0; }
        set { progress = value ? 1.0 : 0.0; }
    }


    private bool _auto_progress = true;
    public bool auto_progress
    {
        get { return _auto_progress; }
        set
        {
            _auto_progress = value;

            if (_auto_progress == true)
                update_progress();
        }
    }


    private weak Task? _parent = null;
    public Task parent
    {
        get { return _parent; }
    }

    private GLib.SList<Task> _childs = new GLib.SList<Task>();
    public GLib.SList<Task> childs
    {
        get { return _childs; }
    }

    public bool has_childs { get { return _childs != null; } }
    public int n_childs { get { return (int)_childs.length(); } }


    public Task(int id, string name)
    {
        this.id = Util.gen_id_if_zero(id);
        _name = name;
    }


    public Task.copy(Task from)
    {
        this.id = Util.gen_new_id();
        copy_properties_from(from);
    }



    public void copy_properties_from(Task from)
    {
        name = from._name;
        auto_type = from._auto_type;
        task_type = from._task_type;
        auto_progress = from._auto_progress;
        progress = from._progress;
    }




    public signal void subtree_changed(Task child);
    public signal void subtree_added(Task child);
    public signal void subtree_removing(Task child);
    public signal void subtree_removed(Task was_parent, Task child);


    protected void notify_subtree_changed(Task child)
    {
        update_progress();

        if (_parent == null) subtree_changed(child);
        else _parent.notify_subtree_changed(child);
    }

    protected void notify_subtree_added(Task child)
    {
        if (_parent == null) subtree_added(child);
        else _parent.notify_subtree_added(child);
    }

    protected void notify_subtree_removing(Task child)
    {
        if (_parent == null) subtree_removing(child);
        else _parent.notify_subtree_removing(child);
    }

    protected void notify_subtree_removed(Task was_parent, Task child)
    {
        if (_parent == null) subtree_removed(was_parent, child);
        else _parent.notify_subtree_removed(was_parent, child);
    }


    public delegate void TaskDelegate(Task task);



    public unowned Task? nth_child(int n)
    {
        if (n >= 0  &&  n < _childs.length())
            return _childs.nth_data(n);
        else
            return null;
    }




    public void add_child(Task child)
    {
        child._parent = this;
        _childs.append(child);

        update_progress();

        child.recursive(notify_subtree_added);
    }


    public void remove_child(Task child)
    {
        // When removing subtree, subtree_removing signal is thrown on root for
        // every item in subtree. But subtree_removed signal is thrown only for
        // root of removed subtree
        child.recursive_from_leafs(notify_subtree_removing);

        child._parent = null;
        _childs.remove(child);

        update_progress();

        notify_subtree_removed(this, child);
    }



    public void recursive(TaskDelegate func)
    {
        func(this);

        foreach (var child in _childs)
            child.recursive(func);
    }

    public void recursive_from_leafs(TaskDelegate func)
    {
        foreach (var childs in _childs)
            childs.recursive_from_leafs(func);

        func(this);
    }



    public void update_progress()
    {
        if (auto_progress && has_childs)
        {
            var new_progress = calc_child_progress();

            if (progress != new_progress)
            {
                _progress = new_progress;
                notify_subtree_changed(this);
            }
        }
    }

    public double calc_child_progress()
    {
        double sum = 0.0;
        foreach (var child in _childs)
            sum += child.progress;

        return sum / n_childs;
    }
}
