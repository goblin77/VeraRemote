//
//  DefaultTextFieldDelegate.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "DefaultTextFieldDelegate.h"

@implementation DefaultTextFieldDelegate

#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if(self.textFieldShouldBeginEditing != nil)
    {
        return self.textFieldShouldBeginEditing(textField);
    }
    
    return YES;
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if(self.textFieldDidBeginEditing != nil)
    {
        self.textFieldDidBeginEditing(textField);
    }
}


- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    if(self.textFieldShouldEndEditing != nil)
    {
        return self.textFieldShouldEndEditing(textField);
    }
    
    return YES;
}


- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if(self.textFieldDidEndEditing != nil)
    {
        self.textFieldDidEndEditing(textField);
    }
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    BOOL res = YES;
    if(self.textFieldShouldChangeCharactersInRange != nil)
    {
        res = self.textFieldShouldChangeCharactersInRange(textField, range, string);
    }
    
    if(res && self.textFieldWillChangeText != nil)
    {
        self.textFieldWillChangeText(textField);
    }
        
    
    return res;
}

- (BOOL)textFieldShouldClear:(UITextField *)textField
{
    BOOL res = YES;
    if(self.textFieldShouldClear != nil)
    {
        res = self.textFieldShouldClear(textField);
    }
    
    if(res && self.textFieldWillChangeText != nil)
    {
        self.textFieldWillChangeText(textField);
    }

    
    return res;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if(self.textFieldShouldReturn != nil)
    {
        return self.textFieldShouldReturn(textField);
    }
    else
    {
        [textField resignFirstResponder];
    }
    
    return YES;
}


@end
