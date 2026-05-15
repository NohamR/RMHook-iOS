TARGET = iphone:latest:14.0
INSTALL_TARGET_PROCESSES = remarkable_mobile
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RMHook

RMHook_FILES = Tweak.xm
RMHook_CFLAGS = -fobjc-arc -F$(HOME)/Qt/6.10.0/lib
RMHook_CXXFLAGS = -fobjc-arc -F$(HOME)/Qt/6.10.0/lib -std=c++17
ADDITIONAL_CFLAGS = -std=c++17 -Wno-c++17-extensions
ADDITIONAL_CXXFLAGS = -std=c++17 -Wno-c++17-extensions -DQT_NO_VERSION_TAGGING
ADDITIONAL_OBJCCFLAGS = -std=c++17 -Wno-c++17-extensions -DQT_NO_VERSION_TAGGING
RMHook_LDFLAGS = 
RMHook_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
