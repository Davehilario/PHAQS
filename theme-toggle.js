
(function () {
  const path = (window.location.pathname || '').replace(/\\/g, '/').toLowerCase();
  const isLandingPage = path.endsWith('/patient/index.html') || path.endsWith('/patient/') || path.endsWith('/patient');

  function applyTheme(dark) {
    if (dark) {
      document.documentElement.classList.add('dark-mode');
    } else {
      document.documentElement.classList.remove('dark-mode');
    }

    document.querySelectorAll('.dark-mode-toggle').forEach(function (btn) {
      btn.innerHTML = dark
        ? '<i class="fas fa-sun" title="Switch to Light Mode"></i>'
        : '<i class="fas fa-moon" title="Switch to Dark Mode"></i>';
      btn.setAttribute('title', dark ? 'Switch to Light Mode' : 'Switch to Dark Mode');
    });
  }

  function toggleDarkMode() {
    if (isLandingPage) {
      applyTheme(false);
      return;
    }
    var isDark = document.documentElement.classList.contains('dark-mode');
    var next = !isDark;
    applyTheme(next);
  }

  if (isLandingPage) {
    document.documentElement.classList.remove('dark-mode');
    applyTheme(false);
    document.addEventListener('DOMContentLoaded', function () {
      document.querySelectorAll('.dark-mode-toggle').forEach(function(btn){ btn.style.display = 'none'; });
    });
  } else {
    applyTheme(false);
  }

  window.toggleDarkMode = toggleDarkMode;

  document.addEventListener('DOMContentLoaded', function () {
    var isDark = document.documentElement.classList.contains('dark-mode');
    if (isLandingPage) {
      applyTheme(false);
      document.querySelectorAll('.dark-mode-toggle').forEach(function(btn){ btn.style.display = 'none'; });
      return;
    }
    applyTheme(isDark);
  });
})();
