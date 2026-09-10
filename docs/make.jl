using Documenter, OhMyREPL

makedocs(
    sitename = "OhMyREPL",
    pages = Any[
        "Home" => "index.md",
        "Installation" => "installation.md",
        "Features" => Any[
            "features/syntax_highlighting.md",
            "features/native.md",
            "features/prompt.md",
            ],
    ]
)

deploydocs(
    repo = "github.com/KristofferC/OhMyREPL.jl.git",
)
