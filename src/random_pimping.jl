
type GlobalSettings
    # If a user writes an opening bracket
    # automatically compelte it with a closing bracket
    # unless the next character is that closing bracket
    complete_brackets::Bool
end

GLOBAL_SETTINGS = GlobalSettings()


enable_complete_brackets!(x::GlobalSettings, enable::Bool) =
    x.complete_brackets = true
enable_complete_brackets!(enable::Bool) = enable_complete_brackets!(GLOBAL_SETTINGS, enable)



const REPL = Base.active_repl
const MIREPL = isdefined(REPL, :mi) ? REPL.mi : REPL
const MAIN_MODE = REPL.interface.modes[1]

set_prompt!(token::AnsiToken)
