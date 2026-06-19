-- MaxuOS / MaxuOc - init.lua

local component = require("component")
local term = require("term")
local computer = require("computer")
local gpu = component.gpu

local W, H = gpu.getResolution()

local function clear()
  gpu.setBackground(0x000000)
  gpu.setForeground(0xFFFFFF)
  term.clear()
end

local function centerText(y, text)
  local x = math.floor((W - #text) / 2)
  gpu.set(x, y, text)
end

local function drawBoot()
  clear()
  centerText(math.floor(H/2)-1, "MaxuOS")
  centerText(math.floor(H/2), "booting...")
end

local function panic(err)
  clear()
  gpu.setForeground(0xFF0000)
  gpu.set(1, 1, "FATAL ERROR")
  gpu.set(1, 3, tostring(err))
  while true do computer.pullSignal() end
end

local function loadFile(path)
  local f = loadfile(path)
  if not f then error("Cannot load: " .. path) end
  return f()
end

local function boot()
  drawBoot()

  local ok, err = pcall(function()
    os.sleep(0.5)
    if component.isAvailable("filesystem") then
      local fs = require("filesystem")
      if fs.exists("/sys/core.lua") then
        loadFile("/sys/core.lua")
      else
        error("Missing /sys/core.lua")
      end
    else
      error("No filesystem component")
    end
  end)

  if not ok then panic(err) end
end

boot()
