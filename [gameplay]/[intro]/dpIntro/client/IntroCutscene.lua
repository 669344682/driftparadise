IntroCutscene = {}
local screenWidth, screenHeight = guiGetScreenSize()

-- Точка, в которой находится камера
local currentCameraPosition = Vector3()
local targetCameraPosition = Vector3()
local cameraMovingSpeed = 0.1
-- Точка, в которую смотрит камера
local currentCameraLookPosition = Vector3()
local targetCameraLookPosition = Vector3()
local cameraLookMovingSpeed = 0.086
-- Field of View
local DEFAULT_CAMERA_FOV = 50
local currentCameraFOV = DEFAULT_CAMERA_FOV
local targetCameraFOV = DEFAULT_CAMERA_FOV
local cameraFOVSpeed = 2
-- Поворот камеры
local DEFAULT_CAMERA_ROLL = 0
local currentCameraRoll = DEFAULT_CAMERA_ROLL
local targetCameraRoll = DEFAULT_CAMERA_ROLL
local cameraRollSpeed = 20

local logoTexture
local logoWidth, logoHeight
local logoAnim = 0
local logoAnimTarget = 0
local logoAnimSpeed = 0
local textAnim = 0
local textAnimTarget = 0
local bgAnim = 0
local bgAnimTarget = 0
local bgAnimSpeed = 0
local creditsAnim = 0
local creditsAnimTarget = 0

local isSpaceEnabled = false

local font
local creditsFont
local bordersVisible = false
local bordersHeight = screenHeight / 10

local currentCreditsText = 1
local currentCreditsString = ""
local creditsTexts = {
	"intro_credits_1",
	"intro_credits_2",
	"intro_credits_3",
	"intro_credits_4"
}

local function update(deltaTime)
	deltaTime = deltaTime / 1000
	-- Плавное движение камеры в заданную точку
	currentCameraPosition = currentCameraPosition + 
		(targetCameraPosition - currentCameraPosition) * cameraMovingSpeed * deltaTime
	currentCameraLookPosition = currentCameraLookPosition + 
		(targetCameraLookPosition - currentCameraLookPosition) * cameraLookMovingSpeed * deltaTime
	currentCameraFOV = currentCameraFOV + (targetCameraFOV - currentCameraFOV) * cameraFOVSpeed * deltaTime
	currentCameraRoll = currentCameraRoll + (targetCameraRoll - currentCameraRoll) * cameraRollSpeed * deltaTime

	-- Реалистичная тряска камеры
	local shakeX = math.sin(getTickCount() / 740) * (math.sin(getTickCount() / 300) + 1) * 0.01
	local shakeY = math.cos(getTickCount() / 550) * (math.sin(getTickCount() / 300) + 1) * 0.01
	local shakeZ = math.sin(getTickCount() / 430) * (math.cos(getTickCount() / 600) + 1) * 0.03
	local cameraShakeOffset = Vector3(shakeX, shakeY, shakeZ)	

	-- Обновление позиции камеры
	Camera.setMatrix(
		currentCameraPosition - cameraShakeOffset / 4, 
		currentCameraLookPosition + cameraShakeOffset,
		currentCameraRoll,
		currentCameraFOV
	)

	logoAnim = logoAnim + (logoAnimTarget - logoAnim) * deltaTime * logoAnimSpeed
	textAnim = textAnim + (textAnimTarget - textAnim) * deltaTime * 2
	bgAnim = bgAnim + (bgAnimTarget - bgAnim) * deltaTime * bgAnimSpeed
	creditsAnim = creditsAnim + (creditsAnimTarget - creditsAnim) * deltaTime * 5
end

