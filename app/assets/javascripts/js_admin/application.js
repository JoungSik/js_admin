import "@hotwired/turbo-rails"
import { Application } from "@hotwired/stimulus"
import ThemeController from "js_admin/controllers/theme_controller"
import FlashController from "js_admin/controllers/flash_controller"

const application = window.Stimulus || window.JSAdminStimulus || Application.start()

if (!window.Stimulus) {
  window.JSAdminStimulus = application
}

application.register("js-admin-theme", ThemeController)
application.register("js-admin-flash", FlashController)
