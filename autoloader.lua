repeat task.wait() until game:IsLoaded()

local GameConfigs = {
    ["79546208627805"] = {
        Hub_Script_ID = "26b31ab20f03d29896dff090b9feb97b",
        LoadingSubtitle = "99 Nights In The Forest"
    },
    ["16281300371"] = {
        Hub_Script_ID = "33300b99dfb4699f0e238fd14afd1587",
        LoadingSubtitle = "Blade Ball"
    },
    ["16732694052"] = {
        Hub_Script_ID = "13fbfb8ad5363ed9bfbfdb557177c7f1",
        LoadingSubtitle = "Fisch"
    },
    ["189707"] = {
        Hub_Script_ID = "a4dec7860e50813be8a29d5cb9df6d81",
        LoadingSubtitle = "Natural Disaster Survival",
        PlaceIDs = {
            ["118693886221846"] = "9b5ab79f8007e89b695dac53c55f0904",
            ["8304191830"] = "0bd8fd6455fc4e4e8453091023892b7c",
            ["18687417158"] = "58b52abb25606af68adcd5c0ce248c92",
            ["94845773826960"] = "69559f04bcb1949ddbea9b5e419520cd",
            ["121864768012064"] = "20efe85b3452d1fa0feb38ce30bbad53",
        }
    }
}

local Hub = "Strive Hub"
local Discord_Invite = "bgzarKxdEK"
local UI_Theme = "Dark"
local workink_enabled = true
local workink_link = "https://ads.luarmor.net/v/cb/kJejUxnJZoDY/OuPhPjdhiUAweAuw"
local lootlabs_enabled = true
local lootlabs_link = "https://ads.luarmor.net/v/cb/aIhgQBmobqwT/tItkoxKfEGbeUZCc"

local CurrentPlaceId = tostring(game.PlaceId)
local CurrentConfig = GameConfigs[CurrentPlaceId] or GameConfigs["79546208627805"]

makefolder(Hub)
local key_path = Hub .. "/Key.txt"
script_key = script_key or isfile(key_path) and readfile(key_path) or nil

local UI = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local API = loadstring(game:HttpGet("https://sdkAPI-public.luarmor.net/library.lua"))()

local Cloneref = cloneref or function(instance) return instance end
local Players = Cloneref(game:GetService("Players"))
local HttpService = Cloneref(game:GetService("HttpService"))
local AssetService = Cloneref(game:GetService("AssetService"))
local Request = http_request or request or syn.request or http

if CurrentConfig.PlaceIDs then
    local GamePlacesPages = AssetService:GetGamePlacesAsync()
    local Pages = GamePlacesPages:GetCurrentPage()

    while true do
        for _, place in ipairs(Pages) do
            if CurrentConfig.PlaceIDs[tostring(place.PlaceId)] then
                API.script_id = CurrentConfig.PlaceIDs[tostring(place.PlaceId)]
                break
            else
                API.script_id = CurrentConfig.Hub_Script_ID
            end
        end
        if GamePlacesPages.IsFinished then
            break
        end
        GamePlacesPages:AdvanceToNextPageAsync()
        Pages = GamePlacesPages:GetCurrentPage()
    end
else
    API.script_id = CurrentConfig.Hub_Script_ID
end

local function notify(title, content, duration)
    UI:Notify({ Title = title, Content = content, Duration = duration or 8 })
end

local function checkKey(input_key)
    local status = API.check_key(input_key or script_key)
    if status.code == "KEY_VALID" then
        script_key = input_key or script_key
        writefile(key_path, script_key)
        UI:Destroy()
        API.load_script()
    elseif status.code:find("KEY_") then
        local messages = {
            KEY_HWID_LOCKED = "Key linked to a different HWID. Please reset it using our bot",
            KEY_INCORRECT = "Key is incorrect",
            KEY_INVALID = "Key is invalid",
        }
        notify("Key Check Failed", messages[status.code] or "Unknown error")
    else
        Players.LocalPlayer:Kick("Key check failed: " .. status.message .. " Code: " .. status.code)
    end
end

if script_key then
    checkKey()
end

local Window = UI:CreateWindow({
    Title = "Strive",
    SubTitle = CurrentConfig.LoadingSubtitle,
    TabWidth = 160,
    Size = UDim2.fromOffset(580, 320),
    Acrylic = false,
    Theme = UI_Theme,
    MinimizeKey = Enum.KeyCode.End,
})

local Tabs = { Main = Window:AddTab({ Title = "Key", Icon = "" }) }

local Input = Tabs.Main:AddInput("Key", {
    Title = "Enter Key:",
    Default = script_key or "",
    Placeholder = "Example: agKhRikQP..",
    Numeric = false,
    Finished = false,
})

if workink_enabled then
    Tabs.Main:AddButton({
        Title = "Get Key (workink)",
        Callback = function()
            setclipboard(workink_link)
            notify("Copied To Clipboard", "Ad Reward Link has been copied to your clipboard", 16)
        end,
    })
end

if lootlabs_enabled then
    Tabs.Main:AddButton({
        Title = "Get Key (Lootlabs)",
        Callback = function()
            setclipboard(lootlabs_link)
            notify("Copied To Clipboard", "Ad Reward Link has been copied to your clipboard", 16)
        end,
    })
end

Tabs.Main:AddButton({
    Title = "Paste Key",
    Callback = function()
        local clipboard_key = getclipboard()
        if clipboard_key and clipboard_key ~= "" then
            Input:SetValue(clipboard_key)
            notify("Key Pasted", "Key from clipboard has been pasted", 3)
        else
            notify("Paste Failed", "No key found in clipboard", 5)
        end
    end,
})

Tabs.Main:AddButton({
    Title = "Check Key",
    Callback = function()
        checkKey(Input.Value)
    end,
})

Tabs.Main:AddButton({
    Title = "Join Discord",
    Callback = function()
        setclipboard("https://discord.gg/" .. Discord_Invite)
        notify("Copied To Clipboard", "discord.gg/" .. Discord_Invite, 16)
        Request({
            Url = "http://127.0.0.1:6463/rpc?v=1",
            Method = "POST",
            Headers = { ["Content-Type"] = "application/json", ["origin"] = "https://discord.com" },
            Body = HttpService:JSONEncode({ args = { code = Discord_Invite }, cmd = "INVITE_BROWSER", nonce = "." }),
        })
    end,
})

Window:SelectTab(1)
notify("Strive", "Loader Has Loaded Successfully")
