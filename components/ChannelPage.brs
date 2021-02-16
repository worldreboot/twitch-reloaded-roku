sub init()
    m.avatar = m.top.findNode("avatar")
    m.username = m.top.findNode("username")
    m.description = m.top.findNode("description")
    m.liveDuration = m.top.findNode("liveDuration")

    m.streamItem = m.top.findNode("streamItem")
    m.pastBroadcastsList = m.top.findNode("pastBroadcastsList")

    'm.liveButton = m.top.findNode("liveButton")
    'm.liveLine = m.top.findNode("liveLine")

    'm.videoButton = m.top.findNode("videoButton")
    'm.videoLine = m.top.findNode("videoLine")

    m.followers = m.top.findNode("followers")

    m.liveStreamLabel = m.top.findNode("liveStreamLabel")
    m.recentVideosLabel = m.top.findNode("recentVideosLabel")

    m.getUserChannel = createObject("roSGNode", "GetUserChannel")
    m.getUserChannel.observeField("searchResults", "onGetUserInfo")

    m.getVideos = createObject("roSGNode", "GetVideos")
    m.getVideos.observeField("searchResults", "onGetVideos")

    m.getStuff = createObject("roSGNode", "GetStuff")
    m.getStuff.observeField("streamUrl", "onGetVideoUrl")

    m.getStuffVideo = createObject("roSGNode", "GetStuffVideo")
    m.getStuffVideo.observeField("streamUrl", "onGetVideoUrl")

    m.streamItem.observeField("itemSelected", "onVideoItemSelect")
    m.pastBroadcastsList.observeField("itemSelected", "onVideoItemSelect")

    m.currentlySelectedTab = true

    m.top.observeField("streamerSelectedName", "onSelectedStreamerChange")

    m.top.observeField("visible", "onGetFocus")

    deviceInfo = CreateObject("roDeviceInfo")
    uiResolutionWidth = deviceInfo.GetUIResolution().width

    if uiResolutionWidth = 1920
        m.top.findNode("profileImageMask").maskSize = [75, 75]
    end if

    m.streamItem.setFocus(true)
end sub

sub onGetFocus()
    if m.top.visible
        if m.streamItem.visible
            m.streamItem.setFocus(true)
        else
            m.pastBroadcastsList.setFocus(true)
        end if
    end if
end sub

sub onGetVideoUrl()
    if m.pastBroadcastsList.hasFocus()
        m.top.thumbnailInfo = m.getStuffVideo.thumbnailInfo
        m.top.videoUrl = m.getStuffVideo.streamUrl
        ? "ChannelPage > thumbnailInfo > "; m.top.thumbnailInfo
    else m.streamItem.hasFocus()
        m.top.streamUrl = m.getStuff.streamUrl
    end if
end sub

sub onVideoItemSelect()
    if m.pastBroadcastsList.hasFocus()
        ? "ChannelPage >> video select "
        m.top.videoTitle = m.pastBroadcastsList.content.getChild(m.pastBroadcastsList.rowItemSelected[0]).getChild(m.pastBroadcastsList.rowItemSelected[1]).Title
        m.getStuffVideo.videoId = m.pastBroadcastsList.content.getChild(m.pastBroadcastsList.rowItemSelected[0]).getChild(m.pastBroadcastsList.rowItemSelected[1]).Rating
        m.getStuffVideo.control = "RUN"
    else if m.streamItem.hasFocus()
        ? "ChannelPage >> stream select"
        m.top.videoTitle = m.streamItem.content.getChild(0).getChild(0).ShortDescriptionLine2
        m.getStuff.streamerRequested = m.streamItem.content.getChild(m.streamItem.rowItemSelected[0]).getChild(m.streamItem.rowItemSelected[1]).ShortDescriptionLine1
        m.getStuff.control = "RUN"
    end if
end sub

sub onGetVideos()
    newList = false
    if m.pastBroadcastsList.content <> invalid
        content = m.pastBroadcastsList.content
        row = content.getChild(0)
    else
        content = createObject("roSGNode", "ContentNode")
        row = createObject("RoSGNode", "ContentNode")
        newList = true
    end if

    for each video in m.getVideos.searchResults
        rowItem = createObject("RoSGNode", "ContentNode")
        rowItem.Title = video.title
        rowItem.Description = video.display_name
        rowItem.Categories = video.duration
        rowItem.ReleaseDate = video.published_at
        rowItem.Rating = video.id
        '? "thumbnail: "; video.thumbnail_url
        if video.thumbnail_url <> ""
            rowItem.HDPosterUrl = video.thumbnail_url
        else
            rowItem.HDPosterUrl = "https://vod-secure.twitch.tv/_404/404_processing_320x180.png"
        end if
        rowItem.ShortDescriptionLine1 = m.top.streamerSelectedName
        rowItem.ShortDescriptionLine2 = video.viewer_count
        row.appendChild(rowItem)
    end for

    if newList
        content.appendChild(row)
    end if

    m.pastBroadcastsList.content = content
