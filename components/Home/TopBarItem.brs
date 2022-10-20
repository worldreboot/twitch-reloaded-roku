sub init()
     m.itemGroup = m.top.findNode("itemGroup")
     m.topButtonText = m.top.findNode("topButtonText")
     m.topButtonImage = m.top.findNode("topButtonImage")
     
end sub

sub itemContentChanged() 
     ic = m.top.itemContent
     'm.itemText.text = m.top.itemContent.TITLE
     if ic.HDPosterUrl <> ""
          m.topButtonImage.uri = ic.HDPosterUrl
     else
          m.topButtonText.text = ic.title
          'print ic.ShortDescriptionLine1
          if ic.ShortDescriptionLine1 <> ""
               m.topButtonText.fontUri = ic.ShortDescriptionLine1
               m.topButtonText.fontSize = ic.ShortDescriptionLine2
          end if
     end if
     horizontalAlignTranslation = ((m.top.width - m.top.localBoundingRect().width)/2).ToStr() 
     m.itemGroup.translation = "["+horizontalAlignTranslation+",10]"
     'm.itemGroup.translation = "[0,10]"
     'itemSize="[64,62]"
     
     
     'cat: 22, 122, 40 //+-5
     'live: 4, 156, 24 //+-5
     'fol: 32,104 ,48 //+-5

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