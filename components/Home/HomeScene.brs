sub init()
    m.browseList = m.top.findNode("browseList")
    m.categoryRowList = m.top.findNode("categoryRowList")
    m.followingRowList = m.top.findNode("followingRowList")
    m.offlineFollowingRowList = m.top.findNode("offlineFollowingRowList")
    m.offlineChannelsLabel = m.top.findNode("offlineChannelsLabel")

    m.channelPage = m.top.findNode("channelPage")
    m.sidebar = m.top.findNode("sidebar")
    m.browseButtons = m.top.findNode("browseButtons")
    m.browseMain = m.top.findNode("browseMain")

    m.loggedUserGroup = m.top.findNode("loggedUserGroup")
    m.profileImage = m.top.findNode("profileImage")
    m.loggedUserName = m.top.findNode("loggedUserName")

    m.headerRect = m.top.findNode("headerRect")

    m.browseList.observeField("itemSelected", "openItemChannelPage")
    m.categoryRowList.observeField("itemSelected", "onCategoryItemSelect")
    m.followingRowList.observeField("itemSelected", "openItemChannelPage")
    m.followingRowList.observeField("itemFocused", "onBrowseFollowing")

    'm.offlineFollowingRowList.observeField("itemSelected", "onBrowseItemSelect")
    m.offlineFollowingRowList.observeField("itemSelected", "openItemChannelPage")
    m.sidebar.observeField("streamerSelected", "openItemChannelPage")

    'm.channelPage.observeField("videoUrl", "onVideoSelectedFromChannel")
    m.channelPage.observeField("streamUrl", "onLiveStreamSelectedFromChannel")

    m.getStreams = createObject("roSGNode", "GetStreams")
    m.getStreams.observeField("searchResults", "onSearchResultChange")

    m.getStuff = createObject("roSGNode", "GetStuff")
    m.getStuff.observeField("streamUrl", "onStreamUrlChange")

    m.getCategories = createObject("roSGNode", "GetCategories")
    m.getCategories.observeField("searchResults", "onCategoryResultChange")

    m.getOfflineFollowed = createObject("roSGNode", "GetOfflineFollowedChannels")
    m.getOfflineFollowed.observeField("offlineFollowedUsers", "onGetOfflineFollowed")

    m.top.observeField("visible", "onGetFocus")
    m.top.observeField("currentlyLiveStreamerIds", "onGetFollowedStreams")
   
   'tofix: currently required in the process to load a channel'
    m.top.observeField("streamerSelectedName", "onStreamerSelected")

    m.sideBarButtons = m.top.findNode("sideBarButtons")
    m.topBarButtons = m.top.findNode("topBarButtons")
    m.topBarButtons.observeField("itemSelected", "onTopBarItemSelected")
    m.topBarButtons.jumpToItem = m.lastSelectedScene

    m.offset = 0
    m.append = false
    m.offsetCategory = 0
    m.appendCategory = false
    m.appLaunchComplete = false

    m.numRowsInFollowingList = 0

    if m.top.visible = true
        onHomeLoad()
    end if

    m.browseList.setFocus(true)
    m.currentSubscene = m.browseList
    m.lastSelectedScene = 1
end sub

sub refreshHomeSubscenes()
     m.categoryRowList.visible = false
     m.browseList.visible = false
     m.followingRowList.visible = false
     m.offlineFollowingRowList.visible = false
     m.offlineChannelsLabel.visible = false
     m.channelPage.visible = false
end sub

sub onSelectedSubsceneChange()
     m.top.currentSubscene.setFocus(true)
end sub

sub onTopBarItemSelected()
     i = m.topBarButtons.itemSelected
     refreshHomeSubscenes()
     if i = 0 
          m.currentSubscene = m.categoryRowList
          onCategorySelect()
     else if i = 1
          m.getCategories.pagination = ""
          m.currentSubscene = m.browseList
          onHomeLoad()
     else if i = 2
          m.currentSubscene = m.followingRowList
     else if i = 3
          m.top.buttonPressed = "search"
     else if i = 4
          m.top.buttonPressed = "options"
     else if i = 5
          m.top.buttonPressed = "login"
     end if
     
     if i < 3
          m.lastSelectedScene = i
          m.currentSubscene.setFocus(true)
     else 
          m.topBarButtons.jumpToItem = m.lastSelectedScene
     end if
