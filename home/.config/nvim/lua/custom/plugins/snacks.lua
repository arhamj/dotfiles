return {
  'folke/snacks.nvim',
  priority = 1000,
  lazy = false,
  init = function()
    -- Snacks compares the incoming filename to Neovim's resolved buffer name.
    -- For symlinks (including macOS /tmp), retry its detector with the real name.
    vim.filetype.add {
      pattern = {
        ['.+'] = {
          function(path, buf)
            if not buf then
              return
            end
            local name = vim.fs.normalize(vim.api.nvim_buf_get_name(buf))
            if path ~= name and vim.uv.fs_realpath(path) == name and vim.filetype.match { buf = buf } == 'bigfile' then
              return 'bigfile'
            end
          end,
          { priority = math.huge },
        },
      },
    }
  end,
  opts = function()
    -- Homebrew's Mermaid CLI does not bundle a browser. Reuse the Chrome
    -- installation managed by these dotfiles, while honoring user overrides.
    local chrome = '/Applications/Google Chrome.app/Contents/MacOS/Google Chrome'
    if not vim.env.PUPPETEER_EXECUTABLE_PATH and vim.fn.executable(chrome) == 1 then
      vim.env.PUPPETEER_EXECUTABLE_PATH = chrome
    end

    return {
      bigfile = { enabled = true },
      quickfile = { enabled = true },
      input = { enabled = true },
      image = {
        enabled = true,
        doc = { enabled = false, inline = false, float = false },
        math = { enabled = false },
        -- The manual preview displays conversion errors in its own window.
        convert = { notify = false },
      },
    }
  end,
  keys = {
    {
      '<leader>mp',
      function()
        require('custom.image-preview').open()
      end,
      desc = 'Preview Mermaid diagram / image (scroll and zoom)',
    },
    {
      '<leader>bd',
      function()
        Snacks.bufdelete()
      end,
      desc = 'Close / delete buffer (keep splits)',
    },
    {
      '<leader>gg',
      function()
        Snacks.lazygit()
      end,
      desc = 'Open LazyGit',
    },
    {
      '<leader>gB',
      function()
        Snacks.gitbrowse()
      end,
      mode = { 'n', 'x' },
      desc = 'Open file / selected lines in browser (GitHub / GitLab)',
    },
  },
}
