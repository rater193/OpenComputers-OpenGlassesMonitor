
--Libraries
local component = require("component")
local thread = require("thread")
local computer = require("computer")

tps = 0

--Used variables
local glasses = component.glasses

--Clearing the glasses
glasses.removeAll()

function createBatteryContent()
  local content = {
    ["bg"] = glasses.addRect(),
    ["textName"] = glasses.addTextLabel(),
    ["textPower"] = glasses.addTextLabel(),
    ["barBG"] = glasses.addRect(),
    ["barFG"] = glasses.addRect()
  }

  content.bg.setColor(0,0,0)
  content.bg.setAlpha(0.5)
  content.bg.setSize(256,23)
  
  content.barBG.setColor(100,0,0)
  content.barBG.setAlpha(0.5)
  content.barBG.setSize(256,23)
  
  content.barFG.setColor(0,255,0)
  content.barFG.setAlpha(1)
  content.barFG.setSize(256,23)

  content.textName.setScale(1,1)
  content.textName.setColor(255,255,255)
  content.textName.setAlpha(1)

  content.textPower.setScale(1,1)
  content.textPower.setColor(255,255,255)
  content.textPower.setAlpha(1)

  return content
end

local tpsBG = glasses.addRect()
local tpsText = glasses.addTextLabel()

tpsBG.setColor(0,0,0)
tpsBG.setAlpha(0.5)
tpsBG.setPosition(8,8)
tpsBG.setSize(128,11)

tpsText.setColor(255,255,255)
tpsText.setScale(1,1)
tpsText.setPosition(10,10)
tpsText.setText("TPS: ...")


local batteries = {}

for i, v in pairs(component.list()) do
  if(v=="energy_device") then
    table.insert(batteries, {
      ["name"] = "N/A",
      ["power"] = {
        ["cur"] = "0",
        ["max"] = "0",
        ["maxin"] = "0",
        ["maxout"] = "0",
        ["generatedLastTick"] = "10"
      },
      ["content"] = createBatteryContent(),
      ["address"] = i,
      ["proxy"] = component.proxy(i)
    })
  end
end

function shortText(val)
  local ret = tostring(math.floor(val)) .. " RF"
  if(val>=1000000000000) then
    ret = tostring((math.floor(val/100000000000)/10)) .. "TRF"
  elseif(val>=1000000000) then
    ret = tostring((math.floor(val/100000000)/10)) .. "MRF"
  elseif(val>=1000000) then
    ret = tostring((math.floor(val/100000)/10)) .. "MRF"
  elseif(val>=1000) then
    ret = tostring((math.floor(val/100)/10)) .. "KRF"
  end
  return ret
end

--Update thread
thread.create(function()
  while true do
    for i, v in pairs(batteries) do
      local bg = v.content.bg
      local textName = v.content.textName
      local textPower = v.content.textPower
      local textStatus = v.content.textStatus
      local barBG = v.content.barBG
      local barFG = v.content.barFG

      local energyStored = math.floor(v.proxy.getEnergyStored())
      local energyMax = math.floor(v.proxy.getMaxEnergyStored())

      tpsText.setText("tps: " .. tostring(tps))

      local _y = 8+(i*36)

      bg.setPosition(8, _y)
      bg.setColor(0,0,0)
      bg.setAlpha(0.5)
      bg.setSize(128,23)

      barBG.setPosition(8, _y + 23)
      barBG.setSize(128,12)

      barFG.setPosition(8, _y + 23)
      barFG.setSize((energyStored/energyMax) * 128,12)
      
      textName.setPosition(10, _y+2)
      textName.setText("Battery: " .. tostring(v.name) .. "")

      textPower.setPosition(10, _y+2+10)
      textPower.setText("Power: " .. shortText(energyStored) .. "/" .. shortText(energyMax))
    end
    os.sleep(0.01)
  end
end)

print("computer: " .. tostring(computer))
--Calculation thread
thread.create(function()
  while true do
    local timeBefore = os.clock()

    local tickBefore = os.time()
    while(tickBefore==os.time()) do
      os.sleep(0.05)
    end
    local timeAfter = os.clock()

    local timeTaken = timeAfter-timeBefore

    tps = math.floor(1/timeTaken)
    if(tps>20) then
      tps = 20
    end
    tps = tostring(tps)

    print("tick took " .. tostring(timeTaken))
  end
end)