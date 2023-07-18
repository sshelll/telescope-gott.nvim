local util = {}

util.split = function(str, sep)
    local fields = {}
    local pattern = string.format("([^%s]+)", sep)
    str:gsub(pattern, function(c) fields[#fields + 1] = c end)
    return fields
end

util.exec = function(cmd, notify, opts)
    -- init args
    notify = notify or false
    opts = opts or {}

    -- exec cmd
    local parsedCmd = vim.api.nvim_parse_cmd(cmd, {})
    local output = vim.api.nvim_cmd(parsedCmd, { output = true })
    local splited = util.split(output, "\n")
    table.remove(splited, 1)

    if not notify then
        return table.concat(splited, "\n")
    end

    -- notify exec result
    local displayed = vim.notify(
        splited,
        vim.log.levels.INFO,
        {
            title = string.format("gott: %s", opts.title or ""),
            render = opts.render or "default",
            icon = "",
            timeout = opts.timeout or 5000,
            keep = opts.keep or function() return true end,
        }
    )
    if not displayed then
        vim.api.nvim_err_writeln(output)
    end
end

return util
