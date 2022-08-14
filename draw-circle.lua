-- Aseprite script to draw a circle at a specified (X,Y) with a given radius and fill option
-- Written by aquova, 2021, Modified 2022 by Dylmm
-- https://github.com/aquova/aseprite-scripts
-- https://github.com/Dylmm/aseprite-scripts

-- Open dialog, ask user for paramters
function userInput()
    local dlg = Dialog()
    -- Create dialog parameters
    dlg:number{ id="x", label="X:", decimals=0 }
    dlg:number{ id="y", label="Y:", decimals=0 }
    dlg:number{ id="radius", label="Radius:", decimals=0 }
    dlg:check{ id="fill", label="Fill:", selected=true }
    dlg:button{ id="ok", text="OK" }
    dlg:button{ id="cancel", text="Cancel" }
    dlg:show()
	
    return dlg.data
end

-- Draws the specified circle
function drawCircle(cx, cy, rad,fill)
    local image = app.activeCel.image
    local copy = image:clone()
    local left = cx - rad
    local top = cy - rad
    for x = left, left + 2 * rad do
        for y = top, top + 2 * rad do
            if (x >= 0 and x < copy.width) and (y >= 0 and y < copy.height) then
                local dx = cx - x
                local dy = cy - y
                dx = dx^2
                dy = dy^2
                distSquared = dx + dy
                radSquared = rad^2
                if fill then   
                    if distSquared <= radSquared then
                        copy:drawPixel(x, y, app.fgColor)
                    end
                else
                    if  distSquared + rad >= radSquared and distSquared - rad <= radSquared then
                        copy:drawPixel(x, y, app.fgColor)
                    end
                end 
            end
        end
    end
    app.activeCel.image:drawImage(copy)
end

-- Run script
do
    local userCircle = userInput()
    if userCircle.ok then
        drawCircle(userCircle.x, userCircle.y, userCircle.radius,userCircle.fill)
    end
end
