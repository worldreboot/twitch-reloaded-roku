'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as Object
    search_results_url = "https://api.twitch.tv/helix/search/categories?query=" + m.top.searchText 

    url = createUrl()
    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)

    if search.status <> invalid and search.status = 401
        ? "401"
        refreshToken()
        return getSearchResults()
    end if

    result = []
    if search <> invalid and search.data <> invalid
        for each game in search.data
            item = {}
            item.id = game.id
            item.name = game.name
            item.logo = game.box_art_url
            result.push(item)
        end for
    end if

    return result
end function