package;

import ui.Case;
import animateatlas.AtlasFrameMaker;
import animate.FlxAnimate;
import shaderslmfao.BuildingShaders;
import ui.PreferencesMenu;
import shaderslmfao.ColorSwap;
#if desktop
import Discord.DiscordClient;
#end
import Section.SwagSection;
import Song.SwagSong;
import flixel.FlxBasic;
import flixel.FlxCamera;
import flixel.FlxG;
import flixel.FlxGame;
import flixel.FlxObject;
import flixel.FlxSprite;
import flixel.FlxState;
import flixel.FlxSubState;
import flixel.addons.display.FlxGridOverlay;
import flixel.addons.effects.FlxTrail;
import flixel.addons.effects.FlxTrailArea;
import flixel.addons.effects.chainable.FlxEffectSprite;
import flixel.addons.effects.chainable.FlxWaveEffect;
import flixel.addons.transition.FlxTransitionableState;
import flixel.graphics.atlas.FlxAtlas;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.math.FlxPoint;
import flixel.math.FlxRect;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween;
import flixel.ui.FlxBar;
import flixel.util.FlxCollision;
import flixel.util.FlxColor;
import flixel.util.FlxSort;
import flixel.util.FlxStringUtil;
import flixel.util.FlxTimer;
import haxe.Json;
import lime.utils.Assets;
import openfl.display.BlendMode;
import openfl.display.StageQuality;
import openfl.filters.ShaderFilter;
import openfl.utils.Assets as OpenFlAssets;
import charting.ChartingState;
import charting.AnimationDebug;

using StringTools;

class PlayState extends MusicBeatState
{
	public static var curStage:String = '';
	public static var SONG:SwagSong;
	public static var isStoryMode:Bool = false;
	public static var isFreePlay:Bool = false;
	public static var storyWeek:Int = 0;
	public static var storyPlaylist:Array<String> = [];
	public static var storyDifficulty:Int = 1;
	public static var deathCounter:Int = 0;
	public static var practiceMode:Bool = false;
	public static var seenCutscene:Bool = false;

	var halloweenLevel:Bool = false;

	private var vocals:FlxSound;
	private var vocalsFinished = false;

	private var dad:Character;
	private var gf:Character;
	private var boyfriend:Boyfriend;

	private var notes:FlxTypedGroup<Note>;
	private var unspawnNotes:Array<Note> = [];

	private var strumLine:FlxSprite;
	private var curSection:Int = 0;

	private var camFollow:FlxObject;
	private var camPos:FlxPoint;

	private static var prevCamFollow:FlxObject;

	private var strumLineNotes:FlxTypedGroup<FlxSprite>;
	private var playerStrums:FlxTypedGroup<FlxSprite>;
	private var grpNoteSplashes:FlxTypedGroup<NoteSplash>;

	private var camZooming:Bool = false;
	private var curSong:String = "";

	private var gfSpeed:Int = 1;
	private var health:Float = 1;
	private var combo:Int = 0;
	private var ss:Bool = true;
	private var healthBarBG:FlxSprite;
	private var healthBar:FlxBar;

    private var timeBarBG:FlxSprite;
	private var timeBar:FlxBar;
	private var generatedMusic:Bool = false;
	private var startingSong:Bool = false;

	private var iconP1:HealthIcon;
	private var iconP2:HealthIcon;
	private var camHUD:FlxCamera;
	private var camGame:FlxCamera;

	var dialogue:Array<String> = ['blah blah blah', 'coolswag'];

	var pixelsong:Array<String> = ['blah blah blah', 'coolswag'];

	var halloweenBG:FlxSprite;
	var isHalloween:Bool = false;

	var foregroundSprites:FlxTypedGroup<BGSprite>;

	var phillyCityLights:FlxTypedGroup<FlxSprite>;
	var phillyTrain:FlxSprite;
	var trainSound:FlxSound;
	var lightFadeShader:BuildingShaders;

	var limo:FlxSprite;
	var grpLimoDancers:FlxTypedGroup<BackgroundDancer>;
	var fastCar:FlxSprite;

	var upperBoppers:FlxSprite;
	var bottomBoppers:FlxSprite;
	var santa:FlxSprite;

	var bgGirls:BackgroundGirls;
	var bgGirlevil:BackgroundGirlsEvil;
	var wiggleShit:WiggleEffect = new WiggleEffect();
	var wiggleShitBg:WiggleEffect = new WiggleEffect();
	var tankSky:BGSprite;
	var tankWatchtower:BGSprite;
	var tankGround:BGSprite;
	var gruy:BGSprite;
	var tankmanRun:FlxTypedGroup<TankmenBG>;
	var gruyweek:BGSprite;

	var gfCutsceneLayer:FlxTypedGroup<FlxAnimate>;
	var bfTankCutsceneLayer:FlxTypedGroup<FlxAnimate>;
	var gfCutsceneLayerFlxSprite:FlxTypedGroup<FlxSprite>;
	var bfTankCutsceneLayerFlxSprite:FlxTypedGroup<FlxSprite>;

	var talking:Bool = true;
	var misses:Int = 0;
	var faults:Int = 0;
	var songScore:Int = 0;
	var scoreTxt:FlxText;
	var effectTween:FlxTween;
    var timeTxt:FlxText;
	var isFilterEnabled:Bool;
	var shader:PixelScaleShader;
	var scale = 4;
	var minScale = 2;
	var maxScale = 128;
	var canDie:Bool = true;

	private var accuracy:Float = 0.00;
	private var totalNotesHit:Float = 0;
	private var totalPlayed:Int = 0;
	private var rank:String = "None";
	private var player2Strums:FlxTypedGroup<FlxSprite>;
	private var strumming2:Array<Bool> = [false, false, false, false];

	public static var campaignScore:Int = 0;

	private var dataSuffix:Array<String> = ['LEFT', 'DOWN', 'UP', 'RIGHT'];

	var defaultCamZoom:Float = 1.05;

	// how big to stretch the pixel art assets
	public static var daPixelZoom:Float = 6;

	var inCutscene:Bool = false;

	#if desktop
	// Discord RPC variables
	var storyDifficultyText:String = "";
	var iconRPC:String = "";
	var songLength:Float = 0;
	var detailsText:String = "";
	var detailsPausedText:String = "";
	#end

