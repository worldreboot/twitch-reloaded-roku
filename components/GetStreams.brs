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
    url.AddHeader("Client-ID", "w9msa6phhl3u8s2jyjcmshrfjczj2y")
    url.AddHeader("Authorization", "Bearer 4c4wmfffp3td582d17c1e76yveh3cd")
    return url
end function

function getGameNameFromId(id)
    url = createUrl()
    search_results_url = "https://api.twitch.tv/helix/games?id=" + id
    url.SetUrl(search_results_url.EncodeUri())
    response_string = url.GetToString()
    search = ParseJson(response_string)
    name = search.data[0].name
    m.gameNames[id] = name
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
    result = []
    if search <> invalid and search.data <> invalid
        for each stream in search.data
            item = {}
            item.id = stream.user_id
            item.display_name = stream.user_name
            item.name = LCase(item.display_name)
            if m.gameNames.DoesExist(stream.game_id.ToStr())
                item.game = m.gameNames[stream.game_id.ToStr()]
            else
                item.game = getGameNameFromId(stream.game_id)
            end if
            item.title = stream.title
            item.viewers = stream.viewer_count
            item.thumbnail = Left(stream.thumbnail_url, Len(stream.thumbnail_url) - 20) + "320x180.jpg"
            result.push(item)
        end for
    end if

    if search.pagination.cursor <> invalid
        m.top.pagination = "&after=" + search.pagination.cursor
    end if

    return result
end function