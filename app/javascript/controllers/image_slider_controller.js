import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  static targets = ["slide"];

  connect() {
    this.currentIndex = 0;
    this.showSlide(this.currentIndex);
  }

  prev() {
    this.currentIndex =
      (this.currentIndex - 1 + this.slideTargets.length) %
      this.slideTargets.length;
    this.showSlide(this.currentIndex);
  }

  next() {
    this.currentIndex = (this.currentIndex + 1) % this.slideTargets.length;
    this.showSlide(this.currentIndex);
  }

  showSlide(index) {
    this.slideTargets.forEach((el, i) => {
      el.classList.toggle("hidden", i !== index);
    });
  }
}
