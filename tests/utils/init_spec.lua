--# selene: allow(undefined_variable, incorrect_standard_library_use)

local string = require("string")

local utils = require("nd.utils")

context("Standard utilities", function()
  describe("when inverting tables", function()
    local tbl = {
      hello = "world",
      these = "people",
    }
    local res = utils.invert(tbl)

    it("it should invert the table correctly", function()
      assert.are.same({ world = "hello", people = "these" }, res)
    end)
  end)

  describe("when applying filters to arrays", function()
    local init = {
      "this",
      "that",
      "other",
      "word",
      "things",
      "hello",
    }
    local function filter(val)
      return val:sub(1, 2) ~= "th"
    end
    local res = utils.filter(init, filter)

    it("it should filter values correctly", function()
      assert.are.same({ "other", "word", "hello" }, res)
    end)
  end)

  describe("when applying filters to tables", function()
    local init = {
      this = "this",
      that = "that",
      other = "other too",
      word = "word",
      things = "things yup",
      hello = "hello",
    }
    local function filter(key, val)
      return key ~= val
    end
    local res = utils.filter(init, filter)

    it("it should filter keys and values correctly", function()
      assert.are.same({ other = "other too", things = "things yup" }, res)
    end)
  end)

  describe("when applying maps to arrays", function()
    local init = {
      "this",
      "that",
      "other",
      "word",
      "things",
      "hello",
    }
    local function map(val)
      return string.len(val)
    end
    local res = utils.map(init, map)

    it("it should map values correctly", function()
      assert.are.same({ 4, 4, 5, 4, 6, 5 }, res)
    end)
  end)

  describe("when applying maps to tables", function()
    local init = {
      this = "this",
      that = "that",
      other = "other too",
      word = "word",
      things = "things yup",
      hello = "hello",
    }
    local function map(key, val)
      return key .. "1", string.len(val)
    end
    local res = utils.map(init, map)

    it("it should map keys and values correctly", function()
      local expected = {
        this1 = 4,
        that1 = 4,
        other1 = 9,
        word1 = 4,
        things1 = 10,
        hello1 = 5,
      }
      assert.are.same(expected, res)
    end)
  end)

  describe("when reducing arrays", function()
    local init = {
      "this",
      "that",
      "other",
      "word",
      "things",
      "hello",
    }
    local function reduce(acc, val)
      return acc .. val
    end
    local res = utils.reduce(init, reduce, "")

    it("it should reduce values correctly", function()
      assert.are.equal("thisthatotherwordthingshello", res)
    end)
  end)

  describe("when reducing tables", function()
    local init = {
      this = "this",
      that = "that",
      other = "other too",
      word = "word",
      things = "things yup",
      hello = "hello",
    }
    local function reduce(acc, key, val)
      return acc + string.len(key) + string.len(val)
    end
    local res = utils.reduce(init, reduce)

    it("it should reduce keys and values correctly", function()
      assert.are.equal(64, res)
    end)
  end)

  describe("when working with sets", function()
    local set = utils.Set:new({
      "this",
      "hello",
      "that",
      "other",
      "hello",
      "word",
      "things",
      "hello",
    })

    it("it should contain values", function()
      assert.is_true(set:contains("hello"))
      assert.is_true(set:contains("word"))
      assert.is_false(set:contains("mymy"))
      assert.is_false(set:contains("they"))
    end)

    it("it should remove duplicate values", function()
      assert.is.equal(6, set:len())
    end)

    it("it should allow to add and remove values", function()
      local set2 = utils.Set:new({
        "this",
        "hello",
        "that",
        "other",
        "hello",
        "word",
        "things",
        "hello",
      })
      set2:remove("other")
      assert.is.equal(5, set2:len())
      assert.is_false(set2:contains("other"))
      set2:insert("please")
      assert.is.equal(6, set2:len())
      assert.is_true(set2:contains("please"))
    end)
  end)
end)
