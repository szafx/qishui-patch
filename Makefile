TARGET := iphone:clang:latest:14.0
ARCHS = arm64 arm64e
THEOS_PACKAGE_SCHEME = rootless

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = QishuiPatch
QishuiPatch_FILES = Tweak.xm
QishuiPatch_CFLAGS = -fobjc-arc -O2

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SchubertAppStore 2>/dev/null || true"