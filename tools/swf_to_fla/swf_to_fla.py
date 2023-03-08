import os, sys
from time import time
from shutil import rmtree
from subprocess import call, Popen
def pip(*mods):
    for m in mods:
        call(os.path.join(os.path.dirname(sys.executable), "python")+" -m pip install "+m)
try:
    from colorama import init, Fore
except ImportError:
    pip("colorama")
    from colorama import init, Fore

JPEXS_PATH = r"C:\Program Files (x86)\FFDec\ffdec.bat"
JAVA_PATH = os.path.expandvars(r"%JAVA_HOME%\bin\java.exe")
USE_JPEXS_SCRIPT = True

def manual(text):
    global start_time
    print(Fore.YELLOW + "="*20 + "\nMANUAL INPUT NECESSARY" + Fore.RESET + "\n" + text.strip() + "\n" + Fore.YELLOW + "="*20 + Fore.RESET)
    t = time()
    input("Press enter when you have completed this step. ")
    #start_time += time()-t
def convert_sounds():
    print("Checking FFMPEG installation")
    try:
        call("ffmpeg -hide_banner")
    except FileNotFoundError:
        manual(f"""
{Fore.RED}FFDEC not found.{Fore.RESET}
1. Go to https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-essentials.7z
2. Extract ffmpeg.exe from the 'bin' folder of the archive and place it in this folder.
""")
        convert_sounds()
        return
    else:
        print("OK")
    print("Converting sounds")
    for fn in os.listdir("sounds"):
        n = os.path.splitext(fn)
        if n[1] != ".flv": continue
        n = n[0].split("_", 1)
        if len(n) > 1 and n[0].isdigit(): n = n[1:]
        n = os.path.join("sounds", "_".join(n)+".mp3")
        fn = os.path.join("sounds", fn)
        if os.path.isfile(n): os.remove(n)
        call(["ffmpeg", "-hide_banner", "-loglevel", "warning", "-i", fn, n])
        os.remove(fn)
    print("Complete")
def manual_convert_swf():
    global using_trillix
    b = os.path.basename(swf_path)
    n = os.path.splitext(b)[0]
    manual(f"""
1. Download a SWF decompiler if you haven't already.
   Suggested:
   - Sothink SWF Decompiler (https://www.sothink.com/product/flashdecompiler/)
   - Flash Decompiler Trillix (https://www.eltima.com/products/flashdecompiler/)
2. Open the decompiler, then drag the SWF file onto the window.
Using Sothink:
    3. Click 'Export to FLA/FLEX'.
    4. Copy-paste '{os.path.join(os.path.dirname(__file__), b+'_st', n+'.fla')}' into the 'export path' box (without the quotes).
    5. Click 'OK'.
Using Trillix:
    3. Go to the 'Convert' tab.
    4. Copy-paste '{os.path.dirname(__file__)}' in to the 'conversion path' box (without the quotes).
    5. Click 'Convert Current'.
6. Wait until it is finished, then close the decompiler.
Note - {Fore.RED}DO NOT{Fore.RESET} rename or change anything after converting!
""")
    print("Checking converted files")
    if os.path.isfile(b+".fla") and os.path.isdir(b+"_as"): using_trillix = True
    elif os.path.isdir(b+"_st") and os.path.isfile(os.path.join(b+"_st", n+".fla")): using_trillix = False
    else:
        print(Fore.RED + "Cannot find converted files - make sure you follow the instructions exactly!" + Fore.RESET)
        manual_convert_swf()
        return
    print("OK - using "+("Trillix" if using_trillix else "Sothink"))
def check_file():
    global swf_path, output_loc, start_time
    swf_path = os.path.abspath(input("Enter the SWF filepath or drag the file onto this window and press enter:\n"))
    print()
    print("Checking file")
    for f in ["", ".swf", ".ssf"]:
        if os.path.isfile(swf_path+f):
            start_time = time()
            swf_path += f
            output_loc = os.path.join(os.path.dirname(__file__), os.path.splitext(os.path.basename(swf_path))[0])
            print(f"OK")
            return
    print(Fore.RED + "File does not exist.\n" + Fore.RESET)
    check_file()
def check_java():
    print("Checking Java installation")
    if os.path.isfile(JAVA_PATH):
        print("OK")
    else:
        manual(f"""
{Fore.RED}Java installation not found.{Fore.RESET}
1. Go to https://www.oracle.com/java/technologies/downloads/
2. Click the 'Windows' button.
3. Download and run the x64 or x32 installer.
""")
        check_java()
def extract_jpexs():
    print("Checking JPEXS installation")
    if os.path.isfile(JPEXS_PATH):
        print("OK")
    else:
        manual(f"""
{Fore.RED}JPEXS Flash Decompiler not found.{Fore.RESET}
1. Go to https://github.com/jindrapetrik/jpexs-decompiler/releases/latest
2. Download and run the windows installer executable, making sure the install location is '{os.path.dirname(JPEXS_PATH)}'.
""")
        extract_jpexs()
        return
    if USE_JPEXS_SCRIPT:
        print("Extracting sounds and scripts")
        call([JPEXS_PATH,
            "-format", "sound:flv,script:as", "-export", "sound,script",
            os.path.dirname(__file__), swf_path])
    else:
        print("Extracting sounds")
        call([JPEXS_PATH,
            "-format", "sound:flv", "-export", "sound",
            os.path.join(os.path.dirname(__file__), "sounds"), swf_path])
def arrange_output():
    print("Cleaning up")
    if os.path.isdir(output_loc): rmtree(output_loc)
    b = os.path.basename(swf_path)
    n = os.path.splitext(b)[0]
    if using_trillix:
        os.mkdir(output_loc)
        os.rename(b+".fla", os.path.join(output_loc, n+".fla"))
        os.rename("scripts" if USE_JPEXS_SCRIPT else b+"_as", os.path.join(output_loc, b+"_as"))
        if USE_JPEXS_SCRIPT: rmtree(b+"_as")
    else:
        if USE_JPEXS_SCRIPT:
            os.rename("scripts", output_loc)
            os.rename(os.path.join(b+"_st", n+".fla"), os.path.join(output_loc, n+".fla"))
            rmtree(b+"_st")
        else:
            os.rename(b+"_st", output_loc)
    os.rename("sounds", output_loc+"_sounds")
    print("Complete")
def finish():
    print(Fore.GREEN + f"""
Successfully exported to '{output_loc}'
Operation completed in {int(time()-start_time)} seconds
Open the generated FLA file and then go to https://youtu.be/m-2kfTw26IM?t=196 to see how to do the final steps in Animate""")
    input()

init()
print(f"{Fore.GREEN}SWF to FLA semi-automated\nCreated by Professor Dragon{Fore.RESET}\n")
start_time = None
swf_path = None
output_loc = None
using_trillix = None

check_file()
extract_jpexs()
convert_sounds()
manual_convert_swf()
arrange_output()
finish()
