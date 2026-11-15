mod.BiomeCleanupData =
{
    N =
    {
        PathValueMap =
        {
            ["CurrentRun.ClosedDoors"] = {},
            ["CurrentRun.SpawnRecord.SoulPylon"] = 0,
            ["CurrentRun.RoomHistory"] = {}
        }
    },
    H =
    {
        PathValueMap =
        {
            ["CurrentRun.FieldsMaxDoorsRolled"] = 0,
        }
    },
    Styx =
    {
        PathValueMap =
        {
            ["CurrentRun.CompletedStyxWings"] = 0,
            ["CurrentRun.ClosedDoors"] = {},
            ["CurrentRun.RoomHistory"] = {}
        }
    },
    Tartarus =
    {
        PathValueMap =
        {
            ["CurrentRun.SupportAINames"] = {}
        }
    }
}

local skipEncounterLookup = game.ToLookup({
    "Empty",
    "Shop"
})

local function gatherRoomsAndEncounters()
    for roomName, roomData in pairs(game.RoomData) do
        if mod.BiomeCleanupData[roomData.RoomSetName] then
            local roomSet = roomData.RoomSetName
            table.insert(mod.BiomeCleanupData[roomSet].Rooms, roomName)
            local legalEncounters = roomData.LegalEncounters or {}
            local multiLegalEncounters = roomData.MultipleEncountersData or {}
            for _, encounter in ipairs(legalEncounters) do
                if not skipEncounterLookup[encounter] then
                    mod.BiomeCleanupData[roomSet].Encounters[encounter] = true
                end
            end
            for _, encounterData in ipairs(multiLegalEncounters) do
                legalEncounters = encounterData.LegalEncounters or {}
                for _, encounter in ipairs(legalEncounters) do
                    if not skipEncounterLookup[encounter] then
                        mod.BiomeCleanupData[roomSet].Encounters[encounter] = true
                    end
                end
            end
        end
    end
    for _, encounter in ipairs(game.ObstacleData.FieldsRewardCage.LegalEncounters) do
        mod.BiomeCleanupData.H.Encounters[encounter] = true
    end
end

function mod.BuildBiomeCleanupData()
    local biomeList =  game.ToLookup({"F", "G", "H", "I", "N", "N_SubRooms", "O", "P", "Q", "Tartarus", "Asphodel", "Elysium", "Styx"})
    for roomSet, _ in pairs(biomeList) do
        mod.BiomeCleanupData[roomSet] = mod.BiomeCleanupData[roomSet] or {}
        mod.BiomeCleanupData[roomSet].Rooms = {}
        mod.BiomeCleanupData[roomSet].Encounters = {}
        mod.BiomeCleanupData[roomSet].PathValueMap = mod.BiomeCleanupData[roomSet].PathValueMap or {}
    end
    gatherRoomsAndEncounters()
end

local function writeEntryHelper(root, pathArray, key, value)
    for _, path in ipairs(pathArray) do
        local data = modutil.mod.Path.Get(path, root)
        if data and key then
            data[key] = value
        end
    end
end

function mod.CleanupBiomeVisit(roomSet)
    local eraseEncounterFromLookups = {
        "EncountersOccurredCache",
        "EncountersCompletedCache",
        "EncountersDepthCache",
        "EncountersOccurredBiomeCache",
    }
    local eraseEncounterFromArrays = {
    }
    local eraseRoomFromLookups = {
        "RoomsEntered",
        "RoomCreations",
        "RoomCountCache",
        "BiomeRoomCountCache"
    }
    for encounter, _ in pairs(mod.BiomeCleanupData[roomSet].Encounters) do
        writeEntryHelper(game.CurrentRun, eraseEncounterFromLookups, encounter, nil)
    end
    for _, room in ipairs(mod.BiomeCleanupData[roomSet].Rooms) do
        writeEntryHelper(game.CurrentRun, eraseRoomFromLookups, room, nil)
    end
    for path, value in pairs(mod.BiomeCleanupData[roomSet].PathValueMap) do
        modutil.mod.Path.Set(path, value, game)
    end
    game.CurrentRun.BiomesReached[roomSet] = nil
    game.CurrentRun.MusicRecord = {}
end

-- do it as late as possible to capture modded encounters/rooms
modutil.once_loaded.save(function ()
    mod.BuildBiomeCleanupData()
end)