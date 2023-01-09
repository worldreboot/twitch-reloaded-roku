function getUserOauthToken()
    login = validateUserToken()
    if login <> invalid
        token = getTokenFromRegistry()
        userToken = token.access_token
        refresh_token = token.refresh_token
        userLogin = token.login
        output = "Oauth: " + userToken
        return output
    end if
    return invalid
end function

function getUserBearerToken()
    login = validateUserToken()
    if login <> invalid
        token = getTokenFromRegistry()
        userToken = token.access_token
        refresh_token = token.refresh_token
        userLogin = token.login
        output = "Oauth: " + userToken
        return output
    end if
    return invalid
end function

function getTokenFromRegistry()
    sec = createObject("roRegistrySection", "LoggedInUserData")
    refresh_token = ""
    userToken = ""
    userLogin = ""
    if sec.Exists("RefreshToken")
        refresh_token = sec.Read("RefreshToken")
    end if
    if sec.Exists("UserToken")
        userToken = sec.Read("UserToken")
    end if
    if sec.Exists("LoggedInUser")
        userLogin = sec.Read("LoggedInUser")
    end if
    if refresh_token = invalid or refresh_token = ""
        refresh_token = ""
    end if
    if userToken = invalid or userToken = ""
        userToken = ""
    end if
    if userLogin = invalid or userLogin = ""
        userLogin = ""
    end if
    return {
        access_token: userToken
        refresh_token: refresh_token
        login: userLogin
    }
end function


function saveLogin(access_token, refresh_token, login) as void
    sec = createObject("roRegistrySection", "LoggedInUserData")
    if access_token <> invalid and access_token <> ""
        sec.Write("UserToken", access_token)
        ' m.global.setField("UserToken", access_token)
    end if
    if refresh_token <> invalid and refresh_token <> ""
        sec.Write("RefreshToken", refresh_token)
        ' m.global.setField("RefreshToken", refresh_token)
    end if
    if login <> invalid and login <> ""
        sec.Write("LoggedInUser", login)
        ' m.global.setField("LoggedInUser", login)
    end if
    sec.Flush()
end function

function UrlEncode(str as string) as string
    o = CreateObject("roUrlTransfer")
    return o.Escape(str)
end function

function validateUserToken(oauth_token = invalid)
    refreshToken()
    if oauth_token = invalid
        token = getTokenFromRegistry()
        userToken = token.access_token
        refresh_token = token.refresh_token
        userLogin = token.login
    else
        userToken = oauth_token.access_token
    end if
    req = HttpRequest({
        url: "https://id.twitch.tv/oauth2/validate"
        headers: {
            "client-id": "w9msa6phhl3u8s2jyjcmshrfjczj2y"
            "Authorization": "OAuth " + userToken
        }
        method: "GET"
    })
    response = ParseJSON(req.send())
    ? "Response: "; response
    if response <> invalid
        if response.status = 401 and refresh_token <> invalid and refresh_token <> ""
            ? "USED FIRST ONE!!!"
            refreshToken()
            return ""
        end if
        if response.login <> invalid and response.login <> ""
            ? "USED THIS ONE!!!"
            return response.login
        end if
    end if
end function



function refreshToken()
    userdata = getTokenFromRegistry()
    userLogin = userdata.login
    refresh_token = userdata.refresh_token
    userToken = userdata.access_token
    ? "Client Asked to Refresh Token"
    if refresh_token <> invalid and refresh_token <> ""
        req = HttpRequest({
            url: "https://twoku-web.herokuapp.com/refresh?code=" + refresh_token
            headers: {
                "Content-Type": "application/x-www-form-urlencoded"
                "Accept": "*/*"
            }
            method: "POST"
            data: ""
        })
        oauth_token = ParseJSON(req.send())
        ' ? "OAUTH TOKEN IS: "; oauth_token
        saveLogin(oauth_token.access_token, oauth_token.refresh_token, userLogin)
    end if
end function


' function getRecommendedStreams()
'     return select(getStreams(), 5)
' end function

' function getFeaturedStreams()
'     return select(getStreams(), 0, 4)
' end function

