function init()
    m.top.functionName = "onStreamerChange"
end function


function onStreamerChange()
    stream_link = getStreamLink(m.top.videoId, true)
    if stream_link = "vod_manifest_restricted"
        m.top.streamUrl = "vod_manifest_restricted"
    else
        extractThumbnailUrl(stream_link)
        m.top.streamUrl = stream_link
    end if
end function

sub extractThumbnailUrl(streamUrl)
    index = Len(streamUrl)
    secondSlash = false
    while index > 0
        if Mid(streamUrl, index, 1) = "/"
            if secondSlash
                info_url = Mid(streamUrl, 1, index - 1) + "/storyboards/"
                url = CreateObject("roUrlTransfer")
                url.EnableEncodings(true)
                url.RetainBodyOnError(true)
                url.SetCertificatesFile("common:/certs/ca-bundle.crt")
                url.InitClientCertificates()
                url.SetUrl(info_url + m.top.videoId + "-info.json")
                ? "video info url > "; info_url + m.top.videoId + "-info.json"
                response_string = url.GetToString()
                thumbnailInfo = ParseJson(response_string)
                if thumbnailInfo <> invalid and thumbnailInfo[0] <> invalid
                    url2 = CreateObject("roUrlTransfer")
                    url2.EnableEncodings(true)
                    url2.RetainBodyOnError(true)
                    url2.SetCertificatesFile("common:/certs/ca-bundle.crt")
                    url2.InitClientCertificates()
                    url2.SetUrl(info_url + thumbnailInfo[1].images[0])
                    'url2.SetUrl(info_url + thumbnailInfo[0].images[0])
                    'url2.SetUrl("https://i.redd.it/u105ro5rg8o31.jpg")
                    ? "image url: "; info_url + thumbnailInfo[1].images[0]
                    '? "response code: "; url2.GetToFile("tmp:/thumbnails.jpg")
                    '? "response: "; url2.GetToString()
                    m.top.thumbnailInfo = { count: thumbnailInfo[1].count,
                        width: thumbnailInfo[1].width,
                        rows: thumbnailInfo[1].rows,
                        interval: thumbnailInfo[1].interval,
                        cols: thumbnailInfo[1].cols,
                        height: thumbnailInfo[1].height,
                        info_url: info_url,
                        thumbnail_parts: thumbnailInfo[1].images,
                    video_id: m.top.videoId }
                else
                    m.top.thumbnailInfo = { video_id: m.top.videoId }
                end if
                exit while
            end if
            secondSlash = true
        end if
        index -= 1
    end while
end sub

'https://usher.ttvnw.net/api/channel/hls/nickmercs.m3u8?allow_source=true&fast_bread=true&p=6274977&play_session_id=587e886acefc28722ef9db20d471d9e9&player_backend=mediaplayer&playlist_include_framerate=true&reassignments_supported=true&sig=cfa200674bab75075ee0d9a5eaec941095033e24&supported_codecs=avc1&token=%7B%22adblock%22%3Atrue%2C%22authorization%22%3A%7B%22forbidden%22%3Afalse%2C%22reason%22%3A%22%22%7D%2C%22blackout_enabled%22%3Afalse%2C%22channel%22%3A%22nickmercs%22%2C%22channel_id%22%3A15564828%2C%22chansub%22%3A%7B%22restricted_bitrates%22%3A%5B%5D%2C%22view_until%22%3A1924905600%7D%2C%22ci_gb%22%3Afalse%2C%22geoblock_reason%22%3A%22%22%2C%22device_id%22%3A%22f3f26ea3cdfea02a%22%2C%22expires%22%3A1594268273%2C%22extended_history_allowed%22%3Afalse%2C%22game%22%3A%22%22%2C%22hide_ads%22%3Afalse%2C%22https_required%22%3Atrue%2C%22mature%22%3Afalse%2C%22partner%22%3Afalse%2C%22platform%22%3A%22_%22%2C%22player_type%22%3A%22site%22%2C%22private%22%3A%7B%22allowed_to_view%22%3Atrue%7D%2C%22privileged%22%3Afalse%2C%22server_ads%22%3Afalse%2C%22show_ads%22%3Atrue%2C%22subscriber%22%3Afalse%2C%22turbo%22%3Afalse%2C%22user_id%22%3A60049647%2C%22user_ip%22%3A%2272.136.77.60%22%2C%22version%22%3A2%7D&cdm=wv&player_version=0.9.80
'https://usher.ttvnw.net/vod/682807996.m3u8?allow_source=true&p=732898&playlist_include_framerate=true&reassignments_supported=true&sig=8aead6f4649e407fdd3f872c44d8d798386bdafc&supported_codecs=avc1&token=%7B%22authorization%22%3A%7B%22forbidden%22%3Afalse%2C%22reason%22%3A%22%22%7D%2C%22chansub%22%3A%7B%22restricted_bitrates%22%3A%5B%5D%7D%2C%22device_id%22%3A%22f3f26ea3cdfea02a%22%2C%22expires%22%3A1595201031%2C%22https_required%22%3Atrue%2C%22privileged%22%3Afalse%2C%22user_id%22%3A60049647%2C%22version%22%3A2%2C%22vod_id%22%3A682807996%7D&cdm=wv&player_version=1.0.0