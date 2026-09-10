# Colorschemes are applied by customizing the `julia_*` StyledStrings faces that
# JuliaSyntaxHighlighting uses, which means they affect everything that goes through
# the native highlighting: REPL input, code blocks in help mode, etc.
#
# All colors are specified as 24-bit RGB; StyledStrings automatically downsamples
# to 256 or 16 colors depending on what the terminal supports.

"""
    ColorScheme(; kwargs...)

A colorscheme for the built-in REPL syntax highlighting. Every keyword argument is a
`StyledStrings.Face` (or `nothing`, the default, to leave the terminal default color):

- `symbol`: symbols (`:foo`) and `true`/`false`
- `comment`: comments
- `string`: strings, chars, cmds and regexes
- `call`: function calls
- `op`: operators and assignments
- `keyword`: keywords (`function`, `if`, ...)
- `function_def`: the name in a function definition
- `error`: syntax errors and unpaired closing brackets
- `argdef`: types and type declarations (`::T`)
- `macro_`: macro invocations (`@foo`)
- `number`: number literals

Rainbow bracket colors are derived from `argdef`, `keyword`, `string`, `call`, `op` and
`number`; for finer control set the `julia_rainbow_*` faces directly with
`StyledStrings.loadface!`.

Register and activate a scheme with [`colorscheme!`](@ref):

```julia
using StyledStrings: Face
colorscheme!("MyScheme", OhMyREPL.ColorScheme(
    keyword = Face(foreground = 0xff0000, weight = :bold),
    string  = Face(foreground = 0x00ff00),
))
```
"""
Base.@kwdef struct ColorScheme
    symbol::Union{Face, Nothing} = nothing
    comment::Union{Face, Nothing} = nothing
    string::Union{Face, Nothing} = nothing
    call::Union{Face, Nothing} = nothing
    op::Union{Face, Nothing} = nothing
    keyword::Union{Face, Nothing} = nothing
    function_def::Union{Face, Nothing} = nothing
    error::Union{Face, Nothing} = nothing
    argdef::Union{Face, Nothing} = nothing
    macro_::Union{Face, Nothing} = nothing
    number::Union{Face, Nothing} = nothing
end

# The faces a colorscheme controls. These are reset to their JuliaSyntaxHighlighting
# defaults every time a scheme is activated so that schemes do not leak into each other.
const MANAGED_FACES = [
    :julia_symbol, :julia_bool, :julia_comment, :julia_string, :julia_cmd, :julia_regex,
    :julia_funcall, :julia_operator, :julia_assignment, :julia_keyword, :julia_funcdef,
    :julia_error, :julia_type, :julia_typedec, :julia_macro, :julia_number,
    :julia_rainbow_paren_1, :julia_rainbow_paren_2, :julia_rainbow_paren_3,
    :julia_rainbow_bracket_1, :julia_rainbow_bracket_2,
    :julia_rainbow_curly_1, :julia_rainbow_curly_2,
]

function _face_pairs(cs::ColorScheme)
    pairs = Pair{Symbol, Face}[]
    add(name, face) = face === nothing || push!(pairs, name => face)
    add(:julia_symbol, cs.symbol)
    add(:julia_bool, cs.symbol)
    add(:julia_comment, cs.comment)
    # string delims and chars inherit from julia_string by default
    add(:julia_string, cs.string)
    add(:julia_cmd, cs.string)
    add(:julia_regex, cs.string)
    add(:julia_funcall, cs.call)
    add(:julia_operator, cs.op)
    add(:julia_assignment, cs.op)
    add(:julia_keyword, cs.keyword)
    add(:julia_funcdef, cs.function_def)
    # julia_unpaired_parentheses inherits from julia_error by default
    add(:julia_error, cs.error)
    add(:julia_type, cs.argdef)
    add(:julia_typedec, cs.argdef)
    add(:julia_macro, cs.macro_)
    add(:julia_number, cs.number)
    # Rainbow brackets, derived from the scheme like in old OhMyREPL versions.
    # The remaining rainbow faces inherit from these by default.
    add(:julia_rainbow_paren_1, cs.argdef)
    add(:julia_rainbow_paren_2, cs.keyword)
    add(:julia_rainbow_paren_3, cs.string)
    add(:julia_rainbow_bracket_1, cs.call)
    add(:julia_rainbow_bracket_2, cs.op)
    add(:julia_rainbow_curly_1, cs.argdef)
    add(:julia_rainbow_curly_2, cs.number)
    return pairs
