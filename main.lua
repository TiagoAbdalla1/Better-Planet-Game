--[[

This is the main.lua file. It executes first and in this demo
is sole purpose is to set some initial visual settings and
then you execute our game or menu scene via composer.

Composer is the official scene (screen) creation and management
library in Corona SDK. This library provides developers with an
easy way to create and transition between individual scenes.

https://docs.coronalabs.com/api/library/composer/index.html

-- ]]

require "scripts.service.global_functions"
-- Global table for systemwide objects and config
_GB = {}
_GB.timers = {}
_GB.enterframe_listeners = {}

-- Load all game libraries
_GB.audio = audio
_GB.composer = require('composer')


_GB.cx, _GB.cy      = display.contentCenterX, display.contentCenterY
_GB.w, _GB.h        = display.safeActualContentWidth, display.safeActualContentHeight
_GB.cw, _GB.ch      = display.contentWidth, display.contentHeight
_GB.ox, _GB.oy      = display.safeScreenOriginX, display.safeScreenOriginY

_GB.top             = _GB.oy
_GB.bottom          = _GB.top + _GB.h
_GB.left            = _GB.ox
_GB.right           = _GB.left + _GB.w

_GB.aspectRatio     = display.pixelHeight / display.pixelWidth

_GB.font = {"res/fonts/04B_03__.TTF"}


_GB.composer.recycleOnSceneChange = true

local composer = require "composer"
composer.recycleOnSceneChange = true

-- The default magnification sampling filter applied whenever an image is loaded by Corona.
-- Use "nearest" with a small content size to get a retro-pixel look
display.setDefault("magTextureFilter", "nearest")
display.setDefault("minTextureFilter", "linear")

-- Removes bottom bar on Android
if isAndroid then
  if system.getInfo( "androidApiLevel" ) and system.getInfo( "androidApiLevel" ) < 19 then
    native.setProperty( "androidSystemUiVisibility", "lowProfile" )
  else
    native.setProperty( "androidSystemUiVisibility", "immersiveSticky" )
  end
end

if isiOS then -- don't turn off background music, remove status bar on iOS
  display.setStatusBar( display.HiddenStatusBar )
  native.setProperty( "prefersHomeIndicatorAutoHidden", true )
  native.setProperty( "preferredScreenEdgesDeferringSystemGestures", true )
  audio.setSessionProperty(audio.MixMode, audio.AmbientMixMode)
end

-- reserve audio for menu and bgsound
local snd = require "com.ponywolf.ponysound"
snd:setVolume(0.75)
snd:batch("footstep", "click")
snd:loadMusic("snd/backGame2.wav")
--local musicMenu = audio.loadStream("snd/backMenu.wav")
--print(musicMenu)

-- go to menu screen
--display.setDefault("background", 0.2,0.2,0.2)
_GB.composer.gotoScene("scene.start")