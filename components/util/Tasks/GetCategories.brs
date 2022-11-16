'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as Object
    limit = 24
    if m.top.offset = "0"
        limit = 25
    end if

    'search_results_url = "https://api.twitch.tv/kraken/games/top?limit=" + limit.ToStr() + "&offset=" + m.top.offset +  "&client_id=jzkbprff40iqj646a697cyrvl0zt2m6"
    search_results_url = "https://api.twitch.tv/helix/games/top?first=24"

    url = createUrl()

    if m.top.pagination <> ""
        search_results_url = search_results_url + m.top.pagination
    end if

    url.SetUrl(search_results_url)

    response_string = url.GetToString()
    search = ParseJson(response_string)

    if search.status <> invalid and search.status = 401
        ? "401"
        refreshToken()
        return getSearchResults()
    end if

    result = []
    if search.data <> invalid
        for each category in search.data
            item = {}
            item.id = category.id
            item.name = category.name
            item.logo = Left(category.box_art_url, Len(category.box_art_url) - 20) + "136x190.jpg"
            item.viewers = 0
            result.push(item)
        end for
    end if

    if search.pagination.cursor <> invalid
        m.top.pagination = "&after=" + search.pagination.cursor
    end if

    return result
end function