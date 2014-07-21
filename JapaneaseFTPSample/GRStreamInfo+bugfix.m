//
//  GRStreamInfo+bugfix.m
//
//  Created by 荻 竜也 on 2014/07/15.
//  Copyright (c) 2014年 TGL. All rights reserved.
//

#import "GRStreamInfo+bugfix.h"
#import "GRRequest.h"
#import <objc/runtime.h>

@interface GRStreamInfo()
{
    dispatch_queue_t _queue;
}
@end

@implementation GRStreamInfo(bugfix)

- (void)openRead:(GRRequest *)request
{
    if ([request.dataSource hostnameForRequest:request] == nil) {
        request.error = [[GRError alloc] init];
        request.error.errorCode = kGRFTPClientHostnameIsNil;
        [request.delegate requestFailed:request];
        [request.streamInfo close:request];
        return;
    }
    
    // a little bit of C because I was not able to make NSInputStream play nice
    CFReadStreamRef readStreamRef = CFReadStreamCreateWithFTPURL(NULL, ( __bridge CFURLRef) request.fullURL);
    CFReadStreamSetProperty(readStreamRef,
                             kCFStreamPropertyFTPAttemptPersistentConnection,
                             kCFBooleanFalse);
    
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
	CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPUsePassiveMode, request.passiveMode ? kCFBooleanTrue :kCFBooleanFalse);
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPUserName, (__bridge CFStringRef) [request.dataSource usernameForRequest:request]);
    CFReadStreamSetProperty(readStreamRef, kCFStreamPropertyFTPPassword, (__bridge CFStringRef) [request.dataSource passwordForRequest:request]);
    self.readStream = ( __bridge_transfer NSInputStream *) readStreamRef;
    
    if (self.readStream == nil) {
        request.error = [[GRError alloc] init];
        request.error.errorCode = kGRFTPClientCantOpenStream;
        [request.delegate requestFailed:request];
        [request.streamInfo close:request];
        return;
    }
    
    self.readStream.delegate = request;
	[self.readStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	[self.readStream open];
    
    request.didOpenStream = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.timeout * NSEC_PER_SEC), _queue, ^{
        if (!request.didOpenStream && request.error == nil) {
            request.error = [[GRError alloc] init];
            request.error.errorCode = kGRFTPClientStreamTimedOut;
            [request.delegate requestFailed:request];
            [request.streamInfo close:request];
        }
    });
}

- (void)openWrite:(GRRequest *)request
{
    if ([request.dataSource hostnameForRequest:request] == nil) {
        request.error = [[GRError alloc] init];
        request.error.errorCode = kGRFTPClientHostnameIsNil;
        [request.delegate requestFailed:request];
        [request.streamInfo close:request];
        return;
    }
    
    CFWriteStreamRef writeStreamRef = CFWriteStreamCreateWithFTPURL(NULL, ( __bridge CFURLRef) request.fullURL);
    CFWriteStreamSetProperty(writeStreamRef,
                             kCFStreamPropertyFTPAttemptPersistentConnection,
                             kCFBooleanFalse);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyShouldCloseNativeSocket, kCFBooleanTrue);
	CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPUsePassiveMode, request.passiveMode ? kCFBooleanTrue :kCFBooleanFalse);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPFetchResourceInfo, kCFBooleanTrue);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPUserName, (__bridge CFStringRef) [request.dataSource usernameForRequest:request]);
    CFWriteStreamSetProperty(writeStreamRef, kCFStreamPropertyFTPPassword, (__bridge CFStringRef) [request.dataSource passwordForRequest:request]);
    
    self.writeStream = ( __bridge_transfer NSOutputStream *) writeStreamRef;
    
    if (!self.writeStream) {
        request.error = [[GRError alloc] init];
        request.error.errorCode = kGRFTPClientCantOpenStream;
        [request.delegate requestFailed:request];
        [request.streamInfo close:request];
        return;
    }
    
    self.writeStream.delegate = request;
    [self.writeStream scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
    [self.writeStream open];
    
    request.didOpenStream = NO;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, self.timeout * NSEC_PER_SEC), _queue, ^{
        if (!request.didOpenStream && (request.error == nil)) {
            request.error = [[GRError alloc] init];
            request.error.errorCode = kGRFTPClientStreamTimedOut;
            [request.delegate requestFailed:request];
            [request.streamInfo close:request];
        }
    });
}
@end
