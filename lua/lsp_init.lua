local nvim_lsp = require('nvim_lsp')
local diagnostic = require('diagnostic')
local completion = require('completion')
local lsp_status = require('lsp-status')
local util = require('nvim_lsp/util')
local configs = require('nvim_lsp/configs')

--require'completion'.on_attach()

local function preview_location_callback(_, method, result)
  if result == nil or vim.tbl_isempty(result) then
    vim.lsp.log.info(method, 'No location found')
    return nil
  end
  if vim.tbl_islist(result) then
    vim.lsp.util.preview_location(result[1])
  else
    vim.lsp.util.preview_location(result)
  end
end

function peek_definition()
  local params = vim.lsp.util.make_position_params()
  return vim.lsp.buf_request(0, 'textDocument/definition', params, preview_location_callback)
end

local on_attach = function(client, bufnr)
  diagnostic.on_attach(client, bufnr)
  completion.on_attach(client, bufnr)
  lsp_status.on_attach(client, bufnr)

  vim.api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

  local opts = { noremap=true, silent=true }
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'K',  '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'ga', '<cmd>lua vim.lsp.buf.code_action()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gD', '<cmd>lua vim.lsp.util.show_line_diagnostics()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gs', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gt', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'g0', '<cmd>lua vim.lsp.buf.document_symbol()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', 'gW', '<cmd>lua vim.lsp.buf.workspace_symbol()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>de', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '<Leader>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)

  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[d', ':PrevDiagnostic<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']d', ':NextDiagnostic<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', '[D', ':PrevDiagnosticCycle<CR>', opts)
  vim.api.nvim_buf_set_keymap(bufnr, 'n', ']D', ':NextDiagnosticCycle<CR>', opts)

  vim.lsp.callbacks['textDocument/codeAction'] = require'lsputil.codeAction'.code_action_handler
  vim.lsp.callbacks['textDocument/references'] = require'lsputil.locations'.references_handler
  vim.lsp.callbacks['textDocument/definition'] = require'lsputil.locations'.definition_handler
  vim.lsp.callbacks['textDocument/declaration'] = require'lsputil.locations'.declaration_handler
  vim.lsp.callbacks['textDocument/typeDefinition'] = require'lsputil.locations'.typeDefinition_handler
  vim.lsp.callbacks['textDocument/implementation'] = require'lsputil.locations'.implementation_handler
  vim.lsp.callbacks['textDocument/documentSymbol'] = require'lsputil.symbols'.document_handler
  vim.lsp.callbacks['workspace/symbol'] = require'lsputil.symbols'.workspace_handler

  vim.api.nvim_command [[autocmd CursorHold  <buffer> lua vim.lsp.buf.document_highlight()]]
  vim.api.nvim_command [[autocmd CursorHoldI <buffer> lua vim.lsp.buf.document_highlight()]]
  vim.api.nvim_command [[autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()]]
  vim.api.nvim_command [[autocmd BufWritePre <buffer> lua vim.lsp.buf.formatting_sync()]]

  local method = "textDocument/publishDiagnostics"
  local default_callback = vim.lsp.callbacks[method]
  vim.lsp.callbacks[method] = function(err, method, result, client_id)
    default_callback(err, method, result, client_id)
    if result and result.diagnostics then
        local item_list = {}
        for _, v in ipairs(result.diagnostics) do
            local fname = result.uri
            table.insert(item_list, { filename = fname, lnum = v.range.start.line + 1, col = v.range.start.character + 1; text = v.message; })
            print(v.message)
        end
        local old_items = vim.fn.getqflist()
        for _, old_item in ipairs(old_items) do
            local bufnr = vim.uri_to_bufnr(result.uri)
            if vim.uri_from_bufnr(old_item.bufnr) ~= result.uri
                then
                    table.insert(item_list, old_item)
                end
            end
            vim.fn.setqflist({}, ' ', { title = 'LSP'; items = item_list; })
        end
    end

end

local servers = { 'gopls', 'tsserver', 'bashls', 'pyls', 'sumneko_lua', 'vimls', 'html', 'jsonls', 'cssls', 'sqlls', 'yamlls', 'ccls', 'dockerls' }
for _, lsp in ipairs(servers) do
  lsp_status.register_progress()
  lsp_status.config({
    status_symbol = '',
    indicator_errors = '',
    indicator_warnings = '',
    indicator_info = 'כֿ',
    indicator_hint = 'λ',
    indicator_ok = '✔️', 
    spinner_frames = { '⣾', '⣽', '⣻', '⢿', '⡿', '⣟', '⣯', '⣷' },
  })
  nvim_lsp[lsp].setup {
    on_attach = on_attach,
    capabilities = lsp_status.capabilities
  }
