sub init()
    m.itemIcon = m.top.findNode("itemIcon")
    m.itemTitle = m.top.findNode("itemTitle")
end sub

sub showContent()
    itemContent = m.top.itemContent
    m.itemId = itemContent.id
    m.itemIcon.uri = itemContent.url
    m.itemTitle.text = itemContent.title
end sub