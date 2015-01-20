//
//  DefaultKeyboardAccessoryView.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DefaultKeyboardAccessoryView : UIToolbar

@property (nonatomic, weak) UIResponder * responder;
@property (nonatomic, copy) void (^secondaryButtonTapped)(void);
@property (nonatomic, copy) void (^doneButtonTapped)(void);
@property (nonatomic, copy) void (^nextButtonTapped)(void);


-(id) initWithCloseButtonAndResponder:(UIResponder *) responder;
-(id) initWithCloseButtonAndResponder:(UIResponder *)responder
                 secondaryButtonTitle:(NSString *) secondaryButtonTitle;

-(id) initWithDoneButtonAndResponder:(UIResponder *) responder;
-(id) initWithNextButtonAndResponder:(UIResponder *) responder;


@end
