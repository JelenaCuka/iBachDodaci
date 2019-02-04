<?php

class PlaylistSongController
{
    private $playlistSong;

    public function __construct($playlistSong)
    {
        $this->playlistSong = $playlistSong;
    }

    public function findSongOnPlaylist($playlistId, $songId)
    {
        if (is_numeric($playlistId) && is_numeric($songId))
        {
            return $this->playlistSong->findOne($playlistId, $songId);
        }
        else
        {
            http_response_code(400);
            $row = array();
            $row["status"] = "400";
            $row["description"] = "Bad request.";

            return json_encode($row);
        }
    }

    public function findAllSongsOnPlaylist($playlistId)
    {
        if (is_numeric($playlistId))
        {
            return $this->playlistSong->findAllSongsOnPlaylist($playlistId);
        }
        else
        {
            http_response_code(400);
            $row = array();
            $row["status"] = "400";
            $row["description"] = "Bad request.";

            return json_encode($row);
        }
    }

    public function saveNewSongOnPlaylist()
    {
        if ($_POST["save"] == 1)
        {
            return $this->playlistSong->save();
        }
        else
        {
            http_response_code(400);
            $row = array();
            $row["status"] = "400";
            $row["description"] = "Bad request.";

            return json_encode($row);
        }
    }

    public function deleteSongFromPlaylist()
    {
        if ($_POST["delete"] == 1)
        {
            return $this->playlistSong->delete();
        }
        else
        {
            http_response_code(400);
            $row = array();
            $row["status"] = "400";
            $row["description"] = "Bad request.";

            return json_encode($row);
        }
    }
}

?>