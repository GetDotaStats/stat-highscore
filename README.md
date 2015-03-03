GetDotaStats Stat-Highscore
=====

###About###
 - This repo allows mods to have highscores. It would be most useful for competitive mods.
 - This mod is only useful in tandem with the site. New high score metrics need to be setup via the site.

# GetDotaStats - StatCollectionHighscore specs 1.0 #

## Client --> Server ##

#### SAVE ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "SAVE", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID32   |Long          |The SteamID32 of the owner of this highscore
|userName   |Stromg          |The username of the owner of this highscore
|highscoreID    |Integer       |The unique ID for this highscore (from the site)
|highscoreValue  |Integer          |The data of this highscore

#### LIST ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "LIST", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID32   |Long          |The SteamID of the owner of this highscore

#### TOP ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "TOP", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats

## Server --> Client ##

Always listen for the error and result fields. If error is populated, then something went wrong and you may want to indicate the raw error to the user in the client, otherwise you may want to communicate the result to the user (optional).

#### on success ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|result    |String        | String describing success, only useful for debugging

#### on failure ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|error     |String        |A string describing the error. Only useful for debugging purposes

#### save ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "save"

#### list ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "list"
|jsonData  |Array of JSON |{"3":123,"1":321,"2":333}

The array is in the form of {highscoreID : highscoreValue}, where highscoreID matches the ID you have received from registering this highscore type on the site.

#### top (limit top 10 users)####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "top"
|jsonData  |Array of JSON |{"1": {"1": ["steamID32","jimmydorry",3213],"2": ["steamID32","noya",3210],"3": ["steamID32","bmd",322],"4": ["steamID32","SinZ",163]},"2": {"1": ["steamID32","jimmydorry",31],"2": ["steamID32","noya",50],"3": ["steamID32","bmd",90],"4": ["steamID32","SinZ",167]}}

The array is in the form of {highscoreID : [steamID32, userName, highscoreValue]}, where highscoreID matches the ID you have received from registering this highscore type on the site.

## Ports ##

* Live: 4451
