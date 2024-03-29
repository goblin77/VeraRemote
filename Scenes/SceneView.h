//
//  SceneView.h
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/25/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpinningCursorView.h"
#import "ControlledDevice.h"

@interface SceneView : UIView

@property (nonatomic, strong) Scene * scene;
@property (nonatomic, copy)   void (^didSelectScene)(SceneView * sceneView);

@end