end sub

sub getMoreVideos()
    m.getVideos.userId = m.getUserChannel.searchResults.id
    m.getVideos.control = "RUN"
end sub

sub getVideos()
    m.getVideos.userId = m.getUserChannel.searchResults.id
    m.getVideos.pagination = ""
    m.getVideos.control = "RUN"
end sub

sub onGetUserInfo()
    m.username.text = m.getUserChannel.searchResults.display_name
    m.avatar.uri = m.getUserChannel.searchResults.profile_image_url
    tempDescription = createObject("roSGNode", "SimpleLabel")
    if m.getUserChannel.searchResults.description <> ""
        m.description.text = chr(34) + m.getUserChannel.searchResults.description + chr(34)
        tempDescription.text = chr(34) + m.getUserChannel.searchResults.description + chr(34)
    else
        m.description.text = ""
        tempDescription.text = ""
    end if
    if tempDescription.localBoundingRect().width <= 600
        m.description.translation = [1200 - tempDescription.localBoundingRect().width, 45]
    else
        m.description.translation = [600, 45]
    end if
    if m.getUserChannel.searchResults.is_live
        m.liveDuration.text = "Streaming for " + m.getUserChannel.searchResults.live_duration
        m.top.streamDurationSeconds = m.getUserChannel.streamDurationSeconds
    else
        m.liveDuration.text = ""
    end if
    if m.getUserChannel.searchResults.is_live
        m.streamItem.content.getChild(0).getChild(0).HDPosterUrl = m.getUserChannel.searchResults.thumbnail_url
    else
        m.streamItem.content.getChild(0).getChild(0).HDPosterUrl = m.getUserChannel.searchResults.offline_image_url
    end if
    m.streamItem.content.getChild(0).getChild(0).Description = m.getUserChannel.searchResults.display_name
    m.streamItem.content.getChild(0).getChild(0).ShortDescriptionLine2 = m.getUserChannel.searchResults.title
    m.streamItem.content.getChild(0).getChild(0).Categories = m.getUserChannel.searchResults.game
    m.streamItem.content.getChild(0).getChild(0).Title = m.getUserChannel.searchResults.viewer_count
    m.followers.text = m.getUserChannel.searchResults.followers
    getVideos()
end sub

sub onSelectedStreamerChange()
    content = createObject("roSGNode", "ContentNode")
    row = createObject("RoSGNode", "ContentNode")
    rowItem = createObject("RoSGNode", "ContentNode")
    'rowItem.Title = stream.title
    'rowItem.Description = stream.display_name
    'rowItem.Categories = stream.game
    if m.top.streamerSelectedThumbnail <> ""
        rowItem.HDPosterUrl = m.top.streamerSelectedThumbnail
    end if
    rowItem.ShortDescriptionLine1 = m.top.streamerSelectedName
    'rowItem.ShortDescriptionLine2 = numberToText(stream.viewers)
    row.appendChild(rowItem)
    content.appendChild(row)

    m.streamItem.content = content

    m.streamItem.setFocus(true)

    m.pastBroadcastsList.content = invalid

    m.getUserChannel.loginRequested = m.top.streamerSelectedName
    m.getUserChannel.control = "RUN"
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false

    if press
        if key = "up" and m.pastBroadcastsList.hasFocus()
            m.currentlySelectedTab = true

            'm.liveButton.color = "0xA970FFFF"
            'm.liveLine.visible = true

            'm.videoButton.color = "0xEFEFF1FF"
            'm.videoLine.visible = false

            'm.pastBroadcastsList.visible = false
            'm.streamItem.visible = true
            m.streamItem.setFocus(true)
            m.liveStreamLabel.color = "0xA172F7FF"
            m.recentVideosLabel.color = "0xB9B9B9FF"
            handled = true
        else if key = "down" and m.streamItem.hasFocus()
            m.pastBroadcastsList.setFocus(true)
            m.liveStreamLabel.color = "0xB9B9B9FF"
            m.recentVideosLabel.color = "0xA172F7FF"
            handled = true
        else if key = "right" and m.pastBroadcastsList.hasFocus()
            getMoreVideos()
            handled = true
        else if key = "back"
            ? "ChannelPage back"
            'm.pastBroadcastsList.visible = false
            m.pastBroadcastsList.content = invalid
            'm.streamItem.visible = true

            'm.liveButton.color = "0xA970FFFF"
            'm.liveLine.visible = true

            'm.videoButton.color = "0xEFEFF1FF"
            'm.videoLine.visible = false
            'm.top.visible = false
        end if
    end if

    return handled
end sub
