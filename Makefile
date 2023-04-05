#TOOLCHAIN_BIN_PATH = toolchain/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin
#set env var, e.g. "export TOOLCHAIN_BIN_PATH=/opt/FT/TXT/opt/ext-toolchain/bin"

#check if TOOLCHAIN_BIN_PATH environment variable is set:
TOOLCHAIN_BIN_PATH=/home/u18new/Downloads/gcc-linaro-7.2.1-2017.11-x86_64_arm-linux-gnueabihf/bin

ifndef TOOLCHAIN_BIN_PATH
$(error TOOLCHAIN_BIN_PATH is undefined! Set with 'export TOOLCHAIN_BIN_PATH=/path/to/toolchain/bin')
endif

TOOLCHAIN_PREFIX = arm-linux-gnueabihf-
COMPILER = g++
AR = ar

LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc.so
HEAPPROFILE=my_heap_profile_output

# Main txt folder and files
# Worked
 EXECUTEABLE_g++ = clang++-14 --target=arm-linux-gnueabihf
# Worked with PASS
# EXECUTEABLE_g++ = clang++-14 --target=arm-linux-gnueabihf -flegacy-pass-manager -g -Xclang -load -Xclang /home/ubuntu-18/LLVM_passes/injectFunc/printf.so

#EXECUTEABLE_g++ = clang++-14 --target=arm-linux-gnueabihf -flegacy-pass-manager -g -Xclang -load -Xclang /home/ubuntu-18/LLVM_passes/functionPassses/funcNArg.so

# WORKING WITH THIS ONE,
# EXECUTEABLE_g++ =  clang++-14 --target=arm-linux-gnueabihf -flegacy-pass-manager -g -Xclang -load -Xclang /home/u18new/LLVM_PASSES/LogPasses-new/messagePublishFunc/TopicExtraction/mqtt/instrument.so


#Using LD_PRELOAD & HEAPPROFILE
#EXECUTEABLE_g++ = env LD_PRELOAD=/usr/lib/x86_64-linux-gnu/libtcmalloc.so HEAPPROFILE=./profiles/my_heap_profile_output  clang++-14 --target=arm-linux-gnueabihf -flegacy-pass-manager -g -Xclang -load -Xclang /home/u18new/LLVM_PASSES/LogPasses-new/messagePublishFunc/instrument.so

#EXECUTEABLE_g++ = clang++-14 --target=arm-linux-gnueabihf -flegacy-pass-manager -g -Xclang -load -Xclang /home/ubuntu-18/LLVM_passes/FunctionsWithValues/getFunctions/function.so

# Didn't work
#EXECUTEABLE_g++ = $(TOOLCHAIN_BIN_PATH)/$(TOOLCHAIN_PREFIX)$(COMPILER)
#EXECUTEABLE_g++ = /home/ubuntu-18/llvm-project-14.0.6.src/build/bin/clang++ --target=arm-linux-gnueabihf  

#EXECUTEABLE_g++ = /home/ubuntu-18/llvm-project-14.0.6.src/build/bin/clang++ --target=arm-linux-gnueabihf -flegacy-pass-manager -g -Xclang -load -Xclang /home/ubuntu-18/llvm-project-14.0.6.src/build/lib/LLVMHello.so

# EXECUTEABLE_g++ = clang++-14 --target=arm-linux-gnueabihf -flegacy-pass-manager -g -Xclang -load -Xclang /home/ubuntu-18/LLVM_passes/FunctionsWithValues/getFunctions/function.so

# previously worked file
#LIB_CFLAGS = -L"../Desktop/paho.mqtt.c/build/_install/lib" -L"../Desktop/paho.mqtt.cpp/build/_install/lib" -L"deps/lib"
#LIB_INC_CFLAGS = -I"../Desktop/paho.mqtt.c/build/_install/include/" -I"../Desktop/paho.mqtt.cpp/build/_install/include/" -I"deps/include"

# Now changing,
LIB_CFLAGS = -L"deps/lib"
LIB_INC_CFLAGS = -I"deps/include"


EXECUTEABLE_ar = $(TOOLCHAIN_BIN_PATH)/$(TOOLCHAIN_PREFIX)$(AR)
BIN_DIR = bin

