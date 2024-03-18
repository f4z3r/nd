local io = require("io")

local file = {}

---get the last line of a file, skipping a potential trailing newline
---@param filename string
---@return string the content of the last line
---@return integer the file offset where the last line starts
function file.get_last_line(filename)
  local fh = assert(io.open(filename, "r"))
  -- offset by one to skip potential trailing newline
  local file_length = fh:seek("end", -1)
  local init_position = 0
  local backtrack_offset = 1024
  if file_length > backtrack_offset then
    init_position = fh:seek("end", -backtrack_offset)
  else
    init_position = fh:seek("set")
  end
  local curr_position = init_position
  local last_line = ""
  while curr_position < file_length do
    init_position = fh:seek()
    last_line = fh:read("l")
    curr_position = fh:seek()
  end
  fh:close()
  return last_line, init_position
end

---update the last line in a file, overwriting the content of the last line
---@param filename string
---@param str string
function file.update_last_line(filename, str)
  local _, last_line_offset = file.get_last_line(filename)
  local fh = assert(io.open(filename, "r+"))
  fh:seek("set", last_line_offset)
  fh:write(str)
  fh:close()
end

return file
