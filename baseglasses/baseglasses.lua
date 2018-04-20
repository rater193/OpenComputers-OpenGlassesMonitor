
--Libraries
local component = require("component")
local thread = require("thread")
local computer = require("computer")
local fs = require("filesystem")

tps = 0

--Used variables
local glasses = component.glasses
local timeBefore = os.clock()
local timeConstant = 0.5

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
      ["proxy"] = component.proxy(i),
      ["previouslyCheckedEnergy"] = component.proxy(i).getEnergyStored()
    })
  end
end

local function time()
  local f = io.open("/tmp/timeFile","w")
  f:write("test")
  f:close()
  return(fs.lastModified("/tmp/timeFile"))
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

function convertToDateString(val)
  local ret = tostring(val) .. " seconds"
  if(val>60) then
    ret = tostring(math.ceil(val/60)) .. " minutes"
  end
  if(val>60*60) then
    ret = tostring(math.ceil(val/(60*60))) .. " hrs"
  end
  if(val>60*60*24) then
    ret = tostring(math.ceil(val/(60*60*24))) .. " days"
  end
  if(val>60*60*24*30) then
    ret = tostring(math.ceil(val/(60*60*24*30))) .. " months"
  end
  if(val>60*60*24*30*12) then
    ret = tostring(math.ceil(val/(60*60*24*30*12))) .. " years"
  end
  return ret
end

--Update thread
thread.create(function()
  local status, err = pcall(function()
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
        local generated = v.previouslyCheckedEnergy - energyStored
        local remaining = energyMax-energyStored

        if(generated==0) then

        else
          print("Time remaining: " .. convertToDateString(math.abs(math.floor(remaining/generated))))
        end

        v.previouslyCheckedEnergy = energyStored


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
      os.sleep(1)
    end
  end)
  print("Glasses updater thread error: " .. tostring(err))
  print("Press CTRL+ALT+T to terminate program!")
end)

print("computer: " .. tostring(computer))
--Calculation thread
thread.create(function()
  local status, err = pcall(function()
    while true do
      --Time calculation
      tps = 0

      realTimeOld = time()
      os.sleep(timeConstant) --waits for an estimated ammount game seconds
      realTimeNew = time()

      realTimeDiff = realTimeNew-realTimeOld

      tps = math.floor(20000*timeConstant/realTimeDiff)
      if(tps>0) then
        tps = 20
      end

      tps = tostring(tps)
      tpsText.setText("tps: " .. tostring(tps))
      os.sleep(1)
      --print("tick took " .. tostring(timeTaken))
    end
  end)
  print("TPS thread error: " .. tostring(err))
  print("Press CTRL+ALT+T to terminate program!")
end)