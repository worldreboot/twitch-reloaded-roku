function init()
    m.progressBar = m.top.findNode("progressBar")
    m.progressBar.visible = false
    m.progressBarBase = m.top.findNode("progressBarBase")
    m.progressBarProgress = m.top.findNode("progressBarProgress")
    m.progressDot = m.top.findNode("progressDot")
    m.timeProgress = m.top.findNode("timeProgress")
    m.timeDuration = m.top.findNode("timeDuration")
    'm.controlSelectRect = m.top.findNode("controlSelectRect")
    m.controlButton = m.top.findNode("controlButton")
    m.timeTravelButton = m.top.findNode("timeTravelButton")
    m.messagesButton = m.top.findNode("messagesButton")
    m.glow = m.top.findNode("bg-glow")
    'm.backButton = m.top.findNode("backButton")
    m.timeTravelRect = m.top.findNode("timeTravelRect")
    m.top.observeField("position", "onVideoPositionChange")
    m.currentProgressBarState = 0
    m.currentPositionSeconds = 0
    m.currentPositionUpdated = false
    m.thumbnails = m.top.findNode("thumbnails")
    m.thumbnailImage = m.top.findNode("thumbnailImage")
    m.arrows = m.top.findNode("arrows")

    m.videoTitle = m.top.findNode("videoTitle")
    m.channelUsername = m.top.findNode("channelUsername")
    m.avatar = m.top.findNode("avatar")

    hour0 = m.top.findNode("hour0")
    hour1 = m.top.findNode("hour1")
    minute0 = m.top.findNode("minute0")
    minute1 = m.top.findNode("minute1")
    second0 = m.top.findNode("second0")
    second1 = m.top.findNode("second1")

    m.focusedTimeSlot = 0
    m.timeTravelTimeSlot = [ hour0, hour1, minute0, minute1, second0, second1 ]

    cancelButton = m.top.findNode("cancelButton")
    acceptButton = m.top.findNode("acceptButton")

    m.focusedTimeButton = 0
    m.timeTravelButtons = [ cancelButton, acceptButton ]

    m.progressBarFocused = false

    m.loadingIndicator = m.top.findNode("loadingIndicator")
    m.top.observeField("state", "onvideoStateChange")
    m.top.observeField("channelAvatar", "onChannelAvatarChange")
    m.top.observeField("chatIsVisible", "onChatVisibilityChange")

    m.uiResolutionWidth = createObject("roDeviceInfo").GetUIResolution().width
    if m.uiResolutionWidth = 1920
        m.thumbnails.clippingRect = [0, 0, 146.66, 82.66]
    end if

    deviceInfo = CreateObject("roDeviceInfo")
    uiResolutionWidth = deviceInfo.GetUIResolution().width

    if uiResolutionWidth = 1920
        m.top.findNode("profileImageMask").maskSize = [75, 75]
    end if

    m.sec = createObject("roRegistrySection", "VideoSettings")

    m.buttonHoldTimer = createObject("roSGNode", "Timer")
    m.buttonHoldTimer.observeField("fire", "onButtonHold")
    m.buttonHoldTimer.repeat = true
    m.buttonHoldTimer.duration = "0.070"
    m.buttonHoldTimer.control = "stop"

    m.buttonHeld = invalid
    m.scrollInterval = 10
end function

sub onChatVisibilityChange()
    if m.top.chatIsVisible
        m.progressBarBase.width = 816
        'm.progressBarProgress.width = 810
        m.glow.translation = [534, 32]
        m.timeTravelButton.translation = [390, 51]
        m.controlButton.translation = [476, 53]
        m.messagesButton.translation = [552, 52]
        m.timeDuration.translation = [814, 61]
    else
        m.progressBarBase.width = 1200
        'm.progressBarProgress.width = 1200
        m.glow.translation = [692, 32]
        m.timeTravelButton.translation = [548, 51]
        m.controlButton.translation = [634, 53]
        m.messagesButton.translation = [710, 52]
        m.timeDuration.translation = [1198, 61]
    end if
end sub

