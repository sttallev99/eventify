import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = [
    "ticketsContainer",
    "emptyState",
    "submit",
    "drawer",
    "ticketTypeInput",
    "priceInput",
    "quantityInput",
    "salesStartInput",
    "salesStartWrapper",
    "salesEndInput",
    "salesEndWrapper",
    "hiddenFields",
    "labelText",
    "preview",
    "fileInput",
    "descriptionInput",
  ];

  static values = {
    preloadTickets: Array,
    preloadImages: Array,
    preloadImagesIds: Array,
  };

  connect() {
    this.tickets = this.preloadTicketsValue || [];
    this.editingIndex = null;
    this.refresh();

    this.filesArray = [];

    if (this.hasPreloadImagesValue) {
      this.preloadImagesValue.forEach((url, index) => {
        this.filesArray.push({
          url,
          existing: true,
          id: this.preloadImagesIdsValue[index],
        });
      });
      this.updatePreview();
    }
  }

  submitForm(event) {
    const dataTransfer = new DataTransfer();

    this.filesArray.forEach((file) => {
      if (!file.existing) {
        dataTransfer.items.add(file);
      }
    });

    this.fileInputTarget.files = dataTransfer.files;
  }

  preview(event) {
    const input = event.target;

    const existingFiles = this.filesArray.filter((f) => f.existing);
    this.filesArray = [...existingFiles, ...Array.from(input.files)];

    this.updatePreview();
  }

  updatePreview() {
    const previewContainer = this.previewTarget;
    previewContainer.innerHTML = "";

    if (this.filesArray.length === 0) {
      this.labelTextTarget.textContent = "Click to upload or drag and drop";
      return;
    }

    const names = this.filesArray
      .map((f) => f.name || "Existing image")
      .join(", ");
    this.labelTextTarget.textContent = names;

    this.filesArray.forEach((file, index) => {
      const wrapper = document.createElement("div");
      wrapper.className = "relative";

      const img = document.createElement("img");
      img.className = "w-20 h-20 object-cover rounded border";

      if (file.existing) {
        img.src = file.url;
      } else {
        const reader = new FileReader();
        reader.onload = (e) => (img.src = e.target.result);
        reader.readAsDataURL(file);
      }

      wrapper.appendChild(img);

      const btn = document.createElement("button");
      btn.type = "button";
      btn.innerHTML = "&times;";
      btn.className =
        "absolute top-0 right-0 bg-red-500 text-white rounded-full w-5 h-5 text-xs flex items-center justify-center hover:bg-red-600";
      btn.addEventListener("click", () => this.removeImage(index));
      wrapper.appendChild(btn);

      previewContainer.appendChild(wrapper);
    });
  }

  removeImage(index) {
    const removed = this.filesArray.splice(index, 1)[0];

    if (removed.existing && removed.id) {
      const input = document.createElement("input");
      input.type = "hidden";
      input.name = "event[remove_image_ids][]";
      input.value = removed.id;
      this.element.appendChild(input);
    }

    this.updatePreview();
  }

  openDrawer(event) {
    const index = event.params?.index;

    this.drawerTarget.classList.remove("hidden");

    if (index === undefined) {
      this.editingIndex = null;
      this.ticketTypeInputTarget.value = "regular";
      this.priceInputTarget.value = "";
      this.quantityInputTarget.value = "";
      this.salesStartInputTarget.value = "";
      this.salesEndInputTarget.value = "";
      this.descriptionInputTarget.value = "";
      this.toggleSalesDates();
      return;
    }

    this.editingIndex = index;
    const ticket = this.tickets[index];
    if (!ticket) return;

    this.ticketTypeInputTarget.value =
      ticket.ticket_type || ticket.ticketType || "regular";

    if (ticket.price && ticket.price.cents !== undefined) {
      this.priceInputTarget.value = (ticket.price.cents / 100).toFixed(2);
    } else {
      this.priceInputTarget.value = Number(ticket.price || 0).toFixed(2);
    }

    console.log(ticket.sales_start_at);

    this.quantityInputTarget.value = ticket.quantity_total || "";
    this.salesStartInputTarget.value = this.formatDateForInput(
      ticket.sales_start_at,
    );
    this.salesEndInputTarget.value = this.formatDateForInput(
      ticket.sales_end_at,
    );
    this.descriptionInputTarget.value = ticket.description || "";

    this.toggleSalesDates();
  }

  toggleSalesDates() {
    const isEarly = this.ticketTypeInputTarget.value === "early_bird";

    if (this.hasSalesStartWrapperTarget) {
      this.salesStartWrapperTarget.style.display = isEarly ? "block" : "none";
    }
    if (this.hasSalesEndWrapperTarget) {
      this.salesEndWrapperTarget.style.display = isEarly ? "block" : "none";
    }
  }

  closeDrawer() {
    this.drawerTarget.classList.add("hidden");
    this.editingIndex = null;
  }

  addTicket() {
    const ticketType = this.ticketTypeInputTarget.value.trim();
    const quantity = this.quantityInputTarget.value.trim();
    const rawPrice = this.priceInputTarget.value.trim();
    const salesStart = this.salesStartInputTarget.value || null;
    const salesEnd = this.salesEndInputTarget.value || null;

    if (!ticketType || !rawPrice || !quantity) {
      alert("Please fill all fields");
      return;
    }

    const priceNumber = Number(rawPrice);
    if (isNaN(priceNumber) || priceNumber <= 0) {
      alert("Please enter a valid price");
      return;
    }

    const validTypes = ["early_bird", "regular", "vip"];
    if (!validTypes.includes(ticketType)) {
      alert(`Invalid ticket type. Choose from: ${validTypes.join(", ")}`);
      return;
    }

    const ticketPayload = {
      ticket_type: ticketType,
      quantity_total: quantity,
      price: priceNumber.toFixed(2),
      sales_start_at: salesStart,
      sales_end_at: salesEnd,
      description: this.descriptionInputTarget.value.trim(),
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
      this.tickets[index] = { ...ticket, _destroy: true };
    } else {
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

      row.innerHTML = `
        <div>
          <div class="font-medium">${ticket.ticket_type}</div>
          <div class="text-sm text-gray-600">
            €${parseFloat(ticket.price).toFixed(2)} · ${ticket.quantity_total} available
          </div>
        </div>
        <div class="flex gap-2">
          <button type="button" data-action="click->event-form#openDrawer" data-event-form-index-param="${index}" class="text-sm text-indigo-600 hover:underline">Edit</button>
          <button type="button" data-action="click->event-form#removeTicket" data-event-form-index-param="${index}" class="text-sm text-red-600 hover:underline">Remove</button>
        </div>
      `;

      this.ticketsContainerTarget.appendChild(row);
    });
  }

  renderHiddenFields() {
    this.hiddenFieldsTarget.innerHTML = "";

    this.tickets.forEach((ticket, index) => {
      const hiddenId = ticket.id
        ? `<input type="hidden" name="event[tickets_attributes][${index}][id]" value="${ticket.id}">`
        : "";
      const hiddenDestroy =
        ticket.id && ticket._destroy
          ? `<input type="hidden" name="event[tickets_attributes][${index}][_destroy]" value="1">`
          : "";

      if (ticket._destroy) {
        this.hiddenFieldsTarget.insertAdjacentHTML(
          "beforeend",
          `${hiddenId}${hiddenDestroy}`,
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
        ${hiddenId}
        <input type="hidden" name="event[tickets_attributes][${index}][ticket_type]" value="${ticket.ticket_type}">
        <input type="hidden" name="event[tickets_attributes][${index}][price]" value="${priceValue}">
        <input type="hidden" name="event[tickets_attributes][${index}][quantity_total]" value="${Number(ticket.quantity_total)}">
        <input type="hidden" name="event[tickets_attributes][${index}][sales_start_at]" value="${ticket.sales_start_at || ""}">
        <input type="hidden" name="event[tickets_attributes][${index}][sales_end_at]" value="${ticket.sales_end_at || ""}">
        <input type="hidden" name="event[tickets_attributes][${index}][description]" value="${ticket.description || ""}">
        ${hiddenDestroy}
      `,
      );
    });
  }

  updateState() {
    const hasTickets = this.tickets.length > 0;
    this.emptyStateTarget.classList.toggle("hidden", hasTickets);
    this.submitTarget.disabled = !hasTickets;
  }

  formatDateForInput(date) {
    if (!date) return "";
    const d = new Date(date);
    const month = String(d.getMonth() + 1).padStart(2, "0");
    const day = String(d.getDate()).padStart(2, "0");
    return `${d.getFullYear()}-${month}-${day}`;
  }
}
