window.mosaico = window.mosaico || { plugins: [] }
window.mosaico.plugins = window.mosaico.plugins || []

window.mosaico.plugins.push(
  function(viewModel) {
    viewModel.t = function(key) {
      return viewModel.tt(window.mosaico.translations[key] || key);
    }
  }
);
