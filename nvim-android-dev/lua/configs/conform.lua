return {
    formatters_by_ft = {
        lua = { "stylua" },
        -- Dart usually formats via LSP, but we can enforce dart_format if installed
        dart = { "dart_format" },
        -- Bash formatting
        sh = { "shfmt" },
        bash = { "shfmt" },
        zsh = { "shfmt" },
    },

    format_on_save = {
        timeout_ms = 500,
        lsp_fallback = true,
    },
}
