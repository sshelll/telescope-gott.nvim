local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values

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


local get_test_list_from_file = function(file)
    local gott_cmd = string.format("!gott -print -file=%s -sub", file)
    local output = util.exec(gott_cmd, false, {})
    local test_list = {}
    local pattern = string.format("([^%s]+)", "\\|")
    _ = output:gsub(pattern,
        function(c)
            -- drop 1st and last char of c
            c = string.sub(c, 2, -2)
            test_list[#test_list + 1] = c
        end
    )
    return test_list
end

local main = function(opts)
    local current_file_path = vim.fn.expand("%:p")
    local go_tests = get_test_list_from_file(current_file_path)
    opts = opts or {}
    pickers.new(opts, {
        prompt_title = "go test list",
        finder = finders.new_table {
            results = go_tests,
        },
        previewer = conf.grep_previewer({}),
        sorter = conf.generic_sorter(opts),
    }):find()
end

return require("telescope").register_extension ({
    setup = function()
    end,
    exports = {
        gott = main
    },
})
