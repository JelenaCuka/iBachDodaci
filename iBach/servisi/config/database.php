<?php

function connect()
{
    $host = "localhost";
    $username = "root";
    $password = "";
    $database = "ibach";

    return new MySqli($host, $username, $password, $database);
}

?>