COMPILER_FLAGS_DEBUG = -std=gnu++0x -std=c++0x -D"DEBUG" -D"SPDLOG_ACTIVE_LEVEL=SPDLOG_LEVEL_TRACE" -I"TxtSmartFactoryLib/include" -I"TxtSmartFactoryLib/libs" $(LIB_INC_CFLAGS) -O0 -g3 -Wall -c -fmessage-length=0 -Wno-psabi

COMPILER_FLAGS_RELEASE = -std=gnu++0x -std=c++0x -D"ENDIAN_LITTLE" -I"TxtSmartFactoryLib/include" -I"TxtSmartFactoryLib/libs" $(LIB_INC_CFLAGS) -O3 -Wall -c -fmessage-length=0 -Wno-psabi

#LINKER_FLAGS_RELEASE_PATHS = -L"deps/lib" -L"TxtSmartFactoryLib/Posix_Release/src" -L"TxtSmartFactoryLib/Posix_Release"
LINKER_FLAGS_RELEASE_PATHS =  $(LIB_CFLAGS) -L"TxtSmartFactoryLib/Posix_Release/src" -L"TxtSmartFactoryLib/Posix_Release"

#LINKER_FLAGS_DEBUG_PATHS = -L"deps/lib" -L"TxtSmartFactoryLib/Posix_Debug/src" -L"TxtSmartFactoryLib/Posix_Debug"
LINKER_FLAGS_DEBUG_PATHS = $(LIB_CFLAGS) -L"TxtSmartFactoryLib/Posix_Debug/src" -L"TxtSmartFactoryLib/Posix_Debug"


LINKER_FLAGS_LIBS = -l"SDLWidgetsLib" \
	-l"TxtSmartFactoryLib" \
	-l"paho-mqtt3c" \
	-l"paho-mqtt3a" \
	-l"paho-mqttpp3" \
	-l"opencv_core" \
	-l"opencv_videoio" \
	-l"opencv_imgcodecs" \
	-l"opencv_imgproc" \
	-l"jsoncpp" \
	-l"pthread" \
	-l"SDL" \
	-l"SDL_gfx" \
	-l"SDL_ttf" \
	-l"ts" \
	-l"freetype" \
	-l"z" \
	-l"png16" \
	-l"bz2" \
	-l"jpeg" \
	-l"asound" \
	-l"SDL_image" \
	-l"nfc" \
	-l"freefare" \
	-l"crypto" \
	-l"TxtControlLib" \
	-l"ROBOProLib" \
	-l"MotorIOLib" \
	-l"KeLibTxt"

#create empty dirs
$(shell mkdir -p bin)
$(shell mkdir -p TxtSmartFactoryLib/Posix_Release/src)
$(shell mkdir -p TxtSmartFactoryLib/Posix_Debug/src)
$(shell mkdir -p TxtSmartFactoryLib/Posix_Release/libs)
$(shell mkdir -p TxtSmartFactoryLib/Posix_Debug/libs)
$(shell mkdir -p TxtFactoryClient/HBW_Release/src)
$(shell mkdir -p TxtFactoryClient/HBW_Debug/src)
$(shell mkdir -p TxtFactoryClient/VGR_Release/src)
$(shell mkdir -p TxtFactoryClient/VGR_Debug/src)
$(shell mkdir -p TxtFactoryClient/MPO_Release/src)
$(shell mkdir -p TxtFactoryClient/MPO_Debug/src)
$(shell mkdir -p TxtFactoryClient/SLD_Release/src)
$(shell mkdir -p TxtFactoryClient/SLD_Debug/src)
$(shell mkdir -p TxtFactoryMain/Posix_Release/src)
$(shell mkdir -p TxtFactoryMain/Posix_Debug/src)
$(shell mkdir -p TxtParkPos/SSC/src)
$(shell mkdir -p TxtParkPos/SSC/src)
$(shell mkdir -p TxtParkPos/HBW/src)
$(shell mkdir -p TxtParkPos/HBW/src)
$(shell mkdir -p TxtParkPos/VGR/src)
$(shell mkdir -p TxtParkPos/VGR/src)
$(shell mkdir -p TxtParkPos/MPO/src)
$(shell mkdir -p TxtParkPos/MPO/src)

#all: all_debug all_release
all: all_release

all_debug: $(BIN_DIR)/TxtFactoryHBW_Debug $(BIN_DIR)/TxtFactoryVGR_Debug $(BIN_DIR)/TxtFactoryMPO_Debug $(BIN_DIR)/TxtFactorySLD_Debug $(BIN_DIR)/TxtFactoryMain_Debug

