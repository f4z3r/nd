local string = require("string")

local entry_log = require("nd.entry_log")
local records = require("nd.records")

local M = {}

local Report = {}

function Report:new()
  local o = {
    records = {},
    projects_sum = {},
    context_sum = {},
    tag_sum = {},
    total = 0,
  }
  setmetatable(o, self)
  self.__index = self
  return o
end

---add a record to the report
---@param record Record
function Report:add_record(record)
  self.records[#self.records+1] = record
  self.total = self.total + record.duration
end

function Report:render()
  print(string.format("Found %d records", #self.records))
  print(string.format("Total time: %d minutes", self.total))
end

M.Report = Report


function M.simple_report(raw_date)
  local entries = entry_log.get_entries(raw_date)
  if #entries < 1 then
    print("nothing to report")
    return
  end
  local report = Report:new()
  for idx = 2, #entries do
    local record = records.Record:new(entries[idx])
    record:update_duration_since(entries[idx-1])
    report:add_record(record)
  end
  report:render()
end


return M
