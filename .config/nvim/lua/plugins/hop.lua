return {
	"smoka7/hop.nvim",
	version = "*",
	opts = {},
	config = function()
		require("hop").setup()
		vim.keymap.set("n", "<C-k>", ":HopWord<CR>", {})
		vim.keymap.set("n", "<C-j>", ":HopLine<CR>", {})
	end,
}
