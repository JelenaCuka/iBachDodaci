<?php

header('Content-type: application/json');

require "../../config/database.php";
require "../../model/Song.php";
require "../../controller/SongController.php";

if (isset($_POST["update"]) && !empty($_POST["update"] && $_GET['id']))
{
    $db = connect();

    $song = new Song($db);
    $songController = new SongController($song);

    print $songController->updateSong($_GET['id']);
}

?>