all_release: $(BIN_DIR)/TxtFactoryHBW $(BIN_DIR)/TxtFactoryVGR $(BIN_DIR)/TxtFactoryMPO $(BIN_DIR)/TxtFactorySLD $(BIN_DIR)/TxtFactoryMain $(BIN_DIR)/TxtParkPosSSC $(BIN_DIR)/TxtParkPosHBW $(BIN_DIR)/TxtParkPosVGR $(BIN_DIR)/TxtParkPosMPO

# LIB ---
TxtSmartFactoryLib/Posix_Debug/libTxtSmartFactoryLib.a: $(shell find TxtSmartFactoryLib/src/ -name "*.cpp" | sed -e "s|src/|Posix_Debug/src/|" | sed -e "s/\.cpp/\.o/") $(shell find TxtSmartFactoryLib/libs/ -name "*.cpp" | sed -e "s|libs/|Posix_Debug/libs/|" | sed -e "s/\.cpp/\.o/") $(shell find TxtSmartFactoryLib/libs/ -name "*.c" | sed -e "s|libs/|Posix_Debug/libs/|" | sed -e "s/\.c/\.o/")
	$(EXECUTEABLE_ar) -r "$@" $^

TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a: $(shell find TxtSmartFactoryLib/src/ -name "*.cpp" | sed -e "s|src/|Posix_Release/src/|" | sed -e "s/\.cpp/\.o/") $(shell find TxtSmartFactoryLib/libs/ -name "*.cpp" | sed -e "s|libs/|Posix_Release/libs/|" | sed -e "s/.cpp/.o/") $(shell find TxtSmartFactoryLib/libs/ -name "*.c" | sed -e "s|libs/|Posix_Release/libs/|" | sed -e "s/\.c/\.o/")
	$(EXECUTEABLE_ar) -r "$@" $^

TxtSmartFactoryLib/Posix_Release/libs/libalgobsec.a: TxtSmartFactoryLib/libs/libalgobsec.a
	cp TxtSmartFactoryLib/libs/libalgobsec.a TxtSmartFactoryLib/Posix_Release/libs

TxtSmartFactoryLib/Posix_Debug/libs/libalgobsec.a: TxtSmartFactoryLib/libs/libalgobsec.a
	cp TxtSmartFactoryLib/libs/libalgobsec.a TxtSmartFactoryLib/Posix_Debug/libs

TxtSmartFactoryLib/Posix_Debug/src/%.o: TxtSmartFactoryLib/src/%.cpp
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" $<

# creating IR of TxtSmartFactoryLib cpp files
TxtSmartFactoryLib/Posix_Debug/src/%.ll: TxtSmartFactoryLib/src/%.cpp
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -emit-llvm -S -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" $<

TxtFactoryClient/src/%.ll: TxtFactoryClient/src/%.cpp
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -emit-llvm -S -D"CLIENT_HBW" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -o "$@" $<

# To compile IR to binary =>  TxtFactoryClient/src/%.ll to $(BIN_DIR)/TxtFactoryHBW, do the following,
# At first compile the TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a, run following on terminal,
# make TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
# also compile the TxtFactoryClient/src/main.ll with this cmd - make TxtFactoryClient/src/main.ll
# now to compile the obj file from TxtFactoryClient/src/%.ll with following cmds,
# llvm-as-14 main.ll -o e.bc
# llc-14 -mtriple=arm-linux-gnueabihf -filetype=obj -relocation-model=pic e.bc -o e.o
# Now use that e.o obj file to compile the $(BIN_DIR)/TxtFactoryHBW - make binFromIR/TxtFactoryHBW
binFromIR/TxtFactoryHBW: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
#	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"CLIENT_HBW" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/HBW_Release/src/main.d" -o "TxtFactoryClient/HBW_Release/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/src/e.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"


TxtSmartFactoryLib/Posix_Debug/libs/%.o: TxtSmartFactoryLib/libs/%.c
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" $<

TxtSmartFactoryLib/Posix_Debug/libs/%.o: TxtSmartFactoryLib/libs/%.cpp
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" $<

TxtSmartFactoryLib/Posix_Release/src/%.o: TxtSmartFactoryLib/src/%.cpp
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" $<

