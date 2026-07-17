import "@hotwired/turbo-rails"
import { Application, Controller } from "@hotwired/stimulus"

const application = window.Stimulus || window.JSAdminStimulus || Application.start()

if (!window.Stimulus) {
  window.JSAdminStimulus = application
}

class ThemeController extends Controller {
  static targets = ["toggle"]

  connect() {
    this.syncToggle()
  }

  toggle() {
    const enabled = !document.documentElement.classList.contains("dark")

    document.documentElement.classList.toggle("dark", enabled)
    this.persistTheme(enabled)
    this.syncToggle()
  }

  syncToggle() {
    if (!this.hasToggleTarget) return

    this.toggleTarget.setAttribute("aria-pressed", document.documentElement.classList.contains("dark"))
  }

  persistTheme(enabled) {
    try {
      localStorage.setItem("js_admin_theme", enabled ? "dark" : "light")
    } catch (_error) {
      return
    }
  }
}

class FlashController extends Controller {
  static values = {
    timeout: { type: Number, default: 4000 }
  }

  connect() {
    this.timeoutId = window.setTimeout(() => this.dismiss(), this.timeoutValue)
  }

  disconnect() {
    window.clearTimeout(this.timeoutId)
  }

  dismiss() {
    this.element.classList.add("opacity-0", "translate-y-1")

    window.setTimeout(() => {
      this.element.remove()
    }, 300)
  }
}

application.register("js-admin-theme", ThemeController)
application.register("js-admin-flash", FlashController)
