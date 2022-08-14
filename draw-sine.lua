-- Aseprite script to draw a sine wave with specified wave frequency and amplitude dampening
-- Written by Dylmm, 2022
-- https://github.com/Dylmm/aseprite-scripts

-- Open dialog, ask user for paramters
function userInput()
    local dlg = Dialog()
    -- Create dialog parameters
    dlg:number{ id="wavefrequency", label="Wave Frequency:", decimals=2, text = "5"}
    dlg:number{ id="wavedampening", label="Wave Dampening:", decimals=2, text = "1" }
    dlg:check{ id="fill", label="Fill:", selected=true }
    dlg:button{ id="ok", text="OK" }
    dlg:button{ id="cancel", text="Cancel" }
    dlg:show()

    return dlg.data
end

-- Draws the specified sin wave
function drawSine(wavefrequency,wavedampening,fill)
    local image = app.activeCel.image
    local copy = image:clone()
    py = image.height / 2 
	for x = 0, image.width do
            if (x >= 0 and x < image.width) then
                ny= math.floor( math.sin(x/(image.width/(wavefrequency* 2 * math.pi))) * image.height ) / (2 * wavedampening) + image.height / 2 
                copy:drawPixel(x, ny, app.fgColor)
                if fill then
                    if ny < py then 
                        incrementdirection = 1
                    else
                        incrementdirection = -1
                    end

                    for fy = ny, py, incrementdirection do
                        copy:drawPixel(x, fy, app.fgColor)
                    end
                end
                py = ny
        end
    end
    app.activeCel.image:drawImage(copy)
end

-- Run script
do
    local userSine = userInput()
    if userSine.ok then
        drawSine(userSine.wavefrequency,userSine.wavedampening,userSine.fill)
    end
end
