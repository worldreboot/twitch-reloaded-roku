sub init()
     m.itemGroup = m.top.findNode("itemGroup")
     m.topButtonText = m.top.findNode("topButtonText")
     m.topButtonImage = m.top.findNode("topButtonImage")
     m.profileImageMask = m.top.findNode("profileImageMask")
     
end sub

sub itemContentChanged() 
     ic = m.top.itemContent
     'm.itemText.text = m.top.itemContent.TITLE

     if ic.HDPosterUrl <> ""
          m.topButtonImage.uri = ic.HDPosterUrl
     else if ic.title <> ""
          m.topButtonText.text = ic.title
          'print ic.ShortDescriptionLine1
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

     'm.itemGroup.translation = "[0,10]"
     'itemSize="[64,62]"
     
     
     'cat: 22, 122, 40 //+-5
     'live: 4, 156, 24 //+-5
     'fol: 32,104 ,48 //+-5
end sub

sub showUserLogin()
     'tofix: test long usernames
     'it seems 60 characters is the maximum. probably gonna need to measure that before moving objects
     ic = m.top.itemContent
     m.topButtonImage.uri = ic.HDPosterUrl
     m.topButtonImage.height = "50"
     m.topButtonImage.width = "50"
     'm.topButtonImage.size = "[50,50]"
     m.topButtonText.text = ic.title
     m.topButtonText.translation = "[60,20]"
     m.profileImageMask.masksize = "["+ic.Rating+","+ic.Rating+"]"
     m.profileImageMask.maskuri ="pkg:/images/profile-mask.png"
     'm.top.appendChild(m.profileImageMask)
end sub


sub showFocus()
     if m.top.itemHasFocus
          'm.topButtonText.color = "0x00FFD1FF"
          'm.topButtonImage.blendColor = "0x00FFD1FF"
     else
          'm.topButtonText.color = "0xEFEFF1FF"
          'm.topButtonImage.blendColor = "0xEFEFF1FF"
     end if
     
     'm.itemFocusLine.opacity = m.top.focusPercent
 end sub