sub init()
    m.currentVideoQuality = m.top.findNode("currentVideoQuality")
    m.videoQualityDropdown = m.top.findNode("videoQualityDropdown")
    m.videoQualitySelectRect = m.top.findNode("videoQualitySelectRect")
    m.chatInfo = m.top.findNode("chatInfo")
    m.optionSelectRect = m.top.findNode("optionSelectRect")

    m.top.observeField("visible", "onBackPress")

    m.videoQualities = ["1080p60","1080p","720p60","720p","480p","360p","160p"]
    '? "m.videoQuality > "; m.global.videoQuality
    m.currentVideoQuality.text = m.videoQualities[m.global.videoQuality]
    m.currentChatOption = m.global.chatOption
    if m.currentChatOption
        m.chatInfo.text = "Enabled"
    else
        m.chatInfo.text = "Disabled"
    end if
    m.currentOption = 0
    m.currentVideoQualitySelected = 0
end sub

sub onBackPress()
    if m.top.visible = false
        m.videoQualityDropdown.visible = false
        m.currentVideoQuality.visible = true
    end if
end sub

sub saveVideoSettings() as Void
    sec = createObject("roRegistrySection", "VideoSettings")
    sec.Write("VideoQuality", m.global.videoQuality.ToStr())
    sec.Write("VideoFramerate", m.global.videoFramerate.ToStr())
    sec.Write("ChatOption", m.global.chatOption.ToStr())
    sec.Flush()
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false
    if press
        '? "options test > ";m.currentOption; " ";m.currentVideoQualitySelected; " ";m.videoQualityDropdown.hasFocus()
        if key = "OK"
            '? "options test > ";m.videoQualityDropdown.hasFocus()
            if m.videoQualityDropdown.hasFocus()
                if m.global.videoQuality <> invalid
                    m.global.setField("videoQuality", m.currentVideoQualitySelected)
                    if m.currentVideoQualitySelected = 0 or m.currentVideoQualitySelected = 2
                        m.global.setField("videoFramerate", 60)
                    else
                        m.global.setField("videoFramerate", 30)
                    end if
                end if
                saveVideoSettings()
                m.currentVideoQuality.text = m.videoQualities[m.currentVideoQualitySelected]
                m.videoQualityDropdown.setFocus(false)
                m.top.setFocus(true)
                m.videoQualitySelectRect.visible = false
                m.videoQualityDropdown.visible = false
                m.currentVideoQuality.visible = true
            else if m.currentOption = 0
                '? "here?"
                m.videoQualityDropdown.setFocus(true)
                m.currentVideoQuality.visible = false
                m.videoQualityDropdown.visible = true
                m.videoQualitySelectRect.visible = true
            else if m.currentOption = 1
                '? "here?"
                m.currentChatOption = not m.currentChatOption
                m.global.setField("chatOption", m.currentChatOption)
                if m.currentChatOption
                    m.chatInfo.text = "Enabled"
                else
                    m.chatInfo.text = "Disabled"
                end if
                saveVideoSettings()
            end if
            handled = true
        else if key = "down"
            if m.videoQualityDropdown.hasFocus()
                if m.currentVideoQualitySelected + 1 <= 6 
                    m.currentVideoQualitySelected += 1
                    m.videoQualitySelectRect.translation = [m.videoQualitySelectRect.translation[0], m.videoQualitySelectRect.translation[1] + 50]
                end if
            else if m.currentOption + 1 <= 1 
                m.optionSelectRect.translation = [90,300]
                m.currentOption += 1
            end if
            handled = true
        else if key = "up"
            if m.videoQualityDropdown.hasFocus()
                if m.currentVideoQualitySelected - 1 >= 0 
                    m.currentVideoQualitySelected -= 1
                    m.videoQualitySelectRect.translation = [m.videoQualitySelectRect.translation[0], m.videoQualitySelectRect.translation[1] - 50]
                end if
            else if m.currentOption - 1 >= 0
                m.optionSelectRect.translation = [90,200] 
                m.currentOption -= 1
            end if
            handled = true
        end if
    end if
    return handled
end sub