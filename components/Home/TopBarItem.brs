sub init()
     m.itemGroup = m.top.findNode("itemGroup")
     m.testlbl = m.top.findNode("testlbl")
end sub

function itemContentChanged() 
   'm.itemText.text = m.top.itemContent.TITLE
   m.testlbl.text = m.top.itemContent.title
 end function


sub showfocus()

 end sub