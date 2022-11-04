sub init()
     m.bcl = m.top.findNode("browseCategoryList")
     m.bcl.observeField("itemFocused", "onItemFocused")
     m.bcl.observeField("itemFocused", "onItemFocused")
end sub

sub onItemFocused()
     m.bcl.visible = m.bcl.isInFocusChain()
    'if m.bcl.isInFocusChain() = true
     ''     m.bcl.visible = true
     'else
     ''     m.bcl.visible = false
    'end if
end sub