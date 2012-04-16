//
//  MessageManager.m
//  skype_bouncer
//
//  Created by Tanuma Shuhei on 12/04/15.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "MessageManager.h"
#import "uv.h"

extern uv_tcp_t in_socket;

static id _instance = nil;

static void write_cb(uv_write_t *req, int status)
{
    NSLog(@"Write2 status; %d", status);
    free(req);
}


@implementation MessageManager

-(id)init
{
    if (self = [super init]) {
        _instance = self;
        dict = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(void)addProperty:(NSString*)key property:(NSString *)property value:(NSString *)value
{
    NSMutableDictionary *a;
    
    NSLog(@"add property for key: %@", key);
    
        if((a = [dict objectForKey:key]) == NULL) {
            NSMutableDictionary *box = [[NSMutableDictionary alloc] init];
            [box setObject:value forKey:property];
            [dict setObject:box forKey:key];
            NSLog(@"create");
        } else {
            [a setObject:value forKey:property];
            [dict setObject:a forKey:key];
            NSLog(@"add %@", a);
            
            if ([a count] >= 3) {
                NSLog(@"################# EMIT MESSAGE ####################");
                
                NSArray *array = [[a objectForKey:@"BODY"] componentsSeparatedByString:@"\n"];
                
                for (NSString *body in array) {
                    NSMutableDictionary *chat = [dict objectForKey:[a objectForKey:@"CHATNAME"]];
                    uv_write_t *req = (uv_write_t *)malloc(sizeof(*req));
                    uv_buf_t buf[1];
                    NSLog(@"body : %@", body);
                    NSString *msg = [NSString stringWithFormat:@"PRIVMSG #bridge :%@@%@> %@\n", 
                                     [a objectForKey:@"FRIEND_DISPLAYNAME"],
                                     [chat objectForKey:@"FRIENDLYNAME"],
                                     body];
                    NSLog(@"PRIV: %@", msg);
                    
                    buf[0] = uv_buf_init([msg UTF8String],strlen([msg UTF8String]));
                    uv_write(req, (uv_stream_t*)&in_socket, buf, 1, write_cb);
                }
            }
    }
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

@end
