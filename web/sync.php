<?php
    require_once("config.inc.php");

    require_once("plan_set.php");
    require_once("loader.php");
    require_once("saver.php");

    function die_with_code($code, $message = "")
    {
        header("HTTP/1.0 $code");
        echo $message;
        die();
    }

    if (empty($_FILES['my']))
        die_with_code(400, "No data");
    else
    {
        $clnt_loader = new Loader($_FILES['my']['tmp_name']);
        $clnt_plan_set = $clnt_loader->load_plan_set();

        $find_user = $db->prepare("SELECT * FROM users WHERE login = :login AND password = :password");
        $find_user->execute(array(":login" => $clnt_plan_set->login, ":password" => $clnt_plan_set->password));
        $row = $find_user->fetch();
        if ($row == null)
            die_with_code(400, "Invalid login/password");

        $uid = $row['id'];

        header("Content-Type: text/plain");

        $serv_loader = new Loader("db/$uid.sqlite");
        $serv_plan_set = $serv_loader->load_plan_set();

        $merged_plan_set = merge_plan_sets($serv_plan_set, $clnt_plan_set);

        $tmp_filename = tempnam(sys_get_temp_dir(), "planaris");

        $saver = new Saver("db/$uid.sqlite");
        $saver->save_plan_set($merged_plan_set);
        $saver = new Saver($tmp_filename);
        $saver->save_plan_set($merged_plan_set);

        readfile($tmp_filename);

        unlink($tmp_filename);
    }


    function get_option($db, $optname)
    {
        $get_opt = $db->prepare("SELECT value FROM options WHERE name = :name");
        $get_opt->execute(array(":name" => $optname));
        $row = $get_opt->fetch();
        return $row[0];
    }
?>