	override public function create()
	{
		if (FlxG.sound.music != null)
			FlxG.sound.music.stop();

		var instPath = Paths.inst(SONG.song.toLowerCase());
		if (OpenFlAssets.exists(instPath, SOUND) || OpenFlAssets.exists(instPath, MUSIC))
			OpenFlAssets.getSound(instPath, true);
		var vocalsPath = Paths.voices(SONG.song.toLowerCase());
		if (OpenFlAssets.exists(vocalsPath, SOUND) || OpenFlAssets.exists(vocalsPath, MUSIC))
			OpenFlAssets.getSound(vocalsPath, true);

		// var gameCam:FlxCamera = FlxG.camera;
		camGame = new FlxCamera();
		camHUD = new FlxCamera();
		camHUD.bgColor.alpha = 0;

		FlxG.cameras.reset(camGame);
		FlxG.cameras.add(camHUD, false);

		grpNoteSplashes = new FlxTypedGroup<NoteSplash>();
		var splash:NoteSplash = new NoteSplash(100, 100, 0);
		grpNoteSplashes.add(splash);
		splash.alpha = 0.1;

		persistentUpdate = true;
		persistentDraw = true;

		if (SONG == null)
			SONG = Song.loadFromJson('tutorial');

		Conductor.mapBPMChanges(SONG);
		Conductor.changeBPM(SONG.bpm);

		foregroundSprites = new FlxTypedGroup<BGSprite>();

		switch (SONG.song.toLowerCase())
		{
			case 'tutorial':
				dialogue = CoolUtil.coolTextFile(Paths.txt('tutorial/tutorialDialogue'));
			case 'bopeebo':
				dialogue = CoolUtil.coolTextFile(Paths.txt('bopeebo/bopeeboDialogue'));
			case 'fresh':
				dialogue = CoolUtil.coolTextFile(Paths.txt('fresh/freshDialogue'));
			case 'dadbattle':
				dialogue = CoolUtil.coolTextFile(Paths.txt('dadbattle/dadbattleDialogue'));
			case 'spookeez':
				dialogue = CoolUtil.coolTextFile(Paths.txt('spookeez/spookeezDialogue'));
			case 'south':
				dialogue = CoolUtil.coolTextFile(Paths.txt('south/southDialogue'));
			case 'pico':
				dialogue = CoolUtil.coolTextFile(Paths.txt('pico/picoDialogue'));
			case 'philly':
				dialogue = CoolUtil.coolTextFile(Paths.txt('philly/phillyDialogue'));
			case 'blammed':
				dialogue = CoolUtil.coolTextFile(Paths.txt('blammed/blammedDialogue'));
			case 'satin-panties':
				dialogue = CoolUtil.coolTextFile(Paths.txt('satin-panties/satin-pantiesDialogue'));
			case 'high': 
				dialogue = CoolUtil.coolTextFile(Paths.txt('high/highDialogue'));
			case 'milf':
				dialogue = CoolUtil.coolTextFile(Paths.txt('milf/milfDialogue'));
			case 'cocoa': 
				dialogue = CoolUtil.coolTextFile(Paths.txt('cocoa/cocoaDialogue'));
			case'eggnog':
			    dialogue = CoolUtil.coolTextFile(Paths.txt('eggnog/eggnogDialogue'));
			case 'senpai':
				dialogue = CoolUtil.coolTextFile(Paths.txt('senpai/senpaiDialogue'));
			case 'roses':
				dialogue = CoolUtil.coolTextFile(Paths.txt('roses/rosesDialogue'));
			case 'thorns':
				dialogue = CoolUtil.coolTextFile(Paths.txt('thorns/thornsDialogue'));
		}

		#if desktop
		// Making difficulty text for Discord Rich Presence.
		switch (storyDifficulty)
		{
			case 0:
				storyDifficultyText = "Easy";
			case 1:
				storyDifficultyText = "Normal";
			case 2:
				storyDifficultyText = "Hard";
		}

		iconRPC = SONG.player2;

		// To avoid having duplicate images in Discord assets
		switch (iconRPC)
		{
			case 'senpai-angry':
				iconRPC = 'senpai';
			case 'monster-christmas':
				iconRPC = 'monster';
			case 'mom-car':
				iconRPC = 'mom';
		}

		// String that contains the mode defined here so it isn't necessary to call changePresence for each mode
		if (isStoryMode)
		{
			detailsText = "Story Mode: Week " + storyWeek;
		}
		else
		{
			detailsText = "Freeplay";
		}

		// String for when the game is paused
		detailsPausedText = "Paused - " + detailsText;
		
		// Updating Discord Rich Presence.
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		#end

		switch (SONG.song.toLowerCase())
		{
                        case 'spookeez' | 'monster' | 'south': 
                        {
                                curStage = 'spooky';
	                          halloweenLevel = true;

		                  var hallowTex = Paths.getSparrowAtlas('halloween_bg');

	                          halloweenBG = new FlxSprite(-200, -100);
		                  halloweenBG.frames = hallowTex;
	                          halloweenBG.animation.addByPrefix('idle', 'halloweem bg0');
	                          halloweenBG.animation.addByPrefix('lightning', 'halloweem bg lightning strike', 24, false);
	                          halloweenBG.animation.play('idle');
	                          halloweenBG.antialiasing = true;
	                          add(halloweenBG);

		                  isHalloween = true;
		          }
		          case 'pico' | 'blammed' | 'philly': 
                        {
		                  curStage = 'philly';

		                  var bg:FlxSprite = new FlxSprite(-100).loadGraphic(Paths.image('philly/sky'));
		                  bg.scrollFactor.set(0.1, 0.1);
		                  add(bg);

	                          var city:FlxSprite = new FlxSprite(-10).loadGraphic(Paths.image('philly/city'));
		                  city.scrollFactor.set(0.3, 0.3);
		                  city.setGraphicSize(Std.int(city.width * 0.85));
		                  city.updateHitbox();
		                  add(city);

						  lightFadeShader = new BuildingShaders();
		                  phillyCityLights = new FlxTypedGroup<FlxSprite>();
		                  add(phillyCityLights);

		                  for (i in 0...5)
		                  {
		                          var light:FlxSprite = new FlxSprite(city.x).loadGraphic(Paths.image('philly/win' + i));
		                          light.scrollFactor.set(0.3, 0.3);
		                          light.visible = false;
		                          light.setGraphicSize(Std.int(light.width * 0.85));
		                          light.updateHitbox();
		                          light.antialiasing = true;
								  light.shader = lightFadeShader.shader;
		                          phillyCityLights.add(light);
		                  }

		                  var streetBehind:FlxSprite = new FlxSprite(-40, 50).loadGraphic(Paths.image('philly/behindTrain'));
		                  add(streetBehind);

	                          phillyTrain = new FlxSprite(2000, 360).loadGraphic(Paths.image('philly/train'));
		                  add(phillyTrain);

		                  trainSound = new FlxSound().loadEmbedded(Paths.sound('train_passes'));
		                  FlxG.sound.list.add(trainSound);

		                  // var cityLights:FlxSprite = new FlxSprite().loadGraphic(AssetPaths.win0.png);

		                  var street:FlxSprite = new FlxSprite(-40, streetBehind.y).loadGraphic(Paths.image('philly/street'));
	                          add(street);
						}
		          case 'milf' | 'satin-panties' | 'high':
		          {
		                  curStage = 'limo';
		                  defaultCamZoom = 0.90;

		                  var skyBG:FlxSprite = new FlxSprite(-120, -50).loadGraphic(Paths.image('limo/limoSunset'));
		                  skyBG.scrollFactor.set(0.1, 0.1);
		                  add(skyBG);

		                  var bgLimo:FlxSprite = new FlxSprite(-200, 480);
		                  bgLimo.frames = Paths.getSparrowAtlas('limo/bgLimo');
		                  bgLimo.animation.addByPrefix('drive', "background limo pink", 24);
		                  bgLimo.animation.play('drive');
		                  bgLimo.scrollFactor.set(0.4, 0.4);
		                  add(bgLimo);

		                  grpLimoDancers = new FlxTypedGroup<BackgroundDancer>();
		                  add(grpLimoDancers);

		                  for (i in 0...5)
		                  {
		                          var dancer:BackgroundDancer = new BackgroundDancer((370 * i) + 130, bgLimo.y - 400);
		                          dancer.scrollFactor.set(0.4, 0.4);
		                          grpLimoDancers.add(dancer);
		                  }

		                  var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
						  overlayShit.alpha = 0.3;
		                  add(overlayShit);
		                  // var shaderBullshit = new BlendModeEffect(new OverlayShader(), FlxColor.RED);

		                  // FlxG.camera.setFilters([new ShaderFilter(cast shaderBullshit.shader)]);

		                  // overlayShit.shader = shaderBullshit;

		                  limo = new FlxSprite(-120, 550);
		                  limo.frames = Paths.getSparrowAtlas('limo/limoDrive');
		                  limo.animation.addByPrefix('drive', "Limo stage", 24);
		                  limo.animation.play('drive');
		                  limo.antialiasing = true;

		                  fastCar = new FlxSprite(-300, 160).loadGraphic(Paths.image('limo/fastCarLol'));
		          }
		          case 'cocoa' | 'eggnog':
		          {
	                          curStage = 'mall';

		                  defaultCamZoom = 0.80;

		                  var bg:FlxSprite = new FlxSprite(-1000, -500).loadGraphic(Paths.image('christmas/bgWalls'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  upperBoppers = new FlxSprite(-240, -90);
		                  upperBoppers.frames = Paths.getSparrowAtlas('christmas/upperBop');
		                  upperBoppers.animation.addByPrefix('bop', "Upper Crowd Bob", 24, false);
		                  upperBoppers.antialiasing = true;
		                  upperBoppers.scrollFactor.set(0.33, 0.33);
		                  upperBoppers.setGraphicSize(Std.int(upperBoppers.width * 0.85));
		                  upperBoppers.updateHitbox();
		                  add(upperBoppers);

		                  var bgEscalator:FlxSprite = new FlxSprite(-1100, -600).loadGraphic(Paths.image('christmas/bgEscalator'));
		                  bgEscalator.antialiasing = true;
		                  bgEscalator.scrollFactor.set(0.3, 0.3);
		                  bgEscalator.active = false;
		                  bgEscalator.setGraphicSize(Std.int(bgEscalator.width * 0.9));
		                  bgEscalator.updateHitbox();
		                  add(bgEscalator);

		                  var tree:FlxSprite = new FlxSprite(370, -250).loadGraphic(Paths.image('christmas/christmasTree'));
		                  tree.antialiasing = true;
		                  tree.scrollFactor.set(0.40, 0.40);
		                  add(tree);

		                  bottomBoppers = new FlxSprite(-300, 140);
		                  bottomBoppers.frames = Paths.getSparrowAtlas('christmas/bottomBop');
		                  bottomBoppers.animation.addByPrefix('bop', 'Bottom Level Boppers', 24, false);
		                  bottomBoppers.antialiasing = true;
	                          bottomBoppers.scrollFactor.set(0.9, 0.9);
	                          bottomBoppers.setGraphicSize(Std.int(bottomBoppers.width * 1));
		                  bottomBoppers.updateHitbox();
		                  add(bottomBoppers);

		                  var fgSnow:FlxSprite = new FlxSprite(-600, 700).loadGraphic(Paths.image('christmas/fgSnow'));
		                  fgSnow.active = false;
		                  fgSnow.antialiasing = true;
		                  add(fgSnow);

		                  santa = new FlxSprite(-840, 150);
		                  santa.frames = Paths.getSparrowAtlas('christmas/santa');
		                  santa.animation.addByPrefix('idle', 'santa idle in fear', 24, false);
		                  santa.antialiasing = true;
		                  add(santa);
		          }
		          case 'winter-horrorland':
		          {
		                  curStage = 'mallEvil';
		                  var bg:FlxSprite = new FlxSprite(-400, -500).loadGraphic(Paths.image('christmas/evilBG'));
		                  bg.antialiasing = true;
		                  bg.scrollFactor.set(0.2, 0.2);
		                  bg.active = false;
		                  bg.setGraphicSize(Std.int(bg.width * 0.8));
		                  bg.updateHitbox();
		                  add(bg);

		                  var evilTree:FlxSprite = new FlxSprite(300, -300).loadGraphic(Paths.image('christmas/evilTree'));
		                  evilTree.antialiasing = true;
		                  evilTree.scrollFactor.set(0.2, 0.2);
		                  add(evilTree);

		                  var evilSnow:FlxSprite = new FlxSprite(-200, 700).loadGraphic(Paths.image("christmas/evilSnow"));
	                          evilSnow.antialiasing = true;
		                  add(evilSnow);
                        }
		          case 'senpai' | 'roses':
		          {
		                  curStage = 'school';

		                  // defaultCamZoom = 0.9;

						if (FlxG.save.data.exquisiteStage)
						{
		                  var bgSky = new FlxSprite().loadGraphic(Paths.image('erectweeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('erectweeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.3, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('erectweeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('erectweeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('erectweeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('erectweeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

						  var lights:FlxSprite = new FlxSprite(-25, 105);
		                  lights.frames = Paths.getSparrowAtlas('erectweeb/light');
		                  lights.animation.addByPrefix('light', 'lights', 24, true);
						  lights.animation.addByPrefix('no', 'no lights', 24, true);
		                  lights.animation.play('light');
		                  lights.scrollFactor.set(0.85, 0.85);
		                  add(lights);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
						  lights.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();
                          lights.updateHitbox();
		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);

						  if (SONG.song.toLowerCase() == 'roses')
							{
								bgGirls.getScared();
								lights.animation.play('no');						
					        }
							if (PreferencesMenu.getPref('pixel-shader'))
								FlxG.camera.setFilters([new ShaderFilter(new PixelParityShader(200, 200))]);
						}
						else
						{
						  var bgSky = new FlxSprite().loadGraphic(Paths.image('weeb/weebSky'));
		                  bgSky.scrollFactor.set(0.1, 0.1);
		                  add(bgSky);

		                  var repositionShit = -200;

		                  var bgSchool:FlxSprite = new FlxSprite(repositionShit, 0).loadGraphic(Paths.image('weeb/weebSchool'));
		                  bgSchool.scrollFactor.set(0.3, 0.90);
		                  add(bgSchool);

		                  var bgStreet:FlxSprite = new FlxSprite(repositionShit).loadGraphic(Paths.image('weeb/weebStreet'));
		                  bgStreet.scrollFactor.set(0.95, 0.95);
		                  add(bgStreet);

		                  var fgTrees:FlxSprite = new FlxSprite(repositionShit + 170, 130).loadGraphic(Paths.image('weeb/weebTreesBack'));
		                  fgTrees.scrollFactor.set(0.9, 0.9);
		                  add(fgTrees);

		                  var bgTrees:FlxSprite = new FlxSprite(repositionShit - 380, -800);
		                  var treetex = Paths.getPackerAtlas('weeb/weebTrees');
		                  bgTrees.frames = treetex;
		                  bgTrees.animation.add('treeLoop', [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18], 12);
		                  bgTrees.animation.play('treeLoop');
		                  bgTrees.scrollFactor.set(0.85, 0.85);
		                  add(bgTrees);

		                  var treeLeaves:FlxSprite = new FlxSprite(repositionShit, -40);
		                  treeLeaves.frames = Paths.getSparrowAtlas('weeb/petals');
		                  treeLeaves.animation.addByPrefix('leaves', 'PETALS ALL', 24, true);
		                  treeLeaves.animation.play('leaves');
		                  treeLeaves.scrollFactor.set(0.85, 0.85);
		                  add(treeLeaves);

		                  var widShit = Std.int(bgSky.width * 6);

		                  bgSky.setGraphicSize(widShit);
		                  bgSchool.setGraphicSize(widShit);
		                  bgStreet.setGraphicSize(widShit);
		                  bgTrees.setGraphicSize(Std.int(widShit * 1.4));
		                  fgTrees.setGraphicSize(Std.int(widShit * 0.8));
		                  treeLeaves.setGraphicSize(widShit);

		                  fgTrees.updateHitbox();
		                  bgSky.updateHitbox();
		                  bgSchool.updateHitbox();
		                  bgStreet.updateHitbox();
		                  bgTrees.updateHitbox();
		                  treeLeaves.updateHitbox();
		                  bgGirls = new BackgroundGirls(-100, 190);
		                  bgGirls.scrollFactor.set(0.9, 0.9);

		                  bgGirls.setGraphicSize(Std.int(bgGirls.width * daPixelZoom));
		                  bgGirls.updateHitbox();
		                  add(bgGirls);

						  if (SONG.song.toLowerCase() == 'roses')
							{
								bgGirls.getScared();					
					        }
							if (PreferencesMenu.getPref('pixel-shader'))
								FlxG.camera.setFilters([new ShaderFilter(new PixelParityShader(175, 175))]);
						}
		          }
		          case 'thorns':
		          {
					curStage = 'schoolEvil';

					if (FlxG.save.data.exquisiteStage)
						{
		                  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                      var posY = 200;
						
							var bg:FlxSprite = new FlxSprite(posX, posY);
							bg.frames = Paths.getSparrowAtlas('erectweeb/animatedEvilSchool');
							bg.animation.addByPrefix('idle', 'background 2', 60);
							bg.animation.play('idle');
							bg.scrollFactor.set(0.8, 0.9);
							bg.scale.set(6, 6);
							add(bg);

						  bgGirlevil = new BackgroundGirlsEvil(400, 400);
		                  bgGirlevil.scrollFactor.set(0.8, 0.8);
						  bgGirlevil.scale.set(6, 6);
						  add(bgGirlevil);

						  if (PreferencesMenu.getPref('pixel-shader'))
							{
							    FlxG.camera.setFilters([new ShaderFilter(new PixelParityShader(200, 200))]);
								
							    var effect = new MosaicEffect();
							    bg.shader = effect.shader;
							    effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 1.5, 1.5, {type: PINGPONG}, function(v)
							    {
								  effect.setStrength(v, v);
							    });
  
							    var effect = new MosaicEffect();
							    bgGirlevil.shader = effect.shader;
							    effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 1.5, 1.5, {type: PINGPONG}, function(v)
							    {
								  effect.setStrength(v, v);
							    });
							}
						}
						else
						{
						  var waveEffectBG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 3, 2);
		                  var waveEffectFG = new FlxWaveEffect(FlxWaveMode.ALL, 2, -1, 5, 2);

		                  var posX = 400;
	                      var posY = 200;

						  var bg:FlxSprite = new FlxSprite(posX, posY);
		                  bg.frames = Paths.getSparrowAtlas('weeb/animatedEvilSchool');
		                  bg.animation.addByPrefix('idle', 'background 2', 24);
		                  bg.animation.play('idle');
		                  bg.scrollFactor.set(0.8, 0.9);
		                  bg.scale.set(6, 6);
		                  add(bg);
						  
						  bgGirlevil = new BackgroundGirlsEvil(400, 400);
		                  bgGirlevil.scrollFactor.set(0.8, 0.8);
						  bgGirlevil.scale.set(6, 6);
						  add(bgGirlevil);

						  if (PreferencesMenu.getPref('pixel-shader'))
							{
							    FlxG.camera.setFilters([new ShaderFilter(new PixelParityShader(175, 175))]);
								
							    var effect = new MosaicEffect();
							    bg.shader = effect.shader;
							    effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 1.5, 1.5, {type: PINGPONG}, function(v)
							    {
								  effect.setStrength(v, v);
							    });
  
							    var effect = new MosaicEffect();
							    bgGirlevil.shader = effect.shader;
							    effectTween = FlxTween.num(MosaicEffect.DEFAULT_STRENGTH, 1.5, 1.5, {type: PINGPONG}, function(v)
							    {
								  effect.setStrength(v, v);
							    });
							}
						}

		          }
				  case 'guns' | 'stress' | 'ugh':
				  {
						defaultCamZoom = 0.9;

						curStage = 'tank';
						
						tankSky = new BGSprite('tankSky', -400, -400, 0, 0);
						add(tankSky);
						
						var clouds:BGSprite = new BGSprite('tankClouds', FlxG.random.int(-700, -100), FlxG.random.int(-20, 20), 0.1, 0.1);
						clouds.active = true;
						clouds.velocity.x = FlxG.random.float(5, 15);
						add(clouds);
						
						var mountains:BGSprite = new BGSprite('tankMountains', -300, -20, 0.2, 0.2);
						mountains.setGraphicSize(Std.int(mountains.width * 1.2));
						mountains.updateHitbox();
						add(mountains);
						
						var buildings:BGSprite = new BGSprite('tankBuildings', -200, 0, 0.3, 0.3);
						buildings.setGraphicSize(Std.int(buildings.width * 1.1));
						buildings.updateHitbox();
						add(buildings);
						
						var ruins:BGSprite = new BGSprite('tankRuins', -200, 0, 0.35, 0.35);
						ruins.setGraphicSize(Std.int(ruins.width * 1.1));
						ruins.updateHitbox();
						add(ruins);
						
						var smokeL:BGSprite = new BGSprite('smokeLeft', -200, -100, 0.4, 0.4, ['SmokeBlurLeft'], true);
						add(smokeL);
						
						var smokeR:BGSprite = new BGSprite('smokeRight', 1100, -100, 0.4, 0.4, ['SmokeRight'], true);
						add(smokeR);
						
						tankWatchtower = new BGSprite('tankWatchtower', 100, 50, 0.5, 0.5, ['watchtower gradient color']);
						add(tankWatchtower);
						
						tankGround = new BGSprite('tankRolling', 300, 300, 0.5, 0.5, ['BG tank w lighting'], true);
						add(tankGround);
						
						tankmanRun = new FlxTypedGroup<TankmenBG>();
						add(tankmanRun);
						
						var ground:BGSprite = new BGSprite('tankGround', -420, -150);
						ground.setGraphicSize(Std.int(ground.width * 1.15));
						ground.updateHitbox();
						add(ground);
						moveTank();

						var tankdude0:BGSprite = new BGSprite('tank0', -500, 650, 1.7, 1.5, ['fg']);
						foregroundSprites.add(tankdude0);
						
						var tankdude1:BGSprite = new BGSprite('tank1', -300, 750, 2, 0.2, ['fg']);
						foregroundSprites.add(tankdude1);
						
						var tankdude2:BGSprite = new BGSprite('tank2', 450, 940, 1.5, 1.5, ['foreground']);
						foregroundSprites.add(tankdude2);
						
						var tankdude4:BGSprite = new BGSprite('tank4', 1300, 900, 1.5, 1.5, ['fg']);
						foregroundSprites.add(tankdude4);
						
						var tankdude5:BGSprite = new BGSprite('tank5', 1620, 700, 1.5, 1.5, ['fg']);
						foregroundSprites.add(tankdude5);
						
						var tankdude3:BGSprite = new BGSprite('tank3', 1300, 1200, 3.5, 2.5, ['fg']);
						foregroundSprites.add(tankdude3);
				  }
		          default:
		          {
		                  defaultCamZoom = 0.9;
						  curStage = 'stage';
		                  var bg:BGSprite = new BGSprite('stageback', -600, -200, 0.9, 0.9);
		                  add(bg);

		                  var stageFront:FlxSprite = new FlxSprite(-650, 600).loadGraphic(Paths.image('stagefront'));
		                  stageFront.setGraphicSize(Std.int(stageFront.width * 1.1));
		                  stageFront.updateHitbox();
		                  stageFront.antialiasing = true;
		                  stageFront.scrollFactor.set(0.9, 0.9);
		                  stageFront.active = false;
		                  add(stageFront);

		                  var stageCurtains:FlxSprite = new FlxSprite(-500, -300).loadGraphic(Paths.image('stagecurtains'));
		                  stageCurtains.setGraphicSize(Std.int(stageCurtains.width * 0.9));
		                  stageCurtains.updateHitbox();
		                  stageCurtains.antialiasing = true;
		                  stageCurtains.scrollFactor.set(1.3, 1.3);
		                  stageCurtains.active = false;

		                  add(stageCurtains);
		          }
              }

		var gfVersion:String = 'gf';

		switch (curStage)
		{
			case 'limo':
				gfVersion = 'gf-car';
			case 'mall' | 'mallEvil':
				gfVersion = 'gf-christmas';
			case 'school':
				gfVersion = 'gf-pixel';
			case 'schoolEvil':
				gfVersion = 'gf-pixel';
			case 'tank':
				gfVersion = 'gf-tankmen';
		}

		if (SONG.song.toLowerCase() == 'stress')
			gfVersion = 'pico-speaker';

		gf = new Character(400, 130, gfVersion);
		gf.scrollFactor.set(0.95, 0.95);
		if (gfVersion == 'pico-speaker')
		{
			gf.x -= 50;
			gf.y -= 200;
			var tankmen:TankmenBG = new TankmenBG(20, 500, true);
			tankmen.strumTime = 10;
			tankmen.resetShit(20, 600, true);
			tankmanRun.add(tankmen);
			for (i in 0...TankmenBG.animationNotes.length)
			{
				if (FlxG.random.bool(16))
				{
					var man:TankmenBG = tankmanRun.recycle(TankmenBG);
					man.strumTime = TankmenBG.animationNotes[i][0];
					man.resetShit(500, 200 + FlxG.random.int(50, 100), TankmenBG.animationNotes[i][1] < 2);
					tankmanRun.add(man);
				}
			}
		}

		dad = new Character(100, 100, SONG.player2);

		camPos = new FlxPoint(dad.getGraphicMidpoint().x, dad.getGraphicMidpoint().y);

		switch (SONG.player2)
		{
			case 'gf':
				dad.setPosition(gf.x, gf.y);
				gf.visible = false;
				if (isStoryMode)
				{
					camPos.x += 600;
					tweenCamIn();
				}

			case "spooky":
				dad.y += 200;
			case "monster":
				dad.y += 100;
			case 'monster-christmas':
				dad.y += 130;
			case 'dad':
				camPos.x += 400;
			case 'pico':
				camPos.x += 600;
				dad.y += 300;
			case 'parents-christmas':
				dad.x -= 500;
			case 'senpai':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'senpai-angry':
				dad.x += 150;
				dad.y += 360;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case 'spirit':
				dad.x -= 150;
				dad.y += 100;
				camPos.set(dad.getGraphicMidpoint().x + 300, dad.getGraphicMidpoint().y);
			case "tankman":
				dad.y += 180;
		}

		boyfriend = new Boyfriend(770, 450, SONG.player1);

		// REPOSITIONING PER STAGE
		switch (curStage)
		{
			case 'limo':
				boyfriend.y -= 220;
				boyfriend.x += 260;

				resetFastCar();
				add(fastCar);

			case 'mall':
				boyfriend.x += 200;

			case 'mallEvil':
				boyfriend.x += 320;
				dad.y -= 80;
			case 'school':
				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'schoolEvil':
				// trailArea.scrollFactor.set();

				var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
				// evilTrail.changeValuesEnabled(false, false, false, false);
				// evilTrail.changeGraphic()
				add(evilTrail);
				// evilTrail.scrollFactor.set(1.1, 1.1);

				boyfriend.x += 200;
				boyfriend.y += 220;
				gf.x += 180;
				gf.y += 300;
			case 'tank':
				gf.y += 10;
				gf.x -= 30;
				boyfriend.x += 40;
				boyfriend.y += 0;
				dad.y += 60;
				dad.x -= 80;
				if (gfVersion != 'pico-speaker')
				{
					gf.x -= 170;
					gf.y -= 75;
				}
		}

		add(gf);

		gfCutsceneLayer = new FlxTypedGroup<FlxAnimate>();
		add(gfCutsceneLayer);
		
		bfTankCutsceneLayer = new FlxTypedGroup<FlxAnimate>();
		add(bfTankCutsceneLayer);

		gfCutsceneLayerFlxSprite = new FlxTypedGroup<FlxSprite>();
		add(gfCutsceneLayerFlxSprite);

		bfTankCutsceneLayerFlxSprite = new FlxTypedGroup<FlxSprite>();
		add(bfTankCutsceneLayerFlxSprite);

		// Shitty layering but whatev it works LOL
		if (curStage == 'limo')
			add(limo);
		if (FlxG.save.data.exquisiteStage)
			{
				switch (curStage)
				{
					case 'tack':
						var backrtx:FlxSprite = new FlxSprite(-400, 10).loadGraphic(Paths.image('rtx/backrtx'));
				        add(backrtx);
				}
			}
		add(dad);
		add(boyfriend);
        if (FlxG.save.data.exquisiteStage)
		{
			switch (curStage)
		    {
			case 'spooky':
				{
					var bgrtx:FlxSprite = new FlxSprite(-200, 10).loadGraphic(Paths.image('rtx/bgrtx'));
				    add(bgrtx);
				}
			case 'philly':
				{
					var bgrtx:FlxSprite = new FlxSprite(-200, 10).loadGraphic(Paths.image('philly/rtx/bgrtx'));
				    bgrtx.alpha = 0.4;
				    add(bgrtx);
				}		
			case 'limo':
				{
					var overlayShit:FlxSprite = new FlxSprite(-500, -600).loadGraphic(Paths.image('limo/limoOverlay'));
		            overlayShit.alpha = 0.3;
		            add(overlayShit);
				}	
			case 'mall' | 'mallEvil':
				{
                    var bgrtx:FlxSprite = new FlxSprite(-790, -600).loadGraphic(Paths.image('christmas/bgrtx'));
				    add(bgrtx);
				}
			case 'tank':
				{
					var bgrtx:FlxSprite = new FlxSprite(-400, 10).loadGraphic(Paths.image('rtx/bgrtx'));
					bgrtx.alpha = 0.9;
				    add(bgrtx);
				}
			default:
				{
					switch(SONG.song.toLowerCase())
					{
					case 'tutorial':
						{
							var bgrtx:BGSprite = new BGSprite('T-stagertx', -600, -200, 0.9, 0.9);
					        bgrtx.alpha = 0.2;
				            add(bgrtx);
						}
					case 'bopeebo' | 'fresh' |'dadbattle':
						{
                            var bgrtx:BGSprite = new BGSprite('D-stagertx', -600, -200, 0.9, 0.9);
					        bgrtx.alpha = 0.2;
				            add(bgrtx);
						}
			        case 'senpai':
						{
                            var bgrtx:BGSprite = new BGSprite('D-stagertx', -600, -200, 0.9, 0.9);
					        bgrtx.alpha = 0.2;
				            add(bgrtx);
						}
					}
				}
		   }
		}
		

		add(foregroundSprites);

		var doof:DialogueBox = new DialogueBox(false, dialogue);
		// doof.x += 70;
		// doof.y = FlxG.height * 0.5;
		doof.scrollFactor.set();
		doof.finishThing = startCountdown;

		Conductor.songPosition = -5000;

		strumLine = new FlxSprite(0, 50).makeGraphic(FlxG.width, 10);
		if (PreferencesMenu.getPref('downscroll'))
			strumLine.y = FlxG.height - 150;
		strumLine.scrollFactor.set();

		strumLineNotes = new FlxTypedGroup<FlxSprite>();
		add(strumLineNotes);

		add(grpNoteSplashes);

		playerStrums = new FlxTypedGroup<FlxSprite>();
		player2Strums = new FlxTypedGroup<FlxSprite>();
		// startCountdown();

		generateSong();

		// add(strumLine);

		camFollow = new FlxObject(0, 0, 1, 1);

		camFollow.setPosition(camPos.x, camPos.y);

		if (prevCamFollow != null)
		{
			camFollow = prevCamFollow;
			prevCamFollow = null;
		}

		add(camFollow);

		FlxG.camera.follow(camFollow, LOCKON, 0.04);
		// FlxG.camera.setScrollBounds(0, FlxG.width, 0, FlxG.height);
		FlxG.camera.zoom = defaultCamZoom;
		FlxG.camera.focusOn(camFollow.getPosition());

		FlxG.worldBounds.set(0, 0, FlxG.width, FlxG.height);

		FlxG.fixedTimestep = false;

		    healthBarBG = new FlxSprite(0, FlxG.height * 0.9).loadGraphic(Paths.image('healthBar'));
			healthBarBG.screenCenter(X);
			healthBarBG.scrollFactor.set();
			if (PreferencesMenu.getPref('downscroll'))
				healthBarBG.y = FlxG.height * 0.1;

			healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, RIGHT_TO_LEFT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
				'health', 0, 2);
				if (PreferencesMenu.getPref('mirror-mode'))
				healthBar = new FlxBar(healthBarBG.x + 4, healthBarBG.y + 4, LEFT_TO_RIGHT, Std.int(healthBarBG.width - 8), Std.int(healthBarBG.height - 8), this,
				'health', 0, 2);
			healthBar.scrollFactor.set();

		switch (SONG.song.toLowerCase())
		{
			case 'senpai' | 'roses' | 'thorns':
			healthBar.createFilledBar(0xFFFF7777, 0xFFACFF77);
		    default:
	        healthBar.createFilledBar(0xFFFF0000, 0xFF00FF00);
        }
            add(healthBar);
            add(healthBarBG);

		timeTxt = new FlxText(500, FlxG.height * 0, "", 20);
		timeTxt.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		timeTxt.scrollFactor.set();
		if (PreferencesMenu.getPref('downscroll'))
			timeTxt.y = FlxG.height * 0.95;

		timeBarBG = new FlxSprite(0, FlxG.height * 0).loadGraphic(Paths.image('timeBar'));
		timeBarBG.screenCenter(X);
		timeBarBG.scrollFactor.set();
		if (PreferencesMenu.getPref('downscroll'))
			{
				timeBarBG.y = FlxG.height * 0.95;
				timeBarBG.flipY = true;
			}	

		add(timeBarBG);
        add(timeTxt);

		scoreTxt = new FlxText(healthBarBG.x + healthBarBG.width / 2 - 380, healthBarBG.y + 40, 0, "", 20);
		scoreTxt.setFormat(Paths.font("funkin.otf"), 30, FlxColor.WHITE, RIGHT, OUTLINE, FlxColor.BLACK);
		scoreTxt.scrollFactor.set();

		iconP1 = new HealthIcon(SONG.player1, true);
		iconP1.y = healthBar.y - (iconP1.height / 2);
		add(iconP1);

		iconP2 = new HealthIcon(SONG.player2, false);
		iconP2.y = healthBar.y - (iconP2.height / 2);
		add(iconP2);
		add(scoreTxt);

		grpNoteSplashes.cameras = [camHUD];
		strumLineNotes.cameras = [camHUD];
		notes.cameras = [camHUD];
		healthBar.cameras = [camHUD];
		healthBarBG.cameras = [camHUD];
		timeBarBG.cameras = [camHUD];
		scoreTxt.cameras = [camHUD];
		iconP1.cameras = [camHUD];
		iconP2.cameras = [camHUD];
		doof.cameras = [camHUD];
		timeTxt.cameras = [camHUD];
		
		// if (SONG.song == 'South')
		// FlxG.camera.alpha = 0.7;
		// UI_camera.zoom = 1;

		// cameras = [FlxG.cameras.list[1]];
		startingSong = true;

		if (isStoryMode && !seenCutscene)
		{
			seenCutscene = true;
			switch (curSong.toLowerCase())
			{
				case "winter-horrorland":
					var blackScreen:FlxSprite = new FlxSprite(0, 0).makeGraphic(Std.int(FlxG.width * 2), Std.int(FlxG.height * 2), FlxColor.BLACK);
					add(blackScreen);
					blackScreen.scrollFactor.set();
					camHUD.visible = false;

					new FlxTimer().start(0.1, function(tmr:FlxTimer)
					{
						remove(blackScreen);
						FlxG.sound.play(Paths.sound('Lights_Turn_On'));
						camFollow.y = -2050;
						camFollow.x += 200;
						FlxG.camera.focusOn(camFollow.getPosition());
						FlxG.camera.zoom = 1.5;

						new FlxTimer().start(0.8, function(tmr:FlxTimer)
						{
							camHUD.visible = true;
							remove(blackScreen);
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, 2.5, {
								ease: FlxEase.quadInOut,
								onComplete: function(twn:FlxTween)
								{
									startCountdown();
								}
							});
						});
					});
				case 'tutorial':
					intro(doof);
				case 'bopeebo':
					intro(doof);
				case 'fresh':
					intro(doof);
				case 'dadbattle':
					intro(doof);
				case 'spookeez':
					intro(doof);
				case 'south':
					intro(doof);
				case 'pico':
					intro(doof);
				case 'philly':
					intro(doof);
				case 'blammed':
					intro(doof);
				case 'satin-panties':
					intro(doof);
				case 'high':
					intro(doof);
				case 'milf':
					intro(doof);
				case 'cocoa':
					intro(doof);
				case 'eggnog':
					intro(doof);
				case 'senpai':
					schoolIntro(doof);
				case 'roses':
					FlxG.sound.play(Paths.sound('ANGRY'));
					schoolIntro(doof);
				case 'thorns':
					schoolIntro(doof);
				case 'ugh':
					ughIntro();
				case 'guns':
					gunsIntro();
				case 'stress':
					stressIntro();
				default:
					startCountdown();
			}
		}
		else
		{
			switch (curSong.toLowerCase())
			{
				default:
					startCountdown();
			}
		}

