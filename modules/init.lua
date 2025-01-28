local script_dir = debug.getinfo(1, "S").source:match("^@?(.*[\\|/])")

package.path = package.path .. ";" .. script_dir .. "?.lua"
package.cpath = package.cpath .. ";" .. script_dir .. "?.dll"
package.cpath = package.cpath .. ";" .. script_dir .. "?.so"

return {
    async = require("async"),
    http = require("http"),
    my_mod = require("my_mod"),
}