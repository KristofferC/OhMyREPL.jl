using Documenter, OhMyREPL

makedocs(
    format = Documenter.Formats.HTML,
    sitename = "OhMyREPL",
    pages = Any[
        "Home" => "index.md",
        "Installation" => "installation.md",
        "Features" => Any[
            "features/syntax_highlighting.md",
            "features/bracket_highlighting.md",
            "features/prompt_pasting.md",
            "features/error_messages.md",
            "features/bracket_complete.md",
            ],
        "Internals" => Any[
            "internals/ansitoken.md",
            "internals/passes.md"
            ]
    ]
)

deploydocs(
    repo = "github.com/KristofferC/OhMyREPL.jl.git",
    target = "build",
    deps = nothing,
    make = nothing,
)