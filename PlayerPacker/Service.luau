local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Build = require(ReplicatedStorage.Shared.PlayerPacker.Build)

local Offsets         =      Build.Offsets
local Stride          =      Build.Stride
local Buffer          =      Build.Buffer
local DefaultBuffer   =      Build.Buffer2
local PlayerPreload   =      Build.PlayerPreload
local StatNames       =      Build.StatNames
local FreeSlots       =      Build.AvailableSlots

local PlayerPacker = {}
PlayerPacker.__index = PlayerPacker
local Cache           = {}

function PlayerPacker.Register(playerID : number) : number
    if Cache[playerID] then error("PlayerPacker: Player already registered " .. playerID) return 0 end
    local indx = table.remove(FreeSlots)
    if not indx then
        error("PlayerPacker: No available slots for " .. playerID)
        return 1
    end
    Cache[playerID] = indx
    return 0
end

function PlayerPacker.UnRegistor(playerID: number)
    local indx = Cache[playerID]
    if not indx then return end
    local offset = PlayerPreload[indx]
    buffer.copy(Buffer, offset, DefaultBuffer, 0, Stride)
    table.insert(FreeSlots, indx)
    Cache[playerID] = nil
end

function PlayerPacker.SetData(playerID : number, statName : string, newVal : number)
    local indx = Cache[playerID]
    if not indx then return end
    local stat   = Offsets[statName]
    if not stat then return end
    local offset = PlayerPreload[indx] + stat.offset
    stat.write(Buffer, offset, newVal)
end

function PlayerPacker.GetData(playerID : number, statName : string) : number
    local indx = Cache[playerID]
    if not indx then return 1 end
    local stat   = Offsets[statName]
    if not stat then return 1 end
    local offset = PlayerPreload[indx] + stat.offset
    return stat.read(Buffer, offset)
end

function PlayerPacker.GetRawData(playerID : number, outTable) 
    local indx = Cache[playerID]
    if not indx then return end
    local baseOffset = PlayerPreload[indx]
    local out = outTable
    for i = 1, #StatNames do
        local name = StatNames[i]
        local stat = Offsets[name]
        out[name] = stat.read(Buffer, baseOffset + stat.offset)
    end
    return out
end

return PlayerPacker