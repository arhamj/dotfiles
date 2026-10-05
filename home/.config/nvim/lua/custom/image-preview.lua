local M = {}
local active
local DEFAULT_ZOOM = 0.75

local function show(src)
  if active and active:valid() then
    active:close()
  end

  local placement, img
  local zoom = DEFAULT_ZOOM
  local viewer

  local function render()
    if not img or not viewer:valid() then
      return
    end
    local old_height = vim.api.nvim_buf_line_count(viewer.buf)
    local old_row = vim.api.nvim_win_get_cursor(viewer.win)[1]
    if placement then
      placement:close()
    end

    -- Fit the width, not the viewport height. Real buffer rows make the
    -- entire image scrollable, unlike an oversized virtual-line preview.
    local width = math.min(vim.api.nvim_win_get_width(viewer.win), math.ceil(img.info.size.width / Snacks.image.terminal.size().cell_width * zoom))
    -- Stay within Snacks' Unicode placeholder grid limits on both axes.
    local size = Snacks.image.util.fit(img.file, { width = math.min(width, 256), height = 256 }, { info = img.info })
    local offset = math.max(0, math.floor((vim.api.nvim_win_get_width(viewer.win) - size.width) / 2))
    local lines = {}
    for _ = 1, size.height do
      lines[#lines + 1] = string.rep(' ', offset)
    end
    vim.bo[viewer.buf].modifiable = true
    vim.api.nvim_buf_set_lines(viewer.buf, 0, -1, false, lines)
    vim.bo[viewer.buf].modifiable = false
    vim.bo[viewer.buf].modified = false

    placement = Snacks.image.placement.new(viewer.buf, src, {
      inline = true,
      conceal = true,
      pos = { 1, offset },
      range = { 1, offset, size.height, offset },
      width = size.width,
      height = size.height,
    })
    local row = math.max(1, math.min(size.height, math.floor((old_row - 1) / old_height * size.height) + 1))
    vim.api.nvim_win_set_cursor(viewer.win, { row, 0 })
  end

  viewer = Snacks.win {
    width = 0.9,
    height = 0.9,
    enter = true,
    border = 'rounded',
    title = ' Diagram preview ',
    footer = ' j/k: scroll  Ctrl-d/u: page  +/-: zoom  0: reset  q/Esc: close ',
    text = 'Rendering preview...',
    bo = { buftype = 'nofile', modifiable = false, swapfile = false },
    wo = { conceallevel = 2, concealcursor = 'nvic', scrolloff = 3, cursorline = false, winblend = 0 },
    keys = {
      q = 'close',
      ['<Esc>'] = 'close',
      ['+'] = function()
        zoom = math.min(4, zoom * 1.25)
        render()
      end,
      ['-'] = function()
        zoom = math.max(0.25, zoom / 1.25)
        render()
      end,
      ['0'] = function()
        zoom = DEFAULT_ZOOM
        render()
      end,
      ['<Up>'] = function()
        vim.cmd 'normal! k'
      end,
      ['<Down>'] = function()
        vim.cmd 'normal! j'
      end,
    },
    on_close = function()
      if placement then
        placement:close()
      end
      if active == viewer then
        active = nil
      end
    end,
  }
  active = viewer
  viewer:on('VimResized', function()
    vim.schedule(render)
  end)

  local conversion = Snacks.image.convert.convert {
    src = src,
    on_done = vim.schedule_wrap(function(result)
      if not viewer:valid() then
        return
      end
      if result:error() then
        local message = result:error():gsub('\n%s+at .*$', '')
        vim.bo[viewer.buf].modifiable = true
        vim.api.nvim_buf_set_lines(viewer.buf, 0, -1, false, vim.split('Preview failed\n\n' .. message, '\n'))
        vim.bo[viewer.buf].modifiable = false
        vim.bo[viewer.buf].modified = false
        return
      end
      img = Snacks.image.image.new(src)
      render()
    end),
  }
  conversion:run()
end

function M.open()
  Snacks.image.doc.at_cursor(function(src)
    if not src then
      vim.notify('Place the cursor inside a Mermaid block or on an image', vim.log.levels.INFO)
      return
    end
    Snacks.image.terminal.detect(function()
      if not Snacks.image.terminal.env().placeholders then
        vim.notify('Scrollable previews require Kitty graphics in Ghostty or Herdr', vim.log.levels.WARN)
        return
      end
      show(src)
    end)
  end)
end

return M
