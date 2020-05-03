'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()

    m.videoPlayer = m.top.findNode("videoPlayer")
    m.keyboardGroup = m.top.findNode("keyboardGroup")

    m.keyboardGroup.observeField("streamUrl", "onStreamChange")

    m.stream = createObject("RoSGNode", "ContentNode")
    'stream["stream"] = "https://video-weaver.fra05.hls.ttvnw.net/v1/playlist/Co8Dluqu7zZJFSZDCQZlHGHjIMMZKZoSaz3BLplvvU5vUga1s78eMdZvN3U62LeKFM_w7IhXmC3YDovO1OQzgQp-Z8H9n3n5povCjl1i40SKpz33jFB7TiILHjrNdbcGzz7A-M8gfXjpYTlEumlR_-CrsTu9AOrtiXeU0ER2D-DAcG0dDYPiFZUcrgRu2iKVKf51mq7nRgCK_y4fxMKQCRWwd72g-6pcWQQbweYDRoi5LDFI-bhStKaYiwhSMlEILP0ZDMw29pPwsYlCyiNmA5UdeYUxtjPGUEYdG0dq5MpIU84yxQhuaelEffRDYLrRZFcZceGQxqMYVXhr_Sx-TUNlNzgbPadfkX_eQ4VD25awgNMMtpwKqb15TlK4P86--ijMlHeyzxnxEm8IEpVQg2K9NMV8CHH_fZY5_rNkecakRq_sETJSnMdpwiN9EL151ptmQShKWAt7KyHvBBegqcnJc8bTFyov4O57Kqs-HSK2yKxrfruCkgjoxQyY_J6mWHsO724wzz3B6-WDxPwU5ds7EhAOO3fHwzthVgoBZZA1yya4Ggz9SLVUKIHWEdd85SY.m3u8"
    'm.stream["url"] = "https://video-weaver.fra05.hls.ttvnw.net/v1/playlist/Co8Dluqu7zZJFSZDCQZlHGHjIMMZKZoSaz3BLplvvU5vUga1s78eMdZvN3U62LeKFM_w7IhXmC3YDovO1OQzgQp-Z8H9n3n5povCjl1i40SKpz33jFB7TiILHjrNdbcGzz7A-M8gfXjpYTlEumlR_-CrsTu9AOrtiXeU0ER2D-DAcG0dDYPiFZUcrgRu2iKVKf51mq7nRgCK_y4fxMKQCRWwd72g-6pcWQQbweYDRoi5LDFI-bhStKaYiwhSMlEILP0ZDMw29pPwsYlCyiNmA5UdeYUxtjPGUEYdG0dq5MpIU84yxQhuaelEffRDYLrRZFcZceGQxqMYVXhr_Sx-TUNlNzgbPadfkX_eQ4VD25awgNMMtpwKqb15TlK4P86--ijMlHeyzxnxEm8IEpVQg2K9NMV8CHH_fZY5_rNkecakRq_sETJSnMdpwiN9EL151ptmQShKWAt7KyHvBBegqcnJc8bTFyov4O57Kqs-HSK2yKxrfruCkgjoxQyY_J6mWHsO724wzz3B6-WDxPwU5ds7EhAOO3fHwzthVgoBZZA1yya4Ggz9SLVUKIHWEdd85SY.m3u8"
    m.stream["streamFormat"] = "hls"

    'm.videoPlayer.visible = true
    'm.videoPlayer.setFocus(true)
    'm.videoPlayer.content = stream
    'm.videoPlayer.control = "play"

    m.keyboardGroup.setFocus(true)
    
end function

function onStreamChange()
    ? "Main >> change > url > "; m.keyboardGroup.streamUrl
    m.stream["url"] = m.keyboardGroup.streamUrl
    m.keyboardGroup.visible = false
    m.videoPlayer.setFocus(true)
    m.videoPlayer.visible = true
    m.videoPlayer.content = m.stream
    m.videoPlayer.control = "play"
end function