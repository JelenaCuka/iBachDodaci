<?php

header('Content-type: application/json');

require "../../config/database.php";
require "../../model/Favorite.php";
require "../../controller/FavoriteController.php";

if (isset($_POST["save"]) && !empty($_POST["save"]))
{
    //database connection
    $db = connect();

    //model and controller calls
    $favorite = new Favorite($db);
    $favoriteController = new FavoriteController($favorite);

    //controller function to push the right data
    print $favoriteController->saveNewFavorite();
}

?>