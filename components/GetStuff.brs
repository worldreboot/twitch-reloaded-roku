function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    stream_link = getStreamLink()

    'stream_file = getStreamFile(stream_link)

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

    ? "GetStuff >> getStreamLink > access_token_url > "; access_token_url
    ? "GetStuff >> getStreamLink > url.Escape(access_token_url) > "; url.Escape(access_token_url)
    url.SetUrl(access_token_url)
    ? "GetStuff >> getStreamLink > url.GetUrl() > "; url.GetUrl()
    response_string = url.GetToString()
    access_token = ParseJson(response_string)
    
    stream_link = "http://usher.ttvnw.net/api/channel/hls/" + m.top.streamerRequested + ".m3u8?allow_source=true&allow_spectre=true&type=any&token=" + access_token.token + "&sig=" + access_token.sig
    ? "GetStuff >> getStreamLink > access_token_url > "; stream_link

    return stream_link.EncodeUri()
end function

function getStreamFile(stream_link as String) as Object
    'url = CreateObject("roUrlTransfer")
    'url.EnableEncodings(true)
    'url.RetainBodyOnError(true)
    'url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    'url.InitClientCertificates()
    '? "GetStuff >> getStreamFile > Escape(stream_link) > "; url.Escape(stream_link)
    'url.SetUrl(url.Escape(stream_link))
    '? "GetStuff >> getStreamFile > GetUrl > "; url.GetUrl()
    'stream_file = url.GetToString()
    '? "GetStuff >> getStreamFile > stream_file > "; stream_file
    '? "GetStuff >> getStreamFile > reason > "; url.GetFailureReason()
    'return stream_file
    urlTransfer = CreateObject("roUrlTransfer")
    urlTransfer.SetMessagePort(CreateObject("roMessagePort"))
    ? "GetStuff >> getStreamFile > stream_link > "; stream_link
    urlTransfer.SetUrl(stream_link.EncodeUri())                                   'Set the url.
    urlTransfer.EnableEncodings(true)                               'Enable gzip compression.
    urlTransfer.RetainBodyOnError(true)                             'Also return the response body in case of errors.
    urlTransfer.SetCertificatesFile("common:/certs/ca-bundle.crt")  'Enable https.
    urlTransfer.InitClientCertificates()                            'Enable https.

    'Perform a HTTP GET.
    urlTransfer.AsyncGetToString()

    'Prepare the object that is to be returned.
    'resultObject = CreateObject("roAssociativeArray")

   ' while true
        'message = wait(0, urlTransfer.GetMessagePort())

        'if (type(message) = "roUrlEvent")

            'resultObject.responseCode = message.GetResponseCode()
            '? "GetStuff >> getStreamFile > responseCode > "; resultObject.responseCode
            'resultObject.failureReason = message.GetFailureReason()
            '? "GetStuff >> getStreamFile > reason > "; resultObject.failureReason
            'resultObject.bodyString = message.GetString()
            '? "GetStuff >> getStreamFile > body > "; resultObject.bodyString

            'exit while
        'end if
    'end while

    'return resultObject
end function