-- Drop-in save system for Festa Hub / VX7
-- No toca la lógica del script original; solo añade persistencia de configuración.
-- Pega este bloque al final del script, o úsalo como archivo adicional.

if not _G.__VX7_SAVE_CONFIG_ADDED then
    _G.__VX7_SAVE_CONFIG_ADDED = true

    local SAVE_PATH = "vx7/VX7Config.json"

    local function VX7_SafeWriteJson(path, data)
        if writefile then
            pcall(function()
                writefile(path, HttpService:JSONEncode(data))
            end)
        end
    end

    local function VX7_SafeReadJson(path)
        if not (isfile and isfile(path)) then
            return nil
        end

        local ok, result = pcall(function()
            return HttpService:JSONDecode(readfile(path))
        end)

        if ok and type(result) == "table" then
            return result
        end

        return nil
    end

    function VX7_SaveConfig()
        if type(Config) ~= "table" then
            return
        end

        local payload = {}
        local keys = {
            "antiBatToggled",
            "safeModeEnabled",
            "bgMode",
            "fontStyle",
            "buttonShape",
            "uiScale",
            "popupScale",
            "floatScale",
            "stealBarScale",
            "stealBarStyle",
            "batTpVersion",
            "speedMethod",
            "fovEnabled",
            "fovValue",
            "speedToggled",
            "laggerEnabled",
            "antiLagEnabled",
            "potatoGraphicsEnabled",
            "autoCarrySpeedEnabled",
            "guiVisible",
            "uiLocked",
            "holdJumpEnabled",
            "autoStealEnabled",
            "dropEnabled",
            "dropType"
        }

        for _, key in ipairs(keys) do
            if Config[key] ~= nil then
                payload[key] = Config[key]
            end
        end

        VX7_SafeWriteJson(SAVE_PATH, payload)
    end

    function VX7_LoadConfig()
        if type(Config) ~= "table" then
            return
        end

        local data = VX7_SafeReadJson(SAVE_PATH)
        if type(data) ~= "table" then
            return
        end

        for key, value in pairs(data) do
            if Config[key] ~= nil then
                Config[key] = value
            end
        end
    end

    if type(scheduleSaveConfig) ~= "function" then
        local saveQueued = false

        function scheduleSaveConfig()
            if saveQueued then
                return
            end

            saveQueued = true
            task.delay(0.25, function()
                saveQueued = false
                VX7_SaveConfig()
            end)
        end
    end

    task.spawn(function()
        task.wait(0.5)
        VX7_LoadConfig()
    end)
end
