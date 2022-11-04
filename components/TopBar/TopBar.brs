sub init()
     'm.topBarButtons = m.top.findNode("topBarButtons")
     m.tbb = m.top.findNode("topBarButtons")
     m.tbb.observeField("itemSelected", "onTopBarItemSelected")
     
     m.lastSelectedScene = 1
     m.tbb.jumpToItem = m.lastSelectedScene
end sub


sub onItemSelected()
     
end sub

sub onGetFocus()
    if m.top.focused = true
     ''   if m.top.getChild(m.topBarButtons.itemFocused) <> invalid
''          m.top.getChild(m.topBarButtons.itemFocused).focusPercent = 1.0
      ''  end if
    else if m.top.focused = false 
''        if m.top.getChild(m.topBarButtons.itemFocused) <> invalid
''                m.top.getChild(m.topBarButtons.itemFocused).focusPercent = 0.0
       '' end if
    end if
end sub