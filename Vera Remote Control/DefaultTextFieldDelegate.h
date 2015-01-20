//
//  DefaultTextFieldDelegate.h
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import <Foundation/Foundation.h>




@interface DefaultTextFieldDelegate : NSObject <UITextFieldDelegate>

@property (nonatomic, strong) BOOL (^textFieldShouldBeginEditing)(UITextField * textField);
@property (nonatomic, strong) void (^textFieldDidBeginEditing)(UITextField * textField);
@property (nonatomic, strong) BOOL (^textFieldShouldEndEditing)(UITextField * textField);
@property (nonatomic, strong) void (^textFieldDidEndEditing)(UITextField * textField);
@property (nonatomic, strong) BOOL (^textFieldShouldChangeCharactersInRange)(UITextField * textField, NSRange range, NSString * replacementString);
@property (nonatomic, strong) BOOL (^textFieldShouldClear)(UITextField * textField);
@property (nonatomic, strong) BOOL (^textFieldShouldReturn)(UITextField * textField);
@property (nonatomic, strong) void (^textFieldWillChangeText)(UITextField * textField);

@end
