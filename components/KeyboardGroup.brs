'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()

    m.keyboard = m.top.findNode("keyboard")
    m.okButton = m.top.findNode("okButton")
    m.keyboardGroup = m.top.findNode("keyboardGroup")

    m.horz = 0

    m.keyboard.setFocus(true)

end function

function onKeyEvent(key, press) as Boolean

    handled = false

    if press
        if key = "right"
            if m.okButton.hasFocus() = false and m.horz = 6
                m.okButton.setFocus(true)
                handled = true
            else if m.horz < 6
                m.horz = m.horz + 1
                handled = true
            end if
        else if key = "left"
            if m.okButton.hasfocus() = false
                m.horz = m.horz - 1
                handled = true
            else
                m.keyboard.setFocus(true)
                handled = true
        end if
    end if

    return handled
end function

