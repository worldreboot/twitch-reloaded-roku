sub init()
     'item found is the rowlist by id
     m.liveRowList = m.top.findNode("liveRowList")
     m.liveRowList.observeField("itemFocused", "onItemFocused")
end sub

sub onItemFocused()
     m.liveRowList.visible = m.liveRowList.isInFocusChain()
end sub