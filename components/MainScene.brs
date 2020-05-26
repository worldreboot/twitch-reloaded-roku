'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()
    m.videoPlayer = m.top.findNode("videoPlayer")
    m.keyboardGroup = m.top.findNode("keyboardGroup")
    m.homeScene = m.top.findNode("homeScene")
    m.categoryScene = m.top.findNode("categoryScene")

    m.keyboardGroup.observeField("streamUrl", "onStreamChange")
    m.homeScene.observeField("streamUrl", "onStreamChange")
    m.homeScene.observeField("categorySelected", "onCategoryItemSelect")

    m.keyboardGroup.observeField("categorySelected", "onCategoryItemSelectFromSearch")

    m.categoryScene.observeField("streamUrl", "onStreamChange")

    m.top.backgroundColor = "0x18181BFF"
    m.top.backgroundUri = ""

    m.lastScene = "home"

    m.stream = createObject("RoSGNode", "ContentNode")
    m.stream["streamFormat"] = "hls"

    m.homeScene.setFocus(true)
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

function onStreamChange()
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

function onKeyEvent(key, press) as Boolean
    handled = false

    if press
        if m.videoPlayer.visible = true and key = "back"
            m.videoPlayer.control = "stop"
            m.videoPlayer.visible = false
            m.keyboardGroup.visible = false
            if m.lastScene = "home"
                m.homeScene.visible = true
                m.homeScene.setFocus(true)
            else if m.lastScene = "category"
                m.categoryScene.visible = true
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