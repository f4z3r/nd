--# selene: allow(undefined_variable, incorrect_standard_library_use)

local date = require("date")

local entry = require("nd.entry_log.entry")
local records = require("nd.records")

context("Given records,", function()
  describe("when they are directly created via entries, they", function()
    local ent = entry.Entry.from_str("2024-02-28 11:00 - !project: description @context")
    local record = records.Record:new(ent, date("00:05:00"))
    it("should behave like normal entries", function()
      assert.are.equal("context", record.context)
      assert.are.equal(28, record.timestamp:getday())
      assert.are.equal(11, record.timestamp:gethours())
      assert.is_true(record.tags:is_empty())
      assert.are.equal(5, record.duration:spanminutes())
    end)
  end)

  describe("when they are updating their duractions, they", function()
    local entry1 = entry.Entry.from_str("2024-02-28 11:00 !project: description @context")
    local entry2 = entry.Entry.from_str("2024-02-28 12:30 other")
    local record = records.Record:new(entry2)
    record:update_duration_since(entry1)
    it("should use the correct timespan", function()
      assert.are.equal(90, record.duration:spanminutes())
    end)
  end)
end)
