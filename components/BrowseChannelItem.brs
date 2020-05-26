sub init()
    m.itemThumbnail = m.top.findNode("itemThumbnail")
    m.itemTitle = m.top.findNode("itemTitle")
    m.itemStreamer = m.top.findNode("itemStreamer")
    m.itemCategory = m.top.findNode("itemCategory")
    m.itemViewers = m.top.findNode("itemViewers")
end sub

sub showContent()
    itemContent = m.top.itemContent
    m.itemThumbnail.uri = itemContent.HDPosterUrl
    m.itemTitle.text = itemContent.Title
    m.itemStreamer.text = itemContent.Description
    m.itemCategory.text = itemContent.Categories
    m.itemViewers.text = itemContent.ShortDescriptionLine2
end sub