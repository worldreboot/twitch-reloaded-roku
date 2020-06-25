'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.gameNames = CreateObject("roAssociativeArray")
    m.userProfiles = CreateObject("roAssociativeArray")
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function createUrl()
    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.AddHeader("Client-ID", "w9msa6phhl3u8s2jyjcmshrfjczj2y")
    url.AddHeader("Authorization", "Bearer 4c4wmfffp3td582d17c1e76yveh3cd")
    return url
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

function getSearchResults() as Object
    'search_results_url = "https://api.twitch.tv/kraken/streams?client_id=jzkbprff40iqj646a697cyrvl0zt2m6&limit=24&offset=" + m.top.offset + "&game="
    search_results_url = "https://api.twitch.tv/helix/users?login=" + m.top.loginRequested

    url = createUrl()

    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)
    result = {}
    if search <> invalid and search.data <> invalid
        for each stream in search.data
            result.id = stream.id
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
            actually_streaming_url = "https://api.twitch.tv/helix/streams?first=100"
            for each followed_user in search.data
                actually_streaming_url += "&user_id=" + followed_user.to_id
                current += 1
            end for
            url3 = createUrl()
            url3.SetUrl(actually_streaming_url.EncodeUri())
            response_string = url3.GetToString()
            search2 = ParseJson(response_string)
            for each streamer in search2.data
                item = {}
                item.user_name = streamer.user_name
                item.viewer_count = streamer.viewer_count
                item.game_id = streamer.game_id
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
        streamer.profile_image_url = m.userProfiles[streamer.profile_image_url]
    end for

    result.followed_users.SortBy("viewer_count", "r")

    return result
end function