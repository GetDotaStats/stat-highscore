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
    print(payload)
    for k,v in pairs(payload) do
        print("Payload key " .. tostring(k))
        print("Payload value " .. tostring(v))
        print("Payload type " .. type(v))
    end
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
        steamID32 = PlayerResource:GetSteamAccountID(pid),
        schemaVersion = statCollection.highscoreSchemaVersion
    }
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