sub init()
    m.itemThumbnail = m.top.findNode("itemThumbnail")
    m.itemTitle = m.top.findNode("itemTitle")
    m.itemGame = m.top.findNode("itemGame")
    m.itemViewers = m.top.findNode("itemViewers")
    m.viewsRect = m.top.findNode("viewsRect")
end sub

sub showContent()
    itemContent = m.top.itemContent
    if itemContent.Categories = invalid
        itemContent.Categories = ""
    end if
    if itemContent.ShortDescriptionLine2 = invalid
        itemContent.ShortDescriptionLine2 = ""
    end if
    m.itemThumbnail.uri = itemContent.HDPosterUrl
    m.itemTitle.text = itemContent.ShortDescriptionLine2
    m.itemGame.text = itemContent.Categories[0]
    '? "itemViewers: " itemContent.Title
    m.itemViewers.text = itemContent.Title
    m.viewsRect.width = m.itemViewers.localBoundingRect().width + 16
    m.viewsRect.height = m.itemViewers.localBoundingRect().height
end sub