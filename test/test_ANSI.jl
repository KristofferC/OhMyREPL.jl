module TestANSI

using Base.Test

using PimpMyREPL
import PimpMyREPL.ANSICodes.ANSIToken

#b = IOBuffer()
# bold, underline, strikethrough, italics, foreground, background
#print(b, ANSIToken(foreground = :magenta, italics = true))
#@test takebuf_string(b) == "\e[3;35;49m"


end # module

