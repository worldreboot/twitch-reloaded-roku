function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    access_token_url = "http://api.twitch.tv/api/channels/" + m.top.streamerRequested + "/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6"

    m.url = CreateObject("roUrlTransfer")
    m.url.SetUrl(access_token_url)

    access_token = ParseJson(url.GetToString())

    stream_link = "http://usher.ttvnw.net/api/channel/hls/" + m.top.streamerRequested + ".m3u8?allow_source=true&allow_spectre=true&type=any&token=" + access_token.token + "&sig=" + access_token.sig

end function