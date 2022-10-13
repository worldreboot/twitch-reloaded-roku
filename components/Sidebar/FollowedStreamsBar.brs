sub init()
     
    m.top.focusable = true
    m.focusedItem = 2
    m.min = 2
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
    fs = m.top.followedStreams
    items = fs.Count()
    if items > m.max
         items = m.max
     end if

    offset = 40
     for each stream in m.top.followedStreams
          if m.top.getChildCount() > m.max
               exit for
          end if
          s = createObject("roSGNode", "SidebarItem")
          stream.yOffset = offset
          stream.maskSize = m.maskSize
          s.itemContent = stream
          s.streamLink = stream.login
          m.top.appendChild(s)
          offset += 60
    end for
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
    if press
         if key = "up"
               if m.focusedItem = m.min
                      'tofix: add behaviour to move to top bar'
               end if
               if m.focusedItem - 1 >= m.min
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
                m.top.streamerSelected = m.top.getChild(m.focusedItem).streamLink
                handled = true
            end if
        end if
    end if
    return handled
end sub