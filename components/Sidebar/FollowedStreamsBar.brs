sub init()
     m.sidebarMarkupList = m.top.FindNode("sidebarMarkupList")
    m.top.focusable = true
    m.children = []
    m.focusedItem = 2
    for child = 2 to m.top.getChildCount() - 1
' what does this do??'
        m.children.push(m.top.getChild(child))
    end for
    m.currentIndex = 0
    m.min = 0
    m.max = 11

    deviceInfo = CreateObject("roDeviceInfo")
    uiResolutionWidth = deviceInfo.GetUIResolution().width
    
    if uiResolutionWidth = 1920
        m.maskSize = [75, 75]
    else
        m.maskSize = [50, 50]
    end if
end sub


sub onFollowedStreamsChange()
    translation = 40
    '? "we got there"
 ''''''  m.top.removeChildren(m.children)
    m.currentIndex = 0
    m.min = 0
    m.max = 9
    
    fs = m.top.followedStreams
    print fs[1]
    For i=0 To fs.Count() - 1 Step +1 
          s = createObject("roSGNode", "SidebarItem")
          fs[i].yOffset = 120 + (i * 60)
          fs[i].maskSize = m.maskSize
          s.itemContent = fs[i]
          s.streamLink = fs.[i].login
          m.top.appendChild(s)
    End For

     'for each stream in m.top.followedStreams
     ''     s = createObject("roSGNode", "SidebarItem")
     ''          s.itemContent = stream
     ''     m.top.appendChild(s)
    'end for
    
end sub

sub onGetFocus()
    if m.top.focused = true
        if m.top.getChild(m.focusedItem) <> invalid
          m.top.getChild(m.focusedItem).focusPercent = 1.0
        end if
    else if m.top.focused = false 
        if m.top.getChild(m.focusedItem) <> invalid
                m.top.getChild(m.focusedItem).focusPercent = 0.0
        end if
    end if
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
      'print "current index: "
      'print  m.currentIndex
      'print "m.top.getChildCount() "
      'print m.top.getChildCount()
      'print "m.children[m.currentIndex]"
      'print m.top.getChild(m.focusedItem)
    if press
        if key = "up"
            if m.focusedItem - 1 >= 2
               m.top.getChild(m.focusedItem).focusPercent = 0.0
                m.focusedItem -= 1
                m.top.getChild(m.focusedItem).focusPercent = 1.0
                
                handled = true
            end if
        else if key = "down"
            if m.focusedItem + 1 < m.top.getChildCount()
                if m.top.getChild(m.focusedItem+1) <> invalid
                    m.top.getChild(m.focusedItem).focusPercent = 0.0
                    m.focusedItem += 1
                    m.top.getChild(m.focusedItem).focusPercent = 1.0
                end if
               
            end if
        else if key = "OK"
            if m.top.getChild(m.focusedItem) <> invalid
            'TRY
            'print m.top.getChild(m.focusedItem)
                m.top.streamerSelected = m.top.getChild(m.focusedItem).streamLink
          ''     PRINT "It worked!"
           'CATCH e     
          ''      PRINT "It went wrong:",e.message
          'END TRY
                
            end if
        end if
    end if
    return handled
end sub