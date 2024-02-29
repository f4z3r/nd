# nd

`nd` (pronounced "end") is a time tracking tool supporting the following features:

- [ ] storing worklogs with projects, tags, and descriptions
- [ ] pomodoro timer on projects
- [ ] plugins on events

## Format

```
2024-02-27 10:11 **- project: some description that describes the task +tag1 +tag2 @context
```

- `2024-02-27 10:11`: end time of the task.
- `***-`: number of completed pomodoros, running pomodoro shown with `-`
- `project`: project to book on. There are a few special projects:
  - `hello`: project that signalises the start of the day
  - `break`: project that does not get included into reporting
  - `!project`: project will be shown in reporting but does not count to total time worked
- `description`: free text to describe the task
- `+tag1`: tag to categorise tasks. Several tags can be provided.
- `@context`: provides a context for the tasks, only a single context can be provided.

## Entries

```bash
nd add "project: bla +tag @context"
```

## Reporting

```bash
nd report [<date>] [context | tag | project ...]
```

If the date is not provided, should report for the current date.
If a filter is provided, only report tasks that AND the filter.

Support reporting:

- completed pomodoros for the time range, stopped
- time table based on project, context, tag
- total time
- fully ignore tasks with `break` project
- do not include `**` into

## Pomodoro Timer

Pause explicitely not supported because it should not be paused and continued

```bash
# content description ignored on rest
nd pomo start "project: description +tag @context" [-c | --current]
nd pomo stop [-c | --current]
nd pomo toggle [-c | --current]
nd pomo show [-d | --description] [--tags] [--context] [-p | --project] [--count] [-c | --current] [-t | --type] [-f | --format]
# 23:45
```

when start ->
move end date of current task to end time and add `-`, when show is called compute this (works for
work)
for break -> move time to end of session, do not update
for stop -> move current to `+`, update end time to now


Use systemd for timer:

```bash
systemd-run --on-active="25m" --user --unit work.service /bin/touch /tmp/foo
```

Consider setting these values for the timer:

```
AccurarySec=1
WakeSystem=true
RemainAfterElapse=false
```

Notifications? -> via env var?

State stored in end log.

## Configuration

- `ND_LOG_FILE`: default `~/.local/state/nd.log`
- `ND_EVENT_PLUGINS_DIR`: default `~/.local/share/nd/event-plugins/`
   All plugins are called with JSON object for event (pomo event, report, add)
- `ND_CMD_PLUGINS_DIR`: default `~/.local/share/nd/cmd-plugins/`
   Command name taken from file name (first part before first dot), called with params and entry
   information for the day in JSON form

## JSON

Event:

```json
{
    "type": "pomodoro",
    "subtype": "work-start",
    "project": "this",
    "description": "that",
    "tags": [ "tag1", "tag2" ],
    "context": null,
    "is-break": false,
    "start-of-day": false,
    ""
}
```

