return {
  "mfussenegger/nvim-dap-python",
  opts = {
    -- Hier definierst du den Pfad zum Python-Interpreter.
    -- "python" nimmt den Interpreter aus deiner aktuell AKTIVIERTEN Shell-Umgebung.
    include_configs = true,
  },
  config = function(_, opts)
    -- Wir ermitteln, ob wir in einer venv sind, sonst Fallback auf System-Python
    local path = vim.fn.exepath("python")
    require("dap-python").setup(path, opts)
  end,
}
