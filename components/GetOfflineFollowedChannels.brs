'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    m.top.functionName = "onSearchTextChange"
end function

function onSearchTextChange()
    m.top.offlineFollowedUsers = getSearchResults()
end function

function getRecentChannels() as Boolean
    sec = createObject("roRegistrySection", "LoggedInUserData")
    if sec.Exists("RecentChannels")
        m.global.addFields({recentChannels: ParseJson(sec.Read("RecentChannels"))})
        return true
    end if
    return false
end function

function getSearchResults() as Object
    current_user_info = GETJSON("https://api.twitch.tv/helix/users?login=" + m.top.loginRequested)
    followed_streamers = GETJSON("https://api.twitch.tv/helix/users/follows?first=100&from_id=" + current_user_info.data[0].id)
    addedUsers = 0
    totalUsers = followed_streamers.total
    appended = false
    streamer_info_url = "https://api.twitch.tv/helix/users"
    addedChannelLogins = {}
    offlineFollowedStreamers = []
    while true
        for each streamer in followed_streamers.data
            appended = false
            if not m.top.currentlyLiveStreamerIds.DoesExist(streamer.to_id)
                if addedUsers = 0
                    streamer_info_url += "?id=" + streamer.to_id
                    addedUsers += 1
                else if addedUsers < 100
                    streamer_info_url += "&id=" + streamer.to_id
                    addedUsers += 1
                end if
            end if
            if addedUsers = 100
                offline_streamer_info = GETJSON(streamer_info_url)
                for each offline_streamer in offline_streamer_info.data
                    streamer_info = {}
                    streamer_info.login = offline_streamer.login
                    streamer_info.display_name = offline_streamer.display_name
                    streamer_info.profile_image_url = offline_streamer.profile_image_url
                    offlineFollowedStreamers.push(streamer_info)
                end for
                appended = true
                addedUsers = 0
                streamer_info_url = "https://api.twitch.tv/helix/users"
            end if
        end for
        'addedUsers = 0
        if followed_streamers.pagination.cursor <> invalid
            '? "GetOfflineFollowedChannels > next > " "https://api.twitch.tv/helix/users/follows?first=100&from_id=" + current_user_info.data[0].id + "&after=" + followed_streamers.pagination.cursor
            followed_streamers = GETJSON("https://api.twitch.tv/helix/users/follows?first=100&from_id=" + current_user_info.data[0].id + "&after=" + followed_streamers.pagination.cursor)
        else
            if appended = false
                '? "GetOfflineFollowedChannels > last round > " streamer_info_url
                offline_streamer_info = GETJSON(streamer_info_url)
                for each offline_streamer in offline_streamer_info.data
                    streamer_info = {}
                    streamer_info.login = offline_streamer.login
                    addedChannelLogins[streamer_info.login] = true
                    streamer_info.display_name = offline_streamer.display_name
                    profile_pic_uri = offline_streamer.profile_image_url
                    last = Right(profile_pic_uri, 2)
                    if last = "eg"
                        streamer_info.profile_image_url = Left(profile_pic_uri, Len(profile_pic_uri) - 12) + "150x150.jpeg"
                    else if last = "pg"
                        streamer_info.profile_image_url = Left(profile_pic_uri, Len(profile_pic_uri) - 11) + "150x150.jpg"
                    else
                        streamer_info.profile_image_url = Left(profile_pic_uri, Len(profile_pic_uri) - 11) + "150x150.png"
                    end if
                    'streamer_info.profile_image_url = offline_streamer.profile_image_url
                    offlineFollowedStreamers.push(streamer_info)
                end for
            end if
            exit while
        end if
    end while

    successfullyLoadedRecentChannels = getRecentChannels()
    if successfullyLoadedRecentChannels
        for each channel_login in m.global.recentChannels
            if addedChannelLogins[channel_login]
                
            end if
        end for
    end if

    return offlineFollowedStreamers
end function