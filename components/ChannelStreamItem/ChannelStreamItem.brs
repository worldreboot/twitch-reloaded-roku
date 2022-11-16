sub init()
    m.itemThumbnail = m.top.findNode("itemThumbnail")
    m.itemTitle = m.top.findNode("itemTitle")
    m.itemGame = m.top.findNode("itemGame")
    m.itemViewers = m.top.findNode("itemViewers")
    m.viewsRect = m.top.findNode("viewsRect")
end sub

sub showContent()
    itemContent = m.top.itemContent
    m.itemThumbnail.uri = itemContent.HDPosterUrl
    m.itemTitle.text = itemContent.ShortDescriptionLine2
    m.itemGame.text = itemContent.Categories[0]
    '? "itemViewers: " itemContent.Title
    m.itemViewers.text = itemContent.Title
    m.viewsRect.width = m.itemViewers.localBoundingRect().width + 16
    m.viewsRect.height = m.itemViewers.localBoundingRect().height
end sub