		super.create();
	}

	function ughIntro():Void
	{
		inCutscene = true;
		#if web
			var black:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.scrollFactor.set();
			add(black);
			new FlxVideo('video/ughCutscene.mp4').finishCallback = function()
			{
				remove(black);
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 5, {ease: FlxEase.quadInOut});
				startCountdown();
				cameraMovement();
			};
			FlxG.camera.zoom = defaultCamZoom * 1.2;
			camFollow.x += 100;
			camFollow.y += 100;
		#else
			dad.visible = false;
			var tankTalk1:FlxSprite = new FlxSprite(-20, 320);
			tankTalk1.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong1');
			tankTalk1.animation.addByPrefix('wellWell', 'TANK TALK 1 P1', 24, false);
			tankTalk1.animation.addByPrefix('killYou', 'TANK TALK 1 P2', 24, false);
			tankTalk1.antialiasing = true;
			gfCutsceneLayerFlxSprite.add(tankTalk1);
			camHUD.visible = false;
			FlxG.camera.zoom = defaultCamZoom * 1.2;
			
			new FlxTimer().start(0.01, function(tmr:FlxTimer)
			{
				FlxG.sound.playMusic(Paths.music('DISTORTO'), 0.5);
				tankTalk1.animation.play('wellWell');
				FlxG.sound.play(Paths.sound('wellWellWell'));
				camFollow.y += 100;
				new FlxTimer().start(3, function(tmr:FlxTimer)
				{
					camFollow.x += 800;
					camFollow.y += 100;
					new FlxTimer().start(1.5, function(tmr:FlxTimer)
					{
						boyfriend.playAnim('singUP');
						FlxG.sound.play(Paths.sound('bfBeep'), 1, false, null, true, function()
						{
							boyfriend.playAnim('idle');
						});
					});
					new FlxTimer().start(3, function(tmr:FlxTimer)
					{
						camFollow.x -= 800;
						camFollow.y -= 100;
						tankTalk1.animation.play('killYou');
						FlxG.sound.play(Paths.sound('killYou'));
						new FlxTimer().start(6.1, function(tmr:FlxTimer)
						{
							FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 20, {ease: FlxEase.quadInOut});
							FlxG.sound.music.fadeOut();
							new FlxTimer().start((Conductor.stepCrochet / 1000) * 20, function(tmr:FlxTimer)
							{
								dad.visible = true;
								tankTalk1.destroy();
							});
							cameraMovement();
							startCountdown();
							camHUD.visible = true;
						});
					});
				});
			});
		#end
	}

	function gunsIntro():Void
	{
		inCutscene = true;
		#if web
			var black:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.scrollFactor.set();
			add(black);
			new FlxVideo('video/gunsCutscene.mp4').finishCallback = function()
			{
				remove(black);
				FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 5, {ease: FlxEase.quadInOut});
				startCountdown();
				cameraMovement();
			};
		#else
			dad.visible = false;
			var tankTalk1:FlxSprite = new FlxSprite(-20, 320);
			tankTalk1.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong2');
			tankTalk1.animation.addByPrefix('tightBars', 'TANK TALK 2', 24, false);
			tankTalk1.antialiasing = true;
			gfCutsceneLayerFlxSprite.add(tankTalk1);
			camHUD.visible = false;

			new FlxTimer().start(0.05, function(tmr:FlxTimer)
			{
				FlxG.sound.playMusic(Paths.music('DISTORTO'), 0.5);
				tankTalk1.animation.play('tightBars');
				camFollow.setPosition(dad.getMidpoint().x + 15, dad.getMidpoint().y - 150);	
				FlxG.camera.follow(camFollow, LOCKON, 0.04);
				FlxTween.tween(FlxG.camera, {zoom: 1.2}, 4.01, {ease: FlxEase.quadInOut});
				FlxG.sound.play(Paths.sound('tankSong2'));

				new FlxTimer().start(4.01, function(tmr:FlxTimer)
				{
					gf.playAnim('sad', true);
					FlxTween.tween(FlxG.camera, {zoom: 1.3}, 0.4, {ease: FlxEase.quadInOut,
						onComplete: function(twn:FlxTween)
						{
							FlxTween.tween(FlxG.camera, {zoom: 1.2}, 0.6, {ease: FlxEase.quadInOut});
						}});
				});

				new FlxTimer().start(11, function(tmr:FlxTimer)
				{
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 25, {ease: FlxEase.quadInOut});
					FlxG.sound.music.fadeOut();
					new FlxTimer().start(10, function(tmr:FlxTimer)
					{
						dad.visible = true;
						tankTalk1.destroy();
					});
					cameraMovement();
					startCountdown();
					camHUD.visible = true;
				});
			});
		#end
	}

	function stressIntro():Void
	{
		inCutscene = true;
		#if web
			var black:FlxSprite = new FlxSprite(-200, -200).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.scrollFactor.set();
			add(black);
			if (!PreferencesMenu.getPref('censor-naughty'))
			{
				new FlxVideo('video/stressCutsceneCensor.mp4').finishCallback = function()
				{
					remove(black);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 5, {ease: FlxEase.quadInOut});
					startCountdown();
					cameraMovement();
				};
			}
			else
			{
				new FlxVideo('video/stressCutscene.mp4').finishCallback = function()
				{
					remove(black);
					FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 5, {ease: FlxEase.quadInOut});
					startCountdown();
					cameraMovement();
				};
			}
		#else
			dad.visible = false;
			gf.visible = false;
			boyfriend.visible = false;
			var gfCutscene1:FlxSprite = new FlxSprite(210, 79);
			gfCutscene1.scrollFactor.set(0.95, 0.95);
			gfCutscene1.frames = Paths.getSparrowAtlas('cutsceneStuff/gfTankmenCutscene');
			gfCutscene1.animation.addByPrefix('idleLoop', 'GF Dancing at Gunpoint', 24, true);
			gfCutscene1.animation.play('idleLoop', true);
			gfCutscene1.antialiasing = true;
			gfCutsceneLayerFlxSprite.add(gfCutscene1);
			var gfCutscene2:FlxSprite = new FlxSprite(-11, -384);
			gfCutscene2.scrollFactor.set(0.95, 0.95);
			gfCutscene2.frames = Paths.getSparrowAtlas('cutsceneStuff/gfTankmenCutsceneDemon');
			gfCutscene2.animation.addByPrefix('gfDemon', 'GF Turnin Demon W Effect', 24, false);
			gfCutscene2.antialiasing = true;
			gfCutscene2.visible = false;
			gfCutsceneLayerFlxSprite.add(gfCutscene2);
			var gfCutscene3:FlxSprite = new FlxSprite(-529, -325);
			gfCutscene3.scrollFactor.set(0.95, 0.95);
			if (!PreferencesMenu.getPref('censor-naughty'))
			{
				gfCutscene3.frames = AtlasFrameMaker.construct('assets/images/cutsceneStuff/stress/picoArrivesCENSORED');
				gfCutscene3.x += 32;
			}
			else
			{
				gfCutscene3.frames = AtlasFrameMaker.construct('assets/images/cutsceneStuff/stress/picoArrives');
			}	
			gfCutscene3.antialiasing = true;
			gfCutscene3.visible = false;
			gfCutsceneLayerFlxSprite.add(gfCutscene3);
			var tankTalk1:FlxSprite = new FlxSprite(-20, 320);
			if (!PreferencesMenu.getPref('censor-naughty'))
			{
				tankTalk1.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong3P1CENSORED');
			}
			else
			{
				tankTalk1.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong3P1');
			}
			tankTalk1.animation.addByPrefix('godEffingDammit', 'TANK TALK 3 P1', 24, false);
			tankTalk1.antialiasing = true;
			gfCutsceneLayerFlxSprite.add(tankTalk1);
			var tankTalk2:FlxSprite = new FlxSprite(73, 325);
			if (!PreferencesMenu.getPref('censor-naughty'))
			{
				tankTalk2.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong3P2CENSORED');
			}
			else
			{
				tankTalk2.frames = Paths.getSparrowAtlas('cutsceneStuff/tankTalkSong3P2');
			}
			tankTalk2.animation.addByPrefix('lookWhoItIs', 'TANK TALK 3 P2', 24, false);
			tankTalk2.antialiasing = true;
			tankTalk2.visible = false;
			gfCutsceneLayerFlxSprite.add(tankTalk2);
			var bfCutscene1:FlxSprite = new FlxSprite(810, 470).loadGraphic(Paths.image('cutsceneStuff/bfIdleStatic'));
			bfCutscene1.antialiasing = true;
			bfTankCutsceneLayerFlxSprite.add(bfCutscene1);
			camHUD.visible = false;

			new FlxTimer().start(0.05, function(tmr:FlxTimer)
			{
				tankTalk1.animation.play('godEffingDammit');
				camFollow.setPosition(dad.getMidpoint().x + 260, dad.getMidpoint().y - 130);	
				FlxG.camera.follow(camFollow, LOCKON, 0.02);
				FlxTween.tween(FlxG.camera, {zoom: 1.0}, 1.2, {ease: FlxEase.quadInOut});
				if (!PreferencesMenu.getPref('censor-naughty'))
				{
					FlxG.sound.play(Paths.sound('song3censor'));
				}
				else
				{
					FlxG.sound.play(Paths.sound('stressCutscene'));
				}

				new FlxTimer().start(15.2, function(tmr:FlxTimer)
				{
					FlxTween.tween(FlxG.camera, {zoom: 1.3}, 2.084, {ease: FlxEase.quadInOut});
					camFollow.x += 150;
					camFollow.y -= 190;
					gfCutsceneLayerFlxSprite.remove(gfCutscene1);
					gfCutscene2.visible = true;
					gfCutscene2.animation.play('gfDemon', true);
					gfCutscene2.animation.finishCallback = function(gfDemonAnim:String)
					{
						gfCutscene2.destroy();
						gfCutscene3.visible = true;
						gfCutscene3.animation.addByPrefix('picoArrives', 'PICO ARRIVES', 24, false);
						gfCutscene3.animation.play('picoArrives', true);
						gfCutscene3.animation.finishCallback = function(picoArriveAnim:String)
						{
							gfCutscene3.destroy();
							gf.visible = true;
						}
					}
					new FlxTimer().start(2.085, function(tmr:FlxTimer) 
					{
						tankSky.x += 20;
						FlxG.camera.zoom = 0.78;
					});
				});

				new FlxTimer().start(17.6, function(tmr:FlxTimer)
				{
					bfCutscene1.destroy();
					boyfriend.visible = true;
					boyfriend.playAnim('bfCatch');
					boyfriend.animation.finishCallback = function(boyfriendCatchAnim:String)
					{
						boyfriend.animation.addByIndices('idleStatic', "BF idle dance w gf", [13], "", 24, false);
						boyfriend.playAnim('idleStatic');
					}
				});

				new FlxTimer().start(19.311, function(tmr:FlxTimer)
				{
					tankTalk1.destroy();
					tankTalk2.visible = true;
					tankTalk2.animation.play('lookWhoItIs');
					new FlxTimer().start(0.9, function(tmr:FlxTimer)
					{
						camFollow.x -= 100;
						camFollow.y += 200;
					});
				});

				new FlxTimer().start(31.2, function(tmr:FlxTimer)
				{
					camFollow.x += 440;
					camFollow.y += 130;
					FlxG.camera.focusOn(camFollow.getPosition());
					FlxG.camera.zoom = 1.3;
					new FlxTimer().start(0.01, function(tmr:FlxTimer)
					{
						FlxTween.tween(FlxG.camera, {zoom: 1.4}, 0.4, {ease: FlxEase.elasticOut});
					});
					boyfriend.playAnim('singUPmiss');
					tankSky.x -= 20;
					foregroundSprites.visible = false;
					new FlxTimer().start(1.2, function(tmr:FlxTimer)
					{
						camFollow.x -= 430;
						camFollow.y -= 140;
						FlxG.camera.zoom = 0.95;
						FlxG.camera.focusOn(camFollow.getPosition());
						boyfriend.playAnim('idleStatic');
						foregroundSprites.visible = true;
					});
				});

				new FlxTimer().start(34, function(tmr:FlxTimer)
				{
					FlxG.sound.music.fadeOut();
					new FlxTimer().start(1, function(tmr:FlxTimer)
					{
						FlxTween.tween(FlxG.camera, {zoom: defaultCamZoom}, (Conductor.stepCrochet / 1000) * 20, {ease: FlxEase.quadInOut});
						
						new FlxTimer().start((Conductor.stepCrochet / 1000) * 20, function(tmr:FlxTimer)
						{
							dad.visible = true;
							tankTalk2.destroy();
						});
						cameraMovement();
						startCountdown();
						camHUD.visible = true;
					});
				});
			});
		#end
	}

	function initDiscord()
	{
		// Angel here.
		// I have no idea what this function does.
		// The function is still in the compiled code, but everything inside was ommited since it was compiled for the HTML target.
		// Just leaving this here in case I ever figure out what it was used for.
		// If I never find a use for this, sorry, but this is just staying here cause it's a part of v0.2.8's code lol.
	}

	function intro(?dialogueBox:DialogueBox):Void
		//This is a new event for fact dialogue.
		{
			var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
			black.scrollFactor.set();
			add(black);
	
			camFollow.setPosition(camPos.x, camPos.y);
	
			new FlxTimer().start(0.1, function(tmr:FlxTimer)
			{
				black.alpha -= 0.15;
	
				if (black.alpha > 0)
				{
					tmr.reset(0.1);
				}
				else
				{
					if (dialogueBox != null)
					{
						inCutscene = true;
						add(dialogueBox);
					}

					else
						startCountdown();
	
				}
			});
		}
	function schoolIntro(?dialogueBox:DialogueBox):Void
	{
		var black:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, FlxColor.BLACK);
		black.scrollFactor.set();
		add(black);

		var red:FlxSprite = new FlxSprite(-100, -100).makeGraphic(FlxG.width * 2, FlxG.height * 2, 0xFFff1b31);
		red.scrollFactor.set();

		var senpaiEvil:FlxSprite = new FlxSprite();
		senpaiEvil.frames = Paths.getSparrowAtlas('weeb/senpaiCrazy');
		senpaiEvil.animation.addByPrefix('idle', 'Senpai Pre Explosion', 24, false);
		senpaiEvil.setGraphicSize(Std.int(senpaiEvil.width * daPixelZoom));
		senpaiEvil.scrollFactor.set();
		senpaiEvil.updateHitbox();
		senpaiEvil.screenCenter();
		senpaiEvil.x += senpaiEvil.width / 5;

		camFollow.setPosition(camPos.x, camPos.y);

		if (SONG.song.toLowerCase() == 'roses' || SONG.song.toLowerCase() == 'thorns')
		{
			remove(black);

			if (SONG.song.toLowerCase() == 'thorns')
			{
				add(red);
				camHUD.visible = false;
			}
		}

		new FlxTimer().start(0.3, function(tmr:FlxTimer)
		{
			black.alpha -= 0.15;

			if (black.alpha > 0)
			{
				tmr.reset(0.3);
			}
			else
			{
				if (dialogueBox != null)
				{
					inCutscene = true;

					if (SONG.song.toLowerCase() == 'thorns')
					{
						add(senpaiEvil);
						senpaiEvil.alpha = 0;
						new FlxTimer().start(0.3, function(swagTimer:FlxTimer)
						{
							senpaiEvil.alpha += 0.15;
							if (senpaiEvil.alpha < 1)
							{
								swagTimer.reset();
							}
							else
							{
								senpaiEvil.animation.play('idle');
								FlxG.sound.play(Paths.sound('Senpai_Dies'), 1, false, null, true, function()
								{
									remove(senpaiEvil);
									remove(red);
									FlxG.camera.fade(FlxColor.WHITE, 0.01, true, function()
									{
										add(dialogueBox);
										camHUD.visible = true;
									}, true);
								});
								new FlxTimer().start(3.2, function(deadTime:FlxTimer)
								{
									FlxG.camera.fade(FlxColor.WHITE, 1.6, false);
								});
							}
						});
					}
					else
					{
						add(dialogueBox);
					}
				}
				else
					startCountdown();

				remove(black);
			}
		});
	}

	var startTimer:FlxTimer = new FlxTimer();
	var perfectMode:Bool = false;

	function startCountdown():Void
	{
		inCutscene = false;

		camHUD.visible = true;

		generateStaticArrows(0);
		generateStaticArrows(1);

		talking = false;
		startedCountdown = true;
		Conductor.songPosition = 0;
		Conductor.songPosition -= Conductor.crochet * 5;

		var swagCounter:Int = 0;

		startTimer.start(Conductor.crochet / 1000, function(tmr:FlxTimer)
		{
			if (swagCounter % gfSpeed == 0)
			{
				gf.dance();
			}
			if (swagCounter % 2 == 0)
			{
				if (!boyfriend.animation.curAnim.name.startsWith('sing'))
					boyfriend.playAnim('idle');
				if (!dad.animation.curAnim.name.startsWith('sing'))
					dad.dance();
			}
			else if (dad.curCharacter == 'spooky' && !dad.animation.curAnim.name.startsWith('sing'))
				dad.dance();

			if (generatedMusic)
			{
				notes.members.sort(function (Obj1:Note, Obj2:Note)
				{
					return sortNotes(FlxSort.DESCENDING, Obj1, Obj2);
				});
			}

			var introAssets:Map<String, Array<String>> = new Map<String, Array<String>>();
			introAssets.set('default', ['ready', "set", "go"]);
			introAssets.set('school', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);
			introAssets.set('schoolEvil', ['weeb/pixelUI/ready-pixel', 'weeb/pixelUI/set-pixel', 'weeb/pixelUI/date-pixel']);

			var introAlts:Array<String> = introAssets.get('default');
			var altSuffix:String = "";

			for (value in introAssets.keys())
			{
				if (value == curStage)
				{
					introAlts = introAssets.get(value);
					altSuffix = '-pixel';
				}
			}

			switch (swagCounter)

			{
				case 0:
					FlxG.sound.play(Paths.sound('intro3' + altSuffix), 0.6);
				case 1:
					var ready:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[0]));
					ready.scrollFactor.set();
					ready.updateHitbox();
					ready.antialiasing = true;

					if (curStage.startsWith('school'))
					{
						ready.antialiasing = false;
						ready.setGraphicSize(Std.int(ready.width * daPixelZoom));
					}

					ready.screenCenter();
					add(ready);
					FlxTween.tween(ready, {y: ready.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							ready.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro2' + altSuffix), 0.6);
				case 2:
					var set:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[1]));
					set.scrollFactor.set();
					set.antialiasing = true;

					if (curStage.startsWith('school'))
					{
						set.antialiasing = false;
						set.setGraphicSize(Std.int(set.width * daPixelZoom));
					}

					set.screenCenter();
					add(set);
					FlxTween.tween(set, {y: set.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							set.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('intro1' + altSuffix), 0.6);
				case 3:
					var go:FlxSprite = new FlxSprite().loadGraphic(Paths.image(introAlts[2]));
					go.scrollFactor.set();
					go.antialiasing = true;

					if (curStage.startsWith('school'))
					{
						go.antialiasing = false;
						go.setGraphicSize(Std.int(go.width * daPixelZoom));
					}

					go.updateHitbox();

					go.screenCenter();
					add(go);
					FlxTween.tween(go, {y: go.y += 100, alpha: 0}, Conductor.crochet / 1000, {
						ease: FlxEase.cubeInOut,
						onComplete: function(twn:FlxTween)
						{
							go.destroy();
						}
					});
					FlxG.sound.play(Paths.sound('introGo' + altSuffix), 0.6);
				case 4:
			}

			swagCounter += 1;
			// generateSong('fresh');
		}, 4);
	}

	var previousFrameTime:Int = 0;
	var lastReportedPlayheadPosition:Int = 0;
	var songTime:Float = 0;

	function startSong():Void
	{
		startingSong = false;

		previousFrameTime = FlxG.game.ticks;
		lastReportedPlayheadPosition = 0;

		if (!paused)
			FlxG.sound.playMusic(Paths.inst(PlayState.SONG.song), 1, false);
		FlxG.sound.music.onComplete = endSong;
		vocals.play();

		#if desktop
		// Song duration in a float, useful for the time left feature
		songLength = FlxG.sound.music.length;

		// Updating Discord Rich Presence (with Time Left)
		DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength);
		#end
	}

	var debugNum:Int = 0;

	private function generateSong():Void
	{
		// FlxG.log.add(ChartParser.parse());

		var songData = SONG;
		Conductor.changeBPM(songData.bpm);

		curSong = songData.song;

		if (SONG.needsVoices)
			vocals = new FlxSound().loadEmbedded(Paths.voices(PlayState.SONG.song));
		else
			vocals = new FlxSound();

		vocals.onComplete = function()
		{
			vocalsFinished = true;
		};
		FlxG.sound.list.add(vocals);

		notes = new FlxTypedGroup<Note>();
		add(notes);

		var noteData:Array<SwagSection>;

		// NEW SHIT
		noteData = songData.notes;

		var playerCounter:Int = 0;

		var daBeats:Int = 0; // Not exactly representative of 'daBeats' lol, just how much it has looped
		for (section in noteData)
		{
			var coolSection:Int = Std.int(section.lengthInSteps / 4);

			for (songNotes in section.sectionNotes)
			{
				var daStrumTime:Float = songNotes[0];
				var daNoteData:Int = Std.int(songNotes[1] % 4);

				var gottaHitNote:Bool = (PreferencesMenu.getPref('mirror-mode') ? !section.mustHitSection : section.mustHitSection);

				if (songNotes[1] > 3)
				{
					gottaHitNote = (PreferencesMenu.getPref('mirror-mode') ? section.mustHitSection : !section.mustHitSection);
				}

				var oldNote:Note;
				if (unspawnNotes.length > 0)
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];
				else
					oldNote = null;

				var swagNote:Note = new Note(daStrumTime, daNoteData, oldNote);
				swagNote.sustainLength = songNotes[2];
				swagNote.altNote = songNotes[3];
				swagNote.scrollFactor.set(0, 0);

				var susLength:Float = swagNote.sustainLength;

				susLength /= Conductor.stepCrochet;
				unspawnNotes.push(swagNote);

				for (susNote in 0...Math.floor(susLength))
				{
					oldNote = unspawnNotes[Std.int(unspawnNotes.length - 1)];

					var sustainNote:Note = new Note(daStrumTime + (Conductor.stepCrochet * susNote) + Conductor.stepCrochet, daNoteData, oldNote, true);
					sustainNote.scrollFactor.set();
					unspawnNotes.push(sustainNote);

					sustainNote.mustPress = gottaHitNote;

					if (sustainNote.mustPress)
					{
						sustainNote.x += FlxG.width / 2; // general offset
					}
				}

				swagNote.mustPress = gottaHitNote;

				if (swagNote.mustPress)
				{
					swagNote.x += FlxG.width / 2; // general offset
				}
			}
			daBeats += 1;
		}

		// trace(unspawnNotes.length);
		// playerCounter += 1;

		unspawnNotes.sort(sortByShit);

		generatedMusic = true;
	}
	function updateAccuracy()
		{
			totalPlayed += 1;
			accuracy = totalNotesHit / totalPlayed * 100;
			if (accuracy >= 100.00)
				{
					if (ss && misses == 0)
						accuracy = 100.00;
					else
						{
						accuracy = 99.98;
						}
				}
				if (ss)
					rank = "SS";
				else if (accuracy >= 95)
					rank = "S";
				else if (accuracy >= 92)
					rank = "A";
				else if (accuracy >= 82)
					rank = "B";
				else if (accuracy >= 70)
					rank = "C";
				else if (accuracy >= 50)
					rank = "D";
				else if (accuracy < 49)
					rank = "F";
		}
	
	function sortByShit(Obj1:Note, Obj2:Note):Int
	{
		return sortNotes(FlxSort.ASCENDING, Obj1, Obj2);
	}

	function sortNotes(Sort:Int = FlxSort.ASCENDING, Obj1:Note, Obj2:Note):Int
	{
		return Obj1.strumTime < Obj2.strumTime ? Sort : Obj1.strumTime > Obj2.strumTime ? -Sort : 0;
	}

	private function generateStaticArrows(player:Int):Void
	{
		for (i in 0...4)
		{
			// FlxG.log.add(i);
			var babyArrow:FlxSprite = new FlxSprite(0, strumLine.y);
			var colorSwap:ColorSwap = new ColorSwap();

			babyArrow.shader = colorSwap.shader;
			colorSwap.update(Note.arrowColors[i]);

			switch (curStage)
			{
				case 'school' | 'schoolEvil':
					if (PreferencesMenu.getPref('game-console-mode'))
					{
						babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;
					}
					else
					{
					babyArrow.loadGraphic(Paths.image('weeb/pixelUI/arrows-pixels'), true, 17, 17);
					babyArrow.animation.add('green', [6]);
					babyArrow.animation.add('red', [7]);
					babyArrow.animation.add('blue', [5]);
					babyArrow.animation.add('purplel', [4]);

					babyArrow.setGraphicSize(Std.int(babyArrow.width * daPixelZoom));
					babyArrow.updateHitbox();
					babyArrow.antialiasing = false;
					}
					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.add('static', [0]);
							babyArrow.animation.add('pressed', [4, 8], 12, false);
							babyArrow.animation.add('confirm', [12, 16], 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.add('static', [1]);
							babyArrow.animation.add('pressed', [5, 9], 12, false);
							babyArrow.animation.add('confirm', [13, 17], 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.add('static', [2]);
							babyArrow.animation.add('pressed', [6, 10], 12, false);
							babyArrow.animation.add('confirm', [14, 18], 12, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.add('static', [3]);
							babyArrow.animation.add('pressed', [7, 11], 12, false);
							babyArrow.animation.add('confirm', [15, 19], 24, false);
					}

				default:
					babyArrow.frames = Paths.getSparrowAtlas('NOTE_assets');
					babyArrow.animation.addByPrefix('green', 'arrowUP');
					babyArrow.animation.addByPrefix('blue', 'arrowDOWN');
					babyArrow.animation.addByPrefix('purple', 'arrowLEFT');
					babyArrow.animation.addByPrefix('red', 'arrowRIGHT');

					babyArrow.antialiasing = true;
					babyArrow.setGraphicSize(Std.int(babyArrow.width * 0.7));

					switch (Math.abs(i))
					{
						case 0:
							babyArrow.x += Note.swagWidth * 0;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 1');
							babyArrow.animation.addByPrefix('pressed', 'left press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'left confirm', 24, false);
						case 1:
							babyArrow.x += Note.swagWidth * 1;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 2');
							babyArrow.animation.addByPrefix('pressed', 'down press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'down confirm', 24, false);
						case 2:
							babyArrow.x += Note.swagWidth * 2;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 4');
							babyArrow.animation.addByPrefix('pressed', 'up press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'up confirm', 24, false);
						case 3:
							babyArrow.x += Note.swagWidth * 3;
							babyArrow.animation.addByPrefix('static', 'arrow static instance 3');
							babyArrow.animation.addByPrefix('pressed', 'right press', 24, false);
							babyArrow.animation.addByPrefix('confirm', 'right confirm', 24, false);
					}
			}

			babyArrow.updateHitbox();
			babyArrow.scrollFactor.set();

			if (!isStoryMode)
			{
				babyArrow.y -= 10;
				babyArrow.alpha = 0;
				FlxTween.tween(babyArrow, {y: babyArrow.y + 10, alpha: 1}, 1, {ease: FlxEase.circOut, startDelay: 0.5 + (0.2 * i)});
			}

			babyArrow.ID = i;

			if (player == 1)
				playerStrums.add(babyArrow);
			else
				player2Strums.add(babyArrow); 

			babyArrow.animation.play('static');
			babyArrow.x += 50;

			if (PreferencesMenu.getPref('mirror-mode'))
				{
					switch (player)
					{
						case 0:
							babyArrow.x += ((FlxG.width / 2) * 1);
						case 1:
							babyArrow.x += ((FlxG.width / 2) * 0);
					}
				}
				else
				{
					babyArrow.x += ((FlxG.width / 2) * player);
				}
	
			strumLineNotes.add(babyArrow);
		}
	}

	function tweenCamIn():Void
	{
		FlxTween.tween(FlxG.camera, {zoom: 1.3}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
	}

	override function openSubState(SubState:FlxSubState)
	{
		if (paused)
		{
			if (FlxG.sound.music != null)
			{
				FlxG.sound.music.pause();
				vocals.pause();
			}

			if (!startTimer.finished)
				startTimer.active = false;
		}

		super.openSubState(SubState);
	}

	override function closeSubState()
	{
		if (paused)
		{
			if (FlxG.sound.music != null && !startingSong)
			{
				resyncVocals();
			}

			if (!startTimer.finished)
				startTimer.active = true;
			paused = false;

			#if desktop
			if (startTimer.finished)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
			#end
		}

		super.closeSubState();
	}

	#if desktop
	override public function onFocus():Void
	{
		if (health > 0 && !paused)
		{
			if (Conductor.songPosition > 0.0)
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC, true, songLength - Conductor.songPosition);
			}
			else
			{
				DiscordClient.changePresence(detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			}
		}

		super.onFocus();
	}
	
	override public function onFocusLost():Void
	{
		if (health > 0 && !paused)
		{
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
		}

		super.onFocusLost();
	}
	#end

	function resyncVocals():Void
	{
		if (!_exiting)
		{
			vocals.pause();
	
			FlxG.sound.music.play();
			Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
			if (!vocalsFinished)
			{
				vocals.time = Conductor.songPosition;
				vocals.play();
			}
		}
	}

	private var paused:Bool = false;
	var startedCountdown:Bool = false;
	var canPause:Bool = true;
	var cameraRightSide:Bool = false;

	function truncateFloat( number : Float, precision : Int): Float {
		var num = number;
		num = num * Math.pow(10, precision);
		num = Math.round( num ) / Math.pow(10, precision);
		return num;
		}

	override public function update(elapsed:Float)
	{
		FlxG.camera.followLerp = CoolUtil.camLerpShit(0.02);

		#if !debug
		perfectMode = false;
		#end

		if (FlxG.keys.justPressed.FIVE)
		{
			iconP1.swapOldIcon();
		}

		if (startingSong)
		{
			if (startedCountdown)
			{
				Conductor.songPosition += FlxG.elapsed * 1000;
				if (Conductor.songPosition >= 0)
					startSong();
			}
		}
		else
		{
			//Conductor.songPosition = FlxG.sound.music.time + Conductor.offset;
			Conductor.songPosition += FlxG.elapsed * 1000;

			if (!paused)
			{
				songTime += FlxG.game.ticks - previousFrameTime;
				previousFrameTime = FlxG.game.ticks;

				// Interpolation type beat
				if (Conductor.lastSongPos != Conductor.songPosition)
				{
					songTime = (songTime + Conductor.songPosition) / 2;
					Conductor.lastSongPos = Conductor.songPosition;
					// Conductor.songPosition += FlxG.elapsed * 1000;
					// trace('MISSED FRAME');
				}
			}

			// Conductor.lastSongPos = FlxG.sound.music.time;
		}

		switch (curStage)
		{
			case 'philly':
				if (trainMoving)
				{
					trainFrameTiming += elapsed;

					if (trainFrameTiming >= 1 / 24)
					{
						updateTrainPos();
						trainFrameTiming = 0;
					}
				}
				// phillyCityLights.members[curLight].alpha -= (Conductor.crochet / 1000) * FlxG.elapsed;
				lightFadeShader.update(1.5 * (Conductor.crochet / 1000) * FlxG.elapsed);
			case 'tank':
				moveTank();
		}

		super.update(elapsed);


		scoreTxt.text = 
		'Score: ' + songScore
		+ ' | Misses: ' + misses
		+ ' | Faults: ' + faults
		+ '| Accuracy:' +truncateFloat(accuracy, 2) + "%"
		+  '| Rank:' + rank;
		// I don't have the copyright
		if (PreferencesMenu.getPref('curbeat'))
		    timeTxt.text = '  curBeat:' + curBeat;
		else
		    timeTxt.text = 'SongTime:' + FlxG.sound.music.time / 1000 + "s";

		if (controls.PAUSE && startedCountdown && canPause)
		{
			persistentUpdate = false;
			persistentDraw = true;
			paused = true;

			// 1 / 1000 chance for Gitaroo Man easter egg
			if (FlxG.random.bool(0.1))
			{
				// gitaroo man easter egg
				FlxG.switchState(new GitarooPause());
			}
			else
			{
				var screenPos:FlxPoint = boyfriend.getScreenPosition();
				var pauseMenu:PauseSubState = new PauseSubState(screenPos.x, screenPos.y);
				openSubState(pauseMenu);
				pauseMenu.camera = camHUD;
			}
		
			#if desktop
			DiscordClient.changePresence(detailsPausedText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
			#end
		}

		if (FlxG.keys.justPressed.SEVEN)
		{
			canDie = false;
			FlxG.switchState(new ChartingState());

			#if desktop
			DiscordClient.changePresence("Chart Editor", null, null, true);
			#end
		}

		// FlxG.watch.addQuick('VOL', vocals.amplitudeLeft);
		// FlxG.watch.addQuick('VOLRight', vocals.amplitudeRight);

		iconP1.setGraphicSize(Std.int(FlxMath.lerp(140, iconP1.width, 0.85)));
		iconP2.setGraphicSize(Std.int(FlxMath.lerp(140, iconP2.width, 0.85)));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		var iconOffset:Int = 26;
		if (PreferencesMenu.getPref('mirror-mode'))
			{
		    iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 100, 0, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
			}
		else
			{
			iconP1.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01) - iconOffset);
			iconP2.x = healthBar.x + (healthBar.width * (FlxMath.remapToRange(healthBar.percent, 0, 100, 100, 0) * 0.01)) - (iconP2.width - iconOffset);
			}
		

		if (health > 2)
			health = 2;

		if (PreferencesMenu.getPref('mirror-mode'))
			{
				if (healthBar.percent < 20)
					{
					iconP1.animation.curAnim.curFrame = 2;
				    iconP2.animation.curAnim.curFrame = 1;
					}
				else if (healthBar.percent < 25)
					{
					iconP1.animation.curAnim.curFrame = 4;
					iconP2.animation.curAnim.curFrame = 3;
					}
				else if (healthBar.percent > 80)
					{
					iconP1.animation.curAnim.curFrame = 1;
				    iconP2.animation.curAnim.curFrame = 2;
					}
				else if (healthBar.percent > 75)
					{
					iconP1.animation.curAnim.curFrame = 3;
					iconP2.animation.curAnim.curFrame = 4;
					}
				else
					{
					iconP2.animation.curAnim.curFrame = 0;
				    iconP1.animation.curAnim.curFrame = 0;
					}
			}
			else
			{
				if (healthBar.percent < 20)
					{
					iconP1.animation.curAnim.curFrame = 1;
				    iconP2.animation.curAnim.curFrame = 2;
					}
				else if (healthBar.percent < 25)
					{
					iconP1.animation.curAnim.curFrame = 3;
					iconP2.animation.curAnim.curFrame = 4;
					}
				else if (healthBar.percent > 80)
					{
					iconP1.animation.curAnim.curFrame = 2;
				    iconP2.animation.curAnim.curFrame = 1;
					}
				else if (healthBar.percent > 75)
					{
					iconP1.animation.curAnim.curFrame = 4;
					iconP2.animation.curAnim.curFrame = 3;
					}
				else
					{
					iconP2.animation.curAnim.curFrame = 0;
				    iconP1.animation.curAnim.curFrame = 0;
					}
			}
		/* if (FlxG.keys.justPressed.NINE)
			FlxG.switchState(new Charting()); */

		//#if debug
		if (FlxG.keys.justPressed.EIGHT)
			FlxG.switchState(new AnimationDebug(SONG.player2));
		//#end

		if (generatedMusic && PlayState.SONG.notes[Std.int(curStep / 16)] != null)
		{
			if (curBeat % 4 == 0)
			{
				// trace(PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection);
			}

			cameraRightSide = PlayState.SONG.notes[Std.int(curStep / 16)].mustHitSection;
			cameraMovement();
		}

		if (camZooming)
		{
			FlxG.camera.zoom = FlxMath.lerp(defaultCamZoom, FlxG.camera.zoom, 0.95);
			camHUD.zoom = FlxMath.lerp(1, camHUD.zoom, 0.95);
		}

		FlxG.watch.addQuick("curBeat", curBeat);
		FlxG.watch.addQuick("curStep", curStep);

		if (curSong == 'Fresh')
		{
			switch (curBeat)
			{
				case 16:
					camZooming = true;
					gfSpeed = 2;
				case 48:
					gfSpeed = 1;
				case 80:
					gfSpeed = 2;
				case 112:
					gfSpeed = 1;
				// case 163:
					// FlxG.sound.music.stop();
					// FlxG.switchState(new TitleState());
			}
		}

		if (curSong == 'Bopeebo')
		{
			switch (curBeat)
			{
				case 128, 129, 130:
					vocals.volume = 0;
					// FlxG.sound.music.stop();
					// FlxG.switchState(new PlayState());
			}
		}
		// better streaming of shit

		if (!inCutscene && !_exiting)
		{
			// RESET = Quick Game Over Screen
			if (controls.RESET)
			{
				health = 0;
				trace("RESET = True");
			}

			// CHEAT = brandon's a pussy
			// if (controls.CHEAT)
			// {
			// 	health += 1;
			// 	trace("User is cheating!");
			// }
	
			if (health <= 0 && !practiceMode && canDie && !PreferencesMenu.getPref('mirror-mode'))
			{
				boyfriend.stunned = true;
	
				persistentUpdate = false;
				persistentDraw = false;
				paused = true;
	
				vocals.stop();
				FlxG.sound.music.stop();

				deathCounter += 1;
	
				openSubState(new GameOverSubstate(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
	
				// FlxG.switchState(new GameOverState(boyfriend.getScreenPosition().x, boyfriend.getScreenPosition().y));
				
				#if desktop
				// Game Over doesn't get his own variable because it's only used here
				DiscordClient.changePresence("Game Over - " + detailsText, SONG.song + " (" + storyDifficultyText + ")", iconRPC);
				#end
			}
		}

		while (unspawnNotes[0] != null)
		{
			if (unspawnNotes[0].strumTime - Conductor.songPosition < 1800 / SONG.speed)
			{
				var dunceNote:Note = unspawnNotes[0];
				if (PreferencesMenu.getPref('mirror-mode'))
				    dunceNote.x += ((FlxG.width / 2) * -1);
				notes.add(dunceNote);

				var index:Int = unspawnNotes.indexOf(dunceNote);
				unspawnNotes.shift();
			}
			else
			{
				break;
			}
		}

		if (generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.y > FlxG.height)
				{
					daNote.active = false;
					daNote.visible = false;
				}
				else
				{
					daNote.visible = true;
					daNote.active = true;
				}

				var center = strumLine.y + (Note.swagWidth / 2);
				
				// i am so fucking sorry for these if conditions
				if (PreferencesMenu.getPref('downscroll'))
				{
					daNote.y = strumLine.y + 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
					
					if (daNote.isSustainNote)
					{
						if (daNote.animation.curAnim.name.endsWith('end') && daNote.prevNote != null)
							daNote.y += daNote.prevNote.height;
						else
							daNote.y += daNote.height / 2;

						if (daNote.y - daNote.offset.y * daNote.scale.y + daNote.height >= center
							&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
						{
							var swagRect = new FlxRect(0, 0, daNote.frameWidth, daNote.frameHeight);
							swagRect.height = (center - daNote.y) / daNote.scale.y;
							swagRect.y = daNote.frameHeight - swagRect.height;
							
							daNote.clipRect = swagRect;
						}
					}
				}
				else
				{
					daNote.y = strumLine.y - 0.45 * (Conductor.songPosition - daNote.strumTime) * FlxMath.roundDecimal(SONG.speed, 2);
	
					if (daNote.isSustainNote
						&& daNote.y + daNote.offset.y * daNote.scale.y <= center
						&& (!daNote.mustPress || (daNote.wasGoodHit || (daNote.prevNote.wasGoodHit && !daNote.canBeHit))))
					{
						var swagRect = new FlxRect(0, 0, daNote.width / daNote.scale.x, daNote.height / daNote.scale.y);
						swagRect.y = (center - daNote.y) / daNote.scale.y;
						swagRect.height -= swagRect.y;

						daNote.clipRect = swagRect;
					}
				}

				if (!daNote.mustPress && daNote.wasGoodHit)
				{
					if (SONG.song != 'Tutorial')
						camZooming = true;

					var altAnim:String = "";

					if (SONG.notes[Math.floor(curStep / 16)] != null)
					{
						if (SONG.notes[Math.floor(curStep / 16)].altAnim && !FlxG.save.data.mirrorMode)
							altAnim = '-alt';
					}
					if (daNote.altNote)
						altAnim = '-alt';

					switch (Math.abs(daNote.noteData))
					{
						case 0:
							if (PreferencesMenu.getPref('mirror-mode'))
								{
									 boyfriend.playAnim('singLEFT' + altAnim, true);
								}
							else
								{
									 dad.playAnim('singLEFT' + altAnim, true);
								}				
						case 1:
							if (PreferencesMenu.getPref('mirror-mode'))
								{
									boyfriend.playAnim('singDOWN' + altAnim, true);
								}
							else
								{
									dad.playAnim('singDOWN' + altAnim, true);
								}				
						case 2:
							if (PreferencesMenu.getPref('mirror-mode'))
											{
												boyfriend.playAnim('singUP' + altAnim, true);
											}
							else
										{
											dad.playAnim('singUP' + altAnim, true);
										}			
						case 3:	
									if (PreferencesMenu.getPref('mirror-mode'))
										{
											boyfriend.playAnim('singRIGHT' + altAnim, true);
										}
									else
										{
											dad.playAnim('singRIGHT' + altAnim, true);
										}
					}

					player2Strums.forEach(function(spr:FlxSprite)
						{
							if (Math.abs(daNote.noteData) == spr.ID)
							{
								spr.animation.play('confirm');
								sustain2(spr.ID, spr, daNote);
							}
						});

					if (!(PreferencesMenu.getPref('mirror-mode')))
                        dad.holdTimer = 0;
					else
						boyfriend.holdTimer = 0;

					if (SONG.needsVoices)
						vocals.volume = 1;
					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				//WIP interpolation shit? Need to fix the pause issue
				//daNote.y = (strumLine.y - (songTime - daNote.strumTime) * (0.45 * PlayState.SONG.speed));

				var doKill = daNote.y < -daNote.height;
				if (PreferencesMenu.getPref('downscroll'))
					doKill = daNote.y > FlxG.height;

				if (doKill)
				{
					if (daNote.tooLate || !daNote.wasGoodHit)
					{
						health -= 0.0475;
						misses += 1;
						combo = 0;
						vocals.volume = 0;
						updateAccuracy();
					}

					daNote.active = false;
					daNote.visible = false;

					daNote.kill();
					notes.remove(daNote, true);
					daNote.destroy();
				}

				var missNote:Bool = daNote.y < -daNote.height;
				if (FlxG.save.data.downscroll)
				{
					missNote = daNote.y > FlxG.height;
				}
				if (missNote && daNote.mustPress)
					{
						if (daNote.tooLate || !daNote.wasGoodHit)
						{
							noteMiss(daNote.noteData);
	
							vocals.volume = 0;
						}
					}
			});
			player2Strums.forEach(function(spr:FlxSprite)
			{
				if (strumming2[spr.ID])
				{
					spr.animation.play("confirm");
				}

				if (spr.animation.curAnim.name == 'confirm' && !curStage.startsWith('school'))
				{
					spr.centerOffsets();
					spr.offset.x -= 13;
					spr.offset.y -= 13;
				}
				else
					spr.centerOffsets();
			});

		}

		if (!inCutscene)
			keyShit();

		if (FlxG.keys.justPressed.ONE)
			endSong();
	}

	function sustain2(strum:Int, spr:FlxSprite, note:Note):Void
		{
			var length:Float = note.sustainLength;
	
			if (length > 0)
			{
				strumming2[strum] = true;
			}
	
			var bps:Float = Conductor.bpm/60;
			var spb:Float = 1/bps;
	
			if (!note.isSustainNote)
			{
				new FlxTimer().start(length == 0 ? 0.2 : (length / Conductor.crochet * spb) + 0.1, function(tmr:FlxTimer)
				{
					if (!strumming2[strum])
					{
						spr.animation.play("static", true);
					} else if (length > 0) {
						strumming2[strum] = false;
						spr.animation.play("static", true);
					}
				});
			}
		}
	
	function endSong():Void
	{
		canDie = false;
		seenCutscene = false;
		deathCounter = 0;
		canPause = false;
		FlxG.sound.music.volume = 0;
		vocals.volume = 0;
		if (SONG.validScore)
		{
			#if !switch
			Highscore.saveScore(SONG.song, songScore, storyDifficulty);
			#end
		}

		if (isStoryMode)
		{
			campaignScore += songScore;

			storyPlaylist.remove(storyPlaylist[0]);

			if (storyPlaylist.length <= 0)
			{
				if (storyWeek != 7)
					FlxG.sound.playMusic(Paths.music('freakyMenu'));

				transIn = FlxTransitionableState.defaultTransIn;
				transOut = FlxTransitionableState.defaultTransOut;

				if (storyWeek == 7)
				{
					TitleState.initialized = false;
					FlxG.switchState(new TitleState());
				}
				else
				{
					FlxG.switchState(new StoryMenuState());
				}

				// if ()
				StoryMenuState.weekUnlocked[Std.int(Math.min(storyWeek + 1, StoryMenuState.weekUnlocked.length - 1))] = true;

				if (SONG.validScore)
				{
					Highscore.saveWeekScore(storyWeek, campaignScore, storyDifficulty);
				}

				FlxG.save.data.weekUnlocked = StoryMenuState.weekUnlocked;
				FlxG.save.flush();
			}
			else
			{
				var difficulty:String = "";

				if (storyDifficulty == 0)
					difficulty = '-easy';

				if (storyDifficulty == 2)
					difficulty = '-hard';

				trace('LOADING NEXT SONG');
				trace(PlayState.storyPlaylist[0].toLowerCase() + difficulty);

				FlxTransitionableState.skipNextTransIn = true;
				FlxTransitionableState.skipNextTransOut = true;

				FlxG.sound.music.stop();
				vocals.stop();

				if (SONG.song.toLowerCase() == 'eggnog')
				{
					var blackShit:FlxSprite = new FlxSprite(-FlxG.width * FlxG.camera.zoom,
						-FlxG.height * FlxG.camera.zoom).makeGraphic(FlxG.width * 3, FlxG.height * 3, FlxColor.BLACK);
					blackShit.scrollFactor.set();
					add(blackShit);
					camHUD.visible = false;

					FlxG.sound.play(Paths.sound('Lights_Shut_off'), 1, false, null, true, function()
					{
						PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
						LoadingState.loadAndSwitchState(new PlayState());
					});
				}
				else
				{
					prevCamFollow = camFollow;
	
					PlayState.SONG = Song.loadFromJson(PlayState.storyPlaylist[0].toLowerCase() + difficulty, PlayState.storyPlaylist[0]);
	
					LoadingState.loadAndSwitchState(new PlayState());
				}
			}
		}
		else
		{
			trace('WENT BACK TO FREEPLAY??');
			FlxG.switchState(new FreeplayState());
		}
	}

	var endingSong:Bool = false;

	private function popUpScore(strumtime:Float, daNote:Note):Void
	{
		var noteDiff:Float = Math.abs(strumtime - Conductor.songPosition);
		// boyfriend.playAnim('hey');
		vocals.volume = 1;

		var placement:String = Std.string(combo);

		var coolText:FlxText = new FlxText(0, 0, 0, placement, 32);
		coolText.screenCenter();
		coolText.x = FlxG.width * 0.55;
		//

		var rating:FlxSprite = new FlxSprite();
		var ranumber:FlxSprite = new FlxSprite();
		var score:Int = 350;

		var daRating:String = "sick";
		var daRanum:String = "great";
		var doSplash:Bool = true;

		if (noteDiff > Conductor.safeZoneOffset * 0.9)
		{
			daRating = 'shit';
			totalNotesHit += 0.10;
			score = 50;
			doSplash = false;
			ss = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.75)
		{
			daRating = 'bad';
			score = 100;
			totalNotesHit += 0.35;
			doSplash = false;
			ss = false;
		}
		else if (noteDiff > Conductor.safeZoneOffset * 0.2)
		{
			daRating = 'good';
			score = 200;
			totalNotesHit += 0.85;
			doSplash = false;
			ss = false;
		}
		else
			{
				totalNotesHit += 1;
			}

		if (doSplash)
		{
			var splash:NoteSplash = grpNoteSplashes.recycle(NoteSplash);
			splash.setupNoteSplash(daNote.x, daNote.y, daNote.noteData);
			grpNoteSplashes.add(splash);
		}

		if (!practiceMode)
			songScore += score;

		 /*if (combo > 60)
				daRanum = 'great';
			else if (combo > 20)
				daRanum = 'more'
			else if (combo > 0)
				daRanum = 'less';
		else
			daRanum = 'less';*/
		var pixelShitPart1:String = "";
		var pixelShitPart2:String = '';

		if (curStage.startsWith('school'))
		{
			if (PreferencesMenu.getPref('game-console-mode'))
			    pixelShitPart1 = 'erectweeb/pixelUI/';
			else
			    pixelShitPart1 = 'weeb/pixelUI/';
			    pixelShitPart2 = '-pixel';
		}

		rating.loadGraphic(Paths.image(pixelShitPart1 + daRating + pixelShitPart2));
		rating.screenCenter();
		rating.x = coolText.x - 40;
		rating.y -= 60;
		rating.acceleration.y = 550;
		rating.velocity.y -= FlxG.random.int(140, 175);
		rating.velocity.x -= FlxG.random.int(0, 10);
		
		/*ranumber.loadGraphic(Paths.image(pixelShitPart1 + daRanum + pixelShitPart2));
		ranumber.screenCenter();
		ranumber.x = coolText.x - 80;
		ranumber.y -= 120;
		ranumber.acceleration.y = 550;
		ranumber.velocity.y -= FlxG.random.int(140, 175);
		ranumber.velocity.x -= FlxG.random.int(0, 10);
        add(ranumber);*/

		var comboSpr:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'combo' + pixelShitPart2));
		comboSpr.screenCenter();
		comboSpr.x = coolText.x;
		comboSpr.acceleration.y = 600;
		comboSpr.velocity.y -= 150;

		comboSpr.velocity.x += FlxG.random.int(1, 10);
		add(rating);

		if (!curStage.startsWith('school'))
		{
			rating.setGraphicSize(Std.int(rating.width * 0.7));
			rating.antialiasing = true;
			/*ranumber.setGraphicSize(Std.int(ranumber.width * 0.7));
			ranumber.antialiasing = true;*/
			comboSpr.setGraphicSize(Std.int(comboSpr.width * 0.7));
			comboSpr.antialiasing = true;
		}
		else
		{
			rating.setGraphicSize(Std.int(rating.width * daPixelZoom * 0.7));
			ranumber.setGraphicSize(Std.int(ranumber.width * daPixelZoom * 0.7));
			comboSpr.setGraphicSize(Std.int(comboSpr.width * daPixelZoom * 0.7));
		}

		comboSpr.updateHitbox();
		rating.updateHitbox();
		//ranumber.updateHitbox();

		var seperatedScore:Array<Int> = [];

		seperatedScore.push(Math.floor(combo / 100));
		seperatedScore.push(Math.floor((combo - (seperatedScore[0] * 100)) / 10));
		seperatedScore.push(combo % 10);
		if (combo >= 4)
        add(comboSpr);
		var daLoop:Int = 0;
		for (i in seperatedScore)
		{
			var numScore:FlxSprite = new FlxSprite().loadGraphic(Paths.image(pixelShitPart1 + 'num' + Std.int(i) + pixelShitPart2));
			numScore.screenCenter();
			numScore.x = coolText.x + (43 * daLoop) - 90;
			numScore.y += 80;

			if (!curStage.startsWith('school'))
			{
				numScore.antialiasing = true;
				numScore.setGraphicSize(Std.int(numScore.width * 0.5));
			}
			else
			{
				numScore.setGraphicSize(Std.int(numScore.width * daPixelZoom));
			}
			numScore.updateHitbox();

			numScore.acceleration.y = FlxG.random.int(200, 300);
			numScore.velocity.y -= FlxG.random.int(140, 160);
			numScore.velocity.x = FlxG.random.float(-5, 5);

			if (combo >= 10)
				add(numScore);

			FlxTween.tween(numScore, {alpha: 0}, 0.2, {
				onComplete: function(tween:FlxTween)
				{
					numScore.destroy();
				},
				startDelay: Conductor.crochet * 0.002
			});

			daLoop++;
		}
		/* 
			trace(combo);
			trace(seperatedScore);
		 */

		coolText.text = Std.string(seperatedScore);
		// add(coolText);

		FlxTween.tween(rating, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});

		/*FlxTween.tween(ranumber, {alpha: 0}, 0.2, {
			startDelay: Conductor.crochet * 0.001
		});*/

		FlxTween.tween(comboSpr, {alpha: 0}, 0.2, {
			onComplete: function(tween:FlxTween)
			{
				coolText.destroy();
				comboSpr.destroy();
                //ranumber.destroy();
				rating.destroy();
			},
			startDelay: Conductor.crochet * 0.001
		});

		curSection += 1;
	}

	private function cameraMovement():Void
	{
		if (camFollow.x != dad.getMidpoint().x + 150 && !cameraRightSide)
		{
			camFollow.setPosition(dad.getMidpoint().x + 150, dad.getMidpoint().y - 100);
			// camFollow.setPosition(lucky.getMidpoint().x - 120, lucky.getMidpoint().y + 210);

			switch (dad.curCharacter)
			{
				case 'mom':
					camFollow.y = dad.getMidpoint().y;
				case 'senpai' | 'senpai-angry':
					camFollow.y = dad.getMidpoint().y - 430;
					camFollow.x = dad.getMidpoint().x - 100;
			}

			if (dad.curCharacter == 'mom')
				vocals.volume = 1;

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				tweenCamIn();
			}
		}

		if (cameraRightSide && camFollow.x != boyfriend.getMidpoint().x - 100)
		{
			camFollow.setPosition(boyfriend.getMidpoint().x - 100, boyfriend.getMidpoint().y - 100);

			switch (curStage)
			{
				case 'limo':
					camFollow.x = boyfriend.getMidpoint().x - 300;
				case 'mall':
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'school':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
				case 'schoolEvil':
					camFollow.x = boyfriend.getMidpoint().x - 200;
					camFollow.y = boyfriend.getMidpoint().y - 200;
			}

			if (SONG.song.toLowerCase() == 'tutorial')
			{
				FlxTween.tween(FlxG.camera, {zoom: 1}, (Conductor.stepCrochet * 4 / 1000), {ease: FlxEase.elasticInOut});
			}
		}
	}

	private function keyShit():Void
	{
		var holdingArray:Array<Bool> = [controls.NOTE_LEFT, controls.NOTE_DOWN, controls.NOTE_UP, controls.NOTE_RIGHT];
		var controlArray:Array<Bool> = [controls.NOTE_LEFT_P, controls.NOTE_DOWN_P, controls.NOTE_UP_P, controls.NOTE_RIGHT_P];
		var releaseArray:Array<Bool> = [controls.NOTE_LEFT_R, controls.NOTE_DOWN_R, controls.NOTE_UP_R, controls.NOTE_RIGHT_R];

		// FlxG.watch.addQuick('asdfa', upP);
		if (holdingArray.contains(true) && generatedMusic)
		{
			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.isSustainNote && daNote.canBeHit && daNote.mustPress && holdingArray[daNote.noteData])
					goodNoteHit(daNote);
			});
		}
		if (controlArray.contains(true) && generatedMusic)
		{
			if (PreferencesMenu.getPref('mirror-mode'))
			    dad.holdTimer = 0;
            else
			    boyfriend.holdTimer = 0;

			var possibleNotes:Array<Note> = [];

			var ignoreList:Array<Int> = [];

			var removeList:Array<Note> = [];

			notes.forEachAlive(function(daNote:Note)
			{
				if (daNote.canBeHit && daNote.mustPress && !daNote.tooLate && !daNote.wasGoodHit)
				{
					if (ignoreList.contains(daNote.noteData))
					{
						for (possibleNote in possibleNotes)
						{
							if (possibleNote.noteData == daNote.noteData && Math.abs(daNote.strumTime - possibleNote.strumTime) < 10)
							{
								removeList.push(daNote);
							}
							else if (possibleNote.noteData == daNote.noteData && daNote.strumTime < possibleNote.strumTime)
							{
								possibleNotes.remove(possibleNote);
								possibleNotes.push(daNote);
							}
						}
					}
					else
					{
						possibleNotes.push(daNote);
						ignoreList.push(daNote.noteData);
					}
				}
			});

			for (badNote in removeList)
			{
				badNote.kill();
				notes.remove(badNote, true);
				badNote.destroy();
			}

			possibleNotes.sort(function(note1:Note, note2:Note)
			{
				return Std.int(note1.strumTime - note2.strumTime);
			});

			if (perfectMode)
			{
				goodNoteHit(possibleNotes[0]);
			}
			else if (possibleNotes.length > 0)
			{
				for (i in 0...controlArray.length)
				{
					if (controlArray[i] && !ignoreList.contains(i))
					{
						badNoteHit();
					}
				}
				for (possibleNote in possibleNotes)
				{
					if (controlArray[possibleNote.noteData])
					{
						goodNoteHit(possibleNote);
					}
				}
			}
			else
				badNoteHit();
		}
				if (boyfriend.holdTimer > 0.004 * Conductor.stepCrochet && !holdingArray.contains(true) && boyfriend.animation.curAnim.name.startsWith('sing') && !boyfriend.animation.curAnim.name.endsWith('miss'))
					{
						boyfriend.playAnim('idle');
					}
			
		playerStrums.forEach(function(spr:FlxSprite)
		{
			if (controlArray[spr.ID] && spr.animation.curAnim.name != 'confirm')
				spr.animation.play('pressed');
			if (!holdingArray[spr.ID])
				spr.animation.play('static');

			if (spr.animation.curAnim.name != 'confirm' || curStage.startsWith('school'))
				spr.centerOffsets();
			else
			{
				spr.centerOffsets();
				spr.offset.x -= 13;
				spr.offset.y -= 13;
			}
		});
	}

	function noteMiss(direction:Int = 1):Void
	{
		if (!boyfriend.stunned)
		{
			health -= 0.04;
			if (combo > 5 && gf.animOffsets.exists('sad'))
			{
				gf.playAnim('sad');
			}
			combo = 0;
			if (!practiceMode)
				songScore -= (songScore - 10) >= 0 ? 10 : songScore;
                
			FlxG.sound.play(Paths.soundRandom('missnote', 1, 3), FlxG.random.float(0.1, 0.2));
			// FlxG.sound.play(Paths.sound('missnote1'), 1, false);
			// FlxG.log.add('played imss note');
			if (!(PreferencesMenu.getPref('mirror-mode')))
				boyfriend.stunned = true;
			
			// get stunned for 5 seconds
			new FlxTimer().start(5 / 60, function(tmr:FlxTimer)
			{
				boyfriend.stunned = false;
			});

			if (PreferencesMenu.getPref('mirror-mode'))
			{
				dad.playAnim('sing' + dataSuffix[direction], true);

				switch (SONG.player2)
				{
					case 'pico':	
                            dad.playAnim('sing' + dataSuffix[direction] + 'miss', true);
					case 'senpai':
							dad.color = 0xFFA59CCF;
					        new FlxTimer().start(15 / 60, function(tmr:FlxTimer)
						    {
							dad.color = 0x00FFFFFF;
						    });
					case 'senpai-angry':
						    dad.color = 0xFFA59CCF;
						    new FlxTimer().start(15 / 60, function(tmr:FlxTimer)
						    {
						    dad.color = 0x00FFFFFF;
						    });
					case 'spirit':
						    dad.color = 0xFFA59CCF;
						    new FlxTimer().start(15 / 60, function(tmr:FlxTimer)
						    {
						    dad.color = 0x00FFFFFF;
						    });
					default:
						{
							dad.color = 0xFF7C89FF;
					        new FlxTimer().start(15 / 60, function(tmr:FlxTimer)
						    {
							dad.color = 0x00FFFFFF;
						    });
						}
					
				}
			}
			else
			boyfriend.playAnim('sing' + dataSuffix[direction] + 'miss', true);	
		}
	}

	function badNoteHit()
	{
		// badNoteCheck is intentional for now, but maybe it can be some option later down the line
		// just double pasting this shit cuz fuk u
		// REDO THIS SYSTEM!
		faults += 1;
		var leftP = controls.NOTE_LEFT_P;
		var downP = controls.NOTE_DOWN_P;
		var upP = controls.NOTE_UP_P;
		var rightP = controls.NOTE_RIGHT_P;

		if (leftP)
			noteMiss(0);
		if (downP)
			noteMiss(1);
		if (upP)
			noteMiss(2);
		if (rightP)
			noteMiss(3);
		updateAccuracy();
	}
		
