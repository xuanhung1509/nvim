local b = 1
return {
  "neovim/nvim-lspconfig",
  dependencies = {
    { import = "user.plugins.lsp.mason" },
    { "williamboman/mason-lspconfig.nvim" },
    { "yioneko/nvim-vtsls" },
    { "b0o/SchemaStore.nvim" },
  },
  config = function()
    local assign_keymaps = function(_, bufnr)
      local bmap = require("user.utils").map(bufnr)
      local finder = nil
      if Settings.use_fzf then
        finder = require("fzf-lua")
      else
        finder = require("telescope.builtin")
      end

      local actions = {
        peekOrHover = function()
          local winid = require("ufo").peekFoldedLinesUnderCursor()
          if not winid then
            vim.lsp.buf.hover()
          end
        end,
        format_buffer = function()
          vim.lsp.buf.format({ async = true })
        end,
      }

      bmap("n", "K", actions.peekOrHover, "Hover symbol")
      bmap("n", "gd", finder.lsp_definitions, "Go to definitions")
      bmap("n", "gr", finder.lsp_references, "Go to references")
      bmap("n", "gl", vim.diagnostic.open_float, "Line diagnostic")
      bmap("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
      bmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")

      bmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename symbol")
      bmap("n", "<F2>", vim.lsp.buf.rename, "Rename symbol")

      bmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
      bmap("n", "<C-.>", vim.lsp.buf.code_action, "Code action")

      bmap("n", "<leader>fm", vim.lsp.buf.format, "Format buffer")

      -- Lesser known
      bmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
      bmap("n", "gI", finder.lsp_implementations, "Go to implementations")
    end

    local tweak_ui = function()
      ---@param level string
      ---@param icon string
      local define_sign = function(level, icon)
        local name = "DiagnosticSign" .. level
        vim.fn.sign_define(name, { text = icon, texthl = name, numhl = "" })
      end

      define_sign("Error", "")
      define_sign("Warn", "")
      define_sign("Hint", "")
      define_sign("Info", "")

      vim.diagnostic.config({
        virtual_text = false,
        update_in_insert = true,
        severity_sort = true,
        float = {
          style = "minimal",
          border = "single",
          source = "always",
        },
      })

      vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(vim.lsp.handlers.hover, {
        border = "single",
      })

      vim.lsp.handlers["textDocument/signatureHelp"] = vim.lsp.with(vim.lsp.handlers.signature_help, {
        border = "single",
      })

      -- Set border for :LspInfo
      require("lspconfig.ui.windows").default_options.border = "single"
    end

    local setup_servers = function()
      -- Setup capabilities
      local capabilities = vim.lsp.protocol.make_client_capabilities()
      capabilities = require("cmp_nvim_lsp").default_capabilities(capabilities)
      capabilities.textDocument.foldingRange = {
        dynamicRegistration = false,
        lineFoldingOnly = true,
      }

      local common_on_attach = function(client, bufnr)
        assign_keymaps(client, bufnr)

        if client.server_capabilities["documentSymbolProvider"] and client.name ~= "volar" then
          require("nvim-navic").attach(client, bufnr)
        end
      end

      local servers = {
        "lua_ls",
        "bashls",
        "html",
        "cssls",
        "somesass_ls",
        "emmet_language_server",
        "tailwindcss",
        "jsonls",
        "vtsls",
        "eslint",
        "volar",
        "prismals",
        "pyright",
        "ruff_lsp",
      }

      require("mason-lspconfig").setup({
        ensure_installed = servers,
        handlers = {
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = capabilities,
              on_attach = common_on_attach,
            })
          end,
          ["cssls"] = function()
            require("user.plugins.lsp.servers.cssls").setup(capabilities, common_on_attach)
          end,
          ["tailwindcss"] = function()
            require("user.plugins.lsp.servers.tailwindcss").setup(capabilities, common_on_attach)
          end,
          ["jsonls"] = function()
            require("user.plugins.lsp.servers.jsonls").setup(capabilities, common_on_attach)
          end,
          ["vtsls"] = function()
            require("user.plugins.lsp.servers.vtsls").setup(capabilities, common_on_attach)
          end,
          ["volar"] = function()
            require("user.plugins.lsp.servers.volar").setup(capabilities)
          end,
          ["ruff_lsp"] = function()
            require("user.plugins.lsp.servers.ruff-lsp").setup(capabilities, common_on_attach)
          end,
        },
      })
    end

    tweak_ui()
    setup_servers()

    require("user.utils").filter_diagnostics({
      "Oops! Something went wrong!", -- eslint error if no config file found
    })
  end,
  event = { "BufReadPre", "BufNewFile" },
}