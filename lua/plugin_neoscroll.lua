-- ============================================================================
-- Scroll: Smooth scrolling animations
-- ============================================================================

local snacks = require("snacks")

-- Note: Scroll is already enabled in core_plugins.lua via snacks.setup()
-- This file only configures custom scroll keymaps

-- ============================================================================
-- Custom Scroll Keymaps
-- ============================================================================

-- Half-page scroll with smooth animation
snacks.keymap.set('n', '<C-S-j>', '<C-d>', { desc = 'Scroll down half-page' })
snacks.keymap.set('n', '<C-S-k>', '<C-u>', { desc = 'Scroll up half-page' })

-- Line scroll (without moving cursor)
snacks.keymap.set('n', '<S-Up>', '<C-y>', { desc = 'Scroll up' })
snacks.keymap.set('n', '<S-Down>', '<C-e>', { desc = 'Scroll down' })

-- Cursor position (zt, zz, zb work natively with smooth scroll)
-- These already have smooth scrolling when snacks.scroll is enabled
