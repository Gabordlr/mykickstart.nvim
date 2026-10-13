-- Ensure TypeScript LSP always starts for JavaScript files
return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Autocommand to ensure TypeScript LSP starts for JS files
      vim.api.nvim_create_autocmd('FileType', {
        pattern = { 'javascript', 'typescript', 'javascriptreact', 'typescriptreact' },
        callback = function()
          -- Check if ts_ls is already attached
          local clients = vim.lsp.get_clients({ bufnr = 0, name = 'ts_ls' })
          if #clients == 0 then
            -- Start ts_ls if not already running
            vim.cmd('LspStart ts_ls')
            print('✅ TypeScript LSP started for ' .. vim.bo.filetype)
          end
        end,
      })
    end,
  },
}