' function getStreams() as object
'     req = HttpRequest({
'         url: "https://api.twitch.tv/helix/streams?first=21"
'         headers: {
'             "client-id": "w9msa6phhl3u8s2jyjcmshrfjczj2y"
'             "Authorization": getBearerToken()
'         }
'         method: "GET"
'     })
'     response = ParseJSON(req.send())
'     first = true
'     result = []
'     if response <> invalid and response.data <> invalid
'         for each stream in response.data
'             game_ids_url = "https://api.twitch.tv/helix/games?id="
'             user_ids_url = "https://api.twitch.tv/helix/users?id="
'             if first = false
'                 game_ids_url += "&id=" + stream.game_id
'                 user_ids_url += "&id=" + stream.user_id
'             else
'                 game_ids_url += stream.game_id
'                 user_ids_url += stream.user_id
'             end if
'             thumbnail_url = Left(stream.thumbnail_url, Len(stream.thumbnail_url) - 21)
'             item = {
'                 description: stream.title
'                 guid: stream.user_id
'                 hdbackgroundimageurl: thumbnail_url + "-854x480.jpg"
'                 hdposterurl: thumbnail_url + "-854x480.jpg"
'                 pubDate: ""
'                 streamurl: "https://twitch.k10labs.workers.dev/stream?streamer=" + stream.user_name
'                 streamformat: "hls"
'                 title: stream.user_name
'                 subtitle: numberToText(stream.viewer_count)
'                 typename: "stream"
'             }
'             result.push(item)
'             first = false
'         end for
'     end if
'     return result
' end function


sub numberToText(number as object) as object
    result = ""
    if number < 1000
        result = number.toStr()
    else if number < 1000 * 1000
        n = (number / 1000).toStr()
        ' Regex: any numbers with a dot and a decimal different from 0 OR any amount of numbers (stops at the dot). In that order.
        r = CreateObject("roRegex", "([0-9]+\.[1-9])|([0-9]+)", "")
        result = r.Match(n)[0] + "K"
    else
        n = (number / 1000 * 1000).toStr()
        r = CreateObject("roRegex", "([0-9]+\.[1-9])|([0-9]+)", "")
        result = r.Match(n)[0] + "M"
    end if
    result = " " + result + " "
    return result
end sub


function getCategorySearchResults()
    req = HttpRequest({
        url: "https://api.twitch.tv/helix/games/top?first=24"
        headers: {
            "client-id": "w9msa6phhl3u8s2jyjcmshrfjczj2y"
            "Authorization": getBearerToken()
        }
        method: "GET"
    })
    response = ParseJSON(req.send())
    result = []
    if response.data <> invalid
        for each category in response.data
            item = {
                descrption: ""
                guid: category.id
                hdbackgroundimageurl: Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
                hdposterurl: Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
                link: ""
                "media:content": ""
                pubDate: ""
                stream: { url: "" }
                streamformat: "hls"
                title: category.name
                typename: "category"
                uri: [
                    Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
                ]

            }
            result.push(item)
        end for
    end if
    return result
end function



function getBearerToken() as object
    req = HttpRequest({
        url: "https://oauth.k10labs.workers.dev/bearer"
        headers: { "Authorization": "Basic YWRtaW46YWRtaW4=" }
        method: "GET"
    })
    response = ParseJSON(req.send())
    return "Bearer " + response.access_token
end function




' function getRecommendedStreams()
'     payload = [{
'         "operationName": "PersonalSections",
'         "variables": {
'             "input": {
'                 "sectionInputs": [
'                     "RECS_FOLLOWED_SECTION",
'                     "RECOMMENDED_SECTION"
'                 ],
'                 "recommendationContext": {
'                     "platform": "web",
'                     "clientApp": "twilight",
'                     "channelName": "",
'                     "categoryName": "",
'                     "lastChannelName": "",
'                     "lastCategoryName": "",
'                     "pageviewContent": "",
'                     "pageviewContentType": "",
'                     "pageviewLocation": "",
'                     "pageviewMedium": "",
'                     "previousPageviewContent": "",
'                     "previousPageviewContentType": "",
'                     "previousPageviewLocation": "",
'                     "previousPageviewMedium": ""
'                 }
'             },
'             "creatorAnniversariesExperimentEnabled": false,
'             "sideNavActiveGiftExperimentEnabled": false
'         },
'         "extensions": {
'             "persistedQuery": {
'                 "version": 1,
'                 "sha256Hash": "469b047f12eef51d67d3007b7c908cf002c674825969b4fa1c71c7e4d7f1bbfb"
'             }
'         }
'     }]
'     req = HttpRequest({
'         url: "https://gql.twitch.tv/gql"
'         headers: { "Client-Id": "kimne78kx3ncx6brgo4mv6wki5h1ko" }
'         method: "POST"
'         data: payload
'     })
'     return req.send()
' end function


