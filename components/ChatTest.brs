'api.twitch.tv/kraken/search/channels?query=${search_text}&limit=5&client_id=jzkbprff40iqj646a697cyrvl0zt2m6

function init()
    'm.gameNames = CreateObject("roAssociativeArray")
    'm.userProfiles = CreateObject("roAssociativeArray")
    m.top.functionName = "main"
end function

' function getJSON(link as Object)
'     url = createUrl()
'     ' url = CreateObject("roUrlTransfer")
'     ' url.EnableEncodings(true)
'     ' url.RetainBodyOnError(true)
'     ' url.SetCertificatesFile("common:/certs/ca-bundle.crt")
'     ' url.InitClientCertificates()
'     ' url.AddHeader("Client-ID", "w9msa6phhl3u8s2jyjcmshrfjczj2y")
'     ' url.AddHeader("Authorization", "Bearer kp3nfb1pwuo6imnfbf20x3gqtbxu2e")

'     'search_results_url = link.EncodeUri()
'     url.SetUrl(link.EncodeUri())
'     response_string = url.GetToString()

'     '? "test > "; response_string
'     return ParseJson(response_string)
' end function

function getChannelBadges() as Object
    url = createUrl()
    ' url = CreateObject("roUrlTransfer")
    ' url.EnableEncodings(true)
    ' url.RetainBodyOnError(true)
    ' url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    ' url.InitClientCertificates()
    ' url.AddHeader("Client-ID", "w9msa6phhl3u8s2jyjcmshrfjczj2y")
    ' url.AddHeader("Authorization", "Bearer kp3nfb1pwuo6imnfbf20x3gqtbxu2e")
    search_results_url = "https://api.twitch.tv/helix/users?login=" + m.top.channel
    url.SetUrl(search_results_url.EncodeUri())
    response_string = url.GetToString()
    '? "test > "; response_string
    user_data = ParseJson(response_string)
    user_id = ""
    if user_data.data[0].id <> invalid
        user_id = user_data.data[0].id
    end if

    return user_id
    'return getJSON("https://badges.twitch.tv/v1/badges/channels/" + user_id + "/display")
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
        tcpListen = CreateObject("roStreamSocket")
        
        addr = CreateObject("roSocketAddress")
        addr.SetAddress("irc.chat.twitch.tv:6667")
        
        tcpListen.SetSendToAddress(addr)
        tcpListen.notifyReadable(true)
        tcpListen.Connect()
        tcpListen.SendStr("CAP REQ :twitch.tv/tags twitch.tv/commands" + Chr(13) + Chr(10))
        tcpListen.SendStr("PASS SCHMOOPIIE" + Chr(13) + Chr(10))
        tcpListen.SendStr("NICK justinfan32006" + Chr(13) + Chr(10))
        tcpListen.SendStr("JOIN #" + m.top.channel + Chr(13) + Chr(10))

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

        queue = createObject("roArray", 300, false)
        first = 0
        last = 0
        while true
            get = ""
            received = ""
            while not get = Chr(10)
                get = tcpListen.ReceiveStr(1)
                received += get
            end while
            if not received = ""
                if Left(received, 4) = "PING"
                    tcpListen.SendStr("PONG :tmi.twitch.tv" + Chr(13) + Chr(10))
                else
                    queue[last] = received
                    if last + 1 < 100
                        last += 1
                    else
                        last = 0
                    end if
                end if
            end if
            if m.top.readyForNextComment and not queue[first] = invalid
                m.top.nextComment = queue[first]
                queue[first] = invalid
                if first + 1 < 100
                    first += 1
                else
                    first = 0
                end if
            end if
        end while

    end if
    

end function