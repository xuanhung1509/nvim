return {
  "nvim-neo-tree/neo-tree.nvim",
  branch = "v3.x",
  dependencies = {
    "nvim-lua/plenary.nvim",
    "nvim-tree/nvim-web-devicons",
    "MunifTanjim/nui.nvim",
  },
  opts = {
    commands = {
      system_open = function(state)
        require("user.utils").system_open(state.tree:get_node():get_id())
      end,
      parent_or_close = function(state)
        local node = state.tree:get_node()
        if (node.type == "directory" or node:has_children()) and node:is_expanded() then
          state.commands.toggle_node(state)
        else
          require("neo-tree.ui.renderer").focus_node(state, node:get_parent_id())
        end
      end,
      child_or_open = function(state)
        local node = state.tree:get_node()
        if node.type == "directory" or node:has_children() then
          if not node:is_expanded() then -- if unexpanded, expand
            state.commands.toggle_node(state)
          else -- if expanded and has children, select the next child
            require("neo-tree.ui.renderer").focus_node(state, node:get_child_ids()[1])
          end
        else -- if not a directory just open it
          state.commands.open(state)
        end
      end,
      copy_selector = function(state)
        local node = state.tree:get_node()
        local filepath = node:get_id()
        local filename = node.name
        local modify = vim.fn.fnamemodify

        local results = {
          e = { val = modify(filename, ":e"), msg = "Extension only" },
          f = { val = filename, msg = "Filename" },
          F = { val = modify(filename, ":r"), msg = "Filename w/o extension" },
          h = { val = modify(filepath, ":~"), msg = "Path relative to Home" },
          p = { val = modify(filepath, ":."), msg = "Path relative to CWD" },
          P = { val = filepath, msg = "Absolute path" },
        }

        local messages = {
          { "\nChoose to copy to clipboard:\n", "Normal" },
        }
        for i, result in pairs(results) do
          if result.val and result.val ~= "" then
            vim.list_extend(messages, {
              { ("%s."):format(i), "Identifier" },
              { (" %s: "):format(result.msg) },
              { result.val, "String" },
              { "\n" },
            })
          end
        end
        vim.api.nvim_echo(messages, false, {})
        local result = results[vim.fn.getcharstr()]
        if result and result.val and result.val ~= "" then
          vim.notify("Copied: " .. result.val, vim.log.levels.INFO, { title = "neo-tree" })
          vim.fn.setreg("+", result.val)
        end
      end,
    },
    window = {
      mappings = {
        o = "open",
        ["<C-cr>"] = "open_vsplit",
        O = "system_open",
        h = "parent_or_close",
        l = "child_or_open",
        Y = "copy_selector",
      },
    },
    filesystem = {
      follow_current_file = { enabled = true },
      filtered_items = {
        hide_dotfiles = false,
        hide_by_name = { ".git" },
      },
    },
    event_handlers = {
      ---------- Equalize Window Sizes on Neo-tree Open and Close ----------
      {
        event = "neo_tree_window_after_open",
        handler = function(args)
          if args.position == "left" or args.position == "right" then
            vim.cmd("wincmd =")
          end
        end,
      },
      {
        event = "neo_tree_window_after_close",
        handler = function(args)
          if args.position == "left" or args.position == "right" then
            vim.cmd("wincmd =")
          end
        end,
      },
    },
  },
  cmd = "Neotree",
  keys = { { "<leader>e", "<cmd> Neotree toggle <cr>", desc = "NeoTree" } },
}
