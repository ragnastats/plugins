<?php

include('mysql.php');
include('sanitize.php');
$_POST = sanitize($_POST);

if($_POST['secret'] == "CHANGE_ME SHARED SECRET")
{
        if($_POST['send'])
        {
                mysql_query("Insert into `simple-relay`
                                                values('', NOW(), '{$_POST['destination']}', '{$_POST['type']}', '{$_POST['message']}', '')");
        }
        elseif($_POST['recv'])
        {
                if($_POST['mode'] == 'slave')
                        $ignore = "and `type` = 'public'";

        
                $recv = mysql_query("Select `destination`, `type`, `message`
                                                                from `simple-relay`
                                                                where `destination`='{$_POST['destination']}'
                                                                        and `relayed`= '0'
                                                                        $ignore
                                                                        
                                                                group by `message`
                                                                order by `relayID` asc");
                                                                        
                while(list($destination, $type, $message) = mysql_fetch_array($recv))
                {
                        if($_POST['destination'] == 'irc')
                                echo "[$type] ".html_entity_decode($message, ENT_QUOTES)."\n";
                        else
                                echo html_entity_decode($message, ENT_QUOTES)."\n";
                }

                if($_POST['mode'] != 'slave')
                {
                        mysql_query("Update `simple-relay`
                                                        set `relayed`='1'
                                                        where `destination`='{$_POST['destination']}'
                                                                and `relayed`= '0'
                                                                $ignore");
                }
        }       
}

?>
