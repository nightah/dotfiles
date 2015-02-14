" .vimrc
" Have fun!

if $TERM != "linux"              " if we are not in TTY
   set t_Co=256                  " set 256 colors \o/
endif

filetype on			 " detect file types
filetype plugin on
filetype plugin indent on

colorscheme barrage		 " modified from slate/colorshot
set completeopt-=preview         " disable scratch buffer
set cursorline                   " enable cursor highlight
set showcmd                      " show command information
set noshowmode                   " we use airline
set foldmethod=marker            " allow marking folds
set showmatch                    " hilight search pattern
set incsearch                    " incremental search
set scrolloff=1                  " 1 line offset from top-bottom
set sidescrolloff=5              " 5 character offset from left-right
set nowrap                       " don't wrap lines
set virtualedit=all              " enable virtualedit (visual block)
set expandtab                    " spaces not tabs
set softtabstop=3                " indents
set shiftwidth=3                 " more indents
set number                       " show line numbers
set noswapfile                   " no swap files
set updatecount=0                " we don't use swap files
set wildmenu                     " enable wildmenu
set wildmode=longest:full,full   " wildmenu mode
set ignorecase                   " ignore case in search
set smartcase                    " if uppercase letter, don't ignore
set undolevels=1000              " undo levels
set lazyredraw                   " don't redraw while executing macros
set noerrorbells                 " disable bell
set showtabline=1                " show/hide tabs
set backspace=indent,eol,start   " backspace behaviour (indent -> eol -> start)
set cmdheight=2                  " avoid hit enter to continue
set modeline                     " use modelines
set noruler                      " use powerline instead to show stats
set laststatus=2                 " show status
set suffixes=.bak,~,.swp,.o,.log " lower prioritory for tab completition
set backup                       " backups are awesome
set backupdir=$HOME/.vim/backup  " set backup directory
set ttimeout                     " key combination timeout
set ttimeoutlen=50               " lower statusline timeout
set autoindent                   " indent to last identation

" vim: set ts=8 sw=3 tw=78 :