end

const COLORSCHEMES = Dict{String, ColorScheme}(
    # The stock Julia 1.13 faces, i.e. only resets what other schemes may have set
    "JuliaDefault" => ColorScheme(),
    "Monokai" => ColorScheme(
        symbol = Face(foreground = 0xae81ff),
        comment = Face(foreground = 0x595959),
        string = Face(foreground = 0xe6db74),
        call = Face(foreground = 0x66d9ef),
        op = Face(foreground = 0xf92672),
        keyword = Face(foreground = 0xf92672),
        function_def = Face(foreground = 0xa6e22a),
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0x66d9ef),
        macro_ = Face(foreground = 0x66d9ef),
        number = Face(foreground = 0xae81ff),
    ),
    "BoxyMonokai" => ColorScheme(
        symbol = Face(foreground = 0xafd700),
        comment = Face(foreground = 0x875f5f),
        string = Face(foreground = 0xafd700),
        call = Face(foreground = 0x5fd7ff),
        op = Face(foreground = 0xafffd7),
        keyword = Face(foreground = 0xaf87ff),
        function_def = Face(foreground = 0x5fd7ff),
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0xd7d787),
        macro_ = Face(foreground = 0x5fd7ff),
        number = Face(foreground = 0xff8700),
    ),
    "TomorrowNightBright" => ColorScheme(
        symbol = Face(foreground = 0xb9ca4a),
        comment = Face(foreground = 0x969896),
        string = Face(foreground = 0xb9ca4a),
        call = Face(foreground = 0x70c0b1),
        op = Face(foreground = 0xffffff),
        keyword = Face(foreground = 0xc397d8),
        function_def = Face(foreground = 0x7aa6da),
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0xeeeeee),
        macro_ = Face(foreground = 0x70c0b1),
        number = Face(foreground = 0xe78c45),
    ),
    "Tomorrow" => ColorScheme(
        symbol = Face(foreground = 0x718c00),
        comment = Face(foreground = 0x8e908c),
        string = Face(foreground = 0x718c00),
        call = Face(foreground = 0x3e999f),
        keyword = Face(foreground = 0x8959a8),
        function_def = Face(foreground = 0x4271ae),
        error = Face(background = :bright_red),
        macro_ = Face(foreground = 0x3e999f),
        number = Face(foreground = 0xf5871f),
    ),
    "TomorrowDay" => ColorScheme(
        symbol = Face(foreground = 0x8959a8),
        comment = Face(foreground = 0x8e908c),
        string = Face(foreground = 0x718c00),
        call = Face(foreground = 0x4271ae),
        op = Face(foreground = 0x4271ae),
        keyword = Face(foreground = 0x8959a8),
        function_def = Face(foreground = 0xf5871f),
        error = Face(foreground = 0xc82829),
        argdef = Face(foreground = 0xbb9200),
        macro_ = Face(foreground = 0xf5871f),
        number = Face(foreground = 0xf5871f),
    ),
    "Distinguished" => ColorScheme(
        symbol = Face(foreground = 0x5f8787, weight = :bold),
        comment = Face(foreground = 0x767676),
        string = Face(foreground = 0xafaf5f),
        op = Face(foreground = 0xd7af87),
        keyword = Face(foreground = 0xd7875f),
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0x5f87af),
        macro_ = Face(foreground = 0x9e9e9e),
        number = Face(foreground = 0xd7875f),
    ),
    "OneDark" => ColorScheme(
        symbol = Face(foreground = 0xe06c75),
        comment = Face(foreground = 0x5c6370),
        string = Face(foreground = 0x98c379),
        call = Face(foreground = 0x61afef),
        op = Face(foreground = 0xc678dd),
        keyword = Face(foreground = 0xe06c75),
        function_def = Face(foreground = 0xabb2bf),
        error = Face(foreground = 0xbe5046),
        argdef = Face(foreground = 0xe5c07b),
        macro_ = Face(foreground = 0xc678dd),
        number = Face(foreground = 0xd19a66),
    ),
    "OneLight" => ColorScheme(
        symbol = Face(foreground = 0xe45649),
        comment = Face(foreground = 0x9ca0a4),
        string = Face(foreground = 0x50a14f),
        call = Face(foreground = 0x4078f2),
        op = Face(foreground = 0x0184bc),
        keyword = Face(foreground = 0xe45649),
        function_def = Face(foreground = 0xa626a4),
        error = Face(foreground = 0xe45649),
        argdef = Face(foreground = 0x986801),
        macro_ = Face(foreground = 0xa626a4),
        number = Face(foreground = 0xda8548),
    ),
    "Base16MaterialDarker" => ColorScheme(
        symbol = Face(foreground = 0xf07178),
        comment = Face(foreground = 0x4a4a4a),
        string = Face(foreground = 0xc3e88d),
        call = Face(foreground = 0x82aaff),
        op = Face(foreground = 0x89ddff),
        keyword = Face(foreground = 0xc792ea),
        function_def = Face(foreground = 0x82aaff),
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0xffcb6b),
        macro_ = Face(foreground = 0x82aaff),
        number = Face(foreground = 0xf78c6c),
    ),
    # palette https://github.com/morhetz/gruvbox#dark-mode-1
    "GruvboxDark" => ColorScheme(
        symbol = Face(foreground = 0x83a598), # blue
        comment = Face(foreground = 0x928374),
        string = Face(foreground = 0xb8bb26), # green
        call = Face(foreground = 0xebdbb2), # foreground
        op = Face(foreground = 0xebdbb2), # foreground
        keyword = Face(foreground = 0xfb4934), # red
        function_def = Face(foreground = 0xebdbb2), # foreground
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0xd79921), # yellow
        macro_ = Face(foreground = 0x8ec07c), # aqua
        number = Face(foreground = 0xd3869b), # purple
    ),
    # https://primer.style/primitives/colors#themes
    # Note: this matches "GitHub Light Default", not the legacy "GitHub Light"
    "GitHubLight" => ColorScheme(
        symbol = Face(foreground = 0x0450ae),
        comment = Face(foreground = 0x6f7781),
        string = Face(foreground = 0x0a2f69),
        call = Face(foreground = 0x0450ae),
        op = Face(foreground = 0xce222e),
        keyword = Face(foreground = 0xce222e),
        function_def = Face(foreground = 0x8250df),
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0x0450ae),
        macro_ = Face(foreground = 0x0450ae),
        number = Face(foreground = 0x0450ae),
    ),
    # Note: this matches "GitHub Dark Default", not the legacy "GitHub Dark"
    "GitHubDark" => ColorScheme(
        symbol = Face(foreground = 0x79c0ff),
        comment = Face(foreground = 0x8c949e),
        string = Face(foreground = 0xa4d7ff),
        call = Face(foreground = 0x79c0ff),
        op = Face(foreground = 0xfe7b72),
        keyword = Face(foreground = 0xfe7b72),
        function_def = Face(foreground = 0xd2a8ff),
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0x79c0ff),
        macro_ = Face(foreground = 0x79c0ff),
        number = Face(foreground = 0x79c0ff),
    ),
    "GitHubDarkDimmed" => ColorScheme(
        symbol = Face(foreground = 0x6cb6ff),
        comment = Face(foreground = 0x768390),
        string = Face(foreground = 0x96d0ff),
        call = Face(foreground = 0x6cb6ff),
        op = Face(foreground = 0xf47067),
        keyword = Face(foreground = 0xf47067),
        function_def = Face(foreground = 0xdcbdfb),
        error = Face(background = :bright_red),
        argdef = Face(foreground = 0x6cb6ff),
        macro_ = Face(foreground = 0x6cb6ff),
        number = Face(foreground = 0x6cb6ff),
    ),
    "Dracula" => ColorScheme(
        symbol = Face(foreground = 0xffb86c),
        comment = Face(foreground = 0x6272a4),
        string = Face(foreground = 0xf1fa8c),
        call = Face(foreground = 0xbd93f9),
        op = Face(foreground = 0xff79c6),
        keyword = Face(foreground = 0xff79c6),
        function_def = Face(foreground = 0xbd93f9),
        error = Face(foreground = 0xff5555),
        argdef = Face(foreground = 0x8be9fd),
        macro_ = Face(foreground = 0x50fa7b),
        number = Face(foreground = 0xff5555),
    ),
)