function noteCheck(keyP:Bool, note:Note):Void
	{

		if (keyP)
		{
			goodNoteHit(note);
		}
		else
		{
			badNoteHit();
		}

	}

	function goodNoteHit(note:Note):Void
	{
		if (!note.wasGoodHit)
		{
			if (!note.isSustainNote)
			{
				popUpScore(note.strumTime, note);
				combo += 1;
			}

			if (note.noteData >= 0)
				health += 0.023;
			else
				health += 0.004;

			
			if (PreferencesMenu.getPref('mirror-mode'))
				{
					dad.playAnim('sing' + dataSuffix[note.noteData], true);
				}
		    else
			{
				boyfriend.playAnim('sing' + dataSuffix[note.noteData], true);
			}
			playerStrums.forEach(function(spr:FlxSprite)
			{
				if (Math.abs(note.noteData) == spr.ID)
				{
					spr.animation.play('confirm', true);
				}
			});

			note.wasGoodHit = true;
			vocals.volume = 1;
			if (!note.isSustainNote)
			{
				note.kill();
				notes.remove(note, true);
				note.destroy();
				updateAccuracy();
			}
		}
	}

	var fastCarCanDrive:Bool = true;

	function resetFastCar():Void
	{
		fastCar.x = -12600;
		fastCar.y = FlxG.random.int(140, 250);
		fastCar.velocity.x = 0;
		fastCarCanDrive = true;
	}

	function fastCarDrive()
	{
		FlxG.sound.play(Paths.soundRandom('carPass', 0, 1), 0.7);

		fastCar.velocity.x = (FlxG.random.int(170, 220) / FlxG.elapsed) * 3;
		fastCarCanDrive = false;
		new FlxTimer().start(2, function(tmr:FlxTimer)
		{
			resetFastCar();
		});
	}

	var tankResetShit:Bool = false;
	var tankMoving:Bool = false;
	var tankAngle:Float = FlxG.random.int(-90, 45);
	var tankSpeed:Float = FlxG.random.float(5, 7);
	var tankX:Float = 400;

	function moveTank():Void
	{
		if (!inCutscene)
		{
			tankAngle += tankSpeed * FlxG.elapsed;
			tankGround.angle = (tankAngle - 90 + 15);
			tankGround.x = tankX + 1500 * Math.cos(Math.PI / 180 * (1 * tankAngle + 180));
			tankGround.y = 1300 + 1100 * Math.sin(Math.PI / 180 * (1 * tankAngle + 180));
		}
	}

	var trainMoving:Bool = false;
	var trainFrameTiming:Float = 0;

	var trainCars:Int = 8;
	var trainFinishing:Bool = false;
	var trainCooldown:Int = 0;

	function trainStart():Void
	{
		trainMoving = true;
		trainSound.play(true);
	}

	var startedMoving:Bool = false;

	function updateTrainPos():Void
	{
		if (trainSound.time >= 4700)
		{
			startedMoving = true;
			gf.playAnim('hairBlow');
		}

		if (startedMoving)
		{
			phillyTrain.x -= 400;

			if (phillyTrain.x < -2000 && !trainFinishing)
			{
				phillyTrain.x = -1150;
				trainCars -= 1;

				if (trainCars <= 0)
					trainFinishing = true;
			}

			if (phillyTrain.x < -4000 && trainFinishing)
				trainReset();
		}
	}

	function trainReset():Void
	{
		gf.playAnim('hairFall');
		phillyTrain.x = FlxG.width + 200;
		trainMoving = false;
		// trainSound.stop();
		// trainSound.time = 0;
		trainCars = 8;
		trainFinishing = false;
		startedMoving = false;
	}

	function lightningStrikeShit():Void
	{
		FlxG.sound.play(Paths.soundRandom('thunder_', 1, 2));
		halloweenBG.animation.play('lightning');

		lightningStrikeBeat = curBeat;
		lightningOffset = FlxG.random.int(8, 24);

		boyfriend.playAnim('scared', true);
		gf.playAnim('scared', true);
	}

	override function stepHit()
	{
		super.stepHit();
		if (Math.abs(FlxG.sound.music.time - (Conductor.songPosition - Conductor.offset)) > 20
			|| (SONG.needsVoices && Math.abs(vocals.time - (Conductor.songPosition - Conductor.offset)) > 20))
		{
			resyncVocals();
		}

		if (dad.curCharacter == 'spooky' && curStep % 4 == 2)
		{
			// dad.dance();
		}
	}

	var lightningStrikeBeat:Int = 0;
	var lightningOffset:Int = 8;

	override function beatHit()
	{
		super.beatHit();

    //event list
	    //event of weeks
        function errorEvent() {
			/*just for week 6
              if you use it to onter weeks
			  it'll be a real error.*/
			var error = new FlxSprite(500, 400).loadGraphic(Paths.image('weeb/error'));
			error.scrollFactor.set(0, 0);
		    add(error);

			FlxG.sound.play(Paths.sound('WindowsXP_Error_Sounds'));

			error.setGraphicSize(600, 150);

			error.updateHitbox();
		}

		function thornscharEvent()
		{
			//hey,do you have a idea as event as this.
			remove(dad);

            dad = new Character(100, 100, 'spirit-event');
			dad.x -= 150;
			dad.y += 100;
            add(dad);

			remove(boyfriend);

            boyfriend = new Boyfriend(770, 450, 'bf-pixel-event');
			boyfriend.x += 200;
			boyfriend.y += 220;
            add(boyfriend);

			remove(gf);

			gf = new Character(400, 130, 'gf-pixel-event');
			gf.x += 180;
			gf.y += 300;
			add(gf);

			gf.playAnim('danceRight');
		}

		function blammedlighton()
		{
			//I don't think about this.
			remove(dad);
            dad = new Character(100, 400, 'picot');
            add(dad);

			remove(boyfriend);
            boyfriend = new Boyfriend(770, 450, 'bft');
            add(boyfriend);
			
			FlxG.camera.flash(FlxColor.WHITE, 1);
		}

		function blammedlightend()
			{
				/*I can't let them be a event.
				But,there was no event,right?!*/
				FlxG.camera.flash(FlxColor.BLACK, 1);

				remove(dad);
				dad = new Character(100, 400, 'pico');
				add(dad);
	
				remove(boyfriend);
				boyfriend = new Boyfriend(770, 450, 'bf');
				add(boyfriend);
			}
//end list

		if (generatedMusic)
		{
			notes.members.sort(function(note1:Note, note2:Note)
			{
				return sortNotes(FlxSort.DESCENDING, note1, note2);
			});
		}

		if (SONG.notes[Math.floor(curStep / 16)] != null)
		{
			if (SONG.notes[Math.floor(curStep / 16)].changeBPM)
			{
				Conductor.changeBPM(SONG.notes[Math.floor(curStep / 16)].bpm);
				FlxG.log.add('CHANGED BPM!');
			}
			// else
			// Conductor.changeBPM(SONG.bpm);

			// Dad doesnt interupt his own notes
			// if (SONG.notes[Math.floor(curStep / 16)].mustHitSection)
			// 	dad.dance();
		}
		// FlxG.log.add('change bpm' + SONG.notes[Std.int(curStep / 16)].changeBPM);
		wiggleShit.update(Conductor.crochet);

		if (PreferencesMenu.getPref('camera-zoom'))
		{
			// HARDCODING FOR MILF ZOOMS!
			if (curSong.toLowerCase() == 'milf' && curBeat >= 168 && curBeat < 200 && camZooming && FlxG.camera.zoom < 1.35)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
	
			if (camZooming && FlxG.camera.zoom < 1.35 && curBeat % 4 == 0)
			{
				FlxG.camera.zoom += 0.015;
				camHUD.zoom += 0.03;
			}
		}

		iconP1.setGraphicSize(Std.int(iconP1.width + 30));
		iconP2.setGraphicSize(Std.int(iconP2.width + 30));

		iconP1.updateHitbox();
		iconP2.updateHitbox();

		if (curBeat % gfSpeed == 0)
		{
			gf.dance();
		}

		if (curBeat % 2 == 0)
		{
			    if (!dad.animation.curAnim.name.startsWith('sing')
				|| (FlxG.save.data.mirrorMode && dad.animation.curAnim.name.startsWith('sing') && dad.animation.curAnim.finished))
				dad.dance();

				if (!boyfriend.animation.curAnim.name.startsWith('sing')
				|| (boyfriend.animation.curAnim.name.startsWith('sing') && boyfriend.animation.curAnim.finished))
				boyfriend.playAnim('idle');
		}
		else if (dad.curCharacter == 'spooky')
		{
			if (!dad.animation.curAnim.name.startsWith("sing"))
			{
				dad.dance();
			}
		}

		if (curBeat % 8 == 7 && curSong == 'Bopeebo')
		{
			boyfriend.playAnim('hey', true);
			gf.playAnim('cheer', true);
		}

		if (curBeat % 16 == 15 && SONG.song == 'Tutorial' && dad.curCharacter == 'gf' && curBeat > 16 && curBeat < 48)
		{
			boyfriend.playAnim('hey', true);
			dad.playAnim('cheer', true);
		}

		foregroundSprites.forEach(function(spr:BGSprite)
		{
			spr.dance();
		});

		if (curSong =='Blammed')
	{
		switch (curBeat)
		{
		case 97:
			blammedlighton();
			dad.color = 0xFFFF7676;//red
		case 101:
			dad.color = 0xFFE092FB;//purple
		case 104:
			dad.color = 0xFF62FF56;//green
		case 109:
			dad.color = 0xFF7A7CFF;//blue
		case 112:
			dad.color = 0x00FFFFFF;
			boyfriend.color = 0xFFFF7676;
		case 116:
			boyfriend.color = 0xFFFFA36D;//orange
		case 120:
			boyfriend.color = 0xFF7A7CFF;
		case 124:
			boyfriend.color = 0xFFFF7676;
		case 128:
			boyfriend.color = 0x00FFFFFF;
			dad.color = 0xFFE092FB;
		case 132:
			dad.color = 0xFF62FF56;
		case 136:
			dad.color = 0xFF7A7CFF;
		case 140:
			dad.color = 0xFF7A7CFF;
		case 144:
			dad.color = 0x00FFFFFF;
			boyfriend.color = 0xFF62FF56;
		case 148:
			boyfriend.color = 0xFF62FF56;
		case 152:
			boyfriend.color = 0xFFFF7676;
		case 156:
			boyfriend.color = 0xFFFFA36D;
		case 159:
			boyfriend.color = 0x00FFFFFF;
		case 160:
			dad.color = 0xFF78F5FD;
		case 165:
			dad.color = 0xFFFFA36D;
		case 168:
			dad.color = 0xFFFF7676;
		case 172:
			dad.color =0xFFE092FB;
		case 175:
			dad.color = 0x00FFFFFF;
		case 176:
			boyfriend.color = 0xFF62FF56;
		case 180:
			boyfriend.color = 0xFF62FF56;
		case 184:
			boyfriend.color = 0xFF7A7CFF;
		case 188:
			boyfriend.color = 0xFFFF7676;
		case 192:
			blammedlightend();
			boyfriend.color = 0x00FFFFFF;
		}
	}
if (curSong =='Thorns')
	{
		switch (curBeat)
		{
		case 1:bgGirlevil.hey();
		case 65:bgGirlevil.hey();
		case 68:bgGirlevil.hey();
		case 71:bgGirlevil.hey();
		case 74:bgGirlevil.hey();
		case 78:bgGirlevil.hey();
		case 81:bgGirlevil.hey();
		case 87:bgGirlevil.hey();
		case 90:bgGirlevil.hey();
		case 92:bgGirlevil.hey();
		case 163:bgGirlevil.hey();
		case 165:bgGirlevil.hey();
		case 167:bgGirlevil.hey();
		case 169:bgGirlevil.hey();
		case 171:bgGirlevil.hey();
		case 173:bgGirlevil.hey();
		case 175:bgGirlevil.hey();
		case 178:bgGirlevil.hey();
		case 180:bgGirlevil.hey();
		case 183:bgGirlevil.hey();
		case 186:bgGirlevil.hey();
		case 189:bgGirlevil.hey();
		case 256:
			bgGirlevil.hey();
		    thornscharEvent();
		case 259:bgGirlevil.hey();
		case 262:bgGirlevil.hey();
		case 265:bgGirlevil.hey();
		case 267:bgGirlevil.hey();
		case 270:bgGirlevil.hey();
		case 273:bgGirlevil.hey();
		case 275:bgGirlevil.hey();
		case 278:bgGirlevil.hey();
		case 280:bgGirlevil.hey();
		case 283:bgGirlevil.hey();
		case 285:bgGirlevil.hey();
		case 288:bgGirlevil.hey();
        case 290:errorEvent();
		case 296:remove(bgGirlevil);
		}
	}
		switch (curStage)
		{
			case 'tank':
				tankWatchtower.dance();
			case 'school':
				bgGirls.dance();
			case 'mall':
				upperBoppers.animation.play('bop', true);
				bottomBoppers.animation.play('bop', true);
				santa.animation.play('idle', true);

			case 'limo':
				grpLimoDancers.forEach(function(dancer:BackgroundDancer)
				{
					dancer.dance();
				});

				if (FlxG.random.bool(10) && fastCarCanDrive)
					fastCarDrive();
			case "philly":
				if (!trainMoving)
					trainCooldown += 1;

				if (curBeat % 4 == 0)
				{
					lightFadeShader.reset();

					phillyCityLights.forEach(function(light:FlxSprite)
					{
						light.visible = false;
					});

					curLight = FlxG.random.int(0, phillyCityLights.length - 1);

					phillyCityLights.members[curLight].visible = true;
					// phillyCityLights.members[curLight].alpha = 1;
				}

				if (curBeat % 8 == 4 && FlxG.random.bool(30) && !trainMoving && trainCooldown > 8)
				{
					trainCooldown = FlxG.random.int(-4, 0);
					trainStart();
				}
		}

		if (isHalloween && FlxG.random.bool(10) && curBeat > lightningStrikeBeat + lightningOffset)
		{
			lightningStrikeShit();
		}
	}

	var curLight:Int = 0;
}
