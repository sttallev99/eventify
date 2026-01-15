import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "ticketsContainer",
    "emptyState",
    "submit",
    "drawer",
    "nameInput",
    "priceInput",
    "quantityInput",
    "hiddenFields",
  ];

  static values = { preloadTickets: Array };

  connect() {
    this.tickets = this.preloadTicketsValue || [];
    this.editingIndex = null;
    this.refresh();
  }

  openDrawer(event) {
    const index = event.params?.index;

    this.drawerTarget.classList.remove("hidden");

    // NEW TICKET MODE
    if (index === undefined) {
      this.editingIndex = null;
      this.nameInputTarget.value = "";
      this.priceInputTarget.value = "";
      this.quantityInputTarget.value = "";
      return;
    }

    // EDIT MODE
    this.editingIndex = index;
    const ticket = this.tickets[index];
    if (!ticket) return;

    this.nameInputTarget.value = ticket.name || "";

    // convert Money object or string to number in dollars
    if (ticket.price && ticket.price.cents !== undefined) {
      this.priceInputTarget.value = (ticket.price.cents / 100).toFixed(2);
    } else {
      this.priceInputTarget.value = Number(ticket.price || 0).toFixed(2);
    }

    this.quantityInputTarget.value = ticket.quantity_total || "";
  }

  clearForm() {
    this.nameInputTarget.value = "";
    this.priceInputTarget.value = "";
    this.quantityInputTarget.value = "";
    this.editingIndex = null;
  }

  closeDrawer() {
    this.drawerTarget.classList.add("hidden");
    this.editingIndex = null;
  }

  addTicket() {
    const name = this.nameInputTarget.value.trim();
    const quantity = this.quantityInputTarget.value.trim();
    const rawPrice = this.priceInputTarget.value.trim();

    if (!name || !rawPrice || !quantity) {
      alert("Please fill all fields");
      return;
    }

    const priceNumber = Number(rawPrice);
    if (isNaN(priceNumber) || priceNumber <= 0) {
      alert("Please enter a valid price");
      return;
    }

    const ticketPayload = {
      name,
      quantity_total: quantity,
      price: priceNumber.toFixed(2), // store dollars as string
    };

    if (this.editingIndex !== null) {
      this.tickets[this.editingIndex] = {
        ...this.tickets[this.editingIndex],
        ...ticketPayload,
      };
    } else {
      this.tickets.push(ticketPayload);
    }

    this.closeDrawer();
    this.refresh();
  }

  removeTicket(event) {
    const index = event.params.index;
    const ticket = this.tickets[index];

    if (!confirm("Are you sure you want to remove this ticket?")) return;

    if (ticket.id) {
      // Existing ticket → mark for destruction
      this.tickets[index] = {
        ...ticket,
        _destroy: true,
      };
    } else {
      // New unsaved ticket → remove completely
      this.tickets.splice(index, 1);
    }

    this.refresh();
  }

  refresh() {
    this.renderTickets();
    this.renderHiddenFields();
    this.updateState();
  }

  renderTickets() {
    this.ticketsContainerTarget.innerHTML = "";

    this.tickets.forEach((ticket, index) => {
      if (ticket._destroy) return;
      const row = document.createElement("div");
      row.className =
        "mt-3 flex items-center justify-between rounded-md border p-3";

      console.log(ticket);

      row.innerHTML = `
        <div>
          <div class="font-medium">${ticket.name}</div>
          <div class="text-sm text-gray-600">
            €${parseFloat(ticket.price).toFixed(2)} · ${
        ticket.quantity_total
      } available
          </div>
        </div>

        <div class="flex gap-2">
          <button
            type="button"
            data-action="click->event-form#openDrawer"
            data-event-form-index-param="${index}"
            class="text-sm text-indigo-600 hover:underline"
          >
            Edit
          </button>

          <button
            type="button"
            data-action="click->event-form#removeTicket"
            data-event-form-index-param="${index}"
            class="text-sm text-red-600 hover:underline"
          >
            Remove
          </button>
        </div>
      `;
      this.ticketsContainerTarget.appendChild(row);
    });
  }

  renderHiddenFields() {
    this.hiddenFieldsTarget.innerHTML = "";

    this.tickets.forEach((ticket, index) => {
      // Rails only cares about _destroy for tickets with an id
      const hiddenIdField = ticket.id
        ? `<input type="hidden" name="event[tickets_attributes][${index}][id]" value="${ticket.id}">`
        : "";

      const hiddenDestroyField =
        ticket.id && ticket._destroy
          ? `<input type="hidden" name="event[tickets_attributes][${index}][_destroy]" value="1">`
          : "";

      // Skip rendering normal fields if ticket is marked for destruction
      if (ticket._destroy) {
        this.hiddenFieldsTarget.insertAdjacentHTML(
          "beforeend",
          `${hiddenIdField}${hiddenDestroyField}`
        );
        return;
      }

      const priceValue =
        ticket.price && ticket.price.cents !== undefined
          ? (ticket.price.cents / 100).toFixed(2)
          : Number(ticket.price || 0).toFixed(2);

      this.hiddenFieldsTarget.insertAdjacentHTML(
        "beforeend",
        `
        ${hiddenIdField}
        <input type="hidden" name="event[tickets_attributes][${index}][name]" value="${
          ticket.name
        }">
        <input type="hidden" name="event[tickets_attributes][${index}][price]" value="${priceValue}">
        <input type="hidden" name="event[tickets_attributes][${index}][quantity_total]" value="${Number(
          ticket.quantity_total
        )}">
        ${hiddenDestroyField}
      `
      );
    });
  }

  updateState() {
    const hasTickets = this.tickets.length > 0;
    this.emptyStateTarget.classList.toggle("hidden", hasTickets);
    this.submitTarget.disabled = !hasTickets;
  }
}
