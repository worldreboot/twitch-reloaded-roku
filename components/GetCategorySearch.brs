'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as Object
    search_results_url = "https://api.twitch.tv/kraken/search/games?query=" + m.top.searchText + "&type=suggest&client_id=jzkbprff40iqj646a697cyrvl0zt2m6"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.AddHeader("Accept", "application/vnd.twitchtv.v5+json")
    url.InitClientCertificates()
    url.SetUrl(search_results_url.EncodeUri())

    response_string = url.GetToString()
    search = ParseJson(response_string)

    result = []
    if search <> invalid and search.games <> invalid
        for each game in search.games
            item = {}
            item.id = game._id
            item.name = game.name
            item.logo = game.box.small
            result.push(item)
        end for
    end if

    return result
end function