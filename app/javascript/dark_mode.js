// Dark mode functionality
class DarkModeToggle {
  constructor() {
    this.init();
  }

  init() {
    // Apply saved theme immediately to prevent flash
    this.applySavedTheme();
    
    // Set up toggle listener when DOM is ready
    if (document.readyState === 'loading') {
      document.addEventListener('DOMContentLoaded', () => this.setupToggle());
    } else {
      this.setupToggle();
    }
  }

  applySavedTheme() {
    const isDarkMode = localStorage.getItem('dark-mode') === 'true';
    const html = document.querySelector('html');
    
    if (isDarkMode) {
      html.classList.add('dark');
    } else {
      html.classList.remove('dark');
    }
  }

  setupToggle() {
    const lightSwitch = document.getElementById('light-switch');
    
    if (lightSwitch) {
      // Set initial state
      const isDarkMode = localStorage.getItem('dark-mode') === 'true';
      lightSwitch.checked = isDarkMode;
      
      // Listen for changes
      lightSwitch.addEventListener('change', (e) => this.handleToggle(e));
    }
  }

  handleToggle(event) {
    const html = document.querySelector('html');
    
    if (event.target.checked) {
      html.classList.add('dark');
      localStorage.setItem('dark-mode', 'true');
    } else {
      html.classList.remove('dark');
      localStorage.setItem('dark-mode', 'false');
    }
  }
}

// Initialize dark mode toggle
new DarkModeToggle();