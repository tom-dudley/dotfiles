set guicursor=
set scrolloff=8
set number
set relativenumber
set tabstop=4 softtabstop=4
set shiftwidth=4
set expandtab
set smartindent
syntax on

call plug#begin()
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'Luxed/ayu-vim'    " or other package manager
Plug 'neovim/nvim-lspconfig'
Plug 'nvim-lualine/lualine.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'hrsh7th/nvim-cmp'
Plug 'hrsh7th/cmp-nvim-lsp'
Plug 'hrsh7th/cmp-buffer'
Plug 'hrsh7th/cmp-nvim-lsp-signature-help'
Plug 'jiangmiao/auto-pairs'
Plug 'fatih/vim-go'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'
Plug 'williamboman/mason.nvim'
Plug 'williamboman/mason-lspconfig.nvim'

Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'github/copilot.vim'

Plug 'nvim-lua/plenary.nvim'
Plug 'ThePrimeagen/harpoon', { 'branch': 'harpoon2', 'requires': ['nvim-lua/plenary.nvim'] }
Plug 'joerdav/templ.vim'
call plug#end()


" LSP Config
lua << EOF
require("mason").setup()
require("mason-lspconfig").setup()

local cmp = require'cmp'
cmp.setup({
  snippet = {
    expand = function(args)
      vim.fn["vsnip#anonymous"](args.body)
    end,
  },
  mapping = {
      ['<C-j>'] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<C-k>'] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
      ['<Tab>'] = cmp.mapping(function(fallback)
          if cmp.visible() then
              cmp.confirm({ select = true })
          else
              fallback()
          end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
        if cmp.visible() then
            cmp.select_prev_item()
        else
            fallback()
        end
    end, { 'i', 's' }),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
  },
  sources = {
    { name = 'nvim_lsp' },
    { name = 'vsnip' },
    { name = 'buffer' },
    { name = 'nvim_lsp_signature_help' },
  }
})

local capabilities = require('cmp_nvim_lsp').default_capabilities()

-- https://github.com/BrotifyPacha/nvim/blob/b12fe7e5b52dcee3b3d3e78d031cb01d862a3785/lua/lsp/init.lua#L28-L29
local function on_attach(client, bufnr)
    -- Set up buffer-local keymaps (vim.api.nvim_buf_set_keymap()), etc.
    local opts = { noremap = true, silent = true }
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gD", "<cmd>lua vim.lsp.buf.declaration()<CR>", opts)
    vim.api.nvim_buf_set_keymap(bufnr, "n", "gd", "<cmd>lua vim.lsp.buf.definition()<CR>", opts)
end

lspconfig = require("lspconfig")
lspconfig.gopls.setup({
    capabilities = capabilities,
    settings = {
        gopls = {
            gofumpt = true
        },
    },
    init_options = {
        usePlaceholders = false,
        completeUnimported = true,
    }
})

lspconfig.htmx.setup{}
lspconfig.tsserver.setup{
    on_attach = on_attach,
    root_dir = lspconfig.util.root_pattern("package.json", "tsconfig.json", ".git")
}
lspconfig.html.setup{}

lspconfig.templ.setup({
    on_attach = on_attach,
    flags = {
      debounce_text_changes = 150,
    },
})

require("lspconfig").tailwindcss.setup({
  filetypes = {
    'templ'
    -- include any other filetypes where you need tailwindcss
  },
  init_options = {
    userLanguages = {
        templ = "html"
    }
  }
})

-- https://stackoverflow.com/a/74584098
-- https://github.com/BrotifyPacha/nvim/blob/b12fe7e5b52dcee3b3d3e78d031cb01d862a3785/lua/lsp/init.lua#L28-L29
vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap=true, silent=true})
vim.api.nvim_buf_set_keymap(0, 'n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', {noremap=true, silent=true})
vim.api.nvim_buf_set_keymap(0, 'n', '<leader>s', '<cmd>lua vim.lsp.buf.signature_help()<CR>', {noremap=true, silent=true})

vim.g.copilot_assume_mapped = true

EOF

imap <silent><script><expr> <C-Y> copilot#Accept("\<CR>")
let g:copilot_no_tab_map = v:true

autocmd BufWritePre * lua vim.lsp.buf.format()

let mapleader = " "

lua <<EOF

require("lualine").setup {
    options = {
        icons_enabled = true,
        theme = 'auto',
    },
    sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch'},
        lualine_c = {
            {
                'filename'
            }, 
            {
                'diagnostics',
                sources = { 'nvim_lsp' },
                sections = {'error', 'warn', 'info', 'hint'},
                diagnostics_color = {
                    error = 'DiagnosticError',
                    warn = 'DiagnosticWarn',
                    info = 'DiagnosticInfo',
                    hint = 'DiagnosticHint',
                },
                symbols = {error = 'E', warn = 'W', info = 'E', hint = 'H'},
                colored = true,
                update_in_insert = true,
                always_visible = true,
            },
        },
        lualine_x = {'encoding', 'fileformat'},
        lualine_y = {'progress'},
        lualine_z = {'location'},        
    },
}

local harpoon = require("harpoon")

-- REQUIRED
harpoon:setup()
-- REQUIRED

vim.keymap.set("n", "<leader>a", function() harpoon:list():append() end)
vim.keymap.set("n", "<C-e>", function() harpoon.ui:toggle_quick_menu(harpoon:list()) end)

vim.keymap.set("n", "<C-j>", function() harpoon:list():select(1) end)
vim.keymap.set("n", "<C-k>", function() harpoon:list():select(2) end)
vim.keymap.set("n", "<C-l>", function() harpoon:list():select(3) end)
vim.keymap.set("n", "<C-;>", function() harpoon:list():select(4) end)

-- local harpoon_group = vim.api.nvim_create_augroup("HarpoonKeymaps", { clear = true })

-- vim.api.nvim_create_autocmd("FileType", {
--    pattern = "harpoon",
--    group = harpoon_group,
--    callback = function()
--        vim.keymap.set("n", "<C-j>", function() harpoon:list():next() end, { silent = true, noremap = true, buffer = true })
--        vim.keymap.set("n", "<C-k>", function() harpoon:list():prev() end, { silent = true, noremap = true, buffer = true })
--        vim.keymap.set("n", "jk", function() harpoon.ui:close_menu() end, { silent = true, noremap = true, buffer = true })
--    end,
-- })

EOF
" Note that this will add delay to navigation, also breaks up/down
" autocmd FileType harpoon nnoremap <buffer> jk :q<CR>

set termguicolors       " enable true colors support
set background=dark     " for either mirage or dark version.
let g:ayucolor="dark"   " for dark version of theme

colorscheme ayu
highlight PmenuSel guibg=#5f5f5f guifg=#ffffff
highlight Visual guibg=#5f5f5f guifg=#ffffff


inoremap jk <ESC>
nnoremap <leader>pv :Vex<CR>
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <C-p> :GFiles<CR> 
nnoremap <leader>pf :Files<CR>
nnoremap <C-j> :cnext<CR> 
nnoremap <C-k> :cprev<CR> 
nnoremap <leader>x :!chmod +x %<CR>

vnoremap J :m '>+1<CR>gv=gv
vnoremap K :m '<-2<CR>gv=gv

let $FZF_DEFAULT_COMMAND = 'rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules}/*"'

nnoremap <leader>ee oif err != nil {<CR>}<Esc>Oreturn err<Esc>
