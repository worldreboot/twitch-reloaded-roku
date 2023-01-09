function init()
    m.top.functionName = "getAuth"
end function

function getAuth() as object
    m.top.finished = false
    getNewUserToken()
    m.top.finished = true
end function


function getNewUserToken() as object
    req = HttpRequest({
        url: "https://twoku-web.herokuapp.com/register"
        headers: {
            "twokupassword": "Chah3choY1ve0eim"
        }
        method: "GET"
    })
    m.top.code = req.send().getstring()
    req = HttpRequest({
        url: "https://twoku-web.herokuapp.com/unregister?code=" + m.top.code
        headers: {
            "twokupassword": "Chah3choY1ve0eim"
        }
        method: "POST"
        data: "code=" + m.top.code
    })

    while true
        res = req.send()
        if res <> "twitch_failure" and res <> "waiting" and res <> "" and res <> invalid
            ? ">>>"
            ? res
            ? ">>>"
            res = ParseJson(res)
            if res <> invalid and res.DoesExist("access_token")
                exit while
            end if
        end if
        sleep(5000)
    end while
    oauth_token = res
    ? "OAUTH TOKEN: " oauth_token
    req = HttpRequest({
        url: "https://id.twitch.tv/oauth2/validate"
        headers: {
            "Client-Id": "w9msa6phhl3u8s2jyjcmshrfjczj2y"
            "Authorization": "OAuth " + oauth_token.access_token
        }
        method: "GET"
    })
    login = ParseJSON(req.send().getstring()).login
    if login <> invalid and login <> ""
        saveLogin(oauth_token.access_token, oauth_token.refresh_token, login)
    end if
end function