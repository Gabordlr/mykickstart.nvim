-- autopairs
-- https://github.com/windwp/nvim-autopairs

return {
  'windwp/nvim-autopairs',
  event = 'InsertEnter',
  -- Optional dependency
  dependencies = { 'hrsh7th/nvim-cmp' },
  config = function()
    local npairs = require('nvim-autopairs')
    local Rule = require('nvim-autopairs.rule')
    local cond = require('nvim-autopairs.conds')
    
    npairs.setup {
      check_ts = true,
      ts_config = {
        lua = { 'string', 'source' },
        javascript = { 'string', 'template_string' },
        java = false,
      },
      disable_filetype = { 'TelescopePrompt', 'spectre_panel' },
      fast_wrap = {
        map = '<M-e>',
        chars = { '{', '[', '(', '"', "'" },
        pattern = string.gsub([[ [%'%"%)%>%]%)%}%,] ]], '%s+', ''),
        offset = 0,
        end_key = '$',
        keys = 'qwertyuiopzxcvbnmasdfghjkl',
        check_comma = true,
        highlight = 'PmenuSel',
        highlight_grey = 'LineNr',
      },
    }

    -- HTML and ERB auto-closing tags
    -- Rule for HTML tags: <tag> -> <tag></tag>
    npairs.add_rules({
      Rule('<', '>', { 'html', 'erb', 'eruby', 'vue', 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' })
        :with_pair(function(opts)
          -- Don't pair if the next character is already >
          if opts.next_char == '>' then
            return false
          end
          -- Don't pair if we're in a comment or string
          local line = opts.line
          local col = opts.col
          -- Simple check for self-closing tags
          if line:sub(col - 1, col - 1):match('[%w]') then
            return true
          end
          return false
        end)
        :with_move(cond.none())
        :with_del(cond.none())
        :use_key('>'),
      
      -- Rule for ERB tags: <% -> <% %>
      Rule('<%', '%>', { 'erb', 'eruby' })
        :with_pair(cond.not_after_regex('%%'))
        :with_move(cond.none())
        :with_del(cond.none()),
      
      -- Rule for ERB output tags: <%= -> <%= %>
      Rule('<%=', '%>', { 'erb', 'eruby' })
        :with_pair(cond.not_after_regex('%%'))
        :with_move(cond.none())
        :with_del(cond.none()),
    })

    -- Custom function to handle HTML tag completion
    local function html_tag_completion()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      local before_cursor = line:sub(1, col)
      
      -- Match opening tag like <h1>, <div>, etc.
      local tag = before_cursor:match('<([%w%-]+)[^>]*>$')
      if tag and not tag:match('^[%u]') then -- Avoid self-closing tags like <BR>
        -- Check if it's not a self-closing tag
        local self_closing = { 'area', 'base', 'br', 'col', 'embed', 'hr', 'img', 'input', 'link', 'meta', 'param', 'source', 'track', 'wbr' }
        local is_self_closing = false
        for _, self_tag in ipairs(self_closing) do
          if tag:lower() == self_tag then
            is_self_closing = true
            break
          end
        end
        
        if not is_self_closing then
          local closing_tag = '</' .. tag .. '>'
          vim.api.nvim_put({ closing_tag }, 'c', false, true)
          -- Move cursor back inside the tags
          vim.api.nvim_win_set_cursor(0, { vim.api.nvim_win_get_cursor(0)[1], col })
        end
      end
    end

    -- Set up autocommand for HTML tag completion
    vim.api.nvim_create_autocmd('FileType', {
      pattern = { 'html', 'erb', 'eruby', 'vue', 'typescript', 'javascript', 'typescriptreact', 'javascriptreact' },
      callback = function()
        vim.keymap.set('i', '>', function()
          vim.api.nvim_feedkeys('>', 'n', false)
          vim.schedule(html_tag_completion)
        end, { buffer = true })
      end,
    })

    -- If you want to automatically add `(` after selecting a function or method
    local cmp_autopairs = require 'nvim-autopairs.completion.cmp'
    local cmp = require 'cmp'
    cmp.event:on('confirm_done', cmp_autopairs.on_confirm_done())
  end,
}
