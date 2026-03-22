import { Controller } from "@hotwired/stimulus";

// Connects to data-controller="lookup"
export default class extends Controller {
  static targets = ["observationMethod"];

  updateParts(event) {
    const observationMethodId = event.target.value; // Get the selected observation_method_id
    const url = new URL(window.location.href);

    if (observationMethodId) {
      url.searchParams.set("observation_method_id", observationMethodId); // Dynamically update the URL
    } else {
      url.searchParams.delete("observation_method_id"); // Remove the parameter if empty
    }

    url.searchParams.delete("part_id"); // Reset parts when observation_method changes
    Turbo.visit(url, { action: "replace" }); // Fetch updated parts with Turbo
  }
}

