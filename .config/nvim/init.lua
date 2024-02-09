local vim = vim
-- boot Plug
local Plug = vim.fn['plug#']
vim.call('plug#begin')
-- mason.nvm: installs and manages LSP & tools (outside of Plug)
Plug('williamboman/mason.nvim')
Plug('williamboman/mason-lspconfig.nvim')
-- UI
Plug('morhetz/gruvbox')
Plug('vim-airline/vim-airline')
-- features
Plug('tpope/vim-fugitive')
Plug('airblade/vim-gitgutter')
Plug('scrooloose/nerdtree')
-- LSP
Plug('neovim/nvim-lspconfig')
Plug('hrsh7th/nvim-cmp') -- Autocompletion plugin
Plug('hrsh7th/cmp-nvim-lsp') -- LSP source for nvim-cmp
-- code highlighting
Plug('slashmili/alchemist.vim') -- Elixir Integration
Plug('HerringtonDarkholme/yats.vim') -- .tsx syntax highlighting
Plug('MaxMEllon/vim-jsx-pretty') -- .jsx syntax highlighting
Plug('editorconfig/editorconfig-vim')
Plug('hail2u/vim-css3-syntax')
Plug('elzr/vim-json')
Plug('elixir-lang/vim-elixir')
Plug('mhinz/vim-mix-format')
Plug('jparise/vim-graphql')
Plug('mustache/vim-mustache-handlebars')
Plug('vim-pandoc/vim-pandoc-syntax')
-- code formatting
Plug('stevearc/conform.nvim')
Plug('mfussenegger/nvim-lint')
vim.call('plug#end')

-- vim options
vim.opt.ruler = true -- show the cursor position
vim.opt.selection = "exclusive" -- visual mode selection to exlusive (rather than inclusive)
vim.opt.clipboard = "unnamed" -- Use the OS clipboard by default (on versions compiled with `+clipboard`)
vim.opt.wildmenu = true -- Enhance command-line completion
vim.opt.backspace = "indent,eol,start" -- Allow backspace in insert mode
vim.opt.ttyfast = true -- optimize for fast terminal connections
vim.opt.gdefault = true -- Add the g flag to search/replace by default
vim.opt.encoding = "utf-8" -- use UTF-8
vim.opt.binary = true -- don't add empty newlines at the end of files
vim.opt.modeline = true -- Respect modeline in files
vim.opt.modelines = 4
vim.opt.exrc = true -- enable per-directory .vimrc files and disable unsafe commands in them
vim.opt.secure = true
vim.opt.number = true -- enable line numbers
vim.opt.tabstop = 4 -- tabs as wide as four spaces
vim.opt.shiftwidth = 4 -- make shift indent operation add four spaces
vim.opt.expandtab = true -- convert tabs to spaces upon tabpress
vim.opt.list = true
vim.opt.hlsearch = true -- highlight searches
vim.opt.incsearch = true -- highlight dynamically as pattern is typed
vim.opt.laststatus = 2 -- always show status line
vim.opt.mouse = "a" -- enable mouse in all modes
vim.opt.shortmess = "atI" -- don’t show the intro message when starting vim
vim.opt.showmode = true -- show the current mode
vim.opt.title = true -- show the filename in the window titlebar
vim.opt.showcmd = true -- show the (partial) command as it’s being typed
vim.opt.scrolloff = 4 -- start scrolling three lines before the horizontal window border
vim.opt.foldmethod = "indent" -- code folding
vim.opt.foldnestmax = 10
vim.opt.foldlevel = 2

vim.o.lcs = [[leadmultispace:∙,tab:▸\ ,trail:·,eol:↲,nbsp:_]] -- :help litchars

vim.g.mapleader = "," -- Change mapleader from "\" (default) to comma

vim.cmd.syntax("on") -- enable syntax highlighting
vim.cmd.filetype("plugin indent on") --enable plugins
-- legacy shit
vim.cmd("set noeol nofoldenable nocursorline noerrorbells nostartofline")
vim.cmd("let &colorcolumn=join(range(120,666),',')") -- highlight at column 121

-- mason.nvim
require("mason").setup()
require('mason-lspconfig').setup({
  ensure_installed = {
    "bashls",
    "cssls",
    "cssmodules_ls",
    "ember",
    "elixirls",
    "graphql",
    "html",
    "jsonls",
    "tailwindcss",
    "tsserver",
    "vimls",
    "yamlls",
  },
  automatic_installation = true, -- auto-install with lspconfig
})

