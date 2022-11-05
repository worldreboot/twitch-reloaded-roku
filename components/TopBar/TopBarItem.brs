sub init()
     m.itemGroup = m.top.findNode("itemGroup")
     m.topButtonText = m.top.findNode("topButtonText")
     m.topButtonImage = m.top.findNode("topButtonImage")
     m.profileImageMask = m.top.findNode("profileImageMask")
     
     deviceInfo = CreateObject("roDeviceInfo")
     uiResolutionWidth = deviceInfo.GetUIResolution().width
     if uiResolutionWidth >= 1920
          m.maskSize = [75, 75]
     else
          m.maskSize = [50, 50]
     end if
end sub

'shortDescriptionLines are used for other data!

sub itemContentChanged() 
     ic = m.top.itemContent
     if ic.HDPosterUrl <> ""
          m.topButtonImage.uri = ic.HDPosterUrl
     else if ic.title <> ""
          m.topButtonText.text = ic.title
     end if
     
     horizontalAlignTranslation = ((ic.w*64 - m.top.localBoundingRect().width)/2).ToStr() 
     m.itemGroup.translation = "["+horizontalAlignTranslation+",10]"
     
     if ic.ShortDescriptionLine1 <> ""
          m.topButtonText.fontUri = ic.ShortDescriptionLine1
          m.topButtonText.fontSize = ic.ShortDescriptionLine2
          if ic.HDPosterUrl <> ""
               showUserLogin()
          end if
     end if
end sub

sub showUserLogin()
     ic = m.top.itemContent
     m.topButtonImage.uri = ic.HDPosterUrl
     m.topButtonImage.height = "50"
     m.topButtonImage.width = "50"
     m.topButtonText.text = ic.title
     m.topButtonText.translation = "[60,20]"
     m.profileImageMask.masksize = m.maskSize
     m.profileImageMask.maskuri ="pkg:/images/profile-mask.png"
end sub

