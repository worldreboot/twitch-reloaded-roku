function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()

    stream_link = getStreamLink()
    m.top.streamUrl = stream_link

end function

function getStreamLink() as Object
    ' access_token_url = "http://api.twitch.tv/api/channels/" + m.top.streamerRequested + "/access_token?client_id=jzkbprff40iqj646a697cyrvl0zt2m6&platform=_"

    url = CreateObject("roUrlTransfer")
    url.EnableEncodings(true)
    url.RetainBodyOnError(true)
    url.SetCertificatesFile("common:/certs/ca-bundle.crt")
    url.InitClientCertificates()
    ' 'url.AddHeader("Origin", "https://www.twitch.tv")
    ' 'url.AddHeader("Referer", "https://www.twitch.tv/")

    ' url.SetUrl(access_token_url)
    ' response_string = url.GetToString()
    ' access_token = ParseJson(response_string)
    ' 'access_token = ParseJson(POST("https://gql.twitch.tv/gql", "{"+Chr(34)+"operationName"+Chr(34)+":"+Chr(34)+"PlaybackAccessToken"+Chr(34)+","+Chr(34)+"variables"+Chr(34)+":{"+Chr(34)+"isLive"+Chr(34)+":true,"+Chr(34)+"login"+Chr(34)+":"+Chr(34)+m.top.streamerRequested+Chr(34)+","+Chr(34)+"isVod"+Chr(34)+":false,"+Chr(34)+"vodID"+Chr(34)+":"+Chr(34)+""+Chr(34)+","+Chr(34)+"playerType"+Chr(34)+":"+Chr(34)+"embed"+Chr(34)+"},"+Chr(34)+"extensions"+Chr(34)+":{"+Chr(34)+"persistedQuery"+Chr(34)+":{"+Chr(34)+"version"+Chr(34)+":1,"+Chr(34)+"sha256Hash"+Chr(34)+":"+Chr(34)+"0828119ded1c13477966434e15800ff57ddacf13ba1911c129dc2200705b0712"+Chr(34)+"}}}"))

    ' if access_token = invalid
    '     return ""
    ' end if

    ' stream_link = "http://usher.ttvnw.net/api/channel/hls/" + m.top.streamerRequested + ".m3u8?allow_source=true&allow_spectre=true&type=any&playlist_include_framerate=true&token=" + access_token.token + "&sig=" + access_token.sig
    'stream_link = "http://usher.ttvnw.net/api/channel/hls/" + m.top.streamerRequested + ".m3u8?allow_source=true&fast_bread=true&p=3737804&play_session_id=ea4af70a988073e598e8c1cab7fc6281&player_backend=mediaplayer&playlist_include_framerate=true&reassignments_supported=true&sig=" + access_token.data.streamPlaybackAccessToken.signature + "&supported_codecs=vp09,avc1&token=" + access_token.data.streamPlaybackAccessToken.value + "&cdm=wv" + "&player_version=1.2.0"

    stream_link = "https://ancient-journey-35965.herokuapp.com/stream?streamer=" + m.top.streamerRequested

    url.SetUrl(stream_link.EncodeUri())

    rsp = url.GetToString()

    '? rsp

    list = rsp.Split(chr(10))

    first_stream_link = ""
    last_stream_link = ""
    link = ""
    cnt = 0
    for line = 2 to list.Count() - 1
        stream_info = list[line + 1].Split(",")
        stream_quality = invalid
        stream_framerate = invalid
        for info = 0 to stream_info.Count() - 1
            info_parsed = stream_info[info].Split("=")
            if info_parsed[0] = "RESOLUTION"
                stream_quality = Int(Val(info_parsed[1].Split("x")[1]))
            else if info_parsed[0] = "VIDEO"
                if info_parsed[1] = (chr(34) + "chunked" + chr(34))
                    stream_framerate = 30
                else
                    stream_framerate = Int(Val(info_parsed[1].Split("p")[1]))
                end if
            end if
        end for

        if stream_framerate = invalid
            stream_framerate = 30
        end if

        if not stream_quality = invalid
            compatible_link = false
            last_stream_link = list[line + 2]
            if m.global.videoFramerate >= stream_framerate
                if m.global.videoQuality <= 1 and stream_quality <= 1080
                    compatible_link = true
                else if m.global.videoQuality <= 3 and stream_quality <= 720
                    compatible_link = true
                else if m.global.videoQuality = 4 and stream_quality <= 480
                    compatible_link = true
                else if m.global.videoQuality = 5 and stream_quality <= 360
                    compatible_link = true
                else if m.global.videoQuality = 6 and stream_quality <= 160
                    compatible_link = true
                end if
            end if

            if compatible_link
                link = list[line + 2]
                exit for
            end if
        end if

        line += 2
    end for
    ' for each word in list
    '     first = word.Left(4)
    '     if first = "http"
    '         last_stream_link = word
    '         if cnt = 1
    '             first_stream_link = word
    '             exit for
    '         end if
    '         cnt += 1
    '     end if
    ' end for

    ' if first_stream_link = ""
    '     first_stream_link = last_stream_link
    ' end if

    ' return first_stream_link

    if link = ""
        return last_stream_link
    end if

    '? "GetStuff >> token > "; access_token.token
    '? "GetStuff >> link > "; link

    return link
