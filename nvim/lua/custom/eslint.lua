local lspconfig = vim.lsp.config

lspconfig.eslint.setup {
    on_attach = function(client, bufnr)
        client.server_capabilities.documentFormattingProvider = true

        vim.api.nvim_create_autocmd("BufWritePre", {
            buffer = bufnr,
            command = "EslintFixAll",
        })
    end,
}
