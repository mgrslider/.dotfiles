local opt = vim.opt

vim.cmd.colorscheme("habamax")
vim.cmd.highlight({ "Normal", "guibg=NONE" })
vim.cmd.highlight({ "Normal", "ctermbg=NONE" })

opt.number = true
opt.relativenumber = true
opt.mouse = "a"
opt.clipboard = "unnamedplus"
opt.hlsearch = false
opt.incsearch = true
opt.tabstop = 4
opt.shiftwidth = 4
opt.expandtab = true
opt.smartindent = true
opt.encoding = "utf-8"
opt.swapfile = true
opt.updatecount = 20
opt.backup = false
opt.undofile = true
opt.inccommand = "split"
opt.scrolloff = 16
opt.signcolumn = "yes"
opt.redrawtime = 10000
opt.maxmempattern = 20000

vim.g.have_nerd_font = true
