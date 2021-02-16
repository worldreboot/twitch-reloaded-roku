sub init()
    m.top.focusable = true

    deviceInfo = CreateObject("roDeviceInfo")
    uiResolutionWidth = deviceInfo.GetUIResolution().width
    
    m.children = []
    m.currentlyFocused = 0
    m.total_channels = 0

    if uiResolutionWidth = 1920
        m.maskSize = [250, 250]
    else
        m.maskSize = [150, 150]
    end if
end sub

sub onOfflineChannelsChange()
    x_translation = 0
    y_translation = 0
    m.currentlyFocused = 0
    m.total_channels = 0
    channels_added_to_row = 0
    m.top.removeChildren(m.children)
    for each channel in m.top.offlineChannels
        group = createObject("roSGNode", "Group")
        group.translation = [x_translation, y_translation]

        mask_group = createObject("roSGNode", "MaskGroup")
        mask_group.maskuri = "pkg:/images/profile-mask-150.png"
        mask_group.opacity = 0.5
        mask_group.masksize = m.maskSize

        profile_image = createObject("roSGNode", "Poster")
        profile_image.uri = channel.profile_image_url
        '? "OfflineChannelList > image > "; profile_image.uri
        profile_image.width = 150
        profile_image.height = 150
        profile_image.visible = true

        stream_user = createObject("roSGNode", "SimpleLabel")
        stream_user.text = channel.display_name
        '? "OfflineChannelList > stream_user > "; stream_user.text
        stream_user.translation = "[5,5]"
        stream_user.visible = false
        stream_user.fontSize = "18"
        stream_user.fontUri = "pkg:/fonts/Inter-SemiBold.ttf"

        ' indicator = createObject("roSGNode", "Poster")
        ' indicator.uri = "pkg:/images/verticalFocusIndicator.9.png"
        ' indicator.appendChild(stream_user)
        ' '? "image > "; profile_image.uri
        ' width = stream_user.localBoundingRect().width + 10
        ' indicator.width = width
        ' indicator.height = stream_user.localBoundingRect().height + 10
        ' if (width / 2) > 75
        '     indicator.translation = [-(width / 2 - 75),160]
        ' else
        '     indicator.translation = [75 - width / 2,160]
        ' end if
        ' indicator.visible = false

        login = createObject("roSGNode", "SimpleLabel")
        login.text = channel.login
        login.visible = false

        mask_group.appendChild(profile_image)

        group.appendChild(mask_group)
        group.appendChild(stream_user)
        group.appendChild(login)

        m.top.appendChild(group)

        channels_added_to_row += 1
        m.total_channels += 1

        if channels_added_to_row = 7
            x_translation = 0
            y_translation += 170
            channels_added_to_row = 0
        else
            x_translation += 170
        end if

    end for

    m.indicator = createObject("roSGNode", "Group")
    m.indicator.visible = false

    circle = createObject("roSGNode", "Poster")
    circle.uri = "pkg:/images/offlineChannelIndicator.png"
    circle.translation = [0, -165]
    circle.visible = false

    nameBox = createObject("roSGNode", "Poster")
    nameBox.uri = "pkg:/images/verticalFocusIndicator.9.png"
    nameBox.visible = true

    stream_user = createObject("roSGNode", "SimpleLabel")
    stream_user.translation = "[5,7]"
    stream_user.visible = true
    stream_user.fontSize = "18"
    stream_user.fontUri = "pkg:/fonts/Inter-SemiBold.ttf"

    nameBox.appendChild(stream_user)
    m.indicator.appendChild(circle)
    m.indicator.appendChild(nameBox)

    m.top.appendChild(m.indicator)
    
    m.children = m.top.getChildren(-1, 0)
end sub

