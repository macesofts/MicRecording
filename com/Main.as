package com {
	import flash.display.MovieClip;
	import org.bytearray.micrecorder.encoder.WaveEncoder;
	import org.bytearray.micrecorder.MicRecorder;
	import org.as3wavsound.WavSound;
	import org.as3wavsound.WavSoundChannel;
	import org.bytearray.micrecorder.events.RecordingEvent;
	import flash.events.MouseEvent;
	import flash.net.FileReference;
	import flash.events.Event;
	import flash.utils.ByteArray;
	import flash.media.Microphone;
	import flash.system.Security;
	import flash.system.SecurityPanel;
    import flash.events.ActivityEvent;
    import flash.events.StatusEvent;
    import flash.events.SampleDataEvent;
	import flash.net.URLRequestMethod;
	import fr.kikko.lab.ShineMP3Encoder;
	import flash.events.ProgressEvent;
	import flash.events.ErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;

	public class Main extends MovieClip {
		private var micRecord:MicRecorder;
		private var wavEncoder:WaveEncoder;
		private var wavSoundEncode:WavSound;
		private var mp3Converter:ShineMP3Encoder;
		private var wavSoundChannel:WavSoundChannel;
		private var wavFile:FileReference;
		private var recMode:Boolean=false;
		private var playMode:Boolean = false;
		private var tl;
		private var serverURL:String = "http://localhost/audio/acceptfile.php?filename=RecordedSound_"+Math.round(Math.random()*100);
		private var urlLoader:URLLoader;
		private var urlReq:URLRequest;
		public var mic:Microphone;
		public function Main(timeline) {
			// constructor code
			tl=timeline||timeline.parent;
			tl.recordBtn.addEventListener(MouseEvent.CLICK,togleRecord);
			tl.recordBtn.buttonMode=true;
			//tl.playBtn.addEventListener(MouseEvent.CLICK,toglePlay);
			init();
		}
		public function init(){
			mic = Microphone.getMicrophone();
    		mic.setSilenceLevel(0);
			mic.gain = 75; 
			mic.rate = 44; 
    		Security.showSettings(SecurityPanel.MICROPHONE);
			wavEncoder =  new WaveEncoder();
			micRecord = new MicRecorder(wavEncoder);
		}
		private function activityHandler(event:ActivityEvent):void {
            trace("activityHandler: " + event);
        }

        private function statusHandler(event:StatusEvent):void {
            trace("statusHandler: " + event);
        }
		private function togleRecord(evt:MouseEvent):void{
			
			recMode=!recMode;
			(recMode)?startRecording():stopRecording();
		}
		private function toglePlay(evt:MouseEvent):void{
			playMode=!playMode;
			(playMode)?startPlay():stopPlay();
		}
		private function startRecording():void{
			micRecord.record();
			tl.recordBtn.gotoAndStop(2);
			tl.statusText.text = "RECORDING";
			micRecord.addEventListener(Event.COMPLETE, onRecordComplete);
			micRecord.addEventListener(RecordingEvent.RECORDING, recording);
			tl.meterMc.addEventListener(Event.ENTER_FRAME, updateMeter);
		}
		private function updateMeter(e:Event):void
		{
    		tl.meterMc.gotoAndPlay(100 - mic.activityLevel);
		}
		private function stopRecording():void{
			micRecord.stop();
			tl.recordBtn.gotoAndStop(1);
			tl.statusText.text = "STOP";
			startPlay();
		}
		private function onRecordComplete(evt:Event):void{
			//encodeToMP3(micRecord.output);
			encodeToWAV(micRecord.output);
			micRecord.removeEventListener(Event.COMPLETE, onRecordComplete);
			tl.meterMc.removeEventListener(Event.ENTER_FRAME, updateMeter);
		}
		private function startPlay():void{
			wavSoundEncode = new WavSound(micRecord.output);
			wavSoundEncode.play();
			wavSoundChannel = wavSoundEncode.play();
			
		}
		private function stopPlay():void{
			wavSoundChannel.stop();
		}
		private function recording(e:RecordingEvent):void
		{
			var currentTime:int = Math.floor(e.time / 1000);//Gets the elapsed time since the recording event was called
		 
			tl.statusText.text = String(currentTime);//Sets the time to the TextField
		 
			//Formats the text used in the time (2 digits numbers only in this example)
			if (String(currentTime).length == 1)
			{
				tl.statusText.text = "00:0" + currentTime;
			}
			else if (String(currentTime).length == 2)
			{
				tl.statusText.text = "00:" + currentTime;
			}
		}
		private function encodeToWAV(Byte:ByteArray):void{
			//wavFile = new FileReference();
			//wavFile.save(Byte,"RecordedSound.wav");
			serverURL = "http://localhost/audio/acceptfile.php?filename=RecordedSound_"+Math.round(Math.random()*100);
			urlReq = new URLRequest(serverURL);
			urlReq.contentType='application/octet-stream';
			urlReq.method = URLRequestMethod.POST;
			urlReq.data = Byte;
			urlLoader = new URLLoader(urlReq);
		}
		private function encodeToMP3(wavData:ByteArray):void {
            mp3Converter = new ShineMP3Encoder(wavData);
            mp3Converter.addEventListener(Event.COMPLETE, mp3EncodeComplete);
            mp3Converter.addEventListener(ProgressEvent.PROGRESS, mp3EncodeProgress);
            mp3Converter.addEventListener(ErrorEvent.ERROR, mp3EncodeError);
            mp3Converter.start();
    	}

     	private function mp3EncodeProgress(event : ProgressEvent) : void {

            trace( event.bytesLoaded, event.bytesTotal);
    	}
     	private function mp3EncodeError(event : ErrorEvent) : void {

            trace("Error : ", event.text);
    	}

    	private function mp3EncodeComplete(event : Event) : void {

            trace("Done !", mp3Converter.mp3Data.length);
			wavFile = new FileReference();
			mp3Converter.saveAs("Recorded_01.mp3");
    	}
	}
	
}

