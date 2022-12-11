'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as Object

    search_results_url = "https://api.twitch.tv/helix/search/channels?query=" + m.top.searchText + "&first=5"

    url = createUrl()
    url.SetUrl(search_results_url)

    response_string = url.GetToString()
    search = ParseJson(response_string)

    if search.status <> invalid and search.status = 401
        ? "401"
        refreshToken()
        return getSearchResults()
    end if

    result = []
    if search <> invalid and search.data <> invalid
        for each channel in search.data
            item = {}
            item.id = channel.id
            item.name = channel.display_name
            if channel.thumbnail_url <> invalid
                channel_logo = channel.thumbnail_url
                last = Right(channel_logo, 2)
                if last = "eg"
                    item.logo = Left(channel_logo, Len(channel_logo) - 12) + "50x50.jpeg"
                else if last = "pg"
                    item.logo = Left(channel_logo, Len(channel_logo) - 11) + "50x50.jpg"
                else
                    item.logo = Left(channel_logo, Len(channel_logo) - 11) + "50x50.png"
                end if
            end if
            result.push(item)
        end for 
    end if

    return result
end function