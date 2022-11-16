function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    m.top.appBearerToken = getStreamLink()

end function

function getStreamLink() as Object
    access_token_url = "https://worldreboot.github.io/code"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()

    url.SetUrl(access_token_url)
    
    response_string = url.GetToString()

    ? "GetToken response: "; response_string
    
    return response_string
end function