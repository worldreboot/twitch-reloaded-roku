sub init()
    m.browseList = m.top.findNode("browseList")
    m.browseCategoryList = m.top.findNode("browseCategoryList")

    m.categoryButton = m.top.findNode("categoryButton")
    m.categoryLine = m.top.findNode("categoryLine")
    m.liveButton = m.top.findNode("liveButton")
    m.liveLine = m.top.findNode("liveLine")

    m.searchLabel = m.top.findNode("searchLabel")
    m.loginButton = m.top.findNode("loginButton")

    m.followBar = m.top.findNode("followBar")
    m.browseButtons = m.top.findNode("browseButtons")
    m.browseMain = m.top.findNode("browseMain")

    m.loggedUserGroup = m.top.findNode("loggedUserGroup")
    m.profileImage = m.top.findNode("profileImage")
    m.loggedUserName = m.top.findNode("loggedUserName")

    m.browseList.observeField("itemSelected", "onBrowseItemSelect")
    m.browseCategoryList.observeField("itemSelected", "onBrowseItemSelect")

    m.followBar.observeField("streamerSelected", "onBrowseItemSelect")

    m.getStreams = createObject("roSGNode", "GetStreams")
    m.getStreams.observeField("searchResults", "onSearchResultChange")

    m.getStuff = createObject("roSGNode", "GetStuff")
    m.getStuff.observeField("streamUrl", "onStreamUrlChange")

    m.getCategories = createObject("roSGNode", "GetCategories")
    m.getCategories.observeField("searchResults", "onCategoryResultChange")

    m.top.observeField("visible", "onGetFocus")

    m.offset = 0
    m.append = false
    m.offsetCategory = 0
    m.appendCategory = false

    m.currentButton = 1

    m.wasLastScene = false

    if m.top.visible = true
        onHomeLoad()
    end if

    m.browseList.setFocus(true)
end sub

sub onNewUser()
    m.loggedUserName.text = m.top.loggedInUserName
    ? "profile name > ";m.top.loggedInUserName
    ? "profile image > ";m.top.loggedInUserProfileImage
    m.profileImage.uri = m.top.loggedInUserProfileImage
    m.loggedUserGroup.visible = true
end sub

sub onGetFocus()
    if m.top.visible = true
        if m.followBar.focused
            m.followBar.setFocus(true)
        else if m.browseCategoryList.visible = true
            m.browseCategoryList.setFocus(true)
        else if m.browseList.visible = true
            m.browseList.setFocus(true)
        end if
    end if
end sub

sub onStreamUrlChange()
    m.top.streamUrl = m.getStuff.streamUrl
end sub

sub onBrowseItemSelect()
    if m.followBar.hasFocus()
        m.getStuff.streamerRequested = m.followBar.streamerSelected
        m.getStuff.control = "RUN"
    else if m.browseList.visible = true
        m.getStuff.streamerRequested = m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).ShortDescriptionLine1
        m.getStuff.control = "RUN"
        m.wasLastScene = true
    else if m.browseCategoryList.visible = true
        m.top.categorySelected = m.browseCategoryList.content.getChild(m.browseCategoryList.rowItemSelected[0]).getChild(m.browseCategoryList.rowItemSelected[1]).ShortDescriptionLine1
    end if
end sub

sub onHomeLoad()
    m.browseCategoryList.visible = false
    m.browseList.visible = true
    m.getStreams.gameRequested = ""
    m.getStreams.offset = "0"
    m.getStreams.pagination = ""
    m.offset = 0
    m.getStreams.control = "RUN"
end sub

