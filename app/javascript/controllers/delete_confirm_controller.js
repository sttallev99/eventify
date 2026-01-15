import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  delete(event) {
    event.preventDefault();

    // Show custom modal
    const modal = document.getElementById("deleteModal");
    modal.classList.remove("hidden");

    // Store the link to delete
    window.deleteLink = this.element;
  }

  confirm() {
    document.getElementById("deleteModal").classList.add("hidden");

    if (window.deleteLink) {
      const href = window.deleteLink.href;
      const csrfToken = document.querySelector(
        'meta[name="csrf-token"]'
      ).content;

      fetch(href, {
        method: "DELETE",
        headers: {
          "X-CSRF-Token": csrfToken,
          "Content-Type": "application/json",
        },
      })
        .then((response) => {
          window.location.href = "/";
        })
        .catch((error) => {
          console.error("Error:", error);
        });
    }
  }

  cancel() {
    document.getElementById("deleteModal").classList.add("hidden");
  }
}
