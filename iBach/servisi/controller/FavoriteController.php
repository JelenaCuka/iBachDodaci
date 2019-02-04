<?php

class FavoriteController
{
    private $favorite;

    public function __construct($favorite)
    {
        $this->favorite = $favorite;
    }

    public function findFavorite($userId, $songId)
    {
        if (is_numeric($userId) && is_numeric($songId))
        {
            return $this->favorite->findOne($userId, $songId);
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

    public function findFavoriteSongsForUser($userId)
    {
        if (is_numeric($userId))
        {
            return $this->favorite->findAllForUser($userId);
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

    public function saveNewFavorite()
    {
        if ($_POST["save"] == 1)
        {
            return $this->favorite->save();
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