//
//  ChatRoomManager.m
//  skype_bouncer
//
//  Created by Tanuma Shuhei on 12/04/17.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "ChatRoomManager.h"
static id _instance = nil;


@implementation ChatRoomManager

-(id)init
{
    if (self = [super init]) {
        _instance = self;
        rooms = [[NSMutableDictionary alloc] init];
    }
    return self;
}

+(id)sharedInstnace
{
    @synchronized(self) {
        if (!_instance) {
            [[self alloc] init];
        }
    }
    return _instance;
}

-(Boolean)hasRegistered:(NSString *)name
{
    if ([rooms objectForKey:name]) {
        return true;
    } else {
        return false;
    }
}
-(void)addRoom:(NSString *)id roomName:(NSString *)roomName
{
    [rooms setObject:roomName forKey:id];
}
@end
