# Terminal integration

By default, OhMyREPL will insert markers for the prompt start, input start and output start.
Many terminals can use these markers to allow you to quickly navigate between prompts in the scrollback buffer.
This feature can be turned on/off using `enable_semantic_prompt(::Bool)`.
OhMyREPL adds the markers to all REPL modes it knows about when it is loaded, and again refreshes this after a short wait.
If you add more REPL modes in the middle of your session, you can call `enable_semantic_prompt(true)` to add the markers to these modes too.
