// Decompiled by AS3 Sorcerer 6.30
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.util.Utils

package com.mcleodgaming.ssf2.util
{
    import flash.geom.Rectangle;
    import flash.geom.Point;
    import flash.net.FileReference;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.engine.Stats;
    import com.mcleodgaming.ssf2.enums.Mode;
    import com.mcleodgaming.ssf2.engine.StageData;
    import com.mcleodgaming.ssf2.engine.InteractiveSprite;
    import flash.display.DisplayObject;
    import flash.display.MovieClip;
    import fl.motion.AdjustColor;
    import flash.filters.ColorMatrixFilter;
    import flash.geom.ColorTransform;
    import flash.display.Bitmap;
    import flash.utils.Dictionary;
    import flash.display.BitmapData;
    import com.adobe.images.PNGEncoder;
    import flash.utils.ByteArray;
    import com.mcleodgaming.ssf2.Main;
    import flash.display.FrameLabel;
    import flash.text.TextFormat;
    import flash.text.TextField;
    import __AS3__.vec.Vector;
    import com.mcleodgaming.ssf2.engine.AttackDamage;
    import com.mcleodgaming.ssf2.engine.Projectile;
    import com.mcleodgaming.ssf2.items.Item;
    import flash.utils.getDefinitionByName;
    import flash.utils.getQualifiedClassName;
    import com.mcleodgaming.ssf2.engine.Beacon;
    import flash.events.Event;
    import flash.events.IOErrorEvent;
    import flash.events.SecurityErrorEvent;
    import flash.events.ProgressEvent;
    import flash.net.FileFilter;
    import flash.net.URLLoader;
    import flash.net.URLLoaderDataFormat;
    import flash.net.URLRequest;
    import com.mcleodgaming.ssf2.engine.*;
    import __AS3__.vec.*;

    public class Utils 
    {

        public static var VELOCITY_SCALE:Number = 3.488;
        public static var WEIGHT2_BASE:Number = 0.051;
        public static var KEY_ARR:Object = getKeysArray(false);
        public static var KEY_ARR_SHORT:Object = getKeysArray(true);
        public static const EMPTY_PALETTE_SWAP:Object = {
            "colors":[],
            "replacements":[]
        };
        private static var rndm:Rndm;
        private static var safeRndm:Rndm;
        private static var origSeed:Number;
        private static var lastRandom:Number;
        private static var lastSafeRandom:Number;
        private static var UID:int = 0;
        private static var paletteRect:Rectangle = new Rectangle();
        private static var palettePoint:Point = new Point();
        private static var KEY:String = "b0cb1f1f-bc82-40bc-a1d7-1a2d16a6e8d1";
        public static var openSuccess:Boolean = false;
        public static var saveSuccess:Boolean = false;
        public static var finishedLoading:Boolean = false;
        public static var cancelled:Boolean = false;
        public static var fileRef:FileReference;

        {
            init();
        }


        public static function init():void
        {
        }

        public static function initializeUtilsClass():void
        {
            Utils.rndm = new Rndm();
            Utils.safeRndm = new Rndm();
            origSeed = Math.round(((Math.random() * 1000000) + 1));
            Utils.setRandSeed(origSeed);
            trace(("Utils class initialized w/ seed of " + origSeed));
        }

        public static function resetUID():void
        {
            Utils.UID = 0;
        }

        public static function getUID():int
        {
            if (Utils.UID >= int.MAX_VALUE)
            {
                Utils.UID = 0;
            };
            return (Utils.UID++);
        }

        public static function get LastRandom():Number
        {
            return (lastRandom);
        }

        public static function get LastSafeRandom():Number
        {
            return (lastSafeRandom);
        }

        public static function fastAbs(input:Number):Number
        {
            return ((input > 0) ? input : -(input));
        }

        public static function getSign(input:Number):Number
        {
            return ((input > 0) ? 1 : -1);
        }

        public static function framesToMinutesString(frames:int, fps:Number=30):String
        {
            var minutes:int = int((frames / (fps * 60)));
            return (minutes + "");
        }

        public static function framesToSecondsString(frames:int, fps:Number=30):String
        {
            var minutes:int = int((frames / (fps * 60)));
            var seconds:int = int(((frames - ((minutes * fps) * 60)) / fps));
            return ((seconds < 10) ? ("0" + seconds) : (seconds + ""));
        }

        public static function framesToMillisecondsString(frames:int, fps:Number=30):String
        {
            var minutes:int = int((frames / (fps * 60)));
            var seconds:int = int(((frames - ((minutes * fps) * 60)) / fps));
            var milliseconds:int = int(((((frames - ((minutes * fps) * 60)) - (seconds * fps)) / fps) * 100));
            return ((milliseconds < 10) ? ("0" + milliseconds) : (milliseconds + ""));
        }

        public static function framesToTimeString(numFrames:int):String
        {
            return ((((Utils.framesToMinutesString(numFrames) + ":") + Utils.framesToSecondsString(numFrames)) + " '") + Utils.framesToMillisecondsString(numFrames));
        }

        public static function generateReplaySaveFileName(stageData:StageData):String
        {
            var playerStr:String;
            var playerChar:String;
            var date:Date = new Date();
            var year:String = ("" + date.getFullYear());
            var month:String = ((date.getMonth() < 9) ? ("0" + (date.getMonth() + 1)) : ("" + (date.getMonth() + 1)));
            var day:String = ((date.getDate() < 9) ? ("0" + (date.getDate() + 1)) : ("" + (date.getDate() + 1)));
            var hours:String = ((date.getHours() < 13) ? ("" + date.getHours()) : ("" + (date.getHours() - 12)));
            var minutes:String = ("" + date.getMinutes());
            var ampm:String = ((date.getHours() < 12) ? "AM" : "PM");
            if (date.getMinutes() < 10)
            {
                minutes = ("0" + minutes);
            };
            var playerNames:Array = [];
            var i:int;
            while (i < stageData.Players.length)
            {
                if (stageData.Players[i])
                {
                    playerStr = "";
                    playerChar = Stats.getStats(stageData.Players[i].getPlayerSettings().character).DisplayName;
                    if (stageData.Players[i].IsHuman)
                    {
                        if (stageData.Players[i].getPlayerSettings().name)
                        {
                            playerStr = stageData.Players[i].getPlayerSettings().name;
                        }
                        else
                        {
                            playerStr = ("P" + (i + 1));
                        };
                    }
                    else
                    {
                        playerStr = ("CPU Lvl " + stageData.Players[i].getPlayerSettings().level);
                    };
                    playerStr = playerStr.replace(/^[^a-zA-Z_]+|[^a-zA-Z_0-9\s\-]+/g, "");
                    playerChar = playerChar.replace(/&/g, "and");
                    playerChar = playerChar.replace(/^[^a-zA-Z_]+|[^a-zA-Z_0-9\s\-]+/g, "");
                    playerNames.push((((playerStr + " (") + playerChar) + ")"));
                };
                i++;
            };
            var mode:String = "";
            if (stageData.GameRef.GameMode === Mode.VS)
            {
                mode = "Versus";
            }
            else
            {
                if (stageData.GameRef.GameMode === Mode.ONLINE)
                {
                    mode = "VersusOnline";
                }
                else
                {
                    if (stageData.GameRef.GameMode === Mode.ARENA)
                    {
                        mode = "Arena";
                    }
                    else
                    {
                        if (stageData.GameRef.GameMode === Mode.ONLINE_ARENA)
                        {
                            mode = "ArenaOnline";
                        }
                        else
                        {
                            if (stageData.GameRef.GameMode === Mode.TARGET_TEST)
                            {
                                mode = "BTT ";
                                mode = (mode + stageData.GameRef.LevelData.customModeID);
                            }
                            else
                            {
                                if (stageData.GameRef.GameMode === Mode.HOME_RUN_CONTEST)
                                {
                                    mode = stageData.GameRef.LevelData.customModeID;
                                }
                                else
                                {
                                    if (stageData.GameRef.GameMode === Mode.MULTIMAN)
                                    {
                                        mode = "Multiman";
                                        if (stageData.GameRef.LevelData.customModeID == "man10")
                                        {
                                            mode = (mode + "10");
                                        }
                                        else
                                        {
                                            if (stageData.GameRef.LevelData.customModeID == "man100")
                                            {
                                                mode = (mode + "100");
                                            }
                                            else
                                            {
                                                if (stageData.GameRef.LevelData.customModeID == "min3")
                                                {
                                                    mode = (mode + "3Min");
                                                }
                                                else
                                                {
                                                    if (stageData.GameRef.LevelData.customModeID == "endless")
                                                    {
                                                        mode = (mode + "Endless");
                                                    }
                                                    else
                                                    {
                                                        if (stageData.GameRef.LevelData.customModeID == "cruel")
                                                        {
                                                            mode = (mode + "Cruel");
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    }
                                    else
                                    {
                                        if (stageData.GameRef.GameMode === Mode.CRYSTAL_SMASH)
                                        {
                                            mode = "CrystalSmash ";
                                            mode = (mode + stageData.GameRef.LevelData.customModeID);
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
            if (mode)
            {
                mode = (mode + " - ");
            };
            return (((((((((((((year + "-") + month) + "-") + day) + " ") + hours) + ".") + minutes) + " ") + ampm) + " - ") + mode) + playerNames.join(" vs "));
        }

        public static function toRadians(input:Number):Number
        {
            return (input * (Math.PI / 180));
        }

        public static function toDegrees(input:Number):Number
        {
            return (input * (180 / Math.PI));
        }

        public static function getDistanceFrom(x1:InteractiveSprite, x2:InteractiveSprite):Number
        {
            if (((x1 == null) || (x2 == null)))
            {
                return (0);
            };
            return (Math.sqrt((Math.pow((x1.X - x2.X), 2) + Math.pow((x1.Y - x2.Y), 2))));
        }

        public static function getDistance(point1:Point, point2:Point):Number
        {
            if (((point1 == null) || (point2 == null)))
            {
                return (0);
            };
            return (Math.sqrt((Math.pow((point1.x - point2.x), 2) + Math.pow((point1.y - point2.y), 2))));
        }

        public static function calculateXSpeed(speed:Number, angle:Number):Number
        {
            return (speed * Math.cos(((angle * Math.PI) / 180)));
        }

        public static function calculateYSpeed(speed:Number, angle:Number):Number
        {
            return (speed * Math.sin(((angle * Math.PI) / 180)));
        }

        public static function calculateSpeed(x_speed:Number, y_speed:Number):Number
        {
            return (Math.sqrt((Math.pow(x_speed, 2) + Math.pow(y_speed, 2))));
        }

        public static function calculateHeightDiff(x_speed:Number, angle:Number=45, cap:Number=10):Number
        {
            if (x_speed > cap)
            {
                x_speed = cap;
            };
            return (Utils.fastAbs((x_speed * Math.tan(Utils.toRadians(Utils.forceBase360(angle))))));
        }

        public static function calculateBounceSpeed(fallSpeed:Number, gravity:Number, bounceAmount:Number):Number
        {
            fallSpeed = Utils.fastAbs(fallSpeed);
            gravity = Utils.fastAbs(gravity);
            var topY:Number = 0;
            var targetY:Number = 0;
            var ticks:int;
            var currentYSpeed:Number = -(fallSpeed);
            while (currentYSpeed < 0)
            {
                topY = (topY + currentYSpeed);
                currentYSpeed = (currentYSpeed + gravity);
            };
            targetY = (topY * bounceAmount);
            currentYSpeed = -(fallSpeed);
            topY = 0;
            while (((topY > targetY) && (currentYSpeed < 0)))
            {
                ticks++;
                topY = (topY + currentYSpeed);
                currentYSpeed = (currentYSpeed + gravity);
            };
            return (currentYSpeed - (gravity * ticks));
        }

        public static function getSpeedCap(value:Number, defaultSpeed:Number):Number
        {
            if (value < 0)
            {
                return (defaultSpeed);
            };
            return (value);
        }

        public static function swapLocations(mc1:DisplayObject, mc2:DisplayObject):void
        {
            var tmpX:int = mc1.x;
            var tmpY:int = mc1.y;
            mc1.x = mc2.x;
            mc1.y = mc2.y;
            mc2.x = tmpX;
            mc2.y = tmpY;
        }

        public static function swapDepths(mc1:DisplayObject, mc2:DisplayObject):void
        {
            if (((((!(mc1 == null)) && (!(mc2 == null))) && (mc1.parent == mc2.parent)) && (!(mc1.parent == null))))
            {
                mc1.parent.swapChildren(mc1, mc2);
            };
        }

        public static function tryToGotoAndPlay(mc:MovieClip, frame:*, cache:Boolean=false):void
        {
            if (((frame is int) || (frame is Number)))
            {
                if (((frame > 0) && (frame <= mc.totalFrames)))
                {
                    mc.gotoAndPlay(frame);
                };
            }
            else
            {
                if ((frame is String))
                {
                    if (Utils.hasLabel(mc, frame, cache))
                    {
                        mc.gotoAndPlay(frame);
                    };
                };
            };
        }

        public static function tryToGotoAndStop(mc:MovieClip, frame:*, cache:Boolean=false):void
        {
            if ((!(mc)))
            {
                return;
            };
            if (((frame is int) || (frame is Number)))
            {
                if (((frame > 0) && (frame <= mc.totalFrames)))
                {
                    mc.gotoAndStop(frame);
                };
            }
            else
            {
                if ((frame is String))
                {
                    if (Utils.hasLabel(mc, frame, cache))
                    {
                        mc.gotoAndStop(frame);
                    };
                };
            };
        }

        public static function getFileNameFromURL(url:String):String
        {
            var lastSlash:int = url.lastIndexOf("/");
            if (lastSlash == (url.length - 1))
            {
                url = url.substr(0, (url.length - 1));
            };
            lastSlash = url.lastIndexOf("/");
            if (((lastSlash < 0) || (lastSlash == (url.length - 1))))
            {
                return (url);
            };
            return (url.substr((lastSlash + 1)));
        }

        public static function getColorString(num:int):String
        {
            return ((num == 1) ? "red" : ((num == 2) ? "green" : ((num == 3) ? "blue" : null)));
        }

        public static function getCostumeObject(obj:Object=null):Object
        {
            var i:*;
            obj = ((obj) ? Utils.cloneObject(obj) : {});
            var colorObj:Object = new Object();
            colorObj.hue = 0;
            colorObj.saturation = 0;
            colorObj.brightness = 0;
            colorObj.contrast = 0;
            colorObj.redMultiplier = 1;
            colorObj.greenMultiplier = 1;
            colorObj.blueMultiplier = 1;
            colorObj.alphaMultiplier = 1;
            colorObj.redOffset = 0;
            colorObj.greenOffset = 0;
            colorObj.blueOffset = 0;
            colorObj.alphaOffset = 0;
            for (i in colorObj)
            {
                if (obj[i] === undefined)
                {
                    obj[i] = colorObj[i];
                };
            };
            return (obj);
        }

        public static function setColorFilterCharacter(mc:MovieClip, team_id:int, statsName:String, costumeID:int=-1, PAPalette:Boolean=false, paletteSmoothing:Boolean=false):void
        {
            var colorStr:String = Utils.getColorString(team_id);
            var colorObj:Object = ResourceManager.getCostume(statsName, colorStr, costumeID);
            if (colorObj == null)
            {
                colorObj = Utils.getCostumeObject();
            };
            if (colorObj != null)
            {
                Utils.setColorFilter(mc, colorObj);
            };
            Utils.replacePalette(mc, ((PAPalette) ? colorObj.paletteSwapPA : colorObj.paletteSwap), 2, true, paletteSmoothing);
        }

        public static function setColorFilter(mc:DisplayObject, settings:Object):void
        {
            var cFilter:AdjustColor;
            var matrix:Array;
            if (((!(mc)) || (!(settings))))
            {
                mc.filters = null;
                return;
            };
            settings = Utils.getCostumeObject(settings);
            var filters:Array = [];
            if ((!((((settings.hue == 0) && (settings.saturation == 0)) && (settings.brightness == 0)) && (settings.contrast == 0))))
            {
                cFilter = new AdjustColor();
                cFilter.hue = ((settings.hue) || (0));
                cFilter.saturation = ((settings.saturation) || (0));
                cFilter.brightness = ((settings.brightness) || (0));
                cFilter.contrast = ((settings.contrast) || (0));
                filters.push(new ColorMatrixFilter(cFilter.CalculateFinalFlatArray()));
            };
            if ((!((((((((settings.redMultiplier == 1) && (settings.greenMultiplier == 1)) && (settings.blueMultiplier == 1)) && (settings.alphaMultiplier == 1)) && (settings.redOffset == 0)) && (settings.greenOffset == 0)) && (settings.blueOffset == 0)) && (settings.alphaOffset == 0))))
            {
                matrix = new Array();
                matrix = matrix.concat([settings.redMultiplier, 0, 0, 0, settings.redOffset]);
                matrix = matrix.concat([0, settings.greenMultiplier, 0, 0, settings.greenOffset]);
                matrix = matrix.concat([0, 0, settings.blueMultiplier, 0, settings.blueOffset]);
                matrix = matrix.concat([0, 0, 0, ((settings.alphaMultiplier) || (1)), settings.alphaOffset]);
                filters.push(new ColorMatrixFilter(matrix));
            };
            mc.filters = filters;
        }

        public static function setTint(mc:DisplayObject, redMultiplier:Number, greenMultiplier:Number, blueMultiplier:Number, alphaMultiplier:Number, redOffset:Number, greenOffset:Number, blueOffset:Number, alphaOffset:Number):void
        {
            var clipColor:ColorTransform = new ColorTransform();
            clipColor.redMultiplier = redMultiplier;
            clipColor.greenMultiplier = greenMultiplier;
            clipColor.blueMultiplier = blueMultiplier;
            clipColor.alphaMultiplier = alphaMultiplier;
            clipColor.redOffset = redOffset;
            clipColor.greenOffset = greenOffset;
            clipColor.blueOffset = blueOffset;
            clipColor.alphaOffset = alphaOffset;
            mc.transform.colorTransform = clipColor;
        }

        public static function setBrightness(mc:MovieClip, level:Number):void
        {
            if (Math.abs(level) > 100)
            {
                level = ((level > 0) ? 100 : -100);
            };
            var color:ColorTransform = new ColorTransform();
            color.redOffset = (level * 2.55);
            color.greenOffset = (level * 2.55);
            color.blueOffset = (level * 2.55);
            mc.transform.colorTransform = color;
        }

        public static function extractAlpha(n:int):int
        {
            return ((n & 0xFF000000) >> 24);
        }

        public static function extractRed(n:int):int
        {
            return ((n & 0xFF0000) >> 16);
        }

        public static function extractGreen(n:int):int
        {
            return ((n & 0xFF00) >> 8);
        }

        public static function extractBlue(n:int):int
        {
            return (n & 0xFF);
        }

        public static function convertTeamToColor(pid:int, teamID:int):int
        {
            var num:int = -1;
            if (teamID > 0)
            {
                switch (teamID)
                {
                    case 1:
                        num = 1;
                        break;
                    case 2:
                        num = 4;
                        break;
                    case 3:
                        num = 2;
                        break;
                };
            }
            else
            {
                switch (pid)
                {
                    case 1:
                        num = 1;
                        break;
                    case 2:
                        num = 2;
                        break;
                    case 3:
                        num = 3;
                        break;
                    case 4:
                        num = 4;
                        break;
                };
            };
            return (num);
        }

        public static function replacePalette(mc:MovieClip, paletteData:Object, recursion:int=1, cacheOriginal:Boolean=false, smoothing:Boolean=false):void
        {
            var i:int;
            var bitmap:Bitmap;
            if ((((paletteData) || (cacheOriginal)) && (mc)))
            {
                i = 0;
                bitmap = null;
                i = 0;
                while (i < mc.numChildren)
                {
                    if ((mc.getChildAt(i) is Bitmap))
                    {
                        bitmap = (mc.getChildAt(i) as Bitmap);
                        if (cacheOriginal)
                        {
                            if (((!(mc.__cachedPalette)) || (!(mc.__cachedPalette[bitmap.bitmapData]))))
                            {
                                mc.__cachedPalette = ((mc.__cachedPalette) || (new flash.utils.Dictionary(true)));
                                mc.__cachedPalette[bitmap.bitmapData] = bitmap.bitmapData.clone();
                            }
                            else
                            {
                                bitmap.bitmapData.draw(mc.__cachedPalette[bitmap.bitmapData]);
                            };
                        };
                        if (paletteData)
                        {
                            Utils.replacePaletteHelper(bitmap.bitmapData, paletteData);
                        };
                        bitmap.smoothing = smoothing;
                    }
                    else
                    {
                        if (((mc.getChildAt(i) is MovieClip) && (recursion > 0)))
                        {
                            Utils.replacePalette((mc.getChildAt(i) as MovieClip), paletteData, (recursion - 1), cacheOriginal, smoothing);
                        };
                    };
                    i++;
                };
            };
        }

        public static function replacePaletteHelper(bitmapData:BitmapData, paletteData:Object):void
        {
            Utils.paletteRect.width = bitmapData.width;
            Utils.paletteRect.height = bitmapData.height;
            var i:int;
            while (i < paletteData.colors.length)
            {
                if (paletteData.colors[i] != paletteData.replacements[i])
                {
                    bitmapData.threshold(bitmapData, Utils.paletteRect, Utils.palettePoint, "==", paletteData.colors[i], paletteData.replacements[i], 0xFFFFFFFF, true);
                };
                i++;
            };
        }

        public static function saveSnapShot(target:MovieClip):void
        {
            var bmpd:BitmapData = Utils.getSnapshot(target);
            var imgByteArray:ByteArray = PNGEncoder.encode(bmpd);
            Utils.saveFile(imgByteArray, "New SSF2 Screenshot.png");
            bmpd.dispose();
            bmpd = null;
        }

        public static function getSnapshot(target:MovieClip):BitmapData
        {
            var bmpd:BitmapData = new BitmapData(Main.Width, Main.Height);
            bmpd.draw(target);
            return (bmpd);
        }

        public static function removeActionScript(target:MovieClip):void
        {
            var i:int;
            while (i < target.totalFrames)
            {
                target.addFrameScript(i, null);
                i++;
            };
        }

        public static function setRandSeed(num:Number):void
        {
            Utils.rndm.seed = num;
            Utils.safeRndm.seed = num;
            trace(("Rand seed set to: " + num));
        }

        public static function random():Number
        {
            var tmp:Number = Utils.rndm.nextDouble();
            lastRandom = tmp;
            return (tmp);
        }

        public static function randomInteger(min:int, max:int):int
        {
            return (Math.floor((Utils.random() * ((max - min) + 1))) + min);
        }

        public static function shuffleRandom():void
        {
            var i:int;
            while (i < 100)
            {
                random();
                safeRandom();
                i++;
            };
        }

        public static function safeRandom():Number
        {
            var tmp:Number = Utils.safeRndm.nextDouble();
            lastSafeRandom = tmp;
            return (tmp);
        }

        public static function safeRandomInteger(min:int, max:int):int
        {
            return (Math.floor((Utils.safeRandom() * ((max - min) + 1))) + min);
        }

        public static function randomizeArray(arr:Array):void
        {
            var i:int;
            var indices:Array = new Array();
            var tempArr:Array = new Array();
            i = 0;
            while (i < arr.length)
            {
                indices.push(i);
                i++;
            };
            while (indices.length)
            {
                tempArr.push(arr[indices.splice(Utils.randomInteger(0, (indices.length - 1)), 1)[0]]);
            };
            i = 0;
            while (i < tempArr.length)
            {
                arr[i] = tempArr[i];
                i++;
            };
        }

        public static function hasLabel(mc:MovieClip, id:String, cache:Boolean=false):Boolean
        {
            var frameLabel:FrameLabel;
            var hasLabel:Boolean;
            if (mc == null)
            {
                return (false);
            };
            if (cache)
            {
                if (mc.__cachedLabels)
                {
                    return ((mc.__cachedLabels[id]) || (false));
                };
                mc.__cachedLabels = {};
            };
            var i:int;
            while (i < mc.currentLabels.length)
            {
                frameLabel = mc.currentLabels[i];
                if (id == frameLabel.name)
                {
                    hasLabel = true;
                };
                if (cache)
                {
                    mc.__cachedLabels[frameLabel.name] = true;
                }
                else
                {
                    if (hasLabel)
                    {
                        return (true);
                    };
                };
                i++;
            };
            return (hasLabel);
        }

        public static function fitText(field:TextField, origSize:Number, numLines:Number=1):void
        {
            var tFormat:TextFormat = field.getTextFormat();
            tFormat.size = origSize;
            field.setTextFormat(tFormat);
            while (field.numLines > numLines)
            {
                tFormat.size = (Number(tFormat.size) - 1);
                field.setTextFormat(tFormat);
            };
            field.setTextFormat(tFormat);
        }

        public static function recursiveMovieClipPlay(mc:MovieClip, shouldPlay:Boolean, pMode:Boolean=false):void
        {
            var e:int;
            while (((!(mc == null)) && (e < mc.numChildren)))
            {
                if ((mc.getChildAt(e) is MovieClip))
                {
                    recursiveMovieClipPlayChildren(MovieClip(mc.getChildAt(e)), shouldPlay, pMode);
                };
                e++;
            };
        }

        private static function recursiveMovieClipPlayChildren(mc:MovieClip, shouldPlay:Boolean, pMode:Boolean=false):void
        {
            if (mc.bypassTicker)
            {
                return;
            };
            if ((!(shouldPlay)))
            {
                mc.stop();
            }
            else
            {
                if (pMode)
                {
                    mc.play();
                }
                else
                {
                    if (mc.currentFrame == mc.totalFrames)
                    {
                        mc.gotoAndStop(1);
                    }
                    else
                    {
                        mc.nextFrame();
                    };
                };
            };
            var e:int;
            while (e < mc.numChildren)
            {
                if ((mc.getChildAt(e) is MovieClip))
                {
                    recursiveMovieClipPlayChildren(MovieClip(mc.getChildAt(e)), shouldPlay, pMode);
                };
                e++;
            };
        }

        public static function advanceFrame(mc:MovieClip):void
        {
            if ((!(mc)))
            {
                return;
            };
            if (mc.bypassTicker)
            {
                return;
            };
            if (((mc.currentFrame == mc.totalFrames) && (mc.totalFrames > 1)))
            {
                mc.gotoAndStop(1);
            }
            else
            {
                try
                {
                    mc.nextFrame();
                }
                catch(e)
                {
                    trace("hhe");
                };
                mc.stop();
            };
        }

        public static function getControlsAngle(obj:Object):Number
        {
            if (((((obj.UP) && (!(obj.DOWN))) && (obj.LEFT)) && (!(obj.RIGHT))))
            {
                return (135);
            };
            if (((((obj.UP) && (!(obj.DOWN))) && (!(obj.LEFT))) && (obj.RIGHT)))
            {
                return (45);
            };
            if (((((!(obj.UP)) && (obj.DOWN)) && (obj.LEFT)) && (!(obj.RIGHT))))
            {
                return (225);
            };
            if (((((!(obj.UP)) && (obj.DOWN)) && (!(obj.LEFT))) && (obj.RIGHT)))
            {
                return (315);
            };
            if (((((obj.UP) && (!(obj.DOWN))) && (!(obj.LEFT))) && (!(obj.RIGHT))))
            {
                return (90);
            };
            if (((((!(obj.UP)) && (obj.DOWN)) && (!(obj.LEFT))) && (!(obj.RIGHT))))
            {
                return (270);
            };
            if (((((!(obj.UP)) && (!(obj.DOWN))) && (obj.LEFT)) && (!(obj.RIGHT))))
            {
                return (180);
            };
            if (((((!(obj.UP)) && (!(obj.DOWN))) && (!(obj.LEFT))) && (obj.RIGHT)))
            {
                return (0);
            };
            return (-1);
        }

        public static function forceBase360(angle:Number):Number
        {
            while (angle < 0)
            {
                angle = (angle + 360);
            };
            while (angle >= 360)
            {
                angle = (angle - 360);
            };
            return (angle);
        }

        public static function calculateDifferenceBetweenAngles(firstAngle:Number, secondAngle:Number):Number
        {
            var difference:Number = (secondAngle - firstAngle);
            while (difference < -180)
            {
                difference = (difference + 360);
            };
            while (difference > 180)
            {
                difference = (difference - 360);
            };
            return (difference);
        }

        public static function rotatePointAroundOrigin(point:Point, rotation:Number):Point
        {
            var origin:Point = new Point();
            var angle:Number = 0;
            var distance:Number = 0;
            if (rotation != 0)
            {
                angle = Utils.toRadians(Utils.getAngleBetween(origin, point));
                distance = Point.distance(origin, point);
                point.copyFrom(Point.polar(distance, (angle + Utils.toRadians(rotation))));
                point.y = (point.y * -1);
            };
            return (point);
        }

        public static function rotateRectangleAroundOrigin(rect:Rectangle, rotation:Number):Rectangle
        {
            var origin:Point = new Point();
            var point1:Point;
            var point2:Point;
            var point3:Point;
            var point4:Point;
            var minX:Number = 0;
            var minY:Number = 0;
            var maxX:Number = 0;
            var maxY:Number = 0;
            var angle1:Number = 0;
            var angle2:Number = 0;
            var angle3:Number = 0;
            var angle4:Number = 0;
            var distance1:Number = 0;
            var distance2:Number = 0;
            var distance3:Number = 0;
            var distance4:Number = 0;
            if (rotation != 0)
            {
                point1 = new Point(rect.x, rect.y);
                point2 = new Point((rect.x + rect.width), rect.y);
                point3 = new Point((rect.x + rect.width), (rect.y + rect.height));
                point4 = new Point(rect.x, (rect.y + rect.height));
                angle1 = Utils.toRadians(Utils.getAngleBetween(origin, point1));
                angle2 = Utils.toRadians(Utils.getAngleBetween(origin, point2));
                angle3 = Utils.toRadians(Utils.getAngleBetween(origin, point3));
                angle4 = Utils.toRadians(Utils.getAngleBetween(origin, point4));
                distance1 = Point.distance(origin, point1);
                distance2 = Point.distance(origin, point2);
                distance3 = Point.distance(origin, point3);
                distance4 = Point.distance(origin, point4);
                point1 = Point.polar(distance1, (angle1 + Utils.toRadians(rotation)));
                point2 = Point.polar(distance2, (angle2 + Utils.toRadians(rotation)));
                point3 = Point.polar(distance3, (angle3 + Utils.toRadians(rotation)));
                point4 = Point.polar(distance4, (angle4 + Utils.toRadians(rotation)));
                point1.y = (point1.y * -1);
                point2.y = (point2.y * -1);
                point3.y = (point3.y * -1);
                point4.y = (point4.y * -1);
                minX = Math.min(point1.x, point2.x, point3.x, point4.x);
                minY = Math.min(point1.y, point2.y, point3.y, point4.y);
                maxX = Math.max(point1.x, point2.x, point3.x, point4.x);
                maxY = Math.max(point1.y, point2.y, point3.y, point4.y);
                rect.x = minX;
                rect.y = minY;
                rect.width = (maxX - minX);
                rect.height = (maxY - minY);
            };
            return (rect);
        }

        public static function rotateRectangleAroundOriginPoints(rect:Rectangle, rotation:Number, scale:Point, offset:Point):Vector.<Point>
        {
            var origin:Point = new Point();
            var point1:Point;
            var point2:Point;
            var point3:Point;
            var point4:Point;
            var minX:Number = 0;
            var minY:Number = 0;
            var maxX:Number = 0;
            var maxY:Number = 0;
            var angle1:Number = 0;
            var angle2:Number = 0;
            var angle3:Number = 0;
            var angle4:Number = 0;
            var distance1:Number = 0;
            var distance2:Number = 0;
            var distance3:Number = 0;
            var distance4:Number = 0;
            point1 = new Point(rect.x, rect.y);
            point2 = new Point((rect.x + rect.width), rect.y);
            point3 = new Point((rect.x + rect.width), (rect.y + rect.height));
            point4 = new Point(rect.x, (rect.y + rect.height));
            if (rotation != 0)
            {
                angle1 = Utils.toRadians(Utils.getAngleBetween(origin, point1));
                angle2 = Utils.toRadians(Utils.getAngleBetween(origin, point2));
                angle3 = Utils.toRadians(Utils.getAngleBetween(origin, point3));
                angle4 = Utils.toRadians(Utils.getAngleBetween(origin, point4));
                distance1 = Point.distance(origin, point1);
                distance2 = Point.distance(origin, point2);
                distance3 = Point.distance(origin, point3);
                distance4 = Point.distance(origin, point4);
                point1 = Point.polar(distance1, (angle1 + Utils.toRadians(rotation)));
                point2 = Point.polar(distance2, (angle2 + Utils.toRadians(rotation)));
                point3 = Point.polar(distance3, (angle3 + Utils.toRadians(rotation)));
                point4 = Point.polar(distance4, (angle4 + Utils.toRadians(rotation)));
                point1.y = (point1.y * -1);
                point2.y = (point2.y * -1);
                point3.y = (point3.y * -1);
                point4.y = (point4.y * -1);
            };
            point1.x = (point1.x * scale.x);
            point1.y = (point1.y * scale.y);
            point2.x = (point2.x * scale.x);
            point2.y = (point2.y * scale.y);
            point3.x = (point3.x * scale.x);
            point3.y = (point3.y * scale.y);
            point4.x = (point4.x * scale.x);
            point4.y = (point4.y * scale.y);
            point1.offset(offset.x, offset.y);
            point2.offset(offset.x, offset.y);
            point3.offset(offset.x, offset.y);
            point4.offset(offset.x, offset.y);
            var points:Vector.<Point> = new Vector.<Point>();
            points.push(point1);
            points.push(point2);
            points.push(point3);
            points.push(point4);
            return (points);
        }

        public static function rotateAroundCenter(mc:MovieClip, facingForward:Boolean, angle:Number):void
        {
        }

        public static function testRectangleToPoint(rectWidth:Number, rectHeight:Number, rectRotation:Number, rectCenterX:Number, rectCenterY:Number, pointX:Number, pointY:Number):Boolean
        {
            if (rectRotation == 0)
            {
                return ((Math.abs((rectCenterX - pointX)) < (rectWidth / 2)) && (Math.abs((rectCenterY - pointY)) < (rectHeight / 2)));
            };
            var tx:Number = ((Math.cos(rectRotation) * pointX) - (Math.sin(rectRotation) * pointY));
            var ty:Number = ((Math.cos(rectRotation) * pointY) + (Math.sin(rectRotation) * pointX));
            var cx:Number = ((Math.cos(rectRotation) * rectCenterX) - (Math.sin(rectRotation) * rectCenterY));
            var cy:Number = ((Math.cos(rectRotation) * rectCenterY) + (Math.sin(rectRotation) * rectCenterX));
            return ((Math.abs((cx - tx)) < (rectWidth / 2)) && (Math.abs((cy - ty)) < (rectHeight / 2)));
        }

        public static function testCircleToSegment(circleCenterX:Number, circleCenterY:Number, circleRadius:Number, lineAX:Number, lineAY:Number, lineBX:Number, lineBY:Number):Boolean
        {
            var distance:Number;
            var ix:Number;
            var iy:Number;
            var lineSize:Number = Math.sqrt((Math.pow((lineAX - lineBX), 2) + Math.pow((lineAY - lineBY), 2)));
            if (lineSize == 0)
            {
                distance = Math.sqrt((Math.pow((circleCenterX - lineAX), 2) + Math.pow((circleCenterY - lineAY), 2)));
                return (distance < circleRadius);
            };
            var u:Number = ((((circleCenterX - lineAX) * (lineBX - lineAX)) + ((circleCenterY - lineAY) * (lineBY - lineAY))) / (lineSize * lineSize));
            if (u < 0)
            {
                distance = Math.sqrt((Math.pow((circleCenterX - lineAX), 2) + Math.pow((circleCenterY - lineAY), 2)));
            }
            else
            {
                if (u > 1)
                {
                    distance = Math.sqrt((Math.pow((circleCenterX - lineBX), 2) + Math.pow((circleCenterY - lineBY), 2)));
                }
                else
                {
                    ix = (lineAX + (u * (lineBX - lineAX)));
                    iy = (lineAY + (u * (lineBY - lineAY)));
                    distance = Math.sqrt((Math.pow((circleCenterX - ix), 2) + Math.pow((circleCenterY - iy), 2)));
                };
            };
            return (distance < circleRadius);
        }

        public static function testRectangleToCircle(points:Vector.<Point>, rectWidth:Number, rectHeight:Number, rectCenterX:Number, rectCenterY:Number, circleCenterX:Number, circleCenterY:Number, circleRadius:Number):Boolean
        {
            return (((((Utils.testRectangleToPoint(rectWidth, rectHeight, 0, rectCenterX, rectCenterY, circleCenterX, circleCenterY)) || (Utils.testCircleToSegment(circleCenterX, circleCenterY, circleRadius, points[0].x, points[0].y, points[1].x, points[1].y))) || (Utils.testCircleToSegment(circleCenterX, circleCenterY, circleRadius, points[1].x, points[1].y, points[2].x, points[2].y))) || (Utils.testCircleToSegment(circleCenterX, circleCenterY, circleRadius, points[2].x, points[2].y, points[3].x, points[3].y))) || (Utils.testCircleToSegment(circleCenterX, circleCenterY, circleRadius, points[3].x, points[3].y, points[0].x, points[0].y)));
        }

        public static function getVelocityVector(speed:Number, angle:Number):Point
        {
            var vec:Point = new Point();
            vec.x = (speed * Math.cos(((angle * Math.PI) / 180)));
            vec.y = (speed * Math.sin(((angle * Math.PI) / 180)));
            return (vec);
        }

        public static function getAngleBetween(center:Point, target:Point):Number
        {
            return (Utils.forceBase360(((Math.atan2(-(target.y - center.y), (target.x - center.x)) * 180) / Math.PI)));
        }

        public static function calculateCamShake(atkObj:AttackDamage):Number
        {
            return (Math.floor(((Math.floor((((0.25 * atkObj.Damage) + (0.75 * (0.001 * (Math.abs(atkObj.Power) * ((atkObj.Power > 0) ? atkObj.KBConstant : 1))))) - 5)) + 3) / 2)));
        }

        public static function calculateAttackDirection(attackObj:AttackDamage, receiver:InteractiveSprite):Number
        {
            var flip:Boolean = true;
            var isForward:Boolean = attackObj.IsForward;
            var angle:Number = 0;
            if (attackObj.Direction == -1)
            {
                angle = Math.round((Utils.random() * 360));
            }
            else
            {
                if (attackObj.Direction == -2)
                {
                    angle = (Math.round((Utils.random() * (150 - 60))) + 60);
                }
                else
                {
                    if (attackObj.Direction == -3)
                    {
                        angle = ((attackObj.XLoc < receiver.X) ? 75 : 115);
                        isForward = (attackObj.XLoc < receiver.X);
                        flip = false;
                    }
                    else
                    {
                        if (attackObj.Direction == -4)
                        {
                            angle = ((attackObj.XLoc < receiver.X) ? 20 : 160);
                            isForward = (attackObj.XLoc < receiver.X);
                            flip = false;
                        }
                        else
                        {
                            if (attackObj.Direction == -5)
                            {
                                angle = ((attackObj.XLoc < receiver.X) ? 160 : 20);
                                isForward = (attackObj.XLoc < receiver.X);
                                flip = false;
                            }
                            else
                            {
                                if (attackObj.Direction == -6)
                                {
                                    angle = ((attackObj.YLoc < receiver.Y) ? 115 : 75);
                                    isForward = (attackObj.XLoc < receiver.X);
                                    flip = false;
                                }
                                else
                                {
                                    if (attackObj.Direction == -7)
                                    {
                                        angle = ((attackObj.YLoc < receiver.Y) ? 90 : 270);
                                    }
                                    else
                                    {
                                        if (attackObj.Direction == -8)
                                        {
                                            angle = Utils.getAngleBetween(new Point(receiver.X, receiver.Y), new Point((receiver.X + receiver.netXSpeed()), (receiver.Y + receiver.netYSpeed())));
                                            flip = false;
                                        }
                                        else
                                        {
                                            if (((attackObj.Direction == -9) && (attackObj.Owner)))
                                            {
                                                if ((attackObj.Owner is Projectile))
                                                {
                                                    if (((!(Projectile(attackObj.Owner).XSpeed == 0)) || (!(Projectile(attackObj.Owner).YSpeed == 0))))
                                                    {
                                                        angle = Utils.getAngleBetween(new Point(receiver.X, receiver.Y), new Point((receiver.X + Projectile(attackObj.Owner).XSpeed), (receiver.Y + Projectile(attackObj.Owner).YSpeed)));
                                                    };
                                                }
                                                else
                                                {
                                                    if ((attackObj.Owner is Item))
                                                    {
                                                        if (((!(Item(attackObj.Owner).XSpeed == 0)) || (!(Item(attackObj).YSpeed == 0))))
                                                        {
                                                            angle = Utils.getAngleBetween(new Point(receiver.X, receiver.Y), new Point((receiver.X + Item(attackObj).XSpeed), (receiver.Y + Item(attackObj).YSpeed)));
                                                        };
                                                    }
                                                    else
                                                    {
                                                        if (attackObj.Owner)
                                                        {
                                                            if (((!(attackObj.Owner.netXSpeed() == 0)) || (!(attackObj.Owner.netYSpeed() == 0))))
                                                            {
                                                                angle = Utils.getAngleBetween(new Point(receiver.X, receiver.Y), new Point((receiver.X + receiver.netXSpeed()), (receiver.Y + receiver.netYSpeed())));
                                                            }
                                                            else
                                                            {
                                                                angle = Utils.getAngleBetween(new Point(receiver.X, receiver.Y), new Point((receiver.X + attackObj.Owner.netXSpeed()), (receiver.Y + attackObj.Owner.netYSpeed())));
                                                            };
                                                        };
                                                    };
                                                };
                                                flip = false;
                                            }
                                            else
                                            {
                                                angle = attackObj.Direction;
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
            if (((!(isForward)) && (flip)))
            {
                angle = (180 - angle);
            };
            return (Utils.forceBase360(angle));
        }

        public static function calculateReversedAngle(angle:Number, attackObj:AttackDamage, receiver:InteractiveSprite):Number
        {
            var backwards:Boolean;
            var x_component:Number = 0;
            var y_component:Number = 0;
            if (((attackObj.ReversableAngle) && (attackObj.Direction >= 0)))
            {
                backwards = ((attackObj.Direction > 90) && (attackObj.Direction < 270));
                x_component = Utils.calculateXSpeed(1, angle);
                y_component = -(Utils.calculateYSpeed(1, angle));
                if (((receiver.getX() < attackObj.XLoc) || (receiver.getX() > attackObj.XLoc)))
                {
                    x_component = ((receiver.getX() > attackObj.XLoc) ? Utils.fastAbs(x_component) : -(Utils.fastAbs(x_component)));
                    if (backwards)
                    {
                        x_component = (x_component * -1);
                    };
                    angle = Utils.getAngleBetween(new Point(), new Point(x_component, y_component));
                };
            };
            return (angle);
        }

        public static function calculateChargeDamage(attackObj:AttackDamage, damageOverride:Number=-1):Number
        {
            var tempDamage:Number = ((damageOverride >= 0) ? damageOverride : attackObj.Damage);
            if (attackObj.SizeStatus != 0)
            {
                tempDamage = (tempDamage * ((attackObj.SizeStatus == 1) ? 1.25 : 0.75));
            };
            if (((attackObj.ChargeTimeMax > 0) && (!(attackObj.IgnoreChargeDamage))))
            {
                tempDamage = (tempDamage * ((1 + ((attackObj.ChargeTime / attackObj.ChargeTimeMax) * 0.4)) * attackObj.ChargeDamageMultiplier));
            };
            return (tempDamage);
        }

        public static function calculateHitlag(knockback:Number, hitLagVal:Number):Number
        {
            var tmpLag:Number;
            var hitlagFrames:Number = Math.floor(((knockback * 0.4) * (Main.FRAMERATE / 60)));
            if (hitLagVal < 0)
            {
                if (hitLagVal < 0)
                {
                    hitLagVal = (hitLagVal * -1);
                };
                tmpLag = hitlagFrames;
                return (Math.ceil((tmpLag * hitLagVal)));
            };
            return (Math.round(hitLagVal));
        }

        public static function calculateRebound(damage:Number):int
        {
            return ((6.6 + (Math.floor(damage) * 0.558)) * 2);
        }

        public static function calculateKnockback(kb:Number, power:Number, wdsk:Number, attackdamage:Number, victimdamage:Number, weight1:Number, charging:Boolean, damageRatio:Number, attackRatio:Number):Number
        {
            var VictimKBMultB:Number = 1;
            var knockback:Number = 0;
            if (attackdamage > 999)
            {
                attackdamage = 999;
            };
            if (wdsk != 0)
            {
                if (power <= 0)
                {
                    power = (power * -1);
                };
                knockback = (((((((((wdsk * 10) * 0.05) + 1) * VictimKBMultB) * 1.4) * (200 / (weight1 + 100))) + 18) * (kb * 0.01)) + power);
            }
            else
            {
                knockback = (((((((((victimdamage + attackdamage) * 0.1) + ((attackdamage * (victimdamage + attackdamage)) * 0.05)) * VictimKBMultB) * 1.4) * (200 / (weight1 + 100))) + 18) * (kb * 0.01)) + power);
            };
            if (charging)
            {
                knockback = (knockback * 1.2);
            };
            knockback = (knockback * damageRatio);
            knockback = (knockback * attackRatio);
            return (knockback);
        }

        public static function calculateVelocity(knockback:Number):Number
        {
            var tempVelocity:Number = 0;
            tempVelocity = ((knockback * 0.03) * Utils.VELOCITY_SCALE);
            return (tempVelocity);
        }

        public static function calculateKnockbackFromVelocity(velocity:Number):Number
        {
            return (velocity / (0.03 * Utils.VELOCITY_SCALE));
        }

        public static function calculateHitStun(hitStun:Number, damage:Number, electric:Boolean, c_cancelled:Boolean):Number
        {
            if (hitStun >= 0)
            {
                return (hitStun);
            };
            var electric_val:Number = ((electric) ? 1.5 : 1);
            var c_cancelled_val:Number = ((c_cancelled) ? (2 / 3) : 1);
            return (Math.ceil((((c_cancelled_val * (Math.floor((electric_val * ((damage / 3) + 3))) / 2)) * (-1 * hitStun)) + 0.5)));
        }

        public static function calculateSelfHitStun(selfHitStun:Number, damage:Number):Number
        {
            if (selfHitStun >= 0)
            {
                return (selfHitStun);
            };
            return (Math.floor((-(selfHitStun) * (((damage / 3) + 3) / 2))));
        }

        public static function calculateGrabLength(damage:Number):int
        {
            return ((90 + (damage * 1.7)) / 2);
        }

        public static function calculatePummelTime(grabLength:int):int
        {
            return ((grabLength / 13) * 3);
        }

        public static function getClass(obj:Object):Class
        {
            return (Class(getDefinitionByName(getQualifiedClassName(obj))));
        }

        public static function dijkstra(STAGEDATA:StageData, beacons:Vector.<Beacon>, am:Array, source:Beacon, dest:Beacon):Array
        {
            var i:int;
            var w:int;
            var min_index:int;
            var min_distance:int;
            var lastIndex:int;
            STAGEDATA.markBeaconsUnvisited();
            var total:int = beacons.length;
            var distance:Array = new Array(beacons.length);
            var prevNodes:Array = new Array(beacons.length);
            var visited:Array = new Array(beacons.length);
            i = 0;
            while (i < beacons.length)
            {
                distance[i] = int.MAX_VALUE;
                prevNodes[i] = -1;
                visited[i] = -1;
                i++;
            };
            distance[source.BID] = 0;
            lastIndex = source.BID;
            while (total > 0)
            {
                min_index = -1;
                min_distance = int.MAX_VALUE;
                i = 0;
                while (i < beacons.length)
                {
                    if (((beacons[i].Visited == false) && (distance[i] < min_distance)))
                    {
                        min_distance = distance[i];
                        min_index = i;
                    };
                    i++;
                };
                if (((min_distance == int.MAX_VALUE) || (min_index == -1)))
                {
                    break;
                };
                beacons[min_index].Visited = true;
                total--;
                w = Beacon.nextNeighbor(STAGEDATA.getBeacons(), STAGEDATA.getAdjMatrix(), min_index, -1);
                while (w < beacons.length)
                {
                    if (((beacons[w].Visited == false) && (distance[w] > (min_distance + am[min_index][w]))))
                    {
                        distance[w] = (min_distance + am[min_index][w]);
                        prevNodes[w] = min_index;
                        lastIndex = w;
                    };
                    w = Beacon.nextNeighbor(STAGEDATA.getBeacons(), STAGEDATA.getAdjMatrix(), min_index, w);
                };
            };
            return (prevNodes);
        }

        public static function getPath(beacons:Vector.<Beacon>, arr:Array, src:Number, dst:Number):Vector.<Beacon>
        {
            var path:Vector.<Beacon> = new Vector.<Beacon>();
            path.push(beacons[dst]);
            while (dst != src)
            {
                path.push(beacons[arr[dst]]);
                dst = arr[dst];
            };
            return (path);
        }

        public static function getClosetBeaconTo(STAGEDATA:StageData, mc:MovieClip):Beacon
        {
            var currBeacon:Beacon;
            var tmpBeacon:Beacon;
            var distance:Number = int.MAX_VALUE;
            var tmpDistance:Number = 0;
            var beaconList:Vector.<Beacon> = STAGEDATA.getBeacons();
            var b:int;
            while (b < beaconList.length)
            {
                tmpDistance = Math.sqrt((Math.pow((beaconList[b].X - mc.x), 2) + Math.pow((beaconList[b].Y - mc.y), 2)));
                if (((tmpDistance < distance) && (STAGEDATA.beaconNeighborCount(beaconList[b].BID) > 0)))
                {
                    distance = tmpDistance;
                    currBeacon = beaconList[b];
                };
                b++;
            };
            return (currBeacon);
        }

        public static function get WeightBase():Number
        {
            return (3.78 * 2.6455);
        }

        private static function xor(source:String):String
        {
            var key:String = KEY;
            var result:String = new String();
            var i:Number = 0;
            while (i < source.length)
            {
                if (i > (key.length - 1))
                {
                    key = (key + key);
                };
                result = (result + String.fromCharCode((source.charCodeAt(i) ^ key.charCodeAt(i))));
                i++;
            };
            return (result);
        }

        public static function encrypt(str:String):String
        {
            var txtToEncrypt:String = str;
            return (Base64.encode(Utils.xor(txtToEncrypt)));
        }

        public static function decrypt(str:String):String
        {
            var txtToDecrypt:String = str;
            return (Utils.xor(Base64.decode(txtToDecrypt)));
        }

        public static function openFile(description:String="SSF2 Save File (*.ssfsav)", extension:String="*.ssfsav"):void
        {
            Utils.openSuccess = false;
            Utils.finishedLoading = false;
            Utils.cancelled = false;
            fileRef = new FileReference();
            fileRef.addEventListener(Event.SELECT, Utils.onFileSelected);
            fileRef.addEventListener(Event.CANCEL, Utils.onCancel);
            fileRef.addEventListener(IOErrorEvent.IO_ERROR, Utils.onIOError);
            fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, Utils.onSecurityError);
            fileRef.addEventListener(ProgressEvent.PROGRESS, onProgress);
            fileRef.addEventListener(Event.COMPLETE, onComplete);
            var textTypeFilter:FileFilter = new FileFilter(description, extension);
            fileRef.browse([textTypeFilter]);
        }

        private static function killFileOpenEvents():void
        {
            fileRef.removeEventListener(ProgressEvent.PROGRESS, onProgress);
            fileRef.removeEventListener(Event.COMPLETE, onComplete);
            fileRef.removeEventListener(Event.CANCEL, Utils.onCancel);
            fileRef.removeEventListener(IOErrorEvent.IO_ERROR, Utils.onIOError);
            fileRef.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, Utils.onSecurityError);
        }

        private static function onFileSelected(evt:Event):void
        {
            fileRef.addEventListener(ProgressEvent.PROGRESS, onProgress);
            fileRef.addEventListener(Event.COMPLETE, onComplete);
            fileRef.load();
            fileRef.removeEventListener(Event.SELECT, Utils.onFileSelected);
        }

        private static function onProgress(evt:ProgressEvent):void
        {
            trace((((("Loaded " + evt.bytesLoaded) + " of ") + evt.bytesTotal) + " bytes."));
        }

        private static function onComplete(evt:Event):void
        {
            trace("File was successfully loaded.");
            Utils.finishedLoading = true;
            Utils.openSuccess = true;
            killFileOpenEvents();
        }

        private static function onCancel(evt:Event):void
        {
            trace("The browse request was canceled by the user.");
            Utils.cancelled = true;
            Utils.openSuccess = false;
            Utils.finishedLoading = true;
            killFileOpenEvents();
        }

        private static function onIOError(evt:IOErrorEvent):void
        {
            trace("There was an IO Error.");
            Utils.openSuccess = false;
            Utils.finishedLoading = true;
            killFileOpenEvents();
        }

        private static function onSecurityError(evt:Event):void
        {
            trace("There was a security error.");
            Utils.openSuccess = false;
            Utils.finishedLoading = true;
            killFileOpenEvents();
        }

        public static function saveFile(bArr:ByteArray, defaultName:String):void
        {
            Utils.saveSuccess = false;
            Utils.finishedLoading = false;
            Utils.cancelled = false;
            fileRef = new FileReference();
            fileRef.addEventListener(Event.SELECT, onSaveFileSelected);
            fileRef.addEventListener(IOErrorEvent.IO_ERROR, Utils.onSaveIOError);
            fileRef.addEventListener(SecurityErrorEvent.SECURITY_ERROR, Utils.onSaveSecurityError);
            fileRef.addEventListener(ProgressEvent.PROGRESS, onSaveProgress);
            fileRef.addEventListener(Event.COMPLETE, onSaveComplete);
            fileRef.save(bArr, defaultName);
            fileRef.removeEventListener(Event.SELECT, onSaveFileSelected);
        }

        private static function killSaveEvents():void
        {
            fileRef.removeEventListener(ProgressEvent.PROGRESS, onSaveProgress);
            fileRef.removeEventListener(Event.COMPLETE, onSaveComplete);
            fileRef.removeEventListener(Event.CANCEL, onSaveCancel);
            fileRef.removeEventListener(IOErrorEvent.IO_ERROR, Utils.onSaveIOError);
            fileRef.removeEventListener(SecurityErrorEvent.SECURITY_ERROR, Utils.onSaveSecurityError);
        }

        private static function onSaveFileSelected(evt:Event):void
        {
            fileRef.addEventListener(ProgressEvent.PROGRESS, onSaveProgress);
            fileRef.addEventListener(Event.COMPLETE, onSaveComplete);
            fileRef.addEventListener(Event.CANCEL, onSaveCancel);
        }

        private static function onSaveProgress(evt:ProgressEvent):void
        {
            trace((((("Saved " + evt.bytesLoaded) + " of ") + evt.bytesTotal) + " bytes."));
        }

        private static function onSaveComplete(evt:Event):void
        {
            trace("File saved.");
            Utils.finishedLoading = true;
            Utils.saveSuccess = true;
            killSaveEvents();
        }

        private static function onSaveCancel(evt:Event):void
        {
            trace("The save request was canceled by the user.");
            Utils.cancelled = true;
            Utils.finishedLoading = true;
            Utils.saveSuccess = false;
            killSaveEvents();
        }

        private static function onSaveIOError(evt:IOErrorEvent):void
        {
            trace("There was an IO Error.");
            Utils.finishedLoading = true;
            Utils.saveSuccess = false;
            killSaveEvents();
        }

        private static function onSaveSecurityError(evt:Event):void
        {
            trace("There was a security error.");
            Utils.finishedLoading = true;
            Utils.saveSuccess = false;
            killSaveEvents();
        }

        public static function loadDataFile(fileName:String):void
        {
            var myTextLoader:URLLoader = new URLLoader();
            myTextLoader.dataFormat = URLLoaderDataFormat.BINARY;
            myTextLoader.addEventListener(Event.COMPLETE, onLoaded);
            myTextLoader.load(new URLRequest(fileName));
            Utils.finishedLoading = false;
        }

        private static function onLoaded(e:Event):void
        {
            trace("Loaded");
            Utils.finishedLoading = true;
        }

        public static function flatten(arr:Array):Array
        {
            var result:Array = [];
            var i:int;
            while (i < arr.length)
            {
                if ((arr[i] is Array))
                {
                    result = result.concat(Utils.flatten(arr[i]));
                }
                else
                {
                    result.push(arr[i]);
                };
                i++;
            };
            return (result);
        }

        public static function union(arr:Array):Array
        {
            var i:int;
            var results:Array = arr.slice(0);
            var currentIndex:int;
            while (currentIndex < results.length)
            {
                i = 0;
                while (i < results.length)
                {
                    if (((!(i === currentIndex)) && (results[currentIndex] === arr[i])))
                    {
                        results.splice(i--, 1);
                    };
                    i++;
                };
                currentIndex++;
            };
            return (results);
        }

        public static function cloneObject(obj:Object):Object
        {
            return (JSON.parse(JSON.stringify(obj)));
        }

        public static function bulkRemoveMC(mc:Array):void
        {
            var i:int;
            while (i < mc.length)
            {
                if ((((mc[i]) && (mc[i] is MovieClip)) && (MovieClip(mc[i]).parent)))
                {
                    MovieClip(mc[i]).parent.removeChild(mc[i]);
                };
                i++;
            };
        }

        private static function getKeysArray(abbreviate:Boolean):Object
        {
            var keyArr:Object = {};
            if (abbreviate)
            {
                keyArr[0] = "n/a";
                keyArr[65] = "A";
                keyArr[66] = "B";
                keyArr[67] = "C";
                keyArr[68] = "D";
                keyArr[69] = "E";
                keyArr[70] = "F";
                keyArr[71] = "G";
                keyArr[72] = "H";
                keyArr[73] = "I";
                keyArr[74] = "J";
                keyArr[75] = "K";
                keyArr[76] = "L";
                keyArr[77] = "M";
                keyArr[78] = "N";
                keyArr[79] = "O";
                keyArr[80] = "P";
                keyArr[81] = "Q";
                keyArr[82] = "R";
                keyArr[83] = "S";
                keyArr[84] = "T";
                keyArr[85] = "U";
                keyArr[86] = "V";
                keyArr[87] = "W";
                keyArr[88] = "X";
                keyArr[89] = "Y";
                keyArr[90] = "Z";
                keyArr[48] = "0";
                keyArr[49] = "1";
                keyArr[50] = "2";
                keyArr[51] = "3";
                keyArr[52] = "4";
                keyArr[53] = "5";
                keyArr[54] = "6";
                keyArr[55] = "7";
                keyArr[56] = "8";
                keyArr[57] = "9";
                keyArr[96] = "Nm0";
                keyArr[97] = "Nm1";
                keyArr[98] = "Nm2";
                keyArr[99] = "Nm3";
                keyArr[100] = "Nm4";
                keyArr[101] = "Nm5";
                keyArr[102] = "Nm6";
                keyArr[103] = "Nm7";
                keyArr[104] = "Nm8";
                keyArr[105] = "Nm9";
                keyArr[106] = "*";
                keyArr[107] = "+";
                keyArr[13] = "Ent";
                keyArr[109] = "-";
                keyArr[110] = ".";
                keyArr[111] = "/";
                keyArr[112] = "F1";
                keyArr[113] = "F2";
                keyArr[114] = "F3";
                keyArr[115] = "F4";
                keyArr[116] = "F5";
                keyArr[117] = "F6";
                keyArr[118] = "F7";
                keyArr[119] = "F8";
                keyArr[120] = "F9";
                keyArr[122] = "F11";
                keyArr[123] = "F12";
                keyArr[124] = "F13";
                keyArr[125] = "F14";
                keyArr[126] = "F15";
                keyArr[8] = "Back";
                keyArr[9] = "Tab";
                keyArr[12] = "Clr";
                keyArr[16] = "Shft";
                keyArr[20] = "Caps";
                keyArr[27] = "Esc";
                keyArr[32] = "Spc";
                keyArr[33] = "PUp";
                keyArr[34] = "PDw";
                keyArr[35] = "End";
                keyArr[36] = "Hme";
                keyArr[37] = "Larr";
                keyArr[38] = "Uarr";
                keyArr[39] = "RArr";
                keyArr[40] = "DArr";
                keyArr[45] = "Ins";
                keyArr[46] = "Del";
                keyArr[47] = "Help";
                keyArr[144] = "NLck";
                keyArr[186] = ";:";
                keyArr[187] = "=+";
                keyArr[188] = ",";
                keyArr[189] = "-_";
                keyArr[190] = ".";
                keyArr[191] = "/?";
                keyArr[192] = "`~";
                keyArr[219] = "[{";
                keyArr[220] = "|";
                keyArr[221] = "]}";
                keyArr[222] = "\"'";
            }
            else
            {
                keyArr[0] = "None";
                keyArr[65] = "A";
                keyArr[66] = "B";
                keyArr[67] = "C";
                keyArr[68] = "D";
                keyArr[69] = "E";
                keyArr[70] = "F";
                keyArr[71] = "G";
                keyArr[72] = "H";
                keyArr[73] = "I";
                keyArr[74] = "J";
                keyArr[75] = "K";
                keyArr[76] = "L";
                keyArr[77] = "M";
                keyArr[78] = "N";
                keyArr[79] = "O";
                keyArr[80] = "P";
                keyArr[81] = "Q";
                keyArr[82] = "R";
                keyArr[83] = "S";
                keyArr[84] = "T";
                keyArr[85] = "U";
                keyArr[86] = "V";
                keyArr[87] = "W";
                keyArr[88] = "X";
                keyArr[89] = "Y";
                keyArr[90] = "Z";
                keyArr[48] = "0";
                keyArr[49] = "1";
                keyArr[50] = "2";
                keyArr[51] = "3";
                keyArr[52] = "4";
                keyArr[53] = "5";
                keyArr[54] = "6";
                keyArr[55] = "7";
                keyArr[56] = "8";
                keyArr[57] = "9";
                keyArr[96] = "Numpad 0";
                keyArr[97] = "Numpad 1";
                keyArr[98] = "Numpad 2";
                keyArr[99] = "Numpad 3";
                keyArr[100] = "Numpad 4";
                keyArr[101] = "Numpad 5";
                keyArr[102] = "Numpad 6";
                keyArr[103] = "Numpad 7";
                keyArr[104] = "Numpad 8";
                keyArr[105] = "Numpad 9";
                keyArr[106] = "*";
                keyArr[107] = "+";
                keyArr[13] = "Enter";
                keyArr[109] = "-";
                keyArr[110] = ".";
                keyArr[111] = "/";
                keyArr[112] = "F1";
                keyArr[113] = "F2";
                keyArr[114] = "F3";
                keyArr[115] = "F4";
                keyArr[116] = "F5";
                keyArr[117] = "F6";
                keyArr[118] = "F7";
                keyArr[119] = "F8";
                keyArr[120] = "F9";
                keyArr[122] = "F11";
                keyArr[123] = "F12";
                keyArr[124] = "F13";
                keyArr[125] = "F14";
                keyArr[126] = "F15";
                keyArr[8] = "Backspace";
                keyArr[9] = "Tab";
                keyArr[12] = "Clear";
                keyArr[16] = "Shift";
                keyArr[20] = "Caps Lock";
                keyArr[27] = "Esc";
                keyArr[32] = "Space";
                keyArr[33] = "Page Up";
                keyArr[34] = "Page Down";
                keyArr[35] = "End";
                keyArr[36] = "Home";
                keyArr[37] = "Left Arrow";
                keyArr[38] = "Up Arrow";
                keyArr[39] = "Right Arrow";
                keyArr[40] = "Down Arrow";
                keyArr[45] = "Insert";
                keyArr[46] = "Delete";
                keyArr[47] = "Help";
                keyArr[144] = "Num Lock";
                keyArr[186] = ";:";
                keyArr[187] = "=+";
                keyArr[188] = ",";
                keyArr[189] = "-_";
                keyArr[190] = ".";
                keyArr[191] = "/?";
                keyArr[192] = "`~";
                keyArr[219] = "[{";
                keyArr[220] = "|";
                keyArr[221] = "]}";
                keyArr[222] = "\"'";
            };
            return (keyArr);
        }

        public static function copyObject(obj:Object):Object
        {
            return (JSON.parse(JSON.stringify(obj)));
        }

        public static function d(s:String, k:String=""):String
        {
            var _local_5:String;
            var kc:String;
            var o:int;
            var o2:int;
            var s2:int;
            var r:String = "";
            s = Base64.decode(s);
            var i:int;
            while (i < s.length)
            {
                _local_5 = s.substr(i, 1);
                kc = k.substr(((i % k.length) - 1), 1);
                o = _local_5.charCodeAt(0);
                o2 = kc.charCodeAt(0);
                s2 = (o - o2);
                _local_5 = String.fromCharCode(s2);
                r = (r + _local_5);
                i++;
            };
            return (r);
        }


    }
}//package com.mcleodgaming.ssf2.util

