//
//  TestSpinningCursor.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SpinningCursorView : UIView


@property (nonatomic, strong) UIColor * spinnerColor;
@property (nonatomic, readonly) BOOL animating;
@property (nonatomic, assign)   double speed; // rotations per second
-(void) startAnimation;
-(void) stopAnimation;

@end
