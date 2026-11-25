-- NvChad already sets number, expandtab, shiftwidth/tabstop = 2 and mapleader.
vim.opt.relativenumber = true
vim.opt.conceallevel = 2 -- render-markdown / markdown concealing

if vim.fn.executable "fish" == 1 then
    vim.opt.shell = vim.fn.exepath "fish"
end

-- nvchad.options puts mason/bin first on PATH, which shadows the Nix-provided
-- servers and formatters. Keep it, but last, for mason-only tools (e.g. pint).
local sep = ":"
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin"
local path = vim.tbl_filter(function(p)
    return p ~= mason_bin
end, vim.split(vim.env.PATH, sep, { plain = true }))
table.insert(path, mason_bin)
vim.env.PATH = table.concat(path, sep)

vim.filetype.add {
    pattern = { [".*%.blade%.php"] = "blade" },
    extension = { ejs = "html" },
}

if os.getenv "TERM" == "xterm-256color" then
    vim.env.TERM = "xterm-kitty"
end

------------------------------------------------------------------
-- SILENCE NOISY NOTIFICATIONS
------------------------------------------------------------------
local notify = vim.notify
local ignored = {
    "signatureHelp",
    "Couldn't find Astro in workspace",
}

---@diagnostic disable-next-line: duplicate-set-field
vim.notify = function(msg, level, opts)
    if type(msg) == "string" then
        for _, pattern in ipairs(ignored) do
            if msg:find(pattern, 1, true) then
                return
            end
        end
    end
    notify(msg, level, opts)
end

-- Nix: parsers + matching queries from nixpkgs, ahead of any stale copies that
-- an earlier runtime install left in stdpath("data")/site.
local treesitter_runtime = require("custom.paths").treesitter_runtime
if treesitter_runtime then
    vim.opt.rtp:prepend(treesitter_runtime)
end
