// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.Main

package com.mcleodgaming.ssf2
{
    import flash.display.MovieClip;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.engine.CharacterData;
    import flash.text.TextField;
    import libraries.uanalytics.tracking.AnalyticsTracker;
    import flash.system.Security;
    import com.mcleodgaming.mgn.net.MGNClient;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.input.GamepadManager;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import flash.display.StageScaleMode;
    import flash.ui.ContextMenu;
    import com.mcleodgaming.ssf2.util.MouseTracker;
    import com.mcleodgaming.ssf2.util.Key;
    import com.mcleodgaming.ssf2.enums.SpecialMode;
    import com.mcleodgaming.ssf2.net.MultiplayerManager;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.events.KeyboardEvent;
    import flash.events.NativeWindowDisplayStateEvent;
    import flash.utils.setTimeout;
    import com.mcleodgaming.ssf2.input.Gamepad;
    import flash.display.StageDisplayState;
    import flash.display.NativeWindowDisplayState;
    import com.mcleodgaming.ssf2.audio.SoundQueue;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import flash.geom.Rectangle;
    import flash.display.InteractiveObject;
    import flash.utils.getQualifiedClassName;
    import flash.net.registerClassAlias;
    import flash.net.LocalConnection;
    import com.mcleodgaming.ssf2.engine.Stats;
    import flash.net.URLRequest;
    import flash.external.ExternalInterface;
    import flash.net.navigateToURL;
    import com.mcleodgaming.ssf2.util.SaveDataMigrations;
    import libraries.uanalytics.tracking.Configuration;
    import libraries.uanalytics.tracker.AppTracker;
    import com.mcleodgaming.ssf2.items.ItemsListData;
    import com.mcleodgaming.ssf2.controllers.UnlockController;
    import flash.net.getClassByAlias;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.audio.*;
    import com.mcleodgaming.ssf2.controllers.*;
    import com.adobe.images.*;
    import com.mcleodgaming.ssf2.assists.*;
    import com.mcleodgaming.ssf2.enemies.*;
    import com.mcleodgaming.ssf2.engine.*;
    import com.mcleodgaming.ssf2.items.*;
    import com.mcleodgaming.ssf2.enums.*;
    import com.mcleodgaming.ssf2.menus.*;
    import com.mcleodgaming.ssf2.net.*;
    import com.mcleodgaming.ssf2.platforms.*;
    import com.mcleodgaming.ssf2.pokemon.*;
    import flash.net.*;
    import __AS3__.vec.*;

    public dynamic class Main extends MovieClip 
    {

        private static var ROOT:Main;
        private static var m_classRefs:Array = new Array(menu_preloader);
        private static var m_randCharList:Vector.<CharacterData>;
        private static var m_randMusicIndex:int;
        private static var m_guidID:Number = 0;
        private static var m_width:Number = 640;
        private static var m_height:Number = 360;
        public static const MAXPLAYERS:int = 4;
        public static const SHOWMASK:Boolean = true;
        public static const ENCRYPTED:Boolean = Config.encrypt_files;//true
        private static const DEBUGCONST:Boolean = true;
        public static var FORCEDEBUGOFF:Boolean = false;
        public static var DEBUGAUTHED:Boolean = true;
        public static var LOCALHOST:Boolean = true;
        public static var DOMAIN:String = "localhost";
        public static var AUTHORIZED:Boolean = false;
        public static const FRAMERATE:int = 30;
        public static const GAID:String = "UA-35183034-6";
        public static var m_debugField:TextField;
        public static var preloader:MovieClip;
        public static var tracker:AnalyticsTracker;

        public function Main()
        {
            super();
            Security.loadPolicyFile(MGNClient.POLICY_FILE);
            Utils.initializeUtilsClass();
            ROOT = this;
            try
            {
                SaveData.initializeSaveData();
            }
            catch(e)
            {
                SaveData.corrupted = true;
                SaveData.eraseGame();
            };
            GamepadManager.init();
            preloader = MovieClip(ROOT.addChild(ResourceManager.getLibraryMC("menu_preloader")));
            preloader.x = (Main.Width / 2);
            preloader.y = (Main.Height / 2);
            m_debugField = new TextField();
            stage.scaleMode = StageScaleMode.SHOW_ALL;
            stage.showDefaultContextMenu = false;
            stage.stageFocusRect = false;
            var myMenu:ContextMenu = new ContextMenu();
            myMenu.hideBuiltInItems();
            this.contextMenu = myMenu;
            makeClassStringArr();
            ResourceManager.init();
            MouseTracker.initializeMouseClass();
            MouseTracker.setAutoHide(ROOT.stage, true);
            Key.initializeKeyClass();
            Key.beginCapture(ROOT.stage);
            SpecialMode.init();
            MultiplayerManager.init();
            trace("Main Method started");
            stage.addEventListener(Event.RESIZE, this.resizeListener);
            Main.initResources();
            m_randCharList = new Vector.<CharacterData>();
            m_randMusicIndex = 0;
            this.stage.quality = SaveData.Quality.display_quality;
            wideScreenScrollRect();
            setFullScreenMode(SaveData.Quality.fullscreen_quality);
            ROOT.stage.addEventListener(Event.FULLSCREEN, fixMenu);
            ROOT.loaderInfo.addEventListener(ProgressEvent.PROGRESS, ROOT.onRootLoadProgress);
            ROOT.loaderInfo.addEventListener(Event.COMPLETE, ROOT.onRootLoadComplete);
            ROOT.stage.addEventListener(KeyboardEvent.KEY_DOWN, handleGlobalKeypress);
            ROOT.stage.nativeWindow.addEventListener(NativeWindowDisplayStateEvent.DISPLAY_STATE_CHANGE, windowStateChanged);
            setTimeout(function ():void
            {
                var p:*;
                var g:int;
                var port:int;
                var gamepads:Vector.<Gamepad> = GamepadManager.getGamepads();
                for (p in SaveData.PortInputs)
                {
                    g = 0;
                    while (g < gamepads.length)
                    {
                        if (((SaveData.PortInputs[p] === ((gamepads[g].Name + " ") + gamepads[g].Port)) && (SaveData.Gamepads[gamepads[g].Name])))
                        {
                            port = parseInt(p);
                            SaveData.Controllers[(port - 1)].GamepadInstance = gamepads[g];
                            gamepads[g].importControls(SaveData.Gamepads[gamepads[g].Name].ports[("port" + gamepads[g].Port)]);
                        };
                        g++;
                    };
                };
            }, 1000);
        }

        public static function get isFullscreen():Boolean
        {
            return (ROOT.stage.displayState === StageDisplayState.FULL_SCREEN_INTERACTIVE);
        }

        public static function windowStateChanged(e:NativeWindowDisplayStateEvent):void
        {
            if (((e.beforeDisplayState === NativeWindowDisplayState.NORMAL) && (e.afterDisplayState === NativeWindowDisplayState.MAXIMIZED)))
            {
                ROOT.stage.nativeWindow.restore();
                setTimeout(function ():void
                {
                    toggleFullScreen(true);
                }, 1);
            };
        }

        private static function handleGlobalKeypress(e:KeyboardEvent):void
        {
            if (((e.ctrlKey) && (e.keyCode === 70)))
            {
                toggleFullScreen((!(Main.isFullscreen)));
            };
            if (((((e.ctrlKey) && (e.shiftKey)) && (e.keyCode === Key.M)) && (!(Main.preloader))))
            {
                SoundQueue.instance.MusicIsMuted = (!(SoundQueue.instance.MusicIsMuted));
                if (SoundQueue.instance.MusicIsMuted)
                {
                    MenuController.muteMenu.SubMenu.gotoAndStop("muted");
                }
                else
                {
                    MenuController.muteMenu.SubMenu.gotoAndStop("unmuted");
                };
                MenuController.muteMenu.removeSelf();
                MenuController.muteMenu.show();
            };
        }

        public static function toggleFullScreen(value:Boolean):void
        {
            if ((!(Main.isFullscreen)))
            {
                Main.Root.stage.displayState = StageDisplayState.FULL_SCREEN_INTERACTIVE;
            }
            else
            {
                Main.Root.stage.displayState = StageDisplayState.NORMAL;
            };
        }

        public static function setFullScreenMode(mode:int):void
        {
            if (mode == 0)
            {
                Main.Root.stage.fullScreenSourceRect = new Rectangle(0, 0, Main.Width, Main.Height);
            }
            else
            {
                if (mode == 1)
                {
                    Main.Root.stage.fullScreenSourceRect = null;
                };
            };
        }

        public static function setFocus(object:InteractiveObject):void
        {
            Main.Root.stage.focus = object;
        }

        public static function fixFocus():void
        {
            Main.Root.stage.focus = Main.Root.stage;
        }

        public static function fixMenu(e:Event):void
        {
            ROOT.stage.showDefaultContextMenu = false;
        }

        public static function resetScrollRect():void
        {
            Main.Root.scrollRect = null;
        }

        public static function wideScreenScrollRect():void
        {
        }

        private static function makeClassStringArr():void
        {
            var fullname:String;
            var alias:String;
            var i:int;
            while (i < m_classRefs.length)
            {
                fullname = getQualifiedClassName(m_classRefs[i]);
                alias = fullname.substr((fullname.indexOf("::") + 2));
                registerClassAlias(alias, m_classRefs[i]);
                i++;
            };
        }

        private static function randomTest():void
        {
            var total:Number = 0;
            var i:int;
            while (i < 1000000)
            {
                total = (total + Utils.random());
                i++;
            };
            trace((("[Random test complete: Average rand value is " + (total / 1000000)) + "]"));
        }

        private static function initResources():void
        {
            var localDomainLC:LocalConnection = new LocalConnection();
            var myDomainName:String = localDomainLC.domain;
            if ((((myDomainName == "localhost") || (myDomainName == "127.0.0.1")) || (myDomainName.match(/^app#com\.mcleodgaming\.ssf2(?:2|3|4)?$/))))
            {
                Main.AUTHORIZED = true;
            }
            else
            {
                if ((((myDomainName.match(/mcleodgaming\.com$/)) || (myDomainName.match(/ssf2\.com$/))) || (myDomainName.match(/supersmashflash\.com$/))))
                {
                    Main.DOMAIN = myDomainName;
                    Main.LOCALHOST = false;
                    Main.AUTHORIZED = true;
                };
            };
        }

        public static function prepRandomCharacters(amount:Number):void
        {
            m_randCharList = new Vector.<CharacterData>();
            while (m_randCharList.length < amount)
            {
                m_randCharList.push(Stats.getRandomCharacter());
            };
        }

        public static function clearRandomCharacterPrep():void
        {
            m_randCharList.splice(0, m_randCharList.length);
        }

        public static function prepRandomMusic(index:Number):void
        {
            if ((((Main.DEBUG) || (SaveData.Unlocks.alternate_tracks)) || (ResourceManager.FORCE_ENABLE_ALT_TRACKS)))
            {
                ResourceManager.FORCE_ENABLE_ALT_TRACKS = false;
                m_randMusicIndex = index;
            }
            else
            {
                m_randMusicIndex = 0;
            };
        }

        public static function getURL(url:*, window:String="_self"):void
        {
            var strUserAgent:String;
            var req:URLRequest = ((url is String) ? new URLRequest(url) : url);
            if ((!(ExternalInterface.available)))
            {
                navigateToURL(req, window);
            }
            else
            {
                strUserAgent = String(ExternalInterface.call("function() {return navigator.userAgent;}")).toLowerCase();
                if (((!(strUserAgent.indexOf("firefox") == -1)) || ((!(strUserAgent.indexOf("msie") == -1)) && (uint(strUserAgent.substr((strUserAgent.indexOf("msie") + 5), 3)) >= 7))))
                {
                    ExternalInterface.call("window.open", req.url, window);
                }
                else
                {
                    navigateToURL(req, window);
                };
            };
        }

        private static function resourceLoadProgress(percent:Number):void
        {
            Main.preloader.pCent.text = ("" + Math.floor(((100 * (1 / 20)) + ((19 / 20) * percent))));
            Main.preloader.progressBar.scaleX = Math.floor(((100 * (1 / 20)) + ((19 / 20) * percent)));
        }

        private static function initGame():void
        {
            try
            {
                while (SaveDataMigrations.postLoadMigrations.length > 0)
                {
                    var _local_2:* = SaveDataMigrations.postLoadMigrations;
                    (_local_2[0]());
                    SaveDataMigrations.postLoadMigrations.splice(0, 1);
                };
            }
            catch(e)
            {
                SaveData.corrupted = true;
            };
            var config:Configuration = new Configuration();
            config.forcePOST = true;
            config.forceSSL = false;
            tracker = new AppTracker(Main.GAID, config);
            if (LOCALHOST)
            {
                tracker.event("SSF2 Local", "load", Version.getVersion());
            }
            else
            {
                tracker.event("SSF2 Web", "load", Version.getVersion());
            };
            Stats.init();
            ItemsListData.init();
            MenuController.init();
            UnlockController.init();
            ROOT.loaderInfo.removeEventListener(Event.COMPLETE, ROOT.onRootLoadComplete);
            if (Main.preloader.parent)
            {
                Main.preloader.parent.removeChild(Main.preloader);
                Main.preloader = null;
            };
            if (Main.AUTHORIZED)
            {
                if (Main.DEBUG)
                {
                    MenuController.showInitialMenu();
                }
                else
                {
                    MenuController.showInitialMenu();
                };
            }
            else
            {
                MenuController.blockedMenu.show();
            };
            if (SaveData.corrupted)
            {
                MultiplayerManager.makeNotifier();
                MultiplayerManager.notify("Warning, save data has been corrupted and could not be recovered. Initializing with clean save file.");
                SaveData.corrupted = false;
            };
        }

        public static function get Root():Main
        {
            return (ROOT);
        }

        public static function getClassByName(str:String):Class
        {
            var cls:Class;
            try
            {
                cls = getClassByAlias(str);
                return (cls);
            }
            catch(e)
            {
            };
            return (cls);
        }

        public static function getClassName(obj:*):String
        {
            return (getQualifiedClassName(obj));
        }

        public static function get DebugField():TextField
        {
            return (m_debugField);
        }

        public static function get Width():Number
        {
            return (m_width);
        }

        public static function get Height():Number
        {
            return (m_height);
        }

        public static function get DEBUG():Boolean
        {
            return ((DEBUGCONST) && (!(FORCEDEBUGOFF)));
        }

        public static function get RandCharList():Vector.<CharacterData>
        {
            return (m_randCharList);
        }

        public static function get RandMusicIndex():int
        {
            return (m_randMusicIndex);
        }

        public static function turnOffDebug():void
        {
            FORCEDEBUGOFF = true;
        }


        private function onRootLoadProgress(e:ProgressEvent):void
        {
            var total:int = ((e.bytesTotal == 0) ? 706780 : e.bytesTotal);
            var pcent:Number = ((e.bytesLoaded / total) * 100);
            if (((pcent > 100) || (isNaN(pcent))))
            {
                pcent = 0;
            };
            Main.preloader.percentage = pcent;
            Main.preloader.pCent.text = Math.floor((pcent * (1 / 20)));
            Main.preloader.progressBar.scaleX = ((pcent / 100) * (1 / 20));
        }

        protected function onRootLoadComplete(event:Event):void
        {
            ROOT.loaderInfo.removeEventListener(ProgressEvent.PROGRESS, ROOT.onRootLoadProgress);
            ROOT.loaderInfo.removeEventListener(Event.COMPLETE, ROOT.onRootLoadComplete);
            ResourceManager.queueRequiredResources();
            ResourceManager.load({
                "onprogress":resourceLoadProgress,
                "oncomplete":initGame
            });
        }

        private function resizeListener(e:Event):void
        {
            trace("resized");
        }


    }
}//package com.mcleodgaming.ssf2

