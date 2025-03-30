--[[ Created by DragonNoir_off
link to GitHub profile : https://github.com/DragonNoir-off
Last edit -> 28/03/2025
version [ 3 ]
]]

local DataStore = {}

-- Services
local DataStoreService = game:GetService("DataStoreService")

-- Tables
local Players_DataTable = {} -- Global table of all players data in the server))
local Player_BaseDataTable = {} -- Base data of the player when first join the game

local Kick_Message__Load_Data = "your data havent been load successfuly, to prevent data loose we decide to kick you from the session"

function DataStore.Return_PlayerData(Player : Player)
	if Player == nil then warn("no player got transfer when calling the function") end
	return Players_DataTable[Player.UserId]
end

function DataStore.Return_SpecificPlayerData(Player : Player, DataStoreName : string, scope : string)
	if Player == nil then warn("no player got transfer when calling the function") return end
	if DataStoreName == nil then warn("no data store name got transfer when calling the function") return end
	if scope == nil then scope = "global" end -- "global" is the default value of "scope" when scope isnt define

	return Players_DataTable[Player.UserId][DataStoreName][scope]
end

function DataStore.Return_SpecificDataStorePlayer(Player : Players, DataStoreName : string)
	if Player == nil then warn("no player got transfer when calling the function") return end
	if DataStoreName == nil then warn("no data store name got transfer when calling the function") return end

	return Players_DataTable[Player.UserId][DataStoreName]
end

-- Save data on the data store of the game
function DataStore.Save_Data__DataStore(Player : Player, DataStore_Key, DataStoreName : string, scope : string, option : Instance, Player_Quit : BoolValue)
	if Player == nil then warn("no player got transfer when calling the function") return end
	if DataStore_Key == nil then warn("no key got transfer when calling the function") return end
	if scope == nil then scope = "global" end -- "global" is the default value of "scope" when scope isnt define

	DataStore_Key = tostring(DataStore_Key)

	local DataStoreScope = DataStoreService:GetDataStore(DataStoreName, scope, option)

	local Attempt = 0
	local Max_Attempt = 10

	repeat
		local result, _error = pcall(function()
			if Attempt ~= 0 then task.wait(5) end
			Attempt += 1
			DataStoreScope:SetAsync(DataStore_Key, Players_DataTable[Player.UserId])
		end)
	until result or Attempt == Max_Attempt
	if Player_Quit ~= false then Players_DataTable[Player.UserId] = nil end
	return true
end

-- Load data from the data store of the game
function DataStore.Load_Data__DataStore(Player : Player, DataStore_Key, DataStoreName : string, scope : string, option : Instance)
	if Player == nil then warn("no player got transfer when calling the function") return end
	if DataStore_Key == nil then warn("no key got transfer when calling the function") return end
	if scope == nil then scope = "global" end -- "global" is the default value of "scope" when scope isnt define
	
	DataStore_Key = tostring(DataStore_Key)
	
	local DataStoreScope = DataStoreService:GetDataStore(DataStoreName, scope, option)
	
	local Attempt = 0
	local Max_Attempt = 5
	
	local Data = "none"
	
	repeat
		local result, _error = pcall(function()
			if Attempt ~= 0 then task.wait(5) end
			Attempt += 1
			Data = DataStoreScope:GetAsync(DataStore_Key)
		end)
	until Data ~= "none" and result or Attempt == Max_Attempt
	if Attempt == Max_Attempt then Player:Kick(Kick_Message__Load_Data) return false end
	
	if not Players_DataTable[Player.UserId] then Players_DataTable[Player.UserId] = {} end
	if not Players_DataTable[Player.UserId][DataStoreName] then Players_DataTable[Player.UserId][DataStoreName] = {} end
	if not Players_DataTable[Player.UserId][DataStoreName][scope] then Players_DataTable[Player.UserId][DataStoreName][scope] = {} end
	
	if Data == "none" then Players_DataTable[Player.UserId] = table.clone(Player_BaseDataTable) else Players_DataTable[Player.UserId] = Data end
	return true
end

return DataStore
