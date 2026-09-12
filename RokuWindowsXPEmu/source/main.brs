sub Main()
    screen = CreateObject("roSGScreen")
    port = CreateObject("roMessagePort")
    screen.setMessagePort(port)
    scene = screen.CreateScene("DesktopScene")
    screen.show()
    scene.setFocus(true)

    while true
        msg = wait(0, port)
        if type(msg) = "roSGScreenEvent" and msg.isScreenClosed() then return
    end while
end sub
