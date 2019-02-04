<?php
class Playlist
{
    private $id;
    private $name;
    private $user_id;
    private $modified_at;
    private $deleted_at;
    private $songs;
    private $db;



    public function __construct($db)
    {
        $this->db = $db;
    }

    public function findAll($userId)
    {
        $this->user_id = $userId;
        if($this->userExists() ){
            $stmt = $this->db->prepare("SELECT id, name, user_id, modified_at,deleted_at FROM playlist where user_id=? AND deleted_at IS NULL");
            $stmt->bind_param("i", $this->user_id );
            $stmt->execute();
            
            $result = $stmt->get_result();
            $playLists = array();

            while ($playlist = $result->fetch_assoc())
            {
                $this->id=$playlist["id"];
                $this->findSongs();
                $playlist["songs"]=$this->songs;
                array_push($playLists, $playlist);
            }
            return json_encode( array("status"=>"200","playlists"=>$playLists) );
           
        }else{
            return json_encode( array("status"=>"404","description"=>"Can't get playlists for nonexistent user"));
        }
    }

    public function findOne($id)
    {
        $this->id = $id;
        $playlist=$this->findPlaylistById();
        if($playlist!=null){
            return json_encode( array("status"=>"200","playlist"=>$playlist ) );
        }else{
            return json_encode( array("status"=>"404","description"=>"Playlist not found."));
        }
    }

    public function save($name,$user_id)
    {
        $this->name=$name;
        $this->user_id=$user_id;
        if($this->userExists() ){
            if($this->playlistExists() ){
                return json_encode( array("status"=>"400","description"=>"User can't have 2 playlists with same name"));
            }else{
                if($this->savePlaylistToDatabase() ){
                    return json_encode( array("status"=>"200","description"=>"Playlist saved.","playlist"=>$this->findPlaylistById()));
                }else{
                    return json_encode( array("status"=>"400","description"=>"Uknnown error while creating playlist."));
                }
            }
        }else{
            return json_encode( array("status"=>"400","description"=>"Bad request. Can't create playlist for user who doesn't exist."));
        }
    }
    
    public function delete($id)
    {
        $this->id = $id;
        $stmt = $this->db->prepare("UPDATE playlist SET deleted_at = NOW() WHERE id = ? and deleted_at IS NULL");
        $stmt->bind_param("i", $this->id);
        $stmt->execute();

        if ($stmt->affected_rows === 1)
        {
            $stmt->close();
            return json_encode( array("status"=>"200","description"=>"OK. Playlist deleted"));
        }else{
            $stmt->close();
            return json_encode( array("status"=>"404","description"=>"Not found."));
        }
    }
    public function update($id,$newName)
    {
        $this->id = $id;
        if ($this->playlistExistsId() ){
            $this->name=$newName;
            if( $this->updateName() ){
                return json_encode( array("status"=>"200","description"=>"Playlist updated.Name changed.","playlist"=>$this->findPlaylistById()));
            }
            else{
                return json_encode( array("status"=>"404","description"=>"Not found. Error update."));
            }
        }else{
            return json_encode( array("status"=>"400","description"=>"Bad request."));
        }
    }
    
    public function savePlaylistToDatabase()
    {
        $stmt = $this->db->prepare("INSERT INTO playlist (name, user_id, modified_at, deleted_at) VALUES (?,?,NOW(),NULL)");
        $stmt->bind_param("si", $this->name, $this->user_id );
        $stmt->execute();
        if ($stmt->affected_rows === 1)
        {
            $this->id=$stmt->insert_id;
            $stmt->close();
            return true;
        }
        else
        {
            $stmt->close();
            return false;
        }
    }
    public function updateName()
    {
        $stmt = $this->db->prepare("UPDATE playlist SET name=? , modified_at=NOW() where id =?");
        $stmt->bind_param("si",$this->name,$this->id);
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

    public function playlistExists()
    {
        $stmt = $this->db->prepare("SELECT COUNT(id) FROM playlist WHERE name=? and user_id=? and deleted_at IS NULL");
        $stmt->bind_param("si", $this->name, $this->user_id );
        $stmt->execute();

        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        if($row["COUNT(id)"]>=1){
            return true;

        }else{
            return false;
        }
    }
    public function playlistExistsId()
    {
        $stmt = $this->db->prepare("SELECT COUNT(id) FROM playlist WHERE id=? and deleted_at IS NULL");
        $stmt->bind_param("i", $this->id );
        $stmt->execute();

        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        if($row["COUNT(id)"]>=1){
            return true;

        }else{
            return false;
        }
    }
    public function userExists()
    {
        $stmt = $this->db->prepare("SELECT COUNT(id) FROM user WHERE id=? and deleted_at is null");
        $stmt->bind_param("i",$this->user_id );
        $stmt->execute();

        $result = $stmt->get_result();
        $row = $result->fetch_assoc();
        $stmt->close();
        if($row["COUNT(id)"]>=1){
            return true;

        }else{
            return false;
        }
    }
    public function findPlaylistById()
    {
        $stmt = $this->db->prepare("SELECT id,name,user_id,modified_at,deleted_at FROM playlist WHERE id=? and deleted_at is null");
        $stmt->bind_param("i", $this->id);
        $stmt->execute();

        $result = $stmt->get_result();
        $playlist = $result->fetch_assoc();
        
        $stmt->close();
        if(!empty($playlist)){
            $this->findSongs();
            $playlist["songs"]=$this->songs;
            return $playlist;
        }else{
            return null;
        }
    }
    public function findSongs()
    {
        $stmt = $this->db->prepare("SELECT s.id,s.title,s.author,s.year,s.file_url FROM playlist_song ps LEFT JOIN song s on ps.song_id=s.id WHERE ps.playlist_id=? and ps.deleted_at IS NULL");
            $stmt->bind_param("i", $this->id);
            $stmt->execute();
            $result=$stmt->get_result();
            $this->songs=array();
            while ($song = $result->fetch_object())
            {
                array_push($this->songs, $song);
            }
    }


}

?>