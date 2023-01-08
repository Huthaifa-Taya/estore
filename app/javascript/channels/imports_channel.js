import consumer from "./consumer"

consumer.subscriptions.create("ImportsChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("connection established on server side !");
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
  }
});
