sub init()
    m.liveRowList = m.top.findNode("liveRowList")
    m.categoryRowList = m.top.findNode("categoryRowList")
    
    m.followingSubscene = m.top.findNode("followingSubscene")
    m.followingRowList = m.top.findNode("followingRowList")
    m.offlineFollowingRowList = m.top.findNode("offlineFollowingRowList")
    m.offlineChannelsLabel = m.top.findNode("offlineChannelsLabel")

    m.channelPage = m.top.findNode("channelPage")
    m.sidebar = m.top.findNode("sidebar")

    m.headerRect = m.top.findNode("headerRect")

    m.liveRowList.observeField("itemSelected", "openItemChannelPage")
    m.categoryRowList.observeField("itemSelected", "onCategoryItemSelect")
    m.followingRowList.observeField("itemSelected", "openItemChannelPage")

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
    m.sideBarButtons.observeField("itemSelected", "openItemChannelPage")
    m.topBarButtons = m.top.findNode("topBarButtons")
    m.topBarButtons.observeField("itemSelected", "onTopBarItemSelected")
    m.lastSelectedScene = 1
    m.topBarButtons.jumpToItem = m.lastSelectedScene

    m.offset = 0
    m.append = false
    m.offsetCategory = 0
    m.appendCategory = false
    m.appLaunchComplete = false

    if m.top.visible = true
        onHomeLoad()
    end if

    m.currentSubscene = m.liveRowList
    m.currentSubscene.setFocus(true)
    
end sub

sub refreshHomeSubscenes()
     m.categoryRowList.visible = false
     m.liveRowList.visible = false
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
          m.currentSubscene.content = createObject("roSGNode", "ContentNode")
          onCategorySelect()
     else if i = 1
          m.currentSubscene = m.liveRowList
          m.currentSubscene.content = createObject("roSGNode", "ContentNode")
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
     'this resets the visible layout'
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
     if m.liveRowList.hasFocus()
          list = m.liveRowList
     else if m.followingRowList.hasFocus()
          list = m.followingRowList
     else if m.sideBarButtons.hasFocus()
          list = m.sideBarButtons
     else if m.offlineFollowingRowList.hasFocus()
          list = m.offlineFollowingRowList
     end if
     
     refreshHomeSubscenes()
     if list.subtype() = "MarkupGrid"
          item = list.content.getChild(list.itemSelected)
     else if  list.subtype() = "RowList"
          item = list.content.getChild(list.rowItemSelected[0]).getChild(list.rowItemSelected[1])
     end if
     m.channelPage.streamerSelectedName = item.ShortDescriptionLine1
     m.top.streamerSelectedName = item.ShortDescriptionLine1
     m.channelPage.streamerSelectedThumbnail = item.HDPosterUrl
end sub

sub onHomeLoad()
    m.getStreams.gameRequested = ""
    m.getStreams.offset = "0"
    m.getStreams.pagination = ""
    m.offset = 0
    m.getStreams.control = "RUN"
end sub

sub onSearchResultChange()
     m.liveSubscene = m.top.findNode("liveSubscene")
     m.liveSubscene.liveStreams = m.getStreams.searchResults
     if m.appLaunchComplete <> true
         m.top.signalBeacon("AppLaunchComplete")
         m.appLaunchComplete = true
     end if
end sub

sub onCategoryResultChange()
     m.categorySubscene = m.top.findNode("categorySubscene")
     m.categorySubscene.categories = m.getCategories.searchResults
end sub

sub onCategorySelect()
     m.getCategories.pagination = ""
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
    m.followingSubscene.followedStreams = m.top.followedStreams
end sub

sub onGetOfflineFollowed()
    m.followingSubscene.offlineFollowedStreams = m.getOfflineFollowed.offlineFollowedUsers
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
     if m.top.visible = true and press
     
          if key = "up" and not m.topBarButtons.hasFocus()
                if m.offlineFollowingRowList.hasFocus() 
                'should this use currentSubscene?'
                    m.followingRowList.setFocus(true)
                    handled = true
               else
                    m.topBarButtons.setFocus(true)
                    handled = true
               end if
          else if key = "down"
                if m.topBarButtons.hasFocus()
                'print m.followingRowList.content.getChildCount()
                ' tofix: this doesnt allow me to access offline channels'
                'tofix: it seems that content can be uninitialized. then it should be content <> invalid'
          ''           if m.followingRowList.visible  AND  m.followingRowList.content.getChildCount() = 0
          ''               return false
          ''          end if
                     if m.channelPage.visible
                         m.channelPage.visible = false
                         m.channelPage.visible = true
                         handled = true
                    else
                         m.currentSubscene.setFocus(true)
                         handled = true
                    end if
                         handled = true
                    else if m.liveRowList.hasFocus()
                         getMoreChannels()
                         handled = true
                    else if m.categoryRowList.hasFocus() 
                         getMoreCategories()
                         handled = true
                    else if m.followingRowList.hasFocus() 
                    'should this use currentSubscene?'
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