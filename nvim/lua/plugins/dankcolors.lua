return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({
				base00 = '#18120b',
				base01 = '#18120b',
				base02 = '#9f9a92',
				base03 = '#9f9a92',
				base04 = '#fff7ee',
				base05 = '#fffbf8',
				base06 = '#fffbf8',
				base07 = '#fffbf8',
				base08 = '#ff9d96',
				base09 = '#ff9d96',
				base0A = '#ffcb88',
				base0B = '#adff9d',
				base0C = '#ffe3c0',
				base0D = '#ffcb88',
				base0E = '#ffd49d',
				base0F = '#ffd49d',
			})

			vim.api.nvim_set_hl(0, 'Visual', {
				bg = '#9f9a92',
				fg = '#fffbf8',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Statusline', {
				bg = '#ffcb88',
				fg = '#18120b',
			})
			vim.api.nvim_set_hl(0, 'LineNr', { fg = '#9f9a92' })
			vim.api.nvim_set_hl(0, 'CursorLineNr', { fg = '#ffe3c0', bold = true })

			vim.api.nvim_set_hl(0, 'Statement', {
				fg = '#ffd49d',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Keyword', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Repeat', { link = 'Statement' })
			vim.api.nvim_set_hl(0, 'Conditional', { link = 'Statement' })

			vim.api.nvim_set_hl(0, 'Function', {
				fg = '#ffcb88',
				bold = true
			})
			vim.api.nvim_set_hl(0, 'Macro', {
				fg = '#ffcb88',
				italic = true
			})
			vim.api.nvim_set_hl(0, '@function.macro', { link = 'Macro' })

			vim.api.nvim_set_hl(0, 'Type', {
				fg = '#ffe3c0',
				bold = true,
				italic = true
			})
			vim.api.nvim_set_hl(0, 'Structure', { link = 'Type' })

			vim.api.nvim_set_hl(0, 'String', {
				fg = '#adff9d',
				italic = true
			})

			vim.api.nvim_set_hl(0, 'Operator', { fg = '#fff7ee' })
			vim.api.nvim_set_hl(0, 'Delimiter', { fg = '#fff7ee' })
			vim.api.nvim_set_hl(0, '@punctuation.bracket', { link = 'Delimiter' })
			vim.api.nvim_set_hl(0, '@punctuation.delimiter', { link = 'Delimiter' })

			vim.api.nvim_set_hl(0, 'Comment', {
				fg = '#9f9a92',
				italic = true
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
