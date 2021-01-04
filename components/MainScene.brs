'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()
    environment_variables = ReadAsciiFile("pkg:/env").Split(Chr(10))
    for each var in environment_variables
        var_info = var.Split("=")
        if var_info[0] = "CLIENT-ID"
            m.global.addFields({CLIENT_ID: Left(var_info[1], Len(var_info[1]) - 1)})
        else if var_info[0] = "AUTHORIZATION"
            m.global.addFields({AUTHORIZATION: var_info[1]})
        end if
    end for

    m.videoPlayer = m.top.findNode("videoPlayer")
    m.keyboardGroup = m.top.findNode("keyboardGroup")
    m.homeScene = m.top.findNode("homeScene")
    m.categoryScene = m.top.findNode("categoryScene")

    m.keyboardGroup.observeField("streamUrl", "onStreamChange")
    m.homeScene.observeField("streamUrl", "onStreamChange")
    m.homeScene.observeField("categorySelected", "onCategoryItemSelect")
    m.homeScene.observeField("buttonPressed", "onHeaderButtonPress")

    m.keyboardGroup.observeField("categorySelected", "onCategoryItemSelectFromSearch")

    m.categoryScene.observeField("streamUrl", "onStreamChange")
    m.categoryScene.observeField("clipUrl", "onClipChange")

    m.top.backgroundColor = "0x18181BFF"
    m.top.backgroundUri = ""

    m.lastScene = "home"

    m.stream = createObject("RoSGNode", "ContentNode")
    m.stream["streamFormat"] = "hls"

    m.login = ""
    m.getUser = createObject("roSGNode", "GetUser")
    m.getUser.observeField("searchResults", "onUserLogin")

    m.testtimer = m.top.findNode("testTimer")
    m.testtimer.control = "start"
    m.testtimer.ObserveField("fire", "refreshFollows")

    loggedInUser = checkIfLoggedIn()
    if loggedInUser <> invalid
        m.getUser.loginRequested = loggedInUser
        m.getUser.control = "RUN"
        m.login = loggedInUser
    end if

    m.homeScene.setFocus(true)
end function

function checkIfLoggedIn() as Dynamic
    sec = createObject("roRegistrySection", "LoggedInUserData")
    if sec.Exists("LoggedInUser")
        return sec.Read("LoggedInUser")
    end if
    return invalid
end function

function saveLogin() as Void
    sec = createObject("roRegistrySection", "LoggedInUserData")
    sec.Write("LoggedInUser", m.homeScene.loggedInUserName)
    sec.Flush()
end function

function onHeaderButtonPress()
    if m.homeScene.buttonPressed = "search"
        m.homeScene.visible = false
        m.keyboardGroup.visible = true
        m.keyboardGroup.setFocus(true)
    else if m.homeScene.buttonPressed = "login"
        m.top.dialog = createObject("RoSGNode", "LoginPrompt")
        m.top.dialog.observeField("buttonSelected", "onLogin")
    end if
end function

function onUserLogin()
    'for each streamer in m.getUser.searchResults.followed_users
    '    ? "live streamer > "; streamer.user_name; " ";streamer.viewer_count
    'end for
    m.homeScene.loggedInUserName = m.getUser.searchResults.display_name
    m.homeScene.loggedInUserProfileImage = m.getUser.searchResults.profile_image_url
    m.homeScene.followedStreams = m.getUser.searchResults.followed_users
    saveLogin()
end function

function onCategoryItemSelectFromSearch()
    m.categoryScene.currentCategory = m.keyboardGroup.categorySelected
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = true
end function

function onCategoryItemSelect()
    m.categoryScene.currentCategory = m.homeScene.categorySelected
    m.homeScene.visible = false
    m.keyboardGroup.visible = false
    m.categoryScene.visible = true
end function

function onClipChange()
    '? "play clip?"
    m.categoryScene.fromClip = true
    m.stream["streamFormat"] = "mp4"
    if m.categoryScene.visible = true
        m.lastScene = "category"
        m.stream["url"] = m.categoryScene.clipUrl
    end if
    m.videoPlayer.setFocus(true)
    m.categoryScene.visible = false
    m.keyboardGroup.visible = false
    m.videoPlayer.visible = true
    m.videoPlayer.content = m.stream
    m.videoPlayer.control = "play"

end function

function onStreamChange()
    m.stream["streamFormat"] = "hls"
    if m.keyboardGroup.visible = true
        m.lastScene = "search"
        m.stream["url"] = m.keyboardGroup.streamUrl
    else if m.homeScene.visible = true
        m.lastScene = "home"
        m.stream["url"] = m.homeScene.streamUrl
    else if m.categoryScene.visible = true
        m.lastScene = "category"
        m.stream["url"] = m.categoryScene.streamUrl
    end if
    m.videoPlayer.setFocus(true)
    m.keyboardGroup.visible = false
    m.videoPlayer.visible = true
    m.videoPlayer.content = m.stream
    m.videoPlayer.control = "play"
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

function onKeyEvent(key, press) as Boolean
    handled = false
    if press
        if m.videoPlayer.visible = true and key = "back"
            m.videoPlayer.control = "stop"
            m.videoPlayer.visible = false
            m.keyboardGroup.visible = false
            if m.lastScene = "home"
                m.homeScene.visible = false
                m.homeScene.visible = true
                m.homeScene.setFocus(true)
            else if m.lastScene = "category"
                ? "main category back"
                m.categoryScene.visible = true
                'm.categoryScene.fromClip = false
                m.categoryScene.setFocus(true)
            else if m.lastScene = "search"
                m.keyboardGroup.visible = true
            end if
            handled = true
        else if m.homeScene.visible = true and key = "options"
            m.homeScene.visible = false
            m.keyboardGroup.visible = true
            m.keyboardGroup.setFocus(true)
            handled = true
        else if m.categoryScene.visible = true and key = "back"
            m.categoryScene.visible = false
            m.homeScene.visible = true
            handled = true
        else if m.keyboardGroup.visible = true and key = "back"
            m.categoryScene.visible = false
            m.keyboardGroup.visible = false
            m.homeScene.visible = true
            handled = true
        end if
    end if

    return handled
end function