sub init()
     m.categoryRowList = m.top.findNode("categoryRowList")
     m.categoryRowList.observeField("itemFocused", "onItemFocused")
     m.categoryRowList.observeField("itemFocused", "onItemFocused")
end sub

sub onItemFocused()
     m.categoryRowList.visible = m.categoryRowList.isInFocusChain()
end sub