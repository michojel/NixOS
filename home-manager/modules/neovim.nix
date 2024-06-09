{ config, pkgs, lib, ... }:

let
  systemConfig = (import <nixpkgs/nixos> { system = config.nixpkgs.system; }).config;
  systemPackages = (import <nixpkgs/nixos> { }).pkgs;

  nvim-nu = pkgs.vimUtils.buildVimPlugin {
    name = "nvim-nu";
    version = "2022-02-17";
    #version = "2021-07-10";
    src = pkgs.fetchFromGitHub {
      owner = "LhKipp";
      repo = "nvim-nu";
      rev = "3ef01939989f4d45520873fdac23a2cd7c9c226b";
      sha256 = "0cq9a93qqxa6kc318g7d8d5rg6rsmavpcddw3vx0sf2r6j7gm8vj";
      #rev = "8729cbfc0d299c94fce0add2c5cfc00b043d6fe1";
      #sha256 = "1q7m5lm4b1jpmw8gzsms7xynkkzngk7jnfdk83vsgszn7nswbyyh";
    };
    meta.homepage = "https://github.com/LhKipp/nvim-nu";
  };

  unstable = import <nixos-unstable> {
    config = {
      allowUnfree = true;
    };
  };
in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    # available starting from 23.05
    #defaultEditor = true;

    extraConfig = (lib.readFile ./vim-extra-config.vim) + ''
      set shell=${pkgs.bash}/bin/bash
    '' + (
      if systemConfig.networking.hostName == "marog14" then
        ''
          colorscheme embark
        ''
      else
        ''
          colorscheme PaperColor
        ''
    );

    extraLuaConfig = ''
      require("nvim-tree").setup()
    '';

    coc = {
      enable = true;
      pluginConfig = lib.readFile ./neovim-coc-plugin-config.vim;
      settings = builtins.fromJSON (lib.readFile ./neovim-coc-settings.json);
    };

    withNodeJs = true;
    extraPackages = with pkgs; [
      nushell
      #nix-linter
      nixfmt-classic
      nixpkgs-fmt
      shellcheck
      shfmt
      silver-searcher
      tree-sitter
      #tree-sitter-grammars.tree-sitter-lua
      #vimPlugins.nvim-treesitter
    ];

    plugins = with pkgs.vimPlugins; [
      {
        plugin = ale;
        config = ''
          let g:ale_shell = '${pkgs.bash}/bin/bash'
          nmap <silent> <M-k> <Plug>(ale_previous_wrap)
          nmap <silent> <M-j> <Plug>(ale_next_wrap)

          augroup vim_md_ale
            autocmd!
            autocmd FileType markdown let b:ale_linters = ['mdl']
          augroup END
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
          let $FZF_DEFAULT_COMMAND='${pkgs.silver-searcher}/bin/ag -l -s --nocolor'
        '';
      }
      nerdcommenter
      {
        plugin = nvim-tree-lua;
        config = ''
          let g:loaded_netrw = 1
          let g:loaded_netrwPlugin = 1
          set termguicolors
          nnoremap <silent> <F9> :NvimTreeToggle<CR>
        '';
      }

      nvim-nu
      nvim-treesitter # dependency of nvim-nu
      null-ls-nvim # dependency of nvim-nu

      SudoEdit-vim
      {
        plugin = vim-airline;
        config = ''
          let g:airline_detect_paste = 1
          " let g:airline_section_warning = airline#section#create(['whitespace'])
          let g:airline_section_z = airline#section#create(['C[%B]', 'windowswap', 'obsession', '%p%%', 'linenr', 'maxlinenr', 'colnr'])

          let g:airline_mode_map = {
              \ '__'     : '-',
              \ 'c'      : 'C',
              \ 'i'      : 'I',
              \ 'ic'     : 'I',
              \ 'ix'     : 'I',
              \ 'n'      : 'N',
              \ 'multi'  : 'M',
              \ 'ni'     : 'N',
              \ 'no'     : 'N',
              \ 'R'      : 'R',
              \ 'Rv'     : 'R',
              \ 's'      : 'S',
              \ 'S'      : 'S',
              \ ''     : 'S',
              \ 't'      : 'T',
              \ 'v'      : 'V',
              \ 'V'      : 'V',
              \ ''     : 'V',
              \ }
          let g:airline#extensions#default#section_truncate_width = {
            \ 'b': 15,
            \ 'x': 25,
            \ 'y': 15,
            \ }
          let g:airline#extensions#ale#enabled = 1
          let g:airline#extensions#tmuxline#enabled = 1
          let g:airline#extensions#tabline#enabled = 1
        '';
      }
      vim-devicons
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
          let g:go_bin_path = $GOBIN
          " rely on coc instead
          let g:go_def_mapping_enabled = 0
          " augroup vim_go_plugin
          "   autocmd!
          "   autocmd FileType go nmap <Leader>gi <Plug>(go-info)
          "   autocmd FileType go nmap <Leader>gds <Plug>(go-doc)
          "   autocmd FileType go nmap <Leader>gdv <Plug>(go-doc-vertical)
          "   autocmd FileType go nmap <Leader>gg <Plug>(go-def)
          "   autocmd FileType go nmap <Leader>gs <Plug>(go-def-split)
          "   autocmd FileType go nmap <Leader>gv <Plug>(go-def-vertical)
          "   autocmd FileType go nmap <Leader>gt <Plug>(go-def-tab)
          "   autocmd FileType go nmap <Leader>ge :GoErrCheck<CR>
          "   autocmd Filetype go command! -bang A  call go#alternate#Switch(<bang>0, 'edit')
          "   autocmd Filetype go command! -bang AV call go#alternate#Switch(<bang>0, 'vsplit')
          "   autocmd Filetype go command! -bang AS call go#alternate#Switch(<bang>0, 'split')
          "   autocmd filetype go inoremap <buffer> . .<C-x><C-o>
          "   autocmd FileType go setlocal textwidth=110 sw=4 ts=4 noet
          " augroup END
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
        # TODO: look into  tpope/vim-rsi as a possible replacement
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
          augroup vim_nix_plugin
            autocmd!
            autocmd FileType nix let b:ale_fixers   = ['nixpkgs-fmt']
            autocmd FileType nix let b:ale_linters  = ['nix-linter']
            autocmd FileType nix let b:ale_fix_on_save = 1
          augroup END
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
      vim-tmux-navigator
      # vim-asciidoctor

      # snippets
      # ultisnips

      {
        plugin = coc-snippets;
        config = ''
          " Use <C-l> for trigger snippet expand.
          imap <C-l> <Plug>(coc-snippets-expand)

          " Use <C-j> for select text for visual placeholder of snippet.
          vmap <C-j> <Plug>(coc-snippets-select)

          " Use <C-j> for jump to next placeholder, it's default of coc.nvim
          let g:coc_snippet_next = '<c-j>'

          " Use <C-k> for jump to previous placeholder, it's default of coc.nvim
          let g:coc_snippet_prev = '<c-k>'

          " Use <C-j> for both expand and jump (make expand higher priority.)
          imap <C-j> <Plug>(coc-snippets-expand-jump)

          " Use <leader>x for convert visual selected code to snippet
          xmap <leader>x  <Plug>(coc-convert-snippet)

          let g:coc_snippet_next = '<tab>'
        '';
      }
      vim-snippets
      vim-startify
      {
        plugin = vim-mundo;
        config = ''
          nnoremap <F5> :MundoToggle<CR>
          set undofile
          set undodir=~/.local/share/nvim/undo
        '';
      }

      # themes
      embark-vim
      jellybeans-nvim
      papercolor-theme
      solarized
      vim-airline-themes
      # skittles-dark
    ];
  };
}
