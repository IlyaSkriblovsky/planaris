// $Id: Saver.vala 91 2010-11-24 12:44:17Z mitrandir $

errordomain SaverError
{
    CANNOT_OPEN_FILE,
    CANNOT_CREATE_TABLE,
    INVALID_COMMAND
}

public class Saver
{
    Sqlite.Database _db;
    Sqlite.Statement _stmt_save_plan;
    Sqlite.Statement _stmt_save_option;
    Sqlite.Statement _stmt_save_command;

    GLib.HashTable<Task, int> _ids;

    public Saver(string filename)
        throws SaverError
    {
        _ids = new GLib.HashTable<Task, int>(null, null);

        Sqlite.Database.open(filename, out _db);
        if (_db == null)
            throw new SaverError.CANNOT_OPEN_FILE(_("Cannot open DB"));

        _db.exec("DROP TABLE IF EXISTS tasks");
        if (_db.exec("CREATE TABLE tasks (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "parent INTEGER, " +
                    "name TEXT, " +
                    "type VARCHAR(20), " +
                    "auto_type BOOL, " +
                    "progress DOUBLE, " +
                    "auto_progress BOOL, " +
                    "sort INTEGER" +
                    ")")
                != Sqlite.OK)
            throw new SaverError.CANNOT_CREATE_TABLE(_("Cannot write to DB"));

        _db.exec("DROP TABLE IF EXISTS commands");
        _db.exec("CREATE TABLE commands (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "plan_id INTEGER, " +
                    "type VARCHAR(20), " +
                    "current BOOL, " +
                    "a, b, c, d, e, f)");

        _db.exec("DROP TABLE IF EXISTS plans");
        _db.exec("CREATE TABLE plans (" +
                    "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
                    "name VARCHAR(20), " +
                    "root_id INTEGER "+
                    ")");

        _db.exec("DROP TABLE IF EXISTS options");
        _db.exec("CREATE TABLE IF NOT EXISTS options (name VARCHAR(30) PRIMARY KEY, value)");

        prepare_statements();

        save_option("dbversion", 1);
    }


    // This destructor is needed because all prepared statements must be freed before
    // closing DB. Without explicit destructor i don't know how to control destruction order
    // of class fields.
    ~Saver()
    {
        _stmt_save_plan = null;
        _stmt_save_option = null;
        _stmt_save_command = null;
    }


    public void begin()
    {
        _db.exec("BEGIN TRANSACTION;");
    }

    public void commit()
    {
        _db.exec("COMMIT TRANSACTION;");
    }


    void prepare_statements()
    {
        _db.prepare_v2(
            "INSERT INTO plans (id, name, root_id) VALUES (?, ?, ?)",
            -1, out _stmt_save_plan
        );

        _db.prepare_v2(
            "REPLACE INTO options (name, value) VALUES (?, ?)",
            -1, out _stmt_save_option
        );

        _db.prepare_v2(
            "INSERT INTO commands (id, plan_id, type, current, a, b, c, d, e, f) VALUES " +
                                 "(NULL, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
            -1, out _stmt_save_command
        );
    }


    void save_option(string name, int value)
    {
        _stmt_save_option.reset();
        _stmt_save_option.bind_text(1, name);
        _stmt_save_option.bind_int(2, value);
        _stmt_save_option.step();
    }


    void save_string_option(string name, string value)
    {
        _stmt_save_option.reset();
        _stmt_save_option.bind_text(1, name);
        _stmt_save_option.bind_text(2, value);
        _stmt_save_option.step();
    }


    int task_id(Task? task)
    {
        if (task == null)
            return 0;

        int id;
        if (_ids.lookup_extended(task, null, out id))
            return id;
        else
        {
            // save_task puts new id into _ids by itself
            return save_task(task);
        }
    }


    public int save_plan(Plan plan)
        throws SaverError
    {
        _stmt_save_plan.reset();
        _stmt_save_plan.bind_int(1, plan.id);
        _stmt_save_plan.bind_text(2, plan.name);
        _stmt_save_plan.bind_int(3, task_id(plan.root));
        _stmt_save_plan.step();
        var id = (int)_db.last_insert_rowid();

        save_commands(plan.command_stack, id);

        return id;
    }


    int save_task(Task task, int sort = 0)
    {
        Sqlite.Statement stmt;
        _db.prepare_v2(
            "INSERT INTO tasks (id, parent, name, type, auto_type, progress, auto_progress, sort) VALUES (?, ?, ?, ?, ?, ?, ?, ?)",
            -1, out stmt
        );

        string type = "?";
        switch (task.task_type)
        {
            case Task.TaskType.CHECK: type = "check"; break;
            case Task.TaskType.PROGRESS: type = "progress"; break;
        }

        stmt.reset();
        stmt.bind_int(1, task.id);
        stmt.bind_int(2, task_id(task.parent));
        stmt.bind_text(3, task.name);
        stmt.bind_text(4, type);
        stmt.bind_int(5, task.auto_type ? 1 : 0);
        stmt.bind_double(6, task.progress);
        stmt.bind_int(7, task.auto_progress ? 1 : 0);
        stmt.bind_int(8, sort);
        stmt.step();

        _ids.replace(task, task.id);

        int child_sort = 0;
        foreach (var child in task.childs)
            save_task(child, child_sort++);

        return task.id;
    }


    int save_command(Command command, int plan_id, bool current)
        throws SaverError
    {
        _stmt_save_command.reset();
        for (var i = 4; i <= 9; i++)
            _stmt_save_command.bind_null(i);

        _stmt_save_command.bind_int(1, plan_id);
        _stmt_save_command.bind_int(3, current ? 1 : 0);

        if (command is ChangeCommand)
        {
            _stmt_save_command.bind_text(2, "change");
            var change = command as ChangeCommand;
            _stmt_save_command.bind_int(4, task_id(change.subject));
            _stmt_save_command.bind_int(5, task_id(change.before));
            _stmt_save_command.bind_int(6, task_id(change.after));
        }
        else if (command is AddCommand)
        {
            _stmt_save_command.bind_text(2, "add");
            var add = command as AddCommand;
            _stmt_save_command.bind_int(4, task_id(add.subject));
            _stmt_save_command.bind_int(5, task_id(add.parent));
        }
        else if (command is DeleteCommand)
        {
            _stmt_save_command.bind_text(2, "delete");
            var del = command as DeleteCommand;
            _stmt_save_command.bind_int(4, task_id(del.subject));
            _stmt_save_command.bind_int(5, task_id(del.parent));
        }
        else
            throw new SaverError.INVALID_COMMAND(_("Unknown command"));


        _stmt_save_command.step();

        return (int)_db.last_insert_rowid();
    }

    void save_commands(CommandStack command_stack, int plan_id)
        throws SaverError
    {
        var current = command_stack.current;
        foreach (var command in command_stack.commands)
        {
            save_command(
                command, plan_id,
                command == current
            );
        }
    }



    public void save_login_password(string login, string password)
    {
        save_string_option("login", login);
        save_string_option("password", password);
    }
}
