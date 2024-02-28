local entry_log = require("end.entry_log")

describe("Entries in the log file", function()
  describe("support parsing and", function()
    it("should parse a very simple base case", function()
      local val = entry_log.Entry.from_str("2024-02-28 11:00 hello")
      assert.are.equal(nil, val.context)
      assert.are.equal(28, val.timestamp:getday())
      assert.are.equal(11, val.timestamp:gethours())
      assert.are.same({}, val.tags)
    end)

    it("should support parsing multiple tags", function()
      local val = entry_log.Entry.from_str("2024-02-28 11:00 hello +tag1 +tag2")
      assert.are.same({ "tag1", "tag2" }, val.tags)
    end)

    it("should support parsing a context", function()
      local val = entry_log.Entry.from_str("2024-02-28 11:00 hello @context")
      assert.are.equal("context", val.context)
    end)

    it("should support parsing a pomodoros", function()
      local val = entry_log.Entry.from_str("2024-02-28 11:00 hello @context")
      assert.are.equal("", val.pomo_str)
      val = entry_log.Entry.from_str("2024-02-28 11:00 **- hello @context")
      assert.are.equal("**-", val.pomo_str)
      val = entry_log.Entry.from_str("2024-02-28 11:00 * hello @context")
      assert.are.equal("*", val.pomo_str)
    end)

    it("should support parsing a project", function()
      local val = entry_log.Entry.from_str("2024-02-28 11:00 hello @context")
      assert.are.equal(nil, val.project)
      val = entry_log.Entry.from_str("2024-02-28 11:00 **- hello @context")
      assert.are.equal(nil, val.project)
      val = entry_log.Entry.from_str("2024-02-28 11:00 * project: description @context")
      assert.are.equal("project", val.project)
      val = entry_log.Entry.from_str("2024-02-28 11:00 * !project: description @context")
      assert.are.equal("project", val.project)
    end)

    it("should support parsing a description", function()
      local val = entry_log.Entry.from_str("2024-02-28 11:00 hello @context")
      assert.are.equal("hello @context", val.description)
      val = entry_log.Entry.from_str("2024-02-28 11:00 **- hello @context")
      assert.are.equal("hello @context", val.description)
      val = entry_log.Entry.from_str("2024-02-28 11:00 * project: description @context")
      assert.are.equal("description @context", val.description)
      val = entry_log.Entry.from_str("2024-02-28 11:00 * !project: description @context")
      assert.are.equal("description @context", val.description)
      val = entry_log.Entry.from_str("2024-02-28 11:00 project: description @context")
      assert.are.equal("description @context", val.description)
    end)
  end)

  describe("support actions", function()
    it("such as returning the pomodoro count", function()
      local val = entry_log.Entry.from_str("2024-02-28 11:00 **- hello @context")
      assert.are.equal(2, val:pomodoros())
      val = entry_log.Entry.from_str("2024-02-28 11:00 - hello @context")
      assert.are.equal(0, val:pomodoros())
      val = entry_log.Entry.from_str("2024-02-28 11:00 hello @context")
      assert.are.equal(0, val:pomodoros())
      val = entry_log.Entry.from_str("2024-02-28 11:00 * hello @context")
      assert.are.equal(1, val:pomodoros())
    end)
  end)
end)