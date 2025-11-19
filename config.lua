Config = {}

-- Seconds between checking if the vehicle still exists
Config.CheckVehicleTick = 600000 -- 10 minutes (600,000 milliseconds)

-- Time in ms between updating vehicle spin (smaller number = smoother, but more demanding)
Config.VehicleSpinRate = 100

-- Define your Showrooms here:
Config.Showrooms = {
    --[[
    -- Example 1: Zentorno (Spins, Livery 1, Extras 1 and 5 ON)
    [1] = {
        model = 'lcso22at4',
        coords = vector4(1853.77, 3674.03, 33.82, 29.65), -- x, y, z, heading
        spin = false,
        locked = true,
        plate = 'CO34 EOW',
        livery = 1,
        callsign = 34,
        callsign_color = 3,
        modkit_id = 634,

        extras = {
            [1] = false,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = true,
            [6] = true,
            [7] = true,
            [8] = true,
            [9] = true,
            [10] = true,
            [11] = false,
            [12] = true,
        },

        colors = {
            primary = 0,
            secondary = 3, --race yellow
        },
    },

    -- Example 2: Adder (No spin, Default Livery, All Extras OFF)
    [2] = {
        model = 'adder',
        coords = vector4(100.0, 200.0, 30.0, 0.0),
        spin = false,
        locked = false,
        -- You can omit any if you want defaults.
    },

    -- Add more show cars here...
    --]]

    [1] = {
        model = 'lcso22at4',
        coords = vector4(1853.77, 3674.03, 33.82, 29.65), -- x, y, z, heading
        spin = false,
        locked = true,
        plate = 'CO34 EOW',
        livery = 1,
        callsign = 34,
        callsign_color = 89,

        extras = {
            [1] = false,
            [2] = true,
            [3] = true,
            [4] = true,
            [5] = true,
            [6] = true,
            [7] = true,
            [8] = true,
            [9] = true,
            [10] = true,
            [11] = false,
            [12] = true,
        },

        colors = {
            primary = 0,
            secondary = 3, --race yellow
        },
    },
}
