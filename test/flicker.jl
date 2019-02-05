using OhMyREPL
import REPL
import TerminalRegressionTests

TerminalRegressionTests.automated_test(
    joinpath(@__DIR__,"flicker/simple.multiout"),
    # Test a bunch of intersting cases:
    # - Typing out keywords
    # - Inserting/deleting braces
    # - Newlines
    # and try to make sure nothing flickers
    [c for c in "function foo(a = b())\nend\n\x4"],
    aggressive_yield=true) do emuterm
    repl = REPL.LineEditREPL(emuterm, false)
    repl.specialdisplay = REPL.REPLDisplay(repl)
    repl.interface = REPL.setup_interface(repl)
    OhMyREPL.Prompt.insert_keybindings(repl)
    REPL.run_repl(repl)
end
