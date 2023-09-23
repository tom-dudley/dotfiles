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
Plug 'tpope/vim-fugitive'
Plug 'hrsh7th/vim-vsnip'
Plug 'hrsh7th/vim-vsnip-integ'

Plug 'mfussenegger/nvim-dap'
Plug 'rcarriga/nvim-dap-ui'
Plug 'github/copilot.vim'
call plug#end()

" LSP Config
lua << EOF

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

vim.api.nvim_buf_set_keymap(0, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', {noremap=true, silent=true})

EOF

autocmd BufWritePre * lua vim.lsp.buf.format()

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

EOF

set termguicolors       " enable true colors support
set background=dark     " for either mirage or dark version.
let g:ayucolor="dark"   " for dark version of theme

colorscheme ayu
highlight PmenuSel guibg=#5f5f5f guifg=#ffffff

let mapleader = " "
inoremap jk <ESC>
nnoremap <leader>pv :Vex<CR>
nnoremap <leader><CR> :so ~/.config/nvim/init.vim<CR>
nnoremap <C-p> :GFiles<CR> 
nnoremap <leader>pf :Files<CR>
nnoremap <C-j> :cnext<CR> 
nnoremap <C-k> :cprev<CR> 
nnoremap <leader>x :!chmod +x %<CR>

let $FZF_DEFAULT_COMMAND = 'rg --files --no-ignore --hidden --follow --glob "!{.git,node_modules}/*"'
