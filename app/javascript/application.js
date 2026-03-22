// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import * as ActiveStorage from "@rails/activestorage"
import "controllers"

ActiveStorage.start()

// Auto-dismiss flash notices after 5 seconds
document.addEventListener('turbo:load', () => {
  const notices = document.querySelectorAll('[data-auto-dismiss="true"]');
  notices.forEach(notice => {
    setTimeout(() => {
      notice.style.opacity = '0';
      setTimeout(() => notice.remove(), 500);
    }, 5000);
  });
});
