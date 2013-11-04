//
//  AppDelegate.m
//  Mavericks Scroll Lock
//
//  Created by Bogdan Popescu on 04/11/2013.
//  Copyright (c) 2013 Kapeli. All rights reserved.
//

#import "AppDelegate.h"


static CGEventRef TapCallback(CGEventTapProxy proxy, CGEventType event_type, CGEventRef event, void *info)
{
    AppDelegate *manager = (__bridge AppDelegate *)(info);
    if(event_type == kCGEventScrollWheel)
    {
        int64_t phase = CGEventGetIntegerValueField(event, kCGScrollWheelEventScrollPhase);
        if(phase == kCGScrollPhaseEnded)
        {
            manager.lockStatus = DHUnlocked;
        }
        else if(manager.lockStatus != DHIgnored)
        {
            if(manager.lockStatus == DHLocked)
            {
                CGEventSetDoubleValueField(event, kCGScrollWheelEventDeltaAxis2, 0.0);
            }
            else
            {
                if(CGEventGetDoubleValueField(event, kCGScrollWheelEventDeltaAxis1) != 0.0) // deltaY
                {
                    manager.lockStatus = DHLocked;
                }
                else if(CGEventGetDoubleValueField(event, kCGScrollWheelEventDeltaAxis2) != 0.0) // deltaX
                {
                    manager.lockStatus = DHIgnored;
                }
            }
        }
    }
    else if(event_type == kCGEventTapDisabledByTimeout || event_type == kCGEventTapDisabledByUserInput)
    {
        CGEventTapEnable([manager eventTap], true);
        return NULL;
    }
    return event;
}

@implementation AppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    CFMutableDictionaryRef options = CFDictionaryCreateMutable(NULL, 0, &kCFTypeDictionaryKeyCallBacks, &kCFTypeDictionaryValueCallBacks);
    CFDictionarySetValue(options, @"AXTrustedCheckOptionPrompt", kCFBooleanTrue);
    if(!AXIsProcessTrustedWithOptions(options))
    {
        [[NSAlert alertWithMessageText:@"Enable Accessibility" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@"You need to enable Accessibility support. Go to System Preferences > Security & Privacy > Privacy > Accessibility > Enable Mavericks Scroll Lock.app. When you're done, relaunch the app."] runModal];
        [NSApp forceTerminate];
    }
    CFRelease(options);
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    if(![defaults boolForKey:@"welcomeSuppressed"])
    {
        NSAlert *alert = [NSAlert alertWithMessageText:@"Welcome!" defaultButton:@"Okay" alternateButton:nil otherButton:nil informativeTextWithFormat:@"Two important things:\n\n1. You might want to add this app to your start at login list (in System Preferences > Users & Groups > Login Items)\n2. This app runs in the background (there's absolutely no interface). If you want to quit it, you can do so using Activity Monitor"];
        [alert setShowsSuppressionButton:YES];
        [alert runModal];
        if([[alert suppressionButton] state] == NSOnState)
        {
            [defaults setBool:YES forKey:@"welcomeSuppressed"];
        }
    }
    
    CGEventMask eventMask = CGEventMaskBit(kCGEventScrollWheel);
    CFRunLoopSourceRef runLoopSource = nil;
    eventTap = CGEventTapCreate(kCGHIDEventTap, kCGHeadInsertEventTap, kCGEventTapOptionDefault, eventMask, TapCallback, (__bridge void *)(self));
    runLoopSource = CFMachPortCreateRunLoopSource(NULL, eventTap, 0);
    CFRunLoopAddSource([[NSRunLoop currentRunLoop] getCFRunLoop], runLoopSource, kCFRunLoopCommonModes);
    CGEventTapEnable(eventTap, false);
}

- (CFMachPortRef)eventTap
{
    return eventTap;
}

@end
