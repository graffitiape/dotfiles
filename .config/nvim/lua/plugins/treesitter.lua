return {
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    opts = {
      auto_install = true,
      ensure_installed = {
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "typescript",
        "tsx",
        "elixir",
        "heex",
        "javascript",
        "html",
        "c_sharp",
        "css",
        "json",
        "sql",
      },
      sync_install = false,
      highlight = { enable = true },
      indent = { enable = true },
      autotag = {
        enable = true,
      },
    },
    config = function(LazyPlug, opts)
      require("nvim-treesitter.configs").setup(opts)
      vim.lsp.handlers["textDocument/publishDiagnostics"] =
          vim.lsp.with(vim.lsp.diagnostic.on_publish_diagnostics, {
            underline = true,
            virtual_text = {
              spacing = 5,
            },
            update_in_insert = true,
          })
    end,
  }
}
