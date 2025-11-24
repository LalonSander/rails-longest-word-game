import { Application } from "@hotwired/stimulus"

const application = Application.start()

import WordController from "./word_controller.js"

// Configure Stimulus development experience
application.debug = false
window.Stimulus   = application

Stimulus.register("word", WordController)

export { application }
