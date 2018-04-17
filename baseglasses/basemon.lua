------------------------------------------------
--                By rater193                 --
------------------------------------------------



local config = {
    ["messageLifetimeInSeconds"] = 2,
    ["messageHeightOffset"] = 64
  }
  
  
  
  
  ------------------------------------------------
  --         Dont edit past this point          --
  ------------------------------------------------
  
  local component = require("component")
  local thread = require("thread")
  
  local glasses = component.glasses
  local messages = {}
  
  --Clearing the glasses
  glasses.removeAll()
  
  --Create variables and functions beyond this point
  local levels = {
    ["warn"] = {
      ["r"] = 255,
      ["g"] = 255,
      ["b"] = 0
    },
    ["info"] = {
      ["r"] = 255,
      ["g"] = 255,
      ["b"] = 255
    },
    ["error"] = {
      ["r"] = 255,
      ["g"] = 0,
      ["b"] = 0
    }
  }
  
  function createMessage(warnLevel, message)
    --Creating the new message
    local msg = {}
    msg.text = message
    msg.swingPlace = 0
    msg.state = "swingIn"
    msg.life = config.messageLifetimeInSeconds * 20
    
    --Creating all the glasses objects
    msg.storage = {}
    msg.storage.bgText = glasses.addRect()
    msg.storage.bgLevel = glasses.addRect()
    msg.storage.text = glasses.addTextLabel()
    
    --Updating the default positions
    msg.storage.bgText.setPosition(0,-24)
    msg.storage.bgLevel.setPosition(0,-24)
    msg.storage.text.setPosition(0,-24)
    
    --Updating the default sizes
    msg.storage.bgText.setSize(200,16)
    msg.storage.bgLevel.setSize(20,16)
    msg.storage.text.setScale(1,1)
    
    --Updating colors
    msg.storage.bgText.setColor(0,0,0)
    msg.storage.bgLevel.setColor(warnLevel.r, warnLevel.g, warnLevel.b)
    msg.storage.text.setColor(255,255,255)
    
    --Setting alphas
    msg.storage.bgText.setAlpha(0.5)
    msg.storage.bgLevel.setAlpha(1)
    msg.storage.text.setAlpha(1)
    
    --Setting text
    msg.storage.text.setText(message)
    
    table.insert(messages, msg)
  end
  
  function update()
    local _y = config.messageHeightOffset
    local indexesToRemove = {}
    for i, v in pairs(messages) do
      local _x = 0
      if(v.state=="swingIn") then
        _x = -224+v.swingPlace
        v.swingPlace = v.swingPlace + 16
        if(_x>=0) then
          _x = 0
          v.state = "wait"
        end
      elseif(v.state=="wait") then
        v.life = v.life-1
        if(v.life<=0) then
          v.state = "swingOut"
        end
      elseif(v.state=="swingOut") then
        v.swingPlace = v.swingPlace - 16
        _x = -224+v.swingPlace
        if(_x<=0) then
          --error.out.here
          table.insert(indexesToRemove, i)
        end
      end
      
      v.storage.bgText.setPosition(_x+20,_y)
      v.storage.bgLevel.setPosition(_x,_y)
      v.storage.text.setPosition(_x+24,_y+4)
      _y = _y+20
    end
    --Cleaning up expired messages
    for i, v in pairs(indexesToRemove) do
      local msg = messages[v]
      
      table.remove(messages, v)
    end
  end
  
  -------------------------------------------------------
  --            Debugging beyond this point            --
  -------------------------------------------------------
  thread.create(function()
    local debugText = glasses.addTextLabel()
    debugText.setText("Debug loading")
    debugText.setColor(255,255,255)
    debugText.setScale(1,1)
    debugText.setPosition(10,0)
    
    local frameCount = 200
    
    --Initial debug text
    createMessage(levels.warn, "This is a warning message")
    createMessage(levels.warn, "Test 2")
    
    while(frameCount>0) do
      debugText.setText("Messages: " .. tostring(#messages) .. ", Frames left: " .. tostring(frameCount) .. ", seconds: " .. tostring(frameCount/20))
      update()
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