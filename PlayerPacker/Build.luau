local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Config    = require(ReplicatedStorage.Shared.PlayerPacker.Config)
local Memory    = require(ReplicatedStorage.Shared.Utility.MemoryManager)
local Constants = require(ReplicatedStorage.Shared.Constants)

type OffsetEntry = {
    offset: number,
    write: Memory.writeBuffer,
    read: Memory.readBuffer
}

local   playerPreload                                   = {}
local   freeSlots                                       = {} 
local   statNames                                       = {}
local   offsets         : { [string]: OffsetEntry }     = {} 
local   stride          : number                        = 0
local   b_default       : buffer
local   buffr           : buffer


function Build()
    local currentOffset = 0
    local maxAlignment = 1
    for _, info in Config do

        local size    =  Memory.GetBytesFromString(info.type)
        local writeFn =  Memory.GetWriteFunctionFromString(info.type)
        local readFn  =  Memory.GetReadFunctionFromString(info.type)

        currentOffset = Memory.AlignByte(currentOffset, size)
        if size > maxAlignment then maxAlignment = size end

        offsets[info.name] = {
            offset = currentOffset,
            write = writeFn,
            read = readFn
        }
        table.insert(statNames, info.name)
        currentOffset += size
    end
    stride = Memory.AlignByte(currentOffset, maxAlignment) 

    --preloaded spaces
    b_default = buffer.create(stride)
    for _, info in Config do
        local stat = offsets[info.name]
        stat.write(b_default, stat.offset, info.defualt)
    end

    --preloaded player offsets
    local playercount = Constants.MaxPlayers
    buffr             = buffer.create(playercount * stride)
    for i = 0, playercount - 1 do
        local playerBaseOffset = i * stride
        buffer.copy(buffr, playerBaseOffset, b_default, 0, stride)
        playerPreload[i + 1] = playerBaseOffset; 
    end

    --load "freeslots"
    for i = 1, Constants.MaxPlayers do
        table.insert(freeSlots, i) 
    end
end

Build()

return {
    Offsets         =   offsets;
    Stride          =   stride;
    Buffer          =   buffr;
    Buffer2         =   b_default;
    StatNames       =   statNames;
    AvailableSlots  =   freeSlots;
    PlayerPreload   =   playerPreload;
}