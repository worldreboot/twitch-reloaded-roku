'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as Object
    search_results_url = "http://api.twitch.tv/kraken/search/channels?query=" + m.top.searchText + "&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(search_results_url)

    response_string = url.GetToString()
    search = ParseJson(response_string)
    
    result = []
    if search.channels <> invalid
        for each channel in search.channels
            item = {}
            item.id = channel._id
            item.name = channel.name
            item.logo = channel.logo
            result.push(item)
        end for
    end if

    return result
end function