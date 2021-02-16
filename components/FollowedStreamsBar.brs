sub init()
    m.top.focusable = true
    m.children = []
    for child = 2 to m.top.getChildCount() - 1
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

sub numberToText(number) as Object
    s = StrI(number)
    result = ""
    if number >=100000 and number < 1000000
        result = Left(s, 4) + "K"
    else if number >=10000 and number < 100000
        result = Left(s, 3) + "." + Mid(s, 4, 1) + "K"
    else if number >=1000 and number < 10000
        result = Left(s, 2) + "." + Mid(s, 3, 1) + "K"
    else if number < 1000
        result = s
    end if
    return result
end sub

sub onFollowedStreamsChange()
    translation = 40
    '? "we got there"
    m.top.removeChildren(m.children)
    m.currentIndex = 0
    m.min = 0
    m.max = 9
    for each stream in m.top.followedStreams
        group = createObject("roSGNode", "Group")
        group.translation = "[5," + translation.ToStr() + "]"

        mask_group = createObject("roSGNode", "MaskGroup")
        mask_group.maskuri = "pkg:/images/profile-mask.png"
        mask_group.masksize = m.maskSize
        'mask_group.maskOffset = "[0,0]"
        'mask_group.visible = true

        profile_image = createObject("roSGNode", "Poster")
        profile_image.uri = stream.profile_image_url
        '? "image > "; profile_image.uri
        profile_image.width = 50
        profile_image.height = 50
        profile_image.visible = true

        stream_user = createObject("roSGNode", "SimpleLabel")
        stream_user.text = stream.user_name
        stream_user.translation = "[90,0]"
        stream_user.visible = false
        stream_user.fontSize = "18"
        stream_user.fontUri = "pkg:/fonts/Inter-SemiBold.ttf"

        stream_game = createObject("roSGNode", "Label")
        stream_game.text = stream.game_id
        'stream_game.width = "175"
        stream_game.translation = "[90,20]"
        stream_game.color = "0xC26BE1FF"
        stream_game.visible = false
        'stream_game.fontSize = "12"
        game_font = createObject("roSGNode", "Font")
        'game_font.role = "font" 
        game_font.uri = "pkg:/fonts/Inter-Regular.ttf" 
        game_font.size = "14"
        stream_game.font = game_font
        'stream_game.fontUri="pkg:/fonts/Roobert-Regular.ttf"

        stream_viewers = createObject("roSGNode", "SimpleLabel")
        stream_viewers.text = stream.live_duration 'numberToText(stream.viewer_count)
        stream_viewers.translation = "[303,10]"
        stream_viewers.visible = false
        stream_viewers.fontSize = "12"
        stream_viewers.fontUri="pkg:/fonts/Inter-Regular.ttf"

        red_rectangle = createObject("roSGNode", "Poster")
        red_rectangle.uri = "pkg:/images/red_rectangle.9.png"
        red_rectangle.width = stream_viewers.localBoundingRect().width + 23
        red_rectangle.height = 28 'stream_viewers.localBoundingRect().height + 5
        red_rectangle.translation = "[285,5]"
        red_rectangle.visible = false

        login_name = createObject("roSGNode", "SimpleLabel")
        login_name.text = stream.login
        login_name.visible = false

        live = createObject("roSGNode", "Poster")
        live.uri = "pkg:/images/live.png"
        live.width = 8
        live.height = 8
        live.translation = "[290,15]"
        live.visible = false

        purple_circle = createObject("roSGNode", "Poster")
        purple_circle.uri = "pkg:/images/purple_circle.png"
        purple_circle.width = 52
        purple_circle.height = 52
        'purple_circle.translation = "[290,15]"
        purple_circle.visible = false

        ' selected = createObject("roSGNode", "Rectangle")
        ' selected.translation = "[0,-5]"
        ' selected.height = 60
        ' selected.width = 300
        ' selected.color = "0x26262CFF"
        ' selected.visible = false

        selected = createObject("roSGNode", "Poster")
        selected.translation = "[64,-5]"
        selected.uri = "pkg:/images/barFocusIndicator.9.png"
        selected.height = 50
        '? "WIDTHS: " stream_user.localBoundingRect().width " " stream_game.localBoundingRect().width
        if stream_user.localBoundingRect().width >= stream_game.localBoundingRect().width
            selected.width = stream_user.localBoundingRect().width + 36
        else
            selected.width = stream_game.localBoundingRect().width + 36
        end if
        'selected.width = 300
        selected.visible = false

        mask_group.appendChild(profile_image)
        
        group.appendChild(selected)
        group.appendChild(mask_group)
        group.appendChild(stream_user)
        group.appendChild(stream_game)
        group.appendChild(red_rectangle)
        group.appendChild(stream_viewers)
        group.appendChild(live)
        group.appendChild(login_name)
        group.appendChild(purple_circle)

        m.top.appendChild(group)

        translation += 60
    end for
    'm.children = m.top.getChildren(-1, 1)
    m.children = []
    for child = 2 to m.top.getChildCount() - 1
        m.children.push(m.top.getChild(child))
    end for