function onKeyEvent(key, press) as Boolean
    handled = false
    if press 'and m.currentlyFocused <= m.total_channels
        'm.children[m.currentlyFocused].getChild(0).opacity = 0.5
        'm.children[m.currentlyFocused].getChild(1).visible = false
        'm.indicator.getChild(0).text = m.children[m.currentlyFocused].getChild(1).text
        'm.indicator.visible = false
        if key = "right" and m.currentlyFocused MOD 7 < 6 and m.currentlyFocused < m.total_channels - 1
            m.children[m.currentlyFocused].getChild(0).opacity = 0.5
            m.indicator.visible = false
            ? m.currentlyFocused " " m.total_channels
            m.currentlyFocused += 1
            handled = true
        else if key = "left" and m.currentlyFocused MOD 7 > 0
            m.children[m.currentlyFocused].getChild(0).opacity = 0.5
            m.indicator.visible = false
            ? m.currentlyFocused " " m.total_channels
            m.currentlyFocused -= 1
            handled = true
        else if key = "left"
            m.children[m.currentlyFocused].getChild(0).opacity = 0.5
            m.indicator.visible = false
        else if key = "up" and m.currentlyFocused > 6
            m.children[m.currentlyFocused].getChild(0).opacity = 0.5
            m.indicator.visible = false
            for each channel in m.children
                channel.translation = [channel.translation[0], channel.translation[1] + 170]
                if channel.translation[1] >= 0
                    channel.visible = true
                end if
            end for
            m.currentlyFocused -= 7
            handled = true
        else if key = "up"
            m.children[m.currentlyFocused].getChild(0).opacity = 0.5
            m.indicator.visible = false
        else if key = "down" and m.currentlyFocused + 7 <= m.total_channels - 1
            m.children[m.currentlyFocused].getChild(0).opacity = 0.5
            m.indicator.visible = false
            for each channel in m.children
                channel.translation = [channel.translation[0], channel.translation[1] - 170]
                if channel.translation[1] < 0
                    channel.visible = false
                end if
            end for
            m.currentlyFocused += 7
            handled = true
        else if key = "OK"
            m.children[m.currentlyFocused].getChild(0).opacity = 0.5
            m.indicator.visible = false
            m.top.channelSelected = m.children[m.currentlyFocused].getChild(2).text
            handled = true
        end if

        if handled 'and m.currentlyFocused <= m.total_channels
            m.children[m.currentlyFocused].getChild(0).opacity = 1
            'm.children[m.currentlyFocused].getChild(1).visible = true
            'm.indicator.getChild(0).text = m.children[m.currentlyFocused].getChild(1).text

            stream_user = m.children[m.currentlyFocused].getChild(1)
            m.indicator.getChild(1).getChild(0).text = stream_user.text

            width = stream_user.localBoundingRect().width + 10

            m.indicator.getChild(1).width = width
            m.indicator.getChild(1).height = stream_user.localBoundingRect().height + 10
            '? "circle translation: " m.indicator.getChild(0).translation
            '? "channel translation: " m.children[m.currentlyFocused].translation
            if (width / 2) > 75
                m.indicator.translation = [m.children[m.currentlyFocused].translation[0] + -(width / 2 - 75), m.children[m.currentlyFocused].translation[1] + 160]
                m.indicator.getChild(0).translation = [width / 2 - 75 - 5, -165]
            else
                m.indicator.translation = [m.children[m.currentlyFocused].translation[0] + 75 - width / 2, m.children[m.currentlyFocused].translation[1] + 160]
                m.indicator.getChild(0).translation = [-(75 - width / 2) - 5, -165]
            end if

            '? "m.indicator " m.indicator.getChild(1)

            m.indicator.visible = true
        end if
    else
        if key = "down" 'and m.currentlyFocused <= m.total_channels
            m.children[m.currentlyFocused].getChild(0).opacity = 1
            'm.children[m.currentlyFocused].getChild(1).visible = true
            'm.indicator.getChild(0).text = m.children[m.currentlyFocused].getChild(1).text

            stream_user = m.children[m.currentlyFocused].getChild(1)
            m.indicator.getChild(1).getChild(0).text = stream_user.text

            width = stream_user.localBoundingRect().width + 10

            m.indicator.getChild(1).width = width
            m.indicator.getChild(1).height = stream_user.localBoundingRect().height + 10
            if (width / 2) > 75
                m.indicator.translation = [m.children[m.currentlyFocused].translation[0] + -(width / 2 - 75), m.children[m.currentlyFocused].translation[1] + 160]
                m.indicator.getChild(0).translation = [width / 2 - 75 - 5, -165]
            else
                m.indicator.translation = [m.children[m.currentlyFocused].translation[0] + 75 - width / 2, m.children[m.currentlyFocused].translation[1] + 160]
                m.indicator.getChild(0).translation = [-(75 - width / 2) - 5, -165]
            end if

            m.indicator.visible = true
        end if
    end if
    return handled
end function