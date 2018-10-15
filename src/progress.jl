

const barchars =  ["", "▏","▎","▍","▌","▋","▊","▉","█"]


function barspec(progress, maxsubs, maxchars)
    maxpoints = maxchars * (maxsubs)
    
    @assert 0.0 <= progress <= 1.0

    points = round(Int, progress * maxpoints)
    fulls = points ÷ maxsubs
    subs = mod(points, maxsubs)
    @assert fulls <= maxchars

    (fulls, subs)
end


function baronly(progress, maxchars = 50, barchars = barchars)
    if isfinite(progress)
        progress = clamp(progress, 0.0, 1.0)

        maxsubs = length(barchars) - 1
        fulls, subs = barspec(progress, maxsubs, maxchars)
        rems = maxchars - (fulls + 1) #+1 is for the subs
        bar = barchars[end]^fulls * barchars[subs+1]
    else
        bar=string(" ", progress, " ")
    end
    @assert length(bar) <= maxchars

    rpad(bar, maxchars)
end

function format_progress(progress)
    if isfinite(progress)
        "$(round(100progress, digits=2))%"
    else
        string(progress)
    end
end


function bar(progress; maxchars = 50, barchars = barchars)
    bartext = baronly(progress, maxchars, barchars)
    "[$bartext] " * format_progress(progress)
end



function progress_message(progress_raw)
    progress_val(x) = x
    function progress_val(x::AbstractString)
        inner(::Nothing) = x
        inner(mm::RegexMatch) = parse(Float32, mm[1])/100

        inner(match(r"^\s*(\d*\.?\d*)\s*\%\s*$", x))
        # a number followed by a %, with whitespace whereever
    end

    message(x) = x
    message(x::Real) = bar(x)

    message(progress_val(progress_raw))
end


