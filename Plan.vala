// $Id: Plan.vala 86 2010-11-23 16:56:31Z mitrandir $

public class Plan: Object
{
    public int id { get; private set; }
    public CommandStack command_stack { get; private set; }

    public string name { get; set; }

    public Task root { get; private set; }

    public TaskTreeModel task_model { get; set; }



    public Plan(int id, string name, Task? root, CommandStack? cmd_stack)
    {
        this.id = Util.gen_id_if_zero(id);
        this.name = name;
        this.task_model = new TaskTreeModel.with_root(root);
        this.root = task_model.root;

        if (cmd_stack != null)
            command_stack = cmd_stack;
        else
            command_stack = new CommandStack();
    }
}


public class PlanSet
{
    List<Plan> _plans;

    public List<Plan> plans { get { return _plans; } }

    public string login { get; set; }
    public string password { get; set; }

    public string default_file_name;


    public signal void plan_added(Plan plan);
    public signal void plan_removing(Plan plan);


    public PlanSet()
    {
        login = password = "";

        _plans = new List<Plan>();

        default_file_name = Environment.get_home_dir() + Path.DIR_SEPARATOR_S + ".planaris.sqlite";
    }



    public void add_plan(Plan plan)
    {
        _plans.append(plan);

        plan_added(plan);
    }


    public void remove_plan(Plan plan)
    {
        plan_removing(plan);

        _plans.remove(plan);
    }


    public unowned Plan? plan_by_id(int id)
    {
        foreach (unowned Plan plan in _plans)
            if (plan.id == id)
                return plan;

        return null;
    }


    public void load(string filename = "")
        throws LoaderError
    {
        string fn;
        if (filename == "")
            fn = default_file_name;
        else
            fn = filename;


        var loader = new Loader(fn);

        var new_plans = new List<Plan>();

        foreach (var plan in loader.load_plans())
            new_plans.append(plan);

//        _plans = (owned) new_plans;
        while (_plans.first() != null)
            remove_plan(_plans.first().data);

        foreach (var plan in new_plans)
            add_plan(plan);

        loader.load_login_password(out _login, out _password);
    }


    public void save(string filename = "")
        throws SaverError
    {
        string fn;
        if (filename == "")
            fn = default_file_name;
        else
            fn = filename;


        var saver = new Saver(fn);

        saver.begin();

        foreach (var plan in _plans)
            saver.save_plan(plan);

        saver.save_login_password(login, password);

        saver.commit();
    }
}
