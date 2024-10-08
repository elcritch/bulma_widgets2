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
let liveSocket = new LiveSocket("/live", Socket, {
  longPollFallbackMs: 2500,
  params: {
    _csrf_token: csrfToken,
  }
})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// Copy for simple theme switching support
function getTheme() {
  return localStorage.getItem("bulma-widgets:theme") || "light"
}
function setTheme(theme) {
  console.log("setting theme: ", theme)
  localStorage.setItem("bulma-widgets:theme", theme)
  document.querySelector('html').className = "theme-" + theme 
}
window.addEventListener(
  "bulma-widgets:set-theme",
  (event) => { setTheme(event.detail.theme)
});
window.addEventListener(
  "phx:page-loading-stop",
  (_info) => setTheme(getTheme())
);
window.addEventListener(
  "DOMContentLoaded",
  (_info) => setTheme(getTheme())
);

// executes LiveView.JS encoded into an attribute
// see: https://fly.io/phoenix-files/server-triggered-js/
// usage:
//     <div 
//       class="hidden h-full bg-slate-100" id={@id}
//       data-plz-wait={show_loader(@id)} 
//       data-ok-done={hide_loader(@id)}
//     ></div>
//
// Then:
//    socket = push_event(socket, "js-exec", %{
//     to: "#my_spinner", attr: "data-plz-wait" })
//

window.addEventListener("phx:js-exec", ({detail}) => {
  document.querySelectorAll(detail.to).forEach(el => {
      liveSocket.execJS(el, el.getAttribute(detail.attr))
  })
});



// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

