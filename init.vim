set hidden
set shiftwidth=0
set softtabstop=0
set tabstop=2
set expandtab
set number
set mouse=a
set gdefault
set undodir=$HOME/.vim_undo
set undofile
set autoread
set directory=$HOME/.vim_swap
set swapfile
set shiftround
set cursorline
set conceallevel=2
set relativenumber
set scrolloff=5
set signcolumn=yes
set ignorecase
set smartcase

set wildignore+=*.exe
set wildignore+=*.gz
set wildignore+=*.jpg
set wildignore+=*.o
set wildignore+=*.pdf
set wildignore+=*.png
set wildignore+=*.pyc
set wildignore+=*/__pycache__/*
set wildignore+=Thumbs.db
set wildignore+=desktop.ini

set completeopt+=menuone
set completeopt+=noselect

call plug#begin()

Plug 'tpope/vim-surround'
Plug 'jiangmiao/auto-pairs'

Plug 'prabirshrestha/asyncomplete.vim'
Plug 'prabirshrestha/async.vim'
Plug 'prabirshrestha/vim-lsp'
Plug 'prabirshrestha/asyncomplete-lsp.vim'
Plug 'junegunn/fzf'
Plug 'pangloss/vim-javascript'
Plug 'tomasiser/vim-code-dark'
Plug 'airblade/vim-gitgutter'
Plug 'jremmen/vim-ripgrep'
Plug 'scrooloose/nerdtree'
Plug 'tpope/vim-commentary'
Plug 'maxmellon/vim-jsx-pretty'


call plug#end()

" close
nnoremap <silent> Q :<C-u>qa<CR>

" buffer
nnoremap <silent> H :<C-u>bp<CR>
nnoremap <silent> L :<C-u>bn<CR>

nnoremap <silent> <BS> :<C-u>nohl<CR>
nnoremap <silent>        U       :<C-U>call search('\u')<CR>
onoremap <silent>        U       :<C-U>call search('\u')<CR>


" lsp config
let g:lsp_log_verbose = 1
let g:lsp_log_file = expand('~/vim-lsp.log')
let g:lsp_highlight_references_enabled = 1


" lsp servers
if executable('pyls')
  " pip install python-language-server
  au User lsp_setup call lsp#register_server({
        \ 'name': 'pyls',
        \ 'cmd': {server_info->['pyls']},
        \ 'whitelist': ['python'],
        \ })
endif

if executable('typescript-language-server')
  au User lsp_setup call lsp#register_server({
        \ 'name': 'javascript support using typescript-language-server',
        \ 'cmd': {server_info->[&shell, &shellcmdflag, 'typescript-language-server --stdio']},
        \ 'root_uri':{server_info->lsp#utils#path_to_uri(lsp#utils#find_nearest_parent_file_directory(lsp#utils#get_buffer_path(), 'package.json'))},
        \ 'whitelist': ['javascript', 'javascript.jsx', 'javascriptreact'],
        \ })
endif


" completion
inoremap <expr> <Tab>   pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
inoremap <expr> <cr>    pumvisible() ? "\<C-y>" : "\<cr>"
imap <c-space> <Plug>(asyncomplete_force_refresh)


" fuzzy search
nnoremap <silent> <c-p> :<C-u>FZF<CR>

" jump
nnoremap <silent> gd :LspDefinition<CR>

" theme
colo codedark


" netrw
let g:netrw_banner=0
let g:netrw_liststyle=3
let g:netrw_browse_split = 4
let g:netrw_winsize = 20
augroup ProjectDrawer
  autocmd!
  " autocmd VimEnter * Vexplore | exe "normal! \<C-w>\<C-w>"
  au VimEnter * NERDTree | exe "normal! \<C-w>\<C-w>"
augroup END


" delete buffer
function! BufferDelete(force)
  if !a:force && &modified
    echohl ErrorMsg
    echo 'Unsaved changes, aborted'
    echohl None
    return
  endif

  let l:buf = bufnr()
  bnext
  exec 'bdelete!' l:buf
endfunction

nnoremap <silent> - :<C-u>call BufferDelete(0)<CR>
nnoremap <silent> _ :<C-u>call BufferDelete(1)<CR>


" save
function! Write() " {{{
    if &buftype == ''
        return ":\<C-U>update\<CR>"
    endif

    return "\<CR>"
endfunction " }}}
nnoremap <silent> <expr> <CR> Write()


" tabline

function! SwitchBuffer(id, clicks, buttons, mods) " {{{
    exec 'buffer ' . a:id
endfunction " }}}

function! BufName(nr) " {{{
    let name = bufname(a:nr)

    let name = fnamemodify(name, ':t')

    if name == ''
        let name = '[No Name]'
    endif

    return name
endfunction " }}}

function! TabInfo() " {{{
    return 'Hello World'
endfunction " }}}

function! TabLine() " {{{
    let line = '%#StatusLine#'

    " if there are more than 1 tab
    if tabpagenr('$') > 1
        let line .= ' tab '

        " for each tab
        for i in range(1, tabpagenr('$'))
            let line .= i == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#'
            let line .= '%' . i . 'T '

            let buflist = tabpagebuflist(i)
            let winnr = tabpagewinnr(i)

            let mod = ''

            if len(buflist) > 1
                " number of buffers in tab
                let mod .= string(len(buflist))
            endif

            for buf in buflist
                " add '+' if modified
                if getbufvar(buf, '&modified')
                    let mod .= '+'
                    break
                endif
            endfor

            if mod != ''
                let line .= mod . ' '
            endif

            let line .= '%{BufName(' . buflist[winnr - 1] . ')}'

            let line .= ' '
        endfor
    else
        let line .= ' buf '

        for i in range(1, bufnr('$'))
            if !buflisted(i)
                continue
            endif

            let line .= i == bufnr('%') ? '%#TabLineSel# ' : '%#TabLine# '
            if has('tablineat')
                let line .= '%' . i . '@SwitchBuffer@'
            endif

            if getbufvar(i, '&modified')
                let line .= '+ '
            endif

            let line .= '%{BufName(' . i . ')}'

            let line .= ' '
        endfor
    endif

    let line .= '%#TabLineFill#%T%=%#StatusLine#%( '
    let line .= TabInfo()
    let line .= ' %)'

    return line
endfunction " }}}

set showtabline=2
set tabline=%!TabLine()


" Grep for word under cursor
nnoremap K :grep! "\b<C-R><C-W>\b"<CR>:cw<CR>

" use ag for vim grep
if executable('ag')
  " Use ag over grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag for FZF
  let $FZF_DEFAULT_COMMAND = 'ag -g ""'

  " Using Ag for global grep
  command -nargs=+ -complete=file -bar Ag silent! grep! <args>|cwindow|redraw!

  nnoremap ? :Ag<SPACE>

  " Use ag in CtrlP for listing files. Lightning fast and respects .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

