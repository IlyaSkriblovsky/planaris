<?php
header("Content-type: text/plain");
header("Content-Disposition: attachment;filename=post.php");
header("Content-Transfer-Encoding: binary");
header('Pragma: no-cache');
header('Expires: 0');
// Send the file contents.
set_time_limit(0);
readfile("post.php");
?>
