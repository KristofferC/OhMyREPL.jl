import .ErrorMessages: linfos


function insert_keymap()
    global prev_er
    repl = Base.active_repl
    mirepl = isdefined(repl,:mi) ? repl.mi : repl
    main_mode = mirepl.interface.modes[1]

    D = Dict{Any, Any}()
    D["^Q"] = (s, o...) -> begin
        str = takebuf_string(Base.LineEdit.buffer(s))
        n = tryparse(Int, str)
        if isnull(n)
            write(Base.LineEdit.buffer(s), str)
            return
        else
            n = get(n, false)
            if n <= 0 || n > length(linfos) || startswith(linfos[n][1], "./REPL")
                write(Base.LineEdit.buffer(s), str)
                return
            end
            Base.edit(linfos[n][1], linfos[n][2])
            Base.LineEdit.refresh_line(s)
            return
        end
    end
    main_mode.keymap_dict = Base.LineEdit.keymap([D, main_mode.keymap_dict])
end


insert_keymap()
