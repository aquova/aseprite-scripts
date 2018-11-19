-- Aseprite Script to show color compliment of given color
-- Written by aquova, 2018
-- https://github.com/aquova/aseprite-scripts

-- Open dialog, ask user for color
function userInput()
    local dlg = Dialog()
    -- Creates a starting color of black
    local defaultColor = Color{r=0, g=0, b=0, a=255}
    dlg:color{ id="color", label="Choose a color", color=defaultColor }
    dlg:button{ id="ok", text="OK" }
    dlg:button{ id="cancel", text="Cancel" }
    dlg:show()

    return dlg.data
end

function generateCompliment(color)
    local newHue = (color.hsvHue + 180) % 360
    local newCol = Color{h=newHue, s=color.hsvSaturation, v=color.hsvValue}
    return newCol
end

-- Generates the color gradiants and displays them
function showOutput(color)
    local dlg = Dialog()
    local newColor = generateCompliment(color)
    dlg:color{ color=newColor }
    dlg:button{ id="ok", text="OK" }
    dlg:show()
end

-- Run script
do
    local userColor = userInput()
    if userColor.ok then
        local c = Color{r=userColor.color.red, g=userColor.color.green, b=userColor.color.blue, a=userColor.color.alpha}
        showOutput(c)
    end
end
