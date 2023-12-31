-- Copyright (c) 2023 sshelll, the telescope-gott.nvim authors. All rights reserved.
-- Use of this source code is governed by a BSD-style license that can
-- be found in the LICENSE file.

local pickers = require "telescope.pickers"
local finders = require "telescope.finders"
local conf = require("telescope.config").values
local actions = require "telescope.actions"
local action_state = require "telescope.actions.state"

local ext_opt = {
    test_args = "-v -vet=off",
    timeout = 3000,
    keep = function()
        return false
    end,
    render = 'default',
    theme = 'dropdown',
    layout_config = {
        width = 0.2,
        height = 0.4,
    },
}

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
            icon = "",
            title = string.format("gott: %s", opts.title or ""),
            render = ext_opt.render or "default",
            timeout = ext_opt.timeout or 3000,
            keep = ext_opt.keep or function() return false end,
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

local run_gotest_by_name = function(test_name)
    local dir = vim.fn.expand("%:p:h")
    local gotest_cmd = string.format("!cd %s && go test %s -test.run=^%s$", dir, ext_opt.test_args, test_name)
    util.exec(gotest_cmd, true, { title = test_name })
end

local run_gotest_by_file = function()
    local file = vim.fn.expand("%:p")
    local filename = vim.fn.expand("%:t")
    local gotest_cmd = string.format("!gott -file=%s %s", file, ext_opt.test_args)
    util.exec(gotest_cmd, true, { title = string.format("Test all of %s", filename) })
end

local build_picker_opts = function()
    local theme_conf = {
        layout_config = ext_opt.layout_config,
        previewer = false,
    }
    if ext_opt.theme == 'ivy' then
        return require("telescope.themes").get_ivy(theme_conf)
    elseif ext_opt.theme == 'cursor' then
        return require("telescope.themes").get_cursor(theme_conf)
    else
        return require("telescope.themes").get_dropdown(theme_conf)
    end
end

local main = function(opts)
    local current_file_path = vim.fn.expand("%:p")
    -- check if current file is go test file
    if not string.match(current_file_path, "_test.go$") then
        print("telescope-gott: current file is not go test file")
        return
    end

    local go_tests = get_test_list_from_file(current_file_path)
    local test_all = "→ Test All"

    go_tests[#go_tests + 1] = test_all

    opts = build_picker_opts()
    pickers.new(opts, {
        prompt_title = "go test list",
        finder = finders.new_table {
            results = go_tests,
        },
        theme = "cursor",
        sorter = conf.generic_sorter(opts),
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                actions.close(prompt_bufnr)
                local selection = action_state.get_selected_entry()
                if selection[1] == test_all then
                    run_gotest_by_file()
                else
                    run_gotest_by_name(selection[1])
                end
            end)
            return true
        end,
    }):find()
end

return require("telescope").register_extension({
    setup = function(ext_config)
        ext_config = ext_config or {}
        ext_opt = vim.tbl_extend("force", ext_opt, ext_config)
    end,
    exports = {
        gott = main
    },
})
