return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#18120b',
				base01 = '#211b13',
				base02 = '#251f17',
				base03 = '#9f9a92',
				base0B = '#ffe466',
				base04 = '#fff7ee',
				base05 = '#fffbf8',
				base06 = '#fffbf8',
				base07 = '#fffbf8',
				base08 = '#ff9d96',
				base09 = '#ff9d96',
				base0A = '#ffcb88',
				base0C = '#ffe3c0',
				base0D = '#ffcb88',
				base0E = '#ffd49d',
				base0F = '#ffd49d',
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