# Old scheme names that existed as separate 16/256/24-bit color variants; the terminal
# capability handling in StyledStrings makes the distinction unnecessary.
const COLORSCHEME_ALIASES = Dict{String, String}(
    "Monokai16" => "Monokai",
    "Monokai256" => "Monokai",
    "Monokai24bit" => "Monokai",
    "BoxyMonokai256" => "BoxyMonokai",
    "TomorrowNightBright24bit" => "TomorrowNightBright",
    "Tomorrow24bit" => "Tomorrow",
)

const DEFAULT_COLORSCHEME = "Monokai"
const ACTIVE_COLORSCHEME = Ref("JuliaDefault")

function _lookup_colorscheme(name::String)
    canonical = get(COLORSCHEME_ALIASES, name, name)
    scheme = get(COLORSCHEMES, canonical, nothing)
    if scheme === nothing
        throw(ArgumentError("colorscheme \"$name\" not found, available colorschemes: " *
                            join(sort!(collect(keys(COLORSCHEMES))), ", ")))
    end
    return canonical, scheme
end

function _activate_colorscheme(cs::ColorScheme)
    foreach(StyledStrings.resetfaces!, MANAGED_FACES)
    foreach(StyledStrings.loadface!, _face_pairs(cs))
    return
end

"""
    colorscheme!(name::String)

Activate the colorscheme `name`. Use [`colorschemes`](@ref) to list the
available colorschemes.

    colorscheme!(name::String, scheme::ColorScheme)

Register `scheme` under `name` and activate it. See [`ColorScheme`](@ref) for
how to define a scheme.
"""
function colorscheme!(name::String)
    canonical, scheme = _lookup_colorscheme(name)
    _activate_colorscheme(scheme)
    ACTIVE_COLORSCHEME[] = canonical
    return
