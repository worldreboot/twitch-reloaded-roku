sub init()
    m.chatPanel = m.top.findNode("chatPanel")
    m.keyboard = m.top.findNode("keyboard")
    m.chatButton = m.top.findNode("chatButton")
    m.chat = CreateObject("roSGNode", "ChatTest")
    m.chat.observeField("nextComment", "onNewComment")
    m.chat.observeField("clientComment", "onNewComment")
    m.top.observeField("visible", "onInvisible")
    m.top.observeField("loggedInUsername", "setLoggedInUsername")
    m.chat.readyForNextComment = true
    m.chat.control = "run"
    m.userstate_change = false
    m.translation = 0
end sub

sub onSetKeyboardFocus()
    if m.top.setKeyboardFocus
        m.keyboard.visible = true
        m.chatButton.visible = true
        m.top.setKeyboardFocus = false
        m.keyboard.setFocus(true)
    end if
end sub

sub setLoggedInUsername()
    m.chat.loggedInUsername = m.top.loggedInUsername
end sub

sub onInvisible()
    if m.top.visible = false
        m.chat.control = "stop"
    else
        m.chat.control = "run" 
    end if
end sub

sub onVideoChange()
    if not m.top.control
        m.chat.control = "stop"
        m.top.control = true
    end if
end sub

sub onEnterChannel()
    ? "Chat >> onEnterChannel > " m.top.channel
    m.chat.channel = m.top.channel
    m.chat.control = "stop"
    m.chat.control = "run"
end sub

sub extractMessage(section) as Object
    words = section.Split(" ")
    if words[2] = "USERSTATE"
        m.userstate_change = true
    end if
    reachedActualMessage = false
    message = ""
    for i=4 to words.Count() - 1
        message += words[i] + " "
    end for
    return message
end sub

