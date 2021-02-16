'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.gameNames = CreateObject("roAssociativeArray")
    m.userProfiles = CreateObject("roAssociativeArray")
    m.userLogins = CreateObject("roAssociativeArray")
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getGameNameFromId(link)
    url = createUrl()
    'search_results_url = "https://api.twitch.tv/helix/games?id=" + id
    url.SetUrl(link.EncodeUri())
    '? "getGameNameFromId > ";link.EncodeUri()
    response_string = url.GetToString()
    search = ParseJson(response_string)
    'name = ""
    if search.data <> invalid
        'name = search.data[0].name
        for each game in search.data
            m.gameNames[game.id] = game.name
        end for
    end if
    'return name
end function

function getProfilePicture(link)
    url = createUrl()
    'search_url = "https://api.twitch.tv/helix/users?id=" + user_id.ToStr()
    url.SetUrl(link.EncodeUri())
    '? "getProfilePicture > ";link.EncodeUri()
    response_string = url.GetToString()
    search = ParseJson(response_string)
    if search.data = invalid
        return ""
    end if
    for each profile in search.data
        m.userLogins[profile.id] = profile.login
        'uri = search.data[0].profile_image_url
        uri = profile.profile_image_url
        '? "uri? "; uri
        last = Right(uri, 2)
        if last = "eg"
            m.userProfiles[profile.id] = Left(uri, Len(uri) - 12) + "50x50.jpeg"
        else if last = "pg"
            m.userProfiles[profile.id] = Left(uri, Len(uri) - 11) + "50x50.jpg"
        else
            m.userProfiles[profile.id] = Left(uri, Len(uri) - 11) + "50x50.png"
        end if
    end for
end function

function convertToTimeFormat(timestamp as String) as String
    secondsSincePublished = createObject("roDateTime")
    secondsSincePublished.FromISO8601String(timestamp)
    currentTime = createObject("roDateTime").AsSeconds()
    elapsedTime = currentTime - secondsSincePublished.AsSeconds()
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
    'search_results_url = "https://api.twitch.tv/kraken/streams?client_id=jzkbprff40iqj646a697cyrvl0zt2m6&limit=24&offset=" + m.top.offset + "&game="
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
        for each stream in search.data
            result.id = stream.id
            result.login = stream.login
            result.display_name = stream.display_name
            last = Right(stream.profile_image_url, 2)
            if last = "eg"
                result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 12) + "50x50.jpeg"
            else if last = "pg"
                result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 11) + "50x50.jpg"
            else
                result.profile_image_url = Left(stream.profile_image_url, Len(stream.profile_image_url) - 11) + "50x50.png"
            end if
        end for
    end if

    if result.id = invalid
        return result
    end if

    url2 = createUrl()

    user_follows_url = "https://api.twitch.tv/helix/users/follows?first=100&from_id=" + result.id
    url2.SetUrl(user_follows_url.EncodeUri())
    response_string = url2.GetToString()
    search = ParseJson(response_string)
    live_streamer_ids = {}
    if search <> invalid and search.data <> invalid
        result.followed_users = []
        total = search.total
        first_added_game = true
        current_added_games = 0
        game_ids_url = "https://api.twitch.tv/helix/games"
        user_ids_url = "https://api.twitch.tv/helix/users"
        current = 0
        addedGameIds = 0
        addedUserIds = 0
        while current < total
            '? "cursor > ";search.pagination.cursor
            if current <> 0
                url2 = createUrl()
                '? "id > ";result.id
                if search.pagination.cursor = invalid
                    if addedGameIds > 0
                        getGameNameFromId(game_ids_url)
                    end if
                    if addedUserIds > 0
                        getProfilePicture(user_ids_url)
                    end if
                    for each streamer in result.followed_users
                        streamer.game_id = m.gameNames[streamer.game_id]
                        streamer.profile_image_url = m.userProfiles[streamer.profile_image_url]
                    end for
                    result.followed_users.SortBy("viewer_count", "r")
                    return result
                end if
                user_follows_url = "https://api.twitch.tv/helix/users/follows?first=100&from_id=" + result.id + "&after=" + search.pagination.cursor
                url2.SetUrl(user_follows_url.EncodeUri())
                response_string = url2.GetToString()
                search = ParseJson(response_string)
            end if
            actually_added_followed_user = false
            actually_streaming_url = "https://api.twitch.tv/helix/streams?first=100"
            for each followed_user in search.data
                actually_streaming_url += "&user_id=" + followed_user.to_id
                actually_added_followed_user = true
                current += 1
            end for

            if not actually_added_followed_user then exit while

            url3 = createUrl()
            url3.SetUrl(actually_streaming_url.EncodeUri())
            response_string = url3.GetToString()
            search2 = ParseJson(response_string)
            for each streamer in search2.data
                item = {}
                item.user_name = streamer.user_name
                item.viewer_count = streamer.viewer_count
                item.game_id = streamer.game_id
                item.title = streamer.title
                item.thumbnail = Left(streamer.thumbnail_url, Len(streamer.thumbnail_url) - 20) + "320x180.jpg"
                item.live_duration = convertToTimeFormat(streamer.started_at)
                live_streamer_ids[streamer.user_id.ToStr()] = true
                if addedGameIds = 0
                    game_ids_url += "?id=" + streamer.game_id.ToStr()
                    addedGameIds += 1
                else if addedGameIds < 100
                    game_ids_url += "&id=" + streamer.game_id.ToStr()
                    addedGameIds += 1
                else if addedGameIds = 100
                    getGameNameFromId(game_ids_url)
                    game_ids_url = "https://api.twitch.tv/helix/games?id=" + streamer.game_id.ToStr()
                    addedGameIds = 1
                end if
                item.profile_image_url = streamer.user_id
                if addedUserIds = 0
                    user_ids_url += "?id=" + streamer.user_id.ToStr()
                    addedUserIds += 1
                else if addedUserIds < 100
                    user_ids_url += "&id=" + streamer.user_id.ToStr()
                    addedUserIds += 1
                else if addedUserIds = 100
                    getProfilePicture(user_ids_url)
                    user_ids_url = "https://api.twitch.tv/helix/users?id=" + streamer.user_id.ToStr()
                    addedUserIds = 1
                end if
                result.followed_users.push(item) 
            end for
        end while
        if addedGameIds > 0
            getGameNameFromId(game_ids_url)
        end if
        if addedUserIds > 0
            getProfilePicture(user_ids_url)
        end if
    end if

    for each streamer in result.followed_users
        streamer.game_id = m.gameNames[streamer.game_id]
        streamer.login = m.userLogins[streamer.profile_image_url]
        streamer.profile_image_url = m.userProfiles[streamer.profile_image_url]
    end for

    result.followed_users.SortBy("viewer_count", "r")

    m.top.currentlyLiveStreamerIds = live_streamer_ids
    '? "currentlyLiveStreamerIds getuser " m.top.currentlyLiveStreamerIds

    return result
end function