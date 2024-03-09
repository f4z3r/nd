local os = require("os")

local date = require("date")

local reports = require("nd.reports")
local str_utils = require("nd.utils.strings")

local report = {}

function report.register_command(parser)
  local report_parser =
    parser:command("report"):summary("Report activity for a day."):description(str_utils.trim_indents([[
    Print a detailed report of the activities that occured during the day provided
    as argument.]]))

  report_parser:argument("date", "The date of the report.", date():fmt("%F"))
  report_parser:option("-p --project", "Project to filter by.")
  report_parser:option("-c --context", "Context to filter by.")
  report_parser:option("-t --tag", "Tags to filter by."):count("*")
end

function report.execute(options)
  local rep = reports.simple_report(options.date, options.project, options.context, options.tag)
  if rep == nil then
    print("nothing to report")
    os.exit(1)
  end
  print(rep:render())
end

return report
