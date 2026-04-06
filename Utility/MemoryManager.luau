local ReplicatedStorage = game:GetService("ReplicatedStorage")

local b_create = buffer.create;
local b_copy   = buffer.copy;
local b_len    = buffer.len;
local b_fill   = buffer.fill;

-- Write Operations
local b_writef32 = buffer.writef32;
local b_writef64 = buffer.writef64; 
local b_writei8  = buffer.writei8;
local b_writei16 = buffer.writei16;
local b_writei32 = buffer.writei32;
local b_writeu8  = buffer.writeu8;
local b_writeu16 = buffer.writeu16;
local b_writeu32 = buffer.writeu32;

-- Read Operations
local b_readf32 = buffer.readf32;
local b_readf64 = buffer.readf64;
local b_readi8  = buffer.readi8;
local b_readi16 = buffer.readi16;
local b_readi32 = buffer.readi32;
local b_readu8  = buffer.readu8;
local b_readu16 = buffer.readu16;
local b_readu32 = buffer.readu32;

-- String Ops
local b_readstring  = buffer.readstring;
local b_writestring = buffer.writestring;

export type writeBuffer  =    (b: buffer, offset: number, value: number) -> ()
export type readBuffer   =    (b: buffer, offset: number) -> number

local Lookup = table.freeze({
    u8 = 1, u16 = 2, u32 = 4,
    i8 = 1, i16 = 2, i32 = 4,
    f32 = 4, f64 = 8,
})

local WriteMethods = table.freeze({
    u8  = buffer.writeu8,
    u16 = buffer.writeu16,
    u32 = buffer.writeu32,
    f32 = buffer.writef32,
    f64 = buffer.writef64,
})

local ReadMethods = table.freeze({
    u8  = buffer.readu8,
    u16 = buffer.readu16,
    u32 = buffer.readu32,
    i8  = buffer.readi8,
    i16 = buffer.readi16,
    i32 = buffer.readi32,
    f32 = buffer.readf32,
    f64 = buffer.readf64,
})

local MemoryManager = {}

function MemoryManager.AllocateMemory(buffr: buffer, byteSize: number): buffer
        local oldSize = buffer.len(buffr)
        if byteSize < oldSize then
            error("Cannot shrink buffer. New size: " .. tostring(byteSize) .. " < Old size: " .. oldSize)
            return buffr 
        end
        local newBuffer = buffer.create(byteSize)
        buffer.copy(newBuffer, 0, buffr, 0, oldSize)
        return newBuffer
end

function MemoryManager.AlignByte(currentOffset :number, alignment :number) : number
    local remainder = currentOffset % alignment
    if remainder == 0 then
        return currentOffset 
    else
        return currentOffset + (alignment - remainder)
    end
end

function MemoryManager.GetBytesFromString(dataType : string) : number 
    local val = Lookup[dataType]
    if not val then
        error("Invalid lookup target: " .. dataType)
        return 0 
    end
    return val
end

function MemoryManager.GetWriteFunctionFromString(dataType : string) : writeBuffer
    local func = WriteMethods[dataType]
    if not func then
        error("Invalid lookup target: " .. dataType)
    end
    return func
end

function MemoryManager.GetReadFunctionFromString(dataType : string) : readBuffer
    local func = ReadMethods[dataType]
    if not func then
        error("Invalid lookup target: " .. dataType)
    end
    return func
end

return MemoryManager