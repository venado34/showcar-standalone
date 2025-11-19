-- Ensure the configuration file is loaded
if Config == nil then
    print('showcar-standalone: Error! Config not loaded.')
    return
end

-- Table to hold vehicle handles created by the script
local showVehicles = {}

-- Function to set Livery and Extras
local function SetVehicleCustomization(vehicle, data)
    -- APPLY LIVERY
    if data.livery and data.livery >= 0 then
        local livery_id = tonumber(data.livery)
        -- Check if the livery ID is valid for the vehicle model
        if GetVehicleLiveryCount(vehicle) >= livery_id then
            SetVehicleLivery(vehicle, livery_id)
        end
    end

    -- APPLY EXTRAS (USING INVERTED LOGIC: TRUE=0, FALSE=1 for the specific custom model)
    if data.extras and type(data.extras) == 'table' then
        for extra_id, is_active in pairs(data.extras) do
            -- If is_active is TRUE (in config), pass 0 (OFF). If FALSE, pass 1 (ON).
            SetVehicleExtra(vehicle, extra_id, is_active and 0 or 1)
        end
    end
end

-- Function to spawn a show vehicle
local function SpawnShowVehicle(car_data, index)
    local model = GetHashKey(car_data.model)
    local coords = car_data.coords

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(100)
    end
    
    -- DEBUG: Print message before spawning
    print('showcar-standalone DEBUG: Model loaded, attempting to spawn vehicle ' .. car_data.model)

    -- Spawn the vehicle
    local vehicle = CreateVehicle(model, coords.x, coords.y, coords.z, coords.w, false, true)
    
    -- Get Net ID for external scripts (like ebu_vroofnum)
    local vehicleNetId = VehToNet(vehicle) 

    --  FIX: APPLY MODKIT FLEXIBLY 
    local modKitToUse = 0 -- Default for most stock cars
    
    -- If a specific modkit ID is defined in the config, use it.
    if car_data.modkit_id and type(car_data.modkit_id) == 'number' then
        modKitToUse = car_data.modkit_id
    end
    
    SetVehicleModKit(vehicle, modKitToUse) 
    Wait(10) -- Allow time for modkit to register

    -- VEHICLE COLORS LOGIC (Run immediately after modkit)
    if car_data.colors and type(car_data.colors) == 'table' then
        local pColor = car_data.colors.primary or 0
        local sColor = car_data.colors.secondary or 0
        SetVehicleColours(vehicle, pColor, sColor)
    end
    
    -- VEHICLE MODS LOGIC (Run after colors)
    if car_data.mods and type(car_data.mods) == 'table' then
        for mod_type, mod_index in pairs(car_data.mods) do
            if type(mod_type) == 'number' and type(mod_index) == 'number' then
                SetVehicleMod(vehicle, mod_type, mod_index, false)
            end
        end
    end
    
    -- CUSTOM PLATE LOGIC
    if car_data.plate and type(car_data.plate) == 'string' then
        SetVehicleNumberPlateText(vehicle, car_data.plate)
    end
    
    -- VEHICLE CLEANING
    SetVehicleDirtLevel(vehicle, 0.0)
    
    -- ANTI-DELETION & FREEZING LOGIC
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleUndriveable(vehicle, true)
    FreezeEntityPosition(vehicle, true)
    
    -- FIX: RESET NEON/DASH COLORS (General cleanup for non-customizable colors)
    SetVehicleNeonLightsColour(vehicle, 0, 0, 0)
    SetVehicleDashboardColour(vehicle, 0)

    -- PREVENT PLAYER ENTRY (Boolean Logic)
    local lockState = 0 -- Default to Unlocked (0)
    if car_data.locked == true then
        lockState = 7 -- 7 = Fully Locked
    end
    SetVehicleDoorsLocked(vehicle, lockState) 
    
    -- LIVERY AND EXTRAS LOGIC
    SetVehicleCustomization(vehicle, car_data)

    --  NEW: EBU ROOF NUMBERS/CALLSIGN LOGIC 
    if exports['ebu_vroofnum'] then
        -- Set the number (e.g., 34 -> 034)
        if car_data.callsign and type(car_data.callsign) == 'number' then
            exports['ebu_vroofnum']:SetVehNum(car_data.callsign, vehicleNetId)
        end

        -- Set the color (e.g., yellow)
        if car_data.callsign_color then
            exports['ebu_vroofnum']:SetVehicleColor(car_data.callsign_color, vehicleNetId)
        end
    end

    -- Mark the model as no longer needed by the script
    SetModelAsNoLongerNeeded(model)

    -- Save the handle
    showVehicles[index] = vehicle
    
    -- DEBUG: Print message after spawning
    if DoesEntityExist(vehicle) then
        print('showcar-standalone DEBUG: Vehicle spawned successfully!')
    else
        print('showcar-standalone DEBUG: Vehicle spawn FAILED!')
    end

    -- Start the spin loop if required
    if car_data.spin then
        local spinThread = CreateThread(function()
            while DoesEntityExist(vehicle) do
                local currentHeading = GetEntityHeading(vehicle)
                SetEntityHeading(vehicle, currentHeading + 0.5) -- Adjust spin speed here
                Wait(Config.VehicleSpinRate)
            end
        end)
        -- Store the thread to potentially stop it later if needed (e.g., resource stop)
        car_data.spinThread = spinThread
    end
end

-- Main function to initialize all show cars
local function InitializeShowCars()
    -- Clean up any previous cars just in case
    for _, veh in pairs(showVehicles) do
        if DoesEntityExist(veh) then
            DeleteVehicle(veh)
        end
    end
    showVehicles = {}

    -- Spawn all configured cars
    for index, car_data in pairs(Config.Showrooms) do
        print('showcar-standalone: Attempting to spawn car at index ' .. index .. ' with model ' .. car_data.model)
        SpawnShowVehicle(car_data, index)
    end
end

-- Thread to ensure vehicles are still present (simple anti-deletion check)
CreateThread(function()
    InitializeShowCars() -- Initial spawn

    -- Start the check loop
    while true do
        for index, car_data in pairs(Config.Showrooms) do
            local vehicle = showVehicles[index]

            -- If the vehicle does not exist (was deleted, despawned, etc.)
            if not DoesEntityExist(vehicle) then
                print(string.format("showcar-standalone: Vehicle %s at index %d was deleted. Re-spawning.",
                    car_data.model, index))
                SpawnShowVehicle(car_data, index)
            end

            -- Re-apply freeze/mission entity status just to be safe in the tick (optional, but robust)
            if DoesEntityExist(vehicle) then
                SetEntityAsMissionEntity(vehicle, true, true)
                FreezeEntityPosition(vehicle, true)
                -- Also ensure it stays clean if the vehicle is checked in the loop
                SetVehicleDirtLevel(vehicle, 0.0)
            end
        end
        Wait(Config.CheckVehicleTick) 
    end
end)

-- Event for resource shutdown (cleanup)
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        for _, veh in pairs(showVehicles) do
            if DoesEntityExist(veh) then
                DeleteVehicle(veh)
            end
        end
    end
end)