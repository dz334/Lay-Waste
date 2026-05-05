local game = {}
local solids = {}
local BASE_W, BASE_H = 1920, 1080
local mapW, mapH = 0, 0
local signUIActive = false
local endUIActive = false
gameLoaded = false
elapsedTime = 0
anim8 = require 'Libraries/anim8'
camera = require 'Libraries/camera'
sti = require 'Libraries/sti'
-- wf = require 'Libraries/Physics/windfield'

function game:enter()
    gamemap = sti('Map/Level1.lua')
    cam = camera()

    textFont = assets.fonts.textFont

    mapW = gamemap.width * gamemap.tilewidth
    mapH = gamemap.height * gamemap.tileheight

    -- Set zoom so the camera scales in like a top-down game
    local screenW, screenH = love.graphics.getDimensions()
    --cam:zoom(math.min(screenW / 800, screenH / 600))  -- tune these values
    cam:zoom(2)

    createPlayer()
end

function createPlayer()
    player = {}
    player.x = 100 
    player.y = 2830
    player.w, player.h = 32, 32
    player.vx, player.vy = 100, 0
    player.moveSpeed = 300

    local char = assets.placeholderChar

    player.animation = {}

    -- Run animations
    player.runRightSheet = char.runRight
    player.runLeftSheet  = char.runLeft

    local runRightGrid = anim8.newGrid(32, 32, char.runRight:getWidth(), char.runRight:getHeight())
    local runLeftGrid  = anim8.newGrid(32, 32, char.runLeft:getWidth(),  char.runLeft:getHeight())

    player.animation.runRight = anim8.newAnimation(runRightGrid('1-5', 1), 0.07)
    player.animation.runLeft  = anim8.newAnimation(runLeftGrid('1-5', 1), 0.07)

    -- Idle
    player.idleRightSheet = char.idle
    player.idleLeftSheet  = char.idleL

    local idleRightGrid = anim8.newGrid(32, 32, char.idle:getWidth(), char.idle:getHeight())
    local idleLeftGrid  = anim8.newGrid(32, 32, char.idleL:getWidth(), char.idleL:getHeight())

    player.animation.idleRight = anim8.newAnimation(idleRightGrid('1-1', 1), 1)
    player.animation.idleLeft  = anim8.newAnimation(idleLeftGrid('1-1', 1), 1)

    -- Default state
    player.anim = player.animation.idleRight
    player.animSheet = player.idleRightSheet
    player.facingRight = true

end

function game:update(dt)
    if gamemap then 
        gamemap:update(dt) 
    end

    -- Read input
    moveX = 0
    moveY = 0
    if love.keyboard.isDown("a") or love.keyboard.isDown("left") then
        moveX = -1
        player.facingRight = false
    elseif love.keyboard.isDown("d") or love.keyboard.isDown("right") then
        moveX = 1
        player.facingRight = true
    end
    if love.keyboard.isDown("w") or love.keyboard.isDown("up") then
        moveY = -1
    elseif love.keyboard.isDown("s") or love.keyboard.isDown("down") then
        moveY = 1
    end

    -- Animation swap
    if moveX ~= 0 then
        if player.facingRight and player.anim ~= player.animation.runRight then
            player.anim = player.animation.runRight
            player.animSheet = player.runRightSheet
            player.anim:gotoFrame(1)
        elseif not player.facingRight and player.anim ~= player.animation.runLeft then
            player.anim = player.animation.runLeft
            player.animSheet = player.runLeftSheet
            player.anim:gotoFrame(1)
        end
    else
        if player.facingRight and player.anim ~= player.animation.idleRight then
            player.anim = player.animation.idleRight
            player.animSheet = player.idleRightSheet
            player.anim:gotoFrame(1)
        elseif not player.facingRight and player.anim ~= player.animation.idleLeft then
            player.anim = player.animation.idleLeft
            player.animSheet = player.idleLeftSheet
            player.anim:gotoFrame(1)
        end
    end

    player.anim:update(dt)

    -- Move player
    player.x = player.x + moveX * player.moveSpeed * dt
    player.y = player.y + moveY * player.moveSpeed * dt

    -- Player boundary clamp
    player.x = math.max(player.w/2, math.min(player.x, mapW - player.w/2))
    player.y = math.max(player.h/2, math.min(player.y, mapH - player.h/2))

    -- Follow player and clamp camera to map bounds
    cam:lookAt(player.x, player.y)
    local w = love.graphics.getWidth() / cam.scale
    local h = love.graphics.getHeight() / cam.scale
    cam.x = math.max(w/2, math.min(cam.x, mapW - w/2))
    cam.y = math.max(h/2, math.min(cam.y, mapH - h/2))

    -- X-Axis Clamp (Centers the map if the map is smaller than the screen)
    if mapW < w then
        cam.x = mapW / 2
    else
        cam.x = math.max(w/2, math.min(cam.x, mapW - w/2))
    end
    
    -- Y-Axis Clamp (Centers the map if the map is smaller than the screen)
    if mapH < h then
        cam.y = mapH / 2
    else
        cam.y = math.max(h/2, math.min(cam.y, mapH - h/2))
    end

end

function game:draw()
    cam:attach()
    if gamemap then
        gamemap:drawLayer(gamemap.layers["Ground"])
        gamemap:drawLayer(gamemap.layers["Enemies"])
        gamemap:drawLayer(gamemap.layers["House and Duck"])
    end
    
    if player then
        -- use player.x/y directly, no collider
        player.anim:draw(player.animSheet,player.x, player.y, nil, 1, nil, player.w / 2, player.h / 2)
    end
    cam:detach()
end

function game:leave()
    -- if game_Music then
    --     game_Music:stop()
    --     game_Music = nil
    -- end
end

function game:keypressed(key)
    if key == "escape" then
        Gamestate.push(pauseState)
    end
end

function game:mousepressed(x, y, button)

end

function game:resize(w, h)
    -- if cam then
    --     cam:zoom(math.min(w / BASE_W, h / BASE_H))
    -- end
end

return game