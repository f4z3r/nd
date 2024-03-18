--# selene: allow(undefined_variable, incorrect_standard_library_use)

local str_utils = require("nd.utils.strings")

context("String utilities", function()
  describe("when escaping single quotes", function()
    local res = str_utils.escape_single_quotes("this is 'some' text")

    it("it should replace single quotes with their full escape", function()
      assert.are.equal("this is '\\''some'\\'' text", res)
    end)
  end)

  describe("when splitting strings into lines", function()
    local res = str_utils.split_into_lines([[
    This

    is
    some super amazing
    text

    !]])

    it("it should keep empty lines", function()
      assert.are.equal(7, #res)
      assert.are.equal("", res[2])
    end)
  end)

  describe("when trimming indent from multiline strings", function()
    local res = str_utils.trim_indents([[
    This

      is
    some super amazing
          text

    !]])

    it("it should keep empty lines and relative indent", function()
      assert.are.equal("This\n\n  is\nsome super amazing\n      text\n\n!", res)
    end)
  end)
end)
