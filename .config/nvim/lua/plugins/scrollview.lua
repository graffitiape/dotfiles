return {
	"dstein64/nvim-scrollview",
	config = function()
		require("scrollview").setup({
			current_only = true,
			signs_on_startup = { "all" },
		})
	end,
}