TxtSmartFactoryLib/Posix_Release/libs/%.o: TxtSmartFactoryLib/libs/%.c
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" $<

TxtSmartFactoryLib/Posix_Release/libs/%.o: TxtSmartFactoryLib/libs/%.cpp
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"$@" -o "$@" $<

# # DEBUG ---
$(BIN_DIR)/TxtFactoryHBW_Debug: TxtSmartFactoryLib/Posix_Debug/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -D"CLIENT_HBW" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/HBW_Debug/src/main.d" -o "TxtFactoryClient/HBW_Debug/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/HBW_Debug/src/main.o $(LINKER_FLAGS_DEBUG_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtFactoryVGR_Debug: TxtSmartFactoryLib/Posix_Debug/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -D"CLIENT_VGR" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/VGR_Debug/src/main.d" -o "TxtFactoryClient/VGR_Debug/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/VGR_Debug/src/main.o $(LINKER_FLAGS_DEBUG_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtFactoryMPO_Debug: TxtSmartFactoryLib/Posix_Debug/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -D"CLIENT_MPO" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/MPO_Debug/src/main.d" -o "TxtFactoryClient/MPO_Debug/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/MPO_Debug/src/main.o $(LINKER_FLAGS_DEBUG_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtFactorySLD_Debug: TxtSmartFactoryLib/Posix_Debug/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -D"CLIENT_SLD" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/SLD_Debug/src/main.d" -o "TxtFactoryClient/SLD_Debug/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/SLD_Debug/src/main.o $(LINKER_FLAGS_DEBUG_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtFactoryMain_Debug: TxtSmartFactoryLib/Posix_Debug/libTxtSmartFactoryLib.a TxtSmartFactoryLib/Posix_Debug/libs/libalgobsec.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_DEBUG) -o "TxtFactoryMain/Posix_Debug/src/main.o" TxtFactoryMain/src/main.cpp
	#$(EXECUTEABLE_g++) -L"TxtSmartFactoryLib/Posix_Debug" -L"TxtSmartFactoryLib/Posix_Debug/libs" -L"deps/lib" -Wl,-rpath=/opt/knobloch/libs/ -o "$@.cloud"  TxtFactoryMain/Posix_Debug/src/main.o -lTxtSmartFactoryLib -lTxtControlLib -lSDLWidgetsLib -lMotorIOLib -lpaho-mqtt3c -lpaho-mqtt3a -lpaho-mqttpp3 -lopencv_core -lopencv_videoio -lopencv_imgcodecs -lopencv_imgproc -ljsoncpp -lalgobsec -lpthread -lSDL -lSDL_gfx -lSDL_ttf -lts -lfreetype -lz -lpng16 -lbz2 -ljpeg -lasound -lSDL_image -lnfc -lROBOProLib -lKeLibTxt
	$(EXECUTEABLE_g++) -L"TxtSmartFactoryLib/Posix_Debug" -L"TxtSmartFactoryLib/Posix_Debug/libs" $(LIB_CFLAGS) -Wl,-rpath=/opt/knobloch/libs/ -o "$@.cloud"  TxtFactoryMain/Posix_Debug/src/main.o -lTxtSmartFactoryLib -lTxtControlLib -lSDLWidgetsLib -lMotorIOLib -lpaho-mqtt3c -lpaho-mqtt3a -lpaho-mqttpp3 -lopencv_core -lopencv_videoio -lopencv_imgcodecs -lopencv_imgproc -ljsoncpp -lalgobsec -lpthread -lSDL -lSDL_gfx -lSDL_ttf -lts -lfreetype -lz -lpng16 -lbz2 -ljpeg -lasound -lSDL_image -lnfc -lROBOProLib -lKeLibTxt
	
# RELEASE ---
$(BIN_DIR)/TxtFactoryHBW: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"CLIENT_HBW" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/HBW_Release/src/main.d" -o "TxtFactoryClient/HBW_Release/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/HBW_Release/src/main.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtFactoryVGR: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"CLIENT_VGR" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/VGR_Release/src/main.d" -o "TxtFactoryClient/VGR_Release/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/VGR_Release/src/main.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtFactoryMPO: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"CLIENT_MPO" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/MPO_Release/src/main.d" -o "TxtFactoryClient/MPO_Release/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/MPO_Release/src/main.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtFactorySLD: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"CLIENT_SLD" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtFactoryClient/SLD_Release/src/main.d" -o "TxtFactoryClient/SLD_Release/src/main.o" TxtFactoryClient/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtFactoryClient/SLD_Release/src/main.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtFactoryMain: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a TxtSmartFactoryLib/Posix_Release/libs/libalgobsec.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -o "TxtFactoryMain/Posix_Release/src/main.o" TxtFactoryMain/src/main.cpp
	#$(EXECUTEABLE_g++) -L"TxtSmartFactoryLib/Posix_Release" -L"TxtSmartFactoryLib/Posix_Release/libs" -L"deps/lib" -Wl,-rpath=/opt/knobloch/libs/ -o "$@.cloud" TxtFactoryMain/Posix_Release/src/main.o -lTxtSmartFactoryLib -lTxtControlLib -lSDLWidgetsLib -lMotorIOLib -lpaho-mqtt3c -lpaho-mqtt3a -lpaho-mqttpp3 -lopencv_core -lopencv_videoio -lopencv_imgcodecs -lopencv_imgproc -ljsoncpp -lalgobsec -lpthread -lSDL -lSDL_gfx -lSDL_ttf -lts -lfreetype -lz -lpng16 -lbz2 -ljpeg -lasound -lSDL_image -lnfc -lROBOProLib -lKeLibTxt
	$(EXECUTEABLE_g++) -L"TxtSmartFactoryLib/Posix_Release" -L"TxtSmartFactoryLib/Posix_Release/libs" $(LIB_CFLAGS) -Wl,-rpath=/opt/knobloch/libs/ -o "$@.cloud" TxtFactoryMain/Posix_Release/src/main.o -lTxtSmartFactoryLib -lTxtControlLib -lSDLWidgetsLib -lMotorIOLib -lpaho-mqtt3c -lpaho-mqtt3a -lpaho-mqttpp3 -lopencv_core -lopencv_videoio -lopencv_imgcodecs -lopencv_imgproc -ljsoncpp -lalgobsec -lpthread -lSDL -lSDL_gfx -lSDL_ttf -lts -lfreetype -lz -lpng16 -lbz2 -ljpeg -lasound -lSDL_image -lnfc -lROBOProLib -lKeLibTxt

# PARKPOS
$(BIN_DIR)/TxtParkPosSSC: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"MAIN_SSC" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtParkPos/SSC/src/main.d" -o "TxtParkPos/SSC/src/main.o" TxtParkPos/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtParkPos/SSC/src/main.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtParkPosHBW: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"CLIENT_HBW" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtParkPos/HBW/src/main.d" -o "TxtParkPos/HBW/src/main.o" TxtParkPos/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtParkPos/HBW/src/main.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtParkPosVGR: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"CLIENT_VGR" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtParkPos/VGR/src/main.d" -o "TxtParkPos/VGR/src/main.o" TxtParkPos/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtParkPos/VGR/src/main.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

$(BIN_DIR)/TxtParkPosMPO: TxtSmartFactoryLib/Posix_Release/libTxtSmartFactoryLib.a
	$(EXECUTEABLE_g++) $(COMPILER_FLAGS_RELEASE) -D"CLIENT_MPO" -fPIC -MMD -MP -MF"$(@:%.o=%.d)" -MT"TxtParkPos/MPO/src/main.d" -o "TxtParkPos/MPO/src/main.o" TxtParkPos/src/main.cpp
	$(EXECUTEABLE_g++) -Wl,-rpath=/opt/knobloch/libs/ TxtParkPos/MPO/src/main.o $(LINKER_FLAGS_RELEASE_PATHS) $(LINKER_FLAGS_LIBS) -o "$@"

.PHONY: clean
clean:
	rm -f -r TxtSmartFactoryLib/Posix_Release TxtSmartFactoryLib/Posix_Debug TxtFactoryClient/HBW_Release TxtFactoryClient/VGR_Release TxtFactoryClient/MPO_Release TxtFactoryClient/SLD_Release TxtFactoryClient/HBW_Debug TxtFactoryClient/VGR_Debug TxtFactoryClient/MPO_Debug TxtFactoryClient/SLD_Debug TxtFactoryMain/Posix_Release TxtFactoryMain/Posix_Debug TxtParkPos/SSC TxtParkPos/HBW TxtParkPos/VGR TxtParkPos/MPO $(BIN_DIR)/*

