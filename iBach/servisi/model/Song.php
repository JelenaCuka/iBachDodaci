<?php

class Song
{
    private $id;
    private $title;
    private $author;
    private $year;
    private $fileUrl;
    private $db;

    public function __construct($db)
    {
        $this->db = $db;
    }

    public function findOne($id)
    {
        $stmt = $this->db->prepare("SELECT * FROM song WHERE id = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();

        $result = $stmt->get_result();

        if ($result->num_rows === 1)
        {
            $row = $result->fetch_assoc();
            return json_encode($row);
        }
        if ($result->num_rows === 0)
        {
            http_response_code(404);
            $row = array();
            $row["status"] = "404";
            $row["description"] = "Not found.";

            return json_encode($row);
        }

        $stmt->close();
    }

    public function findAll(){
        $stmt = $this->db->prepare('SELECT * FROM song');
        $stmt->execute();

        $result = $stmt->get_result();
        $row = array();
        $songList = array();

        while($r = $result->fetch_object())
        {
            $row = $r;
            array_push($songList,$r);
        }
        return json_encode($songList);
    }

    public function save()
    {
        $this->title = $_POST["title"];
        $this->author = $_POST["author"];
        $this->year = $_POST["year"];
        $this->fileUrl = $_POST["fileUrl"];

        $stmt = $this->db->prepare("INSERT INTO song(title, author, year, file_url) VALUES(?, ?, ?, ?)");
        $stmt->bind_param("ssis", $this->title, $this->author, $this->year, $this->fileUrl);
        $stmt->execute();

        if ($stmt->affected_rows === 1)
        {
            $row = array();
            $row["status"]= "200";
            $row["description"] = "OK. New song added.";
            $stmt->close();

            return json_encode($row);
        }
        else
        {
            http_response_code(500);
            $row = array();
            $row["status"] = "500";
            $row["description"] = "Internal server error. 0 rows affected";
            $stmt->close();

            return json_encode($row);
        }
    }
    public function update($id)
    {
        $this->title = $_POST["title"];
        $this->author = $_POST["author"];
        $this->year = $_POST["year"];
        $this->fileUrl = $_POST["fileUrl"];
    
        $stmt = $this->db->prepare('UPDATE song SET title = ?, author = ?, year = ?, file_url = ? WHERE id = ? ');
        $stmt->bind_param('ssisi', $this->title, $this->author, $this->year, $this->fileUrl, $id);
        $stmt->execute();

        if ($stmt->affected_rows === 1)
        {
            $row = array();
            $row["status"]= "200";
            $row["description"] = "OK. Song updated.";
            $stmt->close();

            return json_encode($row);
        }
        else
        {
            http_response_code(500);
            $row = array();
            $row["status"] = "500";
            $row["description"] = "Internal server error. 0 rows affected";
            $stmt->close();

            return json_encode($row);
        }



    }
}

?>