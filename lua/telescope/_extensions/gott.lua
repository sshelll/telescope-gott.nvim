local gott = require('gott.gott')

local go_tests = gott.get_test_list_from_file("/Users/shaojiale/go/src/github.com/sshelll/gott/core/mock_test.go")
for _, v in ipairs(go_tests) do
    print(string.format("%s,", v))
end