sub onSearchResultChange()
    lastFocusedRow = 0
    if m.browseList.rowItemFocused[0] <> invalid
        lastFocusedRow = m.browseList.rowItemFocused[0]
    end if
    if m.append = true
        content = m.browseList.content
    else if m.append = false
        content = createObject("roSGNode", "ContentNode")
    end if 
    if m.getStreams.searchResults <> invalid
        row = createObject("RoSGNode", "ContentNode")
        rowItem = invalid
        alreadyAppended = false
        cnt = 0
        for each stream in m.getStreams.searchResults
            alreadyAppended = false
            rowItem = createObject("RoSGNode", "ContentNode")
            rowItem.Title = stream.title
            rowItem.Description = stream.display_name
            rowItem.Categories = stream.game
            rowItem.HDPosterUrl = stream.thumbnail
            rowItem.ShortDescriptionLine1 = stream.name
            rowItem.ShortDescriptionLine2 = numberToText(stream.viewers)
            row.appendChild(rowItem)
            cnt += 1
            if cnt <> 0 and cnt MOD 3 = 0
                content.appendChild(row)
                row = createObject("RoSGNode", "ContentNode")
                alreadyAppended = true
            end if
        end for
        if rowItem <> invalid and cnt <> 0 and alreadyAppended = false
            row.appendChild(rowItem)
        end if
    end if
    if m.browseList.visible = true
        m.browseList.content = content
    end if
    m.browseList.jumpToItem = lastFocusedRow
    m.append = false
end sub

sub numberToText(number) as Object
    s = StrI(number)
    result = ""
    if number >=100000 and number < 1000000
        result = Left(s, 4) + "K"
    else if number >=10000 and number < 100000
        result = Left(s, 3) + "." + Mid(s, 4, 1) + "K"
    else if number >=1000 and number < 10000
        result = Left(s, 2) + "." + Mid(s, 3, 1) + "K"
    else if number < 1000
        result = s
    end if
    return result + " viewers"
end sub

sub onCategoryResultChange()
    lastFocusedRow = 0
    if m.browseCategoryList.rowItemFocused[0] <> invalid
        lastFocusedRow = m.browseCategoryList.rowItemFocused[0]
    end if
    if m.appendCategory = true
        content = m.browseCategoryList.content
    else if m.appendCategory = false
        content = createObject("roSGNode", "ContentNode")
    end if 
    if m.getStreams.searchResults <> invalid
        row = createObject("RoSGNode", "ContentNode")
        rowItem = invalid
        alreadyAppended = false
        cnt = 0
        for each stream in m.getCategories.searchResults
            rowItem = createObject("RoSGNode", "ContentNode")
            rowItem.Title = stream.name
            rowItem.Description = numberToText(stream.viewers)
            rowItem.ShortDescriptionLine1 = stream.id
            rowItem.HDPosterUrl = stream.logo
            row.appendChild(rowItem)
            cnt += 1
            if cnt <> 0 and cnt MOD 6 = 0
                content.appendChild(row)
                row = createObject("RoSGNode", "ContentNode")
                alreadyAppended = true
            end if
        end for
        'if rowItem <> invalid and cnt <> 0 and alreadyAppended = false
            'row.appendChild(rowItem)
        'end if
    end if
    m.browseCategoryList.content = content
    m.browseCategoryList.jumpToItem = lastFocusedRow
    m.appendCategory = false
end sub

sub onCategorySelect()
    m.browseList.visible = false
    m.browseCategoryList.visible = true
    m.getCategories.searchText = ""
    m.getCategories.offset = "0"
    m.getCategories.pagination = ""
    m.offsetCategory = 0
    m.getCategories.control = "RUN"
end sub

sub getMoreChannels()
    m.offset += 25
    m.append = true
    m.getStreams.gameRequested = ""
    m.getStreams.offset = m.offset.ToStr()
    m.getStreams.control = "RUN"
end sub

