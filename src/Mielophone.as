
import air.net.URLMonitor;

import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.Song;
import com.codezen.mse.playr.PlaylistManager;
import com.codezen.mse.playr.Playr;
import com.codezen.mse.playr.PlayrTrack;
import com.codezen.mse.plugins.PluginManager;
import com.mielophone.ui.player.MusicPlayer;

import flash.events.Event;
import flash.events.StatusEvent;
import flash.net.URLRequest;

import mx.utils.ObjectUtil;

import qnx.system.QNXSystem;
import qnx.system.QNXSystemPowerMode;

import views.AlbumInfoView;
import views.AlbumsView;
import views.ArtistView;
import views.SettingsView;
import views.SongsView;

public var mse:MusicSearchEngine;
private var _nowSearching:Boolean = false;

// ------- PLAYER STUFF -----------------
public var player:Playr;
public var _playQueue:Array;
public var _playPos:int;
public var playerComponent:MusicPlayer;

// -------------- MP3 LIST --------------
public var _mp3List:Array;

public var isOnline:Boolean = false;

private function initApp():void{
	//QNXSystem.system.inactivePowerMode = QNXSystemPowerMode.THROTTLED;
	
	mse = new MusicSearchEngine();
	
	player = new Playr();
}

// -----------------------------------------------
public function openArtists():void{
	if(isOnline)
		this.navigator.pushView(ArtistView);
}
public function openAlbums():void{
	if(isOnline)
		this.navigator.pushView(AlbumsView);
}
public function openSongs():void{
	if(isOnline)
		this.navigator.pushView(SongsView);
}
public function openTags():void{
	
}
public function openMoods():void{
	
}
public function openSettings():void{
	this.navigator.pushView(SettingsView);
}
// -------------------------------------------------
public function findNextSong():void{
	trace('next song');
	if(_nowSearching) return;
	
	_playPos++;
	if(_playPos < 0 || _playPos >= _playQueue.length) _playPos = 0;
	_nowSearching = true;
	findSong(_playQueue[_playPos] as Song);
}

public function findPrevSong():void{
	trace('prev song');
	if(_nowSearching) return;
	
	_playPos--;
	if(_playPos < 0) _playPos = _playQueue.length-1;
	_nowSearching = true;
	findSong(_playQueue[_playPos] as Song);
}

public function findSong(song:Song):void{
	if(_mp3List != null){
		_nowSearching = false;
		playSong(_mp3List[song.number] as PlayrTrack);
	}else{
		playerComponent.nowplay_text.text = "Searching for stream..";
		_nowSearching = true;
		mse.addEventListener(Event.COMPLETE, onSongLinks);
		mse.findMP3(song);
	}
}

private function onSongLinks(e:Event):void{
	mse.removeEventListener(Event.COMPLETE, onSongLinks);
	
	//trace( ObjectUtil.toString(mse.mp3s) )
	
	_nowSearching = false;
	
	if( mse.mp3s.length == 0 ){
		trace('nothing :(');
		findNextSong();
		return;
	}
	
	playSong(mse.mp3s[0] as PlayrTrack);
}

private function playSong(song:PlayrTrack):void{
	var pl:PlaylistManager = new PlaylistManager();
	pl.addTrack(song);
	
	player.stop();
	player.playlist = pl;
	player.play();
}