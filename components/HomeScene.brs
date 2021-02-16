sub init()
    m.browseList = m.top.findNode("browseList")
    m.browseCategoryList = m.top.findNode("browseCategoryList")
    m.browseFollowingList = m.top.findNode("browseFollowingList")
    m.browseOfflineFollowingList = m.top.findNode("browseOfflineFollowingList")

    m.offlineChannelList = m.top.findNode("offlineChannelList")

    m.categoryButton = m.top.findNode("categoryButton")
    m.categoryLine = m.top.findNode("categoryLine")
    m.liveButton = m.top.findNode("liveButton")
    m.liveLine = m.top.findNode("liveLine")
    m.followingButton = m.top.findNode("followingButton")
    m.followingLine = m.top.findNode("followingLine")

    m.searchLabel = m.top.findNode("searchLabel")
    'm.loginButton = m.top.findNode("loggedUserName")'m.top.findNode("loginButton")
    m.optionsButton = m.top.findNode("optionsButton")
    m.offlineChannelsLabel = m.top.findNode("offlineChannelsLabel")

    'm.actualBrowseButtons = [ m.categoryButton, m.liveButton, m.followingButton, m.searchLabel, m.loginButton, m.optionsButton ]

    m.channelPage = m.top.findNode("channelPage")
    m.followBar = m.top.findNode("followBar")
    m.browseButtons = m.top.findNode("browseButtons")
    m.browseMain = m.top.findNode("browseMain")

    m.loggedUserGroup = m.top.findNode("loggedUserGroup")
    m.profileImage = m.top.findNode("profileImage")
    m.loggedUserName = m.top.findNode("loggedUserName")

    m.actualBrowseButtons = [ m.categoryButton, m.liveButton, m.followingButton, m.searchLabel, m.optionsButton, m.loggedUserName ]

    m.headerRect = m.top.findNode("headerRect")

    m.browseList.observeField("itemSelected", "onBrowseItemSelect")
    m.browseCategoryList.observeField("itemSelected", "onBrowseItemSelect")
    m.browseFollowingList.observeField("itemSelected", "onBrowseItemSelect")
    m.browseFollowingList.observeField("itemFocused", "onBrowseFollowing")

    'm.browseOfflineFollowingList.observeField("itemSelected", "onBrowseItemSelect")
    m.offlineChannelList.observeField("channelSelected", "onBrowseItemSelect")

    'm.channelPage.observeField("videoUrl", "onVideoSelectedFromChannel")
    m.channelPage.observeField("streamUrl", "onLiveStreamSelectedFromChannel")

    m.followBar.observeField("streamerSelected", "onBrowseItemSelect")

    m.getStreams = createObject("roSGNode", "GetStreams")
    m.getStreams.observeField("searchResults", "onSearchResultChange")

    m.getStuff = createObject("roSGNode", "GetStuff")
    m.getStuff.observeField("streamUrl", "onStreamUrlChange")

    m.getCategories = createObject("roSGNode", "GetCategories")
    m.getCategories.observeField("searchResults", "onCategoryResultChange")
    'm.getCategories = createObject("roSGNode", "GetCategories2")
    'm.getCategories.observeField("searchResults", "onCategoryResultChange")

    m.getOfflineFollowed = createObject("roSGNode", "GetOfflineFollowedChannels")
    m.getOfflineFollowed.observeField("offlineFollowedUsers", "onGetOfflineFollowed")

    m.top.observeField("visible", "onGetFocus")
    m.top.observeField("currentlyLiveStreamerIds", "onGetFollowedStreams")
    m.top.observeField("streamerSelectedName", "onStreamerSelected")

    deviceInfo = CreateObject("roDeviceInfo")
    uiResolutionWidth = deviceInfo.GetUIResolution().width

    if uiResolutionWidth = 1920
        m.top.findNode("profileImageMask").maskSize = [75, 75]
    end if

    m.offset = 0
    m.append = false
    m.offsetCategory = 0
    m.appendCategory = false
    m.appLaunchComplete = false

    m.numRowsInFollowingList = 0

    m.currentlySelectedButton = 1
    m.currentlyFocusedButton = 1

    m.followingListIsFocused = true

    m.wasLastScene = false

    if m.top.visible = true
        onHomeLoad()
    end if

    m.browseList.setFocus(true)
