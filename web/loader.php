<?php

require_once("plan_set.php");
require_once("db.php");

class Loader
{
    var $db;

    var $tasks_by_id = array();

    var $stmt_load_task_by_id;
    var $stmt_load_plans;
    var $stmt_load_commands;
    var $stmt_load_option;

    function Loader($filename)
    {
        $this->db = new PDO("sqlite:$filename");

        db_create_tables($this->db, false);


        $this->stmt_load_task_by_id = $this->db->prepare(
            "SELECT id, parent, name, type, auto_type, progress, auto_progress FROM tasks WHERE id = :id"
        );

        $this->stmt_load_plans = $this->db->prepare(
            "SELECT id, name, root_id FROM plans ORDER BY id"
        );

        $this->stmt_load_commands = $this->db->prepare(
            "SELECT id, type, current, a, b, c, d, e, f FROM commands WHERE plan_id = :plan_id ORDER BY id"
        );

        $this->stmt_load_option = $this->db->prepare(
            "SELECT value FROM options WHERE name=:name"
        );
    }

    function load_option($name)
    {
        $this->stmt_load_option->execute(array(":name" => $name));
        $row = $this->stmt_load_option->fetch();
        $this->stmt_load_option->closeCursor();
        if ($row != null)
            return $row[0];

        return null;
    }

    function task_by_id($id)
    {
        if (! empty($this->tasks_by_id[$id]))
            return  $this->tasks_by_id[$id];
        else
            return $this->load_task($id);
    }

    function load_task($id)
    {
        $this->stmt_load_task_by_id->execute(array(":id" => $id));
        $row = $this->stmt_load_task_by_id->fetch();
        $this->stmt_load_task_by_id->closeCursor();

        if ($row)
        {
            $task = $this->parse_task($row);

            $this->load_childs($task, $id);

            return $task;
        }
        else
            return null;
    }


    function parse_task($row)
    {
        $task = new Task($row['id'], $row['name']);
        $task->auto_type = $row['auto_type'] == 1;
        $task->type = $row['type'];
        $task->auto_progress = $row['auto_progress'];
        $task->progress = $row['progress'];
        $id = $row['id'];

        $this->tasks_by_id[$id] = $task;

        return $task;
    }


    function load_childs(&$root, $parent_id)
    {
        $stmt = $this->db->prepare("SELECT id, parent, name, type, auto_type, progress, auto_progress FROM tasks WHERE parent = :parent ORDER BY sort");

        $stmt->execute(array(":parent" => $parent_id));

        while ($row = $stmt->fetch())
        {
            $child = $this->task_by_id($row['id']);
            $root->add_child($child);
        }

        $stmt->closeCursor();
    }


    function load_plans($plan_set)
    {
        $this->stmt_load_plans->execute();

        while ($row = $this->stmt_load_plans->fetch())
        {
            $root = $this->task_by_id($row['root_id']);

            $command_stack = $this->load_commands($row['id']);

            $plan = new Plan($row['id'], $row['name'], $root, $command_stack);
            $plan_set->add_plan($plan);
        }

        $this->stmt_load_plans->closeCursor();
    }

    function load_plan_set()
    {
        $plan_set = new PlanSet();
        $this->load_plans($plan_set);

        $plan_set->login = $this->load_option("login");
        $plan_set->password = $this->load_option("password");

        return $plan_set;
    }


    function load_commands($plan_id)
    {
        $command_stack = new CommandStack();

        $this->stmt_load_commands->execute(array(":plan_id" => $plan_id));

        while ($row = $this->stmt_load_commands->fetch())
        {
            switch ($row['type'])
            {
                case 'change':
                {
                    $cmd = new ChangeCommand(
                        $this->task_by_id($row['a']),
                        $this->task_by_id($row['b']),
                        $this->task_by_id($row['c'])
                    );
                    break;
                }
                case 'add':
                {
                    $cmd = new AddCommand(
                        $this->task_by_id($row['b']),
                        $this->task_by_id($row['a'])
                    );
                    break;
                }
                case 'delete':
                {
                    $cmd = new DeleteCommand(
                        $this->task_by_id($row['b']),
                        $this->task_by_id($row['a'])
                    );
                    break;
                }
            }

            $command_stack->add_command($cmd);

            if ($row['current'] == 1)
                $command_stack->current = $cmd;
        }

        $this->stmt_load_commands->closeCursor();

        return $command_stack;
    }
}

?>
