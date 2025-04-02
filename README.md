# Snipman.nvim

A dead simple snippet manager for neovim.

## Features

- **Small**: around 100 LOC
- **Setupless**: just works no need to call setup
- **Seemless**: design to work out of the box with the `vim.snippet` module

## Usage

> [!NOTE]
> For example of how to write a snippet checkout [this][1] repository 

Expand a snippet under the cursor:
1. Type you specified prefix
2. Press `<Tab>` (the default mapping) to try to expand the snippet

Create a new snippet:
1. Type `:SnipMapEdit`.
2. Select the snippet file you want to open (`all` is for global snippets)
3. Select one and open it.

## Config

The following are the defaults:

```lua
snipman.config({
    -- Full path to where search for snippets
    directory = vim.fs.joinpath(vim.fn.stdpath("config"), "snippets"),
    -- Key used by the keymaping and <Plug> bindings
    expand_key = "<Tab>",
    -- Create default keybinding or not
    default_mappings = true,
})
```

This plugin provides two `<Plug>Mappings`:
- `<Plug>SnipManExpandOrJump`
- `<Plug>SnipManExpand`

[1]: https://github.com/rafamadriz/friendly-snippets/tree/main/snippets
