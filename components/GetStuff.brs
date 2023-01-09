'***********************
'** FIXED
'***********************
function init()
    m.top.functionName = "onStreamerChange"
end function

function onStreamerChange()
    m.top.streamUrl = getStreamLink(m.top.streamerRequested, false)
end function