end sub

'tofix: should be out of use already, but a check is needed. It seems its called in categoryscene'
sub onStreamerSelected()
     refreshHomeSubscenes()
    m.channelPage.streamerSelectedName = m.top.streamerSelectedName
    m.channelPage.streamerSelectedThumbnail = m.top.streamerSelectedThumbnail
    'm.wasLastScene = true
    m.channelPage.visible = true
end sub

sub onLiveStreamSelectedFromChannel()
    m.top.streamUrl = m.channelPage.streamUrl
end sub

sub onNewUser()
     x = 13
     w = 3
     if len(m.top.loggedInUserName) > 15
          x = 12
          w = 4
     end if
     for i = 3 to 5
          updateX = {"x":x.toStr()}
          m.topBarButtons.content.getChild(i).update(updateX)
          x++
     end for
     
     uLogin = {"w":w.toStr(), "title":m.top.loggedInUserName, "HDPosterUrl":m.top.loggedInUserProfileImage}
     m.topBarButtons.content.getChild(5).update(uLogin)
     
     m.topBarButtons.fixedLayout = false
     m.topBarButtons.fixedLayout = true
     
     width = w*64
     m.headerRect.width = 1352 + 64 - width
end sub

sub onGetFocus()
    if m.top.visible = true
        if m.channelPage.visible
            'm.channelPage.setFocus(true)
            m.channelPage.visible = false
            m.channelPage.visible = true
        else
          m.currentSubscene.setFocus(true)
        end if
    end if
end sub

sub onStreamUrlChange()
    ? "HomeScene > streamURL change > " m.getStuff.streamerRequested
    m.top.streamerRequested = m.getStuff.streamerRequested
    m.top.streamUrl = m.getStuff.streamUrl
end sub

sub onCategoryItemSelect()
     list = m.categoryRowList
     item = list.content.getChild(list.rowItemSelected[0]).getChild(list.rowItemSelected[1])
     m.top.categorySelected = item.ShortDescriptionLine1
end sub

'tofix: this should be handled by the row lists, but the attributes seem to be being wached'
sub openItemChannelPage()
     list = invalid
     itemName = invalid
     
     if m.browseList.hasFocus()
          list = m.browseList
     else if m.followingRowList.hasFocus()
          list = m.followingRowList
     else  if m.sideBarButtons.hasFocus()
          itemName = m.sidebar.streamerSelected
     else if m.offlineFollowingRowList.hasFocus()
          list = m.offlineFollowingRowList
     end if

     refreshHomeSubscenes()
     
     if itemName = invalid
          item = list.content.getChild(list.rowItemSelected[0]).getChild(list.rowItemSelected[1])
          m.channelPage.streamerSelectedName = item.ShortDescriptionLine1
          m.top.streamerSelectedName = item.ShortDescriptionLine1
          m.channelPage.streamerSelectedThumbnail = item.HDPosterUrl
     else
          m.top.streamerSelectedName = itemName
          m.channelPage.streamerSelectedName = itemName
          'm.channelPage.streamerSelectedThumbnail = ""
     end if
     m.channelPage.visible = true
end sub

sub onHomeLoad()
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
            rowItem.ShortDescriptionLine2 = numberToText(stream.viewers)  + " viewers"
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

sub onCategoryResultChange()
    lastFocusedRow = 0
    if m.categoryRowList.rowItemFocused[0] <> invalid
        lastFocusedRow = m.categoryRowList.rowItemFocused[0]
    end if
    if m.appendCategory = true
        content = m.categoryRowList.content
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
    m.categoryRowList.content = content
    m.categoryRowList.jumpToItem = lastFocusedRow
    m.appendCategory = false
end sub

sub onCategorySelect()
    m.getCategories.searchText = ""
    m.getCategories.offset = "0"
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

