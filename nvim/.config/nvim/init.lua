require("settings")
require("keymaps")
require("status_line")

vim.pack.add({
    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        branch = "main",
        build = ":TSUpdate",
    },
    "https://www.github.com/neovim/nvim-lspconfig",
    "https://github.com/mason-org/mason.nvim",

    "https://github.com/stevearc/oil.nvim",
    "https://github.com/Eutrius/Otree.nvim",
    "https://github.com/nvim-tree/nvim-web-devicons",

    "https://github.com/lewis6991/gitsigns.nvim",
    "https://github.com/powerman/vim-plugin-AnsiEsc",
    "https://github.com/tpope/vim-fugitive",

    "https://github.com/mbbill/undotree",
    "https://github.com/ibhagwan/fzf-lua",
})

-- setup fzf
do
    local fzf = require("fzf-lua")
    vim.keymap.set("n", "<Leader>ff", fzf.files, { desc = "FZF: Znajdź pliki" })
    vim.keymap.set("n", "<Leader>fs", fzf.live_grep, { desc = "FZF: Szukaj tekstu (grep)" })
end
-- setup undotree
do
    vim.g.undotree_WindowLayout = 4
    vim.g.undotree_SetFocusWhenToggle = 1
    vim.g.undotree_SplitWidth = 50
    vim.g.undotree_DiffAutoOpen = 0
    vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle)
end
-- setup_otree
do
    vim.keymap.set("n", "<leader>e", ":OtreeFocus<CR>", { desc = "Focus file tree", silent = true })

    vim.api.nvim_create_autocmd("BufEnter", {
        group = vim.api.nvim_create_augroup("otree_esc_fix", { clear = true }),
        callback = function()
            vim.defer_fn(function()
                if vim.bo.filetype == "Otree" then
                    vim.keymap.set("n", "<Esc><Esc>", ":qa!<CR>", { buffer = true, silent = true, nowait = true })
                end
            end, 150)
        end,
    })
    require("oil").setup({
        columns = { "icon" },
        default_file_explorer = false,
        skip_confirm_for_simple_edits = true,
        view_options = {
            show_hidden = true,
        },
    })

    require("Otree").setup({
        win_size = 40,
        open_on_left = true,
        open_on_startup = false,
        show_hidden = true,
        focus_on_enter = false,
        hijack_netrw = true,
    })
end
-- setup treesitter
do
    local treesitter = require("nvim-treesitter")
    treesitter.setup({})
    local ensure_installed = {
        "vim",
        "vimdoc",
        "c",
        "html",
        "css",
        "javascript",
        "json",
        "lua",
        "markdown",
        "bash",
        "odin",
        "kotlin",
        "java",
        "go"
    }

    local config = require("nvim-treesitter.config")
    local already_installed = config.get_installed()
    local parsers_to_install = {}

    for _, parser in ipairs(ensure_installed) do
        if not vim.tbl_contains(already_installed, parser) then
            table.insert(parsers_to_install, parser)
        end
    end

    if #parsers_to_install > 0 then
        treesitter.install(parsers_to_install)
    end

    local group = vim.api.nvim_create_augroup("TreeSitterConfig", { clear = true })
    vim.api.nvim_create_autocmd("FileType", {
        group = group,
        callback = function(args)
            if vim.list_contains(config.get_installed(), vim.treesitter.language.get_lang(args.match)) then
                vim.treesitter.start(args.buf)
            end
        end,
    })
end
-- setup LSP
do
    vim.o.autocomplete = true
    vim.opt.completeopt = { 'menuone', 'noinsert', 'popup', 'fuzzy' }
    
    vim.api.nvim_create_autocmd('LspAttach', {
        group = vim.api.nvim_create_augroup('my.lsp', {}),
        callback = function(ev)
            local opts = { buffer = ev.buf, remap = false }
            vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
            vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
            vim.keymap.set("n", "<Leader>rn", function() vim.lsp.buf.rename() end, opts)
            local client = assert(vim.lsp.get_client_by_id(ev.data.client_id))
            if client:supports_method('textDocument/completion') then
                vim.lsp.completion.enable(true, client.id, ev.buf, { autotrigger = true })
            end
        end,
    })

    vim.lsp.config("lua_ls", {
        settings = {
            Lua = {
                diagnostics = { globals = { "vim" } },
                telemetry = { enable = false },
            },
        },
    })

    local servers = { "clangd", "ols", "bashls", "jdtls", "lua_ls", "kotlin_lsp" }
    for _, server in ipairs(servers) do
        vim.lsp.enable(server)
    end
end

require("mason").setup({})

local default_group = vim.api.nvim_create_augroup("user_config", {})

vim.api.nvim_create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text",
    group = default_group,
    callback = function()
        vim.highlight.on_yank()
    end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
    desc = "Return to last edit position when opening files",
    group = default_group,
    callback = function()
        local mark = vim.api.nvim_buf_get_mark(0, '"')
        local lcount = vim.api.nvim_buf_line_count(0)
        local line = mark[1]
        local ft = vim.bo.filetype
        if line > 0 and line <= lcount
            and vim.fn.index({ "commit", "gitrebase", "xxd" }, ft) == -1
            and not vim.o.diff then
            pcall(vim.api.nvim_win_set_cursor, 0, mark)
        end
    end,
})
