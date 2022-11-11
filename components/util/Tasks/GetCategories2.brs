'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()

    m.top.searchResults = getSearchResults()

end function

function getSearchResults() as Object
    streams_data = ""
    if m.top.cursor = ""
        streams_data = ParseJson(POST("https://gql.twitch.tv/gql", "[{"+Chr(34)+"operationName"+Chr(34)+":"+Chr(34)+"BrowsePage_AllDirectories"+Chr(34)+","+Chr(34)+"variables"+Chr(34)+":{"+Chr(34)+"limit"+Chr(34)+":24,"+Chr(34)+"options"+Chr(34)+":{"+Chr(34)+"recommendationsContext"+Chr(34)+":{"+Chr(34)+"platform"+Chr(34)+":"+Chr(34)+"web"+Chr(34)+"},"+Chr(34)+"requestID"+Chr(34)+":"+Chr(34)+"JIRA-VXP-2397"+Chr(34)+","+Chr(34)+"sort"+Chr(34)+":"+Chr(34)+"VIEWER_COUNT"+Chr(34)+","+Chr(34)+"tags"+Chr(34)+":[]}},"+Chr(34)+"extensions"+Chr(34)+":{"+Chr(34)+"persistedQuery"+Chr(34)+":{"+Chr(34)+"version"+Chr(34)+":1,"+Chr(34)+"sha256Hash"+Chr(34)+":"+Chr(34)+"78957de9388098820e222c88ec14e85aaf6cf844adf44c8319c545c75fd63203"+Chr(34)+"}}}]"))
    else
        streams_data = ParseJson(POST("https://gql.twitch.tv/gql", "[{"+Chr(34)+"operationName"+Chr(34)+":"+Chr(34)+"BrowsePage_AllDirectories"+Chr(34)+","+Chr(34)+"variables"+Chr(34)+":{"+Chr(34)+"limit"+Chr(34)+":24,"+Chr(34)+"options"+Chr(34)+":{"+Chr(34)+"recommendationsContext"+Chr(34)+":{"+Chr(34)+"platform"+Chr(34)+":"+Chr(34)+"web"+Chr(34)+"},"+Chr(34)+"requestID"+Chr(34)+":"+Chr(34)+"JIRA-VXP-2397"+Chr(34)+","+Chr(34)+"sort"+Chr(34)+":"+Chr(34)+"VIEWER_COUNT"+Chr(34)+","+Chr(34)+"tags"+Chr(34)+":[]},"+Chr(34)+"cursor"+Chr(34)+":"+Chr(34)+ m.top.cursor +Chr(34)+"},"+Chr(34)+"extensions"+Chr(34)+":{"+Chr(34)+"persistedQuery"+Chr(34)+":{"+Chr(34)+"version"+Chr(34)+":1,"+Chr(34)+"sha256Hash"+Chr(34)+":"+Chr(34)+"78957de9388098820e222c88ec14e85aaf6cf844adf44c8319c545c75fd63203"+Chr(34)+"}}}]"))
    end if

    cursor = ""
    result = []
    if streams_data <> invalid and streams_data[0].data.directoriesWithTags.edges <> invalid
        for each category in streams_data[0].data.directoriesWithTags.edges
            item = {}
            item.id = category.node.id
            item.name = category.node.name
            avatarUrl = category.node.avatarURL
            item.logo = Left(avatarUrl, Len(avatarUrl) - 11) + "136x190.jpg"
            item.viewers = category.node.viewersCount
            cursor = category.cursor
            '? "item " item
            result.push(item)
        end for
    end if

    m.top.cursor = cursor

    return result
end function