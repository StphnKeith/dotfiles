return {
  "scalameta/nvim-metals",
  dependencies = { "nvim-lua/plenary.nvim" },
  ft = { "scala", "sbt", "java" },
  opts = function()
    local metals = require("metals").bare_config()
    metals.settings = {
      showImplicitArguments = true,
    }
    metals.init_options = { statusBarProvider = "on" }
    metals.on_attach = function(_, bufnr)
      local opts = { buffer = bufnr }
      vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)
      vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
      vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)
      vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
      vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
      vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
      vim.keymap.set("n", "<leader>mi", function() require("metals").import_build() end, opts)
    end
    return metals
  end,
  config = function(_, metals)
    local group = vim.api.nvim_create_augroup("nvim-metals", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
      pattern = { "scala", "sbt", "java" },
      group = group,
      callback = function() require("metals").initialize_or_attach(metals) end,
    })
  end,
}
