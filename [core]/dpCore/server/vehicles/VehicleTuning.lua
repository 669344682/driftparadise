VehicleTuning = {}

VehicleTuning.defaultTuningTable = {
	-- Цвета
	BodyColor 		= {212, 0, 40},		-- Цвет кузова
	WheelsColorR 	= {255, 255, 255},	-- Цвет задних дисков
	WheelsColorF 	= {255, 255, 255},	-- Цвет передних дисков
	BodyTexture 	= false,			-- Текстура кузова
	NeonColor 		= false,			-- Цвет неона
	SpoilerColor	= false,			-- Цвет спойлера

	-- Дополнительно
	Numberplate 	= "DRIFT", 	-- Текст номерного знака
	Nitro 			= 0, -- Уровень нитро
	Windows			= 0, -- Тонировка окон	

	-- Колёса
	WheelsAngleF 	= 0, -- Развал передних колёс
	WheelsAngleR 	= 0, -- Развал задних колёс
	WheelsSize		= 0.69, -- Размер 
	WheelsWidthF 	= 0, -- Толщина передних колёс
	WheelsWidthR	= 0, -- Толщина задних колёс
	WheelsOffsetF	= 0, -- Вынос передних колёс
	WheelsOffsetR	= 0, -- Вынос задних колёс
	WheelsF 		= 0, -- Передние диски
	WheelsR 		= 0, -- Задние диски

	-- Компоненты
	Spoilers 		= 0, -- Спойлер	
	FrontBump		= 0, -- Задний бампер
	RearBump		= 0, -- Передний бампер
	SideSkirts		= 0, -- Юбки
	Bonnets			= 0, -- Капот
	RearLights		= 0, -- Задние фары
	FrontFends		= 0, -- Передние фендеры
	RearFends		= 0, -- Задние фендеры
	Exhaust			= 0, -- Глушитель
	Acces			= 0, -- Аксессуары

	-- Настройки
	Suspension 		= 0.4, -- Высота подвески

	-- Улучшения
	StreetHandling 	= 0, -- Уровень стрит-хандлинга
	DriftHandling  	= 0, -- Уровень дрифт-хандлинга
}

function VehicleTuning.applyToVehicle(vehicle, tuningJSON, stickersJSON)
	if not isElement(vehicle) then
		return false
	end

	-- Тюнинг
	pcall(function ()
		local tuningTable
		if type(tuningJSON) == "string" then
			tuningTable = fromJSON(tuningJSON)
		end
		if not tuningTable then
			tuningTable = {}
		end
		-- Размер колёс по-умолчанию
		if not tuningTable["WheelsSize"] then
			tuningTable["WheelsSize"] = exports.dpVehicles:getModelDefaultWheelsSize(vehicle.model)
		end
		-- Выставление полей по-умолчанию
		for k, v in pairs(VehicleTuning.defaultTuningTable) do
			if not tuningTable[k] then
				tuningTable[k] = v
			end
		end
		-- Перенос тюнинга в дату
		for k, v in pairs(tuningTable) do
			vehicle:setData(k, v)
		end
	end)

	-- Наклейки
	pcall(function ()
		local stickersTable
		if type(stickersJSON) == "string" then
			stickersTable = fromJSON(stickersJSON)
		end
		if not stickersTable then
			stickersTable = {}
		end
		vehicle:setData("stickers", stickersTable)
	end)
end

function VehicleTuning.updateVehicleTuning(vehicleId, tuning, stickers)
	if not vehicleId then
		return false
	end
	local update = {}
	if tuning then
		local tuningJSON = toJSON(tuning)
		if tuningJSON then
			update.tuning = tuningJSON
		end		
	end
	if stickers then
		local stickersJSON = toJSON(stickers)
		if stickersJSON then
			update.stickers = stickersJSON
		end			
	end

	return UserVehicles.updateVehicle(vehicleId, update)
end