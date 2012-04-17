//
//  AppDelegate.m
//  skype_bouncer
//
//  Created by Tanuma Shuhei on 12/04/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import <Skype/Skype.h>
#import "uv.h"
#import "MessageManager.h"
#import "NotificationParser.h"
#import "ChatRoomManager.h"

extern uv_tcp_t in_socket;

static void _close_cb(uv_handle_t* handle)
{
    NSLog(@"Uv Close callback");
}

static void _write_cb(uv_write_t *req, int status)
{
    NSLog(@"Write status: %d", status);
    if (status == 0) {
//        uv_close(, _close_cb);
    }
    free(req);
}

@interface Skype2Controller : NSObject <SkypeAPIDelegate>
{
}
@end

@implementation Skype2Controller

- (id)init
{
    if(self = [super init]){
        NSLog(@"Initialized");
    }

    return self;
}

- (NSString *)clientApplicationName
{
	NSLog(@"applicationName");
	return @"Chobie";
}

- (void)skypeNotificationReceived:(NSString*)aNotificationString
{
    MessageManager *manager = (MessageManager*)[MessageManager sharedInstnace];
    ChatRoomManager *cmanager = (ChatRoomManager*)[ChatRoomManager sharedInstnace];

	NSLog(@"LOG: %@",aNotificationString);
    
    /* debug log */
//    NSArray *debug_list = [aNotificationString componentsSeparatedByString:@"\n"];
//    for(NSString *im in debug_list) {
//        uv_write_t *req = (uv_write_t *)malloc(sizeof(*req));
//        uv_buf_t *buf = (uv_buf_t *)malloc(sizeof(uv_buf_t)*1);
//        NSString *msg = [NSString stringWithFormat:@"PRIVMSG #debug :%@\n", im];
//        NSLog(@"DB: %@", msg);
//        buf[0] = uv_buf_init([msg UTF8String],strlen([msg UTF8String]));
//        uv_write(req, (uv_stream_t*)&in_socket, buf, 1, _write_cb);
//    }
//    [debug_list release];
    /* debug log end */
    
    NotificationParser *parser = [[NotificationParser alloc] init];
    [parser setString:aNotificationString];
	NSArray *array = [aNotificationString componentsSeparatedByString:@" "];
    
    
    NSString *hoge;
    
    if ([array count] > 3) {
        int i =0;
        NSMutableArray *tmp = [[NSMutableArray alloc] init];
        for(i = 3; i < [array count];i++) {
            [tmp addObject:[array objectAtIndex:i]];
        }
        hoge = [tmp componentsJoinedByString:@" "];
    }
    
    if ([parser isMessage]) {
        if ([parser received] || [parser sent]) {
            /* message received: obtain message info and chat name */
            
            NSString* command = [[NSString alloc] initWithFormat:@"GET CHATMESSAGE %@ BODY", [array objectAtIndex:1]];
            [SkypeAPI sendSkypeCommand:command];
            [command release];
            
            NSString* command2 = [[NSString alloc] initWithFormat:@"GET CHATMESSAGE %@ FROM_DISPNAME", [array objectAtIndex:1]];
            [SkypeAPI sendSkypeCommand:command2];

            [SkypeAPI sendSkypeCommand:[[NSString alloc] initWithFormat:@"GET CHATMESSAGE %@ CHATNAME",[array objectAtIndex:1]]];

            [command2 release];
        } else if ([parser hasBody]) {
            NSLog(@"###has body");
            
            [manager addProperty:[array objectAtIndex:1] property:@"BODY" value:hoge];
        } else if ([parser hasFriendDisplayname]) {
            NSLog(@"###has display name %@", [array objectAtIndex:3]);
            
            [manager addProperty:[array objectAtIndex:1] property:@"FRIEND_DISPLAYNAME" value:hoge];
        } else if ([parser hasChatName]) {
            NSLog(@"###has chat name");
            
            [manager addProperty:[array objectAtIndex:1] property:@"CHATNAME" value:hoge];

            NSString* command3 = [[NSString alloc] initWithFormat:@"GET CHAT %@ FRIENDLYNAME", hoge];
            [SkypeAPI sendSkypeCommand:command3];
            [command3 release];
        }
        
    } else if ([parser isChat]) {
        if ([parser hasFriendlyName]) {
            NSLog(@"friendly name: %@", hoge);
            [manager addProperty:[array objectAtIndex:1] property:@"FRIENDLYNAME" value:hoge];
            
            if (![cmanager hasRegistered:[hoge stringByReplacingOccurrencesOfString:@" " withString:@"_"]]) {
                [cmanager addRoom:[hoge stringByReplacingOccurrencesOfString:@" " withString:@"_"] roomName:@""];

                uv_write_t *req  = (uv_write_t *)malloc(sizeof(*req));
                uv_buf_t *buf    = (uv_buf_t*)malloc(sizeof(uv_buf_t)*2);
                NSString *join   = [NSString stringWithFormat:@"join #%@\n", [hoge stringByReplacingOccurrencesOfString:@" " withString:@"_"]];
                NSString *invite = [NSString stringWithFormat:@"INVITE %@ #%@\n", @"chobie",[hoge stringByReplacingOccurrencesOfString:@" " withString:@"_"]];

                buf[0] = uv_buf_init((const char*)[join UTF8String], (int)[join length]);
                buf[1] = uv_buf_init((const char*)[invite UTF8String], (int)[invite length]);
                NSLog(@"join : %@", join);
                uv_write(req, (uv_stream_t*)&in_socket, buf, 2, _write_cb);
                [NSThread sleepForTimeInterval:1];
//                [join release];
//                [invite release];
            }
        }
    } else if ([parser isChats]) {

        for (NSString *item in array) {
            NSString *tmp = [[NSString alloc] initWithFormat:@"GET CHAT %@ FRIENDLYNAME", [item substringToIndex:[item length]-1]];
            NSLog(@"log %@", tmp);
            [SkypeAPI sendSkypeCommand:tmp];
            [tmp release];
        }
    }
    
    [parser release];
}

- (void)skypeBecomeAvailable: (NSNotification*)aNotification
{
	NSLog(@"Skype became available");
    
}

- (void)skypeAttachResponse:(unsigned)aAttachResponseCode
{
	switch (aAttachResponseCode)
	{
		case 0:
			fprintf(stderr,"Failed to connect\n");
			break;
		case 1:
			/* OK */
            [SkypeAPI sendSkypeCommand:@"SEARCH CHATS"];
			break;
		default:
			fprintf(stderr,"Failed to connect\n");
			break;
	}
	
}
@end

/* ここまで */

@implementation AppDelegate

@synthesize window = _window;

- (void)dealloc
{
    [SkypeAPI disconnect];
    [super dealloc];
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
	Skype2Controller *skype = [[Skype2Controller alloc] init];
	[SkypeAPI setSkypeDelegate:skype];
	
    
    if ([SkypeAPI isSkypeRunning]) {
        NSLog(@"Skype is runninn");
    }
    if ([SkypeAPI isSkypeAvailable]) {
        NSLog(@"Skype is available");
    }

    [SkypeAPI connect];
    
//    [SkypeAPI sendSkypeCommand:@"SET PROFILE MOOD_TEXT HELLO"];
    

    // Insert code here to initialize your application
}

@end
