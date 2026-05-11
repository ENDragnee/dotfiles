{
  programs.nixvim = {
    # 1. Provide custom Lua functions required by your mappings
    extraConfigLua = ''
      -- Global toggle function for Copilot
      _G.toggle_copilot = function()
          if vim.fn.exists(":Copilot") == 0 then
              print("Copilot not installed")
              return
          end

          local clients = vim.lsp.get_clients({ name = "copilot" })
          if not vim.tbl_isempty(clients) then
              vim.cmd(":Copilot disable")
              print("Copilot is disabled")
          else
              vim.cmd(":Copilot enable")
              print("Copilot is enabled")
          end
      end

      -- Load NvChad's default mappings just like your old init.lua did!
      pcall(function()
          require("nvchad.mappings")
      end)
    '';

    # 2. Define all your custom mappings
    keymaps =[
      # --- General ---
      { mode = "n"; key = ";"; action = ":"; options.desc = "CMD enter command mode"; }
      { mode = "i"; key = "jk"; action = "<ESC>"; }

      # --- LSP & Diagnostics ---
      { mode = "n"; key = "K"; action = "<cmd>lua vim.diagnostic.open_float()<cr>"; options.desc = "Open diagnostic float"; }
      { mode = "n"; key = "<leader>gd"; action = "<cmd>lua vim.lsp.buf.definition()<cr>"; options.desc = "Go to definition"; }
      { mode = "n"; key = "<leader>ca"; action = "<cmd>lua vim.lsp.buf.code_action()<cr>"; options.desc = "LSP Code Action"; }

      # --- Telescope ---
      { mode = "n"; key = "<A-p>"; action = "<cmd>Telescope project<cr>"; options.desc = "Projects"; }
      { mode = "n"; key = "<A-l>"; action = "<cmd>Telescope terms<cr>"; options.desc = "Toggle hidden terminals"; }

      # --- Copilot ---
      {
        mode = "i";
        key = "<C-/>";
        action.__raw = "function() require('copilot.suggestion').accept_line() end";
        options = { expr = false; noremap = true; silent = true; desc = "Copilot Accept Line"; };
      }
      { mode = "n"; key = "<C-]>"; action = "<cmd>lua _G.toggle_copilot()<cr>"; options.desc = "Copilot Toggle"; }
      { mode = "n"; key = "<A-/>"; action = "<cmd>CopilotChatToggle<cr>"; options.desc = "Copilot Toggle"; }

      # --- CopilotChat ---
      { mode = "n"; key = "<leader>ccq"; action = "<cmd>lua require('CopilotChat').ask(vim.fn.input('Quick Chat: '))<CR>"; options.desc = "CopilotChat - Quick chat"; }
      { mode = [ "n" "v" ]; key = "<leader>ccv"; action = "<cmd>CopilotChatVisual<CR>"; options.desc = "CopilotChat - Visual selection chat"; }
      { mode = "n"; key = "<leader>ccb"; action = "<cmd>CopilotChatBuffer<CR>"; options.desc = "CopilotChat - Buffer chat"; }
      { mode = "v"; key = "<leader>cce"; action = ":CopilotChatExplain<CR>"; options.desc = "Explain selection"; }
      { mode = "v"; key = "<leader>ccf"; action = ":CopilotChatFix<CR>"; options.desc = "Fix selection"; }
      {
        mode = "v";
        key = "<leader>cci";
        action.__raw = "function() require('CopilotChat').ask_inline('Fix this error and rewrite') end";
        options.desc = "Copilot Inline Fix";
      }

      # --- DAP (Debugging) ---
      { mode = "n"; key = "<leader>db"; action = "<cmd>lua require('dap').toggle_breakpoint()<cr>"; options.desc = "Dap Toggle Breakpoint"; }
      { mode = "n"; key = "<leader>dr"; action = "<cmd>lua require('dap').continue()<cr>"; options.desc = "Dap Start/Continue"; }
      { mode = "n"; key = "<leader>di"; action = "<cmd>lua require('dap').step_into()<cr>"; options.desc = "Dap Step Into"; }
      { mode = "n"; key = "<leader>do"; action = "<cmd>lua require('dap').step_over()<cr>"; options.desc = "Dap Step Over"; }
      { mode = "n"; key = "<leader>dt"; action = "<cmd>lua require('dap').terminate()<cr>"; options.desc = "Dap Terminate"; }
      { mode = "n"; key = "<leader>du"; action = "<cmd>lua require('dapui').toggle()<cr>"; options.desc = "Toggle DAP UI"; }

      # --- Agentic ---
      { mode = [ "n" "v" "i" ]; key = "<C-`>"; action = "<cmd>lua require('agentic').toggle()<cr>"; options.desc = "Toggle Agentic Chat"; }
      { mode = [ "n" "v" "i" ]; key = "<C-,>"; action = "<cmd>lua require('agentic').new_session()<cr>"; options.desc = "New Agentic Session"; }
      { mode =[ "n" "v" "i" ]; key = "<A-i>r"; action = "<cmd>lua require('agentic').restore_session()<cr>"; options = { desc = "Agentic Restore session"; silent = true; }; }
      { mode = [ "n" "v" ]; key = "<leader>ac"; action = "<cmd>lua require('agentic').toggle()<cr>"; options.desc = "Toggle Agentic Chat"; }
      { mode =[ "n" "v" ]; key = "<leader>aa"; action = "<cmd>lua require('agentic').add_selection_or_file_to_context()<cr>"; options.desc = "Add file or selection to Agentic to Context"; }
      { mode = [ "n" "v" ]; key = "<leader>an"; action = "<cmd>lua require('agentic').new_session()<cr>"; options.desc = "New Agentic Session"; }
      { mode = [ "n" "v" ]; key = "<leader>ar"; action = "<cmd>lua require('agentic').restore_session()<cr>"; options = { desc = "Agentic Restore session"; silent = true; }; }
      { mode = "n"; key = "<leader>ad"; action = "<cmd>lua require('agentic').add_current_line_diagnostics()<cr>"; options.desc = "Add current line diagnostic to Agentic"; }
      { mode = "n"; key = "<leader>aD"; action = "<cmd>lua require('agentic').add_buffer_diagnostics()<cr>"; options.desc = "Add all buffer diagnostics to Agentic"; }
    ];
  };
}