function HttpRequest(params = invalid as dynamic) as object
    url = invalid
    method = invalid
    headers = {}
    data = invalid
    timeout = 0
    retries = 1
    interval = 500
    if params <> invalid then
        if params.url <> invalid then url = params.url
        if params.method <> invalid then method = params.method
        if params.headers <> invalid then headers = params.headers
        if params.data <> invalid then data = params.data
        if params.timeout <> invalid then timeout = params.timeout
        if params.retries <> invalid then retries = params.retries
        if params.interval <> invalid then interval = params.interval
    end if

    obj = {
        _timeout: timeout
        _retries: retries
        _interval: interval
        _deviceInfo: createObject("roDeviceInfo")
        _url: url
        _method: method
        _requestHeaders: headers
        _data: data
        _http: invalid
        _isAborted: false

        _isProtocolSecure: function(url as string) as boolean
            return left(url, 6) = "https:"
        end function

        _createHttpRequest: function() as object
            request = createObject("roUrlTransfer")
            request.setPort(createObject("roMessagePort"))
            request.setUrl(m._url)
            request.retainBodyOnError(true)
            request.enableCookies()
            request.setHeaders(m._requestHeaders)
            if m._method <> invalid then request.setRequest(m._method)

            'Checks if URL protocol is secured, and adds appropriate parameters if needed
            if m._isProtocolSecure(m._url) then
                request.setCertificatesFile("common:/certs/ca-bundle.crt")
                ' request.addHeader("X-Roku-Reserved-Dev-Id", "")
                ' request.addHeader("Client-Id", "kimne78kx3ncx6brgo4mv6wki5h1ko")
                request.initClientCertificates()
            end if

            return request
        end function

        getPort: function()
            if m._http <> invalid then
                return m._http.getPort()
            else
                return invalid
            end if
        end function

        getCookies: function(domain as string, path as string) as object
            if m._http <> invalid then
                return m._http.getCookies(domain, path)
            else
                return invalid
            end if
        end function

        send: function(data = invalid as dynamic) as dynamic
            timeout = m._timeout
            retries = m._retries
            response = invalid

            if data <> invalid then m._data = data

            if m._data <> invalid and getInterface(m._data, "ifString") = invalid then
                m._data = formatJson(m._data)
            end if

            while retries > 0 and m._deviceInfo.getLinkStatus()
                if m._sendHttpRequest(m._data) then
                    event = m._http.getPort().waitMessage(timeout)

                    if m._isAborted then
                        m._isAborted = false
                        m._http.asyncCancel()
                        exit while
                    else if type(event) = "roUrlEvent" then
                        response = event
                        exit while
                    end if

                    m._http.asyncCancel()
                    timeout *= 2
                    sleep(m._interval)
                end if

                retries--
            end while

            return response
        end function

        _sendHttpRequest: function(data = invalid as dynamic) as dynamic
            m._http = m._createHttpRequest()

            if data <> invalid then
                return m._http.asyncPostFromString(data)
            else
                return m._http.asyncGetToString()
            end if
        end function

        abort: function()
            m._isAborted = true
        end function

    }

    return obj
end function


function createUrl()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-ID", "w9msa6phhl3u8s2jyjcmshrfjczj2y")
    while m.global.appBearerToken = invalid
    end while
    at = getTokenFromRegistry()
    userToken = at.access_token
    '? "(userToken) " userToken
    if userToken <> invalid and userToken <> ""
        ? "we usin " userToken
        ? "header btw: Authorization Bearer " + userToken
        url.AddHeader("Authorization", "Bearer " + userToken)
    else
        ? "we using global"
        url.AddHeader("Authorization", m.global.appBearerToken)
    end if
    return url
end function

function GETJSON(link as string) as object
    url = createUrl()
    url.SetUrl(link.EncodeUri())
    response_string = url.GetToString()
    return ParseJson(response_string)
end function

function getRefreshToken()
    token = getTokenFromRegistry()
    if token.refresh_token <> invalid
        return token.refresh_token
    end if
end function

