using OhMyREPL
using Test
using StyledStrings: StyledStrings, Face, getface, SimpleColor
import JuliaSyntaxHighlighting

@testset "colorscheme activation" begin
    @test_throws ArgumentError colorscheme!("NotAColorScheme")
    @test_throws ArgumentError test_colorscheme("NotAColorScheme")

    # all schemes and legacy alias names can be activated
    for name in [collect(keys(OhMyREPL.COLORSCHEMES)); collect(keys(OhMyREPL.COLORSCHEME_ALIASES))]
        colorscheme!(name)
    end

    colorscheme!("Monokai")
    @test getface(:julia_string).foreground == SimpleColor(0xe6db74)
    @test getface(:julia_keyword).foreground == SimpleColor(0xf92672)
    @test getface(:julia_bool).foreground == SimpleColor(0xae81ff)
    # rainbow faces derive from the scheme
    @test getface(:julia_rainbow_paren_2).foreground == SimpleColor(0xf92672)
    @test getface(:julia_rainbow_curly_2).foreground == SimpleColor(0xae81ff)

    # switching schemes does not leak attributes from the previous one
    colorscheme!("Distinguished")
    @test getface(:julia_symbol).weight == :bold
    colorscheme!("Monokai")
    @test getface(:julia_symbol).weight == :normal

    # legacy alias
    colorscheme!("Monokai256")
    @test OhMyREPL.ACTIVE_COLORSCHEME[] == "Monokai"

    # JuliaDefault restores the stock faces
    colorscheme!("JuliaDefault")
    @test getface(:julia_string).foreground == SimpleColor(:green)
    @test getface(:julia_keyword).foreground == SimpleColor(:red)
end

@testset "custom colorschemes" begin
    colorscheme!("MyScheme", OhMyREPL.ColorScheme(string = Face(foreground = 0x123456)))
    @test OhMyREPL.ACTIVE_COLORSCHEME[] == "MyScheme"
    @test getface(:julia_string).foreground == SimpleColor(0x123456)
    # unset fields fall back to the defaults
    @test getface(:julia_keyword).foreground == SimpleColor(:red)
end

@testset "test_colorscheme" begin
    colorscheme!("Monokai")
    for name in sort!(collect(keys(OhMyREPL.COLORSCHEMES)))
        test_colorscheme(name)
    end
    # the active scheme is restored afterwards
    @test getface(:julia_string).foreground == SimpleColor(0xe6db74)
    test_colorscheme(OhMyREPL.ColorScheme(string = Face(foreground = 0x654321)))
    @test getface(:julia_string).foreground == SimpleColor(0xe6db74)
end

@testset "colorschemes listing" begin
    io = IOBuffer()
    colorschemes(io)
    output = String(take!(io))
    for name in keys(OhMyREPL.COLORSCHEMES)
        @test occursin(name, output)
    end
end

@testset "enable_pass! compat shims" begin
    @test JuliaSyntaxHighlighting.RAINBOW_DELIMITERS_ENABLED[]
    OhMyREPL.enable_pass!("RainbowBrackets", false)
    @test !JuliaSyntaxHighlighting.RAINBOW_DELIMITERS_ENABLED[]
    OhMyREPL.enable_pass!("RainbowBrackets", true)
    @test JuliaSyntaxHighlighting.RAINBOW_DELIMITERS_ENABLED[]

    OhMyREPL.enable_pass!("SyntaxHighlighter", false)
    @test OhMyREPL.STYLE_INPUT[] === false
    OhMyREPL.enable_pass!("SyntaxHighlighter", true)
    @test OhMyREPL.STYLE_INPUT[] === true

    @test_logs (:warn,) OhMyREPL.enable_pass!("SomeUnknownPass", true)
end

@testset "option toggles" begin
    enable_autocomplete_brackets(false)
    @test OhMyREPL.AUTO_BRACKETS[] === false
    enable_autocomplete_brackets(true)
    @test OhMyREPL.AUTO_BRACKETS[] === true

    @test_logs (:warn,) enable_fzf(false)
    @test_logs (:warn,) enable_highlight_markdown(false)
end
