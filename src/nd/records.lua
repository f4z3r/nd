local entry = require("nd.entry_log.entry")
local date = require("date")

local records = {}

---a log entry with an associated duration.
---@class Record:Entry
---@field duration dateObject duration of the record in minutes
local Record = entry.Entry:new()

---create a new record from a log entry.
---@param val table
---@param duration dateObject?
---@return Record
function Record:new(val, duration)
  val.duration = duration or date("00:00:00")
  setmetatable(val, self)
  self.__index = self
  return val
end

---update the duraction of the record with the timespan since the other entry
---@param other Entry
function Record:update_duration_since(other)
  self.duration = self:since(other)
end

records.Record = Record

return records
