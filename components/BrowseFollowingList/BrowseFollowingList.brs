sub init()
     m.browseFollowingList = m.top.findNode("browseFollowingList")
     m.offlineChannelsLabel = m.top.findNode("offlineChannelsLabel")
     m.browseOfflineFollowingList = m.top.findNode("browseOfflineFollowingList")
     m.browseFollowingList.observeField("itemFocused", "onItemFocused")
     
end sub

sub onItemFocused()
     m.browseFollowingList.visible = m.top.isInFocusChain()
     m.offlineChannelsLabel.visible = m.top.isInFocusChain()
     m.browseOfflineFollowingList.visible = m.top.isInFocusChain()
end sub