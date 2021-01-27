'api.twitch.tv/api/channels/${user}/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6
'usher.ttvnw.net/api/channel/hls/${user}.m3u8?allow_source=true&allow_spectre=true&type=any&token=${token}&sig=${sig}

function init()
    m.keyboard = m.top.findNode("keyboard")
    'm.okButton = m.top.findNode("okButton")
    m.keyboardGroup = m.top.findNode("keyboardGroup")
    m.browseButtons = m.top.findNode("browseButtons")
    m.searchResultList = m.top.findNode("resultList")
    m.resultCategoryList = m.top.findNode("resultCategoryList")

    m.categoryButton = m.top.findNode("categoryButton")
    m.categoryLine = m.top.findNode("categoryLine")
    m.liveButton = m.top.findNode("liveButton")
    m.liveLine = m.top.findNode("liveLine")

    m.searchResultList.observeField("itemSelected", "onSearchItemSelect")
    m.resultCategoryList.observeField("itemSelected", "onSearchItemSelect")

    'm.okButton.observeField("buttonSelected", "onOkButtonSelect")

    m.getSearch = createObject("roSGNode", "GetSearch")
    m.getSearch.observeField("searchResults", "onSearchResultChange")

    m.getCategorySearch = createObject("roSGNode", "GetCategorySearch")
    m.getCategorySearch.observeField("searchResults", "onSearchResultChange")

    m.getStuff = createObject("roSGNode", "GetStuff")
    m.getStuff.observeField("streamUrl", "onStreamUrlChange")

    m.top.observeField("visible", "onGetFocus")

    m.wasLastScene = false

    m.searchResultList.visible = true
    m.resultCategoryList.visible = false

    m.keyboard.setFocus(true)
end function

function onGetFocus()
    m.keyboard.setFocus(true)
end function

function onSearchItemSelect()
    if m.liveLine.visible = true
        'm.getStuff.streamerRequested = m.searchResultList.content.getChild(m.searchResultList.itemSelected).title
        'm.getStuff.control = "RUN"
        m.top.streamerSelectedName = m.searchResultList.content.getChild(m.searchResultList.itemSelected).title
        m.wasLastScene = true
    else if m.categoryLine.visible = true
        m.top.categorySelected = m.resultCategoryList.content.getChild(m.resultCategoryList.itemSelected).categories
    end if
end function

function onSearchTextChange()
    if m.liveLine.visible = true
        if Right(m.keyboard.text, 1) = " "
            m.keyboard.text = Left(m.keyboard.text, Len(m.keyboard.text) - 1) + "_"
        end if
        m.getSearch.searchText = m.keyboard.text
        m.getSearch.control = "RUN"
    else if m.categoryLine.visible = true
        m.getCategorySearch.searchText = m.keyboard.text
        m.getCategorySearch.control = "RUN"
    end if
end function

function onOkButtonSelect()
    m.getStuff.streamerRequested = m.keyboard.text
    m.getStuff.control = "RUN"
    m.wasLastScene = true
end function

function onSearchResultChange()
    content = createObject("roSGNode", "ContentNode")
    if m.liveLine.visible = true
        if m.getSearch.searchResults <> invalid
            for each channel in m.getSearch.searchResults
                child = content.createChild("ContentNode")
                'child.id = channel.id
                'fifty = Left(channel.logo, 98) + "50x50.png"
                child.url = channel.logo
                child.title = channel.name
            end for
        end if
        m.searchResultList.content = content
    else if m.categoryLine.visible = true
        if m.getCategorySearch.searchResults <> invalid
            for each channel in m.getCategorySearch.searchResults
                child = content.createChild("ContentNode")
                'child.id = channel.id
                'fifty = Left(channel.logo, 98) + "50x50.png"
                child.url = channel.logo
                child.categories = channel.id.ToStr()
                child.title = channel.name
            end for
        end if
        m.resultCategoryList.content = content
    end if
end function

function onStreamUrlChange()
    m.top.streamerRequested = m.getStuff.streamerRequested
    m.top.streamUrl = m.getStuff.streamUrl
end function

function onKeyEvent(key, press) as Boolean
    handled = false

    'okHasFocus = m.okButton.hasFocus()
    searchResultsHasFocus = m.searchResultList.hasFocus()
    searchCategoryResultsHasFocus = m.resultCategoryList.hasFocus()
    browseButtonsHasFocus = m.browseButtons.hasFocus()

    if m.top.visible = true and press
        if key = "right" and searchResultsHasFocus = false and searchCategoryResultsHasFocus = false and browseButtonsHasFocus = false 
            if m.categoryLine.visible = true
                m.resultCategoryList.setFocus(true)
            else if m.liveLine.visible = true
                m.searchResultList.setFocus(true)
            end if
            handled = true
        else if key ="left" and (searchResultsHasFocus = true or searchCategoryResultsHasFocus = true)
            m.keyboard.setFocus(true)
            handled = true
        else if key = "up" and browseButtonsHasFocus = false
            if m.categoryLine.visible = true
                m.liveButton.color = "0xA970FFFF"
            else if m.liveLine.visible = true
                m.categoryButton.color = "0xA970FFFF"
            end if
            m.browseButtons.setFocus(true)
            handled = true
        else if browseButtonsHasFocus = true and key = "down"
            if m.categoryLine.visible = true
                m.liveButton.color = "0xEFEFF1FF"
                handled = true
            else if m.liveLine.visible = true
                m.categoryButton.color = "0xEFEFF1FF"
                m.keyboard.setFocus(true)
                handled = true
            end if
        else if browseButtonsHasFocus = true and key = "OK"
            if m.categoryLine.visible = true
                m.liveButton.color = "0xA970FFFF"
                m.liveLine.visible = true
                m.categoryLine.visible = false
                m.categoryButton.color = "0xEFEFF1FF"
                m.resultCategoryList.visible = false
                m.searchResultList.visible = true
                m.keyboard.setFocus(true)
                handled = true
            else if m.liveLine.visible = true
                m.categoryButton.color = "0xA970FFFF"
                m.categoryLine.visible = true
                m.liveLine.visible = false
                m.liveButton.color = "0xEFEFF1FF"
                m.searchResultList.visible = false
                m.resultCategoryList.visible = true
                m.keyboard.setFocus(true)
                handled = true
            end if
        end if
    else if press = false
        if m.wasLastScene = true and m.top.visible = false and key = "back" and m.keyboard.hasFocus() = false
            m.keyboard.setFocus(true)
            m.wasLastScene = false
            handled = true
        end if
    end if

    return handled
end function

