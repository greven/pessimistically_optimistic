import 'phoenix_html'
import { Socket } from 'phoenix'
import { LiveSocket } from 'phoenix_live_view'
import topbar from '../vendor/topbar'

// Hooks

let Hooks = {}

Hooks.Ping = {
  mounted() {
    let pingEvery

    this.valueEl = this.el.querySelector('#ping-value')
    this.unitEl = this.el.querySelector('#ping-unit')
    this.indicatorEl = this.el.querySelector('#ping-indicator')
    this.animationEl = this.el.querySelector('#ping-animation')

    this.handleEvent('pong', () => {
      let rtt = Date.now() - this.nowMs
      pingEvery = pingEvery ? 5000 : 1000

      if (this.loading) {
        this.el.classList.remove('animate-pulse')
        this.valueEl.classList.remove('text-gray-500')
        this.valueEl.innerText = `${rtt}`

        this.unitEl.innerText = 'ms'
        this.unitEl.classList.remove('hidden')
      }

      this.setIndicator(rtt)
      this.timer = setTimeout(() => this.ping(rtt), pingEvery)
      this.loading = false
    })

    this.ping(null)
    this.loading = true

    this.valueEl.innerText = 'ping...'
    this.valueEl.classList.add('text-gray-500')
    this.el.classList.add('animate-pulse')
    this.setPingClass(this.indicatorEl, 'bg-gray-300')
  },

  reconnected() {
    clearTimeout(this.timer)
    this.ping(null)
  },

  destroyed() {
    clearTimeout(this.timer)
  },

  ping(rtt) {
    this.nowMs = Date.now()
    this.pushEventTo(this.el, 'ping', { rtt: rtt })
  },

  setIndicator(rtt) {
    let className = 'bg-gray-300'

    if (rtt < 100) {
      className = 'bg-green-500'
    } else if (rtt < 200) {
      className = 'bg-yellow-500'
    } else if (rtt < 300) {
      className = 'bg-orange-500'
    } else if (rtt < 500) {
      className = 'bg-red-500'
    } else if (rtt < 5000) {
      className = 'bg-purple-600'
    } else {
      className = 'bg-gray-300'
    }

    this.setPingClass(this.indicatorEl, className)
    this.setPingClass(this.animationEl, className)
  },

  setPingClass(el, classeName) {
    el.classList.remove('bg-green-500', 'bg-yellow-500', 'bg-orange-500', 'bg-red-500', 'bg-gray-300')
    el.classList.add(classeName)
  },
}

Hooks.ListItem = {
  mounted() {
    this.handleEvent('unhide', ({ container }) => {
      this.el.classList.remove('hidden')
      this.el.style.display = container
    })
  },
}

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute('content')
let liveSocket = new LiveSocket('/live', Socket, {
  longPollFallbackMs: 2500,
  params: { _csrf_token: csrfToken },
  hooks: Hooks,
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: '#F66F4D' }, shadowColor: 'rgba(0, 0, 0, .3)' })
window.addEventListener('phx:page-loading-start', (_info) => topbar.show(300))
window.addEventListener('phx:page-loading-stop', (_info) => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
