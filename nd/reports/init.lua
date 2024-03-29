local table = require("table")
local tables = require("nd.luatables")
local utils = require("nd.utils")

local entry_log = require("nd.entry_log")
local records = require("nd.records")

local reports = {}

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
  self.records[#self.records + 1] = record
  self.total = self.total + record.duration
end

function Report:filter_project(project)
  self._filter_project = project
end

function Report:filter_context(ctx)
  self._filter_context = ctx
end

function Report:filter_tags(...)
  self._filter_tags = { ... }
end

---@private
function Report:filter()
  local recs = self.records
  if self._filter_project then
    recs = utils.filter(recs, function(record)
      return record.project == self._filter_project
    end)
  end
  if self._filter_context then
    recs = utils.filter(recs, function(record)
      return record.context == self._filter_context
    end)
  end
  if self._filter_tags then
    for _, tag in ipairs(self._filter_tags) do
      recs = utils.filter(recs, function(record)
        return record.tags:contains(tag)
      end)
    end
  end
  return recs
end

function Report:render()
  local tbl = tables.Table
    :new()
    :border()
    :border_style(tables.BorderStyle.Double)
  tbl:headers("project", "description", "context", "tags", "duration")
  local recs = self:filter()
  for _, record in ipairs(recs) do
    tbl:row(
      record.project,
      record.description,
      record.context,
      table.concat(record.tags:to_table(), ","),
      record.duration:fmt("%Hh %Mm")
    )
  end
  local durations = utils.map(recs, function(record)
    return record.duration
  end)
  local sum = utils.reduce(durations, function(acc, val)
    return acc + val
  end)
  tbl:row("total", "", "", "", sum:fmt("%Hh %Mm"))
  print(tbl:render())
end

---add a list of records to the report
---@param recs table a list of records
function Report:add_records(recs)
  for _, record in ipairs(recs) do
    self:add_record(record)
  end
end

reports.Report = Report

function reports.simple_report(raw_date, project_filter, context_filter, tag_filter)
  local entries = entry_log.get_entries(raw_date)
  if #entries < 1 then
    return
  end
  local report = Report:new()
  for idx = 2, #entries do
    local record = records.Record:new(entries[idx])
    if record.project ~= "break" then
      record:update_duration_since(entries[idx - 1])
      report:add_record(record)
    end
  end
  if project_filter then
    report:filter_project(project_filter)
  end
  if context_filter then
    report:filter_context(context_filter)
  end
  if #tag_filter > 0 then
    report:filter_tags(unpack(tag_filter))
  end
  return report
end

return reports
