/**
 * 
 */// BookHaven Online Bookstore - Main JavaScript File
// Common functionality for the entire application

// Global variables
const cart = []
const wishlist = []

// Import Bootstrap
const bootstrap = window.bootstrap

// Initialize application when DOM is loaded
document.addEventListener("DOMContentLoaded", () => {
  initializeApp()
})

// Main initialization function
function initializeApp() {
  // Initialize tooltips
  var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
  var tooltipList = tooltipTriggerList.map((tooltipTriggerEl) => new bootstrap.Tooltip(tooltipTriggerEl))

  // Initialize popovers
  var popoverTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="popover"]'))
  var popoverList = popoverTriggerList.map((popoverTriggerEl) => new bootstrap.Popover(popoverTriggerEl))

  // Load cart count
  updateCartCount()

  // Initialize search functionality
  initializeSearch()

  // Initialize featured books if on homepage
  if (document.getElementById("featured-books")) {
    loadFeaturedBooks()
  }

  // Initialize form validations
  initializeFormValidation()
}

// Cart Management Functions
function addToCart(bookId, title, price, imageUrl) {
  // Send AJAX request to add item to cart
  fetch("CartController", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: `action=add&bookId=${bookId}&quantity=1`,
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        showNotification("Book added to cart successfully!", "success")
        updateCartCount()

        // Update cart UI if on cart page
        if (document.getElementById("cart-items")) {
          loadCartItems()
        }
      } else {
        showNotification(data.message || "Failed to add book to cart", "error")
      }
    })
    .catch((error) => {
      console.error("Error:", error)
      showNotification("An error occurred while adding to cart", "error")
    })
}

function removeFromCart(bookId) {
  if (confirm("Are you sure you want to remove this item from your cart?")) {
    fetch("CartController", {
      method: "POST",
      headers: {
        "Content-Type": "application/x-www-form-urlencoded",
      },
      body: `action=remove&bookId=${bookId}`,
    })
      .then((response) => response.json())
      .then((data) => {
        if (data.success) {
          showNotification("Item removed from cart", "success")
          updateCartCount()
          loadCartItems()
        } else {
          showNotification(data.message || "Failed to remove item", "error")
        }
      })
      .catch((error) => {
        console.error("Error:", error)
        showNotification("An error occurred while removing item", "error")
      })
  }
}

function updateCartQuantity(bookId, quantity) {
  if (quantity < 1) {
    removeFromCart(bookId)
    return
  }

  fetch("CartController", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: `action=update&bookId=${bookId}&quantity=${quantity}`,
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        updateCartCount()
        loadCartItems()
      } else {
        showNotification(data.message || "Failed to update quantity", "error")
      }
    })
    .catch((error) => {
      console.error("Error:", error)
      showNotification("An error occurred while updating quantity", "error")
    })
}

function updateCartCount() {
  fetch("CartController?action=count")
    .then((response) => response.json())
    .then((data) => {
      const cartBadge = document.getElementById("cart-count")
      if (cartBadge) {
        cartBadge.textContent = data.count || 0
        cartBadge.style.display = data.count > 0 ? "inline" : "none"
      }
    })
    .catch((error) => {
      console.error("Error updating cart count:", error)
    })
}

function loadCartItems() {
  const cartContainer = document.getElementById("cart-items")
  if (!cartContainer) return

  fetch("CartController?action=list")
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        displayCartItems(data.items, data.total)
      }
    })
    .catch((error) => {
      console.error("Error loading cart items:", error)
    })
}

function displayCartItems(items, total) {
  const cartContainer = document.getElementById("cart-items")
  const totalElement = document.getElementById("cart-total")

  if (items.length === 0) {
    cartContainer.innerHTML = `
            <div class="text-center py-5">
                <i class="fas fa-shopping-cart fa-3x text-muted mb-3"></i>
                <h4>Your cart is empty</h4>
                <p class="text-muted">Add some books to get started!</p>
                <a href="catalog.jsp" class="btn btn-primary">Browse Books</a>
            </div>
        `
    if (totalElement) totalElement.textContent = "$0.00"
    return
  }

  let html = ""
  items.forEach((item) => {
    html += `
            <div class="cart-item border-bottom py-3" data-book-id="${item.bookId}">
                <div class="row align-items-center">
                    <div class="col-md-2">
                        <img src="${item.imageUrl || "/placeholder.svg?height=80&width=60"}" 
                             alt="${item.title}" class="img-fluid rounded">
                    </div>
                    <div class="col-md-4">
                        <h6 class="mb-1">${item.title}</h6>
                        <small class="text-muted">by ${item.author}</small>
                    </div>
                    <div class="col-md-2">
                        <span class="fw-bold">$${item.price.toFixed(2)}</span>
                    </div>
                    <div class="col-md-2">
                        <div class="input-group input-group-sm">
                            <button class="btn btn-outline-secondary" type="button" 
                                    onclick="updateCartQuantity(${item.bookId}, ${item.quantity - 1})">-</button>
                            <input type="number" class="form-control text-center" 
                                   value="${item.quantity}" min="1" 
                                   onchange="updateCartQuantity(${item.bookId}, this.value)">
                            <button class="btn btn-outline-secondary" type="button" 
                                    onclick="updateCartQuantity(${item.bookId}, ${item.quantity + 1})">+</button>
                        </div>
                    </div>
                    <div class="col-md-2 text-end">
                        <button class="btn btn-sm btn-outline-danger" 
                                onclick="removeFromCart(${item.bookId})" title="Remove item">
                            <i class="fas fa-trash"></i>
                        </button>
                    </div>
                </div>
            </div>
        `
  })

  cartContainer.innerHTML = html
  if (totalElement) totalElement.textContent = `$${total.toFixed(2)}`
}

