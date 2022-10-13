sub init()
     m.itemGroup = m.top.findNode("itemGroup")
     m.focusedGroup = m.top.findNode("focusedGroup")
    m.itemMask = m.top.findNode("itemMask")
    m.streamerProfile = m.top.findNode("streamerProfile")
    m.boundingBox = m.top.findNode("boundingBox")
    m.streamerName = m.top.findNode("streamerName")
    m.gameId = m.top.findNode("gameId")
    m.selectionIndicator = m.top.findNode("selectionIndicator")
end sub

sub showContent()
    ic = m.top.itemContent
     if ic <> invalid 
          m.streamerProfile.uri = ic.profile_image_url
          m.streamerName.text = ic.user_name
          m.gameId.text = ic.game_id
          m.itemGroup.translation = "[5," + ic.yOffset.ToStr() + "]"
          m.itemMask.maskSize = ic.maskSize
          bbw = m.streamerName.localBoundingRect().width + 36
          if m.streamerName.localBoundingRect().width < m.gameId.localBoundingRect().width
               bbw = m.gameId.localBoundingRect().width + 36
          end if
          m.boundingBox.width = bbw
     end if
end sub

sub showfocus()
      m.focusedGroup.opacity = m.top.focusPercent
 end sub