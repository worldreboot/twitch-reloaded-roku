function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    stream_link = LogUser()

    m.top.finished = true

end function

function logUser()
    access_token_url = "http://72.136.77.60:3000/"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()

    url.SetUrl(access_token_url)
    response_string = url.GetToString()

    return ""
end function