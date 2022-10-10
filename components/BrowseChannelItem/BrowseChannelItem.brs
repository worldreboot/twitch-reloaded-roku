sub init()
    m.itemThumbnail = m.top.findNode("itemThumbnail")
    m.itemTitle = m.top.findNode("itemTitle")
    m.itemStreamer = m.top.findNode("itemStreamer")
    m.itemCategory = m.top.findNode("itemCategory")
    m.itemViewers = m.top.findNode("itemViewers")
    m.viewsRect = m.top.findNode("viewsRect")

    m.top.observeField("itemHasFocus", "onItemHasFocus")
end sub

sub onItemHasFocus()
    if m.top.itemHasFocus
        m.itemTitle.repeatCount = -1
    else
        m.itemTitle.repeatCount = 0
    end if
end sub

sub showContent()
    itemContent = m.top.itemContent
    m.itemThumbnail.uri = itemContent.HDPosterUrl
    m.itemTitle.text = itemContent.Title
    m.itemStreamer.text = itemContent.Description
    m.itemCategory.text = itemContent.Categories
    m.itemViewers.text = itemContent.ShortDescriptionLine2
    m.viewsRect.width = m.itemViewers.localBoundingRect().width + 16
    m.viewsRect.height = m.itemViewers.localBoundingRect().height
end sub