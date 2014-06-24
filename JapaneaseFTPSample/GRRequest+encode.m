//
//  GRRequest+encode.m
//
//  Created by Tatsuya Ogi on 2014/06/23.
//  Copyright (c) 2014年 personal. All rights reserved.
//

#import "GRRequest+encode.h"
#import <objc/runtime.h>

@implementation GRRequest(Encode)

- (NSString *)encodeString:(NSString *)string;
{
    NSString *urlEncoded = [string stringByAddingPercentEscapesUsingEncoding:NSMacOSRomanStringEncoding];
    return urlEncoded;
}

@end