end sub

sub onStreamerSelected()
    m.channelPage.streamerSelectedName = m.top.streamerSelectedName
    m.channelPage.streamerSelectedThumbnail = m.top.streamerSelectedThumbnail

    if m.currentlySelectedButton = 0
        m.browseCategoryList.visible = false
    else if m.currentlySelectedButton = 1
        m.browseList.visible = false
    else if m.currentlySelectedButton = 2
        m.browseFollowingList.visible = false
        m.offlineChannelsLabel.visible = false
        m.offlineChannelList.visible = false
        m.browseOfflineFollowingList.visible = false
    end if
    m.wasLastScene = true
    m.channelPage.visible = true
end sub

sub onLiveStreamSelectedFromChannel()
    m.top.streamUrl = m.channelPage.streamUrl
end sub

sub onNewUser()
    ? "HomeScene > loggedInUserProfileImage > " m.top.loggedInUserProfileImage
    m.loggedUserName.text = m.top.loggedInUserName
    m.loggedUserName.color = "0xEFEFF1FF"
    m.loggedUserName.translation = [60, 20]
    m.profileImage.uri = m.top.loggedInUserProfileImage
    width = m.loggedUserName.localBoundingRect().width + 10
    m.searchLabel.translation = [1080 - width, 24]
    m.optionsButton.translation = [1145 - width, 24]
    m.headerRect.translation = [-150 - width, 0]
    m.loggedUserGroup.translation = [1220 - width, 15]
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
        else if m.browseFollowingList.visible = true
            m.browseFollowingList.setFocus(true)
            m.followingListIsFocused = true
        else if m.channelPage.visible
            'm.channelPage.setFocus(true)
            m.channelPage.visible = false
            m.channelPage.visible = true
        end if
    end if
end sub

sub onStreamUrlChange()
    ? "HomeScene > streamURL change > " m.getStuff.streamerRequested
    m.top.streamerRequested = m.getStuff.streamerRequested
    m.top.streamUrl = m.getStuff.streamUrl
end sub

sub onBrowseItemSelect()
    if m.followBar.hasFocus()
        'm.getStuff.streamerRequested = m.followBar.streamerSelected
        'm.getStuff.control = "RUN"
        m.top.streamerSelectedThumbnail = ""
        m.top.streamerSelectedName = m.followBar.streamerSelected
        ? "selected: "; m.top.streamerSelectedName
    else if m.browseList.visible = true
        'm.getStuff.streamerRequested = m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).ShortDescriptionLine1
        'm.getStuff.control = "RUN"
        m.top.streamerSelectedName =  m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).ShortDescriptionLine1
        m.top.streamerSelectedThumbnail =  m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).HDPosterUrl
        'm.top.streamerSelectedThumbnail =  m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).HDPosterUrl
        m.wasLastScene = true
    else if m.browseCategoryList.visible = true
        m.top.categorySelected = m.browseCategoryList.content.getChild(m.browseCategoryList.rowItemSelected[0]).getChild(m.browseCategoryList.rowItemSelected[1]).ShortDescriptionLine1
    else if m.browseFollowingList.hasFocus()
        m.top.streamerSelectedName =  m.browseFollowingList.content.getChild(m.browseFollowingList.rowItemSelected[0]).getChild(m.browseFollowingList.rowItemSelected[1]).ShortDescriptionLine1
        m.top.streamerSelectedThumbnail =  m.browseFollowingList.content.getChild(m.browseFollowingList.rowItemSelected[0]).getChild(m.browseFollowingList.rowItemSelected[1]).HDPosterUrl
    else if m.browseOfflineFollowingList.hasFocus()
        m.top.streamerSelectedName =  m.browseOfflineFollowingList.content.getChild(m.browseOfflineFollowingList.rowItemSelected[0]).getChild(m.browseOfflineFollowingList.rowItemSelected[1]).ShortDescriptionLine1
        m.top.streamerSelectedThumbnail =  m.browseOfflineFollowingList.content.getChild(m.browseOfflineFollowingList.rowItemSelected[0]).getChild(m.browseOfflineFollowingList.rowItemSelected[1]).HDPosterUrl
    else if m.offlineChannelList.hasFocus()

        m.top.streamerSelectedName = m.offlineChannelList.channelSelected
        m.top.streamerSelectedThumbnail = ""
    end if
