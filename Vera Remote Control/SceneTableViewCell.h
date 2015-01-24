//
//  SceneTableViewCell.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/23/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ControlledDevice.h"
#import "CircularShapeView.h"

@interface SceneTableViewCell : UITableViewCell

@property (nonatomic, strong) CircularShapeView * statusView;
@property (nonatomic, strong) UIActivityIndicatorView * progressView;
@property (nonatomic, strong) UILabel * nameLabel;
@property (nonatomic, strong) UIButton * goButton;


@property (nonatomic, strong) Scene * scene;
@property (nonatomic, copy) void (^didLaunchScene)(SceneTableViewCell * cell);

@end