sub onGetFollowedStreams()
    m.getOfflineFollowed.loginRequested = m.top.loggedInUserName
    m.getOfflineFollowed.currentlyLiveStreamerIds = m.top.currentlyLiveStreamerIds
    '? "currentlyLiveStreamerIds homescene " m.getOfflineFollowed.currentlyLiveStreamerIds
    m.getOfflineFollowed.control = "RUN"

    m.numRowsInFollowingList = 0
    lastFocusedRow = 0
    if m.followingRowList.rowItemFocused[0] <> invalid
        lastFocusedRow = m.followingRowList.rowItemFocused[0]
    end if
    if m.append = true
        content = m.followingRowList.content
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
            rowItem.ShortDescriptionLine2 = numberToText(stream.viewer_count)  + " viewers"
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
    m.followingRowList.content = content
    m.followingRowList.jumpToItem = lastFocusedRow
    m.append = false
    m.numRowsInFollowingList -= 1
end sub

sub onBrowseFollowing()
    if m.followingRowList.itemFocused = m.numRowsInFollowingList
    'todo: check this translations when i have more than 3 active following channels'
        m.offlineChannelsLabel.translation = [0,300]
        'm.offlineFollowingRowList.translation = [100,500]
        m.offlineFollowingRowList.visible = true
    else
        m.offlineChannelsLabel.translation = [0,560]
        m.offlineFollowingRowList.translation = [0,360]
        m.offlineFollowingRowList.visible = false
    end if
end sub

sub onGetOfflineFollowed()
    lastFocusedRow = 0
    if m.offlineFollowingRowList.rowItemFocused[0] <> invalid
        lastFocusedRow = m.offlineFollowingRowList.rowItemFocused[0]
    end if
    if m.append = true
        content = m.offlineFollowingRowList.content
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
            if cnt <> 0 and cnt MOD 7 = 0
                content.appendChild(row)
                row = createObject("RoSGNode", "ContentNode")
                alreadyAppended = true
            end if
        end for
        if row <> invalid and alreadyAppended = false
            content.appendChild(row)
        end if
    end if
    m.offlineFollowingRowList.content = content
    m.offlineFollowingRowList.jumpToItem = lastFocusedRow
    m.append = false
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
     if m.top.visible = true and press
     
          if key = "up" and not m.topBarButtons.hasFocus()
               if m.offlineFollowingRowList.hasFocus()
                    m.followingRowList.setFocus(true)
               else 
                    m.topBarButtons.setFocus(true)
               end if
               handled = true
          
          else if key = "down"
                if m.topBarButtons.hasFocus()
                    if m.followingRowList.visible AND m.followingRowList.content = invalid
                         return false
                    end if
                    if m.channelPage.visible
                         m.channelPage.visible = false
                         m.channelPage.visible = true
                    else
                         m.currentSubscene.setFocus(true)
                    end if
                    handled = true
               else if m.browseList.hasFocus()
                    getMoreChannels()
                    handled = true
               else if m.categoryRowList.hasFocus() 
                    getMoreCategories()
                    handled = true
               else if m.followingRowList.hasFocus() 
                    m.offlineChannelsLabel.translation = [0,300]
                    m.offlineFollowingRowList.setFocus(true)
                    handled = true
               end if
               
          else if key = "left" and not m.sideBarButtons.hasFocus()
               if m.sideBarButtons.content.getChildCount() = 0
                    return false
               end if
               m.sideBarButtons.setFocus(true)
               handled = true
          else if m.sideBarButtons.hasFocus() = true and key = "right"
               if m.currentSubscene.visible
                    m.currentSubscene.setFocus(true) 
               else if m.channelPage.visible
               'tofix: should gain visibility on focus, not focus on visibility
                    m.channelPage.visible = false
                    m.channelPage.visible = true
               end if
               handled = true

          else if key = "back"
               if m.channelPage.visible
                    m.channelPage.visible = false
                    m.currentSubscene.setFocus(true)
                    handled = true
               end if
          end if
     end if

    ? "HOMESCENE > key " key " " handled
    return handled
end sub