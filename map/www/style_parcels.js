
var d = {};

// the event handler listens to shiny for messages send by handler1
// if it receives a message, call the callback function doAwesomething and pass the message
Shiny.addCustomMessageHandler("handler1", set_d);

// this function is called by the handler, which passes the message
function set_d(data){
  d = data;
}
