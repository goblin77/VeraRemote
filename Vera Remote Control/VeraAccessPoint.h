//
//  VeraAccessPoint.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/20/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VeraAccessPoint : NSObject


@property (nonatomic, strong) NSString * localUrl;
@property (nonatomic, strong) NSString * remoteUrl;
@property (nonatomic, assign) BOOL localMode;


@end
