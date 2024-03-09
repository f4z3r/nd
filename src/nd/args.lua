local argparse = require("argparse")
local date = require("date")

local utils = require("nd.utils")

local M = {}

---parse the command line arguments.
---@return table
function M.parse()
  local parser = argparse()
      :name("nd")
      :description("Time tracking tool that incorporates pomodoro timers and is plugin capable.")
      :epilog("For more information see: https://github.com/f4z3r/nd")
      :require_command(false)
      :command_target("command")

  local _ = parser:command("hello"):summary("Start tracking time for the day."):description(utils.trim_indents([[
    Starts tracking time for the day by creating a "hello" entry in the entry log
    at the current time.]]))

  local add = parser:command("add"):summary("Add a time tracking entry."):description(utils.trim_indents([[
    Adds an entry in the entry log at the current time with the argument
    provided. The argument can be any string of the correct format:

    <project>: <description>

    - <project>: is optional, can start with an '!' to ommit in the reporting.
    - <descrpition>: any string. Can contain any number of tags marked with '+'
      and at most on context marked with '@'.

    Example:
       $ nd add 'nd-project: continue improving documentation +docs +nd @home']]))

  add:argument("entry", "The entry to add. See format in command description.")

  local report = parser:command("report"):summary("Report activity for a day."):description(utils.trim_indents([[
    Print a detailed report of the activities that occured during the day provided
    as argument.]]))

  report:argument("date", "The date of the report.", date():fmt("%F"))
  report:option("-p --project", "Project to filter by.")
  report:option("-c --context", "Context to filter by.")
  report:option("-t --tag", "Tags to filter by."):count("*")

  local _ = parser:command("edit"):summary("Edit the entry log manually."):description(utils.trim_indents([[
    Launch your editor and open the entry log. This enables editing the entry log
    manually to correct errors or edit entries. The EDITOR environment variable
    defines which editor will be launched. If the variable is not defined, end will
    attempt to launch nvim.]]))

  local pomo = parser:command("pomo"):summary("Pomodoro timer."):description(utils.trim_indents([[
    Interact with the integrated pomodoro timer.]]))

  local start = pomo:command("start"):summary("Start the timer."):description(utils.trim_indents([[
    Start the pomodoro timers. This will auto-detect whether to launch a work, rest,
    or long-rest session.]]))
  start:argument("type", "Force a work or rest session."):choices({"work", "rest", "long-rest"})

  local _ = pomo:command("stop"):summary("Stop any current timer."):description(utils.trim_indents([[
    Stop any running timer. This will not mark the running timer as completed.]]))

  local _ = pomo:command("toggle"):summary("Toggle the timer."):description(utils.trim_indents([[
    Start a timer if none is running, or stop the current timer if one is running.]]))

  local _ = pomo:command("skip"):summary("Skip the current or upcoming session."):description(utils.trim_indents([[
    Skip the currently running session, marking it as completed. If no session is
    running, skip the session that would be next.]]))

  local status =
      pomo:command("status"):summary("Print the current status of the pomodoro."):description(utils.trim_indents([[
    Print the status of the running session and additional information about the day.]]))
  -- TODO set default format and document in README.
  status:argument("format", "Format in which to print the status.", "default_format")

  return parser:parse()
end

return M
