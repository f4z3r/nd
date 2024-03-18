local utils = require("nd.utils")
local table = require("table")

local pomodoros = {}

---@alias SessionType "work" | "rest" | "long-rest"

local function type_to_symbol(session)
  local mapping = {
    work = "*",
    rest = "-",
    ["long-rest"] = "+",
  }
  return mapping[session]
end

---@class PomodoroString
---@field private _sessions SessionType[]
local PomodoroString = {}

---create a new pomodoro string
---@param sessions SessionType[]
---@return PomodoroString
function PomodoroString:new(sessions)
  sessions = sessions or {}
  local o = {}
  o._sessions = sessions
  setmetatable(o, self)
  self.__index = self
  return o
end

---add a session to the PomodoroString
---@param session SessionType
function PomodoroString:add(session)
  self._sessions[#self._sessions+1] = session
end

---convert the PomodoroString to a string
---@return string
function PomodoroString:to_str()
  return table.concat(utils.map(self._sessions, type_to_symbol), "")
end

---convert the PomodoroString to a string
---@param val PomodoroString
---@return string
function PomodoroString.___tostring(val)
  return val:to_str()
end

pomodoros.PomodoroString = PomodoroString

return pomodoros
