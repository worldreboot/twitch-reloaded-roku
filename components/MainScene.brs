'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()
    ' environment_variables = ReadAsciiFile("pkg:/env").Split(Chr(10))
    ' for each var in environment_variables
    '     var_info = var.Split("=")
    '     if var_info[0] = "CLIENT-ID"
    '         m.global.addFields({CLIENT_ID: Left(var_info[1], Len(var_info[1]) - 1)})
    '     else if var_info[0] = "AUTHORIZATION"
    '         m.global.addFields({AUTHORIZATION: var_info[1]})
    '     end if
    ' end for

    m.instructions = m.top.findNode("instructions")

    m.getStatus = createObject("roSGNode", "GetStatus")
    m.getStatus.observeField("appStatus", "onAppStatusReceived")
    m.getStatus.control = "RUN"

    m.videoPlayer = m.top.findNode("videoPlayer")
    m.keyboardGroup = m.top.findNode("keyboardGroup")
    m.homeScene = m.top.findNode("homeScene")
    m.categoryScene = m.top.findNode("categoryScene")
    ' m.channelPage = m.top.findNode("channelPage")
    m.loginPage = m.top.findNode("loginPage")

    m.keyboardGroup.observeField("streamUrl", "onStreamChange")
    m.keyboardGroup.observeField("streamerSelectedName", "onStreamerSelected")

    m.homeScene.observeField("streamUrl", "onStreamChange")
    m.homeScene.observeField("streamerSelectedName", "onStreamerSelected")
    m.homeScene.observeField("categorySelected", "onCategoryItemSelect")
    m.homeScene.observeField("buttonPressed", "onHeaderButtonPress")
    m.homeScene.observeField("videoUrl", "onStreamChangeFromChannelPage")

    m.keyboardGroup.observeField("categorySelected", "onCategoryItemSelectFromSearch")

    m.categoryScene.observeField("streamUrl", "onStreamChange")
    m.categoryScene.observeField("streamerSelectedThumbnail", "onStreamerSelected")
    m.categoryScene.observeField("clipUrl", "onClipChange")

    ' m.channelPage.observeField("videoUrl", "onStreamChangeFromChannelPage")
    ' m.channelPage.observeField("streamUrl", "onStreamChange")

    m.loginPage.observeField("finished", "onLoginFinish")

    m.videoPlayer.observeField("back", "onVideoPlayerBack")
    m.videoPlayer.observeField("toggleChat", "onToggleChat")
    m.videoPlayer.observeField("streamLayoutMode", "onToggleStreamLayout")

    m.top.backgroundColor = "0x18181BFF"
    m.top.backgroundUri = ""

    m.currentScene = "home"
    m.lastScene = ""
    m.lastLastScene = ""

    getInfo = createObject("RoSGNode", "GetInfo")
    getInfo.control = "RUN"

    m.stream = createObject("RoSGNode", "ContentNode")
    m.stream["streamFormat"] = "hls"

    m.getToken = createObject("roSGNode", "GetToken")
    m.getToken.observeField("appBearerToken", "onBearerTokenReceived")
    m.getToken.control = "RUN"

    m.login = ""
    m.getUser = createObject("roSGNode", "GetUser")
    m.getUser.observeField("searchResults", "onUserLogin")

    m.testtimer = m.top.findNode("testTimer")
    m.testtimer.control = "start"
    m.testtimer.ObserveField("fire", "refreshFollows")

    if checkRegistrySection("LoggedInUserData", "Reset") = invalid
        sec = createObject("roRegistrySection", "LoggedInUserData")
        sec.Write("UserToken", "")
        sec.Write("RefreshToken", "")
        sec.Write("LoggedInUser", "")
        ? "RESETTED"
        ' setReset("true")
        setRegistrySection("LoggedInUserData", "Reset", "true")
    end if

    ' registry = CreateObject("roRegistry")
    ' registry.Delete("LoggedInUserData")
    ' registry.Delete("VideoSettings")

    ' loggedInUser = checkIfLoggedIn()
    loggedInUser = checkRegistrySection("LoggedInUserData", "LoggedInUser")
    if loggedInUser <> invalid
        m.getUser.loginRequested = loggedInUser
        m.getUser.control = "RUN"
        m.login = loggedInUser
    end if

    ' videoQuality = checkSavedVideoQuality()
    videoQuality = checkRegistrySection("VideoSettings", "VideoQuality")
    if videoQuality <> invalid
        m.global.addFields({ videoQuality: Int(Val(videoQuality)) })
    else
        m.global.addFields({ videoQuality: 2 })
    end if

    ' videoFramerate = checkSavedVideoFramerate()
    videoFramerate = checkRegistrySection("VideoSettings", "VideoFramerate")
    if videoQuality <> invalid
        m.global.addFields({ videoFramerate: Int(Val(videoFramerate)) })
    else
        m.global.addFields({ videoFramerate: 60 })
    end if

    ' chatOption = checkSavedChatOption()
    chatOption = checkRegistrySection("VideoSettings", "ChatOption")
    if chatOption <> invalid and chatOption = "true"
        m.global.addFields({ chatOption: true })
    else
        m.global.addFields({ chatOption: false })
    end if

    ' userToken = checkUserToken()
    userToken = checkRegistrySection("LoggedInUserData", "UserToken")
    if userToken <> invalid and userToken <> ""
        m.global.addFields({ userToken: userToken })
    else
        m.global.addFields({ userToken: "" })
    end if

    ' videoBookmarks = checkVideoBookmarks()
    videoBookmarks = checkRegistrySection("VideoSettings", "VideoBookmarks")
    ? "MainScene >> videoBookmarks > " videoBookmarks
    if videoBookmarks <> invalid
        'm.videoPlayer.videoBookmarks = {}
        m.videoPlayer.videoBookmarks = ParseJSON(videoBookmarks)
        ? "MainScene >> ParseJSON > " m.videoPlayer.videoBookmarks
    else
        m.videoPlayer.videoBookmarks = {}
    end if

    recentStreamers = checkRegistrySection("LoggedInUserData", "RecentStreamers")
    if recentStreamers <> invalid and recentStreamers <> ""
        parsedRecents = ParseJSON(recentStreamers)
        m.homeScene.recentStreamers = parsedRecents.recents
    else
        m.homeScene.recentStreamers = []
    end if

    ? "MainScene >> registry space > " createObject("roRegistry").GetSpaceAvailable()

    deviceInfo = CreateObject("roDeviceInfo")
    m.uiResolutionWidth = deviceInfo.GetUIResolution().width

    m.chat = m.top.findNode("chat")
    m.chat.observeField("doneFocus", "onChatDoneFocus")

    m.options = createObject("roSGNode", "Options")
    m.options.visible = false

    m.top.appendChild(m.options)

    m.homeScene.setFocus(true)
    m.videoPlayer.notificationInterval = 1
    m.plyrTask = invalid
