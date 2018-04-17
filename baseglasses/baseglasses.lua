
--Libraries
local component = require("component")
local thread = require("thread")

--Used variables
local glasses = component.glasses

--Clearing the glasses
glasses.removeAll()

function createBatteryContent()
  local content = {
    ["bg"] = glasses.addRect(),
    ["textName"] = glasses.addTextLabel(),
    ["textPower"] = glasses.addTextLabel()
  }

  content.bg.setColor(0,0,0)
  content.bg.setAlpha(0.5)
  content.bg.setSize(256,23)

  content.textName.setScale(1,1)
  content.textName.setColor(255,255,255)
  content.textName.setAlpha(1)

  content.textPower.setScale(1,1)
  content.textPower.setColor(255,255,255)
  content.textPower.setAlpha(1)

  return content
end

local batteries = {
  {
    ["name"] = "Battery-1",
    ["power"] = {
      ["cur"] = "2435",
      ["max"] = "63215424",
      ["maxin"] = "10000",
      ["maxout"] = "10000",
      ["generatedLastTick"] = "10"
    },
    ["content"] = createBatteryContent()
  },
  {
    ["name"] = "Battery-2",
    ["power"] = {
      ["cur"] = "2435",
      ["max"] = "63215424",
      ["maxin"] = "10000",
      ["maxout"] = "10000",
      ["generatedLastTick"] = "10"
    },
    ["content"] = createBatteryContent()
  },
  {
    ["name"] = "Battery-3",
    ["power"] = {
      ["cur"] = "2435",
      ["max"] = "63215424",
      ["maxin"] = "10000",
      ["maxout"] = "10000",
      ["generatedLastTick"] = "10"
    },
    ["content"] = createBatteryContent()
  }
}

--Update thread
thread.create(function()
  while true do
    for i, v in pairs(batteries) do
      local bg = v.content.bg
      local textName = v.content.textName
      local textPower = v.content.textPower

      bg.setPosition(8, 8+(i*24))
      bg.setColor(0,0,0)
      bg.setAlpha(0.5)
      bg.setSize(128,23)

      textName.setPosition(10, 10+(i*24))
      textName.setText("Battery: " .. tostring(v.name) .. "")

      textPower.setPosition(10, 10+(i*24)+12)
      textPower.setText("Power: 0/0")
    end
    os.sleep(1)
  end
end)

--Calculation thread
thread.create(function()

end)