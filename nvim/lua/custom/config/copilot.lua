return {
  cmd = { "copilot", "agent", "vscode" },
  filetypes = { "javascript", "typescript", "lua", "python", "go", "rust", "c", "cpp", "java" },
  root_dir = function() return vim.loop.cwd() end,
  capabilities = vim.lsp.protocol.make_client_capabilities(),
}

