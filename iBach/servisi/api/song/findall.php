<?php

header('Content-type: application/json');

require "../../config/database.php";
require "../../model/Song.php";
require "../../controller/SongController.php";

$db = connect();
$song = new Song($db);
$songController = new SongController($song);
print $songController->findAllSongs();