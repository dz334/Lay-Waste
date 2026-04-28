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

    -- Set map dimensions from the loaded map
    mapW = gamemap.width * gamemap.tilewidth
    mapH = gamemap.height * gamemap.tileheight

    createPlayer()
end

function createPlayer()
    player = {}
    player.x, player.y = 400, 300
    player.w, player.h = 32, 32
    player.vx, player.vy = 100, 0
    player.moveSpeed = 300
    player.jumpForce = 410
    player.gravity = 1100
    player.maxFallSpeed = 700
    player.isGrounded = false

    player.sprite = assets.placeholderChar.idle
end



function game:update(dt)
    if gamemap then 
        gamemap:update(dt) 
    end

    

    local moveX, moveY = 0, 0
    if love.keyboard.isDown("d") then 
        moveX = 1 
    end
    if love.keyboard.isDown("a") then 
        moveX = -1 
    end
    if love.keyboard.isDown("w") then 
        moveY = -1 
    end
    if love.keyboard.isDown("s") then 
        moveY = 1 
    end

    player.x = player.x + moveX * player.moveSpeed * dt
    player.y = player.y + moveY * player.moveSpeed * dt

     -- Follow player and clamp camera to map bounds
    cam:lookAt(player.x, player.y)
    local w = love.graphics.getWidth() / cam.scale
    local h = love.graphics.getHeight() / cam.scale
    cam.x = math.max(w/2, math.min(cam.x, mapW - w/2))
    cam.y = math.max(h/2, math.min(cam.y, mapH - h/2))

    -- Clamp player to map bounds
    player.x = math.max(player.w/2, math.min(player.x, mapW - player.w/2))
    player.y = math.max(player.h/2, math.min(player.y, mapH - player.h/2))

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

    love.graphics.print("px: " .. player.x .. " py: " .. player.y, 10, 16)
    love.graphics.print("mapW: " .. mapW .. " mapH: " .. mapH, 10, 30)

    cam:attach()
    if gamemap then
        gamemap:draw()
    end
    if player then
        -- use player.x/y directly, no collider
        love.graphics.draw(player.sprite, player.x - player.w/2, player.y - player.h/2, nil, 2.5)
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