sub onVideoStateChange()
    if m.top.state = "buffering"
        m.loadingIndicator.control = "start"
    else
        m.loadingIndicator.control = "stop"
    end if
end sub

sub onButtonHold()
    if m.buttonHeld <> invalid and m.top.thumbnailInfo <> invalid
        if m.buttonHeld = "right"
            m.currentPositionSeconds += m.scrollInterval
            m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
            m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
            if m.currentPositionSeconds > m.top.duration
                m.currentPositionSeconds = m.top.duration
            end if
            if m.top.thumbnailInfo.width <> invalid
                if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                    if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                        m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                    else
                        m.thumbnails.translation = [0, -150]
                    end if
                else
                    m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                end if
            end if
        else if m.buttonHeld = "left"
            m.currentPositionSeconds -= m.scrollInterval
            m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
            m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
            if m.currentPositionSeconds < 0
                m.currentPositionSeconds = 0
            end if
            if m.top.thumbnailInfo.width <> invalid
                if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                    if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                        m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                    else
                        m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                    end if
                else
                    m.thumbnails.translation = [0, -150]
                end if
            end if
        end if

        m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
        m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
        if m.top.thumbnailInfo.width <> invalid
            showThumbnail()
        end if         
        m.scrollInterval += 10
    end if
end sub

function convertToReadableTimeFormat(time) as String
    time = Int(time) '+ m.top.streamDurationSeconds
    if time < 3600
        seconds = Int((time MOD 60))
        if seconds < 10
            seconds = "0" + Int((time MOD 60)).ToStr()
        else
            seconds = seconds.ToStr() 
        end if
        return Int((time / 60)).ToStr() + ":" + seconds
    else
        hours = Int(time / 3600)
        minutes = Int((time MOD 3600) / 60)
        seconds = Int((time MOD 3600) MOD 60)
        if seconds < 10
            seconds = "0" + seconds.ToStr()
        else
            seconds = seconds.ToStr()
        end if
        if minutes < 10
            minutes = "0" + minutes.ToStr()
        else
            minutes = minutes.ToStr()
        end if
        return hours.ToStr() + ":" + minutes + ":" + seconds
    end if
end function

sub onVideoPositionChange()
    if m.top.duration > 0
        m.progressBarProgress.width = m.progressBarBase.width * (m.top.position / m.top.duration)
        m.progressDot.translation = [m.progressBarBase.width * (m.top.position / m.top.duration) + 33, 77]
        m.timeProgress.text = convertToReadableTimeFormat(m.top.position)
        m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
    end if
end sub

sub showThumbnail()
    if m.top.thumbnailInfo <> invalid and m.top.thumbnailInfo.width <> invalid
        thumbnailsPerPart = Int(m.top.thumbnailInfo.count / m.top.thumbnailInfo.thumbnail_parts.Count())
        thumbnailPosOverall = Int(m.currentPositionSeconds / m.top.thumbnailInfo.interval)
        thumbnailPosCurrent = thumbnailPosOverall MOD thumbnailsPerPart
        thumbnailRow = Int(thumbnailPosCurrent / m.top.thumbnailInfo.cols)
        thumbnailCol = Int(thumbnailPosCurrent MOD m.top.thumbnailInfo.cols)
        if m.uiResolutionWidth = 1280
            m.thumbnailImage.translation = [-thumbnailCol * m.top.thumbnailInfo.width, -thumbnailRow * m.top.thumbnailInfo.height]
        else
            m.thumbnailImage.translation = [(-thumbnailCol * m.top.thumbnailInfo.width) * 0.66, (-thumbnailRow * m.top.thumbnailInfo.height) * 0.66]
        end if
        '? thumbnailPosOverall " " thumbnailPosCurrent
        '? m.currentPositionSeconds " " m.top.thumbnailInfo.interval " " m.top.thumbnailInfo.cols " " m.top.thumbnailInfo.width " " m.top.thumbnailInfo.height
        if m.top.thumbnailInfo.info_url <> invalid and m.top.thumbnailInfo.thumbnail_parts[Int(thumbnailPosOverall / thumbnailsPerPart)] <> invalid 
            m.thumbnailImage.uri = m.top.thumbnailInfo.info_url + m.top.thumbnailInfo.thumbnail_parts[Int(thumbnailPosOverall / thumbnailsPerPart)]
        end if
        m.thumbnailImage.visible = true
    end if
