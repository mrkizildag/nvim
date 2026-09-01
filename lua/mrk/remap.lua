--convineance
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")


-- telescope.nvim
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Telescope find files" })
vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Telescope live grep" })
vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Telescope buffers" })
vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Telescope help tags" })
-- Symbol search. The file-level picker is aerial's rather than `lsp_document_symbols`:
-- it renders the full symbol path and falls back to treesitter, so it works in buffers
-- with no server attached. Aerial's picker is current-buffer only, so the project-wide
-- one stays on telescope's "dynamic" variant, which re-sends the query to the server on
-- every keystroke instead of filtering a single up-front result set.
vim.keymap.set("n", "<leader>fs", function()
	require("telescope").load_extension("aerial")
	require("telescope").extensions.aerial.aerial()
end, { desc = "Telescope symbols (file)" })
vim.keymap.set("n", "<leader>fS", builtin.lsp_dynamic_workspace_symbols, { desc = "Telescope symbols (project)" })
vim.keymap.set("n", "<leader>/", builtin.current_buffer_fuzzy_find, { desc = "Telescope fuzzy find in buffer" })
vim.keymap.set("n", "<leader>fw", builtin.grep_string, { desc = "Telescope grep word under cursor" })
vim.keymap.set("n", "<leader>fr", builtin.resume, { desc = "Telescope resume last picker" })
vim.keymap.set("n", "<leader>fo", builtin.oldfiles, { desc = "Telescope recent files" })
vim.keymap.set("n", "<leader>fk", builtin.keymaps, { desc = "Telescope keymaps" })
-- Picker of pickers: reaches the other ~45 builtins without binding each one.
vim.keymap.set("n", "<leader>fp", builtin.builtin, { desc = "Telescope all pickers" })

-- yazi.nvim
vim.keymap.set({ "n", "v" }, "<leader>ya", "<cmd>Yazi<cr>", { desc = "Open yazi at the current file" })

-- fugitive.nvim
vim.keymap.set({ "n", "v" }, "<leader>gs", "<cmd>Git<cr>", { desc = "Open Git Panel" })

-- undotree.nvim
vim.keymap.set("n", "<leader>u", vim.cmd.UndotreeToggle, { desc = "Toggle undotree" })

-- formatting
vim.keymap.set({ "n", "v" }, "<leader>F", function()
	require("conform").format({ async = true })
end, { desc = "Format buffer" })

-- LSP keymaps are buffer-local, so register them when a server attaches.
vim.api.nvim_create_autocmd("LspAttach", {
	group = vim.api.nvim_create_augroup("mrk-lsp-keymaps", { clear = true }),
	callback = function(event)
		local map = function(mode, lhs, rhs, desc)
			vim.keymap.set(mode, lhs, rhs, {
				buffer = event.buf,
				desc = desc,
			})
		end

			map("n", "gl", vim.diagnostic.open_float, "Line diagnostics")
			map("n", "[d", function()
				vim.diagnostic.jump({ count = -1, float = true })
			end, "Previous diagnostic")
			map("n", "]d", function()
				vim.diagnostic.jump({ count = 1, float = true })
			end, "Next diagnostic")

		map("n", "gd", vim.lsp.buf.definition, "LSP: Go to definition")
		map("n", "gD", vim.lsp.buf.declaration, "LSP: Go to declaration")
		map("n", "grr", vim.lsp.buf.references, "LSP: Find references")
		map("n", "gri", vim.lsp.buf.implementation, "LSP: Go to implementation")
		map("n", "grn", vim.lsp.buf.rename, "LSP: Rename")
		map({ "n", "x" }, "gra", vim.lsp.buf.code_action, "LSP: Code action")
		map("n", "K", vim.lsp.buf.hover, "LSP: Hover")
	end,
})

-- Run the current file (see lua/mrk/run.lua)
vim.keymap.set("n", "<leader>rf", function()
    require("mrk.run").run()
end, { desc = "Run current file" })

-- Overseer generic task/template picker (previously bound to <leader>rf)
vim.keymap.set("n", "<leader>rt", function()
    vim.cmd("write")
    require("overseer").run_task()
end, {
    desc = "Run overseer task",
})

vim.keymap.set("n", "<leader>rr", function()
    local overseer = require("overseer")
    local tasks = overseer.list_tasks({
        recent_first = true,
    })
    if vim.tbl_isempty(tasks) then
        vim.notify("No previous task", vim.log.levels.WARN)
        return
    end
    tasks[1]:restart()
end, {
    desc = "Restart last task",
})

vim.keymap.set("n", "<leader>ro", "<cmd>OverseerToggle<CR>", {
    desc = "Toggle task list",
})

vim.keymap.set("n", "<leader>ra", "<cmd>OverseerTaskAction<CR>", {
    desc = "Task action",
})