end function

function playVideo(stream as object)
    m.videoPlayer.width = 0
    m.videoPlayer.height = 0
    m.videoPlayer.setFocus(true)
    if m.keyboardGroup.visible
        m.keyboardGroup.visible = false
    end if
    if not m.videoPlayer.visible
        m.videoPlayer.visible = true
    end if
    if invalid = m.plyrTask
        m.plyrTask = createObject("roSGNode", "playerTask")
        m.plyrTask.observeField("state", "onTaskStateUpdated")
    end if
    streamConfig = {
        title: ""
        streamformat: stream["streamFormat"]
        useStitched: true
        live: false
        url: stream["url"]
        type: "vod"
        streamtype: "vod"
        player: { sgnode: m.videoPlayer }
    }
    if stream["streamFormat"] = "hls"
        streamConfig.live = true
        streamConfig.type = "live"
        streamConfig.streamtype = "live"
    end if
    m.plyrTask.streamConfig = streamConfig
    m.plyrTask.video = m.videoPlayer
    m.plyrTask.control = "run"
end function

sub onChatDoneFocus()
    if m.chat.doneFocus
        m.videoPlayer.setFocus(true)
        m.chat.doneFocus = false
    end if
end sub

sub onLoginFinish()
    if m.loginPage.finished = true
        ' loggedInUser = checkIfLoggedIn()
        loggedInUser = checkRegistrySection("LoggedInUserData", "LoggedInUser")
        if loggedInUser <> invalid
            m.getUser.loginRequested = loggedInUser
            m.getUser.control = "RUN"
            m.login = loggedInUser
        end if
        m.loginPage.visible = false
        m.homeScene.visible = false
        m.homeScene.visible = true
        m.homeScene.setFocus(true)
        m.loginPage.finished = false
    end if
