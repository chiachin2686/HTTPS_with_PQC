<html>
<head>
<meta charset="utf-8">
<title>Get data</title>
</head>
<body>

<?php

// Program to display complete URL
$link = (isset($_SERVER['HTTPS']) && $_SERVER['HTTPS']
=== 'on' ? "https" : "http") . "://" . 
$_SERVER['HTTP_HOST'] . $_SERVER['PHP_SELF'];

$link = $link.'?msg='.$_GET['msg'];

echo $link;

// if (isset($_GET['link'])) {
//     echo $_GET['link'];
// } else {
//     // Fallback behaviour goes here
// }
// $f=fopen('myfile.txt','w');
// fwrite($f, $link);
// fclose($f);
?>

<p class = "recv">Receive data!!</p>
<p class = "recv">URI: <?php echo $_SERVER['REQUEST_URI']; echo $_SERVER['PHP_SELF']; echo $_SERVER['SERVER_NAME']; ?></p>
<p class = "recv">Data: <?php echo $_GET['msg']; ?></p>

</body>
</html>