' function getPlaybackAccessToken(streamLogin as string, id as string, isVod as boolean) as object
'     request = {
'         "extensions": {
'             "persistedQuery": {
'                 "sha256Hash": "0828119ded1c13477966434e15800ff57ddacf13ba1911c129dc2200705b0712",
'                 "version": 1
'             }
'         },
'         "operationName": "PlaybackAccessToken",
'         "variables": {
'             "isLive": not isVod,
'             "isVod": isVod,
'             "login": streamLogin,
'             "playerType": "channel_home_live",
'             "vodID": id
'         }
'     }
'     ? "format json: " FormatJson(request)
'     response = POST("https://gql.twitch.tv/gql", FormatJson(request))
'     return response
' end function



'**************************************
'** Added for backwards compatibility
'**************************************

function POST(request_url as string, request_payload as string) as string
    token = getTokenFromRegistry()
    userToken = token.access_token
    req = HttpRequest({
        url: request_url
        headers: {
            "Client-ID": "kimne78kx3ncx6brgo4mv6wki5h1ko"
            "Authorization": "OAuth " + userToken
            "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/86.0.4240.198 Safari/537.36"
            "Origin": "https://player.twitch.tv"
            "Referer": "https://player.twitch.tv"
        }
        method: "POST"
        data: request_payload
    })
    response = req.send()
    return response.GetString()
end function


function getPlaybackAccessToken(id as string, isVod as boolean)
    token = getTokenFromRegistry()
    if isVod
        isLive = false
        vodId = id
        login = ""
    else
        isLive = True
        vodId = ""
        login = id
    end if
    req = HttpRequest({
        url: "https://gql.twitch.tv/gql"
        headers: {
            "Accept": "*/*"
            ' "Accept-Encoding": "gzip, deflate, br"
            ' "Accept-Language": "en-US"
            ' "Authorization": "OAuth uk5seeh033g141pr69vdw7f8s1y0b7"
            ' "Cache-Control": "no-cache"
            "Client-Id": "kimne78kx3ncx6brgo4mv6wki5h1ko"
            ' "Content-Type": "text/plain; charset=UTF-8"
            ' "Device-ID": getDeviceId()
            ' "Host": "gql.twitch.tv"
            ' "Origin": "https://www.twitch.tv"
            ' "Pragma": "no-cache"
            ' "Referer": "https://www.twitch.tv/"
            ' "Sec-Fetch-Site": "same-site"
            ' "Sec-Fetch-Mode": "cors"
            ' "Sec-Fetch-Dest": "empty"
            ' "User-Agent": "Mozilla/5.0 (Linux; Android 5.1; AFTS Build/LMY47O) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/41.99900.2250.0242 Safari/537.36"
        }
        method: "POST"
        data: {
            operationName: "PlaybackAccessToken_Template"
            query: "query PlaybackAccessToken_Template($login: String!, $isLive: Boolean!, $vodID: ID!, $isVod: Boolean!, $playerType: String!) { streamPlaybackAccessToken(channelName: $login, params: { platform: " + Chr(34) + "web" + Chr(34) + ", playerBackend: " + Chr(34) + "mediaplayer" + chr(34) + ", playerType: $playerType }) @include(if: $isLive) { value signature __typename } videoPlaybackAccessToken(id: $vodID, params: { platform: " + chr(34) + "web" + chr(34) + ", playerBackend: " + chr(34) + "mediaplayer" + chr(34) + ", playerType: $playerType }) @include(if: $isVod) { value signature __typename } }"
            variables: {
                "isLive": isLive
                "login": login
                "isVod": isVod
                "vodID": vodId
                "playerType": "site"
            }
        }
    })
    data = req.send()
    response = ParseJSON(data)
    if isVod
        return response.data.videoPlaybackAccessToken
    else
        return response.data.streamPlaybackAccessToken
    end if
end function

function select(arr, start = invalid, finish = invalid, step_ = 1):
    if step_ = 0 then print "ValueError: slice step cannot be zero" : stop
    if start = invalid then if step_ > 0 then start = 0 else start = arr.count() - 1
    if finish = invalid then if step_ > 0 then finish = arr.count() - 1 else finish = 0
    if start < 0 then start = arr.count() + start 'negative counts backwards from the end
    if finish < 0 then finish = arr.count() + finish
    res = []
    for i = start to finish step step_:
        res.push(arr[i])
    end for
    return res
end function


