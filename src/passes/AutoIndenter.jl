# Takes a vector of tokens and gives back a new string
module AutoIndenter

using Compat

using Tokenize
using Tokenize.Tokens
import Tokenize.Tokens: Token, kind, startpos, endpos


type AutoIndenterSettings
    tabs::Bool
    n_spaces::Int
end


const AUTOINDENTER_SETTINGS = AutoIndenterSettings(false, 4)

start_identifiers = [kw_begin,  kw_while, kw_if, kw_for, kw_try,
                      kw_function, kw_macro, kw_quote, kw_let,
                      kw_type, kw_immutable, kw_do, kw_module, kw_baremodule]

end_identifiers = [kw_end]

# When 'd' is pressed we run the identer.
# Check that line starts with whitespace + end
# In that case, dedent the line. The julia REPL only uses spaces.
@compat function (matcher::AutoIndenterSettings)(tokens::Vector{Token}, cursorpos::Int)
    curr_line = 1
    n_startids = 0
    for token in tokens

        if kind(token) in start_identifiers
            n_startids += 1



end


end