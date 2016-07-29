LOCAL_PATH := $(call my-dir)

include $(CLEAR_VARS)

LOCAL_MODULE    := hook
LOCAL_SRC_FILES := hook.c ihookstub.s
LOCAL_LDLIBS := -llog
LOCAL_ARM_MODE := arm

include $(BUILD_SHARED_LIBRARY)

