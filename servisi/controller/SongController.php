<?php

class SongController
{
    private $song;

    public function __construct($song)
    {
        $this->song = $song;
    }

    public function findSongById($id)
    {
        if (is_numeric($id))
        {
            return $this->song->findOne($id);
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

    public function findAllSongs()
    {
        return $this->song->findAll();
    }

    public function saveNewSong()
    {
        if ($_POST["save"] == 1)
        {
            return $this->song->save();
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

    public function updateSong($id)
    {
        if($_POST["update"] == 1 && $_GET['id'])
        {
            return $this->song->update($id);
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