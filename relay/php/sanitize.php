<?php

function sanitize($data, $type = 'html')
{
        $type = strtolower($type);

        if(is_array($data))
        {
                $SanitizedData = array();
        
                foreach($data as $key => $value)
                {
                        if(get_magic_quotes_gpc())
                        {
                                $key = stripslashes($key);
                                $value = stripslashes($value);
                        }
                        
                        if($type == 'html')
                                $SanitizedData[filter_var($key, FILTER_SANITIZE_SPECIAL_CHARS)] = filter_var($value, FILTER_SANITIZE_SPECIAL_CHARS);
                        else
                                $SanitizedData[mysql_real_escape_string($key)] = mysql_real_escape_string($value);
                }
                
                return $SanitizedData;
        }
        else
        {
                if(get_magic_quotes_gpc())
                        $data = stripslashes($data);
                
                if($type == 'html')
                        return filter_var($data, FILTER_SANITIZE_SPECIAL_CHARS);
                else
                        return mysql_real_escape_string($data);
        }
}

function sanitizeInput()
{
        // Automatically santize user input.
        $_GET = sanitize($_GET);
        $_POST = sanitize($_POST);
        $_COOKIE = sanitize($_COOKIE);
}

?>
