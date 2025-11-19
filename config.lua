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
        model = 'zentorno',
        coords = vector4(-123.45, 678.90, 31.0, 180.0), -- x, y, z, heading
        locked = false,
        spin = false,
        plate = 'Dealer',

        -- Vehicle Livery (Integer index: 0 is default)
        livery = 1,

        -- Vehicle Extras (Key=Extra ID 1-12, Value = false/false)
        extras = {
            [1] = false,   -- Extra 1: ON
            [2] = false,  -- Extra 2: OFF
            [5] = false,   -- Extra 5: ON
        },

        mods = {

        },

        colors = {
            primary = 0,
            secondary = 0, 
        }
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

        extras = {
            [1] = true,
            [2] = false,
            [3] = false,
            [4] = false,
            [5] = false,
            [6] = false,
            [7] = false,
            [8] = false,
            [9] = false,
            [10] = false,
            [11] = true,
            [12] = false,
        },

        mods = {
            [10] = 1,   -- Aerials
            [11] = 4,   -- Trim
            [12] = 5,   -- Tank
        },

        colors = {
            primary = 0,
            secondary = 3, --race yellow
        },
    },
}
