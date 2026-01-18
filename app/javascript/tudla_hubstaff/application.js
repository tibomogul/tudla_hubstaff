// TudlaHubstaff Stimulus Integration
// This module provides controller registration for host applications.
// The host app is responsible for initializing Stimulus (Application.start()).
// This engine registers its controllers with the host's Stimulus instance.

import { Application } from "@hotwired/stimulus"

// Get the host application's Stimulus instance, or create one if it doesn't exist
function getApplication() {
  if (window.Stimulus) {
    return window.Stimulus
  }
  // Fallback: start a new application if host hasn't initialized one
  const application = Application.start()
  window.Stimulus = application
  return application
}

const application = getApplication()

export { application }
