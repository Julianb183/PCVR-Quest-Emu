sub init()
    m.top.backgroundColor = "0x245EDBFF"
    m.startButton = m.top.findNode("startButton")
    m.notice = m.top.findNode("notice")
    m.clock = m.top.findNode("clock")
    m.startButton.observeField("buttonSelected", "openStartMenu")
    m.startButton.setFocus(true)
    m.timer = CreateObject("roSGNode", "Timer")
    m.timer.duration = 1
    m.timer.repeat = true
    m.timer.observeField("fire", "updateClock")
    m.timer.control = "start"
end sub

sub openStartMenu()
    m.notice.text = "Start menu opened\nApps   Documents   Settings   Power"
end sub

sub updateClock()
    dt = CreateObject("roDateTime")
    dt.ToLocalTime()
    m.clock.text = dt.AsTimeString()
end sub

function onKeyEvent(key as String, press as Boolean) as Boolean
    if not press then return false
    if key = "OK" then
        openStartMenu()
        return true
    end if
    if key = "back" then
        m.notice.text = "Windows XP 1GB Simulator\nPress OK to open the simulated Start menu."
        m.startButton.setFocus(true)
        return true
    end if
    if key = "up" or key = "down" or key = "left" or key = "right" then
        m.notice.text = "Start button focused — press OK\nUse the Roku remote arrows to navigate."
        return true
    end if
    return false
end function
