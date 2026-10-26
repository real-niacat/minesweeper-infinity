luis = require("luis.init")("luis/widgets")
luis.flux = require("luis.3rdparty.flux")
local lw = require("src.luis_wrapper")
print_table = require("src.print_table")
print() -- adds a newline in the console because for some reason love2d doesn't do that itself so it starts the first print on the same line as the `love foldername` command
-- ugh


local minesweeper = require("src.minesweeper")
MOD_API = require("src.mod_api")
local mods = require("src.mod_manager")
game = {}

--#region Menus

local larger_font_theme = {
    font = love.graphics.newFont(64, "normal"),
    color = {1, 1, 1},
    align = "center",
}


local menus = {
    main = {
        create_func = function(name, sx, sy)
            luis.newLayer(name)
            lw.newLabel {
                text = "lcl: minesweeper_infinity",
                width = 40,
                height = 1,
                x = 0,
                y = 5,
                theme = larger_font_theme,
                layer = name,
            }

            lw.newButton {
                text = "lcl: Play",
                width = 20,
                height = 5,
                on_release = function()
                    game.exclusive_enable_layer("play")
                end,
                x = 5,
                y = 10,
                layer = name,
            }

            lw.newButton {
                text = "lcl: options",
                width = 20,
                height = 5,
                on_release = function()
                    game.exclusive_enable_layer("options")
                end,
                x = 5,
                y = 17,
                layer = name,
            }

            lw.newButton {
                text = "lcl: mods",
                width = 20,
                height = 5,
                on_release = function()
                    game.exclusive_enable_layer("mods")
                end,
                x = 5,
                y = 24,
                layer = name,
            }
        end,
        default_enabled = true,
    }
}

function game.enable_layer(layer)
    luis.enableLayer(layer)
    if menus[layer].enable_func then
        menus[layer].enable_func(layer)
    end
end

function game.disable_layer(layer)
    luis.disableLayer(layer)
    if menus[layer].disable_func then
        menus[layer].disable_func(layer)
    end
end

function game.exclusive_enable_layer(layer)
    for name, menu in pairs(menus) do
        if name ~= layer then
            game.disable_layer(name)
        else
            game.enable_layer(name)
        end
    end
end

--#endregion

--#region luis functionality stuff

function love.load()
    love.window.setMode(1280, 1024)
    luis.setGridSize(math.floor(love.graphics.getWidth() / 40))
    for name, menu in pairs(menus) do
        menu.create_func(name)
        if menu.default_enabled then
            game.enable_layer(name)
        end
    end

end

function love.draw()
    luis.draw()
end

function love.mousepressed(x, y, button, istouch)
    luis.mousepressed(x, y, button, istouch)
end

function love.mousereleased(x, y, button, istouch)
    luis.mousereleased(x, y, button, istouch)
end

function love.keypressed(key)
    luis.keypressed(key)
end

local time = 0
function love.update(dt)
    time = time + dt
    if time >= 1 / 60 then
        luis.flux.update(time)
        time = 0
    end

    luis.update(dt)
end

--#endregion
