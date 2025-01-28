-- ~/.config/nvim/init.lua

-- 1. Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath,
  })
end
vim.opt.rtp:prepend(lazypath)

-- 2. Initialize lazy.nvim with plugins
require("lazy").setup({
  -- A) Gruvbox Theme
  {
    "ellisonleao/gruvbox.nvim",
    config = function()
      require("gruvbox").setup({
        bold = true,
        italic = {
          strings = false,
          comments = false,
          operators = false,
          folds = false,
        },
        underline = true,
        contrast = "medium", -- "hard", "soft", or "medium"
        overrides = {},
        dim_inactive = false,
        transparent_mode = false,
      })
      vim.cmd.colorscheme("gruvbox")
    end,
  },

  -- B) Telescope
  {
    "nvim-telescope/telescope.nvim",
    dependencies = { 
      "nvim-lua/plenary.nvim",
      { 
        'nvim-telescope/telescope-fzf-native.nvim', 
        -- More explicit build command
        build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build',
        -- Ensure the plugin is only loaded if build is successful
        cond = function()
          return vim.fn.executable('cmake') == 1 and 
                 vim.fn.executable('make') == 1
        end
      }
    },
    config = function()
      local telescope = require("telescope")
      
      telescope.setup({
        extensions = {
          fzf = {
            fuzzy = true,                    -- false will only do exact matching
            override_generic_sorter = true,  -- override the generic sorter
            override_file_sorter = true,     -- override the file sorter
            case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
          }
        }
      })
  
      -- fzf extension
      pcall(telescope.load_extension, 'fzf')
  
      -- Keybindings
      local builtin = require("telescope.builtin")
      vim.keymap.set("n", "<leader>ff", builtin.find_files, { desc = "Find Files" })
      vim.keymap.set("n", "<leader>fg", builtin.live_grep, { desc = "Live Grep" })
      vim.keymap.set("n", "<leader>fb", builtin.buffers, { desc = "Buffers" })
      vim.keymap.set("n", "<leader>fh", builtin.help_tags, { desc = "Help Tags" })
    end,
  },

  -- C) nvim-cmp (Autocompletion)
  {
    "hrsh7th/nvim-cmp",
    dependencies = {
      "hrsh7th/cmp-buffer",
      "hrsh7th/cmp-path",
      "hrsh7th/cmp-cmdline",
      "hrsh7th/cmp-nvim-lsp",
      "L3MON4D3/LuaSnip",
      "saadparwaiz1/cmp_luasnip",
      "neovim/nvim-lspconfig",
    },
    config = function()
      local cmp = require("cmp")
      local luasnip = require("luasnip")

      cmp.setup({
        snippet = {
          expand = function(args)
            luasnip.lsp_expand(args.body)
          end,
        },
        mapping = {
          ["<Tab>"] = cmp.mapping.select_next_item(),
          ["<S-Tab>"] = cmp.mapping.select_prev_item(),
          ["<CR>"] = cmp.mapping.confirm({ select = true }),
        },
        sources = {
          { name = "nvim_lsp" },
          { name = "path" },
          { name = "buffer" },
          { name = "luasnip" },
        },
      })

      -- Setup LSP
      local lspconfig = require("lspconfig")
      lspconfig.pyright.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
      lspconfig.clangd.setup({
        capabilities = require("cmp_nvim_lsp").default_capabilities(),
      })
    end,
  },

  -- Mason Plugins
  {
    "williamboman/mason.nvim",
    config = function()
      require("mason").setup()
    end,
  },
  {
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
    config = function()
      require("mason-lspconfig").setup({
        ensure_installed = { "pyright", "clangd" },
      })
      require("mason-lspconfig").setup_handlers({
        function(server_name)
          require("lspconfig")[server_name].setup({
            capabilities = require("cmp_nvim_lsp").default_capabilities(),
          })
        end,
      })
    end,
  },

  -- D) nvim-tree.lua (File Explorer)
  {
    "nvim-tree/nvim-tree.lua",
    dependencies = {
      "nvim-tree/nvim-web-devicons",
    },
    config = function()
      require("nvim-tree").setup({
        update_focused_file = {
          enable = true,
          update_cwd = true,
        },
        view = {
          width = 30,
        },
      })
      -- Keybinding to toggle nvim-tree
      vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>", { desc = "Toggle Nvim-Tree" })
    end,
  },
})

-- 3. General Settings
vim.opt.number = true
vim.opt.relativenumber = true
vim.g.mapleader = " "

-- Optional: Additional UI Tweaks
vim.opt.termguicolors = true
vim.opt.cursorline = true
