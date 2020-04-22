'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()

    m.keyboard = m.top.findNode("keyboard")
    m.okButton = m.top.findNode("okButton")
    m.keyboardGroup = m.top.findNode("keyboardGroup")

    m.okButton.ObserveField("buttonSelected", "onOkButtonSelect")

    m.keyboard.setFocus(true)

end function

function onOkButtonSelect()
    streamer = m.keyboard.text
    access_token_url = "http://api.twitch.tv/api/channels/" + streamer + "/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6"
    
    url = CreateObject("roUrlTransfer")
    url.SetUrl(access_token_url)

    access_token = ParseJson(url.GetToString())

    stream_link = "http://usher.ttvnw.net/api/channel/hls/" + streamer + ".m3u8?allow_source=true&allow_spectre=true&type=any&token=" + access_token.token + "&sig=" + access_token.sig

    m.global.videoContent = stream_link
end function

function onKeyEvent(key, press) as Boolean

    handled = false

    if press
        if m.okButton.hasFocus() = false and key = "down"
            m.okButton.setFocus(true)
            handled = true
        else if m.okButton.hasFocus() = true and key = "up"
            m.keyboard.setFocus(true)
            handled = true
        end if
    end if

    return handled
end function

