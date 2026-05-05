local menu = {}
local buttons = {}
local font
local titleFont
local buttonHeight = 64
local margin = 16

local function makeButton(text, onClick)
    return { 
        text = text, 
        onClick = onClick, 
        x = 0, 
        y = 0, 
        w = 0, 
        h = 0 
    }
end

function menu:enter()
    -- Stop game music if coming from game state
    -- if game_Music then
    --     game_Music:stop()
    -- end
    -- menu_Music = love.audio.newSource('sounds/theme.mp3', 'stream')
    -- menu_Music:setVolume(0.5)
    -- menu_Music:play()

    -- Enter fullscreen mode
    love.window.setFullscreen(true) -- Starts game as fullscreen

    buttons = {}
    titleFont = assets.fonts.titleFont
    textFont = assets.fonts.textFont
    menuTextFont = assets.fonts.menuTextFont
    darkViolet = assets.palette.darkViolet
    mandarinRed = assets.palette.mandarinRed

    table.insert(buttons, makeButton("Start Game", function()
        Gamestate.switch(require 'states/game2')
    end))

    table.insert(buttons, makeButton("Load Game", function()
        Gamestate.switch(require 'states/loadGame')
    end))

    table.insert(buttons, makeButton("Settings", function()
        Gamestate.push(require 'states/settings')
    end))

    table.insert(buttons, makeButton("Quit", function()
        love.event.quit(0)
    end))

    gameloaded = false
end

function menu:leave()
    -- menu_Music:stop()
end

function menu:draw()
    -- Draw background
    drawBackground(assets.background2.background2, 0.00)

    -- Get Screen size
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()

    -- Get button Size
    local buttonWidth = width / 3
    local cursorY = 0
    local mouseX, mouseY = love.mouse.getPosition()

    -- Title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(darkViolet)
    local title = "Lay Waste"
    local titleWidth = titleFont:getWidth(title)
    love.graphics.print(title, (width - titleWidth) / 2, 200)

    -- Menu buttons
    love.graphics.setFont(menuTextFont)
    for _, i in ipairs(buttons) do
        local textWidth = menuTextFont:getWidth(i.text)
        local textHeight = menuTextFont:getHeight()
        local x = width - textWidth - 500 -- Places and aligns button to right center
        local y = (height - buttonHeight) / 2 + cursorY

        i.x, i.y, i.w, i.h = x, y, textWidth, buttonHeight

        local isHovered = mouseX >= x and mouseX <= x + textWidth
                    and mouseY >= y and mouseY <= y + buttonHeight

        if isHovered then
            love.graphics.setColor(mandarinRed)
        else
            love.graphics.setColor(darkViolet)
        end

        love.graphics.print(i.text, x, y + (buttonHeight - textHeight) / 2)

        love.graphics.setColor(1, 1, 1, 1)
        cursorY = cursorY + buttonHeight + margin
    end
end

function menu:mousepressed(x, y, mouseButton)
    if mouseButton ~= 1 then return end
    for _, b in ipairs(buttons) do
        if x >= b.x and x <= b.x + b.w and y >= b.y and y <= b.y + b.h then
            b.onClick()
            return
        end
    end
end

function menu:keypressed(key)
end

return menu
