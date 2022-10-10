function init()
    m.top.functionName = "main"
end function

function main()
    ? "PubSub"

    address = createObject("roSocketAddress")
    address.setHostName("pubsub-edge.twitch.tv")
    address.setPort(433)

    ? " address.isAddressValid() " address.isAddressValid()

    socket = CreateObject("roStreamSocket")
    socket.notifyReadable(true)
    socket.notifyWritable(true)
    socket.notifyException(true)
    
    ? " socket.SetSendToAddress(addr) " socket.SetSendToAddress(address)
    ? " socket.Connect() " socket.Connect()
    'socket.SendStr("CAP REQ :twitch.tv/tags twitch.tv/commands" + Chr(13) + Chr(10))
    'socket.SendStr("PASS SCHMOOPIIE" + Chr(13) + Chr(10))
    'socket.SendStr("NICK justinfan32006" + Chr(13) + Chr(10))
    'socket.SendStr("JOIN #" + m.top.channel + Chr(13) + Chr(10))

    ' while true
    '     get = socket.ReceiveStr(1)
    '     ? "get: " get
    ' end while
    

end function