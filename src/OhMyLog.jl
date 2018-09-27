__precompile__(true)
module OhMyLog
using Crayons
using Logging

import Base.CoreLogging:
    LogLevel, BelowMinLevel, Debug, Info, Warn, Error, AboveMaxLevel,
    AbstractLogger,
    NullLogger,
    handle_message, shouldlog, min_enabled_level, catch_exceptions,
    @debug,
    @info,
    @warn,
    @error,
    @logmsg,
    with_logger,
    current_logger,
    global_logger,
    disable_logging,
    SimpleLogger

export
    AbstractLogger,
    LogLevel,
    NullLogger,
    @debug,
    @info,
    @warn,
    @error,
    @logmsg,
    with_logger,
    current_logger,
    global_logger,
    disable_logging,
    SimpleLogger,
    OhMyLogger



include("overprint.jl")
include("logging_core.jl")


function __init__()
    global_logger(OhMyLogger(stderr))
    atexit() do
        logger = global_logger()
        if logger isa OhMyLogger
            global_logger(OhMyLogger(Core.stderr, min_enabled_level(logger)))
        end
    end
end

end # module
