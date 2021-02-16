' WebSocketClientTask.brs
' Copyright (C) 2018 Rolando Islas
' Released under the MIT license
'
' BrightScript, SceneGraph Task wrapper for the web socket client

' Entry point
function init() as void
    ' Task init
    m.top.functionName = "run"
    m.top.control = "RUN"
end function

' Main task loop
function run() as void
    m.ws = WebSocketClient()
    m.port = createObject("roMessagePort")
    m.ws.set_message_port(m.port)
    ' Fields
    m.top.STATE_CONNECTING = m.ws.STATE.CONNECTING
    m.top.STATE_OPEN = m.ws.STATE.OPEN
    m.top.STATE_CLOSING = m.ws.STATE.CLOSING
    m.top.STATE_CLOSED = m.ws.STATE.CLOSED
    m.top.ready_state = m.ws.get_ready_state()
    m.top.protocols = m.ws.get_protocols()
    m.top.headers = m.ws.get_headers()
    m.top.secure = m.ws.get_secure()
    m.top.buffer_size = m.ws.get_buffer_size()
    ' Event listeners
    m.top.observeField("open", m.port)
    m.top.observeField("send", m.port)
    m.top.observeField("close", m.port)
    m.top.observeField("buffer_size", m.port)
    m.top.observeField("protocols", m.port)
    m.top.observeField("headers", m.port)
    m.top.observeField("secure", m.port)
    m.top.observeField("log_level", m.port)

    if len(m.top.open) > 0
        m.ws.open(m.top.open)
    end if

    while true
        ' Check task messages
        msg = wait(1, m.port)
        ' Field event
        if type(msg) = "roSGNodeEvent"
            if msg.getField() = "open"
                m.ws.open(msg.getData())
            else if msg.getField() = "send"
                m.ws.send(msg.getData())
            else if msg.getField() = "close"
                m.ws.close(msg.getData())
            else if msg.getField() = "buffer_size"
                m.ws.set_buffer_size(msg.getData())
            else if msg.getField() = "protocols"
                m.ws.set_protocols(msg.getData())
            else if msg.getField() = "headers"
                m.ws.set_headers(msg.getData())
            else if msg.getField() = "secure"
                m.ws.set_secure(msg.getData())
            else if msg.getField() = "log_level"
                m.ws.set_log_level(msg.getData())
            end if
            ' WebSocket event
        else if type(msg) = "roAssociativeArray"
            if msg.id = "on_open"
                m.top.on_open = msg.data
            else if msg.id = "on_close"
                m.top.on_close = msg.data
            else if msg.id = "on_message"
                m.top.on_message = msg.data
            else if msg.id = "on_error"
                m.top.on_error = msg.data
            else if msg.id = "ready_state"
                m.top.ready_state = msg.data
            else if msg.id = "buffer_size"
                m.top.unobserveField("buffer_size")
                m.top.buffer_size = msg.data
                m.top.observeField("buffer_size", m.task_port)
            else if msg.id = "protocols"
                m.top.unobserveField("protocols")
                m.top.protocols = msg.data
                m.top.observeField("protocols", m.task_port)
            else if msg.id = "headers"
                m.top.unobserveField("headers")
                m.top.headers = msg.data
                m.top.observeField("headers", m.task_port)
            else if msg.id = "secure"
                m.top.unobserveField("secure")
                m.top.secure = msg.data
                m.top.observeField("secure", m.task_port)
            end if
        end if
        m.ws.run()
    end while
end function