// Wishlist Management
function toggleWishlist(bookId, title) {
  fetch("WishlistController", {
    method: "POST",
    headers: {
      "Content-Type": "application/x-www-form-urlencoded",
    },
    body: `action=toggle&bookId=${bookId}`,
  })
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        const wishlistBtn = document.querySelector(`[data-book-id="${bookId}"] .wishlist-btn`)
        if (wishlistBtn) {
          if (data.added) {
            wishlistBtn.innerHTML = '<i class="fas fa-heart text-danger"></i>'
            showNotification(`${title} added to wishlist`, "success")
          } else {
            wishlistBtn.innerHTML = '<i class="far fa-heart"></i>'
            showNotification(`${title} removed from wishlist`, "success")
          }
        }
      } else {
        showNotification(data.message || "Failed to update wishlist", "error")
      }
    })
    .catch((error) => {
      console.error("Error:", error)
      showNotification("An error occurred", "error")
    })
}

// Search Functionality
function initializeSearch() {
  const searchForm = document.getElementById("search-form")
  const searchInput = document.getElementById("search-input")

  if (searchForm) {
    searchForm.addEventListener("submit", (e) => {
      e.preventDefault()
      performSearch()
    })
  }

  if (searchInput) {
    // Add search suggestions
    searchInput.addEventListener("input", debounce(showSearchSuggestions, 300))
  }
}

function performSearch() {
  const searchInput = document.getElementById("search-input")
  const query = searchInput.value.trim()

  if (query.length < 2) {
    showNotification("Please enter at least 2 characters to search", "warning")
    return
  }

  // Redirect to catalog with search parameters
  window.location.href = `catalog.jsp?search=${encodeURIComponent(query)}`
}

function showSearchSuggestions(query) {
  if (query.length < 2) return

  fetch(`BookController?action=suggestions&query=${encodeURIComponent(query)}`)
    .then((response) => response.json())
    .then((data) => {
      displaySearchSuggestions(data.suggestions)
    })
    .catch((error) => {
      console.error("Error fetching suggestions:", error)
    })
}

function displaySearchSuggestions(suggestions) {
  let suggestionsContainer = document.getElementById("search-suggestions")

  if (!suggestionsContainer) {
    suggestionsContainer = document.createElement("div")
    suggestionsContainer.id = "search-suggestions"
    suggestionsContainer.className = "position-absolute bg-white border rounded shadow-sm w-100"
    suggestionsContainer.style.zIndex = "1000"
    suggestionsContainer.style.top = "100%"

    const searchContainer = document.getElementById("search-input").parentElement
    searchContainer.style.position = "relative"
    searchContainer.appendChild(suggestionsContainer)
  }

  if (suggestions.length === 0) {
    suggestionsContainer.style.display = "none"
    return
  }

  let html = ""
  suggestions.forEach((suggestion) => {
    html += `
            <div class="p-2 border-bottom suggestion-item" 
                 onclick="selectSuggestion('${suggestion.title}')" 
                 style="cursor: pointer;">
                <small><strong>${suggestion.title}</strong> by ${suggestion.author}</small>
            </div>
        `
  })

  suggestionsContainer.innerHTML = html
  suggestionsContainer.style.display = "block"

  // Hide suggestions when clicking outside
  document.addEventListener("click", (e) => {
    if (!e.target.closest("#search-input") && !e.target.closest("#search-suggestions")) {
      suggestionsContainer.style.display = "none"
    }
  })
}

function selectSuggestion(title) {
  document.getElementById("search-input").value = title
  document.getElementById("search-suggestions").style.display = "none"
  performSearch()
}

// Featured Books Loading
function loadFeaturedBooks() {
  fetch("BookController?action=featured")
    .then((response) => response.json())
    .then((data) => {
      if (data.success) {
        displayFeaturedBooks(data.books)
      }
    })
    .catch((error) => {
      console.error("Error loading featured books:", error)
    })
}

