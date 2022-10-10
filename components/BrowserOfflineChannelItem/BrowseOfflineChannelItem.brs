sub init()
    m.itemThumbnail = m.top.findNode("itemThumbnail")
    m.itemStreamer = m.top.findNode("itemStreamer")
end sub

sub showContent()
    itemContent = m.top.itemContent
    'm.itemId = itemContent.id
    m.itemThumbnail.uri = itemContent.HDPosterUrl
    m.itemStreamer.text = itemContent.Title
end sub