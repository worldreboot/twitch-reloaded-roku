sub init()
    m.code = m.top.findNode("code")
    m.top.observeField("visible", "onVisible")
    m.getAuth = createObject("RoSGNode", "GetAuth")
    m.getAuth.observeField("code", "setUserCode")
    m.getAuth.observeField("finished", "whenFinished")
end sub

sub whenFinished()
    m.top.finished = true
end sub

sub setUserCode()
    m.code.text = m.getAuth.code
end sub

sub onVisible()
    if m.top.visible = true
        ? "RUN"
        m.getAuth.control = "RUN"
    else
        ? "STOP"
        m.getAuth.control = "STOP"
    end if
end sub