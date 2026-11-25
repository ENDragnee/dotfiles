-- This file needs to have same structure as nvconfig.lua
-- https://github.com/NvChad/ui/blob/v3.0/lua/nvconfig.lua
-- Please read that file to know all available options :(
-- Shared: the Nix configs install this file as their chadrc.lua too.

---@type ChadrcConfig
local M = {}

M.base46 = {
    theme = "gruvbox",

    -- hl_override = {
    -- 	Comment = { italic = true },
    -- 	["@comment"] = { italic = true },
    -- },
}

return M
