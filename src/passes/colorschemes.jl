function _create_juliadefault()
    cs = ColorScheme()
    symbol!(cs, Crayon(bold = true))
    comment!(cs, Crayon(bold = true))
    string!(cs, Crayon(bold = true))
    call!(cs, Crayon(bold = true))
    op!(cs, Crayon(bold = true))
    keyword!(cs, Crayon(bold = true))
    text!(cs, Crayon(bold = true))
    macro!(cs, Crayon(bold = true))
    function_def!(cs, Crayon(bold = true))
    error!(cs, Crayon(bold = true))
    argdef!(cs, Crayon(bold = true))
    number!(cs, Crayon(bold = true))
    return cs
end


# Try to represent the Monokai colorscheme.
function _create_monokai()
    cs = ColorScheme()
    symbol!(cs, Crayon(foreground = :magenta))
    comment!(cs, Crayon(foreground = :dark_gray))
    string!(cs, Crayon(foreground = :yellow))
    call!(cs, Crayon(foreground = :cyan))
    op!(cs, Crayon(foreground = :light_red))
    keyword!(cs, Crayon(foreground = :light_red))
    text!(cs, Crayon(foreground = :default))
    macro!(cs, Crayon(foreground = :cyan))
    function_def!(cs, Crayon(foreground = :green))
    error!(cs, Crayon(foreground = :default))
    argdef!(cs, Crayon(foreground = :cyan))
    number!(cs, Crayon(foreground = :magenta))
    return cs
end

function _create_monokai_256()
    cs = ColorScheme()
    symbol!(cs, Crayon(foreground = 141)) # purpleish
    comment!(cs, Crayon(foreground = 60)) # greyish
    string!(cs, Crayon(foreground = 208)) # beigish
    call!(cs, Crayon(foreground = 81)) # cyanish
    op!(cs, Crayon(foreground = 197)) # redish
    keyword!(cs, Crayon(foreground = 197)) # redish
    text!(cs, Crayon(foreground = :default))
    macro!(cs, Crayon(foreground = 208)) # cyanish
    function_def!(cs, Crayon(foreground = 148))
    error!(cs, Crayon(foreground = :default))
    argdef!(cs, Crayon(foreground = 81))  # cyanish
    number!(cs, Crayon(foreground = 141)) # purpleish
    return cs
end

function _create_monokai_24()
    cs = ColorScheme()
    symbol!(cs, Crayon(foreground = (174,129,255)))
    comment!(cs, Crayon(foreground = (89, 89, 89)))
    string!(cs, Crayon(foreground = (253,151,31)))
    call!(cs, Crayon(foreground = (102,217,239)))
    op!(cs, Crayon(foreground = (249, 38, 114)))
    keyword!(cs, Crayon(foreground = (249, 38, 114)))
    text!(cs, Crayon(foreground = :default))
    macro!(cs, Crayon(foreground = (253,151,31)))
    function_def!(cs, Crayon(foreground = (166,226,42)))
    error!(cs, Crayon(foreground = :default))
    argdef!(cs, Crayon(foreground = (102,217,239)))
    number!(cs, Crayon(foreground = (174,129,255)))
    return cs
end


function _create_boxymonokai_256()
    cs = ColorScheme()
    symbol!(cs, Crayon(foreground = 148))
    comment!(cs, Crayon(foreground = 95))
    string!(cs, Crayon(foreground = 148))
    call!(cs, Crayon(foreground = 81))
    op!(cs, Crayon(foreground = 158))
    keyword!(cs, Crayon(foreground = 141))
    text!(cs, Crayon(foreground = :default))
    macro!(cs, Crayon(foreground = 81))
    function_def!(cs, Crayon(foreground = 81))
    error!(cs, Crayon(foreground = :default))
    argdef!(cs, Crayon(foreground = 186))
    number!(cs, Crayon(foreground = 208))
    return cs
end

function _create_tomorrow_night_bright()
    cs = ColorScheme()
    symbol!(cs, Crayon(foreground = 185))
    comment!(cs, Crayon(foreground = 246))
    string!(cs, Crayon(foreground = 185))
    call!(cs, Crayon(foreground = 73))
    op!(cs, Crayon(foreground = 231))
    keyword!(cs, Crayon(foreground = 140))
    text!(cs, Crayon(foreground = :default))
    macro!(cs, Crayon(foreground = 73))
    function_def!(cs, Crayon(foreground = 110))
    error!(cs, Crayon(foreground = :default))
    argdef!(cs, Crayon(foreground = 255)) # nothing special added here
    number!(cs, Crayon(foreground = 208))
    return cs
end

function _create_tomorrow_night_bright_24()
    cs = ColorScheme()
    symbol!(cs, Crayon(foreground = (185, 202, 74)))
    comment!(cs, Crayon(foreground = (150, 152, 150)))
    string!(cs, Crayon(foreground = (185, 202, 74)))
    call!(cs, Crayon(foreground = (112, 192, 177)))
    op!(cs, Crayon(foreground = (255, 255, 255)))
    keyword!(cs, Crayon(foreground = (195, 151, 216)))
    text!(cs, Crayon(foreground = :default))
    macro!(cs, Crayon(foreground = (112, 192, 177)))
    function_def!(cs, Crayon(foreground = (122, 166, 218)))
    error!(cs, Crayon(foreground = :default))
    argdef!(cs, Crayon(foreground = 255)) # nothing special added here
    number!(cs, Crayon(foreground = (231, 140, 69)))
    return cs
end


function _create_tomorrow_24()
    cs = ColorScheme()
    symbol!(cs, Crayon(foreground = (113, 140, 0)))
    comment!(cs, Crayon(foreground = (142, 144, 140)))
    string!(cs, Crayon(foreground = (113, 140, 0)))
    call!(cs, Crayon(foreground = (62, 153, 159)))
    op!(cs, Crayon(foreground = :default))
    keyword!(cs, Crayon(foreground = (137, 89, 168)))
    text!(cs, Crayon(foreground = :default))
    macro!(cs, Crayon(foreground = (62, 153, 159)))
    function_def!(cs, Crayon(foreground = (66, 113, 174)))
    error!(cs, Crayon(foreground = :default))
    argdef!(cs, Crayon(foreground = :default)) # nothing special added here
    number!(cs, Crayon(foreground = (245, 135, 31)))
    return cs
end

function _create_tomorrow_256()
    cs = ColorScheme()
    symbol!(cs, Crayon(foreground = 64))
    comment!(cs, Crayon(foreground = 102))
    string!(cs, Crayon(foreground = 64))
    call!(cs, Crayon(foreground = 67))
    op!(cs, Crayon(foreground = :default))
    keyword!(cs, Crayon(foreground = 97))
    text!(cs, Crayon(foreground = :default))
    macro!(cs, Crayon(foreground = 67))
    function_def!(cs, Crayon(foreground = 61))
    error!(cs, Crayon(foreground = :default))
    argdef!(cs, Crayon(foreground = :default)) # nothing special added here
    number!(cs, Crayon(foreground = 208))
    return cs
end
