
function _create_juliadefault()
    cs = ColorScheme()
    symbol!(cs, ANSIToken(bold = true))
    comment!(cs, ANSIToken(bold = true))
    string!(cs, ANSIToken(bold = true))
    call!(cs, ANSIToken(bold = true))
    op!(cs, ANSIToken(bold = true))
    keyword!(cs, ANSIToken(bold = true))
    text!(cs, ANSIToken(bold = true))
    macro!(cs, ANSIToken(bold = true))
    function_def!(cs, ANSIToken(bold = true))
    error!(cs, ANSIToken(bold = true))
    argdef!(cs, ANSIToken(bold = true))
    number!(cs, ANSIToken(bold = true))
    return cs
end


# Try to represent the Monokai colorscheme.
function _create_monokai()
    cs = ColorScheme()
    symbol!(cs, ANSIToken(foreground = :magenta))
    comment!(cs, ANSIToken(foreground = :dark_gray))
    string!(cs, ANSIToken(foreground = :yellow))
    call!(cs, ANSIToken(foreground = :cyan))
    op!(cs, ANSIToken(foreground = :light_red))
    keyword!(cs, ANSIToken(foreground = :light_red))
    text!(cs, ANSIToken(foreground = :default))
    macro!(cs, ANSIToken(foreground = :cyan))
    function_def!(cs, ANSIToken(foreground = :green))
    error!(cs, ANSIToken(foreground = :default))
    argdef!(cs, ANSIToken(foreground = :cyan))
    number!(cs, ANSIToken(foreground = :magenta))
    return cs
end

function _create_monokai_256()
    cs = ColorScheme()
    symbol!(cs, ANSIToken(foreground = 141)) # purpleish
    comment!(cs, ANSIToken(foreground = 60)) # greyish
    string!(cs, ANSIToken(foreground = 208)) # beigish
    call!(cs, ANSIToken(foreground = 81)) # cyanish
    op!(cs, ANSIToken(foreground = 197)) # redish
    keyword!(cs, ANSIToken(foreground = 197)) # redish
    text!(cs, ANSIToken(foreground = :default))
    macro!(cs, ANSIToken(foreground = 208)) # cyanish
    function_def!(cs, ANSIToken(foreground = 148))
    error!(cs, ANSIToken(foreground = :default))
    argdef!(cs, ANSIToken(foreground = 81))  # cyanish
    number!(cs, ANSIToken(foreground = 141)) # purpleish
    return cs
end


function _create_boxymonokai_256()
    cs = ColorScheme()
    symbol!(cs, ANSIToken(foreground = 148))
    comment!(cs, ANSIToken(foreground = 95))
    string!(cs, ANSIToken(foreground = 148))
    call!(cs, ANSIToken(foreground = 81))
    op!(cs, ANSIToken(foreground = 158))
    keyword!(cs, ANSIToken(foreground = 141))
    text!(cs, ANSIToken(foreground = :default))
    macro!(cs, ANSIToken(foreground = 81))
    function_def!(cs, ANSIToken(foreground = 81))
    error!(cs, ANSIToken(foreground = :default))
    argdef!(cs, ANSIToken(foreground = 186))
    number!(cs, ANSIToken(foreground = 208))
    return cs
end