end sub

function saveVideoBookmark() as Void
    if m.top.duration >= 900
        videoBookmarks = "{"
        
        tempBookmarks = m.top.videoBookmarks
        if m.top.thumbnailInfo <> invalid and m.top.thumbnailInfo.video_id <> invalid
            bookmarkAlreadyExists = tempBookmarks.DoesExist(m.top.thumbnailInfo.video_id)
            tempBookmarks[m.top.thumbnailInfo.video_id] = Int(m.top.position).ToStr()
        else
            bookmarkAlreadyExists = false
        end if

        if tempBookmarks.Count() < 100
            first = true
            for each item in tempBookmarks.Items()
                if not first
                    videoBookmarks += ","
                end if
                videoBookmarks += chr(34) + item.key + chr(34) + " : " + chr(34) + item.value + chr(34)
                first = false
            end for
        else
            skip = true
            first = true
            for each item in tempBookmarks.Items()
                if not skip
                    if not first
                        videoBookmarks += ","
                    end if
                    videoBookmarks += chr(34) + item.key + chr(34) + " : " + chr(34) + item.value + chr(34)
                    first = false
                end if
                skip = false
            end for
        end if
        
        if m.top.thumbnailInfo <> invalid and bookmarkAlreadyExists = false
            videoBookmarks += "," + chr(34) + m.top.thumbnailInfo.video_id.ToStr() + chr(34) + " : " + chr(34) + Int(m.top.position).ToStr() + chr(34) + "}"
        else
            videoBookmarks += "}"
        end if

        m.top.videoBookmarks = tempBookmarks

        ? "CustomVideo >> videoBookmarks > " videoBookmarks

        'sec = createObject("roRegistrySection", "VideoSettings")
        m.sec.Write("VideoBookmarks", videoBookmarks)
        m.sec.Flush()
    end if
end function

function getTimeTravelTime()
    hour0 = Int(Val(m.timeTravelTimeSlot[0].getChild(0).text)) * 36000
    hour1 = Int(Val(m.timeTravelTimeSlot[1].getChild(0).text)) * 3600
    minute0 = Int(Val(m.timeTravelTimeSlot[2].getChild(0).text)) * 600
    minute1 = Int(Val(m.timeTravelTimeSlot[3].getChild(0).text)) * 60
    second0 = Int(Val(m.timeTravelTimeSlot[4].getChild(0).text)) * 10
    second1 = Int(Val(m.timeTravelTimeSlot[5].getChild(0).text))
    return hour0 + hour1 + minute0 + minute1 + second0 + second1
end function

sub onChannelAvatarChange()
    m.videoTitle.text = m.top.videoTitle
    m.channelUsername.text = m.top.channelUsername
    m.avatar.uri = m.top.channelAvatar
end sub

