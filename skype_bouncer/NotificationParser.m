//
//  NotificationParser.m
//  skype_bouncer
//
//  Created by Tanuma Shuhei on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "NotificationParser.h"

@implementation NotificationParser


-(void)setString:(NSString*)string
{
    line = string;
    array = [string componentsSeparatedByString:@" "];
}

-(Boolean)hasBody
{
    if ([[array objectAtIndex:2] compare:@"BODY"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }    
}
-(Boolean)hasChatName
{
    if ([[array objectAtIndex:2] compare:@"CHATNAME"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }        
}
-(Boolean)hasFriendlyName
{
    if ([[array objectAtIndex:2] compare:@"FRIENDLYNAME"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }        
    
}
-(Boolean)hasFriendDisplayname
{
    if ([[array objectAtIndex:2] compare:@"FROM_DISPNAME"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }
}

-(Boolean)isMessage
{
    if ([[array objectAtIndex:0] compare:@"MESSAGE"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }
}
-(Boolean)isChat
{
    if ([[array objectAtIndex:0] compare:@"CHAT"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }    
}
-(Boolean)isChats
{
    if ([[array objectAtIndex:0] compare:@"CHATS"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }    
}
-(Boolean)hasStatus
{
    if ([[array objectAtIndex:2] compare:@"STATUS"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }    
}
-(Boolean)received
{
    if ([[array objectAtIndex:3] compare:@"RECEIVED"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }    
}
-(Boolean)sent
{
    if ([[array objectAtIndex:3] compare:@"SENT"] == NSOrderedSame) {
        return true;
    } else {
        return false;
    }    
}
@end
