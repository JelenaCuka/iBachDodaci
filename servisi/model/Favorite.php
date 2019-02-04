<?php

require "../../model/Song.php";
require "../../controller/SongController.php";

class Favorite
{
    private $userId;
    private $songId;
    private $deletedAt;
    private $modifiedAt;
    private $db;

    public function __construct($db)
    {
        $this->db = $db;
        $this->song = new Song($this->db);
        $this->songController = new SongController($this->song);
    }

    //Gets one active favorite song by userId and songId
    public function findOne($userId, $songId)
    {
        $stmt = $this->db->prepare("SELECT * FROM favorite WHERE user_id = $userId AND song_id = $songId AND deleted_at is null");
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

    //Gets all active favorite songs for one user by userId
    public function findAllForUser($userId)
    {
        $stmt = $this->db->prepare("SELECT * FROM favorite WHERE user_id = $userId AND deleted_at is null");
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
        $favoriteSongs = array();

        while ($r = $result->fetch_object())
        {
            $row = $r;

            //Gets song data         
            $songData = $this->songController->findSongById($row->song_id);
            $songData = json_decode($songData);

            array_push($favoriteSongs, $songData);
        }

        return json_encode($favoriteSongs);

        $stmt->close();
    }

    //Koristi se za:
    //1 - Brisanje postojećeg favorita
    //2 - Dodavanje pjesme u favorite koja je već bila favorit 
    //3 - Stvaranje novog zapisa, tj. dodavanje pjesme favorita koja još nije bila favorit
    public function save()
    {
        $this->userId = $_POST["userId"];
        $this->songId = $_POST["songId"];

        $this->favoriteSongStatus = $this->checkIfExists($this->userId, $this->songId);

        if ($this->favoriteSongStatus == 1)
        {
            $stmt = $this->db->prepare("UPDATE favorite
                                        SET deleted_at = CURRENT_TIME(), modified_at = CURRENT_TIME()
                                        WHERE user_id = $this->userId AND song_id = $this->songId");
            $stmt->execute();

            if ($stmt->affected_rows === 1)
            {
                $row = array();
                $row["status"]= "200";
                $row["description"] = "OK. Favorite song removed";
                
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

        if ($this->favoriteSongStatus == 2)
        {
            $stmt = $this->db->prepare("UPDATE favorite
                                        SET deleted_at = null, modified_at = CURRENT_TIME()
                                        WHERE user_id = $this->userId AND song_id = $this->songId");
            $stmt->execute();

            if ($stmt->affected_rows === 1)
            {
                $row = array();
                $row["status"]= "200";
                $row["description"] = "OK. Favorite song added.";

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
            $stmt = $this->db->prepare("INSERT INTO favorite (user_id, song_id)
                                        VALUES ($this->userId, $this->songId)");
            $stmt->execute();


            if ($stmt->affected_rows === 1)
            {
                $row = array();
                $row["status"]= "200";
                $row["description"] = "OK. Favorite song added.";

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
    }

    //Provjerava da li postoji zapis u tablici favorite za određenog korisnika i pjesmu
    //Ovisno o postojanju zapisa: vraća 3 statusa
    //Status 1 - Zapis postoji i aktivan je
    //Status 2 - Zapis postoji i nije aktivan
    //Status 3 - Zapis nije aktivan
    public function checkIfExists($userId, $songId)
    {
        $stmt = $this->db->prepare("SELECT * FROM favorite WHERE user_id = $userId AND song_id = $songId");
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