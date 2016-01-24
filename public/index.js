$(function(){
    "use strict";
    var ws_url = ((location.protocol === "https:")? "wss:" : "ws:") + location.host + "/socket";
    var ws = new WebSocket(ws_url);
    
    var execVJCmd = function execVJCmd (data) {
        Array.prototype.forEach.call(data, function (v) {
            if (v.type === "background") {
                $(document.body).css("background", v.value.toString());
            } else if (v.type === "transition") {
                $(document.body).css("transition", v.value.toString());
            } else {
                console.info("undefined command type", v);
            }
        });
    };

    ws.onmessage = function (event) {
        try {
            var cmdParam = JSON.parse(event.data);
            console.info(cmdParam);
            execVJCmd(cmdParam);
        } catch (ex) {
            console.error(ex);
        }
    };
});
