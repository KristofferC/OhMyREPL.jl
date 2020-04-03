# Prompt changing

The functions

```julia
OhMyREPL.input_prompt!(str::Union{String, Function}, color::Symbol)
OhMyREPL.output_prompt!(str::Union{String, Function}, color::Symbol)
```

can be used to change the way that the input and output prompts are displayed.

As an example, after running:

```julia
OhMyREPL.input_prompt!(">", :magenta)
OhMyREPL.output_prompt!(">", :red)
```

![](new_prompts.png)

If the first argument instead is a function, it will be run every time the prompt wants
to update which allows for more dynamic behavior.

The different possible colors can be found by typing `Base.text_colors` in the Julia REPL's help mode.

!!! hint
    You can use something like `OhMyREPL.input_prompt!(string(VERSION) * ">", :green)`
    to show which version of Julia you are currently running.

    ![](version_prompt.png)
