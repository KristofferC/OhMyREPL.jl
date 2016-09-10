# Error Messages

!!!warn
    This feature only works on Julia v0.5 and v0.6 time if 

`OhMyREPL` provides what can be argued to be a bit nicer error messages than Julia's default ones.

The difference between the standard error messages and the ones from `OhMyREPL` is shown below:



* Colorized error messages [0.5 only]. Will write the error messages in a bit nicer way. To disable, put `ENV["LEGACY_ERRORS"] = true` in your `.juliarc` file. Each stack frame has a number that is shown to the left. If you enter that number in the REPL and then press `Ctrl + Q` the editor will open at the line in the file of that stackframe. To set the editor to use, use for example `ENV["EDITOR"] = "subl"` for Sublime Text on linux. A demonstration of this functionality can be seen [here](https://media.giphy.com/media/3o7TKKlZrKQnWcdGTK/giphy.gif).
