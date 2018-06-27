module TestRainbowBrackets
using OhMyREPL

import OhMyREPL.Passes.RainbowBrackets.RAINBOWBRACKETS_SETTINGS

str = "(([[]] [[  {{ }}]])) ]] )) }}"
OhMyREPL.Passes.RainbowBrackets.activate_256colors()

OhMyREPL.test_pass(stdout, RAINBOWBRACKETS_SETTINGS, str)
println()
OhMyREPL.Passes.RainbowBrackets.activate_16colors()
OhMyREPL.test_pass(stdout, RAINBOWBRACKETS_SETTINGS, str)

end
