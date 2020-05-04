function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    stream_link = getStreamLink()

    m.top.streamUrl = stream_link

end function

function createHttp(link as String) as Object
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(link)
    return url
end function

function getStreamLink() as Object
    access_token_url = "http://api.twitch.tv/api/channels/" + m.top.streamerRequested + "/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()

    url.SetUrl(access_token_url)
    response_string = url.GetToString()
    access_token = ParseJson(response_string)
    
    stream_link = "http://usher.ttvnw.net/api/channel/hls/" + m.top.streamerRequested + ".m3u8?allow_source=true&allow_spectre=true&type=any&token=" + access_token.token + "&sig=" + access_token.sig

    url.SetUrl(stream_link.EncodeUri())

    rsp = url.GetToString()

    list = rsp.Split(chr(10))

    first_stream_link = ""
    for each word in list
        first = word.Left(4)
        if first = "http"
            first_stream_link = word
            exit for
        end if
    end for

    return first_stream_link
end function