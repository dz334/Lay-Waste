assets = {}

function assets.load()
    -- Backgrounds
    assets.background1 = {
        sky = love.graphics.newImage('Tiles/Seaside/Background/Sky.png'),
        ocean = love.graphics.newImage('Tiles/Seaside/Background/Ocean.png'),
        sand = love.graphics.newImage('Tiles/Seaside/Background/Sand.png'),
        cloud1 = love.graphics.newImage('Tiles/Seaside/Background/Clouds_big.png'),
        cloud2 = love.graphics.newImage('Tiles/Seaside/Background/Clouds_medium.png'),
        cloud3 = love.graphics.newImage('Tiles/Seaside/Background/Clouds_small.png'),
        background = love.graphics.newImage('Tiles/Seaside/Background/background.png')
    }

    assets.background2 = {
        background = love.graphics.newImage('Tiles/background.png'),
        background2 = love.graphics.newImage('Tiles/background2.png')
    }

    -- assets.character1 = {
    --     idleLeft = love.graphics.newImage('Sprites/Character1/IdleLeft.png'),
    --     idleRight = love.graphics.newImage('Sprites/Character1/IdleRight.png'),

    --     jumpLeft = love.graphics.newImage('Sprites/Character1/JumpLeft.png'),
    --     jumpRight = love.graphics.newImage('Sprites/Character1/JumpRight.png'),

    --     runLeft = love.graphics.newImage('Sprites/Character1/RunLeft.png'),
    --     runRight = love.graphics.newImage('Sprites/Character1/RunRight.png'),

    --     fallLeft = love.graphics.newImage('Sprites/Character1/FallLeft.png'),
    --     fallRight = love.graphics.newImage('Sprites/Character1/FallRight.png'),
        
    --     doubleJumpLeft = love.graphics.newImage('Sprites/Character1/Double_Jump_Left.png'),
    --     doubleJumpRight = love.graphics.newImage('Sprites/Character1/Double_Jump_Right.png')
    -- }

    assets.placeholderChar = {
        idle = love.graphics.newImage('Sprites/Duck_Summoner.png'),
        idleL = love.graphics.newImage('Sprites/Duck_SummonerL.png'),
        runRight = love.graphics.newImage('Sprites/Duck_Summoner-run.png'),
        runLeft = love.graphics.newImage('Sprites/Duck_Summoner-runL.png')
    }

    assets.palette = {
        darkGreen = {love.math.colorFromBytes(78, 145, 3)},
        darkViolet = {love.math.colorFromBytes(70, 3, 145)},
        mandarinRed = {love.math.colorFromBytes(99,12,36)}
    }

    assets.fonts = {
        titleFont = love.graphics.newFont('Fonts/Perpetua-Font/Perpetua-Font/Perpetua-Titling-Bold.otf', 128),
        textFont = love.graphics.newFont('Fonts/Perpetua-Font/Perpetua-Font/Perpetua-Regular.otf', 32),
        menuTextFont = love.graphics.newFont('Fonts/Perpetua-Font/Perpetua-Font/Perpetua-Bold.otf', 64)
    }
end

return assets



