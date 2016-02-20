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
        
        try {
            var data = JSON.parse(event.data);
            if ((data.type === "connected") ||
                (data.type === "get_clients") ||
                (data.type === "disconnected")) {
                updateClientsList(data);
            }
        } catch (ex) {
        }
    };
    
    ws.onclose = function(event){
        var message_li = $('<li>').text("CLOSED.");
        $("#msg-area").append(message_li);
    };

    function updateClientsList(data) {
        if (data.type === "get_clients") {
            var list = [];
            for (var i = 0; i < data.value.length; i++) {
                var item = $("<li></li>");
                item.text(data.value[i].name);
                list.push(item);
            }
            $("#client-list").empty().append(list);
        } else if (data.type === "connected") {
            var item = $("<li></li>");
            item.text(data.name);
            $("#client-list").append(item);
        } else if (data.type === "disconnected") {
            $("li", $("#client-list")).each(function() {
                if ($(this).text().indexOf(data.name) == 0) {
                    $(this).remove();
                }
            });
        } else {
            ws.send(JSON.stringify([{type: "get_clients"}]));
        }
    }
});
