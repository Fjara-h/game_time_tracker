local json = require("json")
local mod = RegisterMod("Game Time Tracker", 1)

-- To log game-duration after leaving a run and starting a new game from the main menu, save current run duration on-exit. When starting a new run, add that to the total.
function mod:gameStart(isContinued)
	if(not isContinued and mod:HasData()) then
		local data = json.decode(mod:LoadData())
		data.total.msec = data.total.msec + data.run.msec
		data.total.sec = data.total.sec + data.run.sec
		data.total.min = data.total.min + data.run.min
		data.total.hour = data.total.hour + data.run.hour
		data.run.msec = 0
		data.run.sec = 0
		data.run.min = 0
		data.run.hour = 0
		mod:SaveData(json.encode(data))
	end
end

function mod:gameExit(shouldCreateSave)
	local data = {
		total = {
			msec = 0,
			sec = 0,
			min = 0,
			hour = 0,
		},
		run = {
			msec = 0,
			sec = 0,
			min = 0,
			hour = 0,
		},
	}
	if(mod:HasData()) then
		data = json.decode(mod:LoadData())
	end

	local frames = Game():GetFrameCount()

	if(not shouldCreateSave) then
		data.total.msec = data.total.msec + (frames % 30 * (10 / 3))
		data.total.sec = data.total.sec + (math.floor(frames / 30) % 60)
		data.total.min = data.total.min + (math.floor(frames / 30 / 60) % 60)
		data.total.hour = data.total.hour+ (math.floor(frames / 30 / 60 / 60) % 60)
		-- Reset the temporary run holding times just in case
		data.run.msec = 0
		data.run.sec = 0
		data.run.min = 0
		data.run.hour = 0
	elseif(shouldCreateSave) then
		data.run.msec =frames % 30 * (10 / 3)
		data.run.sec = math.floor(frames / 30) % 60
		data.run.min = math.floor(frames / 30 / 60) % 60
		data.run.hour = math.floor(frames / 30 / 60 / 60) % 60
	end

	mod:SaveData(json.encode(data))
end

mod:AddCallback(ModCallbacks.MC_PRE_GAME_EXIT, mod.gameExit)
mod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, mod.gameStart)