local function draw()
	if bordersVisible then
		dxDrawRectangle(0, 0, screenWidth, bordersHeight - bordersHeight * logoAnim * 2, tocolor(0, 0, 0, 255))
		dxDrawRectangle(0, screenHeight - bordersHeight + bordersHeight * logoAnim * 2, screenWidth, bordersHeight, tocolor(0, 0, 0, 255))
	end
	local colorMul = 0.3
	dxDrawRectangle(0, 0, screenWidth, screenHeight, tocolor(0, 0, 0, 100 * bgAnim))
	local w = logoWidth * (logoAnim * 0.1 + 0.9)
	local h = logoHeight * (logoAnim * 0.1 + 0.9)
	dxDrawImage(
		screenWidth / 2 - w / 2, 
		screenHeight * 0.55 - h / 2, 
		w, 
		h, 
		logoTexture,
		0, 0, 0,
		tocolor(255, 255, 255, 255 * logoAnim))

	dxDrawText(exports.dpLang:getString("intro_press_to_start"), 
		0, screenHeight * 0.45, screenWidth, screenHeight * 0.85,
		tocolor(255, 255, 255, 255 * textAnim),
		1, font,
		"center", "bottom")

	dxDrawText(currentCreditsString, 
		0, 0, screenWidth, screenHeight,
		tocolor(255, 255, 255, 255 * creditsAnim),
		1, creditsFont,
		"center", "center")	

	local hh, mm = getTime()
	if hh <= 14 and hh >= 3 and mm > 0 then
		setTime(3, 0)
		setMinuteDuration(1000 * 60 * 60)
	end
end

local function preLogo()
	cameraFOVSpeed = 0.1
	targetCameraFOV = 40
	bgAnimTarget = 1
end

local function showCredits()
	creditsAnimTarget = 1
	currentCreditsString = utf8.upper(exports.dpLang:getString(creditsTexts[currentCreditsText]))

	local hideTime = 3000
	setTimer(function ()
		creditsAnimTarget = 0
	end, hideTime, 1)
	if currentCreditsText < #creditsTexts then
		setTimer(function ()
			currentCreditsText = currentCreditsText + 1
			showCredits()
		end, hideTime + 1000, 1)
	end
end

local function showLogo()
	isSpaceEnabled = true
	logoAnimTarget = 1
	cameraFOVSpeed = 2
	targetCameraFOV = 60

	setTimer(function ()		
		textAnimTarget = 1
	end, 2500, 1)
end

local function gotoSkinSelection()
	if not isSpaceEnabled then
		return
	end
	unbindKey("space", "down", gotoSkinSelection)
	textAnimTarget = 0
	logoAnimTarget = 0
	creditsAnimTarget = 0
	bgAnimTarget = 0
	bordersVisible = false
	logoAnimSpeed = 2
	bgAnimSpeed = 2
	setTimer(function ()
		IntroCutscene.stop()
		exports.dpSkinSelect:show()
	end, 2000, 1)
end

function IntroCutscene.start()
	isSpaceEnabled = false

	logoAnimSpeed = 0.5
	bgAnimSpeed = 0.2

	logoTexture = exports.dpAssets:createTexture("logo_red.png")
	local textureWidth, textureHeight = dxGetMaterialSize(logoTexture)
	logoWidth = screenWidth * 0.6
	logoHeight = logoWidth

	font = exports.dpAssets:createFont("Roboto-Regular.ttf", 18)
	creditsFont = exports.dpAssets:createFont("Roboto-Regular.ttf", 36)

	exports.dpTime:forceTime(15, 0)
	setMinuteDuration(500)
	setGameSpeed(10)

	addEventHandler("onClientPreRender", root, update)
	addEventHandler("onClientRender", root, draw)

	currentCameraPosition = Vector3 { x =  558.043, y = -966.229, z = 106.204 }
	targetCameraPosition = Vector3 { x = 1141.950, y = -1092.399, z = 60.909 } 
	currentCameraLookPosition = Vector3 { x =  558.043, y = -966.229, z = 0 }
	targetCameraLookPosition = Vector3 { x = 1347.834, y = -1160.533, z = 109.864  }
	cameraMovingSpeed = 0.08
	cameraLookMovingSpeed = 0.06

	bindKey("space", "down", gotoSkinSelection)

	setTimer(showCredits, 3000, 1)
	setTimer(preLogo, 18000, 1)
	setTimer(showLogo, 22000, 1)

	bordersVisible = true
end

function IntroCutscene.stop()
	unbindKey("space", "down", gotoSkinSelection)	
	setGameSpeed(1)
	removeEventHandler("onClientPreRender", root, update)
	removeEventHandler("onClientRender", root, draw)

	if isElement(logoTexture) then
		destroyElement(logoTexture)
	end

	if isElement(font) then
		destroyElement(font)
	end

	localPlayer:setData("activeUI", false)
end