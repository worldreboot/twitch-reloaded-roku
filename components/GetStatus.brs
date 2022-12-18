function init()
    m.top.functionName = "onStatusChange"
end function

function onStatusChange()

    m.top.appStatus = getAppStatus()

end function

function getAppStatus() as Object
    app_status_url = "https://worldreboot.github.io/status1"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()

    url.SetUrl(app_status_url)
    
    response_string = url.GetToString()

    ? "GetToken response: "; response_string
    
    return response_string
end function