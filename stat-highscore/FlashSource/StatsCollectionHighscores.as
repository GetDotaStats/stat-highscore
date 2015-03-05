package  {

	import flash.display.MovieClip;
	import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
	
	import com.adobe.utils.DateUtil;
	
	import com.adobe.serialization.json.JSONEncoder;
	import com.adobe.serialization.json.JSONParseError;
	import com.adobe.serialization.json.JSONDecoder;
	
    public class StatsCollectionHighscores extends MovieClip {
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;
		
		var SteamID:Number; //Collected on launch
		var UserName:Number;// ^

		var sock:Socket;
		
		var callback:Function; //Used to get info from GetDotaStats back to the mod
		var json:String;       //Used to get info from the mod to GetDotaStats

		var SERVER_ADDRESS:String = "176.31.182.87";
		var SERVER_PORT:Number = 4451;

        public function onLoaded() : void {
            // Tell the user what is going on
            trace("##Loading StatsCollectionHighscores...");

            // Reset our json
            json = '';

            // Load KV
            var settings = globals.GameInterface.LoadKVFile('scripts/stat_collection_highscore.kv');  
            // Load the live setting
            var live:Boolean = (settings.live == "1");

            // Load the settings for the given mode
			SERVER_ADDRESS = settings.SERVER_ADDRESS_LIVE;
			SERVER_PORT = parseInt(settings.SERVER_PORT_LIVE);
            // Log the server
            trace("Server was set to "+SERVER_ADDRESS+":"+SERVER_PORT);
			
			// Hook the stat collection event
			gameAPI.SubscribeToGameEvent("stat_collection_steamID", this.statCollectSteamID);
        }
		private function ServerConnect(serverAddress:String, serverPort:int) {
			// Tell the client
			trace("###STATS_HIGHSCORES Sending payload:");
			trace(json);

            // Create the socket
			sock = new Socket();
			sock.timeout = 10000; //10 seconds is fair..
			// Setup socket event handlers
			sock.addEventListener(Event.CONNECT, socketConnect);
			sock.addEventListener(ProgressEvent.SOCKET_DATA, socketData);

			try {
				// Connect
				sock.connect(serverAddress, serverPort);
			} catch (e:Error) {
				// Oh shit, there was an error
				trace("###STATS_HIGHSCORES Failed to connect!");

				// Return failure
				return false;
			}
		}
		private function socketConnect(e:Event) {
			// We have connected successfully!
            trace('###STATS_HIGHSCORES Connected to the server!');

            // Hook the data connection
            //sock.addEventListener(ProgressEvent.SOCKET_DATA, socketData);
			var buff:ByteArray = new ByteArray();
			writeString(buff, json + '\r\n');
			sock.writeBytes(buff, 0, buff.length);
            sock.flush();
		}
		private function socketData(e:ProgressEvent) {
			trace("###STATS_HIGHSCORES Received data, length: "+sock.bytesAvailable);
			var str:String = sock.readUTFBytes(sock.bytesAvailable);
			trace("###STATS_HIGHSCORES Received string: "+str);
			try {
				var test = new JSONDecoder(str, false).getValue();
				switch(test["type"]) {
					case "success":
						trace("###STATS_HIGHSCORES YAY?");
					break;
					case "failure":
						trace("###STATS_HIGHSCORES WHAT DID YOU JUST DO?!?!?!");
						trace("###STATS_HIGHSCORES ERROR: "+test["error"]);
					break;
					case "list":
						var output:Object = new Object();
						if (test.hasOwnProperty("error")) {
							trace("###STATS_HIGHSCORES list failed horribly (probably no highscores yet)");
							callback(output); //soz not soz
							return;
						}
						for each (var entry:Object in test["jsonData"]) {
							PrintTable(entry);
							if (output.hasOwnProperty(entry["highscoreID"])) {}
							else {
								output[entry["highscoreID"]] = new Array();
							}
							output[entry["highscoreID"]].push({
									highscoreValue : entry["highscoreValue"],
									date : DateUtil.parseW3CDTF(entry["date_recorded"])
							});
						}
						callback(output);
					break;
					case "top":
						var output:Object = new Object();
						if (test.hasOwnProperty("error")) {
							trace("###STATS_HIGHSCORES top failed horribly (probably no highscores yet)");
							callback(output); //soz not soz
							return;
						}
						for each (var entry:Object in test["jsonData"]) {
							PrintTable(entry);
							if (output.hasOwnProperty(entry["highscoreID"])) {}
							else {
								output[entry["highscoreID"]] = new Array();
							}
							output[entry["highscoreID"]].push({
									userName : entry["userName"],
									steamID : entry["steamID32"],
									highscoreValue : entry["highscoreValue"],
									date : DateUtil.parseW3CDTF(entry["date_recorded"])
							});
						}
						callback(output);
					break;
					default:
						trace("###STATS_HIGHSCORES OHGODOHGODOHGOD WHAT IS HAPPENING?!");
						trace("###STATS_HIGHSCORES "+test["type"]);
					break;
				}
			} catch (error:JSONParseError) {
				trace("###STATS_HIGHSCORES HELP ME...");
				trace(str);
			}
		}
		private static function writeString(buff:ByteArray, write:String){
			trace("###STATS_HIGHSCORES Message: "+write);
			trace("###STATS_HIGHSCORES Length: "+write.length);
            buff.writeUTFBytes(write);
        }
		
		// HIGH SCORES FLASH API
		public function SaveHighScore(modID:String, highscoreID:int, highscoreValue:int) {
			var info:Object = {
				type    : "SAVE",
				modID   : modID,
				steamID32 : SteamID,
				userName : globals.Players.GetPlayerName(globals.Players.GetLocalPlayer()),
				highscoreID  : highscoreID,
				highscoreValue : highscoreValue
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
		}
		public function GetPersonalLeaderboard(modID:String, callback:Function) {
			this.callback = callback;
			
			var info:Object = {
				type    : "LIST",
				modID   : modID,
				steamID32 : SteamID
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
		}
		public function GetTopLeaderboard(modID:String, callback:Function) {
			this.callback = callback;
			
			var info:Object = {
				type    : "TOP",
				modID   : modID
			};
			
			json = new JSONEncoder(info).getString();
			ServerConnect(SERVER_ADDRESS, SERVER_PORT);
		}
		// END FLASH API
		
		//
		// Event Handlers 
		//
		public function statCollectSteamID(args:Object) {
			SteamID = args[globals.Players.GetLocalPlayer()];
			UserName = globals.Players.GetPlayerName(globals.Players.GetLocalPlayer());
			trace("STEAM ID: "+SteamID);
			trace("USERNAME: "+UserName);
		}
		
				//Stolen from Frota
		public function strRep(str, count) {
            var output = "";
            for(var i=0; i<count; i++) {
                output = output + str;
            }

            return output;
        }

        public function isPrintable(t) {
        	if(t == null || t is Number || t is String || t is Boolean || t is Function || t is Array) {
        		return true;
        	}
        	// Check for vectors
        	if(flash.utils.getQualifiedClassName(t).indexOf('__AS3__.vec::Vector') == 0) return true;

        	return false;
        }

        public function PrintTable(t, indent=0, done=null) {
        	var i:int, key, key1, v:*;

        	if(indent == 0) {
        		trace(t.name+" "+t+": {")
        	}

        	// Stop loops
        	done ||= new flash.utils.Dictionary(true);
        	if(done[t]) {
        		trace(strRep("\t", indent)+"<loop object> "+t);
        		return;
        	}
        	done[t] = true;

        	// Grab this class
        	var thisClass = flash.utils.getQualifiedClassName(t);

        	// Print methods
			for each(key1 in flash.utils.describeType(t)..method) {
				// Check if this is part of our class
				if(key1.@declaredBy == thisClass) {
					// Yes, log it
					trace(strRep("\t", indent+1)+key1.@name+"()");
				}
			}

			// Check for text
			if("text" in t) {
				trace(strRep("\t", indent+1)+"text: "+t.text);
			}

			// Print variables
			for each(key1 in flash.utils.describeType(t)..variable) {
				key = key1.@name;
				v = t[key];

				// Check if we can print it in one line
				if(isPrintable(v)) {
					trace(strRep("\t", indent+1)+key+": "+v);
				} else {
					// Open bracket
					trace(strRep("\t", indent+1)+key+": {");

					// Recurse!
					PrintTable(v, indent+1, done)

					// Close bracket
					trace(strRep("\t", indent+1)+"}");
				}
			}

			// Find other keys
			for(key in t) {
				v = t[key];

				// Check if we can print it in one line
				if(isPrintable(v)) {
					trace(strRep("\t", indent+1)+key+": "+v);
				} else {
					// Open bracket
					trace(strRep("\t", indent+1)+key+": {");

					// Recurse!
					PrintTable(v, indent+1, done)

					// Close bracket
					trace(strRep("\t", indent+1)+"}");
				}
        	}

        	// Get children
        	if(t is MovieClip) {
        		// Loop over children
	        	for(i = 0; i < t.numChildren; i++) {
	        		// Open bracket
					trace(strRep("\t", indent+1)+t.name+" "+t+": {");

					// Recurse!
	        		PrintTable(t.getChildAt(i), indent+1, done);

	        		// Close bracket
					trace(strRep("\t", indent+1)+"}");
	        	}
        	}

        	// Close bracket
        	if(indent == 0) {
        		trace("}");
        	}
        }
    }
}
