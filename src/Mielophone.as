
import com.codezen.mse.MusicSearchEngine;
import com.codezen.mse.models.Song;
import com.codezen.mse.playr.PlaylistManager;
import com.codezen.mse.playr.Playr;
import com.codezen.mse.playr.PlayrTrack;
import com.codezen.mse.plugins.PluginManager;
import com.mielophone.ui.player.MusicPlayer;

import flash.events.Event;

import mx.utils.ObjectUtil;

import views.AlbumInfoView;
import views.AlbumsView;
import views.ArtistView;
import views.SongsView;

public var mse:MusicSearchEngine;
// ------- PLAYER STUFF -----------------
public var player:Playr;
public var _playQueue:Array;
public var _playPos:int;

// -------------- MP3 LIST --------------
public var _mp3List:Array;

private function initApp():void{
	mse = new MusicSearchEngine();
	
	player = new Playr();
}

// -----------------------------------------------
public function openArtists():void{
	this.navigator.pushView(ArtistView);
}
public function openAlbums():void{
	this.navigator.pushView(AlbumsView);
}
public function openSongs():void{
	this.navigator.pushView(SongsView);
}
public function openTags():void{
	
}
public function openMoods():void{
	
}
// -------------------------------------------------
private var _nowSearching:Boolean = false;
public function findNextSong():void{
	trace('next song');
	if(_nowSearching) return;
	
	_playPos++;
	if(_playPos < 0) _playPos = 0;
	_nowSearching = true;
	findSong(_playQueue[_playPos] as Song);
}

public function findPrevSong():void{
	trace('prev song');
	if(_nowSearching) return;
	
	_playPos--;
	_nowSearching = true;
	findSong(_playQueue[_playPos] as Song);
}

public function findSong(song:Song):void{
	if(_mp3List != null){
		_nowSearching = false;
		playSong(_mp3List[song.number] as PlayrTrack);
	}else{
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