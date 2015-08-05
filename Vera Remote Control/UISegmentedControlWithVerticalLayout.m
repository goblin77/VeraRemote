//
//  UISegmentedControlWithVerticalLayout.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 7/26/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "UISegmentedControlWithVerticalLayout.h"

@implementation UISegmentedControlWithVerticalLayout

- (void)goVertical
{
    self.transform = CGAffineTransformMakeRotation(M_PI_2);
    for (UIView *segment in self.subviews)
    {
        for (UIView *segmentSubview in segment.subviews)
        {
            if([segmentSubview isKindOfClass:[UILabel class]])
            {
                ((UILabel *)segmentSubview).transform = CGAffineTransformMakeRotation(-M_PI_2);
            }
        }
    }
}

@end
