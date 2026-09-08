return {
  'MeanderingProgrammer/render-markdown.nvim',
  enabled = false,
  dependencies = {
    'nvim-treesitter/nvim-treesitter',
    'echasnovski/mini.nvim',
  },
  ft = { 'markdown' },
  keys = {
    { '<leader>tm', '<cmd>RenderMarkdown toggle<CR>', desc = '[T]oggle [M]arkdown rendering' },
  },
  opts = {},
}
