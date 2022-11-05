sub init()
     m.focusedGroup = m.top.findNode("focusedGroup")
     m.itemMask = m.top.findNode("itemMask")
     m.streamerProfile = m.top.findNode("streamerProfile")
     m.boundingBox = m.top.findNode("boundingBox")
     m.streamerName = m.top.findNode("streamerName")
     m.gameId = m.top.findNode("gameId")
    
     deviceInfo = CreateObject("roDeviceInfo")
     uiResolutionWidth = deviceInfo.GetUIResolution().width
     if uiResolutionWidth = 1920
          m.maskSize = [75, 75]
     else
          m.maskSize = [50, 50]
     end if
end sub

sub showContent()
    ic = m.top.itemContent
     m.streamerProfile.uri = ic.HDPosterUrl
     m.streamerName.text = ic.Title
     m.gameId.text = ic.ShortDescriptionLine2
     m.top.streamLink = ic.ShortDescriptionLine1
     m.itemMask.maskSize = m.maskSize
     bbw = m.streamerName.localBoundingRect().width + 36
     if m.streamerName.localBoundingRect().width < m.gameId.localBoundingRect().width
          bbw = m.gameId.localBoundingRect().width + 36
     end if
     m.boundingBox.width = bbw
end sub

sub showfocus()
      m.focusedGroup.visible = m.top.itemHasFocus
end sub