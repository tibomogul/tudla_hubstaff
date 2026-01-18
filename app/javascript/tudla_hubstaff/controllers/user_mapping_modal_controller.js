import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["modal", "userName", "usersList", "loading", "pagination", "searchInput"]

  connect() {
    this.currentPage = 1
    this.currentUserId = null
    this.searchTimeout = null
  }

  open(event) {
    this.currentUserId = event.currentTarget.dataset.userId
    this._mapUrl = event.currentTarget.dataset.mapUrl
    const userName = event.currentTarget.dataset.userName

    this.userNameTarget.textContent = userName
    this.searchInputTarget.value = ""
    this.currentPage = 1

    this.modalTarget.classList.remove("hidden")
    this.loadUsers()
  }

  close() {
    this.modalTarget.classList.add("hidden")
    this.usersListTarget.innerHTML = ""
    this.paginationTarget.innerHTML = ""
  }

  filterUsers() {
    clearTimeout(this.searchTimeout)
    this.searchTimeout = setTimeout(() => {
      this.currentPage = 1
      this.loadUsers()
    }, 300)
  }

  async loadUsers() {
    this.loadingTarget.classList.remove("hidden")
    this.usersListTarget.innerHTML = ""

    const nameFilter = this.searchInputTarget.value
    const url = new URL(this.availableUsersUrl, window.location.origin)
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

      if (!response.ok) throw new Error("Failed to load users")

      const data = await response.json()
      this.renderUsers(data.users)
      this.renderPagination(data.current_page, data.total_pages)
    } catch (error) {
      this.usersListTarget.innerHTML = `<p class="text-red-500 text-center py-4">Failed to load users</p>`
    } finally {
      this.loadingTarget.classList.add("hidden")
    }
  }

  renderUsers(users) {
    if (users.length === 0) {
      this.usersListTarget.innerHTML = `<p class="text-gray-500 text-center py-4">No users found</p>`
      return
    }

    this.usersListTarget.innerHTML = users.map(user => `
      <button type="button"
              class="w-full text-left px-4 py-3 rounded-md border border-gray-200 hover:bg-indigo-50 hover:border-indigo-300 transition-colors"
              data-action="click->user-mapping-modal#selectUser"
              data-tudla-user-id="${user.id}">
        <div class="font-medium text-gray-900">${this.escapeHtml(user.name)}</div>
        <div class="text-sm text-gray-500">${this.escapeHtml(user.email || "")}</div>
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
                       data-action="click->user-mapping-modal#prevPage">
                 Previous
               </button>`
    }

    if (currentPage < totalPages) {
      html += `<button type="button"
                       class="px-3 py-1 text-sm rounded-md bg-white border border-gray-300 hover:bg-gray-50"
                       data-action="click->user-mapping-modal#nextPage">
                 Next
               </button>`
    }

    html += "</div>"
    this.paginationTarget.innerHTML = html
  }

  prevPage() {
    if (this.currentPage > 1) {
      this.currentPage--
      this.loadUsers()
    }
  }

  nextPage() {
    this.currentPage++
    this.loadUsers()
  }

  selectUser(event) {
    event.preventDefault()
    event.stopPropagation()
    
    const tudlaUserId = event.currentTarget.dataset.tudlaUserId
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
        alert("Success! User mapped.")
        window.location.href = window.location.pathname
      } else {
        alert("Failed to map user. Status: " + xhr.status)
      }
    }
    
    xhr.onerror = () => {
      alert("Network error mapping user.")
    }
    
    xhr.send(`tudla_user_id=${encodeURIComponent(tudlaUserId)}`)
    this.close()
  }

  escapeHtml(text) {
    const div = document.createElement("div")
    div.textContent = text
    return div.innerHTML
  }

  get availableUsersUrl() {
    return this.element.dataset.availableUsersUrl || "/tudla_hubstaff/users/available_tudla_users"
  }

  get csrfToken() {
    return document.querySelector('meta[name="csrf-token"]')?.content || ""
  }
}
