TARGET = iphone:latest:17.0
INSTALL_TARGET_PROCESSES = remarkable_mobile
ARCHS = arm64 

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RMHook

QT_VERSION ?= 6.8.2

RMHook_FILES = Tweak.xm Config.mm
RMHook_CFLAGS = -fobjc-arc -F$(HOME)/Qt/$(QT_VERSION)/ios/lib
RMHook_CXXFLAGS = -fobjc-arc -F$(HOME)/Qt/$(QT_VERSION)/ios/lib -std=c++17 -DQT_NO_VERSION_TAGGING
ADDITIONAL_CFLAGS = -std=c++17 -Wno-c++17-extensions $(RM_VERSION_FLAG)
ADDITIONAL_CXXFLAGS = -std=c++17 -Wno-c++17-extensions -DQT_NO_VERSION_TAGGING $(RM_VERSION_FLAG)
ADDITIONAL_OBJCCFLAGS = -std=c++17 -Wno-c++17-extensions -DQT_NO_VERSION_TAGGING $(RM_VERSION_FLAG)
RMHook_FRAMEWORKS = Foundation QtNetwork QtCore QtWebSockets UIKit UniformTypeIdentifiers Network SystemConfiguration Security IOKit
RMHook_LDFLAGS = -F$(HOME)/Qt/$(QT_VERSION)/ios/lib -lz $(HOME)/Qt/$(QT_VERSION)/ios/lib/libQt6BundledPcre2.a

include $(THEOS_MAKE_PATH)/tweak.mk
