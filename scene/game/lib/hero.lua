-- Module/class for hero

-- Use this as a template to build an in-game hero
local composer = require "composer"
local json = require "json"
local app = require "app"

local fx = require "com.ponywolf.ponyfx"
local snd = require "com.ponywolf.ponysound"

physics.setDrawMode( "hybrid" )
local test = "desconectado"


-- Define module
local M = {}
local sqrt = math.sqrt
local function len(dx, dy)
  return sqrt(dx * dx + dy * dy)
end

function M.new(player, options)
  options = options or {}
  -- Get the current scene
  local scene = composer.getScene("scene.game")

  -- Store map placement and hide placeholder
  local parent = scene.world:findLayer("game")
  local x, y = player.x, player.y
  display.remove(player)

  -- load frame animation
  local playerSheetOptions = options.playerSheetOptions or { width = 16, height = 16, numFrames = 12 }
  local playerSheet = graphics.newImageSheet("img/player.png", playerSheetOptions)
  local sequences = require("scene.game.lib.animations")[options.animations or "hero"]

  -- Build hero's view
  player = display.newGroup()
  player.sprite = display.newSprite(playerSheet, sequences)
  player:insert(player.sprite)
  player.sprite.anchorY = 0.6
  player.sprite:translate(0,2)
  player.sprite:play()
  fx.breath(player.sprite)
  parent:insert(player)
  player.x, player.y = x, y

  -- vars
  player.name = "hero"
  player.phase = "idle"
  player.speed = 10 -- walk speed based on physics sim

  -- Add physics
  physics.addBody(player, "dynamic", { radius = 8, density = 1.2, bounce = 0, friction =  1})
  player.isFixedRotation = true
  player.linearDamping = 15

  local adx, ady, oadx, oady = 0,0,0,0

  local deadZone = 0.50
  local function axis(event)
    local scene = composer.getScene("scene.game")
    if scene and scene.isDead then
      player.dx, player.dy = 0,0
      return true
    end

    local axis = event.axis
    local number = axis.number or 0
    adx, ady = oadx, oady

    if number > 2 then return false end

    -- read axis
    if axis.type:find("X") then
      adx = math.max(-1.0, math.min(1.0, event.normalizedValue or 0))
    elseif axis.type:find("Y") then
      ady = math.max(-1.0, math.min(1.0, event.normalizedValue or 0))
    end

    oadx, oady = adx, ady
  end

  local lastPhase, lastKeyName, nx, ny, ox, oy = nil, nil, 0, 0, 0, 0
   local function key(event)
    local phase, keyName = event.phase, event.keyName
   -- print(test)
    -- buttons
    if phase == "down" then
      if (keyName == "buttonA" or keyName == "button1" or keyName == "space" ) then
        
        if test == "conectado" and juntaPivo2.isActive == true  then
        
          --coliJunta()
         
        juntaPivo2:removeSelf()
      
        --display.remove(juntaPivo2)
        end
       
      elseif (keyName == "buttonB" or keyName == "button2" or keyName == "leftControl" ) then
        if test == "desconectado" then
         --local juntaPivo2 = physics.newJoint ("pivot", other, player, player.x-10,player.y -10)
        end

      end
    end
  end

  function player:setSequence(sequence)
    if self.sprite and self.sprite.setSequence then
      self.sequence = sequence or self.sequence or "idle"
      self.sprite:setSequence(self.sequence)
    end
  end
  player:setSequence()

  function player:hide()
    self.isVisible = false
    self.shadow.isVisible = false
  end

  function player:show()
    self.isVisible = true
    self.shadow.isVisible = true
  end

  function player:hurt()
  end

  function player:die()
  end

  function player:pause()
    self.paused = true
  end

  function player:resume()
    self.paused = false
  end

  function player:preCollision(event)
    local other = event.other
  end

  function player:collision(event)
    local phase = event.phase
    local other = event.other
   -- print(phase, other.name)
    if phase == "began" then
      if other.name == "object" or other.name == "saco de lixo" or other.name == "garrafa pet" then
        object = other.name
        --print(object)
        timer.performWithDelay(30,
        function()
          juntaPivo2 = physics.newJoint( "distance", other, player , other.x +2,other.y+2,player.x+2,player.y+2)
          test = "conectado"
         
         -- juntaPivo2 = physics.newJoint ("pivot", other, player, player.x-10,player.y -10)
          --print(juntaPivo2.isActive)
           --key(event)
        end, 1)
       
      --juntaPivo2:removeSelf()
      end
      --elseif phase == "ended" then
      --  if other.name == "hero" then
      -- hero left us
      --  end
      --end
    end
  end

  player.frameCount = 0
  local function enterFrame(event)

    -- shadow
    if player.shadow and player.shadow.translate then
      player.shadow.x, player.shadow.y = player.x, player.y + 7.5
      player.shadow.isVisible = player.isVisible
    else
      local scene = composer.getScene("scene.game")
      if scene then
        player.shadow = display.newImage(scene.world:findLayer("shadow"), "img/shadow.png")
      end
    end

    if scene.isPaused then return false end

    -- frameCount
    player.frameCount = (player.frameCount or 0) + 1

    -- new arrow keys
    local dx,dy = 0, 0

    local kdx, kdy = 0,0
    if app.keyStates["up"] then kdy = kdy - 1 else kdy = kdy + 1 end
    if app.keyStates["down"] then kdy = kdy + 1 else kdy = kdy - 1  end
    if app.keyStates["left"] then kdx = kdx - 1 else kdx = kdx + 1 end
    if app.keyStates["right"] then kdx = kdx + 1 else kdx = kdx - 1 end

    dx = dx + kdx
    dy = dy + kdy

    dx = dx + adx
    dy = dy + ady

    -- force 8-way movement
    local a = math.deg(math.atan2(dy,dx))
    local v = len(dx, dy) < deadZone and 0 or 1
    a = math.rad(math.floor((a+22.5)/45) * 45)
    dx, dy = math.max(-1.0, math.min(math.cos(a) * v, 1.0)), math.max(math.min(math.sin(a) * v, 1.0), -1.0)

    if not player.ignoreInput then
      player.dx, player.dy = dx, dy
    end

    -- check if our physics body has been deleted
    if player.applyForce then
      -- Move it
      if not player.paused then
        local speed = player.speed or 20
        player:applyForce(speed * (player.dx or 0), speed * (player.dy or 0), player.x, player.y)
      end

      -- set walking animation
      local vx, vy = player:getLinearVelocity()
      local newSequence = "idleSouth"
      if vx < -20 then
        newSequence = "walkWest"
      elseif vx > 20 then
        newSequence = "walkEast"
      elseif vy < -20 then
        newSequence = "walkNorth"
      elseif vy > 20 then
        newSequence = "walkSouth"
      end

      if math.abs(vx) < 3 and math.abs(vy) < 3 then -- we are idle
        newSequence = newSequence:gsub("walk", "idle")
      else
        -- step sound
        if player.frameCount % 27 == 1 then snd:play("footstep") end
      end

      if newSequence and player.sequence ~= newSequence then
        player:setSequence(newSequence)
        player.sprite:play()
      end
    end
  end

  function player:finalize()
    -- On remove, cleanup player, or call directly for non-visual
    display.remove(self.shadow)
    player:removeEventListener("preCollision")
    player:removeEventListener("collision")
    Runtime:removeEventListener("enterFrame", enterFrame)
    Runtime:removeEventListener("axis")
    Runtime:removeEventListener("key")
  end

-- Add a finalize listener (for display objects only, comment out for non-visual)
  player:addEventListener("finalize")

-- Add our enterFrame listener
  Runtime:addEventListener("enterFrame", enterFrame)


-- Add our joystick listeners
  Runtime:addEventListener("axis", axis)
  Runtime:addEventListener("key", key)

-- Add our collision listeners
  player:addEventListener("preCollision")
  player:addEventListener("collision")

  return player
end

return M