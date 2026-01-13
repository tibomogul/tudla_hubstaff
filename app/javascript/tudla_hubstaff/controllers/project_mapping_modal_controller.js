import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "projectName", "projectsList", "loading", "pagination", "searchInput"]

  connect() {
    this.currentPage = 1
    this.currentProjectId = null
    this.searchTimeout = null
  }

  open(event) {
    this.currentProjectId = event.currentTarget.dataset.projectId
    this._mapUrl = event.currentTarget.dataset.mapUrl
    const projectName = event.currentTarget.dataset.projectName

    console.log("Opening modal for project:", this.currentProjectId, "with map URL:", this._mapUrl)

    this.projectNameTarget.textContent = projectName
    this.searchInputTarget.value = ""
    this.currentPage = 1

    this.modalTarget.classList.remove("hidden")
    this.loadProjects()
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.projectsListTarget.innerHTML = ""
    this.paginationTarget.innerHTML = ""
  }

  filterProjects() {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.currentPage = 1
      this.loadProjects()
    }, 300)
  }

  async loadProjects() {
    this.loadingTarget.classList.remove("hidden")
    this.projectsListTarget.innerHTML = ""

    const nameFilter = this.searchInputTarget.value
    const url = new URL(this.availableProjectsUrl, window.location.origin)
    url.searchParams.set("page", this.currentPage)
    if (nameFilter) {
      url.searchParams.set("name", nameFilter)
    }

    try {
      const response = await fetch(url, {
        headers: {
          "Accept": "application/json",
          "X-CSRF-Token": this.csrfToken
        }
      })

      if (!response.ok) throw new Error("Failed to load projects")

      const data = await response.json()
      this.renderProjects(data.projects)
      this.renderPagination(data.current_page, data.total_pages)
    } catch (error) {
      this.projectsListTarget.innerHTML = `<p class="text-red-500 text-center py-4">Failed to load projects</p>`
    } finally {
      this.loadingTarget.classList.add("hidden")
    }
  }

  renderProjects(projects) {
    if (projects.length === 0) {
      this.projectsListTarget.innerHTML = `<p class="text-gray-500 text-center py-4">No projects found</p>`
      return
    }

    this.projectsListTarget.innerHTML = projects.map(project => `
      <button type="button"
              class="w-full text-left px-4 py-3 rounded-md border border-gray-200 hover:bg-indigo-50 hover:border-indigo-300 transition-colors"
              data-action="click->project-mapping-modal#selectProject"
              data-tudla-project-id="${project.id}">
        <div class="font-medium text-gray-900">${this.escapeHtml(project.name)}</div>
      </button>
    `).join("")
  }

  renderPagination(currentPage, totalPages) {
    if (totalPages <= 1) {
      this.paginationTarget.innerHTML = ""
      return
    }

    let html = `<span class="text-sm text-gray-500">Page ${currentPage} of ${totalPages}</span><div class="flex gap-2">`

    if (currentPage > 1) {
      html += `<button type="button"
                       class="px-3 py-1 text-sm rounded-md bg-white border border-gray-300 hover:bg-gray-50"
                       data-action="click->project-mapping-modal#prevPage">
                 Previous
               </button>`
    }

    if (currentPage < totalPages) {
      html += `<button type="button"
                       class="px-3 py-1 text-sm rounded-md bg-white border border-gray-300 hover:bg-gray-50"
                       data-action="click->project-mapping-modal#nextPage">
                 Next
               </button>`
    }

    html += "</div>"
    this.paginationTarget.innerHTML = html
  }

  prevPage() {
    if (this.currentPage > 1) {
      this.currentPage--
      this.loadProjects()
    }
  }

  nextPage() {
    this.currentPage++
    this.loadProjects()
  }

  selectProject(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const tudlaProjectId = event.currentTarget.dataset.tudlaProjectId
    const mapUrl = this._mapUrl
    
    console.log("selectProject called - tudla_project_id:", tudlaProjectId, "mapUrl:", mapUrl)
    
    if (!mapUrl) {
      console.error("Map URL not set")
      alert("Error: Map URL not set. Please try again.")
      return
    }
    
    const xhr = new XMLHttpRequest()
    const fullUrl = window.location.origin + mapUrl
    const csrfToken = this.csrfToken
    console.log("Making XHR request to:", fullUrl, "with CSRF token:", csrfToken ? "present" : "MISSING")
    
    xhr.open("PATCH", fullUrl, true)
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xhr.setRequestHeader("Accept", "text/html, application/xhtml+xml")
    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
    if (csrfToken) {
      xhr.setRequestHeader("X-CSRF-Token", csrfToken)
    }
    
    xhr.onload = () => {
      console.log("XHR onload - status:", xhr.status)
      if (xhr.status >= 200 && xhr.status < 300) {
        alert("Success! Project mapped.")
        window.location.href = window.location.pathname
      } else {
        console.error("Failed to map project:", xhr.status, xhr.responseText.substring(0, 200))
        alert("Failed to map project. Status: " + xhr.status)
      }
    }
    
    xhr.onerror = () => {
      console.error("XHR onerror triggered")
      alert("Network error mapping project.")
    }
    
    console.log("Sending XHR...")
    xhr.send(`tudla_project_id=${encodeURIComponent(tudlaProjectId)}`)
    console.log("XHR sent, closing modal...")
    this.close()
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  get availableProjectsUrl() {
    return this.element.dataset.availableProjectsUrl || "/tudla_hubstaff/projects/available_tudla_projects"
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
