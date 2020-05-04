'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()

    m.videoPlayer = m.top.findNode("videoPlayer")
    m.keyboardGroup = m.top.findNode("keyboardGroup")

    m.keyboardGroup.observeField("streamUrl", "onStreamChange")

    m.stream = createObject("RoSGNode", "ContentNode")
    m.stream["streamFormat"] = "hls"

    m.keyboardGroup.setFocus(true)
    
end function

function onStreamChange()
    m.stream["url"] = m.keyboardGroup.streamUrl
    m.videoPlayer.setFocus(true)
    m.keyboardGroup.visible = false
    m.videoPlayer.visible = true
    m.videoPlayer.content = m.stream
    m.videoPlayer.control = "play"
end function

function onKeyEvent(key, press) as Boolean

    handled = false

    if press
        if m.keyboardGroup.okButton.hasFocus() = false and key = "down"
            m.keyboardGroup.okButton.setFocus(true)
            handled = true
        else if m.keyboardGroup.okButton.hasFocus() = true and key = "up"
            m.keyboardGroup.keyboard.setFocus(true)
            handled = true
        end if
    end if

    return handled
end function