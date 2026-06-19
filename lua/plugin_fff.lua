-- ============================================================================
-- fff.nvim: Fast File Search (replaces snacks.picker.files)
-- ============================================================================
-- Keeps snacks.explorer as sidebar file manager and snacks.picker for
-- buffers, commands, git status, etc.

-- Binary download on install/update
vim.api.nvim_create_autocmd('PackChanged', {
  group = vim.api.nvim_create_augroup('fff_install', { clear = true }),
  callback = function(ev)
    local name, kind = ev.data.spec.name, ev.data.kind
    if name == 'fff' and (kind == 'install' or kind == 'update') then
      if not ev.data.active then vim.cmd.packadd('fff') end
      require('fff.download').download_or_build_binary()
    end
  end,
})

-- ============================================================================
-- fff Setup
-- ============================================================================

require('fff').setup({
  lazy_sync = true,
  debug = {
    enabled = false,
    show_scores = false,
  },
  layout = {
    height = 0.8,
    width = 0.8,
    prompt_position = 'bottom',
    preview_position = 'right',
    preview_size = 0.5,
    anchor = 'center',
  },
  frecency = {
    enabled = true,
  },
  git = {
    status_text_color = true,
  },
  grep = {
    smart_case = true,
    modes = { 'plain', 'regex', 'fuzzy' },
  },
})

-- ============================================================================
-- Keymaps
-- ============================================================================

-- Find files (replaces <C-p> which was snacks.picker.files)
vim.keymap.set('n', '<C-p>', function()
  require('fff').find_files()
end, { desc = 'Find files (FFF)' })

-- Find files (alternative, was <leader><space> with snacks)
vim.keymap.set('n', '<leader><space>', function()
  require('fff').find_files()
end, { desc = 'Find files (FFF)' })

-- Live grep (content search)
vim.keymap.set('n', '<leader>fw', function()
  require('fff').live_grep()
end, { desc = 'Live grep (FFF)' })

-- Fuzzy live grep (more forgiving matching)
vim.keymap.set('n', '<leader>fz', function()
  require('fff').live_grep({ grep = { modes = { 'fuzzy', 'plain' } } })
end, { desc = 'Live fuzzy grep (FFF)' })

-- Search for word under cursor
vim.keymap.set('n', '<leader>fc', function()
  require('fff').live_grep({ query = vim.fn.expand('<cword>') })
end, { desc = 'Search current word (FFF)' })
