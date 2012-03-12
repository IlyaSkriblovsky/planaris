<?php require_once("config.inc.php"); ?>
<?php require_once("header.inc.html"); ?>

<h1>Welcome to Planaris online sync</h1>

<p>
    <b>Planaris</b> is hierarhical task manager for N900 and desktop PCs
</p>

<p>
    <a href="download/">You can download Planaris here</a>
</p>

<p>
    This site is used for online synchronization of Planaris task databases
</p>

<?php
    if (empty($_SESSION['user']))
    {
?>
    <p>
        You must <a href="register.php">register here</a> in order to use online sync
    </p>

    <p>
        <a href="login.php">Login</a>
    </p>
<?php
    }
    else
    {
?>
    <p>
        You have logged in as <b><?php echo $_SESSION['user']['login'];?></b> (<a href="logout.php">logout</a>)
    </p>
<?php
    }
?>

<?php require_once("footer.inc.html"); ?>
