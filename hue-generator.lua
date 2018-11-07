-- Aseprite Script to open dialog to select hues between two colors
-- Written by aquova, 2018
-- https://github.com/aquova/aseprite-scripts

-- Open dialog, ask user for two colors
function userInput()
    local dlg = Dialog()
    -- Creates a starting color of black
    local defaultColor = Color{r=0, g=0, b=0, a=255}
    dlg:color{ id="color1", label="Choose two colors", color=defaultColor }
    dlg:color{ id="color2", color=defaultColor }
    dlg:slider{ id="num_hues", label="Number of colors to generate: ", min=3, max=9, value=3 }
    dlg:button{ id="ok", text="OK" }
    dlg:button{ id="cancel", text="Cancel" }
    dlg:show()

    return dlg.data
end

-- Generates the color gradiants and displays them
function showOutput(color1, color2)
    local dlg = Dialog()
    -- Find the slopes of each component of both colors
    local m = {
        r=(color1.red - color2.red),
        g=(color1.green - color2.green),
        b=(color1.blue - color2.blue),
        a=(color1.alpha - color2.alpha)
    }

    for i=0,numHues do
        -- Linearly find the colors between the two initial colors
        local newRed = color1.red - math.floor(m.r * i / numHues)
        local newGreen = color1.green - math.floor(m.g * i / numHues)
        local newBlue = color1.blue - math.floor(m.b * i / numHues)
        local newAlpha = color1.alpha - math.floor(m.a * i / numHues)

        local newC = Color{r=newRed, g=newGreen, b=newBlue, a=newAlpha}
        -- Put every entry on a new row
        dlg:newrow()
        dlg:color{ color=newC }
    end
    dlg:button{ id="ok", text="OK" }
    dlg:show()
end

-- Run script
do
    local color = userInput()
    if color.ok then
        -- Number of hues generated does not include initial colors
        numHues = color.num_hues + 1
        local c1 = Color{r=color.color1.red, g=color.color1.green, b=color.color1.blue, a=color.color1.alpha}
        local c2 = Color{r=color.color2.red, g=color.color2.green, b=color.color2.blue, a=color.color2.alpha}
        showOutput(c1, c2)
    end
end
