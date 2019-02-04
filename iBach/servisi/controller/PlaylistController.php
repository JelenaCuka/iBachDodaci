<?php

class PlaylistController
{
    private $playlist;

    public function __construct($playlist)
    {
        $this->playlist = $playlist;
    }
    
    public function findAll()
    {
        if ($_GET["findall"] === "1")
        {
            if( isset($_GET["user_id"]) && !empty($_GET["user_id"]) && is_numeric($_GET["user_id"]) ){
                return $this->playlist->findAll($_GET["user_id"]);
            }else{
                http_response_code(400);
                $row = array();
                $row["status"]= "400";
                $row["description"] = "Bad request. Missing parameters";
                return json_encode($row);
            }
        }else
        {
            http_response_code(400);
            $row = array();
            $row["status"] = "400";
            $row["description"] = "Bad request.";

            return json_encode($row);
        }

    }
    
    public function findOne($id)
    {
        if (is_numeric($id) )
        {
            return $this->playlist->findOne($id);

        }else
        {
            http_response_code(400);
            $row = array();
            $row["status"] = "400";
            $row["description"] = "Bad request.";

            return json_encode($row);
        }
    }
    


    public function save()
    {
        if ($_POST["save"] === "1")
        {
            if( isset($_POST["name"]) && !empty($_POST["name"])&&
            isset($_POST["user_id"]) && !empty($_POST["user_id"]) && is_numeric($_POST["user_id"]) ){
                return $this->playlist->save($_POST["name"],$_POST["user_id"] );
            }else{
                http_response_code(400);
                $row = array();
                $row["status"]= "400";
                $row["description"] = "Bad request. Missing parameters";
                return json_encode($row);
            }
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

    public function delete()
    {
        if ($_POST["delete"] === "1" )
        {
            if( isset($_POST["playlist_id"]) && !empty($_POST["playlist_id"]) && is_numeric($_POST["playlist_id"]) ){
                return $this->playlist->delete($_POST["playlist_id"]);
            }else{
                http_response_code(400);
                $row = array();
                $row["status"]= "400";
                $row["description"] = "Bad request.";
                return json_encode($row);
            }
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

    public function update()
    {
        if ($_POST["update"] === "1" )
        {
            if( isset($_POST["id"]) && !empty($_POST["id"])&& is_numeric($_POST["id"]) &&
                isset($_POST["name"]) && !empty($_POST["name"]) ){
                return $this->playlist->update($_POST["id"],$_POST["name"]);
            }else{
                http_response_code(400);
                $row = array();
                $row["status"]= "400";
                $row["description"] = "Bad request. Missing parameters";
                return json_encode($row);
            }
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