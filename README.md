OCaml script to remind me of stuff (currently only birthdays).

* Setup: cron-jobs

** Mac OS X or Linux
A naive but working example is the following:
```0 9 * * *
     ./<path-to_reminders>/reminder.native bday.csv 2> birthday_reminders.log ```