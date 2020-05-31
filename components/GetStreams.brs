'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as Object
    search_results_url = "https://api.twitch.tv/kraken/streams?client_id=jzkbprff40iqj646a697cyrvl0zt2m6&limit=24&offset=" + m.top.offset + "&game="

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    url.SetUrl(search_results_url.EncodeUri() + m.top.gameRequested.EncodeUriComponent())

    response_string = url.GetToString()
    search = ParseJson(response_string)
    result = []
    if search <> invalid and search.streams <> invalid
        for each stream in search.streams
            item = {}
            item.id = stream.channel._id
            item.display_name = stream.channel.display_name 
            item.name = stream.channel.name
            item.game = stream.game
            item.title = stream.channel.status
            item.viewers = stream.viewers
            item.thumbnail = stream.preview.medium
            result.push(item)
        end for
    end if

    return result
end function