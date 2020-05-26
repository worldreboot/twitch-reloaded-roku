sub init()
    m.browseList = m.top.findNode("browseList")

    m.clipButton = m.top.findNode("clipButton")
    m.clipLine = m.top.findNode("clipLine")
    m.liveButton = m.top.findNode("liveButton")
    m.liveLine = m.top.findNode("liveLine")

    m.browseButtons = m.top.findNode("browseButtons")

    m.browseList.observeField("itemSelected", "onBrowseItemSelect")

    m.getStreams = createObject("roSGNode", "GetStreams")
    m.getStreams.observeField("searchResults", "onSearchResultChange")

    m.getStuff = createObject("roSGNode", "GetStuff")
    m.getStuff.observeField("streamUrl", "onStreamUrlChange")

    m.top.observeField("visible", "onGetFocus")

    m.offset = 0
    m.newCategory = false
    m.append = false

    m.wasLastScene = false
end sub

sub onGetFocus()
    if m.top.visible = true
        m.browseList.visible = true
        m.browseList.setFocus(true)
    else if m.top.visible = false
        'm.offset = 0
        m.append = false
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
    return result + " viewers"
end sub

sub onSearchResultChange()
    lastFocusedRow = 0
    if m.browseList.rowItemFocused[0] <> invalid
        lastFocusedRow = m.browseList.rowItemFocused[0]
    end if
    if m.append = true and m.browseList.content <> invalid
        content = m.browseList.content
    else
        content = createObject("roSGNode", "ContentNode")
    end if
    if m.getStreams.searchResults <> invalid
        row = createObject("RoSGNode", "ContentNode")
        rowItem = invalid
        alreadyAppended = false
        cnt = 0
        for each stream in m.getStreams.searchResults
            alreadyAppended = false
            if cnt <> 0 and cnt MOD 3 = 0
                content.appendChild(row)
                row = createObject("RoSGNode", "ContentNode")
                alreadyAppended = true
            end if
            rowItem = createObject("RoSGNode", "ContentNode")
            rowItem.Title = stream.title
            rowItem.Description = stream.display_name
            rowItem.Categories = stream.game
            rowItem.HDPosterUrl = stream.thumbnail
            rowItem.ShortDescriptionLine1 = stream.name
            rowItem.ShortDescriptionLine2 = numberToText(stream.viewers)
            row.appendChild(rowItem)
            cnt += 1
        end for
        if rowItem <> invalid and cnt <> 0 and alreadyAppended = false
            row.appendChild(rowItem)
        end if
    end if
    if m.browseList.visible = true
        m.browseList.content = content
    end if
    if m.newCategory = false
        m.browseList.jumpToItem = lastFocusedRow
    else if m.newCategory = true
        m.browseList.jumpToItem = 0
        m.newCategory = false
    end if
    m.append = false
end sub

sub onCategoryChange()
    m.newCategory = true
    m.offset = 0
    m.getStreams.offset = "0"
    m.getStreams.gameRequested = m.top.currentCategory
    m.getStreams.control = "RUN"
end sub

sub onStreamUrlChange()
    m.top.streamUrl = m.getStuff.streamUrl
end sub

sub onBrowseItemSelect()
    if m.browseList.visible = true
        m.getStuff.streamerRequested = m.browseList.content.getChild(m.browseList.rowItemSelected[0]).getChild(m.browseList.rowItemSelected[1]).ShortDescriptionLine1
        m.getStuff.control = "RUN"
        m.wasLastScene = true
    end if
end sub

sub onSceneLoad()
    m.browseList.visible = true
    m.getStreams.gameRequested = ""
    m.getStreams.offset = "0"
    m.getStreams.control = "RUN"
end sub

sub getMoreChannels()
    m.offset += 24
    m.append = true
    m.getStreams.gameRequested = m.top.currentCategory
    m.getStreams.offset = m.offset.ToStr()
    ? "m.offset >> ";m.getStreams.offset
    m.getStreams.control = "RUN"
end sub

sub onKeyEvent(key, press) as Boolean
    handled = false

    if m.top.visible = true and press
        if m.browseList.hasFocus() = true and key = "up"
            if m.clipLine.visible = true
                m.liveButton.color = "0xA970FFFF"
            else if m.liveLine.visible = true
                m.clipButton.color = "0xA970FFFF"
            end if
            m.browseButtons.setFocus(true)
            handled = true
        else if m.browseButtons.hasFocus() = true and key = "down"
            if m.clipLine.visible = true
                m.liveButton.color = "0xEFEFF1FF"
                m.browseList.setFocus(true)
                handled = true
            else if m.liveLine.visible = true
                m.clipButton.color = "0xEFEFF1FF"
                m.browseList.setFocus(true)
                handled = true
            end if
        else if m.browseButtons.hasFocus() = true and key = "OK"
            if m.clipLine.visible = true
                m.liveButton.color = "0xA970FFFF"
                m.liveLine.visible = true
                m.clipLine.visible = false
                m.clipButton.color = "0xEFEFF1FF"
                m.browseList.setFocus(true)
                handled = true
            else if m.liveLine.visible = true
                m.clipButton.color = "0xA970FFFF"
                m.clipLine.visible = true
                m.liveLine.visible = false
                m.liveButton.color = "0xEFEFF1FF"
                handled = true
            end if
        else if m.browseList.hasFocus() = true and key = "down"
            getMoreChannels()
        end if
    else if press = false
        if key = "back" and m.wasLastScene = true
            if m.clipLine.visible = true
                handled = true
            else if m.liveLine.visible = true
                m.browseList.setFocus(true)
                handled = true
            end if
            m.offset = 0
            m.wasLastScene = false
        end if
    end if

    return handled
end sub