end sub

sub onBearerTokenReceived()
    m.global.addFields({ appBearerToken: m.getToken.appBearerToken })
end sub

sub onAppStatusReceived()
    ? "onAppStatusReceived >> " m.getStatus.appStatus
    if m.getStatus.appStatus = "true"
        m.instructions.visible = true
    end if
end sub

sub onStreamChangeFromChannelPage()
    m.stream["streamFormat"] = "hls"
    m.stream["url"] = m.homeScene.videoUrl
    m.chat.visible = false
    m.videoPlayer.chatIsVisible = m.chat.visible

    m.videoPlayer.videoTitle = m.homeScene.videoTitle
    m.videoPlayer.channelUsername = m.homeScene.channelUsername
    'm.videoPlayer.channelAvatar =  ""
    m.videoPlayer.channelAvatar = m.homeScene.channelAvatar
    updateRecents()
    ' m.channelPage.visible = false
    m.videoPlayer.thumbnailInfo = m.homeScene.thumbnailInfo
    m.homeScene.thumbnailInfo = invalid
    playVideo(m.stream)
    if m.videoPlayer.thumbnailInfo <> invalid
        if m.videoPlayer.videoBookmarks.DoesExist(m.videoPlayer.thumbnailInfo.video_id.ToStr())
            ? "MainScene >> position > " m.videoPlayer.videoBookmarks[m.videoPlayer.thumbnailInfo.video_id.ToStr()]
            m.videoPlayer.seek = Val(m.videoPlayer.videoBookmarks[m.videoPlayer.thumbnailInfo.video_id.ToStr()])
        end if
    end if
end sub

sub updateRecents()
    recents = m.homeScene.recentStreamers
    for streamer = 0 to recents.count() - 1
        if recents[streamer].user_name = m.homeScene.channelUsername
            recents.delete(streamer)
            exit for
        end if
    end for
    streamer = {
        user_name: m.homeScene.channelUsername,
        profile_image_url: m.homeScene.channelAvatar,
        login: m.homeScene.streamerSelectedName
    }
    recents.push(streamer)
    m.homeScene.recentStreamers = recents
    sec = createObject("roRegistrySection", "LoggedInUserData")
    sec.Write("RecentStreamers", FormatJSON({ recents: recents }))
end sub

sub onStreamerSelected()
    if m.homeScene.visible
        'm.channelPage.streamerSelectedName = m.homeScene.streamerSelectedName
        'm.channelPage.streamerSelectedThumbnail = m.homeScene.streamerSelectedThumbnail
        m.lastScene = "home"
    else if m.categoryScene.visible
        m.homeScene.lastScene = "category"
        m.homeScene.streamerSelectedThumbnail = m.categoryScene.streamerSelectedThumbnail
        m.homeScene.streamerSelectedName = m.categoryScene.streamerSelectedName
        m.lastLastScene = "home" 'm.lastScene
        m.lastScene = "category"
    else if m.keyboardGroup.visible
        'm.channelPage.streamerSelectedName = m.keyboardGroup.streamerSelectedName
        'm.channelPage.streamerSelectedThumbnail = ""
        m.homeScene.streamerSelectedName = m.keyboardGroup.streamerSelectedName
        m.homeScene.streamerSelectedThumbnail = ""
        m.lastLastScene = "home"
        m.lastScene = "search"
    end if
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = false

    'm.channelPage.visible = true
    m.homeScene.visible = true

    m.currentScene = "channel"
end sub

function checkRegistrySection(section as object, key as object)
    sec = createObject("roRegistrySection", section)
    if sec.Exists(key)
        return sec.Read(key)
    end if
    return invalid
end function

function setRegistrySection(section as object, key as object, value as object)
    sec = createObject("roRegistrySection", section)
    sec.Write(key, value)
    sec.Flush()
end function

' function setReset(word as String) as Void
'     sec = createObject("roRegistrySection", "LoggedInUserData")
'     sec.Write("Reset", word)
'     sec.Flush()
' end function