' Helper function to add and set fields of a content node
function AddAndSetFields(node as object, aa as object)
    'This gets called for every content node -- no logging since it's pretty verbose
    addFields = {}
    setFields = {}
    for each field in aa
        if node.hasField(field)
            setFields[field] = aa[field]
        else
            addFields[field] = aa[field]
        end if
    end for
    node.setFields(setFields)
    node.addFields(addFields)
end function

function getMd5Hash(s as string)
    ba = CreateObject("roByteArray")
    ba.FromAsciiString(s)
    digest = CreateObject("roEVPDigest")
    digest.Setup("md5")
    result = digest.Process(ba)
    return result
end function

function getDeviceId()
    di = CreateObject("roDeviceInfo")
    uniqueId = di.GetChannelClientId()
    return uniqueId
end function


function getStreamLink(id, isVod) as object
    at = getTokenFromRegistry()
    userToken = at.access_token
    playbackAccessToken = getPlaybackAccessToken(id, isVod)
    baseurl = "https://usher.ttvnw.net/"
    if isVod
        middle = "vod/"
    else
        middle = "api/channel/hls/"
    end if
    fullUrl = baseurl + middle + id + ".m3u8"
    date = CreateObject("roDateTime")
    ' actionid = getDeviceId() + id + playbackAccessToken.value + date.AsSeconds().toStr()
    ' play_session_id = getMd5Hash(actionid)
    usherUrl = fullUrl + "?client_id=kimne78kx3ncx6brgo4mv6wki5h1ko&allow_source=true&fast_bread=true&player_backend=mediaplayer&playlist_include_framerate=true&reassignments_supported=true&supported_codecs=avc1&cdm=wv&player_version=1.16.0&token=" + UrlEncode(playbackAccessToken.value) + "&sig=" + UrlEncode(playbackAccessToken.signature) '+ "&play_session_id=" + play_session_id
    req = HttpRequest({
        url: usherUrl
        headers: {
            "Client-id": "kimne78kx3ncx6brgo4mv6wki5h1ko"
            "Referer": ""
            "Accept": "application/x-mpegURL, application/vnd.apple.mpegurl, application/json, text/plain"
            "User-Agent": "Mozilla/5.0 (Linux; Android 5.1; AFTS Build/LMY47O) AppleWebKit/537.36 (KHTML, like Gecko) Version/4.0 Chrome/41.99900.2250.0242 Safari/537.36"
        }
        method: "GET"
    })
    rsp = req.send().getString()
    check = rsp.Split((Chr(34) + "vod_manifest_restricted" + Chr(34)))
    if check.count() > 1
        return "vod_manifest_restricted"
    end if
    list = rsp.Split(chr(10))
    first_stream_link = ""
    last_stream_link = ""
    link = ""
    cnt = 0
    for line = 2 to list.Count() - 1
        stream_info = list[line + 1].Split(",")
        stream_quality = invalid
        stream_framerate = invalid
        for info = 0 to stream_info.Count() - 1
            info_parsed = stream_info[info].Split("=")
            if info_parsed[0] = "RESOLUTION"
                stream_quality = Int(Val(info_parsed[1].Split("x")[1]))
            else if info_parsed[0] = "VIDEO"
                if info_parsed[1] = (chr(34) + "chunked" + chr(34))
                    stream_framerate = 30
                else
                    stream_framerate = Int(Val(info_parsed[1].Split("p")[1]))
                end if
            end if
        end for
        if stream_framerate = invalid
            stream_framerate = 30
        end if
        if not stream_quality = invalid
            compatible_link = false
            last_stream_link = list[line + 2]
            if m.global.videoFramerate >= stream_framerate
                if m.global.videoQuality <= 1 and stream_quality <= 1080
                    compatible_link = true
                else if m.global.videoQuality <= 3 and stream_quality <= 720
                    compatible_link = true
                else if m.global.videoQuality = 4 and stream_quality <= 480
                    compatible_link = true
                else if m.global.videoQuality = 5 and stream_quality <= 360
                    compatible_link = true
                else if m.global.videoQuality = 6 and stream_quality <= 160
                    compatible_link = true
                end if
            end if
            if compatible_link
                link = list[line + 2]
                exit for
            end if
        end if
        line += 2
    end for
    ? "link: "; link
    ? "last_link: " last_stream_link
    if link = ""
        link = last_stream_link
    end if
    ? link
    return link
end function
