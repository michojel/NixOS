{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the
  # paths it should manage.
  home.username = "miminar";
  home.homeDirectory = "/home/miminar";

  # This value determines the Home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new Home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update Home Manager without changing this value. See
  # the Home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "22.05";

  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs = {
    git = {
      enable = true;
      userName = "Michal Minář";
      userEmail = "mm@michojel.cz";
    };

    fzf = {
      enable = true;
      tmux.enableShellIntegration = true;
    };

    tmux = {
      enable = true;
      clock24 = true;
      keyMode = "vi";
      terminal = "screen-256color";
      tmuxinator.enable = true;
      plugins = with pkgs.tmuxPlugins; [
        copycat
        logging
        open
        sensible
        yank
      ];
    };

    readline = {
      enable = true;
      bindings = {
        # Map (UTF-8) non-breaking space to regular space, in case the user
        # accidentally types Option-Space or Shift-Space when they meant Space.
        "\\xC2\\xA0" = ''" "'';
        "\\eo" = ''"\\C-p\\C-a\\ef "'';
        # Make Meta+S cycle through the list of completions
        "\\em" = "menu-complete";
        # autocomplete by pressing Tab
        "Tab" = "complete";
      };

      variables = {
        visible-stats = true;
        mark-modified-lines = true;
        mark-directories = true;
        page-completions = true;
        skip-completed-text = true;
        match-hidden-files = false;
        show-all-if-ambiguous = true;
        # to make <delete> key work in Suckless Terminal
        enable-keypad = true;
      };

      extraConfig = ''
        $if mode=emacs
            "\ei": overwrite-mode
            "\ew": kill-region
            #"\C-w": kill-region
            #"\ew": copy-region-as-kill
            "\e ": set-mark
        $endif

        # disable beep
        set bell-style none
      '';
    };

    bash = {
      enable = true;
      enableVteIntegration = true;
      bashrcExtra = '''';
      historyControl = [ "erasedups" "ignorespace" ];
      bat.enable = true;
      #initExtra = '''';
      #shellAliases = [ ];
      #profileExtra = '''';
    };

    nushell = {
      enable = true;
      settings = {
        edit_mode = "vi";
      };
    };

    neovim = {
      enable = true;
      viAlias = true;
      vimAlias = true;
      vimdiffAlias = true;

      extraConfig = lib.readFile ./extra-config.vim;
      coc.enable = true;

      withNodeJs = true;
      extraPackages = with pkgs; [
        nix-linter
        nixpkgs-fmt
        shellcheck
        shfmt
      ];

      plugins = with pkgs.vimPlugins; [
        {
          plugin = ale;
          config = ''
            nmap <silent> <C-k> <Plug>(ale_previous_wrap)
            nmap <silent> <C-j> <Plug>(ale_next_wrap)
          '';
        }
        {
          plugin = fzf-vim;
          config = ''
            nmap <leader>t :Files<CR>
            nmap <leader>T :GFiles<CR>
            nmap <leader>b :Buffers<CR>
            nmap <leader>C :Commits<CR>
            nmap <leader><tab> <plug>(fzf-maps-n)
            xmap <leader><tab> <plug>(fzf-maps-x)
            omap <leader><tab> <plug>(fzf-maps-o)

            imap <c-x><c-k> <plug>(fzf-complete-word)
            imap <c-x><c-f> <plug>(fzf-complete-path)
            imap <c-x><c-j> <plug>(fzf-complete-file-ag)
            imap <c-x><c-l> <plug>(fzf-complete-line)

            inoremap <expr> <c-x><c-k> fzf#vim#complete#word({'left': '15%'})

            " command that fetches file list for the fzf; ag pays attention to vcs-ignores.
            let $FZF_DEFAULT_COMMAND='ag -l -s --nocolor'
          '';
        }
        {
          plugin = nerdtree;
          config = ''
            let g:NERDTreeHijackNetrw       = 1     " use NERDTree instead of netrw
            let g:NERDTreeRespectWildIgnore = 1
            let g:NERDTreeChDirMode         = 2     " change CWD when changing root in NERDTree
            nnoremap <silent> <F9> :NERDTreeToggle<CR>
          '';
        }
        SudoEdit-vim
        {
          plugin = vim-airline;
          config = ''
            let g:airline_detect_paste = 1
            let g:airline_section_warning = airline#section#create(['whitespace'])
            let g:airline_mode_map = {
                \ '__' : '-',
                \ 'n'  : 'N',
                \ 'i'  : 'I',
                \ 'R'  : 'R',
                \ 'c'  : 'C',
                \ 'v'  : 'V',
                \ 'V'  : 'V',
                \ '' : 'V',
                \ 's'  : 'S',
                \ 'S'  : 'S',
                \ '' : 'S',
                \ }
            let g:airline#extensions#default#section_truncate_width = {
              \ 'b': 15,
              \ 'x': 25,
              \ 'y': 15,
              \ }
            let g:airline#extensions#ale#enabled = 1
            let g:airline#extensions#tmuxline#enabled = 1
            let g:airline_theme='papercolor_dark'
          '';
        }
        {
          plugin = vim-easy-align;
          config = ''
            nmap ga <Plug>(EasyAlign)
            xmap ga <Plug>(EasyAlign)
          '';
        }
        vim-fugitive
        {
          plugin = vim-go;
          config = ''
            let g:go_fmt_options = '-s'
            let g:go_fmt_autosave = 1
            " let g:go_fmt_command = 'goimports'
            augroup go
              autocmd!
              autocmd FileType go nmap <Leader>gi <Plug>(go-info)
              autocmd FileType go nmap <Leader>gds <Plug>(go-doc)
              autocmd FileType go nmap <Leader>gdv <Plug>(go-doc-vertical)
              autocmd FileType go nmap <Leader>gg <Plug>(go-def)
              autocmd FileType go nmap <Leader>gs <Plug>(go-def-split)
              autocmd FileType go nmap <Leader>gv <Plug>(go-def-vertical)
              autocmd FileType go nmap <Leader>gt <Plug>(go-def-tab)
              autocmd FileType go nmap <Leader>ge :GoErrCheck<CR>
              autocmd Filetype go command! -bang A  call go#alternate#Switch(<bang>0, 'edit')
              autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
              autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
              autocmd filetype go inoremap <buffer> . .<C-x><C-o>
              autocmd FileType go setlocal textwidth=110 sw=4 ts=4 noet
            augroup END
          '';
        }
        {
          plugin = vim-grepper;
          config = ''
            nmap gs <Plug>(GrepperOperator)
            xmap gs <Plug>(GrepperOperator)
            nnoremap <Leader>G/ :Grepper<cr>
            nnoremap <Leader>Gv :Grepper -side<cr>
            nnoremap <Leader>Gg :Grepper -tool git -side<cr>
            nnoremap <Leader>G* :Grepper -cword -noprompt -switch -open<cr>
          '';
        }
        {
          plugin = vim-husk;
          config = ''
            let g:husk_ctrl_k = 0
            if !has('gui_running') && !has('nvim')
              cmap <Esc>k <M-k>
            endif
            cnoremap <expr> <M-k> husk#clear_line_after_cursor()
            " TODO: allow to use <C-]> and <C-M-]> in command line mode
          '';
        }
        vim-jsonnet
        {
          plugin = vim-nix;
          config = ''
            autocmd FileType nix let b:ale_fixers   = ['nixpkgs-fmt']
            autocmd FileType nix let b:ale_linters  = ['nix-linter']
            autocmd FileType nix let b:ale_fix_on_save = 1
          '';
        }
        vim-one
        vim-repeat
        vim-rhubarb
        vim-sensible
        vim-surround
        vim-terraform
        {
          plugin = vista-vim;
          config = ''
            let g:vista#renderer#enable_icon = 1
            let g:vista_fzf_preview = ['right:50%']
            nmap <F8> :Vista!!<CR>
          '';
        }
        # vim-asciidoctor

        # themes
        jellybeans-nvim
        papercolor-theme
        solarized
        vim-airline-themes
        # skittles-dark
      ];
    };
  };
}
