$(function(){
    "use strict";
    var ws_url = ((location.protocol === "https:")? "wss:" : "ws:") + location.host + "/controller_socket";
    var ws = new WebSocket(ws_url);
    $("#send").on('click', function(){
        ws.send($('#message').val());
    });

    ws.onmessage = function(event){
        var message_li = $('<li>').text(event.data);
        $("#msg-area").append(message_li);
    };
    
    ws.onclose = function(event){
        var message_li = $('<li>').text("CLOSED.");
        $("#msg-area").append(message_li);
    };
});
