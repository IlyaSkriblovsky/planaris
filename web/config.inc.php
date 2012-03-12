<?php
    session_start();

    $db = new PDO("sqlite:db/planaris.sqlite");

    $db->query("CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, login, password, is_admin)");
?>
