local snipman = require("snipman")
local Config = snipman.config()

vim.keymap.set({ "i", "s" }, "<Plug>SnipManExpandOrJump", function()
    if snipman.is_over_prefix() then
        return "<Cmd>lua require'snipman'.expand_under_cursor()<CR>"
    elseif vim.snippet.active({ direction = 1 }) then
        return "<Cmd>lua vim.snippet.jump(1)<CR>"
    else
        return Config.expand_key
    end
end, { expr = true, silent = true })

vim.keymap.set({ "i", "s" }, "<Plug>SnipManExpand", function()
    if snipman.is_over_prefix() then
        return "<Cmd>lua require'snipman'.expand_under_cursor()<CR>"
    else
        return Config.expand_key
    end
end, { expr = true, silent = true })

if Config.default_mappings then
    vim.keymap.set({ "i", "s" }, Config.expand_key, "<Plug>SnipManExpandOrJump")
end

vim.api.nvim_create_user_command("SnipManEdit", function(a)
    local filetypes = vim.split(vim.o.filetype, ".", { plain = true, trimempty = true })
    local items = vim.list_extend({ "all" }, filetypes)

    if a.bang and #filetypes == 1 then
        snipman.edit(vim.o.filetype)
        return
    end

    vim.ui.select(items, {
        prompt = "Select type: ",
    }, function(choice)
        if vim.fn.empty(choice) == 1 then
            return
        end
        snipman.edit(choice)
    end)
end, { nargs = 0, bang = true })
