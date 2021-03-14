-- todo allow config passed in

local lspconfig = nil
local lsp_status = nil
if not packer_plugins["nvim-lua/lsp-status.nvim"] or not packer_plugins["lsp-status.nvim"].loaded then
  vim.cmd [[packadd lsp-status.nvim]]
  lsp_status = require("lsp-status")
  -- if lazyloading
  vim.cmd [[packadd nvim-lspconfig]]
  lspconfig = require "lspconfig"
end

local function setup(user_opts)
  if lspconfig == nil then
    print("lsp-config need installed and enabled")
    return
  end
  if user_opts ~= nil and user_opts.clients ~= nil then
    return
  end
  local on_attach = require("lsp.handler").on_attach
  local servers = {
    "gopls",
    "tsserver",
    "flow",
    "bashls",
    "dockerls",
    "pyls",
    "sumneko_lua",
    "vimls",
    "html",
    "jsonls",
    "cssls",
    "yamlls",
    "clangd",
    "sqls"
  }

  for _, lspclient in ipairs(servers) do
    if lsp_status ~= nl then
      lsp_status.register_progress()

      lsp_status.config(
        {
          status_symbol = "",
          indicator_errors = "", --'',
          indicator_warnings = "", --'',
          indicator_info = "﯎",
          --'',
          indicator_hint = "💡",
          indicator_ok = "",
          --'✔️',
          spinner_frames = {"⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"},
          select_symbol = function(cursor_pos, symbol)
            if symbol.valuerange then
              local value_range = {
                ["start"] = {
                  character = 0,
                  line = vim.fn.byte2line(symbol.valuerange[1])
                },
                ["end"] = {
                  character = 0,
                  line = vim.fn.byte2line(symbol.valuerange[2])
                }
              }

              return require("lsp-status.util").in_range(cursor_pos, value_range)
            end
          end
        }
      )
    end
    require "utils.highlight".diagnositc_config_sign()
    require "utils.highlight".add_highlight()
  end

  for _, lspclient in ipairs({"tsserver", "bashls", "flow", "dockerls", "vimls", "html", "jsonls", "cssls", "yamlls"}) do
    lspconfig[lspclient].setup {
      message_level = vim.lsp.protocol.MessageType.error,
      log_level = vim.lsp.protocol.MessageType.error,
      on_attach = on_attach,
      capabilities = lsp_status.capabilities
    }
  end

  local cap = vim.lsp.protocol.make_client_capabilities()

  local gopls={}
  gopls['ui.completion.usePlaceholders'] =  true
  lspconfig.gopls.setup {
    on_attach = on_attach,
    capabilities = cap,
    -- init_options = {
    --   useplaceholders = true,
    --   completeunimported = true
    -- },
    message_level = vim.lsp.protocol.MessageType.Error,
    cmd = {
      "gopls"

      -- share the gopls instance if there is one already
      -- "-remote=auto",

      --[[ debug options ]]
      --
      --"-logfile=auto",
      --"-debug=:0",
      --"-remote.debug=:0",
      --"-rpc.trace",
    },
    settings = {
      -- gopls = gopls
      --{
        --"ui.completion.usePlaceholders" = true,
        -- analyses = {
        --   unusedparams = true,
        --   unreachable = false
        -- },
        -- codelenses = {
        --   generate = true, -- show the `go generate` lens.
        --   gc_details = true --  // show a code lens toggling the display of gc's choices.
        -- },
        -- ui ={
        --   completion = {useplaceholders = true,matcher = "fuzzy", symbolMatcher = "fuzzy", },
        --   diagnostic = {staticcheck = true, experimentalDiagnosticsDelay = '400ms'},
        --   navigation = {symbolMatcher= 'Fuzzy'},
        -- },
        --
        -- formatting = {gofumpt=true},
        -- documentation = {hoverKind = 'FullDocumentation'},
        -- -- completeunimported = true,
        -- build = {buildFlags = {"-tags", "integration"}}
      --}
    },
    root_dir = function(fname)
      local util = require("lspconfig").util
      return util.root_pattern("go.mod", ".git")(fname) or util.path.dirname(fname)
    end
  }

  lspconfig.sqls.setup(
    {
      on_attach = function(client, bufnr)
        client.resolved_capabilities.execute_command = true
        lsp_status.on_attach(client, bufnr)
        require "utils.highlight".diagnositc_config_sign()
        require "sqls".setup {picker = "telescope"} -- or default
      end,
      settings = {
        cmd = {"sqls", "-config", "$HOME/.config/sqls/config.yml"},
        -- alterantively:
        -- connections = {
        --   {
        --     driver = 'postgresql',
        --     datasourcename = 'host=127.0.0.1 port=5432 user=postgres password=password dbname=user_db sslmode=disable',
        --   },
        -- },
        workspace = {
          library = {
            -- this loads the `lua` files from nvim into the runtime.
            [vim.fn.expand("$vimruntime/lua")] = true,
            [vim.fn.expand("~/repos/nvim/lua")] = true
          }
        }
      }
    }
  )

  local system_name
  if vim.fn.has("mac") == 1 then
    system_name = "macos"
  elseif vim.fn.has("unix") == 1 then
    system_name = "linux"
  elseif vim.fn.has("win32") == 1 then
    system_name = "windows"
  else
    print("unsupported system for sumneko" .. system_name)
  end

-- lua setup
-- local sumneko_root_path = vim.fn.stdpath('cache')..'/lspconfig/sumneko_lua/lua-language-server'
-- local sumneko_binary = sumneko_root_path.."/bin/"..system_name.."/lua-language-serve"
local sumneko_root_path = vim.fn.expand("$HOME") .. "/github/sumneko/lua-language-server"
local sumneko_binary = vim.fn.expand("$HOME") .. "/github/sumneko/lua-language-server/bin/macOS/lua-language-server"

require "lspconfig".sumneko_lua.setup {
  cmd = {sumneko_binary, "-E", sumneko_root_path .. "/main.lua"},
  on_attach = on_attach,
  settings = {
    Lua = {
      runtime = {
        -- Tell the language server which version of Lua you're using (most likely LuaJIT in the case of Neovim)
        version = "LuaJIT",
        -- Setup your lua path
        path = vim.split(package.path, ";")
      },
      diagnostics = {
        enable = true,
        -- Get the language server to recognize the `vim` global
        globals = {
          "vim",
          "describe",
          "it",
          "before_each",
          "after_each",
          "teardown",
          "pending"
        }
      },
      workspace = {
        -- Make the server aware of Neovim runtime files
        library = {
          [vim.fn.expand("$VIMRUNTIME/lua")] = true,
          [vim.fn.expand("$VIMRUNTIME/lua/vim/lsp")] = true,
          [vim.fn.expand("~/repos/nvim/lua")] = true
        }
      }
    }
  }
}


  lspconfig.clangd.setup {
    cmd = {
      "clangd",
      "--background-index",
      "--suggest-missing-includes",
      "--clang-tidy",
      "--header-insertion=iwyu"
    },
    on_attach = function(client)
      client.resolved_capabilities.document_formatting = true
      on_attach(client)
    end
  }

  servers = {
    "dockerls",
    "bashls",
    "rust_analyzer",
    "pyls"
  }

  for _, server in ipairs(servers) do
    lspconfig[server].setup {
      on_attach = on_attach
    }
  end
end

return {setup = setup}