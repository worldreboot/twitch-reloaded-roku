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

    search_results_url = "https://api.twitch.tv/kraken/games/top?limit=" + limit.ToStr() + "&offset=" + m.top.offset +  "&client_id=jzkbprff40iqj646a697cyrvl0zt2m6"

    ? "GetCategories >> search > ";search_results_url

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.AddHeader("Accept", "application/vnd.twitchtv.v5+json")
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(search_results_url)

    response_string = url.GetToString()
    search = ParseJson(response_string)

    result = []
    if search.top <> invalid
        for each category in search.top
            item = {}
            item.id = category.game._id
            item.name = category.game.name
            item.logo = category.game.box.medium
            item.viewers = category.viewers
            result.push(item)
        end for
    end if

    return result
end function