-- shim deprecated API
if vim.lsp and vim.lsp.start then
    vim.lsp.start_client = function(config)
      return vim.lsp.start(config)
    end
  end
  
  -- 0. Leader keys (set before loading plugins)
  vim.g.mapleader      = "\\"
  vim.g.maplocalleader = "\\"
  
  -- 1. Bootstrap lazy.nvim
  local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
  if not vim.loop.fs_stat(lazypath) then
    vim.fn.system({
      "git", "clone", "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", lazypath,
    })
  end
  vim.opt.rtp:prepend(lazypath)
  
  -- 2. Plugin setup
  require("lazy").setup({
  
    ------------------------------------------------------------------
    -- A) CORE LSP STACK (load first so `require("lspconfig")` never breaks)
    ------------------------------------------------------------------
    {
      "neovim/nvim-lspconfig",
      lazy = false,
      dependencies = {
        "williamboman/mason.nvim",
        "williamboman/mason-lspconfig.nvim",
        "hrsh7th/cmp-nvim-lsp",        -- for capabilities
        "hrsh7th/nvim-cmp",            -- completion engine
        "L3MON4D3/LuaSnip",            -- snippet engine
        "saadparwaiz1/cmp_luasnip",    -- luasnips source
      },
      config = function()
        -- 1.1 Mason
        require("mason").setup()
        require("mason-lspconfig").setup({
          ensure_installed = { "pyright", "clangd", "gopls", "texlab" },
        })
        require("mason-lspconfig").setup_handlers({
          -- default handler for any server
          function(server_name)
            require("lspconfig")[server_name].setup({
              capabilities = require("cmp_nvim_lsp").default_capabilities(),
            })
          end,
        })
  
        -- 1.2 nvim-cmp
        local cmp = require("cmp")
        local luasnip = require("luasnip")
        cmp.setup({
          snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
          mapping = {
            ["<Tab>"]   = cmp.mapping.select_next_item(),
            ["<S-Tab>"] = cmp.mapping.select_prev_item(),
            ["<CR>"]    = cmp.mapping.confirm({ select = true }),
          },
          sources = {
            { name = "nvim_lsp" },
            { name = "path" },
            { name = "buffer" },
            { name = "luasnip" },
          },
        })
      end,
    },
  
    {
      "lervag/vimtex",
      ft = { "tex", "plaintex" },
      config = function()
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_compiler_method = "latexmk"
        vim.g.vimtex_compiler_latexmk = {
          build_dir  = "build",
          continuous = 1,
        }
      end,
    },
  
    {
      "nvim-treesitter/nvim-treesitter",
      build = ":TSUpdate",
      config = function()
        require("nvim-treesitter.configs").setup {
          ensure_installed = { "lua", "python", "c", "cpp", "rust" },
          highlight        = { enable = true },
          indent           = { enable = true },
        }
      end,
    },
  
    ---------------------------------------------------
    -- B) COLORS, UI, NAVIGATION & GIT
    ---------------------------------------------------
    {
      "ellisonleao/gruvbox.nvim",
      config = function()
        require("gruvbox").setup({ contrast = "hard", transparent_mode = false })
        vim.cmd.colorscheme("gruvbox")
      end,
    },
  
    {
      "nvim-telescope/telescope.nvim",
      dependencies = { "nvim-lua/plenary.nvim",
        { "nvim-telescope/telescope-fzf-native.nvim",
          build = 'cmake -S. -Bbuild -DCMAKE_BUILD_TYPE=Release && cmake --build build --config Release && cmake --install build',
          cond  = function() return vim.fn.executable("cmake")==1 end,
        },
      },
      config = function()
        local tele = require("telescope")
        tele.setup({ extensions = { fzf = { fuzzy = true, override_generic_sorter = true, override_file_sorter = true } } })
        pcall(tele.load_extension, "fzf")
        local b = require("telescope.builtin")
        vim.keymap.set("n","<leader>ff",b.find_files,{desc="Find Files"})
        vim.keymap.set("n","<leader>fg",b.live_grep,{desc="Live Grep"})
        vim.keymap.set("n","<leader>fb",b.buffers,{desc="Buffers"})
        vim.keymap.set("n","<leader>fh",b.help_tags,{desc="Help Tags"})
      end,
    },
  
    {
      "nvim-tree/nvim-tree.lua",
      dependencies = "nvim-tree/nvim-web-devicons",
      config = function()
        require("nvim-tree").setup({
          update_focused_file = { enable = true, update_cwd = true },
          view = { width = 30 },
        })
        vim.keymap.set("n","<leader>e",":NvimTreeToggle<CR>",{desc="Toggle Explorer"})
      end,
    },
  
    {
      "github/copilot.vim",
      config = function()
        vim.g.copilot_no_tab_map = true
        vim.api.nvim_set_keymap("i","<C-J>", 'copilot#Accept("<CR>")', { expr=true, silent=true })
        vim.api.nvim_set_keymap("n","<leader>cp",":Copilot panel<CR>",{silent=true})
      end,
    },
  
  })
  
  -- 3. General Settings (after plugin setup)
  vim.opt.number         = true
  vim.opt.relativenumber = true
  vim.opt.termguicolors  = true
  vim.opt.cursorline     = true
  