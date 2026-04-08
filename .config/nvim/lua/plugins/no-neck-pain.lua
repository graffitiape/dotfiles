return {
	"shortcuts/no-neck-pain.nvim",
	version = "*",
	config = function()
		require("no-neck-pain").setup()
		vim.keymap.set("n", "<C-d>", "<ScrollWheelDown>", {})
		vim.keymap.set("n", "<C-u>", "<ScrollWheelUp>", {})
	end,
}
