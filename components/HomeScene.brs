sub init()
    m.focusSelectionColor = "0x9146FFFF" 'Twitch Purple'
    ' m.focusSelectionColor 'Cyan`
    m.inactiveSelectionColor = "0xEFEFF1FF" 'Grey'
    m.activeSelectionColor = m.inactiveSelectionColor
    m.browseList = m.top.findNode("browseList")
    m.browseCategoryList = m.top.findNode("browseCategoryList")
    m.browseFollowingList = m.top.findNode("browseFollowingList")
    m.browseOfflineFollowingList = m.top.findNode("browseOfflineFollowingList")

    m.offlineChannelList = m.top.findNode("offlineChannelList")

    m.categoryButton = m.top.findNode("categoryButton")
    m.categoryLine = m.top.findNode("categoryLine")
    m.liveButton = m.top.findNode("liveButton")
    m.liveLine = m.top.findNode("liveLine")

    '' i might start from here: low amount of mentions
    m.followingButton = m.top.findNode("followingButton")
    m.followingLine = m.top.findNode("followingLine")

    m.searchLabel = m.top.findNode("searchLabel")
    'm.loginButton = m.top.findNode("loggedUserName")'m.top.findNode("loginButton")
    m.optionsButton = m.top.findNode("optionsButton")
    m.offlineChannelsLabel = m.top.findNode("offlineChannelsLabel")

    'm.actualBrowseButtons = [ m.categoryButton, m.liveButton, m.followingButton, m.searchLabel, m.loginButton, m.optionsButton ]
    m.backgroundImagePoster = m.top.findNode("backgroundImagePoster")
    m.channelPage = m.top.findNode("channelPage")
    m.followBar = m.top.findNode("followBar")
    m.browseButtons = m.top.findNode("browseButtons")
    m.browseMain = m.top.findNode("browseMain")
    m.recentsBar = m.top.findNode("recentsBar")

    m.loggedUserGroup = m.top.findNode("loggedUserGroup")
    m.profileImage = m.top.findNode("profileImage")
    m.loggedUserName = m.top.findNode("loggedUserName")

    m.actualBrowseButtons = [m.categoryButton, m.liveButton, m.followingButton, m.searchLabel, m.optionsButton, m.loggedUserName]

    m.headerRect = m.top.findNode("headerRect")

    m.browseList.observeField("itemSelected", "onBrowseItemSelect")
    m.browseCategoryList.observeField("itemSelected", "onBrowseItemSelect")
    m.browseFollowingList.observeField("itemSelected", "onBrowseItemSelect")
    m.browseFollowingList.observeField("itemFocused", "onBrowseFollowing")

    'm.browseOfflineFollowingList.observeField("itemSelected", "onBrowseItemSelect")
    m.offlineChannelList.observeField("channelSelected", "onBrowseItemSelect")

    'm.channelPage.observeField("videoUrl", "onVideoSelectedFromChannel")
    m.channelPage.observeField("streamUrl", "onLiveStreamSelectedFromChannel")
    m.channelPage.observeField("backgroundImageUri", "onBackgroundChange")
    m.followBar.observeField("streamerSelected", "onBrowseItemSelect")
    m.recentsBar.observeField("streamerSelected", "onBrowseItemSelect")

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

sub onBackgroundChange()
    ? "Home Scene > onBackgroundChange"
    m.top.backgroundImageUri = m.channelPage.backgroundImageUri
end sub

sub onStreamerSelected()
    ? "Home Scene > onStreamerSelected"
    m.channelPage.streamerSelectedName = m.top.streamerSelectedName
    m.channelPage.streamerSelectedThumbnail = m.top.streamerSelectedThumbnail
    m.channelPage.streamItemFocused = false

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
    ? "Home Scene > onLiveStreamSelectedFromChannel"
    m.top.streamUrl = m.channelPage.streamUrl
end sub

sub onNewUser()
    ? "Home Scene > onNewUser"
    ? "Home Scene > onNewUser > loggedInUserProfileImage > " m.top.loggedInUserProfileImage
    m.loggedUserName.text = m.top.loggedInUserName
    m.loggedUserName.color = m.inactiveSelectionColor
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
    ? "Home Scene > onGetFocus"
    if m.top.visible = true
        if m.followBar.focused
            m.followBar.setFocus(true)
        else if m.recentsBar.focused
            m.recentsBar.setFocus(true)
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
    ? "Home Scene > onStreamUrlChange"
    m.top.streamerRequested = m.getStuff.streamerRequested
    m.top.streamUrl = m.getStuff.streamUrl
end sub

'tofix: what is this?
sub onBrowseItemSelect()
    ? "Home Scene > onStreamUrlChange"
    if m.followBar.hasFocus()
        'm.getStuff.streamerRequested = m.followBar.streamerSelected
        'm.getStuff.control = "RUN"
        m.top.streamerSelectedThumbnail = ""
        m.top.streamerSelectedName = m.followBar.streamerSelected
        ? "selected: "; m.top.streamerSelectedName
    else if m.recentsBar.hasFocus()
        m.top.streamerSelectedThumbnail = ""
        m.top.streamerSelectedName = m.recentsBar.streamerSelected
    else if m.browseList.visible = true
        'm.getStuff.streamerRequested = m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).ShortDescriptionLine1
        'm.getStuff.control = "RUN"
        m.top.streamerSelectedName = m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).ShortDescriptionLine1
        m.top.streamerSelectedThumbnail = m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).HDPosterUrl
        'm.top.streamerSelectedThumbnail =  m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).HDPosterUrl
        m.wasLastScene = true
        m.channelPage.streamItemFocused = true
    else if m.browseCategoryList.visible = true
        m.top.categorySelected = m.browseCategoryList.content.getChild(m.browseCategoryList.rowItemSelected[0]).getChild(m.browseCategoryList.rowItemSelected[1]).ShortDescriptionLine1
    else if m.browseFollowingList.hasFocus()
        m.top.streamerSelectedName = m.browseFollowingList.content.getChild(m.browseFollowingList.rowItemSelected[0]).getChild(m.browseFollowingList.rowItemSelected[1]).ShortDescriptionLine1
        m.top.streamerSelectedThumbnail = m.browseFollowingList.content.getChild(m.browseFollowingList.rowItemSelected[0]).getChild(m.browseFollowingList.rowItemSelected[1]).HDPosterUrl
        m.channelPage.streamItemFocused = true
    else if m.browseOfflineFollowingList.hasFocus()
        m.top.streamerSelectedName = m.browseOfflineFollowingList.content.getChild(m.browseOfflineFollowingList.rowItemSelected[0]).getChild(m.browseOfflineFollowingList.rowItemSelected[1]).ShortDescriptionLine1
        m.top.streamerSelectedThumbnail = m.browseOfflineFollowingList.content.getChild(m.browseOfflineFollowingList.rowItemSelected[0]).getChild(m.browseOfflineFollowingList.rowItemSelected[1]).HDPosterUrl
        m.channelPage.streamItemFocused = true
    else if m.offlineChannelList.hasFocus()

        m.top.streamerSelectedName = m.offlineChannelList.channelSelected
        m.top.streamerSelectedThumbnail = ""
        m.channelPage.streamItemFocused = true
    end if
end sub

sub onHomeLoad()
    ? "************ Home Scene **************"
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
    ? "Home Scene > onSearchResultChange"
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
            rowItem.ShortDescriptionLine2 = numberToText(stream.viewers) + " viewers "
            row.appendChild(rowItem)
            cnt += 1
            if cnt <> 0 and cnt mod 3 = 0
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


sub onCategoryResultChange()
    ? "Home Scene > onCategoryResultChange"
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
            rowItem.Description = numberToText(stream.viewers) + " viewers"
            rowItem.ShortDescriptionLine1 = stream.id
            rowItem.HDPosterUrl = stream.logo
            row.appendChild(rowItem)
            cnt += 1
            if cnt <> 0 and cnt mod 7 = 0 and content <> invalid
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
    ? "Home Scene > onCategorySelect"
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
    ? "Home Scene > onFollowingSelect"
    m.browseList.visible = false
    m.browseCategoryList.visible = false
    m.browseFollowingList.visible = true
    'm.browseOfflineFollowingList.visible = true
    m.offlineChannelsLabel.visible = true
end sub

sub getMoreChannels()
    ? "Home Scene > getMoreChannels"
    m.offset += 25
    m.append = true
    m.getStreams.gameRequested = ""
    m.getStreams.offset = m.offset.ToStr()
    m.getStreams.control = "RUN"
end sub

sub getMoreCategories()
    ? "Home Scene > getMoreCategories"
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
    ? "Home Scene > onGetFollowedStreams"
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
            rowItem.ShortDescriptionLine2 = numberToText(stream.viewer_count) + " viewers "
            row.appendChild(rowItem)
            cnt += 1
            if cnt <> 0 and cnt mod 3 = 0
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
    ? "Home Scene > onBrowseFollowing"
    if m.browseFollowingList.itemFocused = m.numRowsInFollowingList
        m.offlineChannelsLabel.translation = [100, 465]
        'm.browseOfflineFollowingList.translation = [100,500]
        m.offlineChannelList.visible = true
    else
        m.offlineChannelsLabel.translation = [100, 700]
        m.browseOfflineFollowingList.translation = [100, 750]
        m.offlineChannelList.visible = false
    end if
end sub

sub onGetOfflineFollowed()
    ? "Home Scene > onGetOfflineFollowed"
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
            if cnt <> 0 and cnt mod 6 = 0
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

sub onKeyEvent(key, press) as boolean
    if press
        ? "Home Scene > onKeyEvent > "; key
    end if
    handled = false
    if m.top.visible = true and press
        if (m.followBar.hasFocus() = true or m.browseList.hasFocus() = true or m.browseCategoryList.hasFocus() = true or m.browseFollowingList.hasFocus() = true or m.channelPage.hasFocus() = true or m.channelPage.streamItemFocused) and key = "up"
            ' Reset focused button when user goes on button header
            if m.followBar.hasFocus() = true
                m.followBar.focused = false
                m.browseMain.translation = "[0, 0]"
                if m.currentlyFocusedButton <> 0
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = m.inactiveSelectionColor
                    m.actualBrowseButtons[0].color = m.focusSelectionColor
                    m.currentlyFocusedButton = 0
                end if
            end if
            m.actualBrowseButtons[m.currentlyFocusedButton].color = m.focusSelectionColor
            m.browseButtons.setFocus(true)
            handled = true
        else if m.browseButtons.hasFocus() = true
            if key = "right"
                if m.currentlyFocusedButton <> 3 and m.currentlyFocusedButton <> 4
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = m.inactiveSelectionColor
                else
                    m.actualBrowseButtons[m.currentlyFocusedButton].blendColor = m.inactiveSelectionColor
                end if
                if m.currentlyFocusedButton < 5
                    m.currentlyFocusedButton += 1
                end if
                'm.actualBrowseButtons[m.currentlyFocusedButton].color =  m.focusSelectionColor
                if m.currentlyFocusedButton <> 3 and m.currentlyFocusedButton <> 4
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = m.focusSelectionColor
                else
                    m.actualBrowseButtons[m.currentlyFocusedButton].blendColor = m.focusSelectionColor
                end if
                handled = true
            else if key = "left"
                'm.actualBrowseButtons[m.currentlyFocusedButton].color =  m.inactiveSelectionColor
                if m.currentlyFocusedButton <> 3 and m.currentlyFocusedButton <> 4
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = m.inactiveSelectionColor
                else
                    m.actualBrowseButtons[m.currentlyFocusedButton].blendColor = m.inactiveSelectionColor
                end if
                if m.currentlyFocusedButton > 0 and not (m.currentlyFocusedButton = 1 and m.currentlySelectedButton = 0)
                    m.currentlyFocusedButton -= 1
                end if
                'm.actualBrowseButtons[m.currentlyFocusedButton].color =  m.focusSelectionColor
                if m.currentlyFocusedButton <> 3 and m.currentlyFocusedButton <> 4
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = m.focusSelectionColor
                else
                    m.actualBrowseButtons[m.currentlyFocusedButton].blendColor = m.focusSelectionColor
                end if
                handled = true
            else if key = "down"
                ' Reset button colours to unfocused colours when user focuses away from header
                for button = 0 to 5
                    if button <> 3 and button <> 4
                        m.actualBrowseButtons[button].color = m.inactiveSelectionColor
                    else
                        m.actualBrowseButtons[button].blendColor = m.inactiveSelectionColor
                    end if
                end for
                if m.currentlySelectedButton = 0
                    m.categoryButton.color = m.activeSelectionColor
                    'm.liveButton.color =  m.inactiveSelectionColor
                    m.browseCategoryList.setFocus(true)
                    m.currentlyFocusedButton = 0
                    handled = true
                else if m.currentlySelectedButton = 1
                    m.liveButton.color = m.activeSelectionColor
                    'm.categoryButton.color =  m.inactiveSelectionColor
                    m.browseList.setFocus(true)
                    m.currentlyFocusedButton = 1
                    handled = true
                else if m.currentlySelectedButton = 2
                    m.followingButton.color = m.activeSelectionColor
                    'm.categoryButton.color =  m.inactiveSelectionColor
                    m.browseFollowingList.setFocus(true)
                    m.followingListIsFocused = true
                    m.currentlyFocusedButton = 2
                    handled = true
                end if
                if m.channelPage.visible
                    m.channelPage.visible = false
                    m.channelPage.visible = true
                end if
            else if key = "OK"
                if m.channelPage.visible
                    m.channelPage.visible = false
                end if
                if m.currentlyFocusedButton = 3
                    m.top.buttonPressed = "search"
                    m.searchLabel.blendColor = m.inactiveSelectionColor
                    m.liveButton.color = m.activeSelectionColor
                    handled = true
                else if m.currentlyFocusedButton = 5
                    m.top.buttonPressed = "login"
                    'm.loginButton.color =  m.inactiveSelectionColor
                    handled = true
                else if m.currentlyFocusedButton = 4
                    m.top.buttonPressed = "options"
                    m.optionsButton.blendColor = m.inactiveSelectionColor
                    handled = true
                else if m.currentlyFocusedButton = 1
                    m.actualBrowseButtons[m.currentlySelectedButton].color = m.inactiveSelectionColor
                    m.searchLabel.blendColor = m.inactiveSelectionColor
                    m.loggedUserName.color = m.inactiveSelectionColor
                    m.liveButton.color = m.activeSelectionColor
                    m.liveLine.visible = true
                    m.categoryLine.visible = false
                    m.categoryButton.color = m.inactiveSelectionColor
                    m.followingLine.visible = false
                    m.getCategories.pagination = ""
                    m.browseList.setFocus(true)
                    m.currentlySelectedButton = 1
                    onHomeLoad()
                    handled = true
                else if m.currentlyFocusedButton = 0
                    m.actualBrowseButtons[m.currentlySelectedButton].color = m.inactiveSelectionColor
                    m.searchLabel.blendColor = m.inactiveSelectionColor
                    m.loggedUserName.color = m.inactiveSelectionColor
                    m.categoryButton.color = m.activeSelectionColor
                    m.categoryLine.visible = true
                    m.liveLine.visible = false
                    m.liveButton.color = m.inactiveSelectionColor
                    m.followingLine.visible = false
                    m.browseCategoryList.setFocus(true)
                    m.currentlySelectedButton = 0
                    onCategorySelect()
                    handled = true
                else if m.currentlyFocusedButton = 2
                    m.actualBrowseButtons[m.currentlyFocusedButton].color = m.activeSelectionColor
                    m.categoryButton.color = m.inactiveSelectionColor
                    m.liveButton.color = m.inactiveSelectionColor
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
        else if (m.browseList.hasFocus() or m.browseCategoryList.hasFocus() or m.browseFollowingList.hasFocus() or m.browseOfflineFollowingList.hasFocus() or m.offlineChannelList.hasFocus() or m.channelPage.streamItemFocused) and key = "left"
            'm.browseButtons.translation = "[200, 0]"
            'm.browseList.translation = "[300,165]"
            'm.browseCategoryList.translation = "[300,165]"
            'm.browseMain.translation = "[250, 0]"
            m.followBar.setFocus(true)
            m.followBar.focused = true
            m.channelPage.streamItemFocused = false
            handled = true
            ' end if
        else if (m.browseList.hasFocus() or m.browseCategoryList.hasFocus() or m.browseFollowingList.hasFocus() or m.browseOfflineFollowingList.hasFocus() or m.offlineChannelList.hasFocus() or m.channelPage.streamItemFocused) and key = "right"
            'm.browseButtons.translation = "[200, 0]"
            'm.browseList.translation = "[300,165]"
            'm.browseCategoryList.translation = "[300,165]"
            'm.browseMain.translation = "[250, 0]"
            ' if key = "right"
            ? "STREAMITEM 2"
            m.recentsBar.setFocus(true)
            m.recentsBar.focused = true
            m.channelPage.streamItemFocused = false
            handled = true
            ' end if
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
                m.channelPage.streamItemFocused = true
                m.channelPage.visible = false
                m.channelPage.visible = true
            end if
            m.followBar.focused = false
            handled = true
        else if m.recentsBar.hasFocus() = true and key = "left"
            'm.browseButtons.translation = "[0, 0]"
            'm.browseList.translation = "[100,165]"
            'm.browseCategoryList.translation = "[100,165]"
            ? "RECENTS ???????????????????????????????????????????????????"
            m.browseMain.translation = "[0, 0]"
            if m.browseList.visible = true
                m.browseList.setFocus(true)
            else if m.browseCategoryList.visible = true
                m.browseCategoryList.setFocus(true)
            else if m.browseFollowingList.visible = true
                m.browseFollowingList.setFocus(true)
                m.followingListIsFocused = true
            else if m.channelPage.visible
                m.channelPage.streamItemFocused = true
                m.channelPage.visible = false
                m.channelPage.visible = true
            end if
            m.recentsBar.focused = false
            handled = true
        else if m.browseList.hasFocus() = true and key = "down"
            getMoreChannels()
            handled = true
        else if m.browseCategoryList.hasFocus() = true and key = "down"
            getMoreCategories()
            handled = true
        else if m.browseFollowingList.hasFocus() = true and key = "down"
            m.offlineChannelsLabel.translation = [100, 465]
            'm.browseOfflineFollowingList.translation = [100,500]
            'm.browseOfflineFollowingList.setFocus(true)
            m.offlineChannelList.visible = true
            m.offlineChannelList.setFocus(true)
            m.followingListIsFocused = false
            handled = true
            'else if m.browseOfflineFollowingList.hasFocus() = true and key = "up"
            ' else if m.browseFollowingList.hasFocus() = true and key = "up"
            '     m.browseButtons.setFocus(true)
            '     handled = true
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
    if m.followBar.hasFocus()
        ? "focus: followbar"
    else if m.recentsBar.hasFocus()
        ? "focus: recentsbar"
    else
        ? "focus: something else"
    end if
    return handled
end sub