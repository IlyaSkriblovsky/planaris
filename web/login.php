<?php require_once("config.inc.php"); ?>
<?php
    if (! empty($_REQUEST['login']))
    {
        $login = $_REQUEST['login'];
        $pass  = $_REQUEST['password'];

        $stmt = $db->prepare("SELECT * FROM users WHERE login=:login AND password=:password");
        $stmt->execute(array("login" => $login, "password" => $pass));
        $row = $stmt->fetch();

        if ($row == null)
            $error = "Invalid login/password";
        else
        {
            $_SESSION['user'] = array();
            $_SESSION['user']['id'] = $row['id'];
            $_SESSION['user']['login'] = $row['login'];

            header("Location: index.php");
        }
    }
?>

<?php require_once("header.inc.html"); ?>

<h1>Login</h1>

<form method="POST">
    <table class="login">
        <?php if (! empty($error)) { ?>
            <tr><td colspan="2"><div class="error"><?php echo $error; ?></div></td></tr>
        <?php } ?>

        <tr>
            <th>Login:</td>
            <td><input type="text" name="login" value="<?php if (! empty($_REQUEST['login'])) echo htmlspecialchars($_REQUEST['login']); ?>" /><td>
        </tr>
        <tr>
            <th>Password:</td>
            <td><input type="password" name="password" /></td>
        </tr>
        <tr>
            <td colspan="2">
                <input type="submit" value="Login" />
            </td>
        </tr>
    </table>
</form>

<?php require_once("footer.inc.html"); ?>
