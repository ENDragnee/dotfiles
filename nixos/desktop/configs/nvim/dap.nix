{ pkgs, ... }:

let
  # We package python specifically with debugpy so Neovim can use it as the adapter
  pythonWithDebugpy = pkgs.python3.withPackages (p:[ p.debugpy ]);
in
{
  programs.nixvim = {
    # Expose the C/C++ debugger so Neovim can run it
    extraPackages = with pkgs;[
      vscode-extensions.vadimcn.vscode-lldb
    ];

    plugins.dap = {
      enable = true;
      
      extensions = {
        dap-ui.enable = true;
        dap-python.enable = true;
      };
    };

    # Replicate your custom DAP configurations and UI auto-open exactly
    extraConfigLua = ''
      local dap = require("dap")
      local dapui = require("dapui")

      -- 1. Auto open DAP UI on launch/attach
      dap.listeners.before.attach.dapui_config = function()
          dapui.open()
      end
      dap.listeners.before.launch.dapui_config = function()
          dapui.open()
      end

      -- 2. Codelldb Adapter Setup (Replaces Mason Path)
      dap.adapters.codelldb = {
          type = "server",
          port = "''${port}",
          executable = {
              command = "${pkgs.vscode-extensions.vadimcn.vscode-lldb}/share/vscode/extensions/vadimcn.vscode-lldb/adapter/codelldb",
              args = { "--port", "''${port}" },
          },
      }

      -- 3. C / C++ Configurations
      local c_cpp_config = {
          {
              name = "Launch",
              type = "codelldb",
              request = "launch",
              program = function()
                  return vim.fn.input("Path: ", vim.fn.getcwd() .. "/", "file")
              end,
              args = function()
                  local args_str = vim.fn.input("Arguments: ")
                  return vim.split(args_str, " +")
              end,
              cwd = "''${workspaceFolder}",
              stopOnEntry = false,
          },
      }
      dap.configurations.c = c_cpp_config
      dap.configurations.cpp = c_cpp_config

      -- 4. Python Adapter Configuration (Replaces Mason Path)
      dap.adapters.python = {
          type = "executable",
          command = "${pythonWithDebugpy}/bin/python",
          args = { "-m", "debugpy.adapter" },
      }

      dap.configurations.python = {
          {
              type = "python",
              request = "launch",
              name = "Launch file",
              program = "''${file}",
              pythonPath = function()
                  -- Automatically use virtual environments if they exist
                  local cwd = vim.fn.getcwd()
                  if vim.fn.executable(cwd .. "/venv/bin/python") == 1 then
                      return cwd .. "/venv/bin/python"
                  elseif vim.fn.executable(cwd .. "/.venv/bin/python") == 1 then
                      return cwd .. "/.venv/bin/python"
                  else
                      -- Fallback to standard Nix python
                      return "${pkgs.python3}/bin/python" 
                  end
              end,
          },
      }
      
      -- Setup dap-python to use the Nix debugpy environment
      require("dap-python").setup("${pythonWithDebugpy}/bin/python")
    '';
  };
}
