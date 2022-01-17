-- Aseprite script to convert an image into the Pico-8 palette with Floyd-Steinberg dithering
-- Written by aquova, 2022
-- https://github.com/aquova/aseprite-scripts

PAL_ID = "PICO-8"

PICO8_PALETTE = {
    {r =   0, g =   0, b =   0},
    {r =  29, g =  43, b =  83},
    {r = 126, g =  37, b =  83},
    {r =   0, g = 135, b =  81},
    {r = 171, g =  82, b =  54},
    {r =  95, g =  87, b =  79},
    {r = 194, g = 195, b = 199},
    {r = 255, g = 241, b = 232},
    {r = 255, g =   0, b =  77},
    {r = 255, g = 163, b =   0},
    {r = 255, g = 236, b =  39},
    {r =   0, g = 228, b =  54},
    {r =  41, g = 173, b = 255},
    {r = 131, g = 118, b = 156},
    {r = 255, g = 119, b = 168},
    {r = 255, g = 204, b = 170},
}

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

    -- Set Pico-8 palette
    local spr = app.activeSprite
    local pal = Palette{ fromResource = PAL_ID }
    spr:setPalette(pal)

    for y = 0, copy.height - 1 do
        for x = 0, copy.width - 1 do
            -- Iterate over every pixel, finding closest Pico-8 color
            local p = copy:getPixel(x, y)
            local old = createRgbTable(p)
            local closest = findClosestColor(old)
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

-- Uses Euclidean distance to find closest matching palette color
function findClosestColor(p)
    local best_dist = 999999
    local best_idx = 0
    for k, v in pairs(PICO8_PALETTE) do
        local dist = colorDist(p, v)
        if dist < best_dist then
            best_dist = dist
            best_idx = k
        end
    end
    return PICO8_PALETTE[best_idx]
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
    convertImage()
end
