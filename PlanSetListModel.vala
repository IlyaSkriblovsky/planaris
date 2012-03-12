// $Id: PlanSetListModel.vala 43 2010-11-13 09:32:38Z mitrandir $

public class PlanSetListModel: GLib.Object, Gtk.TreeModel
{
    int stamp;
    PlanSet plan_set = null;


    private enum Column
    {
        NAME = 0,
        PLAN,
        TOTAL
    }


    public PlanSetListModel(PlanSet plan_set)
    {
        stamp = (int)Random.next_int();

        this.plan_set = plan_set;

        this.plan_set.plan_added.connect(on_plan_added);
        this.plan_set.plan_removing.connect(on_plan_removing);
    }


    public unowned Plan plan_from_path(Gtk.TreePath path)
    {
        Gtk.TreeIter iter;
        get_iter(out iter, path);
        return (Plan)iter.user_data;
    }



    // Private

    void plan_iter(Plan plan, out Gtk.TreeIter iter)
    {
        iter.stamp = stamp;
        iter.user_data = plan;
        iter.user_data2 = null;
        iter.user_data3 = null;
    }



    void on_plan_added(Plan plan)
    {
        Gtk.TreeIter iter;
        plan_iter(plan, out iter);
        row_inserted(get_path(iter), iter);
    }

    void on_plan_removing(Plan plan)
    {
        Gtk.TreeIter iter;
        plan_iter(plan, out iter);
        row_deleted(get_path(iter));
    }



    // TreeModel implementatioin

    public Type get_column_type(int index)
    {
        switch (index)
        {
            case Column.NAME: return typeof(string);
            case Column.PLAN: return typeof(Plan);

            default: return typeof(int);
        }
    }


    public Gtk.TreeModelFlags get_flags()
    {
        return 0;
    }


    public bool get_iter(out Gtk.TreeIter iter, Gtk.TreePath path)
    {
        var i = path.get_indices()[0];

        if (0 <= i && i < plan_set.plans.length())
        {
            plan_iter(plan_set.plans.nth_data(i), out iter);
            return true;
        }

        return false;
    }


    public int get_n_columns()
    {
        return Column.TOTAL;
    }


    public Gtk.TreePath get_path(Gtk.TreeIter iter)
    {
        var path = new Gtk.TreePath();

        path.append_index(plan_set.plans.index((Plan)iter.user_data));

        return path;
    }


    public void get_value(Gtk.TreeIter iter, int column, out Value value)
    {
        var plan = (Plan)iter.user_data;

        switch (column)
        {
            case Column.NAME: value = plan.name; break;
            case Column.PLAN: value = plan; break;

            default: value = 0; break;
        }
    }


    public bool iter_children(out Gtk.TreeIter iter, Gtk.TreeIter? parent)
    {
        if (parent == null)
        {
            if (plan_set.plans.length() > 0)
            {
                plan_iter(plan_set.plans.first().data, out iter);
                return true;
            }
        }

        return false;
    }


    public bool iter_has_child(Gtk.TreeIter iter)
    {
        return false;
    }


    public int iter_n_children(Gtk.TreeIter? iter)
    {
        if (iter == null)
            return (int)plan_set.plans.length();
        else
            return 0;
    }


    public bool iter_next(ref Gtk.TreeIter iter)
    {
        var plan = (Plan)iter.user_data;

        int i = plan_set.plans.index(plan);

        if (i+1 < plan_set.plans.length())
        {
            plan_iter(plan_set.plans.nth_data(i+1), out iter);
            return true;
        }

        return false;
    }


    public bool iter_nth_child(out Gtk.TreeIter iter, Gtk.TreeIter? parent, int n)
    {
        if (parent != null)
            return false;

        if (0 <= n && n < plan_set.plans.length())
        {
            plan_iter(plan_set.plans.nth_data(n), out iter);
            return true;
        }

        return false;
    }


    public bool iter_parent(out Gtk.TreeIter iter, Gtk.TreeIter child)
    {
        return false;
    }


    public void ref_node(Gtk.TreeIter iter)
    {
    }


    public void unref_node(Gtk.TreeIter iter)
    {
    }
}
