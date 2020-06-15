sub init()
    m.image = m.top.findNode("image")
    m.itemTitle = m.top.findNode("itemTitle")
end sub

sub showContent()
    itemContent = m.top.itemContent
    m.itemId = itemContent.id
    m.image.uri = itemContent.url
    m.itemTitle.text = itemContent.title
end sub