end

function colorscheme!(name::String, scheme::ColorScheme)
    COLORSCHEMES[name] = scheme
    colorscheme!(name)
end

function _swatch(cs::ColorScheme)
    buf = Base.AnnotatedIOBuffer()
    for field in fieldnames(ColorScheme)
        face = getfield(cs, field)
        block = Base.AnnotatedString("██")
        face === nothing || Base.annotate!(block, 1:ncodeunits(block), :face, face)
        print(buf, block)
    end
    return read(seekstart(buf), Base.AnnotatedString)
end

"""
    colorschemes()

Print the available colorschemes together with a sample of their colors.
The active colorscheme is marked with an arrow.
"""
function colorschemes(io::IO = stdout)
    names = sort!(collect(keys(COLORSCHEMES)))
    width = maximum(textwidth, names)
    for name in names
        print(io, name == ACTIVE_COLORSCHEME[] ? "→ " : "  ")
        print(io, rpad(name, width + 1))
        println(io, _swatch(COLORSCHEMES[name]))
    end
end

const TEST_STR = """

function funcdef(x::Float64, y::Int64)
    y = 100_000
    x = :foo
    s = "I am a happy string"
    c = `mycmd`
    @time 1+1
    #= Comments look like this =#
    z = funccall(x, y)
    5 * 3 + 2 - 1
end
"""

"""
    test_colorscheme(name::String)
    test_colorscheme(scheme::ColorScheme)

Print a sample of highlighted Julia code using the given colorscheme, without
permanently activating it.
"""
function test_colorscheme(name::String, str::String = TEST_STR)
    test_colorscheme(last(_lookup_colorscheme(name)), str)
end

function test_colorscheme(cs::ColorScheme, str::String = TEST_STR)
    active = COLORSCHEMES[ACTIVE_COLORSCHEME[]]
    try
        _activate_colorscheme(cs)
        println(stdout, JuliaSyntaxHighlighting.highlight(str))
    finally
        _activate_colorscheme(active)
    end
    return
end