sub onNewComment()
    m.chat.readyForNextComment = false
    comment = m.chat.nextComment.Split(";")
    '? "comment: " comment
    display_name = ""
    message = ""
    color = ""
    badges = []
    emote_set = {}
    for each section in comment
        if Left(section, 9) = "user-type"
            temp = extractMessage(section)
            temp = Left(temp, Len(temp) - 3)
            message = Right(temp, Len(temp) - 1)
        else if Left(section, 12) = "display-name"
            display_name = Right(section, Len(section) - 13)
        else if Left(section, 5) = "color"
            color = Right(section, Len(section) - 7)
        else if Left(section, 6) = "badges"
            badges = Right(section, Len(section) - 7).Split(",")
        else if Left(section, 6) = "emotes"
            emotes = Right(section, Len(section) - 7).Split("/")
            for each emote in emotes
                if emote <> ""
                    temp = emote.Split(":")
                    key = temp[0]
                    value = {}
                    value.starts = []
                    for each interval in temp[1].Split(",")
                        range = interval.Split("-")
                        value.starts.Push(Val(range[0]))
                        value.length = Val(range[1]) - Val(range[0]) + 1
                    end for
                    emote_set[key] = value
                end if
            end for
        end if
    end for

    if display_name = "" or message = ""
        if m.userstate_change
            clientInfo = {}
            clientInfo.display_name = display_name
            clientInfo.color = color
            clientInfo.badges = badges
            'm.top.clientInfo.emotes = emotes
            clientInfo.emote_set = emote_set
            m.top.clientInfo = clientInfo
            m.userstate_change = false
        end if
        if m.chat.clientComment <> ""
            message = m.chat.clientComment
            display_name = m.top.clientInfo.display_name
            color = m.top.clientInfo.color
            badges = m.top.clientInfo.badges
            'emotes = m.top.clientInfo.emotes
            emote_set = m.top.clientInfo.emote_set
            m.chat.clientComment = ""
        else
            m.chat.readyForNextComment = true
            return
        end if
    end if

    group = createObject("roSGNode", "Group")
    group.visible = true
    group.translation = [5, m.translation ]

    badge_translation = 0
    for each badge in badges
        if badge <> ""
            badge_parts = badge.Split("/")
            if m.global.channelBadges.badge_sets[badge_parts[0]] <> invalid
                if m.global.channelBadges.badge_sets[badge_parts[0]].versions[badge_parts[1]] <> invalid
                    poster = createObject("roSGNode", "Poster")
                    poster.uri = m.global.channelBadges.badge_sets[badge_parts[0]].versions[badge_parts[1]].image_url_1x
                    poster.width = 18
                    poster.height = 18
                    poster.visible = true
                    poster.translation = [badge_translation,0]
                    group.appendChild(poster)
                    badge_translation += 20
                end if
            else if m.global.globalBadges.badge_sets[badge_parts[0]].versions[badge_parts[1]] <> invalid
                poster = createObject("roSGNode", "Poster")
                poster.uri = m.global.globalBadges.badge_sets[badge_parts[0]].versions[badge_parts[1]].image_url_1x
                poster.width = 18
                poster.height = 18
                poster.visible = true
                poster.translation = [badge_translation,0]
                group.appendChild(poster)
                badge_translation += 20
            end if
        end if
    end for

    username = createObject("roSGNode", "SimpleLabel")
    username.text = display_name
    if color = ""
        color = "FFFFFF"
    end if
    username.color = "0x" + color + "FF"
    username.translation = [badge_translation,0]
    username.visible = true
    username.fontSize = "14"
    username.fontUri = "pkg:/fonts/Inter-SemiBold.ttf"
    
    message_chars = message.Split(" ")

    username_width = username.localBoundingRect().width
    x_translation = badge_translation + username_width + 1
    y_translation = 0
    first_line = true
    appended_last_line = false

    message_text = createObject("roSGNode", "SimpleLabel")
    message_text.fontSize = "14"
    message_text.fontUri = "pkg:/fonts/Inter-Regular.ttf"
    message_text.visible = true
    message_text.text = ""

    colon = createObject("roSGNode", "SimpleLabel")
    colon.fontSize = "14"
    colon.fontUri = "pkg:/fonts/Inter-Regular.ttf"
    colon.color = "0xFFFFFFFF"
    colon.translation = [x_translation, y_translation]
    colon.visible = true
    colon.text = ":"

    currentWord = createObject("roSGNode", "SimpleLabel")
    currentWord.fontSize = "14"
    currentWord.fontUri = "pkg:/fonts/Inter-Regular.ttf"
    currentWord.color = "0xFFFFFFFF"
    currentWord.translation = [x_translation, y_translation]
    currentWord.visible = true
    currentWord.text = ""

    x_translation += 7
    
    word_number = 1
    char = 0
    for each word in message_chars
        appended_last_line = false
        is_emote = false

        currentWord.text = word

        width = message_text.localBoundingRect().width
        currentWordWidth = currentWord.localBoundingRect().width

        '? "Current word width ("; word; "): "; currentWordWidth; ", Total message width: "; width

        for each emote in emote_set.Items()
            for each start in emote.value.starts
                if start = char
                    message_text.translation = [ x_translation, y_translation ]
                    group.appendChild(message_text)

                    message_text = createObject("roSGNode", "SimpleLabel")
                    message_text.fontSize = "14"
                    message_text.fontUri = "pkg:/fonts/Inter-Regular.ttf"
                    message_text.visible = true
                    message_text.text = ""

                    x_translation += width

                    poster = createObject("roSGNode", "Poster")
                    poster.uri = "https://static-cdn.jtvnw.net/emoticons/v1/" + emote.key + "/1.0"
                    poster.visible = true
                    poster.translation = [x_translation, y_translation - 5]
                    
                    group.appendChild(poster)

                    x_translation += 35

                    if x_translation >= 230 or word_number = message_chars.Count()
                        x_translation = 0
                        y_translation += 23
                    end if

                    is_emote = true
                    appended_last_line = true
                end if
            end for
        end for

        'for each emote in m.global.globalTTVEmotes
            if m.global.globalTTVEmotes.DoesExist(word) and not is_emote
                message_text.translation = [ x_translation, y_translation ]
                group.appendChild(message_text)

                message_text = createObject("roSGNode", "SimpleLabel")
                message_text.fontSize = "14"
                message_text.fontUri = "pkg:/fonts/Inter-Regular.ttf"
                message_text.visible = true
                message_text.text = ""

                x_translation += width

                poster = createObject("roSGNode", "Poster")
                poster.uri = "https://cdn.betterttv.net/emote/" + m.global.globalTTVEmotes[word] + "/1x"
                poster.visible = true
                poster.translation = [x_translation, y_translation - 5]
                
                group.appendChild(poster)

                x_translation += 35

                if x_translation >= 230 or word_number = message_chars.Count()
                    x_translation = 0
                    y_translation += 23
                end if

                is_emote = true
                appended_last_line = true
            end if
        'end for

        if m.global.channelTTVEmotes <> invalid and not is_emote
            'for each emote in m.global.channelTTVEmotes.sharedEmotes
                if m.global.channelTTVEmotes.DoesExist(word)
                    message_text.translation = [ x_translation, y_translation ]

                    group.appendChild(message_text)

                    message_text = createObject("roSGNode", "SimpleLabel")
                    message_text.fontSize = "14"
                    message_text.fontUri = "pkg:/fonts/Inter-Regular.ttf"
                    message_text.visible = true
                    message_text.text = ""

                    x_translation += width

                    poster = createObject("roSGNode", "Poster")
                    poster.uri = "https://cdn.betterttv.net/emote/" + m.global.channelTTVEmotes[word] + "/1x"
                    poster.visible = true
                    poster.translation = [x_translation, y_translation - 5]
                    
                    group.appendChild(poster)

                    x_translation += 35

                    if x_translation >= 230 or word_number = message_chars.Count()
                        x_translation = 0
                        y_translation += 23
                    end if

                    is_emote = true
                    appended_last_line = true
                end if
            'end for
        end if

        if m.global.channelTTVFrankerEmotes <> invalid and not is_emote
            'for each emote in m.global.channelTTVFrankerEmotes
                if m.global.channelTTVFrankerEmotes.DoesExist(word)
                    message_text.translation = [ x_translation, y_translation ]

                    group.appendChild(message_text)

                    message_text = createObject("roSGNode", "SimpleLabel")
                    message_text.fontSize = "14"
                    message_text.fontUri = "pkg:/fonts/Inter-Regular.ttf"
                    message_text.visible = true
                    message_text.text = ""

                    x_translation += width

                    poster = createObject("roSGNode", "Poster")
                    poster.uri = m.global.channelTTVFrankerEmotes[word]
                    poster.visible = true
                    poster.translation = [x_translation, y_translation - 5]
                    
                    group.appendChild(poster)

                    x_translation += 35

                    if x_translation >= 230 or word_number = message_chars.Count()
                        x_translation = 0
                        y_translation += 23
                    end if

                    is_emote = true
                    appended_last_line = true
                end if
            'end for
        end if

        if not is_emote
            if (x_translation + currentWordWidth + width) < 230
                temp = message_text.text
                temp2 = word + " "
                temp.AppendString(temp2, Len(temp2))
                message_text.text = temp
                'appended_last_line = false
            else if (x_translation + currentWordWidth + width) >= 230
                if currentWordWidth >= 230
                    currentWordChars = word.Split("")
                    for each character in currentWordChars
                        width = message_text.localBoundingRect().width
                        appended_last_line = false
                        if width >= 230
                            message_text.translation = [ x_translation, y_translation ]
                            group.appendChild(message_text)

                            appended_last_line = true
                            
                            message_text = createObject("roSGNode", "SimpleLabel")
                            message_text.fontSize = "14"
                            message_text.fontUri = "pkg:/fonts/Inter-Regular.ttf"
                            message_text.visible = true
                            message_text.text = ""

                            x_translation = 0
                            y_translation += 23
                        end if
                        message_text.text += character
                    end for
                else
                    message_text.translation = [ x_translation, y_translation ]
                    group.appendChild(message_text)
                    
                    message_text = createObject("roSGNode", "SimpleLabel")
                    message_text.fontSize = "14"
                    message_text.fontUri = "pkg:/fonts/Inter-Regular.ttf"
                    message_text.visible = true
                    message_text.text = word

                    appended_last_line = false

                    x_translation = 0
                    y_translation += 23
                end if
                message_text.text += " "
            else
                ' message_text.translation = [ x_translation, y_translation ]
                ' group.appendChild(message_text)
                
                ' message_text = createObject("roSGNode", "SimpleLabel")
                ' message_text.fontSize = "14"
                ' message_text.fontUri = "pkg:/fonts/Inter-Regular.ttf"
                ' message_text.visible = true
                ' message_text.text = word + " "
                
                ' x_translation = 0
                ' y_translation += 28
                
                ' appended_last_line = true
            end if
        end if
        char += Len(word) + 1
        word_number += 1
    end for

    if not appended_last_line
        message_text.translation = [ x_translation, y_translation ]

        group.appendChild(message_text)
        
        y_translation += 32
    end if

    group.appendChild(username)
    group.appendChild(colon)

    m.chatPanel.appendChild(group)

    if m.translation + y_translation > 700
        for each chatmessage in m.chatPanel.getChildren(-1, 0)
            if chatmessage.translation[1] - y_translation < 0
                m.chatPanel.removeChild(chatmessage)
            else
                chatmessage.translation = [0, (chatmessage.translation[1] - y_translation) ]
            end if
        end for
    else
        m.translation += y_translation
    end if

    '? "";display_name;": ";message
    'm.chat.clientComment = ""
    m.chat.readyForNextComment = true
