
--background
bg = display.newImage( "images/honeycomb-bg.png", display.contentWidth/2, display.contentHeight/2 )
bg.width=display.contentWidth
bg.height=display.contentHeight

local display_stage = display.getCurrentStage()
display_stage:insert( bg )


-- skeleton vars

local spine = require "spine-corona.spine"
local CBE=require("CBEffects.Library")
local powered = false
local json = spine.SkeletonJson.new()
json.scale = .5
local skeletonData = json:readSkeletonDataFile("animations/bee.json")

local skeleton = spine.Skeleton.new(skeletonData)
function skeleton:createImage (attachment)
	return display.newImageRect("animations/images/" .. attachment.name .. ".png",100,100)
end

skeleton.group.x = display.contentWidth/2
skeleton.group.y = display.contentHeight/2
skeleton.flipX = false
skeleton.flipY = false
skeleton.debug = false 

local stateData = spine.AnimationStateData.new(skeletonData)
local state = spine.AnimationState.new(stateData)
state:setAnimationByName(0, "rest", true, 0)



local function moveBee(event)

	if event.phase == "ended" then

		local stop = function(obj)
	    	powered = false
	    	if skeleton.flipX == false then
	    		skeleton.flipX = true
	    	else 
	    		skeleton.flipX = false
	    	end
	    	if skeleton.flipY == false then
	    		skeleton.flipY = true
	    	else
	    		skeleton.flipY = false
	    	end

	    		state:addAnimationByName(0,"rest",true,0)
		end
			
			if powered == true then
				transition.to(skeleton.group,{time=200,x=event.x,y=event.y,onComplete=stop})
			end
		end	
end

local function feed(event)

	--dispense pollen

	if event.phase == "ended" then

	powered = true
	
	spark=CBE.VentGroup{
		{
			preset="sparks",
			positionType="atPoint",
			x = skeleton.group.x,
			y = skeleton.group.y,
				build=function()
					local size=math.random(20, 40) 
					return display.newImageRect("images/pollen.png", size, size)
				end,
			onDeath=function()end, 
			perEmit=10,
			fadeInTime=100,
			emitDelay=1,
			physics={
				xDamping=1.02,
				gravityY=0.1,
				relativeToSize=false,
				velocity=3
					}
			}
		}
			
		spark:emit("sparks")

		state:setAnimationByName(0,"fly",true,0)

		return true

	end

end

skeleton.group:addEventListener("touch",feed)

local lastTime = 0
local animationTime = 0

Runtime:addEventListener("enterFrame", function (event)
	local currentTime = event.time / 100
	local delta = currentTime - lastTime
	lastTime = currentTime

	state:update(delta)
	state:apply(skeleton)
	skeleton:updateWorldTransform()
end)


bg:addEventListener("touch",moveBee)



