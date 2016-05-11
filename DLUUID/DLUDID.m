//
//  DLUDID.m
//  DLUDID
//
//  Created by zhangdali on 16/5/5.
//  Copyright © 2016年 zhangdali. All rights reserved.
//

#import "DLUDID.h"
#import <UIKit/UIDevice.h>
#import <UIKit/UIPasteboard.h>
#import "SSKeychain.h"

#define kUDIDService @"com.dali.udid"
#define kUDIDKey @"com.dali.udid"

#define DL_IS_STR_NIL(objStr) (![objStr isKindOfClass:[NSString class]] || objStr == nil || [objStr length] <= 0)

static NSString *_udid;

@implementation DLUDID

#pragma mark - generate UUID
/**
 *  get IDFA
 *
 *  @return IDFA
 */
+ (NSString *)appleIDFA {
    NSString *idfa = nil;
    Class ASIdentifierManagerClass = NSClassFromString(@"ASIdentifierManager");
    if (ASIdentifierManagerClass) { // a dynamic way of checking if AdSupport.framework is available
        SEL sharedManagerSelector = NSSelectorFromString(@"sharedManager");
        id sharedManager = ((id (*)(id, SEL))[ASIdentifierManagerClass methodForSelector:sharedManagerSelector])(ASIdentifierManagerClass, sharedManagerSelector);
        SEL advertisingIdentifierSelector = NSSelectorFromString(@"advertisingIdentifier");
        NSUUID *advertisingIdentifier = ((NSUUID* (*)(id, SEL))[sharedManager methodForSelector:advertisingIdentifierSelector])(sharedManager, advertisingIdentifierSelector);
        idfa = [advertisingIdentifier UUIDString];
    }
    return idfa;
}

/**
 *  get IDFV
 *
 *  @return IDFV
 */
+ (NSString *)appleIDFV {
    if(NSClassFromString(@"UIDevice") && [UIDevice instancesRespondToSelector:@selector(identifierForVendor)]) {
        // only available in iOS >= 6.0
        return [[UIDevice currentDevice].identifierForVendor UUIDString];
    }
    return nil;
}

/**
 *  get UDID
 *
 *  @return UDID
 */
+ (NSString *)randomUDID {
    if(NSClassFromString(@"NSUUID")) { // only available in iOS >= 6.0
        return [[NSUUID UUID] UUIDString];
    }
    CFUUIDRef uuidRef = CFUUIDCreate(kCFAllocatorDefault);
    CFStringRef cfuuid = CFUUIDCreateString(kCFAllocatorDefault, uuidRef);
    CFRelease(uuidRef);
    NSString *uuid = [((__bridge NSString *) cfuuid) copy];
    CFRelease(cfuuid);
    return uuid;
}

#pragma mark - keychain

/**
 *  get UDID in keychain
 *
 *  @return UDID
 */
+ (NSString *)UDIDInKeychain {
    return [SSKeychain passwordForService:kUDIDService account:kUDIDKey];
}

/**
 *  save UDID to keychain
 *
 *  @param udid
 */
+ (void)saveUDIDToKeychain:(NSString *)udid {
    [SSKeychain setPassword:udid forService:kUDIDService account:kUDIDKey];
}

#pragma mark - UIPasteboard
/**
 *  get UDID in pasteboard
 *
 *  @return UDID
 */
+ (NSString *)UDIDInPasteboard {
    UIPasteboard *pb = [UIPasteboard pasteboardWithName:kUDIDService create:NO];
    if (!pb) {
        return nil;
    }
    return [pb valueForPasteboardType:kUDIDKey];
}

/**
 *  save UDID to pasteboard
 *
 *  @param udid
 */
+ (void)saveUDIDToPasteboard:(NSString *)udid {
    UIPasteboard *pb = [UIPasteboard pasteboardWithName:kUDIDService create:YES];
    [pb setPersistent:YES];
    [pb setValue:udid forPasteboardType:kUDIDKey];
}

#pragma mark - NSUserDefaults
/**
 *  get UDID in NSUserDefaults
 *
 *  @return UDID
 */
+ (NSString *)UDIDInUserDefaults {
    return [[NSUserDefaults standardUserDefaults] objectForKey:kUDIDKey];
}

/**
 *  save UDID to NSUserDefaults
 *
 *  @param udid
 */
+ (void)saveUDIDToUserDefaults:(NSString *)udid {
    [[NSUserDefaults standardUserDefaults] setObject:udid forKey:kUDIDKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

/**
 *  save UDID to cache: keychain, pasteboard, userDefaults
 */
+ (void)save:(NSString *)udid {
    if (DL_IS_STR_NIL(udid))
    {
        return;
    }
    [[self class] saveUDIDToKeychain:udid];
    [[self class] saveUDIDToPasteboard:udid];
    [[self class] saveUDIDToUserDefaults:udid];
}

/**
 *  get UDID
 *
 *  @return UDID
 */
+ (NSString *)value {
    // get exists value
    if (DL_IS_STR_NIL(_udid)) _udid = [[self class] UDIDInKeychain];
    if (DL_IS_STR_NIL(_udid)) _udid = [[self class] UDIDInPasteboard];
    if (DL_IS_STR_NIL(_udid)) _udid = [[self class] UDIDInUserDefaults];
    // generate new value
    if (DL_IS_STR_NIL(_udid)) _udid = [[self class] appleIDFA];
    if (DL_IS_STR_NIL(_udid)) _udid = [[self class] appleIDFV];
    if (DL_IS_STR_NIL(_udid)) _udid = [[self class] randomUDID];
    [[self class] save:_udid];
    return _udid;
}

@end
