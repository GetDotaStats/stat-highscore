"use strict";

var instance = {
    modIdentifier: null,
    highscoreSchemaVersion: 1
}

Game.stathighscore = {
    TopHighscores: function(highscoreID, callback) {
        if (!instance.modIdentifier) {
            $.Msg("Called API too early, I'm out");
            return;
        }
        var payload = {
            type: "TOP",
            modIdentifier: instance.modIdentifier,
            highscoreID: highscoreID,
            schemaVersion: instance.highscoreSchemaVersion
        }
        $.AsyncWebRequest('https://api.getdotastats.com/s2_highscore.php',
            {
                type: 'POST',
                data: {payload: JSON.stringify(payload)},
                success: function (data) {
                    if (data["result"] === 1) {
                        callback(data["jsonData"]);
                    } else {
                        callback(null);
                    }
                }
            });
    },
    LobbyHighscores: function(highscoreID, callback) {
        Game.stathighscore.ListHighscores(highscoreID, Game.GetAllPlayerIDs(), callback);
    },
    ListHighscores: function(highscoreID, nPlayerID, callback) {
        if (!instance.modIdentifier) {
            $.Msg("Called API too early, I'm out");
            return;
        }
        var payload = {
            type: "LIST",
            modIdentifier: instance.modIdentifier,
            highscoreID: highscoreID,
            schemaVersion: instance.highscoreSchemaVersion
        }
        if (typeof nPlayerID === "number") {
            payload.steamID32 = [GetSteamID32(nPlayerID)];
        } else {
            payload.steamID32 = [];
            for(var val of nPlayerID) {
                payload.steamID32.push(GetSteamID32(val));
            }
        }
        $.AsyncWebRequest('https://api.getdotastats.com/s2_highscore.php',
            {
                type: 'POST',
                data: {payload: JSON.stringify(payload)},
                success: function (data) {
                    if (data["result"] === 1) {
                        callback(data["jsonData"]);
                    } else {
                        callback(null);
                    }
                }
            });
    }
}

function OnClientCheckIn(args) {
    instance.modIdentifier = args.modID;
}
function GetSteamID32(nPlayerID) {
    var playerInfo = Game.GetPlayerInfo(nPlayerID);

    var steamID64 = playerInfo.player_steamid,
        steamIDPart = Number(steamID64.substring(3)),
        steamID32 = String(steamIDPart - 61197960265728);

    return steamID32;
}

(function () {
    $.Msg("Stat-Highscore Client Loaded");

    GameEvents.Subscribe("statcollection_client", OnClientCheckIn);
})();