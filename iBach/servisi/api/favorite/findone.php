<?php

header('Content-type: application/json');

require "../../config/database.php";
require "../../model/Favorite.php";
require "../../controller/FavoriteController.php";

if (isset($_GET["userId"]) && (isset($_GET["songId"])) )
{

    //database connection
    $db = connect();

    //model and controller calls
    $favorite = new Favorite($db);
    $favoriteController = new FavoriteController($favorite);

    //controller function to push the right data
    print $favoriteData = $favoriteController->findFavorite( $_GET["userId"], $_GET["songId"]);

}

?>