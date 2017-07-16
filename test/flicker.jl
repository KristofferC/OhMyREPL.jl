using OhMyREPL

include(Pkg.dir("VT100","test","TerminalRegressionTests.jl"))

const thisdir = dirname(@__FILE__)
TerminalRegressionTests.automated_test(
    joinpath(thisdir,"flicker/simple.multiout"),
    # Test a bunch of intersting cases:
    # - Typing out keywords
    # - Inserting/deleting braces
    # - Newlines
    # and try to make sure nothing flickers
    [c for c in "function foo(a = b())\nend\n\x4"],
    aggressive_yield=true) do emuterm
    repl = Base.REPL.LineEditREPL(emuterm)
    repl.specialdisplay = val->display(Base.REPL.REPLDisplay(repl), val)
    repl.interface = Base.REPL.setup_interface(repl)
    OhMyREPL.Prompt.insert_keybindings(repl)
    Base.REPL.run_repl(repl)
end