function onKeyEvent(key, press) as Boolean
    handled = false
    if press
        if key = "up"
            if m.currentProgressBarState = 0
                m.currentProgressBarState = 1
                m.progressBar.visible = true
                w = m.controlButton.width
                h = m.controlButton.height
                m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
                m.controlButton.blendColor = "0xBD00FFFF"
                'm.controlSelectRect.visible = true
            else if m.currentProgressBarState = 1
                ' m.currentProgressBarState = 5
                ' m.progressBarBase.height = 2
                ' m.progressBarProgress.height = 2
                ' m.controlButton.blendColor = "0xFFFFFFFF"
                ' m.backButton.blendColor = "0xBD00FFFF"
                ' 'm.controlSelectRect.visible = false
                ' m.thumbnailImage.visible = true
            else if m.currentProgressBarState = 2
                m.currentProgressBarState = 0
                m.progressBarBase.height = 2
                m.progressBarProgress.height = 2
                m.progressBar.visible = false
                m.thumbnailImage.visible = false
            else if m.currentProgressBarState = 3
                ' m.currentProgressBarState = 4
                ' m.timeTravelButton.blendColor = "0xFFFFFFFF"
                ' m.messagesButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 6
                number = (Int(Val(m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).text)) + 1)
                if m.focusedTimeSlot = 2 or m.focusedTimeSlot = 4
                    number = number Mod 6
                else
                    number = number Mod 10
                end if
                m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).text = number.ToStr()
            end if
            return true
        else if key = "right"
            if m.currentProgressBarState = 1
                m.currentProgressBarState = 4
                m.controlButton.blendColor = "0xFFFFFFFF"
                w = m.messagesButton.width
                h = m.messagesButton.height
                m.glow.translation = [m.messagesButton.translation[0] - 30 + w / 2, m.messagesButton.translation[1] - 30 + h / 2]
                m.messagesButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 2
                
            else if m.currentProgressBarState = 3
                m.currentProgressBarState = 1
                m.timeTravelButton.blendColor = "0xFFFFFFFF"
                w = m.controlButton.width
                h = m.controlButton.height
                m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
                m.controlButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 6
                if m.focusedTimeSlot <> -1 and m.focusedTimeSlot + 1 <= 5
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].uri = "pkg:/images/unfocusedTimeSlot.png"
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).color = "0x3F3F3FFF"
                    m.focusedTimeSlot += 1
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].uri = "pkg:/images/focusedTimeSlot.png"
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).color = "0xDC79FFFF"
                    m.arrows.translation = [m.timeTravelTimeSlot[ m.focusedTimeSlot ].translation[0] + 18, m.timeTravelTimeSlot[ m.focusedTimeSlot ].translation[1] - 6]
                else if m.focusedTimeSlot = -1
                    m.timeTravelButtons[ m.focusedTimeButton ].opacity = 0.5
                    m.focusedTimeButton += 1
                    m.focusedTimeButton = m.focusedTimeButton Mod 2
                    m.timeTravelButtons[ m.focusedTimeButton ].opacity = 1
                end if
            else if m.currentProgressBarState = 2
                if m.currentPositionUpdated = false
                    m.currentPositionSeconds = m.top.position
                    m.currentPositionUpdated = true
                    m.top.control = "pause"
                    m.controlButton.uri = "pkg:/images/play.png"
                end if
                m.currentPositionSeconds += 10
                if m.currentPositionSeconds > m.top.duration
                    m.currentPositionSeconds = m.top.duration
                end if
                m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
                m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
                if m.top.thumbnailInfo <> invalid and m.top.thumbnailInfo.width <> invalid
                    if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                        if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                            m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                        else
                            m.thumbnails.translation = [0, -150]
                        end if
                    else
                        m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                    end if

                    m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
                    m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
                    if m.top.thumbnailInfo.width <> invalid
                        showThumbnail()
                    end if
                end if
                m.buttonHeld = "right"
                m.buttonHoldTimer.control = "start"
            end if
            return true
        else if key = "left"
            if m.currentProgressBarState = 2
               
            else if m.currentProgressBarState = 4
                m.currentProgressBarState = 1
                m.messagesButton.blendColor = "0xFFFFFFFF"
                w = m.controlButton.width
                h = m.controlButton.height
                m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
                m.controlButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 1
                m.currentProgressBarState = 3
                m.controlButton.blendColor = "0xFFFFFFFF"
                w = m.timeTravelButton.width
                h = m.timeTravelButton.height
                m.glow.translation = [m.timeTravelButton.translation[0] - 30 + w / 2, m.timeTravelButton.translation[1] - 30 + h / 2]
                m.timeTravelButton.blendColor = "0xBD00FFFF"
            else if m.currentProgressBarState = 6
                if m.focusedTimeSlot <> -1 and m.focusedTimeSlot - 1 >= 0
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].uri = "pkg:/images/unfocusedTimeSlot.png"
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).color = "0x3F3F3FFF"
                    m.focusedTimeSlot -= 1
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].uri = "pkg:/images/focusedTimeSlot.png"
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).color = "0xDC79FFFF"
                    m.arrows.translation = [m.timeTravelTimeSlot[ m.focusedTimeSlot ].translation[0] + 18, m.timeTravelTimeSlot[ m.focusedTimeSlot ].translation[1] - 6]
                else if m.focusedTimeSlot = -1
                    m.timeTravelButtons[ m.focusedTimeButton ].opacity = 0.5
                    m.focusedTimeButton -= 1
                    if m.focusedTimeButton = -1
                        m.focusedTimeButton = 1
                    end if
                    m.timeTravelButtons[ m.focusedTimeButton ].opacity = 1
                end if
            end if
            return true
        else if key = "down"
            if m.currentProgressBarState = 6
                number = (Int(Val(m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).text)) - 1)
                if number = -1
                    if m.focusedTimeSlot = 2 or m.focusedTimeSlot = 4
                        number = 5
                    else
                        number = 9
                    end if
                end if
                m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).text = number.ToStr()
            else
                m.controlButton.blendColor = "0xFFFFFFFF"
                m.messagesButton.blendColor = "0xFFFFFFFF"
                m.timeTravelButton.blendColor = "0xFFFFFFFF"
                m.currentProgressBarState = 0
                m.thumbnailImage.visible = false
                m.progressBar.visible = false
                return true
            end if
        else if key = "back"
            if m.timeTravelRect.visible
                m.timeTravelRect.visible = false
                m.currentProgressBarState = 3
                handled = true
            else
                m.currentPositionSeconds = 0
                m.currentProgressBarState = 0
                m.timeTravelRect.visible = false
                m.progressBar.visible = false
                'm.controlSelectRect.visible = false
                m.currentPositionUpdated = false
                m.thumbnailImage.uri = ""
                saveVideoBookmark()
                m.top.thumbnailInfo = invalid
            end if
        else if key = "OK"
            ? "CustomVideo >> OK"
            if m.currentProgressBarState = 1
                if m.top.state = "paused"
                    m.top.control = "resume"
                    m.controlButton.uri = "pkg:/images/pause.png"
                    m.currentPositionUpdated = false
                else
                    m.top.control = "pause"
                    m.controlButton.uri = "pkg:/images/play.png"
                end if
                return true
            else if m.currentProgressBarState = 2
                m.top.seek = m.currentPositionSeconds
                m.controlButton.uri = "pkg:/images/pause.png"
                m.currentPositionUpdated = false
                m.currentProgressBarState = 1
                'm.progressBarFocused = not m.progressBarFocused
                return true
            else if m.currentProgressBarState = 3
                m.currentProgressBarState = 6
                m.focusedTimeSlot = 0
                m.timeTravelTimeSlot[ m.focusedTimeSlot ].uri = "pkg:/images/focusedTimeSlot.png"
                m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).color = "0xDC79FFFF"
                m.arrows.translation = [m.timeTravelTimeSlot[ m.focusedTimeSlot ].translation[0] + 18, m.timeTravelTimeSlot[ m.focusedTimeSlot ].translation[1] - 6]
                m.timeTravelRect.visible = true
                return true
            else if m.currentProgressBarState = 4
                m.top.toggleChat = true
                return true
            else if m.currentProgressBarState = 5
                m.currentPositionSeconds = 0
                m.currentProgressBarState = 0
                m.progressBar.visible = false
                'm.controlSelectRect.visible = false
                m.currentPositionUpdated = false
                m.thumbnailImage.uri = ""
                saveVideoBookmark()
                m.top.thumbnailInfo = invalid
                'm.backButton.blendColor = "0xFFFFFFFF"
                m.top.back = true
                return true
            else if m.currentProgressBarState = 6
                if m.focusedTimeSlot <> -1
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].uri = "pkg:/images/unfocusedTimeSlot.png"
                    m.timeTravelTimeSlot[ m.focusedTimeSlot ].getChild(0).color = "0x3F3F3FFF"
                    m.timeTravelButtons[ m.focusedTimeButton ].opacity = 1
                    m.focusedTimeSlot = -1
                else
                    if m.focusedTimeButton = 1
                        m.top.seek = getTimeTravelTime()
                        m.controlButton.uri = "pkg:/images/pause.png"
                        m.currentPositionUpdated = false
                    end if
                    for timeSlot = 0 to 5
                        m.timeTravelTimeSlot[ timeSlot ].getChild(0).text = "0"
                    end for 
                    m.timeTravelButtons[ m.focusedTimeButton ].opacity = 0.5
                    m.currentProgressBarState = 3
                    m.timeTravelRect.visible = false
                end if
                return true
            end if
            'return true
        else if key = "fastforward"
            m.progressBar.visible = true
            w = m.controlButton.width
            h = m.controlButton.height
            m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
            m.controlButton.blendColor = "0xBD00FFFF"
            m.currentProgressBarState = 2
            if m.currentPositionUpdated = false
                m.currentPositionSeconds = m.top.position
                m.currentPositionUpdated = true
                m.top.control = "pause"
                m.controlButton.uri = "pkg:/images/play.png"
            end if
            m.currentPositionSeconds += 10
            if m.currentPositionSeconds > m.top.duration
                m.currentPositionSeconds = m.top.duration
            end if
            m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
            m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
            if m.top.thumbnailInfo <> invalid and m.top.thumbnailInfo.width <> invalid
                if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                    if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                        m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                    else
                        m.thumbnails.translation = [0, -150]
                    end if
                else
                    m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                end if

                m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
                m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
                if m.top.thumbnailInfo.width <> invalid
                    showThumbnail()
                end if
            end if
            m.buttonHeld = "right"
            m.buttonHoldTimer.control = "start"
        else if key = "rewind"
            m.progressBar.visible = true
            w = m.controlButton.width
            h = m.controlButton.height
            m.glow.translation = [m.controlButton.translation[0] - 30 + w / 2, m.controlButton.translation[1] - 30 + h / 2]
            m.controlButton.blendColor = "0xBD00FFFF"
            m.currentProgressBarState = 2
            if m.currentPositionUpdated = false
                m.currentPositionSeconds = m.top.position
                m.currentPositionUpdated = true
                m.top.control = "pause"
                m.controlButton.uri = "pkg:/images/play.png"
            end if
            m.currentPositionSeconds -= 10
            if m.currentPositionSeconds < 0
                m.currentPositionSeconds = 0
            end if
            if m.top.thumbnailInfo <> invalid and m.top.thumbnailInfo.width <> invalid
                if m.progressBarProgress.width - m.top.thumbnailInfo.width / 2 >= 0
                    if m.progressBarProgress.width + m.top.thumbnailInfo.width / 2 <= m.progressBarBase.width
                        m.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                    else
                        m.thumbnails.translation = [m.progressBarBase.width - m.top.thumbnailInfo.width, -150]
                    end if
                else
                    m.thumbnails.translation = [0, -150]
                end if

                m.progressBarProgress.width = m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration)
                m.progressDot.translation = [m.progressBarBase.width * (m.currentPositionSeconds / m.top.duration) + 33, 77]
                'm.thumbnails.translation = [m.progressBarProgress.width - m.top.thumbnailInfo.width / 2, -150]
                m.timeProgress.text = convertToReadableTimeFormat(m.currentPositionSeconds)
                m.timeDuration.text = convertToReadableTimeFormat(m.top.duration)
                if m.top.thumbnailInfo.width <> invalid
                    showThumbnail()
                end if
            end if
            m.buttonHeld = "left"
            m.buttonHoldTimer.control = "start"
        else if key = "play"
            if m.currentProgressBarState = 2
                m.top.seek = m.currentPositionSeconds
                m.controlButton.uri = "pkg:/images/pause.png"
                m.currentPositionUpdated = false
                m.currentProgressBarState = 1
                'm.progressBarFocused = not m.progressBarFocused
            else
                if m.top.state = "paused"
                    m.top.control = "resume"
                    m.controlButton.uri = "pkg:/images/pause.png"
                    m.currentPositionUpdated = false
                else
                    m.top.control = "pause"
                    m.controlButton.uri = "pkg:/images/play.png"
                end if
            end if
        end if
    else if not press
        if key = "rewind" or key = "fastforward"
            m.scrollInterval = 10
            m.buttonHeld = invalid
            m.buttonHoldTimer.control = "stop"
        end if
    end if
    return handled
end function