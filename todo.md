# ToDos

## Features

### Pomodoro Caching

Currently, when a pomodoro completes, it will add the pomodoro to the last entry in the log. Entries
do however represent tasks that are already completed, so this makes little sense unless one has
pre-registered a task. It would be nicer to behave as follows:

- If the last entry in the log has a completion time in the future, add the pomodoro to that entry
  (same as current behaviour).
- If the last entry in the log is in the past, add the pomodoro to a "cache"
  (e.g. `~/.local/state/nd/pomo.log`, configurable). The next time `add` is called, the pomodoros
  from the cache are added to the new entry, and the cache is cleared.

The above approach requires to think about a couple of scenarios though:

- When someone edits the log file while the cache is populated to add a new entry, it might be
  confusing when the next time `add` is called, that the cache is added to the fresh entry. This
  might be solved by a helpful warning via logging.
- Due to manual changes, it is possible to have a populated cache and a task completion time in the
  future. Think:
  1. Completing pomodoros while last task in entry log is in the past: pomodoros are added to the
     cache.
  2. Edit the log to add a task with completion in the future.
  3. A pomodoro ends.
  In such a case, the cache *and the completed pomodoro* should be added to the latest entry in the
  log upon completion.

### Extend Command

The `extend` command should extend the last entry in the log to the current time.

Considerations:
- What if the last entry is in the future? IMO we could "truncate" it to the current time and log a
  warning. That way `extend` covers more use cases.

## Quality of Life

- [ ] allow to configure to not behave like `edit` when no command is provided. Something such as
  `ND_DEFAULT_COMMAND` that can be set in the env.
- [ ] allow to configure bell sound on notification using `ND_NOFITICATION_SOUND`.
