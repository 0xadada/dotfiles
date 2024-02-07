local vimrc = vim.fn.stdpath("config") .. "/init.legacy.vim"
vim.cmd.source(vimrc)

-- boot Plug
local vim = vim
local Plug = vim.fn['plug#']
vim.call('plug#begin')
-- load Plugs
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
-- code formatting/highlighting
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
Plug('prettier/vim-prettier', { ['ft'] = {'javascript', 'typescript', 'html', 'css', 'scss', 'json', 'graphql', 'markdown', 'yaml'} })
vim.call('plug#end')

-- Gruvbox color palette
vim.o.background = "dark"
vim.cmd.colorscheme("gruvbox")

-- Add additional capabilities supported by nvim-cmp
local capabilities = require("cmp_nvim_lsp").default_capabilities()

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'tsserver' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end

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
  -- format on save
  if client.server_capabilities.documentFormattingProvider then
    vim.api.nvim_create_autocmd("BufWritePre", {
      group = vim.api.nvim_create_augroup("Format", { clear = true }),
      buffer = bufnr,
      callback = function() vim.lsp.buf.format() end
    })
  end
  -- disable inline diagnostics
  vim.diagnostic.config({ virtual_text = false })
  -- Show line diagnostics automatically in hover window
  vim.o.updatetime = 250
  vim.cmd [[autocmd CursorHold,CursorHoldI * lua vim.diagnostic.open_float(nil, {focus=false})]]
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

-- vim/prettier setup
vim.g['prettier#autoformat'] = 1
vim.g['prettier#autoformat_require_pragma'] = 0

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

-- TypeScript/Javascript https://www.andersevenrud.net/neovim.github.io/lsp/configurations/tsserver/
lspconfig['tsserver'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

-- HTML https://www.andersevenrud.net/neovim.github.io/lsp/configurations/html/
lspconfig['html'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

-- CSS/LESS/SASS https://www.andersevenrud.net/neovim.github.io/lsp/configurations/cssls/
lspconfig['cssls'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

-- TailwindCSS https://www.andersevenrud.net/neovim.github.io/lsp/configurations/tailwindcss/
lspconfig['tailwindcss'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

lspconfig['eslint'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

-- GraphQL https://www.andersevenrud.net/neovim.github.io/lsp/configurations/graphql/
lspconfig['graphql'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

-- JSON https://www.andersevenrud.net/neovim.github.io/lsp/configurations/jsonls/
lspconfig['jsonls'].setup{
  on_attach = on_attach,
  flags = lsp_flags,
}

if vim.fn.executable('volta') then
  vim.g.node_host_prog = vim.trim(vim.fn.system('volta which neovim-node-host | tr -d "\n"'))
end