end

nvim_lsp.gopls.setup {
    on_attach=on_attach,
    capabilities = lsp_status.capabilities,
    root_dir = function(fname)
      return util.root_pattern("go.mod", ".git")(fname) or util.path.dirname(fname)
    end;
}

-- populate quickfix list with diagnostics
local method = "textDocument/publishDiagnostics"
local default_callback = vim.lsp.callbacks[method]
vim.lsp.callbacks[method] = function(err, method, result, client_id)
    default_callback(err, method, result, client_id)
    if result and result.diagnostics then
        local item_list = {}
        for _, v in ipairs(result.diagnostics) do
            local fname = result.uri
            table.insert(item_list, { filename = fname, lnum = v.range.start.line + 1, col = v.range.start.character + 1; text = v.message; })
            print(v.message)
        end
        local old_items = vim.fn.getqflist()
        for _, old_item in ipairs(old_items) do
            local bufnr = vim.uri_to_bufnr(result.uri)
            if vim.uri_from_bufnr(old_item.bufnr) ~= result.uri
                then
                    table.insert(item_list, old_item)
                end
            end
            vim.fn.setqflist({}, ' ', { title = 'LSP'; items = item_list; })
        end
    end


-- local function nmap_lsp(keys, cmd)
--   api.nvim_buf_set_keymap(
--     bufnr, 'n', keys, '<cmd>lua vim.lsp.'..cmd..'<CR>', opts
--   )
-- end

-- local custom_on_attach = function(client, bufnr)
--   api.nvim_buf_set_option(bufnr, 'omnifunc', 'v:lua.vim.lsp.omnifunc')

--   -- Mappings.

--   local opts = {
--     noremap=true,
--     silent=true,
--   }
--   local function nmap_lsp(keys, cmd)
--     api.nvim_buf_set_keymap(
--       bufnr, 'n', keys, '<cmd>lua vim.lsp.'..cmd..'<CR>', opts
--     )
--   end
--   nmap_lsp('gd',    'buf.declaration()')
--   nmap_lsp('<c-]>', 'buf.definition()')
--   nmap_lsp('K',     'buf.hover()')
--   nmap_lsp('D',     'util.show_line_diagnostics()')
--   nmap_lsp('gi',    'util.implementation()')
--   nmap_lsp('<C-k>', 'buf.signature_help()')
--   nmap_lsp(',rn',   'buf.rename()')
--   nmap_lsp('gy',    'buf.type_definition()')
--   nmap_lsp('pd',    'buf.peek_definition()')
--   nmap_lsp('gr',    'buf.references()')
--   vim.g['diagnostic_enable_virtual_text'] = 1
--   -- api.nvim_set_var('diagnostic_enable_virtual_text','1')
--   require'diagnostic'.on_attach()
--   require'completion'.on_attach()
--   lsp_status.on_attach(client)
-- end
-- -- nvim_lsp.tsserver.setup{}
-- local custom_on_attach_folding = function(client, bufnr)
--   custom_on_attach(client, bufnr)
--   require('folding').on_attach()
-- end

-- local custom_on_attach_sumneko_lua = function(client, bufnr)
--   lsp_status.config {
--     select_symbol = function(cursor_pos, symbol)
--       if symbol.valueRange then
--         local value_range = {
--           ["start"] = {
--             character = 0,
--             line = vim.fn.byte2line(symbol.valueRange[1])
--           },
--           ["end"] = {
--             character = 0,
--             line = vim.fn.byte2line(symbol.valueRange[2])
--           }
--         }

--         return require("lsp-status.util").in_range(cursor_pos, value_range)
--       end
--     end
--   }
--   custom_on_attach_folding(client, bufnr)
-- end

-- nvim_lsp.sumneko_lua.setup{
--   on_attach = custom_on_attach_sumneko_lua,
--   capabilities = lsp_status.capabilities,
--   settings = {
--     Lua = {
--       runtime = {
--         version = "LuaJIT"
--       }
--     }
--   }
-- }

-- require'nvim_lsp'.sumneko_lua.setup{
--     on_attach = on_attach,
--     capabilities = lsp_status.capabilities,
--     settings = {
--         Lua = {
--             diagnostics = {
--                 globals = {"vim", "vis", "rpm"},
--                 disable = {"lowercase-global"}
--             }
--         }
--     }
-- }
