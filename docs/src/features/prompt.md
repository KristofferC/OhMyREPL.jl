# Prompt changing

The functions

```julia
OhMyREPL.input_prompt!(str::String, color::Symbol)
OhMyREPL.output_prompt!(str::String, color::Symbol)
```

can be used to change the way that the input and output prompts are displayed.

As an example, after running:

```julia
OhMyREPL.input_prompt!(">", :blue)
OhMyREPL.output_prompt!(">", :red)
```

![](new_prompts.png)

The different possible colors can be found by typing `Base.text_colors` in the Julia REPL's help mode.

!!! hint
    You can use something like `OhMyREPL.input_prompt!(string(VERSION) * ">", :green)`
    to show which version of Julia you are currently running.

    ![](version_prompt.png)