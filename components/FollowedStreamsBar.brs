sub init()
    m.top.focusable = true
    m.children = m.top.getChildren(-1, 0)
    m.currentIndex = 0
    m.min = 0
    m.max = 11
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
    translation = 0
    '? "we got there"
    m.top.removeChildren(m.children)
    m.currentIndex = 0
    m.min = 0
    m.max = 11
    for each stream in m.top.followedStreams
        group = createObject("roSGNode", "Group")
        group.translation = "[5," + translation.ToStr() + "]"

        mask_group = createObject("roSGNode", "MaskGroup")
        mask_group.maskuri = "pkg:/images/profile-mask.png"
        mask_group.masksize = "[50,50]"
        mask_group.maskOffset = "[0,0]"
        'mask_group.visible = true

        profile_image = createObject("roSGNode", "Poster")
        profile_image.uri = stream.profile_image_url
        '? "image > "; profile_image.uri
        profile_image.width = 50
        profile_image.height = 50
        profile_image.visible = true

        stream_user = createObject("roSGNode", "SimpleLabel")
        stream_user.text = stream.user_name
        stream_user.translation = "[60,0]"
        stream_user.visible = m.top.focused
        stream_user.fontSize = "14"
        stream_user.fontUri = "pkg:/fonts/Roobert-SemiBold.ttf"

        stream_game = createObject("roSGNode", "Label")
        stream_game.text = stream.game_id
        stream_game.width = "175"
        stream_game.translation = "[60,20]"
        stream_game.visible = m.top.focused
        'stream_game.fontSize = "12"
        game_font = createObject("roSGNode", "Font")
        'game_font.role = "font" 
        game_font.uri = "pkg:/fonts/Roobert-Regular.ttf" 
        game_font.size = "14"
        stream_game.font = game_font
        'stream_game.fontUri="pkg:/fonts/Roobert-Regular.ttf"

        stream_viewers = createObject("roSGNode", "SimpleLabel")
        stream_viewers.text = numberToText(stream.viewer_count)
        stream_viewers.translation = "[250,10]"
        stream_viewers.visible = m.top.focused
        stream_viewers.fontSize = "14"
        stream_viewers.fontUri="pkg:/fonts/Roobert-Regular.ttf"

        live = createObject("roSGNode", "Poster")
        live.uri = "pkg:/images/live.png"
        live.width = 8
        live.height = 8
        live.translation = "[240,15]"
        live.visible = m.top.focused

        selected = createObject("roSGNode", "Rectangle")
        selected.translation = "[0,-5]"
        selected.height = 60
        selected.width = 300
        selected.color = "0x26262CFF"
        selected.visible = false

        mask_group.appendChild(profile_image)
        
        group.appendChild(selected)
        group.appendChild(mask_group)
        group.appendChild(stream_user)
        group.appendChild(stream_game)
        group.appendChild(stream_viewers)
        group.appendChild(live)

        m.top.appendChild(group)

        translation += 60
    end for
    m.children = m.top.getChildren(-1, 0)
end sub

sub onGetFocus()
    if m.top.focused = true
        for each stream in m.children
            stream.getChild(2).visible = true
            stream.getChild(3).visible = true
            stream.getChild(4).visible = true
            stream.getChild(5).visible = true
        end for
        if m.children[m.currentIndex] <> invalid
            m.children[m.currentIndex].getChild(0).visible = true
        end if
    else if m.top.focused = false
        for each stream in m.children
            stream.getChild(2).visible = false
            stream.getChild(3).visible = false
            stream.getChild(4).visible = false
            stream.getChild(5).visible = false
        end for
        if m.children[m.currentIndex] <> invalid
            m.children[m.currentIndex].getChild(0).visible = false
        end if
    end if
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
    if press
        if key = "up"
            if m.currentIndex - 1 >= 0
                m.children[m.currentIndex].getChild(0).visible = false
                m.currentIndex -= 1
                if m.currentIndex < m.min
                    for each stream in m.children
                        stream.translation = "[0," + (stream.translation[1] + 60).ToStr() + "]"
                    end for
                    m.min -= 1
                    m.max -= 1
                end if
                m.children[m.currentIndex].getChild(0).visible = true
            end if
        else if key = "down"
            if m.currentIndex + 1 < m.top.getChildCount()
                m.children[m.currentIndex].getChild(0).visible = false
                m.currentIndex += 1
                if m.currentIndex > m.max
                    for each stream in m.children
                        stream.translation = "[0," + (stream.translation[1] - 60).ToStr() + "]"
                    end for
                    m.min += 1
                    m.max += 1
                end if
                m.children[m.currentIndex].getChild(0).visible = true
            end if
        else if key = "OK"
            if m.children[m.currentIndex] <> invalid
                '? "selected > ";m.children[m.currentIndex].getChild(2).text
                m.top.streamerSelected = LCase(m.children[m.currentIndex].getChild(2).text)
            end if
        end if
    end if
    return handled
end sub