<?php

require_once("plan_set.php");
require_once("db.php");

class Saver
{
    var $db;

    function Saver($filename)
    {
        $this->db = new PDO("sqlite:$filename");

        db_create_tables($this->db, true);
    }


    function save_task($task, $sort = 0)
    {
        $stmt = $this->db->prepare(
            "INSERT INTO tasks (id, parent, name, type, auto_type, progress, auto_progress, sort)"
           ." VALUES (:id, :parent, :name, :type, :auto_type, :progress, :auto_progress, :sort)"
        );

        $stmt->execute(array(
            ":id"       => $task->id,
            ":parent"   => ($task->parent != null ? $task->parent->id : 0),
            ":name"     => $task->name,
            ":type"     => $task->type,
            ":auto_type"=> $task->auto_type,
            ":progress" => $task->progress,
            ":auto_progress" => $task->auto_progress,
            ":sort"     => $sort
        ));
        $stmt->closeCursor();

        $child_sort = 0;
        foreach ($task->childs as $child)
            $this->save_task($child, $child_sort++);

        return $task->id;
    }



    function save_plan($plan)
    {
        $stmt = $this->db->prepare("INSERT INTO plans (id, name, root_id) VALUES (:id, :name, :root_id)");

        $this->save_task($plan->root);

        $stmt->execute(array(
            ":id" => $plan->id,
            ":name" => $plan->name,
            ":root_id" => $plan->root->id
        ));
        $stmt->closeCursor();
    }



    function save_option($name, $value)
    {
        $stmt = $this->db->prepare("INSERT INTO options (name, value) VALUES (:name, :value)");
        //echo $this->db->errorCode();
        $stmt->execute(array(":name" => $name, ":value" => $value));
        $stmt->closeCursor();
    }


    function save_plan_set($plan_set)
    {
        $this->db->exec("BEGIN TRANSACTION");

        foreach ($plan_set->plans as $plan)
            $this->save_plan($plan);

        $this->save_option("login", $plan_set->login);
        $this->save_option("password", $plan_set->password);

        $this->db->exec("COMMIT TRANSACTION");
    }
}

?>
