-- Runs as the nvim-dap config function (see custom/plugins.lua).
local nix = require("custom.nix")
local dap = require("dap")
local dapui = require("dapui")

dapui.setup()

-- Auto open/close DAP UI
dap.listeners.before.attach.dapui_config = function()
  dapui.open()
end
dap.listeners.before.launch.dapui_config = function()
  dapui.open()
end
dap.listeners.before.event_terminated.dapui_config = function()
  dapui.close()
end
dap.listeners.before.event_exited.dapui_config = function()
  dapui.close()
end

-- JS / TS adapter (Node, NestJS, Next.js)
dap.adapters["pwa-node"] = {
  type = "server",
  host = "127.0.0.1",
  port = "${port}",
  executable = {
    command = nix.js_debug,
    args = { "${port}" },
  },
}

local js_ts_configs = {
  {
    type = "pwa-node",
    request = "launch",
    name = "Launch current file",
    program = "${file}",
    cwd = "${workspaceFolder}",
    sourceMaps = true,
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach to Node / NestJS / Next.js (port 9229)",
    address = "127.0.0.1",
    port = 9229,
    cwd = "${workspaceFolder}",
    sourceMaps = true,
    skipFiles = { "<node_internals>/**" },
  },
  {
    type = "pwa-node",
    request = "attach",
    name = "Attach to process (pick PID)",
    processId = require("dap.utils").pick_process,
    cwd = "${workspaceFolder}",
    sourceMaps = true,
    skipFiles = { "<node_internals>/**" },
  },
}

for _, lang in ipairs({ "javascript", "typescript", "javascriptreact", "typescriptreact" }) do
  dap.configurations[lang] = js_ts_configs
end

-- C / C++ / Rust adapter via lldb-dap
dap.adapters.lldb = {
  type = "executable",
  command = nix.lldb_dap,
  name = "lldb",
}

local lldb_config = {
  {
    name = "Launch executable",
    type = "lldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntry = false,
    args = {},
  },
}

dap.configurations.c = lldb_config
dap.configurations.cpp = lldb_config
dap.configurations.rust = lldb_config

-- Python adapter
require("dap-python").setup(nix.python)
