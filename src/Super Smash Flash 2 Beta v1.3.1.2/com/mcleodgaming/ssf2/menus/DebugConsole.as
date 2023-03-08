// Decompiled by AS3 Sorcerer 6.20
// www.as3sorcerer.com

//com.mcleodgaming.ssf2.menus.DebugConsole

package com.mcleodgaming.ssf2.menus
{
    import com.mcleodgaming.ssf2.interfaces.IDebugConsole;
    import flash.text.TextField;
    import com.mcleodgaming.ssf2.util.ResourceManager;
    import com.mcleodgaming.ssf2.Main;
    import flash.events.KeyboardEvent;
    import flash.events.Event;
    import com.mcleodgaming.ssf2.util.Key;
    import com.adobe.utils.StringUtil;
    import com.mcleodgaming.ssf2.controllers.GameController;
    import com.mcleodgaming.ssf2.engine.ItemData;
    import com.mcleodgaming.ssf2.items.Item;
    import com.mcleodgaming.ssf2.items.ItemsListData;
    import com.mcleodgaming.ssf2.Version;
    import com.mcleodgaming.ssf2.net.MultiplayerManager;
    import com.mcleodgaming.ssf2.engine.HitBoxManager;
    import flash.system.System;
    import flash.utils.ByteArray;
    import flash.utils.Timer;
    import com.mcleodgaming.ssf2.engine.Character;
    import com.mcleodgaming.ssf2.enums.SpecialMode;
    import com.mcleodgaming.ssf2.util.Utils;
    import com.mcleodgaming.ssf2.engine.ReplayData;
    import flash.events.TimerEvent;
    import com.mcleodgaming.ssf2.enums.Mode;
    import com.mcleodgaming.ssf2.controllers.Game;
    import com.mcleodgaming.ssf2.controllers.MenuController;
    import com.mcleodgaming.ssf2.util.SaveData;
    import com.mcleodgaming.ssf2.controllers.UnlockController;
    import com.mcleodgaming.ssf2.controllers.Unlockable;
    import com.mcleodgaming.ssf2.util.Resource;
    import com.mcleodgaming.ssf2.util.*;
    import com.mcleodgaming.ssf2.engine.*;
    import com.mcleodgaming.ssf2.items.*;

    public class DebugConsole extends Menu implements IDebugConsole 
    {

        public static var globalHash:Object = {};

        private var MAX_HISTORY:int = 75;
        private var m_enabled:Boolean;
        private var m_input:TextField;
        private var m_output:TextField;
        private var m_history:Array;
        private var m_historyIndex:int;
        private var m_commands:Array;
        private var m_function:Function;
        private var m_enterReleased:Boolean;
        private var m_upReleased:Boolean;
        private var m_downReleased:Boolean;
        private var m_controlsCapture:Boolean;
        private var m_onlineCapture:Boolean;
        private var m_pingCapture:Boolean;
        private var m_attackStateCapture:Boolean;
        private var m_disableKeyCapture:Boolean;
        private var m_knockbackCapture:Boolean;
        private var m_alerts:Boolean;

        public function DebugConsole()
        {
            m_subMenu = ResourceManager.getLibraryMC("debug_console");
            this.m_input = m_subMenu.input;
            this.m_output = m_subMenu.output;
            this.m_output.text = "";
            this.m_historyIndex = 0;
            this.m_history = new Array("");
            this.m_commands = new Array();
            this.m_commands["tas"] = this.tas;
            this.m_commands["help"] = this.help;
            this.m_commands["clear"] = this.clear;
            this.m_commands["exit"] = this.exit;
            this.m_commands["close"] = this.exit;
            this.m_commands["alpha"] = this.alpha;
            this.m_commands["unfocus"] = this.unfocus;
            this.m_commands["capture"] = this.capture;
            this.m_commands["print"] = this.print;
            this.m_commands["generate"] = this.generate;
            this.m_commands["debug"] = this.debug;
            this.m_commands["config"] = this.config;
            this.m_commands["hud"] = this.hud;
					  this.m_commands["hack"] = this.hack;
            m_container.addChild(m_subMenu);
            m_subMenu.x = (Main.Width / 2);
            m_subMenu.y = Main.Height;
            this.m_enabled = false;
            this.m_enterReleased = true;
            this.m_upReleased = true;
            this.m_downReleased = true;
            this.m_alerts = false;
            this.m_controlsCapture = false;
            this.m_onlineCapture = false;
            this.m_disableKeyCapture = true;
            this.m_attackStateCapture = false;
            this.m_knockbackCapture = false;
            if (Main.DEBUG)
            {
                Main.Root.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.toggleDebugConsole);
            };
        }

        public function get ControlsCapture():Boolean
        {
            return (this.m_controlsCapture);
        }

        public function get DisableKeyCapture():Boolean
        {
            return (this.m_disableKeyCapture);
        }

        public function get OnlineCapture():Boolean
        {
            return (this.m_onlineCapture);
        }

        public function get PingCapture():Boolean
        {
            return (this.m_pingCapture);
        }

        public function get AttackStateCapture():Boolean
        {
            return (this.m_attackStateCapture);
        }

        public function get KnockbackCapture():Boolean
        {
            return (this.m_knockbackCapture);
        }

        public function get Alerts():Boolean
        {
            return (this.m_alerts);
        }

        public function set Alerts(value:Boolean):void
        {
            this.m_alerts = value;
        }

        override public function makeEvents():void
        {
            super.makeEvents();
            Main.Root.addEventListener(Event.ADDED, moveToFront);
            Main.Root.stage.addEventListener(KeyboardEvent.KEY_DOWN, this.submitCommand);
            Main.Root.stage.addEventListener(KeyboardEvent.KEY_UP, this.resetKeys);
        }

        override public function show():void
        {
            Main.setFocus(this.m_input);
            super.show();
            if (m_container.parent)
            {
                m_container.parent.setChildIndex(m_container, (m_container.parent.numChildren - 1));
            };
            if (this.m_disableKeyCapture)
            {
                Key.endCapture();
            };
            this.m_historyIndex = 0;
            this.clearInput();
        }

        override public function killEvents():void
        {
            super.killEvents();
            Main.Root.removeEventListener(Event.ADDED, moveToFront);
            Main.Root.stage.removeEventListener(KeyboardEvent.KEY_DOWN, this.submitCommand);
            Main.Root.stage.removeEventListener(KeyboardEvent.KEY_UP, this.resetKeys);
        }

        override public function removeSelf():void
        {
            super.removeSelf();
            this.m_enterReleased = true;
            this.m_upReleased = true;
            this.m_downReleased = true;
            m_subMenu.alpha = 1;
            Main.fixFocus();
            if (this.m_disableKeyCapture)
            {
                Key.beginCapture(Main.Root.stage);
            };
        }

        public function forceShow():void
        {
            if ((!(this.m_enabled)))
            {
                this.show();
                this.m_enabled = true;
            };
        }

        private function toggleDebugConsole(e:KeyboardEvent):void
        {
            if ((!(Main.DEBUGAUTHED)))
            {
                return;
            };
            if (e.keyCode == 192)
            {
                if (this.m_enabled)
                {
                    this.removeSelf();
                    this.m_enabled = (!(this.m_enabled));
                }
                else
                {
                    if (Main.DEBUG)
                    {
                        this.show();
                        this.m_enabled = (!(this.m_enabled));
                    };
                };
            };
        }

        private function resetKeys(param1:KeyboardEvent):void
        {
            if (((param1.keyCode == 13) && (!(this.m_enterReleased))))
            {
                this.m_enterReleased = true;
            };
            if (((param1.keyCode == 38) && (!(this.m_upReleased))))
            {
                this.m_upReleased = true;
            };
            if (((param1.keyCode == 40) && (!(this.m_downReleased))))
            {
                this.m_downReleased = true;
            };
        }

        private function submitCommand(e:KeyboardEvent):void
        {
            var input:String;
            var argArray:Array;
            var funcName:String;
            if (((e.keyCode == 13) && (this.m_enterReleased)))
            {
                this.m_enterReleased = false;
                input = this.cleanString(this.m_input.text);
                if (input == "")
                {
                    this.writeLine("-No command entered");
                }
                else
                {
                    this.m_history[0] = input;
                    this.m_history.unshift("");
                    if (this.m_history.length > this.MAX_HISTORY)
                    {
                        this.m_history.pop();
                    };
                    argArray = input.split(" ");
                    funcName = argArray[0];
                    argArray.splice(0, 1);
                    if (this.m_commands[funcName] != null)
                    {
                        this.m_commands[funcName].apply(null, argArray);
                    }
                    else
                    {
                        this.writeLine((("Command '" + funcName) + "' not found"));
                    };
                };
                this.clearInput();
                this.m_historyIndex = 0;
            }
            else
            {
                if (((e.keyCode == 38) && (this.m_upReleased)))
                {
                    if (((this.m_history.length > 0) && (this.m_historyIndex < (this.m_history.length - 1))))
                    {
                        this.m_historyIndex++;
                        this.m_input.text = this.m_history[this.m_historyIndex];
                        this.cursorToEnd();
                    };
                }
                else
                {
                    if (((e.keyCode == 40) && (this.m_downReleased)))
                    {
                        if (((this.m_history.length > 0) && (this.m_historyIndex > 0)))
                        {
                            this.m_historyIndex--;
                            this.m_input.text = this.m_history[this.m_historyIndex];
                            this.cursorToEnd();
                        };
                    };
                };
            };
        }

        private function writeLine(param1:String):void
        {
            this.m_output.appendText((param1 + "\n"));
            this.m_output.scrollV = this.m_output.numLines;
        }

        private function cleanString(str:String):String
        {
            while (str.indexOf("  ") >= 0)
            {
                str = str.replace("  ", " ");
            };
            while (str.indexOf("\n") >= 0)
            {
                str = str.replace("\n", "");
            };
            while (str.indexOf("\r") >= 0)
            {
                str = str.replace("\r", "");
            };
            return (StringUtil.trim(str));
        }

        private function cursorToEnd():void
        {
            this.m_input.setSelection(this.m_input.text.length, this.m_input.text.length);
        }

        private function clearInput():void
        {
            this.m_input.text = "";
        }

        private function help(... args):void
        {
            this.writeLine("[Commands]");
            this.writeLine("clear");
            this.writeLine("close");
            this.writeLine("exit");
            this.writeLine("print");
            this.writeLine("tas");
            this.writeLine("alpha: Adjust transparency of this window. (0-1.0)");
            this.writeLine("capture: Gather various data about the game.");
            this.writeLine("config: Allows you to change some settings.");
            this.writeLine("debug: Toggle the ConstantDebuggerMenu.");
            this.writeLine("generate assist");
            this.writeLine("generate pokemon");
            this.writeLine("unfocus: Why would you use this?");
            this.writeLine("hud: Toggle the HUD!");
            this.writeLine("This window is small, huh? Scroll up to see more.");
        }

        private function exit(... args):void
        {
            this.removeSelf();
            this.m_enabled = false;
        }

        private function clear(... args):void
        {
            this.m_output.text = "";
        }

        private function alpha(... args):void
        {
            var alpha:Number;
            var flags:Array = new Array();
            while (((args.length > 0) && (args[0].charAt(0) == "-")))
            {
                flags.push(args[0]);
                args.splice(0, 1);
            };
            var error:String = "Use a number between 0 and 1.0.";
            if (args.length == 0)
            {
                this.writeLine(error);
            }
            else
            {
                if (isNaN(parseFloat(args[0])))
                {
                    this.writeLine(error);
                }
                else
                {
                    alpha = parseFloat(args[0]);
                    alpha = Math.min(alpha, 1);
                    alpha = Math.max(alpha, 0);
                    this.writeLine(("alpha set to " + alpha));
                    m_subMenu.alpha = alpha;
                };
            };
        }

        private function unfocus(... args):void
        {
            Main.fixFocus();
        }

        private function capture(... args):void
        {
            var flags:Array = new Array();
            while (((args.length > 0) && (args[0].charAt(0) == "-")))
            {
                flags.push(args[0]);
                args.splice(0, 1);
            };
            var error:String = "Error, capture expects args [controls | keyboard | online | attack | ping]";
            if (args.length == 0)
            {
                this.writeLine(error);
            }
            else
            {
                if (args[0] == "controls")
                {
                    if (this.m_controlsCapture)
                    {
                        this.m_controlsCapture = false;
                        this.writeLine("controls capture stopped");
                    }
                    else
                    {
                        if (((GameController.stageData) && (GameController.stageData.getPlayerByID(1))))
                        {
                            GameController.stageData.getPlayerByID(1).clearAttackControlsArr();
                        };
                        this.m_controlsCapture = true;
                        this.writeLine("controls capture started for player 1");
                    };
                }
                else
                {
                    if (args[0] == "online")
                    {
                        if (this.m_onlineCapture)
                        {
                            this.m_onlineCapture = false;
                            this.writeLine("online capture stopped");
                        }
                        else
                        {
                            this.m_onlineCapture = true;
                            this.writeLine("online capture started");
                        };
                    }
                    else
                    {
                        if (args[0] == "ping")
                        {
                            if (this.m_pingCapture)
                            {
                                this.m_pingCapture = false;
                                this.writeLine("ping capture stopped");
                            }
                            else
                            {
                                this.m_pingCapture = true;
                                this.writeLine("ping capture started");
                            };
                        }
                        else
                        {
                            if (args[0] == "keyboard")
                            {
                                this.m_disableKeyCapture = Key.CaptureStarted;
                                if (this.m_disableKeyCapture)
                                {
                                    this.writeLine("key capture blocked.");
                                    Key.endCapture();
                                }
                                else
                                {
                                    this.writeLine("key capture unblocked.");
                                    Key.beginCapture(Main.Root.stage);
                                };
                            }
                            else
                            {
                                if (args[0] == "attack")
                                {
                                    this.m_attackStateCapture = (!(this.m_attackStateCapture));
                                    if (this.m_attackStateCapture)
                                    {
                                        this.writeLine("attack capture started");
                                    }
                                    else
                                    {
                                        this.writeLine("attack capture ended");
                                    };
                                }
                                else
                                {
                                    if (args[0] == "knockback")
                                    {
                                        this.m_knockbackCapture = (!(this.m_knockbackCapture));
                                        if (this.m_knockbackCapture)
                                        {
                                            this.writeLine("knockback capture started");
                                        }
                                        else
                                        {
                                            this.writeLine("knockback capture ended");
                                        };
                                    }
                                    else
                                    {
                                        this.writeLine(error);
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }

        private function generate(... args):void
        {
            var itemData:ItemData;
            var index:int;
            var item:Item;
            var flags:Array = new Array();
            while (((args.length > 0) && (args[0].charAt(0) == "-")))
            {
                flags.push(args[0]);
                args.splice(0, 1);
            };
            var error:String = "Error, generate expects args [assist | item | pokemon]";
            if (args.length == 0)
            {
                this.writeLine(error);
            }
            else
            {
                if (((!(GameController.stageData)) || (GameController.stageData.GameEnded)))
                {
                    this.writeLine("Error, no game detected for generate command");
                }
                else
                {
                    if (args[0] == "assist")
                    {
                        if (((args.length <= 1) || (isNaN(parseInt(args[1])))))
                        {
                            this.writeLine("Error parsing assist ID ##");
                        }
                        else
                        {
                            args[1] = Math.max(0, parseInt(args[1]));
                            item = GameController.stageData.ItemsRef.generateItemObj(GameController.stageData.ItemsRef.getItemByLinkage("assistTrophy"));
                            if (item)
                            {
                                if (flags.indexOf("-rare") >= 0)
                                {
                                    GameController.stageData.ItemsRef.AssistClass = GameController.stageData.AssistsRare[Math.min((GameController.stageData.AssistsRare.length - 1), args[1])];
                                }
                                else
                                {
                                    GameController.stageData.ItemsRef.AssistClass = GameController.stageData.Assists[Math.min((GameController.stageData.Assists.length - 1), args[1])];
                                };
                                item.X = (GameController.stageData.getPlayerByID(1).X + ((GameController.stageData.getPlayerByID(1).FacingForward) ? 8 : -8));
                                item.Y = (GameController.stageData.getPlayerByID(1).Y - GameController.stageData.getPlayerByID(1).Height);
                                this.writeLine((((((("Generated assist ID#" + args[1]) + " @ (x:") + item.X) + ", y:") + item.Y) + ")"));
                            }
                            else
                            {
                                this.writeLine(("Error, failed to assist ID#" + args[1]));
                            };
                        };
                    }
                    else
                    {
                        if (args[0] == "item")
                        {
                            if (((args.length <= 1) || (isNaN(parseInt(args[1])))))
                            {
                                this.writeLine("Error parsing item ID ##");
                            }
                            else
                            {
                                args[1] = Math.max(0, parseInt(args[1]));
                                itemData = new ItemData();
                                itemData.importData(ItemsListData.DATA[Math.min((ItemsListData.DATA.length - 1), args[1])]);
                                item = GameController.stageData.ItemsRef.generateItemObj(itemData);
                                if (item)
                                {
                                    if (GameController.stageData.getPlayerByID(1))
                                    {
                                        item.X = (GameController.stageData.getPlayerByID(1).X + ((GameController.stageData.getPlayerByID(1).FacingForward) ? 8 : -8));
                                        item.Y = (GameController.stageData.getPlayerByID(1).Y - GameController.stageData.getPlayerByID(1).Height);
                                    };
                                    this.writeLine((((((("Generated item ID#" + args[1]) + " @ (x:") + item.X) + ", y:") + item.Y) + ")"));
                                }
                                else
                                {
                                    this.writeLine(("Error, failed to item ID#" + args[1]));
                                };
                            };
                        }
                        else
                        {
                            if (args[0] == "pokemon")
                            {
                                if (((args.length <= 1) || (isNaN(parseInt(args[1])))))
                                {
                                    this.writeLine("Error parsing pokemon ID ##");
                                }
                                else
                                {
                                    args[1] = Math.max(0, parseInt(args[1]));
                                    item = GameController.stageData.ItemsRef.generateItemObj(GameController.stageData.ItemsRef.getItemByLinkage("pokeball"));
                                    if (item)
                                    {
                                        if (flags.indexOf("-rare") >= 0)
                                        {
                                            GameController.stageData.ItemsRef.PokemonClass = GameController.stageData.PokemonsRare[Math.min((GameController.stageData.PokemonsRare.length - 1), args[1])];
                                        }
                                        else
                                        {
                                            GameController.stageData.ItemsRef.PokemonClass = GameController.stageData.Pokemons[Math.min((GameController.stageData.Pokemons.length - 1), args[1])];
                                        };
                                        item.X = (GameController.stageData.getPlayerByID(1).X + ((GameController.stageData.getPlayerByID(1).FacingForward) ? 8 : -8));
                                        item.Y = (GameController.stageData.getPlayerByID(1).Y - GameController.stageData.getPlayerByID(1).Height);
                                        this.writeLine((((((("Generated pokemon ID#" + args[1]) + " @ (x:") + item.X) + ", y:") + item.Y) + ")"));
                                    }
                                    else
                                    {
                                        this.writeLine(("Error, failed to pokemon ID#" + args[1]));
                                    };
                                };
                            }
                            else
                            {
                                this.writeLine(error);
                            };
                        };
                    };
                };
            };
        }

        private function print(... args):void
        {
            var itemIndex:int;
            var itemName:String;
            var flags:Array = new Array();
            while (((args.length > 0) && (args[0].charAt(0) == "-")))
            {
                flags.push(args[0]);
                args.splice(0, 1);
            };
            var error:String = "Error, print expects flags [-assist | -item | -online | -pokemon | -version | -ping | -dat]";
            if (flags.length == 0)
            {
                this.writeLine(error);
            }
            else
            {
                if (flags[0] == "-assist")
                {
                    this.writeLine("[Common Assists]");
                    this.writeLine("0 - BandanaDee");
                    this.writeLine("1 - Amigo");
                    this.writeLine("2 - Starfy");
                    this.writeLine("3 - Protoman");
                    this.writeLine("4 - Metroid");
                    this.writeLine("5 - PacMan");
                    this.writeLine("6 - RenjiAssist");
                    this.writeLine("7 - Krillin");
                    this.writeLine("8 - Lakitu");
                    this.writeLine("9 - Silver");
                    this.writeLine("[Rare Assists]");
                    this.writeLine("0 - YagamiLight");
                };
                if (flags[0] == "-item")
                {
                    this.writeLine("[Items]");
                    itemIndex = 0;
                    while (itemIndex < ItemsListData.DATA.length)
                    {
                        itemName = ItemsListData.DATA[itemIndex].displayName;
                        this.writeLine(((itemIndex + " - ") + itemName));
                        itemIndex++;
                    };
                };
                if (flags.indexOf("-online") >= 0)
                {
                    if (((GameController.stageData) && (GameController.stageData.OnlineMode)))
                    {
                        this.writeLine("[BEGIN ONLINE LOG]");
                        this.writeLine(GameController.stageData.LogText);
                        this.writeLine("[END ONLINE LOG]");
                    }
                    else
                    {
                        this.writeLine("Error, online mode not detected");
                    };
                };
                if (flags.indexOf("-pokemon") >= 0)
                {
                    this.writeLine("[Common Pokemon]");
                    this.writeLine("0 - Gligar");
                    this.writeLine("1 - Hitmonlee");
                    this.writeLine("2 - Chikorita");
                    this.writeLine("3 - Koffing");
                    this.writeLine("4 - Charizard");
                    this.writeLine("5 - Delibird");
                    this.writeLine("6 - Magikarp");
                    this.writeLine("7 - Electrode");
                    this.writeLine("8 - Shroomish");
                    this.writeLine("9 - Snorlax");
                    this.writeLine("10 - Chatot");
                    this.writeLine("[Rare Pokemon]");
                    this.writeLine("0 - Missingno");
                    this.writeLine("1 - Victini");
                };
                if (flags.indexOf("-version") >= 0)
                {
                    this.writeLine(((((((("SSF2 Version: " + Version.Major) + ".") + Version.Minor) + ".") + Version.Build) + ".") + Version.Revision));
                    this.writeLine(("ActionScript Version: " + Main.Root.loaderInfo.actionScriptVersion));
                    this.writeLine(("SWF Version: " + Main.Root.loaderInfo.swfVersion));
                };
                if (flags.indexOf("-ping") >= 0)
                {
                    this.writeLine((("Current Average Ping: " + MultiplayerManager.Ping) + " ms"));
                };
                if (flags.indexOf("-dat") >= 0)
                {
                    this.writeDatScript();
                };
            };
        }

        private function debug(... args):void
        {
            var flags:Array = new Array();
            while (((args.length > 0) && (args[0].charAt(0) == "-")))
            {
                flags.push(args[0]);
                args.splice(0, 1);
            };
            var error:String = "You need to type debug off.";
            if (args.length == 0)
            {
                this.writeLine(error);
            }
            else
            {
                if (args[0] == "off")
                {
                    this.writeLine("Debug mode has been disabled.");
                    Main.turnOffDebug();
                }
                else
                {
                    this.writeLine(error);
                };
            };
        }

        private function config(... args):void
        {
            var flags:Array = new Array();
            while (((args.length > 0) && (args[0].charAt(0) == "-")))
            {
                flags.push(args[0]);
                args.splice(0, 1);
            };
            var error:String = "Error, config expects args [alerts | fps | meleeAirDodge | global | flushcache]";
            if (args.length == 0)
            {
                this.writeLine(error);
            }
            else
            {
                if (args[0] == "meleeAirDodge")
                {
                    if (args.length <= 1)
                    {
                        this.writeLine("Error parsing config meleeAirDodge value (Expects [true | false])");
                    }
                    else
                    {
                        if ((!(GameController.stageData)))
                        {
                            this.writeLine("Error, match must be initialized to change config meleeAirDodge value");
                        }
                        else
                        {
                            if (args[1] == "true")
                            {
                                GameController.stageData.MeleeAirDodge = true;
                                this.writeLine("Melee air dodging has been enabled");
                            }
                            else
                            {
                                if (args[1] == "false")
                                {
                                    GameController.stageData.MeleeAirDodge = false;
                                    this.writeLine("Melee air dodging has been disabled");
                                }
                                else
                                {
                                    this.writeLine("Error, invalid config meleeAirDodge value provided (Expects [true | false])");
                                };
                            };
                        };
                    };
                }
                else
                {
                    if (args[0] == "fps")
                    {
                        if (args.length <= 1)
                        {
                            this.writeLine("Error parsing config fps value (Expects [1-120])");
                        }
                        else
                        {
                            if (((args.length <= 1) || (isNaN(parseInt(args[1])))))
                            {
                                this.writeLine("Error, invalid config fps value provided (Expects [1-120])");
                            }
                            else
                            {
                                args[1] = Math.max(0, parseInt(args[1]));
                                if (((args[1] < 1) || (args[1] > 120)))
                                {
                                    this.writeLine("Error, invalid config fps value provided (Expects [1-120])");
                                }
                                else
                                {
                                    this.writeLine(("Game FPS has been set to " + args[1]));
                                    Main.Root.stage.frameRate = args[1];
                                };
                            };
                        };
                    }
                    else
                    {
                        if (args[0] == "alerts")
                        {
                            if (args.length <= 1)
                            {
                                this.writeLine("Error parsing config alerts value (Expects [true | false])");
                            }
                            else
                            {
                                if (args[1] == "true")
                                {
                                    this.m_alerts = true;
                                    this.writeLine("Alerts have been enabled");
                                }
                                else
                                {
                                    if (args[1] == "false")
                                    {
                                        this.m_alerts = false;
                                        this.writeLine("Alerts have been disabled");
                                    }
                                    else
                                    {
                                        this.writeLine("Error, invalid config alerts value provided (Expects [true | false])");
                                    };
                                };
                            };
                        }
                        else
                        {
                            if (args[0] == "global")
                            {
                                if (args.length <= 1)
                                {
                                    this.writeLine("Error parsing config global var name (Expects {varname}))");
                                }
                                else
                                {
                                    if (args.length <= 2)
                                    {
                                        this.writeLine(((("Retrieved config global var: " + args[1]) + " = ") + DebugConsole.globalHash[args[1]]));
                                    }
                                    else
                                    {
                                        if (((args[2] === "true") || (args[2] === "false")))
                                        {
                                            DebugConsole.globalHash[args[1]] = (args[2] === "true");
                                        }
                                        else
                                        {
                                            if ((!(isNaN(parseFloat(args[2])))))
                                            {
                                                DebugConsole.globalHash[args[1]] = ((parseFloat(args[2]) === parseInt(args[2])) ? parseFloat(args[2]) : parseInt(args[2]));
                                            }
                                            else
                                            {
                                                DebugConsole.globalHash[args[1]] = ((args[2].match(/^"(.*?)"$/)) ? args[2].replace(/^"(.*?)"$/, "$1") : args[2]);
                                            };
                                        };
                                        this.writeLine(((("Assigned config global var: " + args[1]) + " = ") + DebugConsole.globalHash[args[1]]));
                                    };
                                };
                            }
                            else
                            {
                                if (args[0] == "flushcache")
                                {
                                    ResourceManager.flushUnusedResources();
                                    HitBoxManager.clearCache();
                                    this.writeLine("All resources that are not required and not currently in the loading queue have been unloaded, and hitbox cache has been cleared. Garbage collection has been requested.");
                                    System.gc();
                                }
                                else
                                {
                                    this.writeLine(error);
                                };
                            };
                        };
                    };
                };
            };
        }

        private function hud(... args):void
        {
            var flags:Array = new Array();
            while (((args.length > 0) && (args[0].charAt(0) == "-")))
            {
                flags.push(args[0]);
                args.splice(0, 1);
            };
            var error:String = "hud on or off?";
            if (args.length == 0)
            {
                this.writeLine(error);
            }
            else
            {
                if (args[0] == "on")
                {
                    if (GameController.stageData)
                    {
                        GameController.stageData.HudRef.Container.alpha = 1;
                        GameController.stageData.FPSTimer.MC.visible = true;
                        GameController.constantDebugger.Container.visible = true;
                        this.writeLine("Collisions enabled.");
                    }
                    else
                    {
                        this.writeLine("A game must be active to toggle hud.");
                    };
                }
                else
                {
                    if (args[0] == "off")
                    {
                        if (GameController.stageData)
                        {
                            GameController.stageData.HudRef.Container.alpha = 0;
                            GameController.stageData.FPSTimer.MC.visible = false;
                            GameController.constantDebugger.Container.visible = false;
                            this.writeLine("Collisions disabled");
                        }
                        else
                        {
                            this.writeLine("A game must be active to toggle hud.");
                        };
                    };
                };
            };
        }

        private function tas(... rest):void
        {
            var _loc2_:Array = new Array();
            while (((rest.length > 0) && (rest[0].charAt(0) == "-")))
            {
                _loc2_.push(rest[0]);
                rest.splice(0, 1);
            };
            var _loc3_:String = "tas on or off?";
            if (rest.length == 0)
            {
                this.writeLine(_loc3_);
            }
            else
            {
                if (rest[0] == "on")
                {
                    this.writeLine("tas mode enabled! :>");
                    Main.Root.stage.frameRate = 1;
                }
                else
                {
                    if (rest[0] == "off")
                    {
                        this.writeLine("tas mode disabled... :<");
                        Main.Root.stage.frameRate = 30;
                    };
                };
            };
        }

				private function hack(... args):void
        {
            var j:* = undefined;
            var date:Date;
            var year:String;
            var month:String;
            var day:String;
            var replayData:ByteArray;
            var replayTimer:Timer;
            var replayFunc:Function;
            var events:Array;
            var i:int;
            var success:Boolean;
            var character:Character;
            var flags:Array = new Array();
            while (((args.length > 0) && (args[0].charAt(0) == "-")))
            {
                flags.push(args[0]);
                args.splice(0, 1);
            };
            var error:String = "Error, hack expects args [fsTimer | special | replay | unlocks | collisions | hud]";
            if (args.length == 0)
            {
                this.writeLine(error);
            }
            else
            {
                if (args[0] == "fsTimer")
                {
                    if (args.length <= 1)
                    {
                        this.writeLine("Error parsing hack fsTimer value (Expects [##])");
                    }
                    else
                    {
                        if ((!(GameController.stageData)))
                        {
                            this.writeLine("Error, match must be initialized to change hack fsTimer value");
                        }
                        else
                        {
                            if (((args.length <= 1) || (isNaN(parseInt(args[1])))))
                            {
                                this.writeLine("Error, invalid hack fsTimer value provided (Expects [##])");
                            }
                            else
                            {
                                success = false;
                                args[1] = Math.max(0, parseInt(args[1]));
                                i = 0;
                                while (i < GameController.stageData.Players.length)
                                {
                                    character = GameController.stageData.Players[i];
                                    if (((character) && (character.TransformedSpecial)))
                                    {
                                        character.transformTimerExtend(args[1]);
                                        success = true;
                                    };
                                    i = (i + 1);
                                };
                                this.writeLine(((success) ? (("Characters have been granted an additional " + args[1]) + " frame(s) of final form time") : "Error, no character is currently in final form"));
                            };
                        };
                    };
                }
                else
                {
                    if (args[0] == "special")
                    {
                        if (args.length <= 1)
                        {
                            this.writeLine("Error, hack special value (Expects [mini, mega, slow, lightning, vampire, vengeance, freeze, egg, dramatic, turbo, light, heavy, invisible, metal, ssf1])");
                        }
                        else
                        {
                            if (((args.length <= 2) || ((!(args[2] == "off")) && (!(args[2] == "on")))))
                            {
                                this.writeLine((("Error reading command for hack special " + args[1]) + " (Expects [ on | off ]"));
                            }
                            else
                            {
                                if ((!(GameController.currentGame)))
                                {
                                    this.writeLine("Error, could not run hack special, no game setup has be initiated.");
                                }
                                else
                                {
                                    switch (args[1])
                                    {
                                        case "mini":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.MINI, (args[2] == "on"));
                                            break;
                                        case "mega":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.MEGA, (args[2] == "on"));
                                            break;
                                        case "slow":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.SLOW, (args[2] == "on"));
                                            break;
                                        case "lightning":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.LIGHTNING, (args[2] == "on"));
                                            break;
                                        case "vampire":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.VAMPIRE, (args[2] == "on"));
                                            break;
                                        case "vengeance":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.VENGEANCE, (args[2] == "on"));
                                            break;
                                        case "freeze":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.FREEZE, (args[2] == "on"));
                                            break;
                                        case "egg":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.EGG, (args[2] == "on"));
                                            break;
                                        case "dramatic":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.DRAMATIC, (args[2] == "on"));
                                            break;
                                        case "turbo":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.TURBO, (args[2] == "on"));
                                            break;
                                        case "invisible":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.INVISIBLE, (args[2] == "on"));
                                            break;
                                        case "light":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.LIGHT, (args[2] == "on"));
                                            break;
                                        case "heavy":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.HEAVY, (args[2] == "on"));
                                            break;
                                        case "ssf1":
                                            GameController.currentGame.LevelData.specialModes = SpecialMode.setModeEnabled(GameController.currentGame.LevelData.specialModes, SpecialMode.SSF1, (args[2] == "on"));
                                            break;
                                        default:
                                            this.writeLine("Error parsing hack special flag (Expects [mini, mega, slow, lightning, vampire, vengeance, freeze, egg, dramatic, turbo, light, heavy, invisible, metal, ssf1]");
                                            return;
                                    };
                                    this.writeLine((((("Hacked special flag " + args[1]) + ' to "') + args[2]) + '"'));
                                };
                            };
                        };
                    }
                    else
                    {
                        if (args[0] == "replay")
                        {
                            if (args.length <= 1)
                            {
                                this.writeLine("Error, hack replay value (Expects [save | load])");
                            }
                            else
                            {
                                if (args[1] == "save")
                                {
                                    if ((!(GameController.stageData)))
                                    {
                                        this.writeLine("Error, cannot save replay unless a match has been started.");
                                    }
                                    else
                                    {
                                        date = new Date();
                                        year = ("" + date.getFullYear());
                                        month = ((date.getMonth() < 9) ? ("0" + (date.getMonth() + 1)) : ("" + (date.getMonth() + 1)));
                                        day = ((date.getDate() < 9) ? ("0" + (date.getDate() + 1)) : ("" + (date.getDate() + 1)));
                                        replayData = new ByteArray();
                                        replayData.writeUTF(GameController.stageData.ReplayDataObj.exportReplay());
                                        replayData.compress();
                                        Utils.saveFile(replayData, (((((((((GameController.stageData.ReplayDataObj.Name + ".") + year) + "-") + month) + "-") + day) + ".v") + Version.getVersion()) + ".ssfrec"));
                                    };
                                }
                                else
                                {
                                    if (args[1] == "load")
                                    {
                                        if (((GameController.stageData) && (!(GameController.stageData.GameEnded))))
                                        {
                                            this.writeLine("Error, cannot load replay mid-match.");
                                        }
                                        else
                                        {
                                            this.writeLine("Choose a replay file load");
                                            Utils.openFile("SSF2 Replay File (*.ssfrec)", "*.ssfrec");
                                            replayTimer = new Timer(20);
                                            replayFunc = function (e:TimerEvent):void
                                            {
                                                var loadedReplayFile:ByteArray;
                                                var loadedReplayData:ReplayData;
                                                var mode:uint;
                                                if (Utils.finishedLoading)
                                                {
                                                    replayTimer.removeEventListener(TimerEvent.TIMER, replayFunc);
                                                    replayTimer.stop();
                                                    if (Utils.openSuccess)
                                                    {
                                                        loadedReplayFile = Utils.fileRef.data;
                                                        loadedReplayFile.uncompress();
                                                        loadedReplayData = new ReplayData(Main.MAXPLAYERS);
                                                        loadedReplayData.importReplay(loadedReplayFile.readUTF());
                                                        if (((!(loadedReplayData.VersionNumber == Version.getVersion())) && (loadedReplayData.CompatibleVersions.indexOf(Version.getVersion()) < 0)))
                                                        {
                                                            writeLine((((("Error, incompatible version number. Received version\t" + loadedReplayData.VersionNumber) + " (Expecting ") + Version.getVersion()) + ")"));
                                                        }
                                                        else
                                                        {
                                                            writeLine(loadedReplayData.exportReplay());
                                                            mode = loadedReplayData.GameMode;
                                                            if (mode === Mode.ONLINE)
                                                            {
                                                                mode = Mode.VS;
                                                            }
                                                            else
                                                            {
                                                                if (mode === Mode.ONLINE_ARENA)
                                                                {
                                                                    mode = Mode.ARENA;
                                                                };
                                                            };
                                                            GameController.currentGame = new Game(Main.MAXPLAYERS, mode);
                                                            GameController.currentGame.ReplayDataObj = loadedReplayData;
                                                            MenuController.removeAllMenus();
                                                            MenuController.CurrentCharacterSelectMenu.initReplay();
                                                            writeLine("Succesfully loaded replay.");
                                                        };
                                                    }
                                                    else
                                                    {
                                                        writeLine("Error, there was a problem loading the replay file");
                                                    };
                                                };
                                            };
                                            replayTimer.addEventListener(TimerEvent.TIMER, replayFunc);
                                            replayTimer.start();
                                        };
                                    }
                                    else
                                    {
                                        this.writeLine("Error, hack replay value (Expects [save | load])");
                                    };
                                };
                            };
                        }
                        else
                        {
                            if (args[0] == "unlocks")
                            {
                                if (args.length <= 1)
                                {
                                    this.writeLine("Error, hack unlocks value (Expects [on | off | partial])");
                                }
                                else
                                {
                                    if (args[1] == "on")
                                    {
                                        for (j in SaveData.Unlocks)
                                        {
                                            if ((SaveData.Unlocks[j] is Boolean))
                                            {
                                                SaveData.Unlocks[j] = true;
                                            };
                                        };
                                        SaveData.saveGame();
                                        this.writeLine("All unlockables have been unlocked.");
                                    }
                                    else
                                    {
                                        if (args[1] == "off")
                                        {
                                            for (j in SaveData.Unlocks)
                                            {
                                                if ((SaveData.Unlocks[j] is Boolean))
                                                {
                                                    SaveData.Unlocks[j] = false;
                                                };
                                            };
                                            SaveData.saveGame();
                                            this.writeLine("All unlockables have been locked.");
                                        }
                                        else
                                        {
                                            if (args[1] == "partial")
                                            {
                                                for (j in SaveData.Unlocks)
                                                {
                                                    if ((SaveData.Unlocks[j] is Boolean))
                                                    {
                                                        SaveData.Unlocks[j] = false;
                                                    };
                                                };
                                                UnlockController.getUnlockableByID(Unlockable.SANDBAG).TriggerUnlock = true;
                                                SaveData.Records.vs.stages.konohavillage = 14;
                                                SaveData.Records.classic.wins.naruto = {"score":123456};
                                                SaveData.Records.vs.ffaMatchTotal = 14;
                                                UnlockController.getUnlockableByID(Unlockable.WORLD_TOURNAMENT).TriggerUnlock = true;
                                                SaveData.Unlocks.waterKOs = 19;
                                                SaveData.Records.classic.wins.jigglypuff = {"score":123456};
                                                SaveData.Unlocks.linkHyrule64Condition = true;
                                                SaveData.Unlocks.zeldaHyrule64Condition = true;
                                                SaveData.Unlocks.linkHyrule64Condition = true;
                                                SaveData.Unlocks.zeldaHyrule64Condition = true;
                                                SaveData.Unlocks.ghostNessSDs = 2;
                                                UnlockController.getUnlockableByID(Unlockable.METAL_CAVERN).TriggerUnlock = true;
                                                SaveData.Records.vs.matchTotal = 99;
                                                SaveData.Records.vs.matches.sandbag = 0;
                                                SaveData.Unlocks.eventAllStar01 = true;
                                                SaveData.Unlocks.events11_20 = true;
                                                SaveData.Unlocks.eventAllStar06 = true;
                                                SaveData.Unlocks.events21_30 = true;
                                                SaveData.Unlocks.eventAllStar07 = true;
                                                SaveData.Unlocks.events31_33 = true;
                                                SaveData.Unlocks.eventAllStar08 = true;
                                                SaveData.Unlocks.events34_40 = true;
                                                SaveData.Unlocks.eventAllStar09 = true;
                                                SaveData.Unlocks.events41_46 = true;
                                                SaveData.Unlocks.eventAllStarBeta = true;
                                                SaveData.Unlocks.events47_51 = false;
                                                SaveData.Unlocks.eventsARank = false;
                                                SaveData.Unlocks.eventsSRank = false;
                                                events = ResourceManager.getResourceByID("event_mode").getProp("eventList");
                                                i = 0;
                                                while (i < events.length)
                                                {
                                                    SaveData.Records.events.wins[events[i].id] = {
                                                        "rank":"S",
                                                        "score":0,
                                                        "scoreType":"time",
                                                        "fps":30
                                                    };
                                                    i = (i + 1);
                                                };
                                                UnlockController.getUnlockableByID(Unlockable.ALTERNATE_TRACKS).TriggerUnlock = true;
                                                SaveData.saveGame();
                                                this.writeLine("All unlockable conditions have been partially satisfied.");
                                            }
                                            else
                                            {
                                                this.writeLine("Error, hack unlocks value (Expects [on | off | partial])");
                                            };
                                        };
                                    };
                                };
                            }
                            else
                            {
                                if (args[0] == "hud")
                                {
                                    if (args.length <= 1)
                                    {
                                        this.writeLine("Error, hack hud value (Expects [on | off])");
                                    }
                                    else
                                    {
                                        if (args[1] == "on")
                                        {
                                            if (GameController.stageData)
                                            {
                                                GameController.stageData.HudRef.Container.alpha = 1;
                                                GameController.stageData.FPSTimer.MC.visible = true;
                                                GameController.constantDebugger.Container.visible = true;
                                                this.writeLine("Collisions enabled.");
                                            }
                                            else
                                            {
                                                this.writeLine("A game must be active to toggle hud.");
                                            };
                                        }
                                        else
                                        {
                                            if (args[1] == "off")
                                            {
                                                if (GameController.stageData)
                                                {
                                                    GameController.stageData.HudRef.Container.alpha = 0;
                                                    GameController.stageData.FPSTimer.MC.visible = false;
                                                    GameController.constantDebugger.Container.visible = false;
                                                    this.writeLine("Collisions disabled");
                                                }
                                                else
                                                {
                                                    this.writeLine("A game must be active to toggle hud.");
                                                };
                                            }
                                            else
                                            {
                                                this.writeLine("Error, hack collisions value (Expects [on | off])");
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
            };
        }				
				
        public function alert(str:String):void
        {
            if (((Main.DEBUG) && (this.m_alerts)))
            {
                if ((!((GameController.currentGame) && (((GameController.currentGame.GameMode == Mode.ONLINE) || (GameController.currentGame.GameMode == Mode.ONLINE_ARENA)) || (GameController.currentGame.GameMode == Mode.ONLINE_WAITING_ROOM)))))
                {
                    this.forceShow();
                };
                this.writeLine(str);
            };
        }

        public function writeEndAttackControls(str:String):void
        {
            if (this.m_controlsCapture)
            {
                this.writeLine(str);
            };
        }

        public function writeTextData(param1:String):void
        {
            this.writeLine(param1);
        }

        private function writeDatScript():void
        {
            var buffer:String;
            var first:int;
            var second:int;
            var tp:int;
            buffer = "";
            var bulkTrace:Function = function (str:String):void
            {
                buffer = (buffer + str);
                buffer = (buffer + "\n");
            };
            var b:int;
            var names:Array = new Array(ResourceManager.pool.length);
            b = 0;
            while (b < ResourceManager.pool.length)
            {
                names[b] = b;
                b = (b + 1);
            };
            b = 1000;
            while (b > 0)
            {
                b = (b - 1);
                first = Utils.randomInteger(0, (names.length - 1));
                second = Utils.randomInteger(0, (names.length - 1));
                tp = names[first];
                names[first] = names[second];
                names[second] = tp;
            };
            (bulkTrace(":: ------------- BEGIN make_dat_files.bat -------------"));
            b = 0;
            while (b < ResourceManager.pool.length)
            {
                if (ResourceManager.pool[b].ID === "targettest_sheik")
                {
                }
                else
                {
                    if (ResourceManager.pool[b].ID === "sheik")
                    {
                    }
                    else
                    {
                        if ((!(ResourceManager.pool[b].EncryptedFileName)))
                        {
                        }
                        else
                        {
                            if (ResourceManager.pool[b].Type == Resource.CHARACTER)
                            {
                                (bulkTrace((((("ren ..\\..\\build\\data\\character\\" + ResourceManager.pool[b].FileName) + " DAT") + names[b]) + ".ssf")));
                            }
                            else
                            {
                                if (ResourceManager.pool[b].Type == Resource.STAGE)
                                {
                                    (bulkTrace((((("ren ..\\..\\build\\data\\stage\\" + ResourceManager.pool[b].FileName) + " DAT") + names[b]) + ".ssf")));
                                }
                                else
                                {
                                    if (ResourceManager.pool[b].Type == Resource.MISC)
                                    {
                                        (bulkTrace((((("ren ..\\..\\build\\data\\misc\\" + ResourceManager.pool[b].FileName) + " DAT") + names[b]) + ".ssf")));
                                    }
                                    else
                                    {
                                        if (ResourceManager.pool[b].Type == Resource.EXTRA)
                                        {
                                            (bulkTrace((((("ren ..\\..\\build\\data\\misc\\" + ResourceManager.pool[b].FileName) + " DAT") + names[b]) + ".ssf")));
                                        }
                                        else
                                        {
                                            if (ResourceManager.pool[b].Type == Resource.MENU)
                                            {
                                                (bulkTrace((((("ren ..\\..\\build\\data\\menu\\" + ResourceManager.pool[b].FileName) + " DAT") + names[b]) + ".ssf")));
                                            }
                                            else
                                            {
                                                if (ResourceManager.pool[b].Type == Resource.AUDIO)
                                                {
                                                    (bulkTrace((((("ren ..\\..\\build\\data\\sound\\" + ResourceManager.pool[b].FileName) + " DAT") + names[b]) + ".ssf")));
                                                }
                                                else
                                                {
                                                    if (ResourceManager.pool[b].Type == Resource.MUSIC)
                                                    {
                                                        (bulkTrace((((("ren ..\\..\\build\\data\\sound\\" + ResourceManager.pool[b].FileName) + " DAT") + names[b]) + ".ssf")));
                                                    }
                                                    else
                                                    {
                                                        if (ResourceManager.pool[b].Type == Resource.MODE)
                                                        {
                                                            (bulkTrace((((("ren ..\\..\\build\\data\\modes\\" + ResourceManager.pool[b].FileName) + " DAT") + names[b]) + ".ssf")));
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
                b = (b + 1);
            };
            (bulkTrace("move ..\\..\\build\\data\\character\\DAT*.ssf ..\\..\\build\\data\\"));
            (bulkTrace("move ..\\..\\build\\data\\stage\\DAT*.ssf ..\\..\\build\\data\\"));
            (bulkTrace("move ..\\..\\build\\data\\misc\\DAT*.ssf ..\\..\\build\\data\\"));
            (bulkTrace("move ..\\..\\build\\data\\menu\\DAT*.ssf ..\\..\\build\\data\\"));
            (bulkTrace("move ..\\..\\build\\data\\sound\\DAT*.ssf ..\\..\\build\\data\\"));
            (bulkTrace("move ..\\..\\build\\data\\modes\\DAT*.ssf ..\\..\\build\\data\\"));
            (bulkTrace(":: ------------- END make_dat_files.bat -------------"));
            (bulkTrace("\n"));
            (bulkTrace(":: ------------- BEGIN unmake_dat_files.bat -------------"));
            (bulkTrace("mkdir ..\\..\\build\\data\\character"));
            (bulkTrace("mkdir ..\\..\\build\\data\\stage"));
            (bulkTrace("mkdir ..\\..\\build\\data\\misc"));
            (bulkTrace("mkdir ..\\..\\build\\data\\menu"));
            (bulkTrace("mkdir ..\\..\\build\\data\\sound"));
            (bulkTrace("mkdir ..\\..\\build\\data\\modes"));
            b = 0;
            while (b < ResourceManager.pool.length)
            {
                if (ResourceManager.pool[b].ID === "targettest_sheik")
                {
                }
                else
                {
                    if (ResourceManager.pool[b].ID === "sheik")
                    {
                    }
                    else
                    {
                        if ((!(ResourceManager.pool[b].EncryptedFileName)))
                        {
                        }
                        else
                        {
                            if (ResourceManager.pool[b].Type == Resource.CHARACTER)
                            {
                                (bulkTrace(((("move ..\\..\\build\\data\\" + "DAT") + names[b]) + ".ssf ..\\..\\build\\data\\character\\")));
                                (bulkTrace((((("ren ..\\..\\build\\data\\character\\" + "DAT") + names[b]) + ".ssf ") + ResourceManager.pool[b].FileName)));
                            }
                            else
                            {
                                if (ResourceManager.pool[b].Type == Resource.STAGE)
                                {
                                    (bulkTrace(((("move ..\\..\\build\\data\\" + "DAT") + names[b]) + ".ssf ..\\..\\build\\data\\stage\\")));
                                    (bulkTrace((((("ren ..\\..\\build\\data\\stage\\" + "DAT") + names[b]) + ".ssf ") + ResourceManager.pool[b].FileName)));
                                }
                                else
                                {
                                    if (ResourceManager.pool[b].Type == Resource.MISC)
                                    {
                                        (bulkTrace(((("move ..\\..\\build\\data\\" + "DAT") + names[b]) + ".ssf ..\\..\\build\\data\\misc\\")));
                                        (bulkTrace((((("ren ..\\..\\build\\data\\misc\\" + "DAT") + names[b]) + ".ssf ") + ResourceManager.pool[b].FileName)));
                                    }
                                    else
                                    {
                                        if (ResourceManager.pool[b].Type == Resource.EXTRA)
                                        {
                                            (bulkTrace(((("move ..\\..\\build\\data\\" + "DAT") + names[b]) + ".ssf ..\\..\\build\\data\\misc\\")));
                                            (bulkTrace((((("ren ..\\..\\build\\data\\misc\\" + "DAT") + names[b]) + ".ssf ") + ResourceManager.pool[b].FileName)));
                                        }
                                        else
                                        {
                                            if (ResourceManager.pool[b].Type == Resource.MENU)
                                            {
                                                (bulkTrace(((("move ..\\..\\build\\data\\" + "DAT") + names[b]) + ".ssf ..\\..\\build\\data\\menu\\")));
                                                (bulkTrace((((("ren ..\\..\\build\\data\\menu\\" + "DAT") + names[b]) + ".ssf ") + ResourceManager.pool[b].FileName)));
                                            }
                                            else
                                            {
                                                if (ResourceManager.pool[b].Type == Resource.AUDIO)
                                                {
                                                    (bulkTrace(((("move ..\\..\\build\\data\\" + "DAT") + names[b]) + ".ssf ..\\..\\build\\data\\sound\\")));
                                                    (bulkTrace((((("ren ..\\..\\build\\data\\sound\\" + "DAT") + names[b]) + ".ssf ") + ResourceManager.pool[b].FileName)));
                                                }
                                                else
                                                {
                                                    if (ResourceManager.pool[b].Type == Resource.MUSIC)
                                                    {
                                                        (bulkTrace(((("move ..\\..\\build\\data\\" + "DAT") + names[b]) + ".ssf ..\\..\\build\\data\\sound\\")));
                                                        (bulkTrace((((("ren ..\\..\\build\\data\\sound\\" + "DAT") + names[b]) + ".ssf ") + ResourceManager.pool[b].FileName)));
                                                    }
                                                    else
                                                    {
                                                        if (ResourceManager.pool[b].Type == Resource.MODE)
                                                        {
                                                            (bulkTrace(((("move ..\\..\\build\\data\\" + "DAT") + names[b]) + ".ssf ..\\..\\build\\data\\modes\\")));
                                                            (bulkTrace((((("ren ..\\..\\build\\data\\modes\\" + "DAT") + names[b]) + ".ssf ") + ResourceManager.pool[b].FileName)));
                                                        };
                                                    };
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
                b = (b + 1);
            };
            (bulkTrace(":: ------------- END unmake_dat_files.bat -------------"));
            (bulkTrace("\n"));
            (bulkTrace("// ------------- BEGIN mappings -------------"));
            (bulkTrace("// Note: This is only the data that is loaded on-demand (characters, stages, music, etc.). Don't overwrite entire mappings with this!"));
            var tempManifest:Object = Utils.cloneObject(ResourceManager.manifestJSONData);
            b = 0;
            while (b < ResourceManager.pool.length)
            {
                if ((!(ResourceManager.pool[b].EncryptedFileName)))
                {
                }
                else
                {
                    if (ResourceManager.pool[b].Type == Resource.CHARACTER)
                    {
                        tempManifest.character[ResourceManager.pool[b].ID].file_pub = (("DAT" + names[b]) + ".ssf");
                    }
                    else
                    {
                        if (ResourceManager.pool[b].Type == Resource.STAGE)
                        {
                            tempManifest.stage[ResourceManager.pool[b].ID].file_pub = (("DAT" + names[b]) + ".ssf");
                        }
                        else
                        {
                            if (ResourceManager.pool[b].Type == Resource.MISC)
                            {
                                tempManifest.misc[ResourceManager.pool[b].ID].file_pub = (("DAT" + names[b]) + ".ssf");
                            }
                            else
                            {
                                if (ResourceManager.pool[b].Type == Resource.EXTRA)
                                {
                                    tempManifest.extra[ResourceManager.pool[b].ID].file_pub = (("DAT" + names[b]) + ".ssf");
                                }
                                else
                                {
                                    if (ResourceManager.pool[b].Type == Resource.MENU)
                                    {
                                        tempManifest.menu[ResourceManager.pool[b].ID].file_pub = (("DAT" + names[b]) + ".ssf");
                                    }
                                    else
                                    {
                                        if (ResourceManager.pool[b].Type == Resource.AUDIO)
                                        {
                                            tempManifest.audio[ResourceManager.pool[b].ID].file_pub = (("DAT" + names[b]) + ".ssf");
                                        }
                                        else
                                        {
                                            if (ResourceManager.pool[b].Type == Resource.MUSIC)
                                            {
                                                tempManifest.music[ResourceManager.pool[b].ID].file_pub = (("DAT" + names[b]) + ".ssf");
                                            }
                                            else
                                            {
                                                if (ResourceManager.pool[b].Type == Resource.MODE)
                                                {
                                                    tempManifest.modes[ResourceManager.pool[b].ID].file_pub = (("DAT" + names[b]) + ".ssf");
                                                };
                                            };
                                        };
                                    };
                                };
                            };
                        };
                    };
                };
                b = (b + 1);
            };
            var engineManifest:Object = {
                "modes":tempManifest.modes,
                "menu":tempManifest.menu,
                "misc":tempManifest.misc,
                "audio":tempManifest.audio
            };
            delete tempManifest.modes;
            delete tempManifest.menu;
            delete tempManifest.misc;
            delete tempManifest.audio;
            tempManifest.character.sheik.file_pub = tempManifest.character.zelda.file_pub;
            (bulkTrace(JSON.stringify(tempManifest, null, "  ")));
            (bulkTrace("// ------------- END mappings -------------"));
            (bulkTrace("\n"));
            (bulkTrace("// ------------- BEGIN manifest -------------"));
            (bulkTrace("// Note: This is in-engine only!"));
            (bulkTrace(JSON.stringify(engineManifest, null, "  ")));
            (bulkTrace("// ------------- END manifest -------------"));
            this.writeLine(buffer);
        }


    }
}//package com.mcleodgaming.ssf2.menus

