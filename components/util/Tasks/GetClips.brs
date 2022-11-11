'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.gameNames = CreateObject("roAssociativeArray")
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getStartDate() as Object
    date = createObject("roDateTime")
    day = date.GetDayOfMonth()
    month = date.GetMonth()
    year = date.GetYear()
    if (day - 7) >= 1
        day -= 7
    else
        if (month - 1) >= 1
            month -= 1
        else
            month = 12
            year -= 1
        end if
        day = 28 + (day - 7)
    end if
    return_string = year.ToStr() + "-"
    if month < 10
        return_string += "0"
    end if
    return_string += month.ToStr() + "-"
    if day < 10
        return_string += "0"
    end if
    return_string += day.ToStr() + "T00:00:00Z"
    return return_string
end function

function getSearchResults() as Object
    'search_results_url = "https://api.twitch.tv/kraken/streams?client_id=jzkbprff40iqj646a697cyrvl0zt2m6&limit=24&offset=" + m.top.offset + "&game="
    search_results_url = "https://api.twitch.tv/helix/clips?first=21&started_at=" + getStartDate()

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

    if search.status <> invalid and search.status = 401
        ? "401"
        refreshToken()
        return getSearchResults()
    end if

    game_ids_url = "https://api.twitch.tv/helix/games?id="
    result = []
    if search <> invalid and search.data <> invalid
        for each clip in search.data
            item = {}
            item.broadcaster_name = clip.broadcaster_name
            item.creator_name = "Clipped by " + clip.creator_name
            item.title = clip.title
            item.viewer_count = clip.view_count
            item.thumbnail_url = clip.thumbnail_url
            'if Asc(stream.user_name) >= 144
            '    item.display_name = getEnglishDisplayName(stream.user_id)
            'else
            '    item.display_name = stream.user_name
            'end if
            result.push(item)
        end for
    end if

    if search.pagination.cursor <> invalid
        m.top.pagination = "&after=" + search.pagination.cursor
    end if

    return result
end function