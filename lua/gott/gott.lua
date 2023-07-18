local util = require('gott.util')

local gott = {}

gott.get_test_list_from_file = function(file)
    local gott_cmd = "!gott -p -runFile=" .. file
    local output = util.exec(gott_cmd, false, {})
    local test_list = {}
    local pattern = string.format("([^%s]+)", "\\|")
    output:gsub(pattern,
        function(c)
            -- drop 1st and last char of c
            c = string.sub(c, 2, -2)
            test_list[#test_list + 1] = c
        end
    )
    return test_list
end

return gott
