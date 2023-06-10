"turn syntax highlighting on
syntax on

"convert backspace to 4 spaces
set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set autoindent

"not expand tabs to spaces in makefiles
au FileType make setlocal noexpandtab

"disable visual mode for mouse
set mouse-=a

"fix backspace not working
set backspace=indent,eol,start

"increase default yank space from 50 to 1000 lines
set viminfo='100,<1000,s100,h

"filter to recognize nginx files
au BufRead,BufNewFile *.nginx set ft=nginx
au BufRead,BufNewFile */etc/nginx/* set ft=nginx
au BufRead,BufNewFile */usr/local/nginx/conf/* set ft=nginx
au BufRead,BufNewFile nginx.conf set ft=nginx

"enable markdown fenced code block syntax highlighting
let g:markdown_fenced_languages = ['html', 'python', 'bash=sh', 'powershell=ps1']
