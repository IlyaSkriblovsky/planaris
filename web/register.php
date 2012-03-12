<?php require_once("config.inc.php"); ?>
<?php
    if (! empty($_REQUEST['login']))
    {
        $login = $_REQUEST['login'];
        $pass1 = $_REQUEST['password1'];
        $pass2 = $_REQUEST['password2'];

        if ($pass1 != $pass2)
            $error = "Passwords don't match";
        else
        {
            $stmt = $db->prepare("SELECT * FROM users WHERE login=:login");
            $stmt->execute(array("login" => $_REQUEST['login']));
            $row = $stmt->fetch();

            if ($row != null)
                $error = "User with this login already exists";
            else
            {
                $stmt = $db->prepare("INSERT INTO users (login, password) VALUES (:login, :password)");
                $stmt->execute(array("login" => $login, "password" => $pass1));

                $_SESSION['user'] = array();
                $_SESSION['user']['id'] = $db->lastInsertId();
                $_SESSION['user']['login'] = $login;

                header("Location: index.php");
            }
        }
    }
?>

<?php require_once("header.inc.html"); ?>

<h1>Registration</h1>

<form method="POST">
    <table class="register">
<?php if (! empty($error)) { ?>
    <tr><td colspan="2"><div class="error"><?php echo $error; ?></div></td></tr>
<?php } ?>

        <tr>
            <th>Login:</th>
            <td><input type="text" name="login" value="<?php if (! empty($_REQUEST['login'])) echo htmlspecialchars($_REQUEST['login']); ?>" /></td>
        </tr>
        <tr>
            <th>Password:</th>
            <td><input type="password" name="password1" /></td>
        </tr>
        <tr>
            <th>One more time:</th>
            <td><input type="password" name="password2" /></td>
        </tr>
        <tr>
            <td colspan="2">
                <input type="submit" value="Register" /></td>
            </tr>
        </tr>
    </table>
</form>


<?php require_once("footer.inc.html"); ?>
