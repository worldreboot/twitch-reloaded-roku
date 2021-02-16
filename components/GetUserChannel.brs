'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function numberToText(number) as Object
    s = StrI(number)
    result = ""
    if number >= 1000000
        result = Left(s, 2) + "." + Mid(s, 3, 1) + "M"
    else if number >=100000 and number < 1000000
        result = Left(s, 4) + "K"
    else if number >=10000 and number < 100000
        result = Left(s, 3) + "." + Mid(s, 4, 1) + "K"
    else if number >=1000 and number < 10000
        result = Left(s, 2) + "." + Mid(s, 3, 1) + "K"
    else if number < 1000
        result = s
    end if
    return result + " followers"
end function

function numberToViewerText(number) as Object
    s = StrI(number)
    result = ""
    if number >=100000 and number < 1000000
        result = Left(s, 4) + "K"
    else if number >=10000 and number < 100000
        result = Left(s, 3) + "." + Mid(s, 4, 1) + "K"
    else if number >=1000 and number < 10000
        result = Left(s, 2) + "." + Mid(s, 3, 1) + "K"
    else if number < 1000
        result = s
    end if
    return result + " viewers"
end function

function getGameNameFromId(id as String)
    game_info = GETJSON("https://api.twitch.tv/helix/games?id=" + id)
    if game_info <> invalid and game_info.data <> invalid and game_info.data[0] <> invalid
        return game_info.data[0].name
    end if
    return id
end function

function convertToTimeFormat(timestamp as String) as String
    secondsSincePublished = createObject("roDateTime")
    secondsSincePublished.FromISO8601String(timestamp)
    currentTime = createObject("roDateTime").AsSeconds()
    elapsedTime = currentTime - secondsSincePublished.AsSeconds()
    m.top.streamDurationSeconds = elapsedTime
    hours = Int(elapsedTime / 60 / 60)
    mins = elapsedTime / 60 MOD 60
    secs = elapsedTime MOD 60
    if mins < 10
        mins = mins.ToStr()
        mins = "0" + mins
    else
        mins = mins.ToStr()
    end if
    if secs < 10
        secs = secs.ToStr()
        secs = "0" + secs
    else
        secs = secs.ToStr()
    end if
    return hours.ToStr() + ":" + mins + ":" + secs
end function

function getSearchResults() as Object
    search_results_url = "https://api.twitch.tv/helix/users?login=" + m.top.loginRequested

    url = createUrl()
    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)

    if search.status <> invalid and search.status = 401
        ? "401"
        refreshToken()
        return getSearchResults()
    end if

    result = {}

    if search <> invalid and search.data <> invalid
        stream = search.data[0]

        result.id = stream.id
        result.display_name = stream.display_name
        result.description = stream.description

        last = Right(stream.profile_image_url, 2)
        if last = "eg"
            result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 12) + "50x50.jpeg"
        else if last = "pg"
            result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 11) + "50x50.jpg"
        else
            result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 11) + "50x50.png"
        end if

        last = Right(stream.offline_image_url, 2)
        if last = "eg"
            result.offline_image_url = Left(stream.offline_image_url, Len(stream.offline_image_url) - 14) + "896x504.jpeg"
        else if last = "pg"
            result.offline_image_url = Left(stream.offline_image_url, Len(stream.offline_image_url) - 13) + "896x504.jpg"
        else
            result.offline_image_url = Left(stream.offline_image_url, Len(stream.offline_image_url) - 13) + "896x504.png"
        end if
    end if

    search_results_url = "https://api.twitch.tv/helix/streams?user_login=" + m.top.loginRequested

    url = createUrl()
    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)

    if search <> invalid and search.data <> invalid and search.data[0] <> invalid
        stream = search.data[0]

        result.title = stream.title
        result.thumbnail_url = Left(stream.thumbnail_url, Len(stream.thumbnail_url) - 20) + "896x504.jpg"
        result.game = getGameNameFromId(stream.game_id)
        result.live_duration = convertToTimeFormat(stream.started_at)
        ? "get viewer count > " stream.viewer_count
        result.viewer_count = numberToViewerText(stream.viewer_count)

        result.is_live = true
    else
        result.is_live = false
    end if

    search_results_url = "https://api.twitch.tv/helix/users/follows?first=1&to_id=" + result.id

    url = createUrl()
    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)

    if search <> invalid and search.total <> invalid
        result.followers = numberToText(search.total)
    else    
        result.followers = "0 followers"
    end if

    return result
end function