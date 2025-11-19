# showcar-standalone (Customized)

A simple script to permanently spawn and showcase custom vehicles anywhere on your FiveM server.

---

## Key Features

* **Permanent Display:** Vehicles are set as mission entities (`SetEntityAsMissionEntity`) and frozen to prevent despawn and movement.
* **Customization Control:** Full configuration for Livery, Mods, and Colors.
* **Anti-Griefing:** Doors are locked to prevent players from entering.
* **Modkit Support:** Automatically handles custom Modkit IDs (like 634) necessary for complex add-on cars.
* **External Integration:** Supports `ebu_vroofnum` for separate control over roof callsigns/numbers.

---

## Configuration (`config.lua`)

Define all show cars in the `Config.Showrooms` table.

### Essential Configuration Fields

| Field | Type | Example Value | Description |
| :--- | :--- | :--- | :--- |
| `model` | string | `'lcso22at4'` | The vehicle spawn name. |
| `coords` | vector4 | `vector4(x, y, z, heading)` | Spawn location and direction. |
| `spin` | boolean | `false` | Set to `true` to make the vehicle rotate continuously. |
| `locked` | boolean | `true` | **true** = Doors fully locked; **false** = Unlocked. |
| `modkit_id` | number | `634` | **Required for custom cars.** |
| `plate` | string | `'CO34 EOW'` | Custom license plate text. |
| `livery` | number | `1` | Livery index (0 is default, 1 is the second option, etc.). |

### Customization Tables

| Table | Field | Description |
| :--- | :--- | :--- |
| `extras` | `[ID] = boolean` | Toggles vehicle extras ON or OFF. (Note: Due to a model bug, `false` often turns some extras ON.) |
| `mods` | `[Type ID] = Index` | Applies custom mods (e.g., `[10] = 1` for Aerials). |
| `colors` | `primary`, `secondary` | Use GTA Color IDs (e.g., `0` for Black, `89` for Race Yellow). |

### Callsign Integration (Requires `ebu_vroofnum`)

| Field | Type | Example Value | Description |
| :--- | :--- | :--- | :--- |
| `callsign` | number | `34` | The number that appears on the roof (e.g., `34` displays as `034`). |
| `callsign_color`| number | `89` | GTA Color ID for the callsign text color (e.g., Race Yellow).