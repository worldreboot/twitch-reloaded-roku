sub init()
     m.topBarButtons = m.top.findNode("topBarButtons")
     
     m.lastSelectedScene = 1
     m.topBarButtons.jumpToItem = m.lastSelectedScene
end sub