<?php require_once("config.inc.php"); ?>
<?php
    unset($_SESSION['user']);
    header("Location: index.php");
?>
