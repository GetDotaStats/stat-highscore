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
|jsonData  |Array of JSON |{"highscore1":123, "highscore2":321, "highscore3":333}

#### top (limit top 10 users)####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "top"
|jsonData  |Array of JSON |{"highscore1":[ ["jimmydorry":3213], ["noya":3210], ["bmd":322], ["sinz":10] ], "highscore2":[ ["jimmydorry":31], ["noya":50], ["bmd":90], ["sinz":231] ]}

## Ports ##

* Live: 4451
