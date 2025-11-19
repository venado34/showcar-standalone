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

    -- APPLY EXTRAS
    if data.extras and type(data.extras) == 'table' then
        for extra_id, is_active in pairs(data.extras) do
            SetVehicleExtra(vehicle, extra_id, is_active and 1 or 0)
            -- SetVehicleExtra(vehicle, extra_id, is_active and 0 or 1)  --uncomment this and comment out above if reversed
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

    -- === CUSTOM PLATE LOGIC ===
    if car_data.plate and type(car_data.plate) == 'string' then
        SetVehicleNumberPlateText(vehicle, car_data.plate)
    end
    
    -- === VEHICLE CLEANING ===
    SetVehicleDirtLevel(vehicle, 0.0) -- Ensure the car is spotless (0.0 dirt level)
    
    -- === ANTI-DELETION & FREEZING LOGIC ===
    SetEntityAsMissionEntity(vehicle, true, true)
    SetVehicleUndriveable(vehicle, true)
    FreezeEntityPosition(vehicle, true)
    
    -- === LIVERY AND EXTRAS LOGIC ===
    SetVehicleCustomization(vehicle, car_data)

    -- Mark the model and entity as no longer needed by the script
    SetModelAsNoLongerNeeded(model)
    -- SetEntityNoLongerNeeded(vehicle) <-- Removed crashing line

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