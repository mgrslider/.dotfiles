-- statusline
local function file_size()
    local size = vim.fn.getfsize(vim.fn.expand("%"))
    if size < 0 then
        return ""
    end
    local size_str
    if size < 1024 then
        size_str = size .. "B"
    elseif size < 1024 * 1024 then
        size_str = string.format("%.1fK", size / 1024)
    else
        size_str = string.format("%.1fM", size / 1024 / 1024)
    end
    return " \u{f016} " .. size_str .. " " -- nf-fa-file_o
end

local function lsp_status()
    local attached_clients = vim.lsp.get_clients({ bufnr = 0 })
    if #attached_clients == 0 then
        return "nil"
    end
    local names = vim.iter(attached_clients)
        :map(function(client)
            local name = client.name:gsub("language.server", "ls")
            return name
        end)
        :totable()
    return "[" .. table.concat(names, ", ") .. "]"
end

_G.file_size = file_size
_G.lsp_status = lsp_status

vim.cmd([[
  highlight StatusLineBold gui=bold cterm=bold
]])

-- Function to change statusline based on window focus
local function setup_dynamic_statusline()
    vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
        callback = function()
            if vim.bo.filetype == "Otree" then
                vim.opt.statusline = "  "
            else
                vim.opt_local.statusline = table.concat({
                    "  ",
                    "%#StatusLineBold#",
                    "%t %h%m%r",
                    "\u{e0b1} ", -- nf-pl-left_hard_divider
                    vim.bo.filetype,
                    "\u{e0b1} ", -- nf-pl-left_hard_divider
                    "%{v:lua.file_size()}",
                    "%#StatusLine#",
                    "%=", -- Right-align everything after this
                    "LSP: ",
                    "%{v:lua.lsp_status()} | ",
                    " \u{f017} %l:%c  %P ", -- nf-fa-clock_o for line/col
                })
            end
        end,
    })
    vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

    vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
        callback = function()
            vim.opt_local.statusline = "  "
        end,
    })
end

setup_dynamic_statusline()
