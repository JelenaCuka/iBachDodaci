<?php

header('Content-type: application/json');

require "../../config/database.php";
require "../../model/PlaylistSong.php";
require "../../controller/PlaylistSongController.php";

if (isset($_POST["delete"]) && !empty($_POST["delete"]))
{
    //database connection
    $db = connect();

     //model and controller calls
     $playlistSong = new PlaylistSong($db);
     $playlistSongController = new PlaylistSongController($playlistSong);

    //controller function to push the right data
    print $playlistSongData = $playlistSongController->deleteSongFromPlaylist();
}

?>