var http = require('http');
var querystring = require('querystring');
var request = require('request');
var relayServer = 'http://CHANGE_ME'; // Change this to the domain running the relay PHP script

function postRequest(request, response, callback)
{
    var queryData = "";
    if(typeof callback !== 'function') return null;

    if(request.method == 'POST')
    {
        request.on('data', function(data)
        {
            queryData += data;
            if(queryData.length > 1e6)
            {
                queryData = "";
                response.writeHead(413, {'Content-Type': 'text/plain'}).end();
                request.connection.destroy();
            }
        });

        request.on('end', function()
        {
            response.post = querystring.parse(queryData);
            callback();
        });
    }

    else
    {
        response.writeHead(405, {'Content-Type': 'text/plain'});
        response.end();
    }
}

function sendPost(response)
{
    if(typeof response.post.send != 'undefined' && typeof response.post.message != 'undefined')
    {
        if(typeof response.retry != 'undefined')
            console.log("Retrying: "+response.post.message);

        else
        {
            // We don't actually need to wait for the return data from the post request when sending chats
            console.log("Sending: "+response.post.message);

            response.writeHead(200, "OK", {'Content-Type': 'text/plain'});
            response.end();
        }
    }
    
    request.post({url: relayServer, timeout: 3000, form: response.post}, function (error, data, body)
    {
        if(!error)
        {
            // The only time we need the returned data is when asking for chats from IRC
            if(typeof response.post.recv != 'undefined')
            {
                response.writeHead(200, "OK", {'Content-Type': 'text/plain'});
                response.end(body);
            }
        }
        else
        {
            console.log(error);
            
            // The only time we need to retry is when sending chats from RO
            // The kore relay script requests these every second anyway...
            if(typeof response.post.send != 'undefined')
            {
                response.retry = true;
                
                // Wait a bit between failures
                setTimeout(function() { sendPost(response); }, 2600);
            }
            else
            {
                response.writeHead(200, "OK", {'Content-Type': 'text/plain'});
                response.end(body);
            }
        }
    });
}

http.createServer(function(req, resp)
{
    postRequest(req, resp, function()
    {
        sendPost(resp);
    });
}).listen(1444);
