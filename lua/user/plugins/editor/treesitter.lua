return {
  "nvim-treesitter/nvim-treesitter",
  build = ":TSUpdate",
  dependencies = {
    { "windwp/nvim-ts-autotag", opts = {} },
    { "JoosepAlviste/nvim-ts-context-commentstring", opts = {} },
    "nvim-treesitter/nvim-treesitter-textobjects",
    { "nvim-treesitter/nvim-treesitter-context", opts = { max_lines = 3 } },
  },
  config = function()
    require("nvim-treesitter.configs").setup({
      ensure_installed = {
        -- the listed parsers MUST always be installed
        "c",
        "lua",
        "vim",
        "vimdoc",
        "query",
        "markdown",
        "markdown_inline",

        -- user list
        "bash",
        "html",
        "css",
        "scss",
        "json",
        "javascript",
        "typescript",
        "tsx",
        "vue",
        "pug",
        "prisma",
        "python",
        "toml",
        "yaml",
        "gitcommit",
      },
      auto_install = false,
      incremental_selection = {
        enable = true,
        keymaps = {
          init_selection = "<C-space>",
          node_incremental = "<C-space>",
          scope_incremental = false,
          node_decremental = "<bs>",
        },
      },
      highlight = { enable = true },
      indent = { enable = true },
      textobjects = {
        select = {
          enable = true,
          lookahead = true,
          keymaps = {
            ["af"] = { query = "@function.outer", desc = "Select outter part of a function definition" },
            ["if"] = { query = "@function.inner", desc = "Select inner part of a function definition" },
            ["ac"] = { query = "@class.outer", desc = "Select outer part of a class" },
            ["ic"] = { query = "@class.inner", desc = "Select inner part of a class" },
            ["ai"] = { query = "@conditional.outer", desc = "Select outer part of a conditional" },
            ["ii"] = { query = "@conditional.inner", desc = "Select inner part of a conditional" },
            ["al"] = { query = "@loop.outer", desc = "Select outer part of a loop" },
            ["il"] = { query = "@loop.inner", desc = "Select inner part of a loop" },
          },
        },
      },
    })
  end,
  cmd = { "TSInstall", "TSInstallInfo", "TSModuleInfo" },
  event = { "BufReadPost", "BufNewFile" },
}
