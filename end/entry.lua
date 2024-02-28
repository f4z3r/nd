local io = require("io")
local config = require("end.config")
local date = require("date")

local _M = {}

function _M.add(entry)
  local out = assert(io.open(config.get_log_file(), 'a+'))
  local now = date():fmt("%Y-%m-%d %H:%M")
  out:write(string.format("\n%s %s", now, entry))
  out:close()
end

return _M
