import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "itemName", "itemsList", "loading", "pagination", "searchInput"]

  connect() {
    this.currentPage = 1
    this.currentActivityId = null
    this.currentHubstaffTaskId = null
    this.searchTimeout = null
  }

  open(event) {
    this.currentActivityId = event.currentTarget.dataset.activityId
    this.currentHubstaffTaskId = event.currentTarget.dataset.hubstaffTaskId
    this._mapUrl = event.currentTarget.dataset.mapUrl
    const taskName = event.currentTarget.dataset.taskName

    this.itemNameTarget.textContent = taskName
    this.searchInputTarget.value = ""
    this.currentPage = 1

    this.modalTarget.classList.remove("hidden")
    this.loadItems()
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.itemsListTarget.innerHTML = ""
    this.paginationTarget.innerHTML = ""
  }

  filterItems() {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.currentPage = 1
      this.loadItems()
    }, 300)
  }

  async loadItems() {
    this.loadingTarget.classList.remove("hidden")
    this.itemsListTarget.innerHTML = ""

    const nameFilter = this.searchInputTarget.value
    const url = new URL(this.availableItemsUrl, window.location.origin)
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

      if (!response.ok) throw new Error("Failed to load tasks")

      const data = await response.json()
      this.renderItems(data.tasks)
      this.renderPagination(data.current_page, data.total_pages)
    } catch (error) {
      this.itemsListTarget.innerHTML = `<p class="text-red-500 text-center py-4">Failed to load tasks</p>`
    } finally {
      this.loadingTarget.classList.add("hidden")
    }
  }

  renderItems(tasks) {
    if (tasks.length === 0) {
      this.itemsListTarget.innerHTML = `<p class="text-gray-500 text-center py-4">No tasks found</p>`
      return
    }

    this.itemsListTarget.innerHTML = tasks.map(task => `
      <button type="button"
              class="w-full text-left px-4 py-3 rounded-md border border-gray-200 hover:bg-indigo-50 hover:border-indigo-300 transition-colors"
              data-action="click->activity-task-mapping-modal#selectItem"
              data-tudla-task-id="${task.id}">
        <div class="font-medium text-gray-900">${this.escapeHtml(task.name)}</div>
        <div class="text-sm text-gray-500">${this.escapeHtml(task.project_name || "")}</div>
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
                       data-action="click->activity-task-mapping-modal#prevPage">
                 Previous
               </button>`
    }

    if (currentPage < totalPages) {
      html += `<button type="button"
                       class="px-3 py-1 text-sm rounded-md bg-white border border-gray-300 hover:bg-gray-50"
                       data-action="click->activity-task-mapping-modal#nextPage">
                 Next
               </button>`
    }

    html += "</div>"
    this.paginationTarget.innerHTML = html
  }

  prevPage() {
    if (this.currentPage > 1) {
      this.currentPage--
      this.loadItems()
    }
  }

  nextPage() {
    this.currentPage++
    this.loadItems()
  }

  selectItem(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const tudlaTaskId = event.currentTarget.dataset.tudlaTaskId
    const mapUrl = this._mapUrl
    
    if (!mapUrl) {
      alert("Error: Map URL not set. Please try again.")
      return
    }
    
    const xhr = new XMLHttpRequest()
    const fullUrl = window.location.origin + mapUrl
    const csrfToken = this.csrfToken
    
    xhr.open("PATCH", fullUrl, true)
    xhr.setRequestHeader("Content-Type", "application/x-www-form-urlencoded")
    xhr.setRequestHeader("Accept", "text/html, application/xhtml+xml")
    xhr.setRequestHeader("X-Requested-With", "XMLHttpRequest")
    if (csrfToken) {
      xhr.setRequestHeader("X-CSRF-Token", csrfToken)
    }
    
    xhr.onload = () => {
      if (xhr.status >= 200 && xhr.status < 300) {
        alert("Success! Task mapped.")
        window.location.reload()
      } else {
        alert("Failed to map task. Status: " + xhr.status)
      }
    }
    
    xhr.onerror = () => {
      alert("Network error mapping task.")
    }
    
    xhr.send(`tudla_task_id=${encodeURIComponent(tudlaTaskId)}`)
    this.close()
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  get availableItemsUrl() {
    return this.element.dataset.availableTasksUrl || "/tudla_hubstaff/activities/available_tudla_tasks"
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
