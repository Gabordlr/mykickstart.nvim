-- Minimal Jbuilder support for Ruby on Rails projects
return {
  -- Simple jbuilder filetype and syntax setup
  {
    'jbuilder-simple',
    name = 'jbuilder-simple',
    dir = vim.fn.stdpath('config'),
    lazy = false,
    config = function()
      -- Set up filetype detection for jbuilder files
      vim.filetype.add({
        extension = { jbuilder = 'ruby' },
        pattern = { ['.*%.json%.jbuilder$'] = 'ruby' },
      })

      -- Enhanced syntax highlighting for jbuilder files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = 'ruby',
        callback = function()
          local filename = vim.fn.expand('%:t')
          if filename:match('%.jbuilder$') or filename:match('%.json%.jbuilder$') then
            vim.cmd([[
              syntax keyword rubyJbuilderDSL json partial collection cache merge! extract! set! nil! array! object! child!
              highlight link rubyJbuilderDSL Function
            ]])
          end
        end,
      })
    end,
  },
}