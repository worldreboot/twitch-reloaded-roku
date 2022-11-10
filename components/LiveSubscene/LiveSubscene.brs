sub init()
     m.liveRowList = m.top.findNode("liveRowList")
     m.liveRowList.observeField("itemFocused", "onItemFocused")
     m.liveRowList.content = createObject("roSGNode", "ContentNode")
end sub

sub onItemFocused()
     m.liveRowList.visible = m.liveRowList.isInFocusChain()
end sub

sub populateLiveList()
    if m.top.liveStreams <> invalid
        row = invalid
        cnt = 0
        for each stream in m.top.liveStreams
             if cnt MOD 3 = 0
                    row = createObject("RoSGNode", "ContentNode")
                    m.liveRowList.content.appendChild(row)
             end if
               rowItem = createObject("RoSGNode", "ContentNode")
               rowItem.Title = stream.title
               rowItem.Description = stream.display_name
               rowItem.Categories = stream.game
               rowItem.HDPosterUrl = stream.thumbnail
               rowItem.ShortDescriptionLine1 = stream.name
               rowItem.ShortDescriptionLine2 = numberToText(stream.viewers)  + " viewers"
               row.appendChild(rowItem)
               cnt++
        end for
    end if
end sub