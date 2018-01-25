-- Экран конфигурации компонента
ConfigurationScreen = Screen:subclass "ConfigurationScreen"
local screenSize = Vector2(guiGetScreenSize())

local menuInfos = {}
menuInfos["Suspension"] = {position = Vector3(2914.6, -3183.3, 2535.3), angle = 20, header="garage_tuning_config_suspension", label="garage_tuning_config_suspension_label"}
menuInfos["WheelsSize"] = {position = Vector3(2914.6, -3183.8, 2535.3), angle = 20, header="garage_tuning_config_wheels_size", label="garage_tuning_config_wheels_size_label"}

function ConfigurationScreen:init(dataName)
	self.super:init()

	local menuInfo = menuInfos[dataName]
	self.menu = SliderMenu(
		exports.dpLang:getString(menuInfo.header),
		exports.dpLang:getString(menuInfo.label),
		menuInfo.position,
		menuInfo.angle
	)
	self.vehicle = GarageCar.getVehicle()
	self.dataName = dataName
	self.dataType = "tuning"
	local price = 0
	if self.dataName == "Suspension" then
		self.applyForce = true
		self.dataType = "handling"

		price = unpack(exports.dpShared:getTuningPrices("suspension"))
	elseif self.dataName == "WheelsSize" then
		price = unpack(exports.dpShared:getTuningPrices("wheels_size"))
	end
	self.menu.price = price
	self.configurationIndex = configurationIndex
	self.menu:setValue(GarageCar.getVehicle():getData(dataName))
	CameraManager.setState("preview" .. tostring(dataName), false, 3)
end

function ConfigurationScreen:draw()
	self.super:draw()
	self.menu:draw(self.fadeProgress)
end

function ConfigurationScreen:update(deltaTime)
	self.super:update(deltaTime)
	if self.dataName then
		if getKeyState("arrow_r") then
			self.menu:increase(deltaTime)
		elseif getKeyState("arrow_l") then
			self.menu:decrease(deltaTime)
		end	

		if self.dataType == "handling" then
			GarageCar.previewHandling(self.dataName, self.menu:getValue())
		else
			GarageCar.previewTuning(self.dataName, self.menu:getValue())
		end
	end
	if self.applyForce then
		if getKeyState("arrow_r") then
			self.vehicle.velocity = Vector3(0, 0, 0.005)
		elseif getKeyState("arrow_l") then			
			self.vehicle.velocity = Vector3(0, 0, -0.005)
		end
	end
end

function ConfigurationScreen:onKey(key)
	self.super:onKey(key)
	
	if key == "backspace" then
		GarageCar.resetTuning()
		self.dataName = nil
		self.screenManager:showScreen(ConfigurationsScreen(self.dataName))
	elseif key == "enter" then	
		local name = "suspension"
		if self.dataName == "WheelsSize" then
			name = "wheels_size"
		end
		
		local this = self
		local price, level = unpack(exports.dpShared:getTuningPrices(name))
		Garage.buy(price, level, function(success)	
			if success then
				if this.dataType == "handling" then
					GarageCar.applyHandling(this.dataName)
				else
					GarageCar.applyTuning(this.dataName)
				end
				GarageCar.save()
			else
				GarageCar.resetTuning()
				self.dataName = nil
			end
			self.screenManager:showScreen(ConfigurationsScreen(self.dataName))
		end)
	end
end