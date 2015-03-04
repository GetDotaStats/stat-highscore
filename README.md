GetDotaStats Stat-Highscore
=====

###About###
 - This repo allows mods to have highscores. It would be most useful for competitive mods.
 - This mod is only useful in tandem with the site. New high score metrics need to be setup via the site.
 - The log file can be observed here: http://getdotastats.com/d2mods/log-highscore-mods.html

# GetDotaStats - StatCollectionHighscore specs 1.0 #

## Client --> Server ##

#### SAVE ####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "SAVE", as thats this packet
|modID     |String        |The modID allocated by GetDotaStats
|steamID32   |Long          |The SteamID32 of the owner of this highscore
|userName   |String          |The username of the owner of this highscore
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
|jsonData  |Array of JSON |Array of data that communicates what value the user has recorded in the highscore charts for this mod

The jsonData will look like: 

[{"highscoreID":2,"highscoreValue":145,"date_recorded":"2015-03-04T03:23:57.000z"},{"highscoreID":5,"highscoreValue":3,"date_recorded":"2015-03-01T03:21:31.000z"}]

#### top (limit top 10 users)####
|Field Name|Field DataType|Field Description
|----------|--------------|-----------------
|type      |String        |Always "top"
|jsonData  |Array of JSON |Array of data that communicates who the top 10 users in each of the highscore types are for this mod and what value they recorded

The jsonData will look like: 

[{"highscoreID":2,"userName":"foobar","steamID32":XXXXXXX,"highscoreValue":145,"date_recorded":"2015-03-04T03:23:57.000z"},
{"highscoreID":2,"userName":"sinz","steamID32":XXXXXXX,"highscoreValue":10,"date_recorded":"2015-03-04T03:23:57.000z"},
{"highscoreID":2,"userName":"bmd","steamID32":XXXXXXX,"highscoreValue":1,"date_recorded":"2015-03-04T03:23:57.000z"},
{"highscoreID":3,"userName":"bmd","steamID32":XXXXXXX,"highscoreValue":420,"date_recorded":"2015-03-04T03:23:57.000z"},
{"highscoreID":3,"userName":"sinz","steamID32":XXXXXXX,"highscoreValue":322,"date_recorded":"2015-03-04T03:23:57.000z"}]

## Ports ##

* Live: 4451
