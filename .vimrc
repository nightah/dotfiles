"           ██                           
"          ░░                            
"  ██    ██ ██ ██████████  ██████  █████ 
" ░██   ░██░██░░██░░██░░██░░██░░█ ██░░░██
" ░░██ ░██ ░██ ░██ ░██ ░██ ░██ ░ ░██  ░░ 
"  ░░████  ░██ ░██ ░██ ░██ ░██   ░██   ██
"   ░░██   ░██ ███ ░██ ░██░███   ░░█████ 
"    ░░    ░░ ░░░  ░░  ░░ ░░░     ░░░░░ 
" Have fun!

if $TERM != "linux"              " if we are not in TTY
   set t_Co=256                  " set 256 colors.
endif

" common settings
syntax on
filetype on
filetype plugin on
filetype plugin indent on

colorscheme barrage		 " modified from slate/colorshot
"set completeopt-=preview        " disable scratch buffer
set cursorline                   " enable cursor highlight
set showcmd                      " show command information
set foldmethod=marker            " allow marking folds
set showmatch                    " hilight search pattern
set incsearch                    " incremental search
set scrolloff=1                  " 1 line offset from top-bottom
set sidescrolloff=5              " 5 character offset from left-right
set nowrap                       " don't wrap lines
set virtualedit=all              " enable virtualedit (visual block)
set expandtab                    " spaces not tabs
set softtabstop=2                " indents
set shiftwidth=2                 " more indents
set number                       " show line numbers
set noswapfile                   " no swap files
set updatecount=0                " we don't use swap files
set ignorecase                   " ignore case in search
set smartcase                    " if uppercase letter, don't ignore
set undolevels=1000              " undo levels
set lazyredraw                   " don't redraw while executing macros
set noerrorbells                 " disable bell
set showtabline=1                " show/hide tabs
set backspace=indent,eol,start   " backspace behaviour (indent -> eol -> start)
set cmdheight=1                  " cmd height
set modeline                     " use modelines
set laststatus=2                 " show status
set suffixes=.bak,~,.swp,.o,.log " lower prioritory for tab completition
set ttimeout                     " key combination timeout
set ttimeoutlen=50               " lower statusline timeout
set autoindent                   " indent to last identation

" vim: set ts=8 sw=3 tw=78 :