end sub

sub onGetFocus()
    if m.top.focused = true
        ' for each stream in m.children
        '     stream.getChild(2).visible = true
        '     stream.getChild(3).visible = true
        '     stream.getChild(4).visible = true
        '     stream.getChild(5).visible = true
        '     'stream.getChild(7).visible = true
        ' end for
        if m.children[m.currentIndex] <> invalid
            m.children[m.currentIndex].getChild(0).visible = true
            m.children[m.currentIndex].getChild(2).visible = true
            m.children[m.currentIndex].getChild(3).visible = true
            'm.children[m.currentIndex].getChild(4).visible = true
            'm.children[m.currentIndex].getChild(5).visible = true
            'm.children[m.currentIndex].getChild(6).visible = true
            m.children[m.currentIndex].getChild(8).visible = true
        end if
    else if m.top.focused = false
        ' for each stream in m.children
        '     stream.getChild(2).visible = false
        '     stream.getChild(3).visible = false
        '     stream.getChild(4).visible = false
        '     stream.getChild(5).visible = false
        '     'stream.getChild(7).visible = false
        ' end for
        if m.children[m.currentIndex] <> invalid
            m.children[m.currentIndex].getChild(0).visible = false
            m.children[m.currentIndex].getChild(2).visible = false
            m.children[m.currentIndex].getChild(3).visible = false
            'm.children[m.currentIndex].getChild(4).visible = false
            'm.children[m.currentIndex].getChild(5).visible = false
            'm.children[m.currentIndex].getChild(6).visible = false
            m.children[m.currentIndex].getChild(8).visible = false
        end if
    end if
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
    if press
        if key = "up"
            if m.currentIndex - 1 >= 0
                m.children[m.currentIndex].getChild(0).visible = false
                m.children[m.currentIndex].getChild(2).visible = false
                m.children[m.currentIndex].getChild(3).visible = false
                'm.children[m.currentIndex].getChild(4).visible = false
                'm.children[m.currentIndex].getChild(5).visible = false
                'm.children[m.currentIndex].getChild(6).visible = false
                m.children[m.currentIndex].getChild(8).visible = false
                m.currentIndex -= 1
                if m.currentIndex < m.min
                    for each stream in m.children
                        stream.translation = "[5," + (stream.translation[1] + 60).ToStr() + "]"
                        if stream.translation[1] > 0
                            stream.visible = true
                        end if
                    end for
                    m.min -= 1
                    m.max -= 1
                end if
                m.children[m.currentIndex].getChild(0).visible = true
                m.children[m.currentIndex].getChild(2).visible = true
                m.children[m.currentIndex].getChild(3).visible = true
                'm.children[m.currentIndex].getChild(4).visible = true
                'm.children[m.currentIndex].getChild(5).visible = true
                'm.children[m.currentIndex].getChild(6).visible = true
                m.children[m.currentIndex].getChild(8).visible = true
            end if
        else if key = "down"
            if m.currentIndex + 1 < m.top.getChildCount() - 1
                m.children[m.currentIndex].getChild(0).visible = false
                m.children[m.currentIndex].getChild(2).visible = false
                m.children[m.currentIndex].getChild(3).visible = false
                'm.children[m.currentIndex].getChild(4).visible = false
                'm.children[m.currentIndex].getChild(5).visible = false
                'm.children[m.currentIndex].getChild(6).visible = false
                m.children[m.currentIndex].getChild(8).visible = false
                if m.children[m.currentIndex + 1] <> invalid
                    m.currentIndex += 1
                end if
                if m.currentIndex > m.max
                    for each stream in m.children
                        stream.translation = "[5," + (stream.translation[1] - 60).ToStr() + "]"
                        if stream.translation[1] <= 0
                            stream.visible = false
                        end if
                    end for
                    m.min += 1
                    m.max += 1
                end if
                m.children[m.currentIndex].getChild(0).visible = true
                m.children[m.currentIndex].getChild(2).visible = true
                m.children[m.currentIndex].getChild(3).visible = true
                'm.children[m.currentIndex].getChild(4).visible = true
                'm.children[m.currentIndex].getChild(5).visible = true
                'm.children[m.currentIndex].getChild(6).visible = true
                m.children[m.currentIndex].getChild(8).visible = true
            end if
        else if key = "OK"
            if m.children[m.currentIndex] <> invalid
                '? "selected > ";m.children[m.currentIndex].getChild(5)
                m.top.streamerSelected = m.children[m.currentIndex].getChild(7).text
            end if
        end if
    end if
    return handled
end sub