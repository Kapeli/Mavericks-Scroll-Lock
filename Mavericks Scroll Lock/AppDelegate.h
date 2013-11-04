//
//  AppDelegate.h
//  Mavericks Scroll Lock
//
//  Created by Bogdan Popescu on 04/11/2013.
//  Copyright (c) 2013 Kapeli. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface AppDelegate : NSObject <NSApplicationDelegate> {
    CFMachPortRef eventTap;
}

@property (assign, nonatomic) int lockStatus;
@property (assign, nonatomic) int lockCount;
@property (assign, nonatomic) int ignoreCount;

- (CFMachPortRef)eventTap;

@end

enum DHLockStatus {
    DHUnlocked,
    DHLocked,
    DHIgnored
};