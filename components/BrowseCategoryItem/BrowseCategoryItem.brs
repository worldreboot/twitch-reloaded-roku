sub init()
    m.itemThumbnail = m.top.findNode("itemThumbnail")
    m.itemTitle = m.top.findNode("itemTitle")
    'm.itemViewers = m.top.findNode("itemViewers")
end sub

sub showContent()
    itemContent = m.top.itemContent
    'm.itemId = itemContent.id
    m.itemThumbnail.uri = itemContent.HDPosterUrl
    m.itemTitle.text = itemContent.Title
    'm.itemViewers.text = itemContent.Description
end sub