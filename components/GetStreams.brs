'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.gameNames = CreateObject("roAssociativeArray")
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
    url.AddHeader("Client-ID", m.global.CLIENT_ID)
    url.AddHeader("Authorization", m.global.AUTHORIZATION)
    return url
end function

function getGameNameFromId(game_ids_url)
    url = createUrl()
    url.SetUrl(game_ids_url.EncodeUri())
    response_string = url.GetToString()
    search = ParseJson(response_string)
    if search.data <> invalid
        for each game in search.data
            m.gameNames[game.id] = game.name
        end for
    end if
end function

function getEnglishDisplayName(id)
    url = createUrl()
    search_results_url = "https://api.twitch.tv/helix/users?id=" + id
    url.SetUrl(search_results_url.EncodeUri())
    response_string = url.GetToString()
    search = ParseJson(response_string)
    name = ""
    if search.data[0] <> invalid
        name = search.data[0].login
    end if
    return name
end function

function getSearchResults() as Object
    'search_results_url = "https://api.twitch.tv/kraken/streams?client_id=jzkbprff40iqj646a697cyrvl0zt2m6&limit=24&offset=" + m.top.offset + "&game="
    search_results_url = "https://api.twitch.tv/helix/streams?first=21"

    if m.top.gameRequested <> ""
        search_results_url = search_results_url + "&game_id=" + m.top.gameRequested
    end if

    url = createUrl()
    
    'url.SetUrl(search_results_url.EncodeUri() + m.top.gameRequested.EncodeUriComponent())

    if m.top.pagination <> ""
        search_results_url = search_results_url + m.top.pagination
    end if

    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)
    game_ids_url = "https://api.twitch.tv/helix/games?id="
    first = true
    result = []
    if search <> invalid and search.data <> invalid
        for each stream in search.data
            item = {}
            item.id = stream.user_id
            if Asc(stream.user_name) >= 144
                item.display_name = getEnglishDisplayName(stream.user_id)
            else
                item.display_name = stream.user_name
            end if
            item.game_id = stream.game_id
            item.name = LCase(item.display_name)
            'if m.gameNames.DoesExist(stream.game_id.ToStr())
                'item.game = m.gameNames[stream.game_id.ToStr()]
            'else
                'item.game = getGameNameFromId(stream.game_id)
            'end if
            if first = false
                game_ids_url += "&id=" + stream.game_id
            else
                game_ids_url += stream.game_id
            end if
            item.title = stream.title
            item.viewers = stream.viewer_count
            item.thumbnail = Left(stream.thumbnail_url, Len(stream.thumbnail_url) - 20) + "320x180.jpg"
            result.push(item)
            first = false
        end for
        getGameNameFromId(game_ids_url)
        for each stream in result
            stream.game = m.gameNames[stream.game_id]
        end for
    end if

    if search.pagination.cursor <> invalid
        m.top.pagination = "&after=" + search.pagination.cursor
    end if

    return result
end function