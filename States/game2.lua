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

    -- UI state
    ui = {}
    ui.hp = 100
    ui.maxHp = 100
    ui.mana = 80
    ui.maxMana = 100
    ui.showMap = true 
end

local function drawBar(x, y, w, h, value, max, fgColor, bgColor, isVertical)
    -- Background
    love.graphics.setColor(bgColor or {0, 0, 0})
    love.graphics.rectangle("fill", x, y, w, h)

    -- Foreground fill
    love.graphics.setColor(fgColor or {1, 1, 1})
    local pct = math.max(0, math.min(1, value / max))

    if isVertical then
        local fillH = h * pct
        love.graphics.rectangle("fill", x, y + (h - fillH), w, fillH)
    else
        local fillW = w * pct
        love.graphics.rectangle("fill", x, y, fillW, h)
    end

    love.graphics.setColor(1, 1, 1, 1)
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
        player.anim:draw(player.animSheet, player.x, player.y, nil, 1, nil, player.w / 2, player.h / 2)
    end
    cam:detach()

    local sw, sh = love.graphics.getDimensions()

    -- 1. Map button (top-left)
    if ui.showMap then
        love.graphics.setColor(0.2, 0.25, 0.2, 0.8)
        love.graphics.rectangle("fill", 20, 20, 80, 60)
        love.graphics.setColor(0.6, 0.7, 0.6, 1)
        love.graphics.setLineWidth(2)
        love.graphics.rectangle("line", 20, 20, 80, 60)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.printf("Map", 20, 40, 80, "center")
    end

    -- 2. HP Bar (bottom-left)
    local hpW, hpH = 250, 24
    local hpX, hpY = 20, sh - hpH - 20
    love.graphics.setFont(textFont)
    drawBar(hpX, hpY, hpW, hpH, ui.hp, ui.maxHp, {0.2, 0.8, 0.2}, {0.1, 0.1, 0.1})
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("HP", hpX, hpY - 18)

    -- 3. Mana / "Spite" Bar (right side, vertical)
    local manaW, manaH = 24, 250
    local manaX, manaY = sw - manaW - 20, (sh - manaH) / 2
    drawBar(manaX, manaY, manaW, manaH, ui.mana, ui.maxMana, {0.6, 0.4, 0.9}, {0.1, 0.1, 0.1}, true)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.printf("Spite", manaX - 80, manaY + manaH / 2 - 6, 70, "right")

    -- 4. Inventory Icon (bottom-right)
    local invSize = 48
    local invX, invY = sw - invSize - 20, sh - invSize - 20
    love.graphics.setColor(0.2, 0.15, 0.1, 0.9)
    love.graphics.rectangle("fill", invX, invY, invSize, invSize)
    love.graphics.setColor(0.8, 0.7, 0.5, 1)
    love.graphics.setLineWidth(2)
    love.graphics.rectangle("line", invX, invY, invSize, invSize)
    love.graphics.setColor(1, 1, 1, 1)
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