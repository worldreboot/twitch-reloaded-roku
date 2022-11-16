function init()
    m.top.functionName = "main"
end function

function getChannelBadges() as Object
    url = createUrl()
    search_results_url = "https://api.twitch.tv/helix/users?login=" + m.top.channel
    url.SetUrl(search_results_url.EncodeUri())
    response_string = url.GetToString()
    user_data = ParseJson(response_string)
    user_id = ""
    if user_data.data[0].id <> invalid
        user_id = user_data.data[0].id
    end if

    return user_id
end function

function main()
    'messagePort = CreateObject("roMessagePort")
    if m.global.globalBadges = invalid
        m.global.addFields({globalBadges: GETJSON("https://badges.twitch.tv/v1/badges/global/display")})
    end if

    if m.global.globalTTVEmotes = invalid
        temp = GETJSON("https://api.betterttv.net/3/cached/emotes/global")
        assocEmotes = {}
        for each emote in temp
            assocEmotes[emote.code] = emote.id
        end for
        m.global.addFields({globalTTVEmotes: assocEmotes})
    end if

    if m.top.channel <> ""
        tcpListen = createObject("roStreamSocket")
        
        addr = createObject("roSocketAddress")
        addr.SetAddress("irc.chat.twitch.tv:6667")

        'messagePort = createObject("roMessagePort")
        
        tcpListen.SetSendToAddress(addr)
        'tcpListen.SetMessagePort(messagePort)
        tcpListen.notifyReadable(true)
        ? "connect " tcpListen.Connect()
        tcpListen.SendStr("CAP REQ :twitch.tv/tags twitch.tv/commands" + Chr(13) + Chr(10))
        user_auth_token = m.global.userToken
        if m.top.loggedInUsername <> "" and user_auth_token <> invalid and user_auth_token <> ""
            ? "PASS " tcpListen.SendStr("PASS oauth:" + user_auth_token + Chr(13) + Chr(10))
            ? "USER " tcpListen.SendStr("USER " + m.top.loggedInUsername + " 8 * :" + m.top.loggedInUsername + Chr(13) + Chr(10))
            ? "NICK " tcpListen.SendStr("NICK " + m.top.loggedInUsername + Chr(13) + Chr(10))
            ? "first eOK " tcpListen.eOK()
            ? "first IsReadable " tcpListen.IsReadable()
            ? "first IsWritable " tcpListen.IsWritable()
            ? "first IsException " tcpListen.IsException()
            ? "first eSuccess " tcpListen.eSuccess()
            '? "PASS oauth:" + user_auth_token
            '? "USER " + m.top.loggedInUsername + " 8 * :" + m.top.loggedInUsername
            '? "NICK " + m.top.loggedInUsername
        else
            tcpListen.SendStr("PASS SCHMOOPIIE" + Chr(13) + Chr(10))
            tcpListen.SendStr("NICK justinfan32006" + Chr(13) + Chr(10))
        end if
        ? "ChatTest >> JOIN > " m.top.channel
        tcpListen.SendStr("JOIN #" + m.top.channel + Chr(13) + Chr(10))

        'm.top.observeField("sendMessage", "sendMessage")

        channel_id = getChannelBadges()

        if m.global.channelBadges = invalid
            m.global.addFields({channelBadges: GETJSON("https://badges.twitch.tv/v1/badges/channels/" + channel_id + "/display")})
        else
            m.global.setField("channelBadges", GETJSON("https://badges.twitch.tv/v1/badges/channels/" + channel_id + "/display"))
        end if

        temp = GETJSON("https://api.betterttv.net/3/cached/users/twitch/" + channel_id)
        assocEmotes = {}
        for each emote in temp.sharedEmotes
            assocEmotes[emote.code] = emote.id
        end for
        if m.global.channelTTVEmotes = invalid
            m.global.addFields({channelTTVEmotes: assocEmotes})
        else
            m.global.setField("channelTTVEmotes", assocEmotes)
        end if

        temp = GETJSON("https://api.betterttv.net/3/cached/frankerfacez/users/twitch/" + channel_id)
        assocEmotes = {}
        for each emote in temp
            assocEmotes[emote.code] = emote.images["1x"]
        end for
        if m.global.channelTTVFrankerEmotes = invalid
            m.global.addFields({channelTTVFrankerEmotes: assocEmotes})
        else
            m.global.setField("channelTTVFrankerEmotes", assocEmotes)
        end if

        queue = createObject("roArray", 300, true)
        first = 0
        last = 0
        while true
            get = ""
            received = ""
            '? "tcpListen isConnected " tcpListen.IsConnected()
            if m.top.sendMessage <> "" and m.top.readyForNextComment
                ' ? "tcpListen isConnected " tcpListen.IsConnected()
                ' ? "second eOK " tcpListen.eOK()
                ' ? "second IsReadable " tcpListen.IsReadable()
                ' ? "second IsWritable " tcpListen.IsWritable()
                ' ? "second IsException " tcpListen.IsException()
                ' ? "second eSuccess " tcpListen.eSuccess()
                sent = tcpListen.SendStr("PRIVMSG #" + m.top.channel + " :" + m.top.sendMessage + Chr(13) + Chr(10))
                ' ? "Send Status " tcpListen.Status()
                ' ? "sent ;) " sent
                if sent > 0
                    m.top.nextComment = ""
                    m.top.clientComment = m.top.sendMessage
                end if
                m.top.sendMessage = ""
                'm.top.clientComment = m.top.sendMessage
            end if

            if tcpListen.GetCountRcvBuf() > 0
                while not get = Chr(10)
                    get = tcpListen.ReceiveStr(1)
                    '? "receive Status " tcpListen.Status()
                    received += get
                end while
            end if

            if tcpListen.GetCountRcvBuf() = 0 and tcpListen.IsReadable()
                ? "chat connection failed?"
                'tcpListen.Close()
                tcpListen = createObject("roStreamSocket")
                tcpListen.SetSendToAddress(addr)
                'tcpListen.SetMessagePort(messagePort)
                'tcpListen.notifyReadable(true)
                ? "connect " tcpListen.Connect()
                tcpListen.SendStr("CAP REQ :twitch.tv/tags twitch.tv/commands" + Chr(13) + Chr(10))
                user_auth_token = m.global.userToken
                if m.top.loggedInUsername <> "" and user_auth_token <> invalid and user_auth_token <> ""
                    ? "PASS " tcpListen.SendStr("PASS oauth:" + user_auth_token + Chr(13) + Chr(10))
                    ? "USER " tcpListen.SendStr("USER " + m.top.loggedInUsername + " 8 * :" + m.top.loggedInUsername + Chr(13) + Chr(10))
                    ? "NICK " tcpListen.SendStr("NICK " + m.top.loggedInUsername + Chr(13) + Chr(10))
                    '? "PASS oauth:" + user_auth_token
                    '? "USER " + m.top.loggedInUsername + " 8 * :" + m.top.loggedInUsername
                    '? "NICK " + m.top.loggedInUsername
                else
                    tcpListen.SendStr("PASS SCHMOOPIIE" + Chr(13) + Chr(10))
                    tcpListen.SendStr("NICK justinfan32006" + Chr(13) + Chr(10))
                end if
                tcpListen.SendStr("JOIN #" + m.top.channel + Chr(13) + Chr(10))
            end if

            if not received = ""
                if Left(received, 4) = "PING"
                    ? "PONG"
                    tcpListen.SendStr("PONG :tmi.twitch.tv" + Chr(13) + Chr(10))
                    '? "send PONG Status " tcpListen.Status()
                else
                    'queue[last] = received
                    queue.push(received)
                    ' ? "Message queue: " queue.count()
                    if last + 1 < 100
                        last += 1
                    else
                        last = 0
                    end if
                end if
            end if

            if m.top.readyForNextComment and queue.count() > 0
                m.top.nextComment = queue.shift()
                'queue[first] = invalid
                if first + 1 < 100
                    first += 1
                else
                    first = 0
                end if
            end if

        end while
    end if
    

end function