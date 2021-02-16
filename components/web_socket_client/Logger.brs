' Logger.brs
' Copyright (C) 2018 Rolando Islas
' Released under the MIT license
'
' Internal logging utility

' Initialize a logging utility
function Logger() as object
    log = {}
    log.FATAL = -2
    log.WARN = -1
    log.INFO = 0
    log.DEBUG = 1
    log.EXTRA = 2
    log.VERBOSE = 3

    ' Main

    ' Log a message
    ' @param level log level string or integer
    ' @param msg message to print
    log.printl = function (level as object, msg as object) as void
        if m._parse_level(level) > m.log_level
            return
        end if
        print "[" + m._level_to_string(level) + "] " + msg
    end function

    ' Parse level to a string
    ' @param level string or integer level
    log._level_to_string = function (level as object) as string
        if type(level) = "roString" or type(level) = "String"
            level = m._parse_level(level)
        end if
        if level = -2
            return "FATAL"
        else if level = -1
            return "WARN"
        else if level = 0
            return "INFO"
        else if level = 1
            return "DEBUG"
        else if level = 2
            return "EXTRA"
        else if level = 3
            return "VERBOSE"
        end if
    end function

    ' Parse level to an integer
    ' @param level string or integer level
    log._parse_level = function (level as object) as integer
        level_string = level.toStr()
        log_level = 0
        if level_string = "FATAL" or level_string = "-2"
            log_level = m.FATAL
        else if level_string = "WARN" or level_string = "-1"
            log_level = m.WARN
        else if level_string = "INFO" or level_string = "0"
            log_level = m.INFO
        else if level_string = "DEBUG" or level_string = "1"
            log_level = m.DEBUG
        else if level_string = "EXTRA" or level_string = "2"
            log_level = m.EXTRA
        else if level_string = "VERBOSE" or level_string = "3"
            log_level = m.VERBOSE
        end if
        return log_level
    end function

    ' Set the log level
    log.set_log_level = function (level as string) as void
        m.log_level = m._parse_level(level)
    end function

    ' Parse Config
    config_string = readAsciiFile("pkg:/bright_web_socket.json")
    config = parseJson(config_string)
    if config <> invalid
        if config.log_level <> invalid
            log.log_level = log._parse_level(config.log_level)
        else
            log.log_level = log.INFO
            log.printl(log.WARN, "WebSocketLogger: Missing log_level param in pkg:/bright_web_socket.json")
        end if
    else
        log.log_level = log.INFO
        log.printl(log.WARN, "WebSocketLogger: Missing pkg:/bright_web_socket.json")
    end if
    return log
end function