end function

'https://usher.ttvnw.net/api/channel/hls/nickmercs.m3u8?allow_source=true&fast_bread=true&p=6274977&play_session_id=587e886acefc28722ef9db20d471d9e9&player_backend=mediaplayer&playlist_include_framerate=true&reassignments_supported=true&sig=cfa200674bab75075ee0d9a5eaec941095033e24&supported_codecs=avc1&token=%7B%22adblock%22%3Atrue%2C%22authorization%22%3A%7B%22forbidden%22%3Afalse%2C%22reason%22%3A%22%22%7D%2C%22blackout_enabled%22%3Afalse%2C%22channel%22%3A%22nickmercs%22%2C%22channel_id%22%3A15564828%2C%22chansub%22%3A%7B%22restricted_bitrates%22%3A%5B%5D%2C%22view_until%22%3A1924905600%7D%2C%22ci_gb%22%3Afalse%2C%22geoblock_reason%22%3A%22%22%2C%22device_id%22%3A%22f3f26ea3cdfea02a%22%2C%22expires%22%3A1594268273%2C%22extended_history_allowed%22%3Afalse%2C%22game%22%3A%22%22%2C%22hide_ads%22%3Afalse%2C%22https_required%22%3Atrue%2C%22mature%22%3Afalse%2C%22partner%22%3Afalse%2C%22platform%22%3A%22_%22%2C%22player_type%22%3A%22site%22%2C%22private%22%3A%7B%22allowed_to_view%22%3Atrue%7D%2C%22privileged%22%3Afalse%2C%22server_ads%22%3Afalse%2C%22show_ads%22%3Atrue%2C%22subscriber%22%3Afalse%2C%22turbo%22%3Afalse%2C%22user_id%22%3A60049647%2C%22user_ip%22%3A%2272.136.77.60%22%2C%22version%22%3A2%7D&cdm=wv&player_version=0.9.80
'https://usher.ttvnw.net/vod/682807996.m3u8?allow_source=true&p=732898&playlist_include_framerate=true&reassignments_supported=true&sig=8aead6f4649e407fdd3f872c44d8d798386bdafc&supported_codecs=avc1&token=%7B%22authorization%22%3A%7B%22forbidden%22%3Afalse%2C%22reason%22%3A%22%22%7D%2C%22chansub%22%3A%7B%22restricted_bitrates%22%3A%5B%5D%7D%2C%22device_id%22%3A%22f3f26ea3cdfea02a%22%2C%22expires%22%3A1595201031%2C%22https_required%22%3Atrue%2C%22privileged%22%3Afalse%2C%22user_id%22%3A60049647%2C%22version%22%3A2%2C%22vod_id%22%3A682807996%7D&cdm=wv&player_version=1.0.0