function displayFeaturedBooks(books) {
  const container = document.getElementById("featured-books")
  if (!container) return

  let html = ""
  books.forEach((book) => {
    html += `
            <div class="col-md-3 mb-4">
                <div class="card h-100 book-card">
                    <img src="${book.imageUrl || "/placeholder.svg?height=300&width=200"}" 
                         class="card-img-top" alt="${book.title}" style="height: 250px; object-fit: cover;">
                    <div class="card-body d-flex flex-column">
                        <h6 class="card-title">${book.title}</h6>
                        <p class="card-text text-muted small">by ${book.author}</p>
                        <div class="mt-auto">
                            <div class="d-flex justify-content-between align-items-center">
                                <span class="h6 text-primary mb-0">$${book.price.toFixed(2)}</span>
                                <div>
                                    <button class="btn btn-sm btn-outline-primary me-1" 
                                            onclick="addToCart(${book.id}, '${book.title}', ${book.price}, '${book.imageUrl}')">
                                        <i class="fas fa-cart-plus"></i>
                                    </button>
                                    <button class="btn btn-sm btn-outline-secondary wishlist-btn" 
                                            onclick="toggleWishlist(${book.id}, '${book.title}')">
                                        <i class="far fa-heart"></i>
                                    </button>
                                </div>
                            </div>
                        </div>
                    </div>
                </div>
            </div>
        `
  })

  container.innerHTML = html
}

// Form Validation
function initializeFormValidation() {
  // Bootstrap form validation
  const forms = document.querySelectorAll(".needs-validation")

  Array.prototype.slice.call(forms).forEach((form) => {
    form.addEventListener(
      "submit",
      (event) => {
        if (!form.checkValidity()) {
          event.preventDefault()
          event.stopPropagation()
        }
        form.classList.add("was-validated")
      },
      false,
    )
  })

  // Custom validation for specific forms
  const registerForm = document.getElementById("register-form")
  if (registerForm) {
    registerForm.addEventListener("submit", validateRegistrationForm)
  }

  const checkoutForm = document.getElementById("checkout-form")
  if (checkoutForm) {
    checkoutForm.addEventListener("submit", validateCheckoutForm)
  }
}

function validateRegistrationForm(event) {
  const password = document.getElementById("password").value
  const confirmPassword = document.getElementById("confirmPassword").value

  if (password !== confirmPassword) {
    event.preventDefault()
    showNotification("Passwords do not match", "error")
    return false
  }

  if (password.length < 6) {
    event.preventDefault()
    showNotification("Password must be at least 6 characters long", "error")
    return false
  }

  return true
}

function validateCheckoutForm(event) {
  const requiredFields = ["fullName", "email", "address", "city", "zipCode"]
  let isValid = true

  requiredFields.forEach((fieldId) => {
    const field = document.getElementById(fieldId)
    if (!field.value.trim()) {
      field.classList.add("is-invalid")
      isValid = false
    } else {
      field.classList.remove("is-invalid")
    }
  })

  if (!isValid) {
    event.preventDefault()
    showNotification("Please fill in all required fields", "error")
  }

  return isValid
}

// Notification System
function showNotification(message, type = "info") {
  // Remove existing notifications
  const existingNotifications = document.querySelectorAll(".notification-toast")
  existingNotifications.forEach((notification) => notification.remove())

  // Create notification element
  const notification = document.createElement("div")
  notification.className = `notification-toast alert alert-${getBootstrapAlertClass(type)} alert-dismissible fade show position-fixed`
  notification.style.cssText = "top: 20px; right: 20px; z-index: 9999; min-width: 300px;"

  notification.innerHTML = `
        ${message}
        <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
    `

  document.body.appendChild(notification)

  // Auto-remove after 5 seconds
  setTimeout(() => {
    if (notification.parentElement) {
      notification.remove()
    }
  }, 5000)
}

function getBootstrapAlertClass(type) {
  const typeMap = {
    success: "success",
    error: "danger",
    warning: "warning",
    info: "info",
  }
  return typeMap[type] || "info"
}

// Utility Functions
function debounce(func, wait) {
  let timeout
  return function executedFunction(...args) {
    const later = () => {
      clearTimeout(timeout)
      func(...args)
    }
    clearTimeout(timeout)
    timeout = setTimeout(later, wait)
  }
}

function formatCurrency(amount) {
  return new Intl.NumberFormat("en-US", {
    style: "currency",
    currency: "USD",
  }).format(amount)
}

function formatDate(dateString) {
  return new Date(dateString).toLocaleDateString("en-US", {
    year: "numeric",
    month: "long",
    day: "numeric",
  })
}

// Loading States
function showLoading(element) {
  if (typeof element === "string") {
    element = document.getElementById(element)
  }
  if (element) {
    element.innerHTML = `
            <div class="text-center py-4">
                <div class="spinner-border text-primary" role="status">
                    <span class="visually-hidden">Loading...</span>
                </div>
            </div>
        `
  }
}

function hideLoading(element) {
  if (typeof element === "string") {
    element = document.getElementById(element)
  }
  if (element) {
    element.innerHTML = ""
  }
}

// Export functions for global use
window.BookStore = {
  addToCart,
  removeFromCart,
  updateCartQuantity,
  toggleWishlist,
  showNotification,
  formatCurrency,
  formatDate,
}