end sub

sub onHomeLoad()
    m.browseCategoryList.visible = false
    m.browseFollowingList.visible = false
    m.browseOfflineFollowingList.visible = false
    m.offlineChannelList.visible = false
    m.offlineChannelsLabel.visible = false
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
    if m.appLaunchComplete <> true
        m.top.signalBeacon("AppLaunchComplete")
        m.appLaunchComplete = true
    end if
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
            if cnt <> 0 and cnt MOD 6 = 0 and content <> invalid
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
    m.browseFollowingList.visible = false
    m.browseOfflineFollowingList.visible = false
    m.offlineChannelList.visible = false
    m.offlineChannelsLabel.visible = false
    m.browseCategoryList.visible = true
    m.getCategories.searchText = ""
    m.getCategories.offset = "0"
    m.offsetCategory = 0
    m.getCategories.control = "RUN"
end sub

sub onFollowingSelect()
    m.browseList.visible = false
    m.browseCategoryList.visible = false
    m.browseFollowingList.visible = true
    'm.browseOfflineFollowingList.visible = true
    m.offlineChannelsLabel.visible = true
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

sub onGetFollowedStreams()
    m.getOfflineFollowed.loginRequested = m.top.loggedInUserName
    m.getOfflineFollowed.currentlyLiveStreamerIds = m.top.currentlyLiveStreamerIds
    '? "currentlyLiveStreamerIds homescene " m.getOfflineFollowed.currentlyLiveStreamerIds
    m.getOfflineFollowed.control = "RUN"

    m.numRowsInFollowingList = 0
    lastFocusedRow = 0
    if m.browseFollowingList.rowItemFocused[0] <> invalid
        lastFocusedRow = m.browseFollowingList.rowItemFocused[0]
    end if
    if m.append = true
        content = m.browseFollowingList.content
    else if m.append = false
        content = createObject("roSGNode", "ContentNode")
    end if 
    if m.top.followedStreams <> invalid
        row = createObject("RoSGNode", "ContentNode")
        rowItem = invalid
        alreadyAppended = false
        cnt = 0
        for each stream in m.top.followedStreams
            alreadyAppended = false
            rowItem = createObject("RoSGNode", "ContentNode")
            rowItem.Title = stream.title
            rowItem.Description = stream.user_name
            rowItem.Categories = stream.game_id
            rowItem.HDPosterUrl = stream.thumbnail
            rowItem.ShortDescriptionLine1 = stream.login
            rowItem.ShortDescriptionLine2 = numberToText(stream.viewer_count)
            row.appendChild(rowItem)
            cnt += 1
            if cnt <> 0 and cnt MOD 3 = 0
                content.appendChild(row)
                row = createObject("RoSGNode", "ContentNode")
                m.numRowsInFollowingList += 1
                alreadyAppended = true
            end if
        end for
        if row <> invalid and alreadyAppended = false
            content.appendChild(row)
            m.numRowsInFollowingList += 1
        end if
    end if
    m.browseFollowingList.content = content
    m.browseFollowingList.jumpToItem = lastFocusedRow
    m.append = false
    m.numRowsInFollowingList -= 1
end sub

sub onBrowseFollowing()
    if m.browseFollowingList.itemFocused = m.numRowsInFollowingList
        m.offlineChannelsLabel.translation = [100,465]
        'm.browseOfflineFollowingList.translation = [100,500]
        m.offlineChannelList.visible = true
    else
        m.offlineChannelsLabel.translation = [100,700]
        m.browseOfflineFollowingList.translation = [100,750]
        m.offlineChannelList.visible = false
    end if
