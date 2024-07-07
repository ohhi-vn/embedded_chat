// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// Get the full URL
const url = new URL(window.location.href);

// Extract the query parameters
const params = new URLSearchParams(url.search);

// Get the user_id and channel_id
const userId = params.get('user_id');
const channelId = params.get('channel_id');

console.log("User ID " + userId, " join channel:" + channelId);

// Now that you are connected, you can join channels with a topic:
let channel = liveSocket.channel("channel:" + channelId, {params: {user_id: userId}})

let chatInput = document.querySelector("#chat-input")

let leaveButton = document.querySelector("#user-leave-room")

chatInput.addEventListener("keypress", event => {
    if(event.key === 'Enter' && chatInput.value != ""){
        channel.push("new_msg", {body: chatInput.value, user_id: userId})
      chatInput.value = ""
    }
  })

leaveButton.addEventListener("click", leaveRoom);
function leaveRoom() {
    channel.push("user_leave_room", {user_id: userId})
}

channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

