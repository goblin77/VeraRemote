//
//  RecordButton.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 5/10/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface RecordButton : UIView

@property (nonatomic, assign) BOOL isOn;
@property (nonatomic, copy) void (^didTap)(RecordButton * button);

@end
