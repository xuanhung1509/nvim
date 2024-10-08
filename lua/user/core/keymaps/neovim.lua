local utils = require("user.utils")
local gmap = utils.map()

gmap("n", "<leader>w", ":w <cr>", "Save buffer")
gmap("n", "<leader>W", ":noautocmd w <cr>", "Save buffer without formatting")

-- Navigate windows
gmap("n", "<C-h>", "<C-w>h", "Navigate to left window")
gmap("n", "<C-l>", "<C-w>l", "Navigate to right window")
gmap("n", "<C-j>", "<C-w>j", "Navigate to lower window")
gmap("n", "<C-k>", "<C-w>k", "Navigate to upper window")

-- Split windows
gmap("n", "<C-\\>", "<C-w>v", "Split window vertically")
gmap("n", "<leader>sv", "<C-w>v", "Split window vertically")
gmap("n", "<leader>sh", "<C-w>s", "Split window horizontally")
gmap("n", "<leader>se", "<C-w>=", "Split window equally")
gmap("n", "<leader>sm", utils.toggle_maximize_window, "Toggle miximize window")

-- Line editing
gmap("n", "<A-j>", ":m .+1<cr>==", "Move line down")
gmap("n", "<A-k>", ":m .-2<cr>==", "Move line up")
gmap("n", "<A-J>", "yyp", "Copy line down")
gmap("n", "<A-K>", "yyP", "Copy line up")

-- Block editing
gmap("v", "<A-j>", ":m '>+1<cr>gv-gv", "Move block down")
gmap("v", "<A-k>", ":m '<-2<cr>gv-gv", "Move block up")
gmap("v", "<A-J>", "yPgv", "Copy block down")
gmap("v", "<A-K>", "y'>pgv", "Copy block up")

-- Better select
gmap({ "o", "x" }, "a'", "2i'", "Select arround ' without leading whitespace")
gmap({ "o", "x" }, 'a"', '2i"', 'Select arround " without leading whitespace')

-- Toggle options
gmap("n", "<leader>uc", utils.toggle_cmdline, "Toggle cmdline")
gmap("n", "<leader>uw", utils.toggle_word_wrap, "Toggle word wrap")
