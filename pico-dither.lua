-- Aseprite script to convert an image into the Pico-8/Picotron palette with Floyd-Steinberg dithering
-- Written by aquova, 2022-2026
-- https://github.com/aquova/aseprite-scripts

PALETTE = {
    0x000000,
    0x1d2b53,
    0x7e2553,
    0x008751,
    0xab5236,
    0x5f574f,
    0xc2c3c7,
    0xfff1e8,
    0xff004d,
    0xffa300,
    0xffec27,
    0x00e436,
    0x29adff,
    0x83769c,
    0xff77a8,
    0xffccaa,
    0x2463b0,
    0x00a5a1,
    0x654688,
    0x125359,
    0x742f29,
    0x452d32,
    0xa28879,
    0xffacc5,
    0xb9003e,
    0xe26b02,
    0x95f042,
    0x00b251,
    0x64dff6,
    0xbd9adf,
    0xe40dab,
    0xff8557,
}

PICO8 = true

-- Prompt user for which platform they prefer
function userInput()
    local dlg = Dialog()

    dlg:combobox{
        id="platform",
        label="Which system palette to use? ",
        option="Pico-8",
        options={"Pico-8", "Picotron"},
    }
    dlg:button{ id="ok", text="Select" }
    dlg:show()

    return dlg.data
end

function convertImage()
    -- Get the current image
    local img = app.activeCel.image

    -- Ensure image is RGBA
    if img.colorMode ~= ColorMode.RGB then
        local dlg = Dialog("Pico-8 Dithering")
        dlg:label{ label="Error:", text="The image must be in RGB color mode for the script to operate" }
        dlg:button{ text="OK" }
        dlg:show()
        return
    end

    -- Duplicate image into our buffer
    local copy = img:clone()

    -- Set specified palette
    local spr = app.activeSprite
    local pal = createPalette()
    spr:setPalette(pal)

    for y = 0, copy.height - 1 do
        for x = 0, copy.width - 1 do
            -- Iterate over every pixel, finding closest Pico-8 color
            local p = copy:getPixel(x, y)
            local old = createRgbTable(p)
            local closest = hex2rgb(findClosestColor(old))
            local err = sub(old, closest)

            local packed = app.pixelColor.rgba(closest.r, closest.g, closest.b, 0xFF)
            copy:drawPixel(x, y, packed)

            -- Apply any error to neighboring pixels
            if (x + 1) < copy.width then
                applyError(copy, x + 1, y, err, 7.0 / 16.0)
            end

            if 0 <= (x - 1) and (y + 1) < copy.height then
                applyError(copy, x - 1, y + 1, err, 3.0 / 16.0)
            end

            if (y + 1) < copy.height then
                applyError(copy, x, y + 1, err, 5.0 / 16.0)
            end

            if (x + 1) < copy.width and (y + 1) < copy.height then
                applyError(copy, x + 1, y + 1, err, 1.0 / 16.0)
            end
        end
    end

    img:drawImage(copy)
end

-- Creates a new palette from the tables above
function createPalette()
    local len = PICO8 and 16 or 32
    local pal = Palette(len)
    for i = 1, len do
        local v = hex2rgb(PALETTE[i])
        local color = app.pixelColor.rgba(v.r, v.g, v.b, 0xFF)
        pal:setColor(i - 1, color)
    end
    return pal
end

-- Uses Euclidean distance to find closest matching palette color
function findClosestColor(p)
    local best_dist = 999999
    local best_idx = 0
    local pal_len = PICO8 and 16 or 32
    for i = 1, pal_len do
        local dist = colorDist(p, hex2rgb(PALETTE[i]))
        if dist < best_dist then
            best_dist = dist
            best_idx = i
        end
    end
    return PALETTE[best_idx]
end

-- Calculates the square of Euclidean distance
function colorDist(a, b)
    return ((a.r - b.r) ^ 2) + ((a.g - b.g) ^ 2) + ((a.b - b.b) ^ 2)
end

-- Converts 32-bit color value into Lua RGB table
function createRgbTable(p)
    local r = app.pixelColor.rgbaR(p)
    local g = app.pixelColor.rgbaG(p)
    local b = app.pixelColor.rgbaB(p)

    return {r = r, g = g, b = b}
end

-- Converts a 24-bit color hex value into a Lua RGB table
function hex2rgb(_hex)
    local r = (_hex & 0xFF0000) >> 16
    local g = (_hex & 0xFF00) >> 8
    local b = _hex & 0xFF

    return {r = r, g = g, b = b}
end

-- Applies Floyd-Steinberg dithering error to neighboring pixels
function applyError(img, x, y, err, percent)
    local nr = img:getPixel(x, y)
    local n = createRgbTable(nr)
    local nc = add(n, mul(err, percent))
    local np = app.pixelColor.rgba(clamp(nc.r), clamp(nc.g), clamp(nc.b), 0xFF)
    img:drawPixel(x, y, np)
end

-- Addition of two Lua RGB tables
function add(a, b)
    return {r = a.r + b.r, g = a.g + b.g, b = a.b + b.b}
end

-- Subtraction of two Lua RGB tables
function sub(a, b)
    return {r = a.r - b.r, g = a.g - b.g, b = a.b - b.b}
end

-- Multiplication of a Lua RGB table with a scalar
function mul(a, val)
    return {r = a.r * val, g = a.g * val, b = a.b * val}
end

-- Clamps value between 0 and 255
function clamp(v)
    if v < 0 then
        return 0
    elseif v > 0xFF then
        return 0xFF
    else
        return v
    end
end

do
    local palette = userInput()
    if palette.ok then
        local pal = palette.platform
        if pal ~= "Pico-8" then
            PICO8 = false
        end
        convertImage()
    end
end
