#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <objc/runtime.h>
#import <stdlib.h>

// Deliberately suppresses UIKit haptic feedback only. It does not hook
// AudioServices, AVFoundation, or any audio playback API.
static void dnh_noHaptic(id self, SEL _cmd) {
    (void)self;
    (void)_cmd;
}

static BOOL dnh_isSubclassOf(Class cls, Class parent) {
    for (Class current = cls; current != Nil; current = class_getSuperclass(current)) {
        if (current == parent) return YES;
    }
    return NO;
}

static void dnh_patchGeneratorHierarchy(Class target) {
    if (target == Nil) return;

    SEL selectors[] = {
        @selector(impactOccurred),
        @selector(impactOccurredWithIntensity:),
        @selector(impactOccurredAtLocation:),
        @selector(impactOccurredWithIntensity:atLocation:),
        @selector(selectionChanged),
        @selector(notificationOccurred:)
    };
    const unsigned int selectorCount = (unsigned int)(sizeof(selectors) / sizeof(selectors[0]));

    int capacity = objc_getClassList(NULL, 0);
    if (capacity <= 0) return;

    Class *classes = (Class *)calloc((size_t)capacity, sizeof(Class));
    if (classes == NULL) return;

    int count = objc_getClassList(classes, capacity);
    for (int i = 0; i < count; i++) {
        Class cls = classes[i];
        if (!dnh_isSubclassOf(cls, target)) continue;

        for (unsigned int j = 0; j < selectorCount; j++) {
            Method method = class_getInstanceMethod(cls, selectors[j]);
            if (method == NULL) continue;

            const char *types = method_getTypeEncoding(method);
            // Add an override on this class (including subclasses that inherit
            // the selector), leaving unrelated methods and audio untouched.
            class_replaceMethod(cls, selectors[j], (IMP)dnh_noHaptic, types);
        }
    }

    free(classes);
}

__attribute__((constructor))
static void dnh_initialize(void) {
    @autoreleasepool {
        dispatch_async(dispatch_get_main_queue(), ^{
            dnh_patchGeneratorHierarchy([UIImpactFeedbackGenerator class]);
            dnh_patchGeneratorHierarchy([UISelectionFeedbackGenerator class]);
            dnh_patchGeneratorHierarchy([UINotificationFeedbackGenerator class]);
        });
    }
}
