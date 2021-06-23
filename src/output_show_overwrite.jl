using GarishPrint

Base.show(io::IO, ::MIME"text/plain", x) = pprint(io, x)
