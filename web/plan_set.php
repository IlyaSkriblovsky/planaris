<?php

function print_indent($indent)
{
    $str = "";
    for ($i = 0; $i < $indent; $i++)
        $str .= " ";
    print $str;
}

class Task
{
    var $id;
    var $name = "";
    var $type = "check";
    var $auto_type = true;
    var $progress = 0.0;
    var $auto_progress = true;
    var $parent = null;
    var $childs = array();


    function Task($id, $name)
    {
        $this->id = $id;
        $this->name = $name;
    }

    function copy_properties($from)
    {
        $this->name = $from->name;
        $this->type = $from->type;
        $this->auto_type = $from->auto_type;
        $this->progress = $from->progress;
        $this->auto_progress = $from->auto_progress;
    }

    function add_child($task)
    {
        $this->childs[$task->id] = $task;
        $task->parent = $this;
    }

    function remove_child($task)
    {
        $task->parent = null;
        unset($this->childs[$task->id]);

        if (count($this->childs) == 0 && $this->auto_progress)
            $this->progress = $task->progress;
    }

    function find_task_by_id($id)
    {
        if ($this->id == $id) return $this;

        foreach ($this->childs as $child)
        {
            $ret = $child->find_task_by_id($id);
            if ($ret != null)
                return $ret;
        }

        return null;
    }

    function dump($indent = 0)
    {
        print_indent($indent);
        print "($this->id)$this->name $this->progress\n";

        foreach ($this->childs as $child)
            $child->dump($indent + 2);
    }
}

class Command
{
}

class ChangeCommand extends Command
{
    var $subject;
    var $before;
    var $after;

    function ChangeCommand($subject, $before, $after)
    {
        $this->subject = $subject;
        $this->before = $before;
        $this->after = $after;
    }

    function dump($indent = 0)
    {
        print_indent($indent);
        echo "Change (" . $this->subject->name . "): " . $this->before->name ."->". $this->after->name . "\n";
    }


    function apply_to_plan($plan)
    {
        $new_subject = $plan->root->find_task_by_id($this->subject->id);
        $new_subject->copy_properties($this->after);
    }
}

class AddCommand extends Command
{
    var $subject;
    var $parent;

    function AddCommand($parent, $subject)
    {
        $this->parent = $parent;
        $this->subject = $subject;
    }

    function dump($indent = 0)
    {
        print_indent($indent);
        echo "Add " . $this->parent->name ."->". $this->subject->name . "\n";
    }


    function apply_to_plan($plan)
    {
        $new_parent = $plan->root->find_task_by_id($this->parent->id);
        $new_parent->add_child($this->subject);
    }
}

class DeleteCommand extends Command
{
    var $subject;
    var $parent;

    function DeleteCommand($parent, $subject)
    {
        $this->parent = $parent;
        $this->subject = $subject;
    }

    function dump($indent = 0)
    {
        print_indent($indent);
        echo "Delete " . $this->parent->name ."->". $this->subject->name . "\n";
    }


    function apply_to_plan($plan)
    {
        $new_parent = $plan->root->find_task_by_id($this->parent->id);
        $new_parent->remove_child($this->subject);
    }
}

class CommandStack
{
    var $commands = array();
    var $current = null;

    function add_command($cmd)
    {
        $this->commands[] = $cmd;
    }

    function dump($indent = 0)
    {
        foreach ($this->commands as $cmd)
            $cmd->dump($indent);
    }
}

class Plan
{
    var $id;
    var $name;
    var $root;
    var $command_stack;

    function Plan($id, $name, $root, $command_stack)
    {
        $this->id = $id;
        $this->name = $name;

        if ($this->root == null)
            $this->root = new Task(1, "<root>");

        $this->root = $root;
        $this->command_stack = $command_stack;
    }

    function dump($indent = 0)
    {
        print_indent($indent);
        print "($this->id)$this->name:\n";
        $this->root->dump($indent+2);
        $this->command_stack->dump($indent+2);
    }
}

class PlanSet
{
    var $plans = array();

    var $login;
    var $password;

    function add_plan($plan)
    {
        $this->plans[$plan->id] = $plan;
    }

    function dump()
    {
        echo "PlanSet:\n";
        foreach ($this->plans as $plan)
            $plan->dump(2);
    }
}


function merge_plan_sets($ps1, $ps2)
{
    $merged = new PlanSet();
    $merged->login = $ps2->login;
    $merged->password = $ps2->password;

    $plan_ids = array();
    foreach ($ps1->plans as $p) $plan_ids[$p->id] = $p->id;
    foreach ($ps2->plans as $p) $plan_ids[$p->id] = $p->id;

    foreach ($plan_ids as $plan_id)
    {
        if (empty($ps2->plans[$plan_id]))
            $merged->add_plan($ps1->plans[$plan_id]);
        elseif (empty($ps1->plans[$plan_id]))
            $merged->add_plan($ps2->plans[$plan_id]);
        else
            $merged->add_plan(merge_plan($ps1->plans[$plan_id], $ps2->plans[$plan_id]));
    }

    return $merged;
}


function merge_plan($p1, $p2)
{
    $merged = new Plan($p2->id, $p2->name, $p1->root, new CommandStack());

    $done_all_commands = false;

    foreach ($p2->command_stack->commands as $cmd)
    {
        if (! $done_all_commands)
        {
            $cmd->apply_to_plan($p1);

            if ($p2->command_stack->current == $cmd)
                $done_all_commands = true;
        }
        else
            $merged->command_stack->add_command($cmd);
    }

    return $merged;
}

?>
