<?php

header('Content-type: application/json');

require "../../config/database.php";
require "../../model/PlaylistSong.php";
require "../../controller/PlaylistSongController.php";

if (isset($_GET["playlistId"]))
{

    //database connection
    $db = connect();

    //model and controller calls
    $playlistSong = new PlaylistSong($db);
    $playlistSongController = new PlaylistSongController($playlistSong);

    //controller function to push the right data
    print $playlistSongData = $playlistSongController->findAllSongsOnPlaylist( $_GET["playlistId"]);

}

?>