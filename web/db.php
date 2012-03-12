<?php

function db_create_tables($db, $drop_tables)
{
    if ($drop_tables) $db->exec("DROP TABLE IF EXISTS tasks");
    $db->exec(
        "CREATE TABLE IF NOT EXISTS tasks ("
       ."id INTEGER PRIMARY KEY AUTOINCREMENT, "
       ."parent INTEGER, "
       ."name TEXT, "
       ."type VARCHAR(20), "
       ."auto_type BOOL, "
       ."progress DOUBLE, "
       ."auto_progress BOOL, "
       ."sort INTEGER"
       .")"
    );

    if ($drop_tables) $db->exec("DROP TABLE IF EXISTS commands");
    $db->exec(
        "CREATE TABLE commands ("
       ."id INTEGER PRIMARY KEY AUTOINCREMENT, "
       ."plan_id INTEGER, "
       ."type VARCHAR(20), "
       ."current BOOL, "
       ."a, b, c, d, e, f)"
    );

    if ($drop_tables) $db->exec("DROP TABLE IF EXISTS plans");
    $db->exec(
        "CREATE TABLE plans ("
       ."id INTEGER PRIMARY KEY AUTOINCREMENT, "
       ."name VARCHAR(20), "
       ."root_id INTEGER "
       .")"
    );

    if ($drop_tables) $db->exec("DTOP TABLE IF EXISTS options");
    $db->exec("CREATE TABLE IF NOT EXISTS options (name VARCHAR(30) PRIMARY KEY, value)");
}
?>
