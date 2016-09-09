using Documenter, OhMyREPL

makedocs(
    format = Documenter.Formats.HTML,
    sitename = "OhMyREPL",
    pages = Any[
        "Home" => "index.md",
        "Features" => Any[
            "features/syntax_highlighting.md",
            "features/bracket_highlighting.md",
            "features/prompt_pasting.md",
            ],
        "Internals" => Any[
            "internals/ansitoken.md",
            ]
    ]
)