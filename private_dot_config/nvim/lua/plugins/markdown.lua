return {
    'MeanderingProgrammer/render-markdown.nvim',
    dependencies = { 'nvim-treesitter/nvim-treesitter', 'echasnovski/mini.nvim' },
    ---@module 'render-markdown'
    ---@type render.md.UserConfig
    opts = {},
    init = function()
      vim.treesitter.language.register('markdown', 'vimwiki')
      require('render-markdown').setup({
        file_types = { 'markdown', 'vimwiki' },
      })
    end
}
