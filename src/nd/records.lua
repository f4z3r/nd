local entry_log = require("nd.entry_log")

local M = {}

---a log entry with an associated duration.
---@class Record:Entry
---@field entry Entry entry providing context to the record
---@field duration dateObject duration of the record in minutes
local Record = entry_log.Entry:new()

---create a new record from a log entry.
---@param entry table
---@param duration number?
---@return Record
function Record:new(entry, duration)
  entry.duration = duration or 0
  setmetatable(entry, self)
  self.__index = self
  return entry
end

---update the duraction of the record with the timespan since the other entry
---@param other Entry
function Record:update_duration_since(other)
  self.duration = self:since(other)
end

M.Record = Record

return M
