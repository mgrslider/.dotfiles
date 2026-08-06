vim.g.mapleader = " "
vim.g.maplocalleader = " "

vim.keymap.set("n", "<Esc>", "<cmd>nohlsearch<CR>")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv", { noremap = true, silent = true })
vim.keymap.set("n", "n", "nzzzv", { desc = "Next search result (centered)" })
vim.keymap.set("n", "N", "Nzzzv", { desc = "Previous search result (centered)" })
vim.keymap.set("n", "<C-d>", "<C-d>zz", { desc = "Half page down (centered)" })
vim.keymap.set("n", "<C-u>", "<C-u>zz", { desc = "Half page up (centered)" })
vim.keymap.set('n', '<C-j>', '<C-w>j', { desc = "Focus window below" })
vim.keymap.set('n', '<C-k>', '<C-w>k', { desc = "Focus window above" })
vim.keymap.set('n', '<C-h>', '<C-w>h', { desc = "Focus window to the left" })
vim.keymap.set('n', '<C-l>', '<C-w>l', { desc = "Focus window to the right" })
vim.keymap.set("n", "<leader>f", function() vim.lsp.buf.format({ async = true }) end, { desc = "Format buffer" })
vim.keymap.set("n", "<leader>fj", ':%!jq .<CR>', { desc = "Format buffer" })
vim.keymap.set("n", "<leader>q", vim.diagnostic.setloclist, { desc = "Open diagnostic [Q]uickfix list" })
vim.keymap.set("x", "<leader>p", '"_dP', { desc = "Paste without yanking" })
local term_buf = nil
local prev_win = nil
vim.keymap.set("n", "<leader>t", function()
    prev_win = vim.api.nvim_get_current_win()
    vim.cmd("botright split")
    if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
        vim.api.nvim_win_set_buf(0, term_buf)
    else
        vim.cmd("terminal")
        term_buf = vim.api.nvim_get_current_buf()
        vim.keymap.set({ "n", "t" }, "<Esc><Esc>", function()
            vim.cmd("close")
            if prev_win and vim.api.nvim_win_is_valid(prev_win) then
                vim.api.nvim_set_current_win(prev_win)
            end
        end, { buffer = term_buf, silent = true, nowait = true })
    end
    vim.cmd("startinsert")
end, { desc = "Enter terminal with ready to type cursor" })
