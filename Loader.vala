// $Id: Loader.vala 91 2010-11-24 12:44:17Z mitrandir $

errordomain LoaderError
{
    CANNOT_OPEN_FILE,
    INVALID_COMMAND
}

public class Loader
{
    Sqlite.Database _db;
    Sqlite.Statement _stmt_load_task_by_id;
    Sqlite.Statement _stmt_load_option;
    Sqlite.Statement _stmt_load_commands;
    Sqlite.Statement _stmt_load_plans;

    GLib.HashTable<int, Task> _tasks;


    public Loader(string filename)
        throws LoaderError
    {
        _tasks = new GLib.HashTable<int, Task>(null, null);

        Sqlite.Database.open(filename, out _db);
        if (_db == null)
            throw new LoaderError.CANNOT_OPEN_FILE(_("Cannot open DB"));


        _db.prepare_v2(
            "SELECT value FROM options WHERE name = ?",
            -1, out _stmt_load_option
        );

        _db.prepare_v2(
            "SELECT id, parent, name, type, auto_type, progress, auto_progress FROM tasks WHERE id = ?",
            -1, out _stmt_load_task_by_id
        );

        _db.prepare_v2(
            "SELECT id, type, current, a, b, c, d, e, f FROM commands WHERE plan_id = ? ORDER BY id",
            -1, out _stmt_load_commands
        );

        _db.prepare_v2(
            "SELECT id, name, root_id FROM plans ORDER BY id",
            -1, out _stmt_load_plans
        );
    }


    // This destructor is needed because all prepared statements must be freed before
    // closing DB. Without explicit destructor i don't know how to control destruction order
    // of class fields.
    ~Loader()
    {
        _stmt_load_task_by_id = null;
        _stmt_load_option = null;
        _stmt_load_commands = null;
        _stmt_load_plans = null;
    }


#if 0
    int load_int_option(string name, int default = 0)
    {
        _stmt_load_option.reset();
        _stmt_load_option.bind_text(1, name);

        if (_stmt_load_option.step() == Sqlite.ROW)
            return _stmt_load_option.column_int(0);
        else
            return default;
    }
#endif


    string load_string_option(string name, string default = "")
    {
        _stmt_load_option.reset();
        _stmt_load_option.bind_text(1, name);

        if (_stmt_load_option.step() == Sqlite.ROW)
            return _stmt_load_option.column_text(0);
        else
            return default;
    }


    public List<Plan> load_plans()
        throws LoaderError
    {
        _stmt_load_plans.reset();

        var plans = new List<Plan>();

        while (_stmt_load_plans.step() == Sqlite.ROW)
        {
            var id = _stmt_load_plans.column_int(0);
            var name = _stmt_load_plans.column_text(1);
            var root_id = _stmt_load_plans.column_int(2);
            var command_stack = load_commands(id);

            plans.append(new Plan(id, name, task(root_id), command_stack));
        }

        return plans;
    }


    Task? task(int id)
    {
        Task task;

        if (_tasks.lookup_extended(id, null, out task))
            return task;
        else
            // load_task puts task into _tasks by itself
            return load_task(id);
    }



    int parse_task(Sqlite.Statement stmt, out Task task)
    {
        task = new Task(stmt.column_int(0), stmt.column_text(2));
        task.auto_type = stmt.column_int(4) == 1;
        switch (stmt.column_text(3))
        {
            case "check": task.task_type = Task.TaskType.CHECK; break;
            case "progress": task.task_type = Task.TaskType.PROGRESS; break;
        }
        task.auto_progress = stmt.column_int(6) == 1;
        task.progress = stmt.column_double(5);

        var id = stmt.column_int(0);

        _tasks.replace(id, task);

        return id;
    }


    Task? load_task(int id)
    {
        _stmt_load_task_by_id.reset();
        _stmt_load_task_by_id.bind_int(1, id);

        if (_stmt_load_task_by_id.step() == Sqlite.ROW)
        {
            Task task;
            parse_task(_stmt_load_task_by_id, out task);

            load_childs(task, id);

            return task;
        }
        else
            return null;
    }

    void load_childs(Task parent, int parent_id)
    {
        Sqlite.Statement stmt;
        _db.prepare_v2(
            "SELECT id, parent, name, type, auto_type, progress, auto_progress FROM tasks WHERE parent = ? ORDER BY sort",
            -1, out stmt
        );
        stmt.reset();
        stmt.bind_int(1, parent_id);

        while (stmt.step() == Sqlite.ROW)
        {
            Task child;
            int child_id = parse_task(stmt, out child);

            load_childs(child, child_id);

            parent.add_child(child);
        }
    }



    CommandStack load_commands(int plan_id)
        throws LoaderError
    {
        var command_stack = new CommandStack();

        Command? current = null;

        _stmt_load_commands.reset();
        _stmt_load_commands.bind_int(1, plan_id);

        while (_stmt_load_commands.step() == Sqlite.ROW)
        {
            // var id = _stmt_load_commands.column_int(0);
            Command cmd = null;

            var is_current = _stmt_load_commands.column_int(2) == 1;

            var type = _stmt_load_commands.column_text(1);
            switch (type)
            {
                case "change":
                {
                    var subject = task(_stmt_load_commands.column_int(3));
                    var before = task(_stmt_load_commands.column_int(4));
                    var after = task(_stmt_load_commands.column_int(5));
                    cmd = new ChangeCommand(subject, before, after);
                    break;
                }

                case "add":
                {
                    var parent = task(_stmt_load_commands.column_int(4));
                    var subject = task(_stmt_load_commands.column_int(3));
                    cmd = new AddCommand(parent, subject);
                    break;
                }

                case "delete":
                {
                    var parent = task(_stmt_load_commands.column_int(4));
                    var subject = task(_stmt_load_commands.column_int(3));
                    cmd = new DeleteCommand(parent, subject);
                    break;
                }

                default:
                    throw new LoaderError.INVALID_COMMAND(_("Invalid command: %s").printf(type));
            }

            if (cmd != null)
                command_stack.add_command(cmd);

            if (is_current)
                current = cmd;
        }

        command_stack.current = current;

        return command_stack;
    }



    public void load_login_password(out string login, out string password)
    {
        login = load_string_option("login");
        password = load_string_option("password");
    }
}
