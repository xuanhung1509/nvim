local M = {}

--- Define a keymap. If `bufnr` is present, the mapping is buffer-scoped.
---@param bufnr? any
M.map = function(bufnr)
  ---@param mode string | table Can be a single mode or multiple modes
  ---@param lhs string Left-hand side `{lhs}` of the mapping
  ---@param rhs string | function Right-hand side `{rhs}` of the mapping
  ---@param desc? string Description
  ---@param opts? table | nil Other map arguments
  return function(mode, lhs, rhs, desc, opts)
    local full_opts = vim.tbl_deep_extend("force", opts or {}, { desc = desc }, bufnr and { buffer = bufnr } or {})
    vim.keymap.set(mode, lhs, rhs, full_opts)
  end
end

---@param msg string Notification body
---@param type? number Notification type (:help vim.log.levels)
---@param opts? table Optional params
M.notify = function(msg, type, opts)
  vim.schedule(function()
    vim.notify(msg, type, opts)
  end)
end

--- Open a URL under the cursor with the current operating system
---@param path string The path of the file to open with the system opener
M.system_open = function(path)
  if vim.ui.open then
    return vim.ui.open(path)
  end
  local cmd
  if vim.fn.has("win32") == 1 and vim.fn.executable("explorer") == 1 then
    -- windows
    cmd = { "cmd.exe", "/K", "explorer" }
  elseif vim.fn.has("unix") == 1 and vim.fn.executable("xdg-open") == 1 then
    -- linux
    cmd = { "xdg-open" }
  elseif (vim.fn.has("mac") == 1 or vim.fn.has("unix") == 1) and vim.fn.executable("open") == 1 then
    -- osx
    cmd = { "open" }
  end
  if not cmd then
    M.notify("Available system opening tool not found", vim.log.levels.ERROR)
  end
  vim.fn.jobstart(vim.fn.extend(cmd, { path or vim.fn.expand("<cfile>") }), { detach = true })
end

M.is_git_repo = function()
  local path = (vim.uv or vim.loop).cwd() .. "/.git"
  return not not (vim.uv or vim.loop).fs_stat(path)
end

--- Allow switching between plugins without remove the unused in `lazy-lock.json`
---@param condition boolean
---@param events? string[]
M.should_plugin_load = function(condition, events)
  if condition then
    return events or { "VimEnter" }
  else
    return {}
  end
end

--- Filter out diagnostic messages we do not want to see
---@param messages string[]
M.filter_diagnostics = function(messages)
  local filter = function(diagnostics)
    return vim.tbl_filter(function(diagnostic)
      for _, message in pairs(messages) do
        return not string.find(diagnostic.message, message)
      end
    end, diagnostics)
  end

  local old_set = vim.diagnostic.set

  vim.diagnostic.set = function(namespace, bufnr, diagnostics, opts)
    old_set(namespace, bufnr, filter(diagnostics), opts)
  end
end

return M
