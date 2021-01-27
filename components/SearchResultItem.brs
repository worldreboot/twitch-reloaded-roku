sub init()
    m.image = m.top.findNode("image")
    m.itemTitle = m.top.findNode("itemTitle")

    deviceInfo = CreateObject("roDeviceInfo")
    uiResolutionWidth = deviceInfo.GetUIResolution().width

    if uiResolutionWidth = 1920
        m.top.findNode("itemIcon").maskSize = [75, 75]
    end if
end sub

sub showContent()
    itemContent = m.top.itemContent
    m.itemId = itemContent.id
    m.image.uri = itemContent.url
    m.itemTitle.text = itemContent.title
end sub