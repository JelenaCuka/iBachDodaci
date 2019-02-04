<?php

require "../../model/Song.php";
require "../../controller/SongController.php";

class PlaylistSong
{
    private $playlistId;
    private $songId;
    private $modifiedAt;
    private $deletedAt;
    private $db;

    public function __construct($db)
    {
        $this->db = $db;
        $this->song = new Song($this->db);
        $this->songController = new SongController($this->song);
    }

    //Gets one active playlist song by playlistId and songId
    public function findOne($playlistId, $songId)
    {
        $stmt = $this->db->prepare("SELECT * FROM playlist_song WHERE playlist_id = $playlistId AND song_id = $songId AND deleted_at is null");
        $stmt->execute();

        $result = $stmt->get_result();

        if ($result->num_rows === 1)
        {
            $row = $result->fetch_assoc();

            //Gets song data         
            $songData = $this->songController->findSongById($row["song_id"]);
            $songData = json_decode($songData);
            return json_encode($songData);
        }

        if($result->num_rows === 0)
        {
            http_response_code(404);
            $row = array();
            $row["status"] = "404";
            $row["description"] = "Not found.";

            return json_encode($row);
        }
        $stmt->close();
    }

    //Gets all active songs for one playlist
    public function findAllSongsOnPlaylist($playlistId)
    {
        $stmt = $this->db->prepare("SELECT * FROM playlist_song WHERE playlist_id = $playlistId AND deleted_at is null");
        $stmt->execute();

        $result = $stmt->get_result();     

        if($result->num_rows === 0)
        {
            http_response_code(404);
            $row = array();
            $row["status"] = "404";
            $row["description"] = "Not found.";

            return json_encode($row);
        }

        $row = array();
        $playlistSongs = array();

        while ($r = $result->fetch_object())
        {
            $row = $r;

            //Gets song data         
            $songData = $this->songController->findSongById($row->song_id);
            $songData = json_decode($songData);

            array_push($playlistSongs, $songData);
        }

        return json_encode($playlistSongs);

        $stmt->close();
    }

    public function save()
    {
        $this->playlistId = $_POST["playlistId"];
        $this->songId = $_POST["songId"];

        $this->favoriteSongStatus = $this->checkIfExists($this->playlistId, $this->songId);

        if ($this->favoriteSongStatus == 2)
        {
            $stmt = $this->db->prepare("UPDATE playlist_song
                                        SET deleted_at = null, modified_at = CURRENT_TIME()
                                        WHERE playlist_id = $this->playlistId AND song_id = $this->songId");
            $stmt->execute();

            if ($stmt->affected_rows === 1)
            {
                $row = array();
                $row["status"]= "200";
                $row["description"] = "OK. Song added to playlist.";

                return json_encode($row);
                $stmt->close();
            }
            else
            {
                http_response_code(500);
                $row = array();
                $row["status"] = "500";
                $row["description"] = "Internal server error. 0 rows affected";
                $stmt->close();

                return $row;
            }

        }

        if ($this->favoriteSongStatus == 3)
        {
            $stmt = $this->db->prepare("INSERT INTO playlist_song (playlist_id, song_id)
                                        VALUES ($this->playlistId, $this->songId)");
            $stmt->execute();


            if ($stmt->affected_rows === 1)
            {
                $row = array();
                $row["status"]= "200";
                $row["description"] = "OK. Song added to playlist.";

                return json_encode($row);
                $stmt->close();
            }
            else
            {
                http_response_code(500);
                $row = array();
                $row["status"] = "500";
                $row["description"] = "Internal server error. 0 rows affected";
                $stmt->close();

                return $row;
            }
        }

        if ($this->favoriteSongStatus == 1)
        {
                $row = array();
                $row["status"]= "400";
                $row["description"] = "Song is already on playlist.";

                return json_encode($row);            
        }


    }

    public function delete()
    {
        $this->playlistId = $_POST["playlistId"];
        $this->songId = $_POST["songId"];

        $this->favoriteSongStatus = $this->checkIfExists($this->playlistId, $this->songId);

        if ($this->favoriteSongStatus == 1)
        {
            $stmt = $this->db->prepare("UPDATE playlist_song
                                        SET deleted_at = CURRENT_TIME(), modified_at = CURRENT_TIME()
                                        WHERE playlist_id = $this->playlistId AND song_id = $this->songId");
            $stmt->execute();

            if ($stmt->affected_rows === 1)
            {
                $row = array();
                $row["status"]= "200";
                $row["description"] = "OK. Song deleted from playlist";
                
                return json_encode($row);
                $stmt->close();
            }
            else
            {
                http_response_code(500);
                $row = array();
                $row["status"] = "500";
                $row["description"] = "Internal server error. 0 rows affected";
                $stmt->close();

                return $row;
            }
        }
        else
        {
            $row = array();
            $row["status"]= "404";
            $row["description"] = "Song is not on playlist.";

            return json_encode($row);  
        }
    }

    public function checkIfExists($playlistId, $songId)
    {
        $stmt = $this->db->prepare("SELECT * FROM playlist_song WHERE playlist_id = $playlistId AND song_id = $songId");
        $stmt->execute();

        $result = $stmt->get_result();
        $row = $result->fetch_assoc();

        if ($result->num_rows == 1 && $row["deleted_at"] == null)
        {
            return 1;
        }
        else if ($result->num_rows === 1 && $row["deleted_at"] != null)
        {
            return 2;
        }
        else
        {
            return 3;
        }
        $stmt->close();
    }
}
?>