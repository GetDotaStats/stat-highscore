package  {

	import flash.display.MovieClip;
	import flash.net.Socket;
    import flash.utils.ByteArray;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.IOErrorEvent;
    import flash.utils.Timer;
    import flash.events.TimerEvent;
	
	import com.adobe.serialization.json.JSONEncoder;
	import com.adobe.serialization.json.JSONParseError;
	import com.adobe.serialization.json.JSONDecoder;
	
    public class StatsCollectionHighscores extends MovieClip {
        public var gameAPI:Object;
        public var globals:Object;
        public var elementName:String;
		
		var SteamID:Number;

		var sock:Socket;
		var callback:Function;
		
		var json:String;

		var SERVER_ADDRESS:String = "176.31.182.87";
		var SERVER_PORT:Number = 4446;

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
						var jsonData = test["jsonData"];
						//TODO: Wrap it in a bow and make sure its nice and shiny for fussy (and lazy) mod devs
						callback(jsonData);
					break;
					case "top":
						var jsonData = test["jsonData"];
						//TODO: Wrap it in a bow and make sure its nice and shiny for fussy (and lazy) mod devs
						callback(jsonData);
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
		
		//TODO: Actually have an API
		
		// END FLASH API
    }
}
