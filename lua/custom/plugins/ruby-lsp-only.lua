-- Completely disable solargraph and ensure proper LSP startup
return {
  {
    'neovim/nvim-lspconfig',
    config = function()
      -- Disable solargraph completely
      vim.api.nvim_create_autocmd('LspAttach', {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.name == 'solargraph' then
            print('🚫 Solargraph disabled - using ruby-lsp instead')
            vim.lsp.stop_client(client.id)
          end
        end,
      })
      
      -- Force stop any existing solargraph clients
      for _, client in ipairs(vim.lsp.get_clients()) do
        if client.name == 'solargraph' then
          vim.lsp.stop_client(client.id)
        end
      end
    end,
  },
}
