sub init()
     m.followingRowList = m.top.findNode("followingRowList")
     m.offlineChannelsLabel = m.top.findNode("offlineChannelsLabel")
     m.offlineFollowingRowList = m.top.findNode("offlineFollowingRowList")
     m.followingRowList.observeField("itemFocused", "onItemFocused")
     
end sub

sub onItemFocused()
     m.followingRowList.visible = m.top.isInFocusChain()
     m.offlineChannelsLabel.visible = m.top.isInFocusChain()
     m.offlineFollowingRowList.visible = m.top.isInFocusChain()
end sub