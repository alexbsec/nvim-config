local M = {}

function M.open_definition_in_split()
    local params = vim.lsp.util.make_position_params()
    vim.lsp.buf_request(0, "textDocument/definition", params, function(_, result, _, _)
        if not result or vim.tbl_isempty(result) then
            vim.notify("No definition found!", vim.log.levels.WARN)
            return
        end

        local target = result[1] or result
        local uri = target.uri or target.targetUri
        local range = target.range or target.targetRange

        -- Set split direction to open below
        vim.cmd("belowright split " .. vim.uri_to_fname(uri))
        vim.api.nvim_win_set_cursor(0, { range.start.line + 1, range.start.character })
    end)
end

return M
