{ config, lib, pkgs, ... }:

let
  mod = "Mod4";
  username = builtins.getEnv "USERNAME";
  homeDir = builtins.getEnv "HOME";
in

{
  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.

  home.stateVersion = "20.09";
  home.username=username;
  home.homeDirectory=homeDir;

  home.packages = with pkgs; [
    bat
    cargo
    curl
    exa
    fd
    fortune
    fzf
    gh
    htop
    jq
    nodejs
    ripgrep
    rustc
    unzip
    wget
    xclip
    yarn
    dhall
    zip
    nodePackages.typescript
  ];

  programs.tmux = {
	  enable = true;
	  shortcut = "a";
    keyMode = "vi";
    terminal = "screen-256color";
    extraConfig = ''
      set -g base-index 1

      set -g pane-base-index 1
      bind : command-prompt
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      set -g status-position bottom
      set -g status-left ""
      set -g status-right-length 50
      set -g status-left-length 20

      is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"

      bind-key -n C-h if-shell "$is_vim" "send-keys C-h"  "select-pane -L"
      bind-key -n C-j if-shell "$is_vim" "send-keys C-j"  "select-pane -D"
      bind-key -n C-k if-shell "$is_vim" "send-keys C-k"  "select-pane -U"
      bind-key -n C-l if-shell "$is_vim" "send-keys C-l"  "select-pane -R"

      bind-key -n C-\\ if-shell "$is_vim" "send-keys C-\\" "select-pane -l"
      bind C-l send-keys 'C-l'



    '';
  };

  programs.zsh = {
	  enable = true;
	  sessionVariables = {
		  EDITOR = "nvim";
	  };
	  oh-my-zsh = {
		  theme = "robbyrussell";
		  enable = true;
		  plugins = [ "git" "sudo" "yarn" "fzf" "vi-mode" ];
	  };
    profileExtra = ''
            export PATH="$HOME/.cabal/bin:$HOME/.ghcup/bin:$HOME/.local/bin:$PATH"
            export USERNAME=${username}
            if [ -e ${homeDir}/.nix-profile/etc/profile.d/nix.sh ]; then . ${homeDir}/.nix-profile/etc/profile.d/nix.sh; fi

            export NIX_PATH=darwin-config=$HOME/.nixpkgs/darwin-configuration.nix:$HOME/.nix-defexpr/channels

            [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    '';
  };

  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    extraConfig = ''
      syntax on
      filetype plugin indent on

      set nocompatible
      set nolist
      set number
      set relativenumber


      set scrolloff=7                                                         " Some lines around scroll for context
      set shiftround                                                          " Always indent/outdent to the nearest tabstop
      set shiftwidth=2                                                        " Indent/outdent by 2 columns
      set showmode
      set smartcase                                                           " ...unless they contain at least one capital letter
      set smartindent
      set softtabstop=2
      set expandtab
      set tabstop=2
      set updatetime=300

      map <C-j> <C-W>j
      map <C-k> <C-W>k
      map <C-h> <C-W>h
      map <C-l> <C-W>l

      let mapleader = " "

      "NERDTree
      let NERDTreeShowHidden=1
      map <C-n> :NERDTreeToggle<CR>
      nnoremap <leader>n :NERDTreeFind<cr>


      " Don't pass messages to |ins-completion-menu|.
      set shortmess+=c

      " Always show the signcolumn, otherwise it would shift the text each time
      " diagnostics appear/become resolved.
      if has("patch-8.1.1564")
        " Recently vim can merge signcolumn and number column into one
        set signcolumn=number
      else
        set signcolumn=yes
      endif

      " Use tab for trigger completion with characters ahead and navigate.
      " NOTE: Use command ':verbose imap <tab>' to make sure tab is not mapped by
      " other plugin before putting this into your config.
      inoremap <silent><expr> <TAB>
            \ pumvisible() ? "\<C-n>" :
            \ <SID>check_back_space() ? "\<TAB>" :
            \ coc#refresh()
      inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : "\<C-h>"

      function! s:check_back_space() abort
        let col = col('.') - 1
        return !col || getline('.')[col - 1]  =~# '\s'
      endfunction

      " Use <c-space> to trigger completion.
      inoremap <silent><expr> <c-space> coc#refresh()

      " Use <cr> to confirm completion, `<C-g>u` means break undo chain at current
      " position. Coc only does snippet and additional edit on confirm.
      " <cr> could be remapped by other vim plugin, try `:verbose imap <CR>`.
      if exists('*complete_info')
        inoremap <expr> <cr> complete_info()["selected"] != "-1" ? "\<C-y>" : "\<C-g>u\<CR>"
      else
        inoremap <expr> <cr> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
      endif

      " Use `[g` and `]g` to navigate diagnostics
      " Use `:CocDiagnostics` to get all diagnostics of current buffer in location list.
      nmap <silent> [g <Plug>(coc-diagnostic-prev)
      nmap <silent> ]g <Plug>(coc-diagnostic-next)

      " GoTo code navigation.
      nmap <silent> gd <Plug>(coc-definition)
      nmap <silent> gy <Plug>(coc-type-definition)
      nmap <silent> gi <Plug>(coc-implementation)
      nmap <silent> gr <Plug>(coc-references)

      " Use K to show documentation in preview window.
      nnoremap <silent> K :call <SID>show_documentation()<CR>

      function! s:show_documentation()
        if (index(['vim','help'], &filetype) >= 0)
          execute 'h '.expand('<cword>')
        else
          call CocAction('doHover')
        endif
      endfunction

      " Highlight the symbol and its references when holding the cursor.
      autocmd CursorHold * silent call CocActionAsync('highlight')

      " Symbol renaming.
      nmap <leader>rn <Plug>(coc-rename)

      " Formatting selected code.
      xmap <leader>F  <Plug>(coc-format-selected)
      nmap <leader>F  <Plug>(coc-format-selected)

      augroup mygroup
        autocmd!
        " Setup formatexpr specified filetype(s).
        autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
        " Update signature help on jump placeholder.
        autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
      augroup end

      " Applying codeAction to the selected region.
      " Example: `<leader>aap` for current paragraph
      xmap <leader>a  <Plug>(coc-codeaction-selected)
      nmap <leader>a  <Plug>(coc-codeaction-selected)

      " Remap keys for applying codeAction to the current buffer.
      nmap <leader>ac  <Plug>(coc-codeaction)
      " Apply AutoFix to problem on the current line.
      nmap <leader>qf  <Plug>(coc-fix-current)

      " Map function and class text objects
      " NOTE: Requires 'textDocument.documentSymbol' support from the language server.
      xmap if <Plug>(coc-funcobj-i)
      omap if <Plug>(coc-funcobj-i)
      xmap af <Plug>(coc-funcobj-a)
      omap af <Plug>(coc-funcobj-a)
      xmap ic <Plug>(coc-classobj-i)
      omap ic <Plug>(coc-classobj-i)
      xmap ac <Plug>(coc-classobj-a)
      omap ac <Plug>(coc-classobj-a)

      " Use CTRL-S for selections ranges.
      " Requires 'textDocument/selectionRange' support of LS, ex: coc-tsserver
      nmap <silent> <C-s> <Plug>(coc-range-select)
      xmap <silent> <C-s> <Plug>(coc-range-select)

      " Add `:Format` command to format current buffer.
      command! -nargs=0 Format :call CocAction('format')

      " Add `:Fold` command to fold current buffer.
      command! -nargs=? Fold :call     CocAction('fold', <f-args>)

      " Add `:OR` command for organize imports of the current buffer.
      command! -nargs=0 OR   :call     CocAction('runCommand', 'editor.action.organizeImport')

      " Add (Neo)Vim's native statusline support.
      " NOTE: Please see `:h coc-status` for integrations with external plugins that
      " provide custom statusline: lightline.vim, vim-airline.
      set statusline^=%{coc#status()}%{get(b:,'coc_current_function',\'\')}

      " Mappings for CoCList
      " Show all diagnostics.
      nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
      " Manage extensions.
      nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
      " Show commands.
      nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
      " Find symbol of current document.
      nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
      " Search workspace symbols.
      nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
      " Do default action for next item.
      nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
      " Do default action for previous item.
      nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
      " Resume latest coc list.
      nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

      " fzf.vim
      nnoremap <leader>fb :Buffers<CR>
      nnoremap <leader>ff :Files<CR>
      nnoremap <leader>ft :Tags<CR>
      nnoremap <leader>fg :Rg<CR>

      "Use Grepper
      nnoremap <leader>ga :Grepper -tool rg<cr>
      nnoremap <leader>gb :Grepper -buffer -tool rg<cr>
      nmap gs  <plug>(GrepperOperator)

      nnoremap <leader>% :vsplit<CR>
      nnoremap <leader>" :split<CR>

      autocmd BufWritePre *.* %s/\s\+$//e

      hi link CocFloating markdown
    '';

    plugins = with pkgs.vimPlugins; [
      fugitive
      vim-grepper
      vim-nix
      vim-monokai
      yats-vim
      denite
      vim-unimpaired
      typescript-vim
      nerdtree
      fzf-vim
      fzfWrapper
      vim-surround
      coc-nvim
      coc-git
      coc-json
      coc-tsserver
    ];
  };

  programs.git = {
    enable = true;
    userName  = "Mateusz Curylo";
    userEmail = "mateusz.curylo@protonmail.com";
  };
}
