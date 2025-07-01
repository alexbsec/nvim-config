local M = {}

function M.open_godot_doc_in_tab()
  local params = vim.lsp.util.make_position_params()
  vim.lsp.buf_request(0, "textDocument/hover", params, function(_, result, _, _)
    if not result or not result.contents then
      vim.notify("Nenhuma documentação encontrada", vim.log.levels.WARN)
      return
    end

    local markdown_lines = vim.lsp.util.convert_input_to_markdown_lines(result.contents)
    markdown_lines = vim.lsp.util.trim_empty_lines(markdown_lines)

    if vim.tbl_isempty(markdown_lines) then
      vim.notify("Documentação vazia", vim.log.levels.WARN)
      return
    end


    for i, line in ipairs(markdown_lines) do
      -- Remove or prettify "<Native>" tags
      markdown_lines[i] = line:gsub("<Native>", "->"):gsub("@GlobalScope%.", "")
    end

    -- Cria um arquivo temporário .md
    local tmpfile = vim.fn.tempname() .. ".md"
    vim.fn.writefile(markdown_lines, tmpfile)

    -- Abre novo tab com terminal rodando glow
    vim.cmd("tabnew")
    vim.fn.termopen({ "glow", tmpfile })

    vim.bo.bufhidden = "wipe"
    vim.bo.filetype = "markdown"
    vim.bo.modifiable = false
    vim.bo.modified = false
    vim.wo.number = false
  end)
end

return M
