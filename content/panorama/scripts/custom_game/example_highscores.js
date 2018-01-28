$.Msg("[Highscores] Hello World");

var highscoreID = "f007815f1328094882cb53259c06d3fb";
// var highscoreID = "GDSR";

function OnRequestLobbyPressed() {
    $.Msg("LOBBY");
    Game.stathighscore.LobbyHighscores(highscoreID, result);
}

function OnRequestTopPressed() {
    $.Msg("TOP");
    Game.stathighscore.TopHighscores(highscoreID, result);
}

function OnRequestChanged() {
    return true;
}

function OnRequestListPressed() {
    $.Msg("LIST");
    var pID = $("#UserList").GetSelected().id;
    Game.stathighscore.ListHighscores(highscoreID, Number(pID), result);
}

function result(data) {
    $.Msg("Response");
    $.Msg(data);

    $("#Output").RemoveAndDeleteChildren();
    if (!data) return;
    for(var entry of data) {
        var newPanel = $.CreatePanel("Panel", $("#Output"), "");
        newPanel.BLoadLayoutSnippet("leaderboardEntry");
        if (entry["steamID32"]) {            
            newPanel.FindChildTraverse("avatar").accountid = entry["steamID32"];
            newPanel.FindChildTraverse("username").accountid = entry["steamID32"];
        }
        newPanel.FindChildTraverse("value").text = entry["highscoreValue"];
        newPanel.FindChildTraverse("matchID").text = entry["matchID"];
        newPanel.FindChildTraverse("date").text = entry["date_recorded"];
        newPanel.FindChildTraverse("rank").text = entry["highscoreRank"];
    }
}

function PopulateDropdown() {
    var dropdown = $("#UserList");

    dropdown.RemoveAllOptions();
    for(var pID of Game.GetAllPlayerIDs()) {
        $.Msg(pID);
        var entry = $.CreatePanel("Label", dropdown, pID);
        entry.text = Players.GetPlayerName(pID);
        dropdown.AddOption(entry);
    }

    dropdown.SetSelected(dropdown.FindDropDownMenuChild(0));
}

PopulateDropdown();