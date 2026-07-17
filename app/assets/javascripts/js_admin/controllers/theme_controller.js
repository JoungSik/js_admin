import { Controller } from "@hotwired/stimulus"

const THEME_STORAGE_KEY = "js_admin_theme"
const THEME_COOKIE_NAME = "js_admin_theme"
const THEME_COOKIE_MAX_AGE = 60 * 60 * 24 * 365

export default class extends Controller {
  static targets = ["toggle"]

  connect() {
    this.applyPreferredTheme()
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
    const theme = enabled ? "dark" : "light"

    try {
      localStorage.setItem(THEME_STORAGE_KEY, theme)
    } catch (_error) {
    }

    document.cookie = `${THEME_COOKIE_NAME}=${theme}; path=/; max-age=${THEME_COOKIE_MAX_AGE}; SameSite=Lax`
  }

  applyPreferredTheme() {
    const storedTheme = this.storedTheme()
    const darkEnabled = storedTheme === "dark" || (!storedTheme && window.matchMedia("(prefers-color-scheme: dark)").matches)

    document.documentElement.classList.toggle("dark", darkEnabled)
  }

  storedTheme() {
    try {
      return localStorage.getItem(THEME_STORAGE_KEY) || this.cookieTheme()
    } catch (_error) {
      return this.cookieTheme()
    }
  }

  cookieTheme() {
    const themeCookie = document.cookie
      .split("; ")
      .find((cookie) => cookie.startsWith(`${THEME_COOKIE_NAME}=`))

    return themeCookie?.split("=")[1]
  }
}
