require "paq" {
    "savq/paq-nvim";                  -- Let Paq manage itself

    "neovim/nvim-lspconfig";          -- Mind the semi-colons

    "hrsh7th/nvim-cmp";

    "hrsh7th/cmp-nvim-lsp";

    "saadparwaiz1/cmp_luasnip";

    "L3MON4D3/LuaSnip";

    {"nvim-treesitter/nvim-treesitter", run=function() vim.cmd "TSUpdate" end};

    "nvim-lua/plenary.nvim";

    "Shatur/neovim-tasks";

    "nvim-tree/nvim-tree.lua";

    "williamboman/mason.nvim";

    "williamboman/mason-lspconfig.nvim";

    "mfussenegger/nvim-dap";
}

local g = vim.g
g.loaded_netrw = 1
g.loaded_netrwPlugin = 1
local set = vim.opt
set.tabstop = 4
set.softtabstop = 4
set.shiftwidth = 4
set.expandtab = true
set.number = true
set.termguicolors = true
set.list = true
set.listchars = "tab:> "

vim.api.nvim_exec(
[[
colorscheme PaperColor
autocmd ColorScheme * highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()
]],
    true)

require("nvim-tree").setup()

-- Mappings.
-- See `:help vim.diagnostic.*` for documentation on any of the below functions
local km = vim.keymap
local opts = { noremap=true, silent=true }
km.set('n', 'R', '<Cmd>redo<CR>', opts)
km.set('n', 'C-B', '<Cmd>Task start cmake build<CR>', opts)
km.set('n', '<space>e', vim.diagnostic.open_float, opts)
km.set('n', '[d', vim.diagnostic.goto_prev, opts)
km.set('n', ']d', vim.diagnostic.goto_next, opts)
km.set('n', '<space>q', vim.diagnostic.setloclist, opts)
km.set('n', '<F5>', '<Cmd>Task start cmake run<CR>', opts)
km.set('n', '<F7>', '<Cmd>sp<CR>', opts)
km.set('n', '<F8>', '<Cmd>vsp<CR>', opts)
km.set('n', '<F10>', '<Cmd>NvimTreeToggle<CR>', opts)

-- Use an on_attach function to only map the following keys
-- after the language server attaches to the current buffer
local on_attach = function(client, bufnr)
  -- Enable completion triggered by <c-x><c-o>
  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings.
  -- See `:help vim.lsp.*` for documentation on any of the below functions
  local bufopts = { noremap=true, silent=true, buffer=bufnr }
  km.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
  km.set('n', 'gd', vim.lsp.buf.definition, bufopts)
  km.set('n', 'K', vim.lsp.buf.hover, bufopts)
  km.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
  km.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
  km.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
  km.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
  km.set('n', '<space>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, bufopts)
  km.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
  km.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
  km.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
  km.set('n', 'gr', vim.lsp.buf.references, bufopts)
  km.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
end

local lsp_flags = {
  -- This is the default in Nvim 0.7+
  debounce_text_changes = 150,
}

local capabilities = require("cmp_nvim_lsp").default_capabilities()

require("mason").setup {
    providers = {
        "mason.providers.client",
        "mason.providers.registry-api",
    }
}
require("mason-lspconfig").setup()

local lspconfig = require('lspconfig')

-- Enable some language servers with the additional completion capabilities offered by nvim-cmp
local servers = { 'asm_lsp', 'clangd', 'cmake', 'pyright' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    -- on_attach = my_custom_on_attach,
    capabilities = capabilities,
  }
end

-- luasnip setup
local luasnip = require 'luasnip'

-- nvim-cmp setup
local cmp = require 'cmp'
cmp.setup {
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-u>'] = cmp.mapping.scroll_docs(-4),
    ['<C-d>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
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

vim.api.nvim_exec(
    [[
NvimTreeOpen
NvimTreeFindFile 
    ]],
    true)

