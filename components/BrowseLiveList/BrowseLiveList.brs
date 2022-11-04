sub init()
     'item found is the rowlist by id
     m.bll = m.top.findNode("browseList")
     m.bll.observeField("itemFocused", "onItemFocused")
end sub

sub onItemFocused()
     m.bll.visible = m.bll.isInFocusChain()
end sub