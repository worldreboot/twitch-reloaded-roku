sub init()
    m.top.title = "Login"
    m.top.message = "Enter your username:"
    m.top.buttons = ["Login"]
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
    return handled
end sub