sub getMoreCategories()
    if m.offsetCategory = 0
        m.offsetCategory += 25
    else
        m.offsetCategory += 24
    end if
    m.appendCategory = true
    m.getCategories.offset = m.offsetCategory.ToStr()
    m.getCategories.control = "RUN"
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
    if m.top.visible = true and press
        if (m.browseList.hasFocus() = true or m.browseCategoryList.hasFocus() = true) and key = "up"
            if m.categoryLine.visible = true
                m.liveButton.color = "0xA970FFFF"
                m.currentButton = 1
            else if m.liveLine.visible = true
                m.categoryButton.color = "0xA970FFFF"
                m.currentButton = 0
            end if
            m.browseButtons.setFocus(true)
            handled = true
        else if m.browseButtons.hasFocus() = true
            if key = "right"
                if m.currentButton = 0
                    m.categoryButton.color = "0xEFEFF1FF"
                    m.liveButton.color = "0xA970FFFF"
                    handled = true
                else if m.currentButton = 1
                    m.liveButton.color = "0xEFEFF1FF"
                    m.searchLabel.color = "0xA970FFFF"
                    handled = true
                else if m.currentButton = 2
                    m.searchLabel.color = "0xEFEFF1FF"
                    m.loginButton.color = "0xA970FFFF"
                    handled = true
                end if
                if m.currentButton < 3
                    m.currentButton += 1
                end if
                handled = true
            else if key = "left"
                if m.currentButton = 1
                    m.liveButton.color = "0xEFEFF1FF"
                    m.categoryButton.color = "0xA970FFFF"
                    handled = true
                else if m.currentButton = 2
                    m.searchLabel.color = "0xEFEFF1FF"
                    m.liveButton.color = "0xA970FFFF"
                    handled = true
                else if m.currentButton = 3
                    m.searchLabel.color = "0xA970FFFF"
                    m.loginButton.color = "0xEFEFF1FF"
                    handled = true
                end if
                if m.currentButton > 0
                    m.currentButton -= 1
                end if
                handled = true
            else if key = "down"
                m.searchLabel.color = "0xEFEFF1FF"
                m.loginButton.color = "0xEFEFF1FF"
                if m.categoryLine.visible = true
                    m.categoryButton.color = "0xA970FFFF"
                    m.liveButton.color = "0xEFEFF1FF"
                    m.browseCategoryList.setFocus(true)
                    handled = true
                else if m.liveLine.visible = true
                    m.liveButton.color = "0xA970FFFF"
                    m.categoryButton.color = "0xEFEFF1FF"
                    m.browseList.setFocus(true)
                    handled = true
                end if
            else if key = "OK"
                if m.currentButton = 2
                    m.top.buttonPressed = "search"
                    m.searchLabel.color = "0xEFEFF1FF"
                    m.liveButton.color = "0xA970FFFF"
                    handled = true
                else if m.currentButton = 3
                    m.top.buttonPressed = "login"
                    'm.loginButton.color = "0xEFEFF1FF"
                    handled = true
                else if m.categoryLine.visible = true
                    m.searchLabel.color = "0xEFEFF1FF"
                    m.loginButton.color = "0xEFEFF1FF"
                    m.liveButton.color = "0xA970FFFF"
                    m.liveLine.visible = true
                    m.categoryLine.visible = false
                    m.categoryButton.color = "0xEFEFF1FF"
                    m.browseList.setFocus(true)
                    onHomeLoad()
                    handled = true
                else if m.liveLine.visible = true
                    m.searchLabel.color = "0xEFEFF1FF"
                    m.loginButton.color = "0xEFEFF1FF"
                    m.categoryButton.color = "0xA970FFFF"
                    m.categoryLine.visible = true
                    m.liveLine.visible = false
                    m.liveButton.color = "0xEFEFF1FF"
                    m.browseCategoryList.setFocus(true)
                    onCategorySelect()
                    handled = true
                end if
            end if 
        else if (m.browseList.hasFocus() or m.browseCategoryList.hasFocus()) and key = "left"
            'm.browseButtons.translation = "[200, 0]"
            'm.browseList.translation = "[300,165]"
            'm.browseCategoryList.translation = "[300,165]"
            m.browseMain.translation = "[250, 0]"
            m.followBar.setFocus(true)
            m.followBar.focused = true
            handled = true
        else if m.followBar.hasFocus() = true and key = "right"
            'm.browseButtons.translation = "[0, 0]"
            'm.browseList.translation = "[100,165]"
            'm.browseCategoryList.translation = "[100,165]"
            m.browseMain.translation = "[0, 0]"
            if m.liveLine.visible = true
                m.browseList.setFocus(true)
            else if m.categoryLine.visible = true
                m.browseCategoryList.setFocus(true)
            end if
            m.followBar.focused = false
            handled = true
        else if m.browseList.hasFocus() = true and key = "down"
            getMoreChannels()
            handled = true
        else if m.browseCategoryList.hasFocus() = true and key = "down"
            getMoreCategories()
            handled = true
        end if
    else if press = false
        if key = "back" and m.wasLastScene = true
            if m.categoryLine.visible = true
                m.browseCategoryList.setFocus(true)
                handled = true
            else if m.liveLine.visible = true
                m.browseList.setFocus(true)
                handled = true
            end if
            m.wasLastScene = false
        end if
    end if

    return handled
end sub
