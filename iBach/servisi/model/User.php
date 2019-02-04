<?php

class User
{
    private $id;
    private $username;
    private $password;
    private $email;
    private $firstName;
    private $lastName;
    private $timeModified;
    private $timeDeleted;
    private $db;

    public function __construct($db)
    {
        $this->db = $db;
    }
    
    public function findOne($id)
    {
        $this->id=$id;
        $stmt = $this->db->prepare("SELECT id, first_name, last_name, email, deleted_at, modified_at, username, password FROM user WHERE id = ?");
        $stmt->bind_param("i", $this->id);
        $stmt->execute();

        $result = $stmt->get_result();
        $fetchUser = $result->fetch_assoc();
        if(!empty($fetchUser)){
            return json_encode( array("status"=>"200","data"=>$fetchUser));
        }else{
            return json_encode( array("status"=>"404","description"=>"Not found. There is no user with that id."));
        }
    }

    public function findAll()
    {
        $stmt = $this->db->prepare("SELECT id, first_name, last_name, email, deleted_at, modified_at, username, password FROM user");
        $stmt->execute();
        
        $result = $stmt->get_result();
        $userList = array();

        while ($fetchUser = $result->fetch_object())
        {
            array_push($userList, $fetchUser);
        }
        if(!empty($userList))
        {
            return json_encode( array("status"=>"200","users"=>$userList));
        }else
        {
            return json_encode( array("status"=>"200","description"=>"Table users has no entries."));
        }
    }
    
    public function save($username,$password,$email,$firstName,$lastName)
    {
        $this->username = $username;
        $this->password = $password;
        $this->email = $email;
        $this->firstName = $firstName;
        $this->lastName = $lastName;

        if( $this->usernameIsNotDuplicate() && $this->emailIsNotDuplicate() ){
            if($this->saveUserToDatabase()){
                $row = array();
                $row["status"]= "200";
                $row["description"] = "User successfully created.";
                return json_encode($row);
            }else{
                http_response_code(400);
                $row = array();
                $row["status"]= "400";
                $row["description"] = "Unexpected error while creating user.";
                return json_encode($row);
            }
        }else{
            if(!$this->usernameIsNotDuplicate()&&!$this->emailIsNotDuplicate()){
                http_response_code(400);
                $row = array();
                $row["status"]= "400";
                $row["description"] = "Username and email already exist.";
                return json_encode($row);

            }elseif(!$this->emailIsNotDuplicate()){
                http_response_code(400);
                $row = array();
                $row["status"]= "400";
                $row["description"] = "There's account with that email.";
                return json_encode($row);
            }
            elseif(!$this->usernameIsNotDuplicate()){
                http_response_code(400);
                $row = array();
                $row["status"]= "400";
                $row["description"] = "That username is already taken.";
                return json_encode($row);
            }
        }
    }
    
    public function update($id,$first_name,$last_name,$password)
    {
        $this->password = $password;
        $this->firstName = $first_name;
        $this->lastName = $last_name;
        $this->id=$id;
        if($this->updateUser() ){
            $stmt = $this->db->prepare("SELECT id, first_name, last_name, email, deleted_at, modified_at, username, password FROM user WHERE id = ? and deleted_at  IS NULL");
            $stmt->bind_param("i", $this->id);
            $stmt->execute();

            $result = $stmt->get_result();
            $fetchUser = $result->fetch_assoc();
            if(!empty($fetchUser)){
                return json_encode( array("status"=>"200","description"=>"User successfully updated.","user"=>$fetchUser));
            }else{
                return json_encode( array("status"=>"404","description"=>"Not found. Unknown update error."));
            }
        }else{
            $row = array();
            $row["status"]= "400";
            $row["description"] = " Bad request.";
            return json_encode($row);
        }
    }

    public function delete($id)
    {
        $this->id = $id;

        $stmt = $this->db->prepare("UPDATE user SET deleted_at = NOW() WHERE id = ? and deleted_at IS NULL");
        $stmt->bind_param("i", $this->id);
        $stmt->execute();

        if ($stmt->affected_rows === 1)
        {
            $row = array();
            $row["status"]= "200";
            $row["description"] = "OK. User deleted";
            $stmt->close();

            return json_encode($row);

        }
        else
        {
            $row = array();
            $row["status"]= "400";
            $row["description"] = " Bad request.";
            $stmt->close();

            return json_encode($row);
        }
    }
    public function findUserByUsername($username)
    {
        $this->username = $username;

        $stmt = $this->db->prepare("SELECT id, first_name, last_name, email, deleted_at, modified_at, username, password FROM user WHERE username = ? and deleted_at is null");
        $stmt->bind_param("s", $this->username );
        $stmt->execute();

        $result = $stmt->get_result();
        $fetchUser = $result->fetch_assoc();
        
        if(!empty($fetchUser))
        {
            return $fetchUser;
        }else{
            return null;
        }
    }
    
    public function usernameIsNotDuplicate()
    {
        $stmt = $this->db->prepare("SELECT COUNT(id) FROM user WHERE username=? and deleted_at IS NULL");
        $stmt->bind_param("s",$this->username);
        $stmt->execute();

        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        if($row["COUNT(id)"]>=1){
            return false;

        }else{
            return true;
        }
    }
    public function emailIsNotDuplicate()
    {
        //only active are considered
        $stmt = $this->db->prepare("SELECT COUNT(id) FROM user WHERE email=? and deleted_at IS NULL");
        $stmt->bind_param("s", $this->email);
        $stmt->execute();

        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        if($row["COUNT(id)"]>=1){
            return false;

        }else{
            return true;
        }
    }
    public function saveUserToDatabase()
    {
        $stmt = $this->db->prepare("INSERT INTO user (first_name, last_name, email, deleted_at,modified_at,username,password) VALUES (?,?,?,NULL,NOW(),?,?)");
        $stmt->bind_param("sssss", $this->firstName, $this->lastName, $this->email, $this->username, $this->password);
        $stmt->execute();

        if ($stmt->affected_rows === 1)
        {
            $stmt->close();
            return true;
        }
        else
        {
            $stmt->close();
            return false;
        }
    }
    
    public function updateUser()
    {
        $stmt = $this->db->prepare("UPDATE user SET first_name=? , last_name=?, modified_at=NOW(),password=? where id =?");
        $stmt->bind_param("sssi",$this->firstName,$this->lastName,$this->password,$this->id);
        $stmt->execute();

        if ($stmt->affected_rows === 1)
        {
            $stmt->close();
            return true;
        }
        else
        {
            $stmt->close();
            return false;
        }
    }

}

?>