end sub

sub onGetOfflineFollowed()
    m.offlineChannelList.offlineChannels = m.getOfflineFollowed.offlineFollowedUsers
    lastFocusedRow = 0
    if m.browseOfflineFollowingList.rowItemFocused[0] <> invalid
        lastFocusedRow = m.browseOfflineFollowingList.rowItemFocused[0]
    end if
    if m.append = true
        content = m.browseOfflineFollowingList.content
    else if m.append = false
        content = createObject("roSGNode", "ContentNode")
    end if 
    if m.getOfflineFollowed.offlineFollowedUsers <> invalid
        row = createObject("RoSGNode", "ContentNode")
        rowItem = invalid
        alreadyAppended = false
        cnt = 0
        for each stream in m.getOfflineFollowed.offlineFollowedUsers
            alreadyAppended = false
            rowItem = createObject("RoSGNode", "ContentNode")
            rowItem.Title = stream.display_name
            rowItem.ShortDescriptionLine1 = stream.login
            rowItem.HDPosterUrl = stream.profile_image_url
            row.appendChild(rowItem)
            cnt += 1
            if cnt <> 0 and cnt MOD 6 = 0
                content.appendChild(row)
                row = createObject("RoSGNode", "ContentNode")
                alreadyAppended = true
            end if
        end for
        if row <> invalid and alreadyAppended = false
            content.appendChild(row)
        end if
    end if
    m.browseOfflineFollowingList.content = content
    m.browseOfflineFollowingList.jumpToItem = lastFocusedRow
    m.append = false
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
    if m.top.visible = true and press
        if (m.browseList.hasFocus() = true or m.browseCategoryList.hasFocus() = true or m.browseFollowingList.hasFocus() = true) and key = "up"
            ' Reset focused button when user goes on button header
            if m.currentlyFocusedButton = 0
                m.actualBrowseButtons[1].color = "0x00FFD1FF"
                m.currentlyFocusedButton = 1
            else
                m.actualBrowseButtons[0].color = "0x00FFD1FF"
                m.currentlyFocusedButton = 0
            end if

            m.browseButtons.setFocus(true)
            handled = true
        else if m.browseButtons.hasFocus() = true
            if key = "right"
                if m.currentlyFocusedButton <> 3 and m.currentlyFocusedButton <> 4
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = "0xEFEFF1FF"
                else
                    m.actualBrowseButtons[m.currentlyFocusedButton].blendColor = "0xEFEFF1FF"
                end if
                if m.currentlyFocusedButton < 5
                    m.currentlyFocusedButton += 1
                    if m.currentlyFocusedButton = m.currentlySelectedButton and m.currentlyFocusedButton < 5
                        m.currentlyFocusedButton += 1
                    end if
                end if
                'm.actualBrowseButtons[m.currentlyFocusedButton].color = "0x00FFD1FF"
                if m.currentlyFocusedButton <> 3 and m.currentlyFocusedButton <> 4
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = "0x00FFD1FF"
                else
                    m.actualBrowseButtons[m.currentlyFocusedButton].blendColor = "0x00FFD1FF"
                end if
                handled = true
            else if key = "left"
                'm.actualBrowseButtons[m.currentlyFocusedButton].color = "0xEFEFF1FF"
                if m.currentlyFocusedButton <> 3 and m.currentlyFocusedButton <> 4
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = "0xEFEFF1FF"
                else
                    m.actualBrowseButtons[m.currentlyFocusedButton].blendColor = "0xEFEFF1FF"
                end if
                if m.currentlyFocusedButton > 0 and not (m.currentlyFocusedButton = 1 and m.currentlySelectedButton = 0)
                    m.currentlyFocusedButton -= 1
                    if m.currentlyFocusedButton = m.currentlySelectedButton and m.currentlyFocusedButton > 0
                        m.currentlyFocusedButton -= 1
                    end if
                end if
                'm.actualBrowseButtons[m.currentlyFocusedButton].color = "0x00FFD1FF"
                if m.currentlyFocusedButton <> 3 and m.currentlyFocusedButton <> 4
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = "0x00FFD1FF"
                else
                    m.actualBrowseButtons[m.currentlyFocusedButton].blendColor = "0x00FFD1FF"
                end if
                handled = true
            else if key = "down"
                ' Reset button colours to unfocused colours when user focuses away from header
                for button = 0 to 5
                    if button <> 3 and button <> 4
                        m.actualBrowseButtons[button].color = "0xEFEFF1FF"
                    else
                        m.actualBrowseButtons[button].blendColor = "0xEFEFF1FF"
                    end if
                end for

                if m.currentlySelectedButton = 0
                    m.categoryButton.color = "0x00FFD1FF"
                    'm.liveButton.color = "0xEFEFF1FF"
                    m.browseCategoryList.setFocus(true)
                    m.currentlyFocusedButton = 0
                    handled = true
                else if m.currentlySelectedButton = 1
                    m.liveButton.color = "0x00FFD1FF"
                    'm.categoryButton.color = "0xEFEFF1FF"
                    m.browseList.setFocus(true)
                    m.currentlyFocusedButton = 1
                    handled = true
                else if m.currentlySelectedButton = 2
                    m.followingButton.color = "0x00FFD1FF"
                    'm.categoryButton.color = "0xEFEFF1FF"
                    m.browseFollowingList.setFocus(true)
                    m.followingListIsFocused = true
                    m.currentlyFocusedButton = 2
                    handled = true
                end if

            else if key = "OK"
                if m.currentlyFocusedButton = 3
                    m.top.buttonPressed = "search"
                    m.searchLabel.blendColor = "0xEFEFF1FF"
                    m.liveButton.color = "0x00FFD1FF"
                    handled = true
                else if m.currentlyFocusedButton = 5
                    m.top.buttonPressed = "login"
                    'm.loginButton.color = "0xEFEFF1FF"
                    handled = true
                else if m.currentlyFocusedButton = 4
                    m.top.buttonPressed = "options"
                    m.optionsButton.blendColor = "0xEFEFF1FF"
                    handled = true
                else if m.currentlyFocusedButton = 1
                    m.actualBrowseButtons[m.currentlySelectedButton].color = "0xEFEFF1FF"
                    m.searchLabel.blendColor = "0xEFEFF1FF"
                    m.loggedUserName.color = "0xEFEFF1FF"
                    m.liveButton.color = "0x00FFD1FF"
                    m.liveLine.visible = true
                    m.categoryLine.visible = false
                    m.categoryButton.color = "0xEFEFF1FF"
                    m.followingLine.visible = false
                    m.getCategories.pagination = ""
                    m.browseList.setFocus(true)
                    m.currentlySelectedButton = 1
                    onHomeLoad()
                    handled = true
                else if m.currentlyFocusedButton = 0
                    m.actualBrowseButtons[m.currentlySelectedButton].color = "0xEFEFF1FF"
                    m.searchLabel.blendColor = "0xEFEFF1FF"
                    m.loggedUserName.color = "0xEFEFF1FF"
                    m.categoryButton.color = "0x00FFD1FF"
                    m.categoryLine.visible = true
                    m.liveLine.visible = false
                    m.liveButton.color = "0xEFEFF1FF"
                    m.followingLine.visible = false
                    m.browseCategoryList.setFocus(true)
                    m.currentlySelectedButton = 0
                    onCategorySelect()
                    handled = true
                else if m.currentlyFocusedButton = 2
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = "0x00FFD1FF"
                    m.categoryButton.color = "0xEFEFF1FF"
                    m.liveButton.color = "0xEFEFF1FF"
                    m.categoryLine.visible = false
                    m.liveLine.visible = false
                    m.followingLine.visible = true
                    m.currentlySelectedButton = 2
                    m.browseFollowingList.setFocus(true)
                    m.followingListIsFocused = true
                    onFollowingSelect()
                    handled = true
                end if
            end if 
        else if (m.browseList.hasFocus() or m.browseCategoryList.hasFocus() or m.browseFollowingList.hasFocus() or m.browseOfflineFollowingList.hasFocus() or m.offlineChannelList.hasFocus() or m.channelPage.visible) and key = "left"
            'm.browseButtons.translation = "[200, 0]"
            'm.browseList.translation = "[300,165]"
            'm.browseCategoryList.translation = "[300,165]"
            'm.browseMain.translation = "[250, 0]"
            m.followBar.setFocus(true)
            m.followBar.focused = true
            handled = true
        else if m.followBar.hasFocus() = true and key = "right"
            'm.browseButtons.translation = "[0, 0]"
            'm.browseList.translation = "[100,165]"
            'm.browseCategoryList.translation = "[100,165]"
            m.browseMain.translation = "[0, 0]"
            if m.browseList.visible = true
                m.browseList.setFocus(true)
            else if m.browseCategoryList.visible = true
                m.browseCategoryList.setFocus(true)
            else if m.browseFollowingList.visible = true
                m.browseFollowingList.setFocus(true)
                m.followingListIsFocused = true
            else if m.channelPage.visible
                m.channelPage.visible = false
                m.channelPage.visible = true
            end if
            m.followBar.focused = false
            handled = true
        else if m.browseList.hasFocus() = true and key = "down"
            getMoreChannels()
            handled = true
        else if m.browseCategoryList.hasFocus() = true and key = "down"
            getMoreCategories()
            handled = true
        else if m.browseFollowingList.hasFocus() = true and key = "down"
            m.offlineChannelsLabel.translation = [100,465]
            'm.browseOfflineFollowingList.translation = [100,500]
            'm.browseOfflineFollowingList.setFocus(true)
            m.offlineChannelList.visible = true
            m.offlineChannelList.setFocus(true)
            m.followingListIsFocused = false
            handled = true
        'else if m.browseOfflineFollowingList.hasFocus() = true and key = "up"
        else if m.offlineChannelList.hasFocus() and key = "up"
            m.browseFollowingList.setFocus(true)
            m.followingListIsFocused = true
            handled = true
        'end if
    'else if press = false
        else if key = "back" 'and m.wasLastScene = true
            if m.channelPage.visible
                m.channelPage.visible = false
                'm.channelPage.visible = true
                if m.currentlySelectedButton = 0 'm.categoryLine.visible = true
                    m.browseCategoryList.visible = true
                    m.browseCategoryList.setFocus(true)
                    'handled = true
                else if m.currentlySelectedButton = 1 'm.liveLine.visible = true
                    m.browseList.visible = true
                    m.browseList.setFocus(true)
                    handled = true
                else if m.currentlySelectedButton = 2
                    m.browseFollowingList.visible = true
                    m.offlineChannelsLabel.visible = true
                    
                    if m.followingListIsFocused = true
                        m.browseFollowingList.setFocus(true)
                    else
                        m.offlineChannelList.visible = true
                        m.offlineChannelList.setFocus(true)
                    end if

                    handled = true
                end if
            else if m.currentlySelectedButton = 0 and m.channelPage.visible'm.top.lastScene = "category"
                'm.top.lastScene = ""
            else if m.currentlySelectedButton = 0 'm.categoryLine.visible = true
                m.browseCategoryList.visible = true
                m.browseCategoryList.setFocus(true)
                'handled = true
            else if m.currentlySelectedButton = 1 'm.liveLine.visible = true
                m.browseList.visible = true
                m.browseList.setFocus(true)
                'handled = true
            else if m.currentlySelectedButton = 2
                m.browseFollowingList.visible = true
                m.offlineChannelsLabel.visible = true
                m.browseFollowingList.setFocus(true)
                m.followingListIsFocused = true
            end if
            'm.channelPage.visible = false
            m.wasLastScene = false
        end if
    end if

    ? "HOMESCENE > key " key " " handled
    return handled
end sub