end sub

function onKeyEvent(key, press) as Boolean
    handled = false
    if press
        if key = "down" and m.keyboard.hasFocus()
            m.chatButton.color = "0xBD00FFFF"
            m.chatButton.setFocus(true)
            handled = true
        else if key = "down"
            m.chatButton.color = "0xBD00FFFF"
            m.chatButton.setFocus(true)
            handled = true
        else if key = "up" and m.chatButton.hasFocus()
            m.keyboard.setFocus(true)
            m.chatButton.color = "0x18181BFF"
            handled = true
        else if key = "OK" and m.chatButton.hasFocus()
            m.chat.sendMessage = m.keyboard.text
            m.keyboard.text = ""
            m.chatButton.visible = false
            m.keyboard.visible = false
            m.chatButton.color = "0x18181BFF"
            m.chatButton.setFocus(false)
            m.top.doneFocus = true
            handled = true
        else if key = "OK" and not m.keyboard.visible
            m.keyboard.visible = true
            m.chatButton.visible = true
            m.keyboard.setFocus(true)
        else if key = "back"
            m.keyboard.text = ""
            m.chatButton.visible = false
            m.keyboard.visible = false
            m.chatButton.color = "0x18181BFF"
            handled = true
            m.top.doneFocus = true
        end if
    end if
    return handled
end function
