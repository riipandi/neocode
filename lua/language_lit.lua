-- =============================================================================
-- Lit Web Component Language Support
-- =============================================================================
-- Lit uses TypeScript/JavaScript with web component specific features
-- ts_ls already handles TS/JS, this file adds Lit-specific configurations
-- =============================================================================

local autocmd = vim.api.nvim_create_autocmd

-- =============================================================================
-- Lit-specific configuration (ts_ls handles most)
-- =============================================================================

autocmd('FileType', {
  pattern = {
    'javascript',
    'javascriptreact',
    'typescript',
    'typescriptreact',
  },
  callback = function(args)
    local bufname = vim.api.nvim_buf_get_name(args.buf)
    if bufname == '' then
      return
    end

    -- Check if this is a Lit project
    local bufdir = vim.fn.fnamemodify(bufname, ':p:h')
    local root_dir = vim.fn.finddir('.git', bufdir .. ';')
    if root_dir == '' then
      root_dir = vim.fn.findfile('package.json', bufdir .. ';')
      if root_dir == '' then
        root_dir = vim.fn.findfile('tsconfig.json', bufdir .. ';')
      end
    end

    if root_dir == '' then
      return
    end

    local project_dir = vim.fn.fnamemodify(root_dir, ':h')
    local has_lit = false

    -- Check for lit in package.json dependencies
    local package_json = project_dir .. '/package.json'
    if vim.fn.filereadable(package_json) == 1 then
      local content = vim.fn.readfile(package_json)
      local joined = table.concat(content, '')
      if joined:find('"lit"') or joined:find('"@lit/lit"') or joined:find('"lit-element"') or joined:find('"@lit/reactive-element"') then
        has_lit = true
      end
    end

    if has_lit then
      vim.b[args.buf].lit_project = true
    end
  end,
  desc = 'Detect Lit project',
})