' function saveLogin() as Void
'     sec = createObject("roRegistrySection", "LoggedInUserData")
'     sec.Write("LoggedInUser", m.homeScene.loggedInUserName)
'     sec.Flush()
' end function

function onHeaderButtonPress()
    if m.homeScene.buttonPressed = "search"
        m.homeScene.visible = false
        m.keyboardGroup.visible = true
        m.keyboardGroup.setFocus(true)
    else if m.homeScene.buttonPressed = "login"
        'm.top.dialog = createObject("RoSGNode", "LoginPrompt")
        'm.top.dialog.observeField("buttonSelected", "onLogin")
        m.homeScene.visible = false
        m.loginPage.visible = true
        m.loginPage.setFocus(true)
    else if m.homeScene.buttonPressed = "options"
        m.homeScene.visible = false
        m.options.visible = true
        m.options.setFocus(true)
    end if
end function

function onUserLogin()
    m.homeScene.loggedInUserName = m.getUser.searchResults.display_name
    m.homeScene.loggedInUserProfileImage = m.getUser.searchResults.profile_image_url
    m.chat.loggedInUsername = m.getUser.searchResults.login
    m.homeScene.followedStreams = m.getUser.searchResults.followed_users
    m.homeScene.currentlyLiveStreamerIds = m.getUser.currentlyLiveStreamerIds
    '? "currentlyLiveStreamerIds mainscene " m.getUser.currentlyLiveStreamerIds
    ' saveLogin()
    setRegistrySection("LoggedInUserData", "LoggedInUser", m.homeScene.loggedInUserName)
end function

function onCategoryItemSelectFromSearch()
    m.categoryScene.currentCategory = m.keyboardGroup.categorySelected
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = true
    m.lastLastScene = "home"
    m.lastScene = "search"
end function

function onCategoryItemSelect()
    m.categoryScene.currentCategory = m.homeScene.categorySelected
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = true
    m.lastScene = "home"
end function

function onClipChange()
    m.categoryScene.fromClip = true
    m.stream["streamFormat"] = "mp4"
    if m.categoryScene.visible = true
        m.currentScene = "category"
        m.stream["url"] = m.categoryScene.clipUrl
    end if
    m.categoryScene.visible = false
    playVideo(m.stream)
end function

function onStreamChange()
    m.stream["streamFormat"] = "hls"
    if m.keyboardGroup.visible
        m.currentScene = "search"
        m.chat.channel = m.keyboardGroup.streamerRequested
        m.stream["url"] = m.keyboardGroup.streamUrl
    else if m.homeScene.visible
        m.currentScene = "home"
        m.chat.channel = m.homeScene.streamerSelectedName 'm.homeScene.streamerRequested
        m.videoPlayer.videoTitle = m.homeScene.videoTitle
        m.videoPlayer.channelUsername = m.homeScene.channelUsername
        m.videoPlayer.channelAvatar = m.homeScene.channelAvatar
        updateRecents()
        m.videoPlayer.streamDurationSeconds = m.homeScene.streamDurationSeconds
        m.stream["url"] = m.homeScene.streamUrl
    else if m.categoryScene.visible
        m.currentScene = "category"
        m.chat.channel = m.categoryScene.streamerRequested
        m.stream["url"] = m.categoryScene.streamUrl
        ' else if m.channelPage.visible
        '     m.currentScene = "channel"
        '     m.channelPage.visible = false
        '     m.chat.channel = m.channelPage.streamerSelectedName
        '     m.stream["url"] = m.channelPage.streamUrl
    end if
    ' m.chat.visible = m.global.chatOption
    ' m.videoPlayer.chatIsVisible = m.chat.visible
    onToggleStreamLayout()
    playVideo(m.stream)
end function

function refreshFollows()
    if m.login <> ""
        m.getUser.loginRequested = m.login
        m.getUser.control = "RUN"
    end if
end function

function onLogin()
    m.login = m.top.dialog.text
    '? "login > "; m.login
    m.top.dialog.close = true
    m.getUser.loginRequested = m.login
    m.getUser.control = "RUN"
end function

