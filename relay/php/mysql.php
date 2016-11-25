<?php

@mysql_connect("localhost", "username", "password") or die("HOLY SHIT THE DATABASE EXPLODED FUCK");
@mysql_select_db("database") or die("Unable to connect to database.");

?>
