<!DOCTYPE HTML>
<?php
$t1 = '<h2>Hello World!!!</h2>' ;
$t2 = '<b>This is a test</b>' ;
define("test_url", "https://www.google.com");
?>

<html lang="en">
<head>
   <meta charset="UTF-8">
   <title>PHP test</title>
</head>

<body>
<?php echo $t1 ; ?>
<!--
<?php echo $t2 ; ?>
<p><?php echo 'the site is ' . test_url ; ?></p>
-->
<?php echo "<p style='color : red'>Hello World</p>" ; ?>
<?php phpinfo() ; ?>
</html>
