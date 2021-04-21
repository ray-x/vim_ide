# vim as a programming IDE

I used to use slickedit, qt-creator, idea (webstorm, goland), vscode, but I am back to vi now. Thanks for `Dein.vim` I do
not need to configure my setup everytime....... I am still using sublime edit(as a notepad)

vimr is one of the best nvim-gui. But it does not in active development(It is hard for a one developer
project), some of the crash durning coding is annoying. I only use nvim(nightly) + kitty now.

The `Plug` config is located in branch [Plug branch](https://github.com/ray-x/dotfiles/tree/zprezto-plug)

- nvim+kitty configured with pop menu:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/menu.jpg)

- nvim clap preview:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/clap.jpg)

- nvim+kitty coc+ale:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/coc_float_errorcheck.jpg)

## Neovim Plugins

There are lots of amazing plugins,
I used following plugin a lots

- `Plug` -> `Dein` -> `Lua-Packer`
  Dein is a great tool. Very fast and very well support for vim/neovim lazy loading. Change to Lua-Packer does not
  bring as great improvements as Plug -> Dein. But still about 80ms faster (~20%) for Golang codes loading.
  If you interested in Dein version, Please refer to [Dein](https://github.com/ray-x/dotfiles/tree/nvim-comple).
  This was the last Dein/Packer dual supports version I have (init.vim has a flag to choose).
  ATM, minium support for vim. Most plugins only works under neovim 0.5.0+.

  I followed Raphael(a.k.a glepnir) https://github.com/glepnir/nvim dotfiles. He provides a good wrapper for
  Packer. I have an `overwrite` folder which will override the settings. Also, lots of changes in modules/plugins.
  luarock setup
  A.T.M. nvim-compe as a completion engine with LSP, LSP saga. vim-multi-cursor, clap/telescope. treesitter,
  lazy load vim-go. So, other than module folder, I could copy/paste everything else from glepnir's configure file,
  which make my life easier.

- vim-clap

  One of the best plugin for search anything. I used it to replace fzf, leaderF, leaderP, defx, Ag/Ack/Rg, yank(ring), project management. undolist and many more.

- nvim-lsp with [navigator.lua](https://github.com/ray-x/navigator.lua)

  I turn off vim-go auto-complete/LSP and turn to nvim-lsp. It adds around 200ms bootup time and some of the extensions
  might crash when I using coc (but it hard to check which becuase ~4 node.js services coc forked)
  Some useful script from TJ, and [glepnir](https://github.com/glepnir)

  nvim-tree: file-explorer (lightweight and fast)
  hrsh7th/nvim-compe: auto-complete
  vsnip: code snipts(Load snippet from VSCode extension). It is a full featured IDE.

  ![document symbol](https://github.com/ray-x/files/blob/master/img/navigator/doc_symbol.gif?raw=true)

- ALE

  Well, I am still using ALE and configure lint tools with it. It is good to find something compiler missed.

- Programming support:
  Treesitter, nvim-lsp and [navigator.lua](https://github.com/ray-x/navigator.lua), for golang, use [go.nvim](https://github.com/ray-x/go.nvim)

- Debug:

  vimspector, dlv, nvim-dap

- Theme, look&feel:

  home cooked Aurora, galaxyline (lua), devicons(lua), blankline(indent),

- Color:

  Primary with treesitter from nvim nightly (nvim-lsp and this make it hard for me to turn back to vim)
  nvim-colorizer.lua (display hex and color in highlight), log-highlight, limelight, interestingwords

- Git:

  fugitive, gv, nvimtree, gitsigns.nvim, git-blame.nvim

- Format:

  tabular, lsp based code formating (or, sometimes prettier), auto-pair

- Menu and tab:
  quickui(created a menu for the function/keybind I used less often. I can not remember all the commands and keybinds....)
  But Damn it, I spend lots of time to configure it, however, I rarely use it. So I end up delete the plugin.
  nvim-bufferline.lua: Yes, with lua and neovim only

- Tools: floatterm

- Move and Edit:

  easymotion, vim-multi-cursor
  , vim-anyfold (better folding)

## Shell

- OhMyZshell is good, iterm2 is popular, but I turned to zim(Zsh IMproved FrameWork
  ) + powerlevel10 + kitty. It is cooool and faster.
  nvim+kitty split view:

  ![vim_ide with nvim+kitty](https://github.com/ray-x/dotfiles/blob/master/img/kitty.jpg)

zimfw is faster than oh-my-zh and zpreztor regarding the loading speed.

## Parking lots

These tools are good, but due to confliction, less use, or, not suite to my workflow

- vim/gvim
- YCM you complete me
- easymotion
- oh-my-zh, iterm2
- zpreztor
- rainbow
- defx
-
-
