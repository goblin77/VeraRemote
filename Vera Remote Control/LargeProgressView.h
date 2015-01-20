//
//  LargeProgressView.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LargeProgressView : UIView

@property (nonatomic, strong) UIView * progressArea;
@property (nonatomic, strong) UILabel * label;
@property (nonatomic, strong) UIActivityIndicatorView * spinner;

+(void) showWithTitle:(NSString *) title;
+(void) show;
+(void) hide;

@end