-- conform.nvim for auto code formatting
local conform = require('conform')
local conformFormatOpts = {
  async = false,
  lsp_fallback = true,
  timeout_ms = 500,
}
conform.setup({
  formatters_by_ft = {
    javascript = { "prettier" },
    typescript = { "prettier" },
    javascriptreact = { "prettier" },
    typescriptreact = { "prettier" },
    css = { "prettier" },
    html = { "prettier" },
    json = { "prettier" },
    yaml = { "prettier" },
    markdown = { "prettier" },
    graphql = { "prettier" },
  },
  format_on_save = conformFormatOpts,
})
vim.keymap.set({"n", "v"}, "<leader>mp", function() -- enable formatting on ',mp' keymap
  conform.format(conformFormatOpts)
end, {desc = "Format file or range (in visual mode)"})

-- nvim-lint
local lint = require("lint")
lint.linters_by_ft = {
  javascript = { "eslint_d", },
  typescript = { "eslint_d" },
  javascriptreact = { "eslint_d" },
  typescriptreact = { "eslint_d" },
  css = { "eslint_d" },
  html = { "eslint_d" },
  json = { "eslint_d" },
  yaml = { "eslint_d" },
  markdown = { "eslint_d" },
  graphql = { "eslint_d" },
}
local lint_augroup = vim.api.nvim_create_augroup("lint", { clear = true })
vim.api.nvim_create_autocmd({ "BufEnter", "BufWritePost", "InsertLeave" }, {
  group = lint_augroup,
  callback = function()
    lint.try_lint()
  end
})
vim.keymap.set({"n"}, "<leader>l", function() -- enable linting on ',l' keymap
  lint.try_lint()
end, {desc = "Lint file"})

-- Gruvbox color palette
vim.cmd.colorscheme("gruvbox")
vim.o.background = "dark"

-- vim-airline
vim.opt.guifont = "Source Code Pro for Powerline:h12"
vim.g["airline_detect_paste"] = 1 -- enable paste detection
vim.g["airline_powerline_fonts"] = 1
vim.g["airline#extensions#branch#enabled"] = 1 -- vim-airline enable branch "fugitive" extension
vim.g["airline#extensions#branch#empty_message"] = ''
vim.g["airline#extensions#branch#displayed_head_limit"] = 10

-- HerringtonDarkholme/yats.vim
vim.g["yats_host_keyword"] = 1 -- yats should handle specfic keywords

-- MaxMEllon/vim-jsx-pretty
vim.g["vim_jsx_pretty_disable_tsx"] = 1 -- let yats handle .tsx

-- NERDTree
vim.g["NERDTreeIgnore"] = { "^dist$", "^node_modules$" }

-- vim-mix-format set to run Elixir formatter upon save
vim.g["mix_format_on_save"] = 1

local opts = { noremap=true, silent=true }
vim.keymap.set('n', '<space>e', vim.diagnostic.open_float, opts)
vim.keymap.set('n', '[d', vim.diagnostic.goto_prev, opts)
vim.keymap.set('n', ']d', vim.diagnostic.goto_next, opts)
vim.keymap.set('n', '<space>q', vim.diagnostic.setloclist, opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')
  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
  vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
  vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
  client.server_capabilities.semanticTokensProvider = nil -- disable syntax highlighting (let other package do that)
  -- disable inline diagnostics
  vim.diagnostic.config({ virtual_text = false })
  -- Show line diagnostics automatically in hover window
  vim.o.updatetime = 250
  vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
end
local lspconfig = require('lspconfig')
-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()
local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}
local servers = {
  'cssls',
  'html',
  'tailwindcss',
  'graphql',
  'jsonls',
  'tsserver'
}
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    on_attach = on_attach,
    flags = lsp_flags,
    capabilities = capabilities,
  }
end

-- nvim-cmp setup
local cmp = require('cmp')
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4), -- Up
    ['<C-d>'] = cmp.mapping.scroll_docs(4), -- Down
    -- C-b (back) C-f (forward) for snippet placeholder navigation.
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  },
}

if vim.fn.executable('volta') then
  vim.g.node_host_prog = vim.trim(vim.fn.system('volta which neovim-node-host | tr -d "\n"'))
end
