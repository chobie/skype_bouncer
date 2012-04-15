//
//  main.m
//  skype_bouncer
//
//  Created by Tanuma Shuhei on 12/04/14.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "uv.h"
#import "pthread.h"

uv_tcp_t in_socket;

static pthread_t thread;

static void irc_write_cb(uv_write_t *req, int status)
{
    NSLog(@"Write");
    free(req);
}

static void irc_read_cb(uv_stream_t *tcp, ssize_t nread, uv_buf_t buf)
{
    NSLog(@"READ:%s", buf.base);
    if (strstr(buf.base, "PING") != NULL) {
        uv_write_t *req = (uv_write_t *)malloc(sizeof(*req));
        uv_buf_t buf[1];
        buf[0] = uv_buf_init("PONG\n",strlen("PONG\n"));    
        uv_write(req, tcp, buf, 1, irc_write_cb);
        NSLog(@"Pong");
        
    }
}

static uv_buf_t irc_alloc_cb(uv_handle_t *handle, size_t size)
{
    NSLog(@"Alloc");
    uv_buf_t buf;
    buf.base = (char*)malloc(size);
    buf.len = size;
    
    return buf;
}
///int uv_read_start(uv_stream_t* stream, uv_alloc_cb alloc_cb,
//                   uv_read_cb read_cb) {
static void irc_connect_cb(uv_connect_t *conn_req, int status)
{
    NSLog(@"Connect:%d", status);

    if (status == 0) {
        uv_write_t *req = (uv_write_t *)malloc(sizeof(*req));
        uv_buf_t buf[4];
        buf[0] = uv_buf_init("NICK CHOBOT\n",strlen("NICK CHOBOT\n"));    
        buf[1] = uv_buf_init("USER CHOBOT h s :CHOBOT\n",strlen("USER CHOBOT h s :CHOBOT\n"));
        buf[2] = uv_buf_init("join #bridge\n",strlen("join #bridge\n"));
        buf[3] = uv_buf_init("join #debug\n",strlen("join #debug\n"));
        uv_write(req, conn_req->handle, buf, 4, irc_write_cb);

        //PRIVMSG #bridge :Hoe

        if(uv_read_start(conn_req->handle,irc_alloc_cb, irc_read_cb)) {
            NSLog(@"uv_read_start failed");
        }
    } else {
        exit(-1);
    }
}

static void run_ircd()
{
    uv_run(uv_default_loop());
}

int main(int argc, char *argv[])
{
    uv_connect_t connect;
    struct sockaddr_in addr = uv_ip4_addr("127.0.0.1",6667); 
    uv_tcp_init(uv_default_loop(),&in_socket);
    uv_tcp_connect(&connect, &in_socket, addr,irc_connect_cb);
    pthread_create(&thread,NULL, (void*)run_ircd,NULL);
    NSLog(@"default_loop");
    //uv_run(uv_default_loop());
    NSLog(@"default_loop");
    
    return NSApplicationMain(argc, (const char **)argv);
}
