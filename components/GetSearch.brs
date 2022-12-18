'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as Object
    ' search_results_url = "http://api.twitch.tv/kraken/search/channels?query=" + m.top.searchText + "&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6"
    search_results_url = "https://api.twitch.tv/helix/search/channels?query=" + m.top.searchText + "&limit=5"

    ' url = CreateObject("roUrlTransfer")
    ' url.EnableEncodings(true)
    ' url.RetainBodyOnError(true)
    ' url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    ' url.AddHeader("Accept", "application/vnd.twitchtv.v5+json")
    ' url.InitClientCertificates()
    ' url.SetUrl(search_results_url)

    ' response_string = url.GetToString()
    ' search = ParseJson(response_string)

    search = GETJSON(search_results_url)

    ' ? "wtf is hjappenign: " search.data[0]

    result = []
    if search <> invalid and search.data <> invalid
        for each channel in search.data
            ? "SEARCH: " channel
            item = {}
            item.id = channel.id
            item.login = channel.broadcaster_login
            item.name = channel.display_name
            if channel.thumbnail_url <> invalid
                last = Right(channel.thumbnail_url, 2)
                if last = "eg"
                    item.logo = Left(channel.thumbnail_url, Len(channel.thumbnail_url) - 12) + "50x50.jpeg"
                else if last = "pg"
                    item.logo = Left(channel.thumbnail_url, Len(channel.thumbnail_url) - 11) + "50x50.jpg"
                else
                    item.logo = Left(channel.thumbnail_url, Len(channel.thumbnail_url) - 11) + "50x50.png"
                end if
            end if
            result.push(item)
        end for
    end if

    return result
end function