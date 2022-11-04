sub init()
     'item found is the rowlist by id
     m.bfl = m.top.findNode("browseFollowingList")
     m.b2 = m.top.findNode("offlineChannelsLabel")
     m.b3 = m.top.findNode("browseOfflineFollowingList")
     m.bfl.observeField("itemFocused", "onItemFocused")
end sub

sub onItemFocused()
     m.bfl.visible = m.bfl.isInFocusChain()
     m.b2.visible = m.bfl.isInFocusChain()
     m.b3.visible = m.bfl.isInFocusChain()
end sub