local defaultRotationX = 5
local defaultRotationY = -15

local rotationX = 15
local rotationY = -20

local camera = getCamera()

local function updateRotations()
	rotationX = 15
	if localPlayer.vehicle then
		local speed = math.min(1, localPlayer.vehicle.velocity:getLength() * 1.5)
		rotationX = defaultRotationX + speed * 20
	end
	local camX = camera.rotation.x + 180
	camX = -Utils.wrapAngle(camX) + 180
	local mul = camX / 80
	rotationY = defaultRotationY - mul * 20

	Speedometer.setRotation(rotationX, rotationY)
	Radar.setRotation(-rotationX, rotationY - 20)
end

addEventHandler("onClientResourceStart", resourceRoot, function ()
	setPlayerHudComponentVisible("all", false)

	Speedometer.start()
	Radar.start()
	addEventHandler("onClientPreRender", root, updateRotations)
end)
