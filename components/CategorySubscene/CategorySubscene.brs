sub init()
     m.categoryRowList = m.top.findNode("categoryRowList")
     m.categoryRowList.observeField("itemFocused", "onItemFocused")
     m.categoryRowList.content = createObject("roSGNode", "ContentNode")
     
end sub

sub onItemFocused()
     m.categoryRowList.visible = m.categoryRowList.isInFocusChain()
end sub

sub populateCategoryList()
    if m.top.categories <> invalid
        row = invalid
        cnt = 0
        for each stream in m.top.categories
             if cnt MOD 6 = 0
                    row = createObject("RoSGNode", "ContentNode")
                    m.categoryRowList.content.appendChild(row)
             end if
             rowItem = createObject("RoSGNode", "ContentNode")
             rowItem.Title = stream.name
             rowItem.Description = numberToText(stream.viewers) + " viewers"
             rowItem.ShortDescriptionLine1 = stream.id
             rowItem.HDPosterUrl = stream.logo
             row.appendChild(rowItem)
               cnt++
        end for
    end if
end sub