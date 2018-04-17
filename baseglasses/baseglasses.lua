local glib = require("rater193/library")
local component = require("component")
local thread = require("thread")

local glasses = component.glasses

thread.create(function()
  local debugText = glasses.addTextLabel()
  debugText.setText("Debug loading")
  debugText.setColor(255,255,255)
  debugText.setScale(1,1)
  debugText.setPosition(10,0)
  
  local frameCount = 200
  
  --Initial debug text
  glib.createMessage(levels.warn, "This is a warning message")
  glib.createMessage(levels.warn, "Test 2")
  
  while(frameCount>0) do
    debugText.setText("Messages: " .. tostring(#messages) .. ", Frames left: " .. tostring(frameCount) .. ", seconds: " .. tostring(frameCount/20))
    glib.update()
    frameCount = frameCount-1
    os.sleep(1/40)
  end
  glasses.removeAll()
end)

thread.create(function()
  local repeatTimes = 5
  while (repeatTimes > 0) do
    os.sleep(1)
    createMessage(levels.error, "Error message, " .. tostring(repeatTimes))
    repeatTimes = repeatTimes-1
  end
end)