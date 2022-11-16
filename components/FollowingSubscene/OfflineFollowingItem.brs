sub init()
     m.itemMask = m.top.findNode("itemMask")
     m.itemThumbnail = m.top.findNode("itemThumbnail")
     m.nameBox = m.top.findNode("nameBox")
     m.nameBoundingBox = m.top.findNode("nameBoundingBox")
     m.channelName = m.top.findNode("channelName")
     deviceInfo = CreateObject("roDeviceInfo")
    
    uiResolutionWidth = deviceInfo.GetUIResolution().width
    m.maskSize = [150, 150]
    if uiResolutionWidth = 1920
       m.maskSize = [225, 225]
    end if
end sub

sub showContent()
    ic = m.top.itemContent
    m.itemThumbnail.uri = ic.HDPosterUrl
    m.channelName.text = ic.Title
    
    cnWidth = m.channelName.localBoundingRect().width
    m.nameBoundingBox.width = cnWidth + 8
    m.nameBox.translation = [(150-cnWidth)/2, 154]
    
    m.itemMask.masksize = m.maskSize
end sub

sub itemFocusChange()
     focused = m.top.itemHasFocus
     if focused
          m.itemMask.opacity = 1.0
     else
          m.itemMask.opacity = 0.5
     end if
     m.nameBox.visible = focused
end sub