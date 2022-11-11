sub init()
     m.followingRowList = m.top.findNode("followingRowList")
     m.offlineChannelsLabel = m.top.findNode("offlineChannelsLabel")
     m.offlineFollowingRowList = m.top.findNode("offlineFollowingRowList")
     m.followingRowList.observeField("itemFocused", "onItemFocused")
     m.offlineFollowingRowList.observeField("itemFocused", "onItemFocused")
     m.top.observeField("hasFocus", "onGetFocus")
end sub

sub onItemFocused()
     subsceneVisibility = m.top.isInFocusChain()
     m.followingRowList.visible = subsceneVisibility
     m.offlineChannelsLabel.visible = subsceneVisibility
     m.offlineFollowingRowList.visible = subsceneVisibility
     
     ' totest: check with one row'
     if m.followingRowList.content <> invalid
          if m.offlineFollowingRowList.hasFocus() OR m.followingRowList.itemFocused >= m.followingRowList.content.getChildCount() - 1
               m.offlineChannelsLabel.translation = [0,300]
               m.offlineFollowingRowList.translation = [0,350]
          else
               m.offlineChannelsLabel.translation = [0,530]
               m.offlineFollowingRowList.translation = [0,560]
          end if
     end if
end sub

sub populateFollowedList()
     content = createObject("roSGNode", "ContentNode")
    if m.top.followedStreams <> invalid
        row = invalid
        cnt = 0
        for each stream in m.top.followedStreams
             if cnt MOD 3 = 0
                    row = createObject("RoSGNode", "ContentNode")
                    content.appendChild(row)
             end if
            rowItem = createObject("RoSGNode", "ContentNode")
            rowItem.Title = stream.title
            rowItem.Description = stream.user_name
            rowItem.Categories = stream.game_id
            rowItem.HDPosterUrl = stream.thumbnail
            rowItem.ShortDescriptionLine1 = stream.login
            rowItem.ShortDescriptionLine2 = numberToText(stream.viewer_count)  + " viewers"
            row.appendChild(rowItem)
            cnt++
        end for
    end if
    m.followingRowList.content = content
end sub

sub populateOfflineFollowedList()
     lastFocusedRow = 0
     if m.offlineFollowingRowList.rowItemFocused[0] <> invalid
         lastFocusedRow = m.offlineFollowingRowList.rowItemFocused[0]
     end if
     
     content = createObject("roSGNode", "ContentNode")
    if m.top.offlineFollowedStreams <> invalid
        row = invalid
        cnt = 0
        for each stream in m.top.offlineFollowedStreams
        if cnt MOD 7 = 0
               row = createObject("RoSGNode", "ContentNode")
               content.appendChild(row)
        end if
             rowItem = createObject("RoSGNode", "ContentNode")
             rowItem.Title = stream.display_name
             rowItem.ShortDescriptionLine1 = stream.login
             rowItem.HDPosterUrl = stream.profile_image_url
             row.appendChild(rowItem)
             cnt++
        end for
    end if
    m.offlineFollowingRowList.content = content
    m.offlineFollowingRowList.jumpToItem = lastFocusedRow
    
end sub

'this leads to doulbe button press interpretations with homescene for some reason.'
'function onKeyEvent(key, press) as Boolean
''     handled = false
''     if key = "up" AND m.offlineFollowingRowList.hasFocus()
''               m.followingRowList.setFocus(true)
''               handled = true
''     else if key = "down" AND m.followingRowList.hasFocus() 
''               m.offlineFollowingRowList.setFocus(true)
''               handled = true
''     end if
''     ? "Following sscene > key " key " " handled
''     return handled
'end function
