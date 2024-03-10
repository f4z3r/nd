# nd

> [!CAUTION]
> This is not ready to be used. The code is not yet properly refactored, and test coverage is
> abysmal.

`nd` (pronounced "end") is a time tracking tool supporting the following features:

- Storing worklogs with projects, tags, and descriptions.
- A file format that is fully text-based so that it can be edited manually.
- Full reporting capabilities on the time worked.
- A pomodoro timer which assigns pomodoros to specific tasks.

## Installation

This tool targets LuaJIT, and thus only supports Lua version 5.1. There is currently no plans to
extend the compatibility of the tool beyond that version.

Moreover the tool has a few external dependencies:

- `systemd`: used for the pomodoro timers.
- `libnotify`: used via `send-notify` for notifications.
- `aplay`: used to play notification sounds.

> [!NOTE]
> I currently do not provide installation instructions as this is not stable. Once the tool becomes
> stable, I will add instructions here.

## Usage

For information about how to use `nd`, use the `--help` options to get information about the
possible commands and arguments:

```sh
nd -h
```

```
Usage: nd [-h] [--completion {bash,zsh,fish}] [<command>] ...

Time tracking tool that incorporates pomodoro timers and is plugin capable.

Options:
   -h, --help            Show this help message and exit.
   --completion {bash,zsh,fish}
                         Output a shell completion script for the specified shell.

Commands:
   hello                 Start tracking time for the day.
   add                   Add a time tracking entry.
   edit                  Edit the entry log manually.
   report                Report activity for a day.
   pomo                  Pomodoro timer.

For more information see: https://github.com/f4z3r/nd
```

> If no command is provided to `nd`, it will behave like `edit`.

## File Format

`nd` uses a single log file as its source of truth for the amount worked. By default, that file is
located at `~/.local/state/nd/nd.log`. It can be edited using the `nd edit` command.

This log file contains entries as follows:

```
2024-03-09 16:45 *-*+*- GH-123: add tests for nd.commands module +oss +nd @home
```

Such a log line consist of the following parts:

- `2024-03-09 16:45`: A timestamp representing the *end* of the task.
- `*-*+*-`: (optional) A pomodoro string. This pomodoro string represents how many pomodoros were
  completed during that task. A `*` represents a work session, a `-` rest session, and a `+` long
  rest session.
- `GH-123:`: (optional) A project to which this task is assigned to.
- `add tests for nd.commands module +oss +nd @home`: A description of the task. Such a description
  *can* contain:
  - A *single* context marked with `@`.
  - A set of tags marked with `+`
  The location of the context and tags within the description is not relevant.

## Configuration

`nd` is configured via environment variables:

- `ND_LOG_FILE`: (default: `~/.local/state/nd/nd.log`) the location of the log file.
- `EDITOR`: (default: `nvim`) the editor to use when opening the log file via `nd edit`.

## Development

### Building

You can package the Lua rock locally using:

```sh
just build
```

### Testing

Testing is performed via `busted`. It can be launched manually or via the `just` command:

```sh
just test
```

### Roadmap

For smaller things that I want to fix, see [`todo.md`](./todo.md).

The following larger changes are being considered for `nd`:
- A plugin system. This should allow to add custom code to both extend the tool with more commands,
  but also run custom code on some events (such as when pomodoros complete).
- Should the configuration potential increase, configuration via a standard configuration file might
  make sense.