sub onVideoPlayerBack()
    if m.videoPlayer.back = true
        m.videoPlayer.control = "stop"
        m.videoPlayer.visible = false
        m.keyboardGroup.visible = false
        if m.currentScene = "home"
            m.homeScene.visible = false
            m.homeScene.visible = true
            m.homeScene.setFocus(true)
        else if m.currentScene = "category"
            m.categoryScene.visible = true
            'm.categoryScene.fromClip = false
            m.categoryScene.setFocus(true)
        else if m.currentScene = "search"
            m.keyboardGroup.visible = true
        else if m.currentScene = "channel"
            m.homeScene.visible = false
            m.homeScene.visible = true
            m.homeScene.setFocus(true)
            'm.channelPage.visible = true
            'm.channelPage.setFocus(true)
        end if
        m.chat.visible = false
        m.videoPlayer.chatIsVisible = m.chat.visible
        m.videoPlayer.back = false
    end if
end sub

sub onToggleChat()
    if m.videoPlayer.toggleChat = true
        m.chat.visible = not m.chat.visible
        m.videoPlayer.chatIsVisible = m.chat.visible
        m.videoPlayer.toggleChat = false
    end if
end sub

sub onToggleStreamLayout()
    if m.videoPlayer.streamLayoutMode = 0 'stream is shrinked
        m.videoPlayer.width = 1030
        m.videoPlayer.height = 720
        m.chat.visible = true
        m.videoPlayer.chatIsVisible = m.chat.visible
    else if m.videoPlayer.streamLayoutMode = 1 'layout with chat on top of stream
        m.videoPlayer.width = 0
        m.videoPlayer.height = 0
        m.chat.visible = true
        m.videoPlayer.chatIsVisible = m.chat.visible
    else if m.videoPlayer.streamLayoutMode = 2 'no chat layout fullscreen
        m.videoPlayer.width = 0
        m.videoPlayer.height = 0
        m.chat.visible = false
        m.videoPlayer.chatIsVisible = m.chat.visible
    end if
end sub

function onKeyEvent(key, press) as boolean
    handled = false
    if press
        if m.videoPlayer.visible = true and key = "back"
            m.videoPlayer.back = true
            handled = true
        else if m.videoPlayer.visible = true and key = "rewind"
            'm.chat.visible = not m.chat.visible
            'handled = true
        else if m.homeScene.visible = true and key = "options"
            m.homeScene.visible = false
            m.keyboardGroup.visible = true
            m.keyboardGroup.setFocus(true)
            handled = true
        else if m.options.visible and key = "back"
            m.options.visible = false
            m.homeScene.visible = false
            m.homeScene.visible = true
            m.homeScene.setFocus(true)
            handled = true
            'else if (m.keyboardGroup.visible or m.categoryScene.visible or m.channelPage.visible) and key = "back"
        else if (m.keyboardGroup.visible or m.categoryScene.visible) and key = "back"
            m.categoryScene.visible = false
            m.keyboardGroup.visible = false
            m.options.visible = false
            'm.channelPage.visible = false
            m.homeScene.visible = false
            if m.lastScene = "home"
                m.homeScene.visible = false
                m.homeScene.visible = true
                m.homeScene.setFocus(true)
            else if m.lastScene = "category"
                m.lastScene = m.lastLastScene
                m.lastLastScene = "home"
                m.categoryScene.visible = true
                'm.categoryScene.fromClip = false
                m.categoryScene.setFocus(true)
            else if m.lastScene = "search"
                m.lastScene = m.lastLastScene
                m.lastLastScene = "home"
                m.keyboardGroup.visible = true
            else
                m.homeScene.visible = false
                m.homeScene.visible = true
                m.homeScene.setFocus(true)
            end if
            handled = true
        else if m.homeScene.visible and key = "back"
            if m.homeScene.lastScene = "category"
                m.homeScene.visible = false
                m.categoryScene.visible = true
                m.lastScene = m.lastLastScene
                m.lastLastScene = "home"
                'm.categoryScene.setFocus(true)
                handled = true
            end if
            'handled = true
        else if m.loginPage.visible and key = "back"
            m.loginPage.visible = false
            m.homeScene.visible = false
            m.homeScene.visible = true
            m.homeScene.setFocus(true)
            return true
        else if key = "OK" and m.videoPlayer.visible
            m.chat.setKeyboardFocus = true
            handled = true
        end if
    end if

    '? "MAINSCENE > handled " handled " > (" key ", " press ")"
    return handled
end function