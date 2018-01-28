statCollection.highscoreSchemaVersion = 1

function statCollection:highscoreSave(highscoreID, pid, value, callback, authKey)
    -- If we are missing required parameters, then don't send
    if not self.doneInit then
        statCollection:printError("highscoreSave", errorRunInit)
        return
    end
    local payload = {
        type = "SAVE",
        modIdentifier = self.modIdentifier,
        highscoreID = highscoreID,
        steamID32 = PlayerResource:GetSteamAccountID(pid),
        userName = PlayerResource:GetPlayerName(pid),
        highscoreValue = value,
        -- authKey will be added in after checks
        matchID = tostring(GameRules:GetMatchID()),
        schemaVersion = statCollection.highscoreSchemaVersion
    }
    if authkey then
        payload.userAuthKey = authKey
    end
    statCollection:sendStage("s2_highscore.php", payload, function(err, res)
        -- Check if we got an error
        if statCollection:ReturnedErrors(err, res) then
            statCollection:printError("highscoreSave", "Saving Highscore value failed!")
            callback(false)
            return
        end
        callback(true)
    end)
end

function statCollection:highscoreTop(highscoreID, callback)
    -- If we are missing required parameters, then don't send
    if not self.doneInit then
        statCollection:printError("highscoreTop", errorRunInit)
        return
    end
    local payload = {
        type = "TOP",
        modIdentifier = self.modIdentifier,
        highscoreID = highscoreID,
        schemaVersion = statCollection.highscoreSchemaVersion
    }
    statCollection:sendStage("s2_highscore.php", payload, function(err, res)
        -- Check if we got an error
        if statCollection:ReturnedErrors(err, res) then
            statCollection:printError("highscoreTop", "Obtaining Highscore player top scores failed!")
            callback(false)
            return
        end
        callback(res)
    end)
end
function statCollection:highscoreLobby(highscoreID, callback)
    local players = {}
    for playerID = 0, DOTA_MAX_TEAM_PLAYERS do
        if PlayerResource:IsValidPlayerID(playerID) then
            table.insert(players, playerID)
        end
    end
    statCollection:highscoreList(highscoreID, players, callback)
end
function statCollection:highscoreList(highscoreID, pid, callback)
    -- If we are missing required parameters, then don't send
    if not self.doneInit then
        statCollection:printError("highscoreList", errorRunInit)
        return
    end
    local payload = {
        type = "LIST",
        modIdentifier = self.modIdentifier,
        highscoreID = highscoreID,
        schemaVersion = statCollection.highscoreSchemaVersion
    }
    if type(pid) == "number" then
        payload.steamID32 = {PlayerResource:GetSteamAccountID(pid)}
    else
        payload.steamID32 = {}
        print(pid)
        print(type(pid))
        DeepPrintTable(pid)
        for _,v in pairs(pid) do
            table.insert(payload.steamID32, PlayerResource:GetSteamAccountID(v))
        end
    end
    statCollection:sendStage("s2_highscore.php", payload, function(err, res)
        -- Check if we got an error
        if statCollection:ReturnedErrors(err, res) then
            statCollection:printError("highscoreList", "Obtaining Highscore list failed!")
            callback(false)
            return
        end
        callback(res)
    end)
end