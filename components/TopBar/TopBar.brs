sub init()
     m.topBarButtons = m.top.findNode("topBarButtons")
     m.topBarButtons.observeField("itemSelected", "onTopBarItemSelected")
     
     m.lastSelectedScene = 1
     m.topBarButtons.jumpToItem = m.lastSelectedScene
end sub

sub onItemSelected()
     
end sub
