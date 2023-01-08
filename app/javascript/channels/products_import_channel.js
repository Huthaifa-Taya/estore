import consumer from "./consumer"

consumer.subscriptions.create("ProductsImportChannel", {
  connected() {
    // Called when the subscription is ready for use on the server
    console.log("Connected to ProductImportChannel!")
  },

  disconnected() {
    // Called when the subscription has been terminated by the server
    console.log("Disconnected from ProductImportChannel.lock!")
  },

  received(data) {
    // Called when there's incoming data on the websocket for this channel
    // const progressBar = document.getElementById("progress-bar");
    // progressBar.style.width = data;
  },

  speak: function() {
    return this.perform('speak');
  }
});
