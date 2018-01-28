-- Load Stat collection (statcollection should be available from any script scope)
require('statcollection.init')
require('statcollection.highscores')

print( "Example stat collection game mode loaded." )

if YourGamemode == nil then
    YourGamemode = class({})
end

--------------------------------------------------------------------------------
-- ACTIVATE
--------------------------------------------------------------------------------
function Activate()
    GameRules.YourGamemode = YourGamemode()
    GameRules.YourGamemode:InitGameMode()
end

--------------------------------------------------------------------------------
-- INIT
--------------------------------------------------------------------------------
function YourGamemode:InitGameMode()
    local GameMode = GameRules:GetGameModeEntity()

    ListenToGameEvent("game_rules_state_change", function()
		local state = GameRules:State_Get()
		if state == DOTA_GAMERULES_STATE_GAME_IN_PROGRESS then
			for pID=0, DOTA_MAX_PLAYERS do
				if PlayerResource:IsValidPlayer(pID) then
					statCollection:highscoreTop("hj43152khjb342", function(res)
						if res then
							print("Successfully retrieved last hits globally")
							DeepPrintTable(res)
						end
					end)
					statCollection:highscoreList("hj43152khjb342", pID, function(res)
						if res then
							print("Successfully retrieved last hits :D")
							DeepPrintTable(res)
						end
					end)
				end
			end
		elseif state == DOTA_GAMERULES_STATE_POST_GAME then
			for pID=0, DOTA_MAX_PLAYERS do
				if PlayerResource:IsValidPlayer(pID) then
					statCollection:highscoreSave("hj43152khjb342", pID, PlayerResource:GetLastHits(pID), function(success)
						if success then
							print("Successfully saved last hits :D")
						end
					end)
				end
			end
		end
	end, self)

    -- Register Game Events
end