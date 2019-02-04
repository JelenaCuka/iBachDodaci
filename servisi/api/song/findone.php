<?php

header('Content-type: application/json');

require "../../config/database.php";
require "../../model/Song.php";
require "../../controller/SongController.php";

if (isset($_GET["id"]))
{

    //database connection
    $db = connect();

    //model and controller calls
    $song = new Song($db);
    $songController = new SongController($song);

    //controller function to push the right data
    print $songController->findSongById($_GET["id"]);

}

?>