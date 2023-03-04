local background = require "scripts.interface.background"
local composer = require "composer"
local scene = _GB.composer.newScene()
local snd = require "com.ponywolf.ponysound"

local guiGroup
local title, btnStart


-- create()
function scene:create( event )
   
    



    local sceneGroup = self.view
    sceneGroup.background = display.newGroup()
    sceneGroup.gui = display.newGroup()
    -- sceneGroup.effect = display.newGroup()
    title = display.newImageRect(sceneGroup.gui, "map/mainTitle.png", 140, 90)
    title.x, title.y = _GB.cx, _GB.cy - 20
    btnStartOutline = display.newRoundedRect(sceneGroup.gui, _GB.cx, _GB.h * 0.85, 81, 22, 11)
    btnStartOutline:setFillColor(0)
    btnStart = display.newRoundedRect(sceneGroup.gui, _GB.cx, _GB.h * 0.85, 80, 20, 10)
   
    btnStart:setFillColor(1)
    btnStart.lbl = display.newText(sceneGroup.gui, "INICIAR", btnStart.x, btnStart.y, _GB.font[1], 10)
   
    local function scaleBtn()
        btnStart.lbl.xScale = 1
        btnStart.lbl.yScale = 1
        btnStartOutline.xScale = 0.9
        btnStartOutline.yScale = 0.9
    end
 local function repeatLoop()
        transition.to( btnStart, { time=500, onComplete=scaleBtn } )
        transition.to( btnStart, { time=600, onComplete=repeatLoop } )
        local r = math.random(1, 150)
        local g = math.random(1, 150)
        local b = math.random(1, 150)
        btnStart.lbl:setFillColor("." .. r,"." .. g,"." .. b)
         --btnStart:setFillColor("." .. r,"." .. g,"." .. b)
         btnStart.lbl.xScale = 1.1
         btnStart.lbl.yScale = 1.1
         btnStartOutline.xScale = 1
         btnStartOutline.yScale = 1
        end
        repeatLoop()

    btnStart.lbl.alpha = 0
    btnStart.isDisable = false
   
    btnStart.touch = function (event)
        
      if ( event.phase == "began" ) then
        snd:play("click")
        if not btnStart.isDisable then
          btnStart.xScale = .9
          btnStart.yScale = .9
          btnStart:setFillColor(.7, .7, .7)
          btnStart.lbl:setFillColor(1)
          snd:panic()
        end
          -- Set touch focus
          display.getCurrentStage():setFocus( btnStart )
          btnStart.isFocus = true
      
      elseif ( btnStart.isFocus ) then
          if ( event.phase == "moved" ) then
  
          elseif ( event.phase == "ended" or event.phase == "cancelled" ) then
            if not btnStart.isDisable then
               
                btnStart.xScale = 1
                btnStart.yScale = 1
                btnStart:setFillColor(1, 1, 1)
                btnStart.lbl:setFillColor(0)
                btnStart.isDisable = true
                transition.to(btnStart.lbl, {time = 200, xScale = 0.03, yScale = 0.03, alpha = 0, transition = easing.inExpo, onComplete = function ()
                    screenFadeIn(function ()                      
                    --composer.gotoScene( "scene.game", { params={ map = "house" } } )
                        --_GB.composer.gotoScene(
                           -- "scene.game", { params={ map = "house" }}--"tutorial"}}
                          --  composer.gotoScene( "scene.game", { params={ map = "house" } } )
                       -- )
                        btnStart:removeEventListener("touch", btnStart.touch)
                    end)
                    transition.to(btnStart, {time = 500, x = - 200, transition = easing.inExpo})
                        composer.gotoScene( "scene.game" )
                   
                end})
            end
              -- Reset touch focus
              display.getCurrentStage():setFocus( nil )
              btnStart.isFocus = nil
          end
      end
      return true
    end
    background = background.new()
    
    sceneGroup.background:insert(background)
    sceneGroup:insert(sceneGroup.background)
    sceneGroup:insert(sceneGroup.gui)
end
 
 
-- show()
function scene:show( event )
    --snd:add("backMenu")
    
    local sceneGroup = self.view
    local phase = event.phase
    
    if ( phase == "will" ) then
        screenFadeOut(function ()
            snd:setVolume(0.25)
            snd:playMusic()
           
            btnStart:addEventListener("touch", btnStart.touch)
          
        end)
        transition.from(btnStart, {time = 800, x = - 200, transition = easing.outExpo, onComplete = function (obj)
            obj.lbl.alpha = 1
            transition.from(obj.lbl, {time = 200, xScale = 0.03, yScale = 0.03, transition = easing.outExpo})
            
          end})
    elseif ( phase == "did" ) then
        
    end
end
 
 
-- hide()
function scene:hide( event )
 
    local sceneGroup = self.view
    local phase = event.phase
 
    if ( phase == "will" ) then
    transition.cancelAll()
    
    elseif ( phase == "did" ) then
        background:destroy()
        
        --print("passou")
        

    end
end
 
 
-- destroy()
function scene:destroy( event )
 
    local sceneGroup = self.view

end
 
 
-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------
 
return scene