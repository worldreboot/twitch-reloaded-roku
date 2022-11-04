sub init()
     m.itemGroup = m.top.findNode("itemGroup")
     m.topButtonText = m.top.findNode("topButtonText")
     m.topButtonImage = m.top.findNode("topButtonImage")
     m.profileImageMask = m.top.findNode("profileImageMask")
     
end sub

'descriptionLines and Rating are used for other data!

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
     m.profileImageMask.masksize = [Val(ic.Rating), Val(ic.Rating)]
     m.profileImageMask.maskuri ="pkg:/images/profile-mask.png"
     'm.top.appendChild(m.profileImageMask)
end sub

