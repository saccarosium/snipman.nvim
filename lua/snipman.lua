local M = {}

--- @class snipman.Opts
---
--- Full path to user snippets directory.
--- (default: `stdpath('config') + "config")
--- @field directory string
---
--- Key used for expand a snippet under the cursor (see [key-codes]())
--- (default: `<Tab>`)
--- @field expand_key string
---
--- Define default mappings (default: `true`)
--- @field default_mappings boolean
local Config = {
    directory = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets"),
    expand_key = "<Tab>",
    default_mappings = true,
}

--- @param path string
--- @return string will panic in case of an error
local function file_read(path)
    local err_msg = "Failed to %s '" .. path .. "'"
    local file = assert(vim.uv.fs_open(path, "r", 0x1A4), err_msg:format("open"))
    local stat = assert(vim.uv.fs_stat(path), err_msg:format("get stats for"))
    local data = assert(vim.uv.fs_read(file, stat.size, 0), err_msg:format("read"))
    assert(vim.uv.fs_close(file), err_msg:format("close"))
    return data
end

--- @class snipman.Word
--- @field content string
--- @field row integer
--- @field start_col integer
--- @field end_col integer
---
--- @return snipman.Word?
local function get_word_under_cursor()
    local line = vim.api.nvim_get_current_line()
    local cursor = vim.api.nvim_win_get_cursor(0)
    local row, cursor_col = cursor[1] - 1, cursor[2]
    local start_col = 0

    for i = cursor_col, 1, -1 do
        if line:sub(i, i):match("%s") then
            break
        end
        start_col = i - 1
    end

    local word = vim.api.nvim_buf_get_text(0, row, start_col, row, cursor_col, {})[1]
    if word == "" then
        return
    end

    return {
        content = word,
        row = row,
        start_col = start_col,
        end_col = cursor_col,
    }
end

--- @param filetype string
--- @param prefix string
--- @return string?
local function get_snippet(filetype, prefix)
    for _, name in ipairs({ "all", filetype }) do
        local path = vim.fs.joinpath(Config.directory, name .. ".json")
        if vim.uv.fs_stat(path) then
            local content = file_read(path)
            local ok, snippets = pcall(vim.json.decode, content)
            if not ok then
                vim.notify(
                    "Snipman: Failed to parse snippet file for " .. name,
                    vim.log.levels.ERROR
                )
                return
            end

            for _, snippet in pairs(snippets) do
                if snippet.prefix == prefix then
                    return table.concat(snippet.body, "\n")
                end
            end
        end
    end
end

--- @param opts snipman.Opts?
--- @reutrn opts.snipman.Opts?
function M.config(opts)
    vim.validate("opts", opts, "table", true)

    if not opts then
        return vim.deepcopy(Config, true)
    end

    for k, v in pairs(opts) do
        Config[k] = v
    end
end

function M.is_over_prefix()
    --- @type snipman.Word
    local word = get_word_under_cursor()
    if not word then
        return false
    end
    local snippet = get_snippet(vim.o.filetype, word.content)
    return snippet ~= nil
end

--- @param filetype string?
function M.edit(filetype)
    vim.validate("filetype", filetype, "string", true)
    filetype = filetype or vim.o.filetype

    local path = vim.fs.joinpath(Config.directory, filetype .. ".json")
    vim.cmd.vsplit(vim.fn.fnameescape(path))
end

function M.expand_under_cursor()
    local word = get_word_under_cursor()
    local snippet = get_snippet(vim.o.filetype, word.content)
    if not snippet then
        return
    end

    vim.api.nvim_buf_set_text(0, word.row, word.start_col, word.row, word.end_col, { "" })
    vim.snippet.expand(snippet)
end

return M
