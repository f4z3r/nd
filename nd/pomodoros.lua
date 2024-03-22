local table = require("table")
local utils = require("nd.utils")

local SESSION_TYPE_MAPPING = {
  work = "*",
  rest = "-",
  ["long-rest"] = "+",
}

local SYMBOL_MAPPING = utils.invert(SESSION_TYPE_MAPPING)

local pomodoros = {}

---@alias SessionType "work" | "rest" | "long-rest"

local function type_to_symbol(session)
  return SESSION_TYPE_MAPPING[session]
end

local function symbol_to_type(symbol)
  return SYMBOL_MAPPING[symbol]
end

---@class PomodoroString
---@field private _sessions SessionType[]
local PomodoroString = {}

---create a new pomodoro string
---@param sessions SessionType[]?
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
  self._sessions[#self._sessions + 1] = session
end

---create a pomodoro string object from a raw symbol string
---@param str string
---@return PomodoroString
function PomodoroString:from_str(str)
  local sessions = {}
  for i = 1, str:len() do
    sessions[#sessions + 1] = symbol_to_type(str:sub(i, i))
  end
  return PomodoroString:new(sessions)
end

---return the number of sessions of a specific type in this PomodoroString
---@param session_type SessionType
---@return integer
function PomodoroString:session_count(session_type)
  return #utils.filter(self._sessions, function(val)
    return val == session_type
  end)
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
