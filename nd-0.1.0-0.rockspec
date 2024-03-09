local package_name = "nd"
local package_version = "0.1.0"
local rockspec_revision = "0"
local github_account_name = "f4z3r"
local github_repo_name = package_name

rockspec_format = "3.0"
package = package_name
version = package_version .. "-" .. rockspec_revision

source = {
  url = "git://github.com/" .. github_account_name .. "/" .. github_repo_name .. ".git",
}

if package_version == "scm" then
  source.branch = "master"
else
  source.tag = "v" .. package_version
end

description = {
  -- summary = 'Elegant Lua unit testing',
  -- detailed = [[
  --   An elegant, extensible, testing framework.
  --   Ships with a large amount of useful asserts,
  --   plus the ability to write your own. Output
  --   in pretty or plain terminal format, JSON,
  --   or TAP for CI integration. Great for TDD
  --   and unit, integration, and functional tests.
  -- ]],
  -- homepage = "https://lunarmodules.github.io/busted/",
  -- license = 'MIT <http://opensource.org/licenses/MIT>'
}

dependencies = {
  "lua == 5.1",
  "luatext >= 1.0",
  "lua-path >= 0.3",
  "date >= 2.2",
  "luatables >= 0.1",
}

test_dependencies = {
  "busted >= 2.0",
}

test = {
  type = "busted",
}

build = {
  type = "builtin",
  modules = {
    ["nd"]                      = "nd/init.lua",
    ["nd.args"]                 = "nd/args.lua",
    ["nd.config"]               = "nd/config.lua",
    ["nd.luatext"]              = "nd/luatext.lua",
    ["nd.records"]              = "nd/records.lua",
    ["nd.timer"]                = "nd/timer.lua",

    ["nd.utils"]                = "nd/utils/init.lua",
    ["nd.utils.strings"]        = "nd/utils/strings.lua",

    ["nd.entry_log"]            = "nd/entry_log/init.lua",
    ["nd.entry_log.entry"]      = "nd/entry_log/entry.lua",

    ["nd.reports"]              = "nd/reports/init.lua",

    ["nd.commands"]             = "nd/commands/init.lua",
    ["nd.commands.add"]         = "nd/commands/add.lua",
    ["nd.commands.complete"]    = "nd/commands/complete.lua",
    ["nd.commands.edit"]        = "nd/commands/edit.lua",
    ["nd.commands.hello"]       = "nd/commands/hello.lua",
    ["nd.commands.pomo"]        = "nd/commands/pomo/init.lua",
    ["nd.commands.pomo.start"]  = "nd/commands/pomo/start.lua",
    ["nd.commands.pomo.skip"]   = "nd/commands/pomo/skip.lua",
    ["nd.commands.pomo.stop"]   = "nd/commands/pomo/stop.lua",
    ["nd.commands.pomo.status"] = "nd/commands/pomo/status.lua",
    ["nd.commands.pomo.toggle"] = "nd/commands/pomo/toggle.lua",
  },
  install = {
    bin = {
      ["nd"] = "bin/nd",
    },
  },
}
