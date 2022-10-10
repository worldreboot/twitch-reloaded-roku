function createUrl()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-ID", "w9msa6phhl3u8s2jyjcmshrfjczj2y")
    while m.global.appBearerToken = invalid
    end while
    userToken = m.global.userToken
    '? "(userToken) " userToken
    if userToken <> invalid and userToken <> ""
        ? "we usin " userToken
        url.AddHeader("Authorization", "Bearer " + m.global.userToken)
    else
        ? "we using global"
        url.AddHeader("Authorization", m.global.appBearerToken)
    end if
    return url
end function

function GETJSON(link as String) as Object
    url = createUrl()
    url.SetUrl(link.EncodeUri())

    response_string = url.GetToString()

    return ParseJson(response_string)
end function

function POST(request_url as String, request_payload as String) as String
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-Id", "kimne78kx3ncx6brgo4mv6wki5h1ko")
    url.AddHeader("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36")
    url.AddHeader("Origin", "https://player.twitch.tv")
    url.AddHeader("Referer", "https://player.twitch.tv")
    url.SetUrl(request_url)

    port = CreateObject("roMessagePort")
    url.SetMessagePort(port)

    url.AsyncPostFromString(request_payload)
    
    response = Wait(0, port)

    return response.GetString()
end function

function refreshToken()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl("https://twoku-web.herokuapp.com/refresh")
    port = CreateObject("roMessagePort")
    url.SetMessagePort(port)
    url.AsyncPostFromString("code=" + getRefreshToken())
    msg = port.WaitMessage(0)
    oauth_token = ParseJson(msg.GetString())

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl("https://id.twitch.tv/oauth2/validate")
    url.AddHeader("Authorization", "Bearer " + oauth_token.access_token)
    response = ParseJson(url.GetToString())

    saveLogin(oauth_token.access_token, oauth_token.refresh_token, response.login)
end function

function getRefreshToken()
    sec = createObject("roRegistrySection", "LoggedInUserData")
    if sec.Exists("RefreshToken")
        return sec.Read("RefreshToken")
    end if
    return ""
end function

function saveLogin(access_token, refresh_token, login) as Void
    sec = createObject("roRegistrySection", "LoggedInUserData")
    sec.Write("UserToken", access_token)
    sec.Write("RefreshToken", refresh_token)
    sec.Write("LoggedInUser", login)
    m.global.setField("userToken", access_token)
    sec.Flush()
end function