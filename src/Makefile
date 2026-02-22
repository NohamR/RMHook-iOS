TARGET = iphone:latest:14.0
INSTALL_TARGET_PROCESSES = remarkable_mobile
ARCHS = arm64 arm64e

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = RMHook

RMHook_FILES = Tweak.x
RMHook_CFLAGS = -fobjc-arc
RMHook_FRAMEWORKS = Foundation

include $(THEOS_MAKE_PATH)/tweak.mk
