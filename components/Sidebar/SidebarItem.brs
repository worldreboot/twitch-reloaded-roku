sub init()
     m.itemGroup = m.top.findNode("itemGroup")
     m.focusedGroup = m.top.findNode("focusedGroup")
    m.itemMask = m.top.findNode("itemMask")
    m.streamerProfile = m.top.findNode("streamerProfile")
    m.boundingBox = m.top.findNode("boundingBox")
    m.streamerName = m.top.findNode("streamerName")
    m.gameId = m.top.findNode("gameId")
    m.selectionIndicator = m.top.findNode("selectionIndicator")
     'm.selectionIndicator.visible = false
end sub


sub showContent()
    ic = m.top.itemContent
    'm.itemGroup.translation = ""
    'mask´s size
    'profile uri
    ' idk'
     if ic <> invalid 
         m.streamerProfile.uri = ic.profile_image_url
         m.streamerName.text = ic.user_name
         m.gameId.text = ic.game_id
         m.itemGroup.translation = "[5," + ic.yOffset.ToStr() + "]"
         m.itemMask.maskSize = ic.maskSize
         'm.selectionIndicator.visible = false
     end if
end sub

sub showfocus()
      'm.itemcursor.opacity = m.top.focusPercent
      'm.itemposter.opacity = m.top.focusPercent
 end sub

     

'sub OnContentSet() ' invoked when item metadata retrieved
''    content = m.top.itemContent
    ' set poster uri if content is valid
''    if content <> invalid 
''        m.top.FindNode("poster").uri = content.hdPosterUrl
 ''   end if
'end sub
