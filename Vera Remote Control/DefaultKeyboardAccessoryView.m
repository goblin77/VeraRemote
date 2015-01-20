//
//  DefaultKeyboardAccessoryView.m
//  Offer Maker
//
//  Created by Dmitry Miller on 1/25/14.
//  Copyright (c) 2014 Dmitry Miller. All rights reserved.
//

#import "DefaultKeyboardAccessoryView.h"

@implementation DefaultKeyboardAccessoryView


@synthesize responder;
@synthesize secondaryButtonTapped;
@synthesize doneButtonTapped;
@synthesize nextButtonTapped;

-(id) initWithFrame:(CGRect)frame
{
    CGFloat w = [UIScreen mainScreen].bounds.size.width;
    CGFloat h = 35;
    
    if(self = [super initWithFrame:CGRectMake(0,0,w,h)])
    {
        self.barStyle = UIBarStyleDefault;
        self.secondaryButtonTapped = nil;
        self.nextButtonTapped = nil;
        self.doneButtonTapped = nil;
    }
    
    return self;
}

-(id) initWithCloseButtonAndResponder:(UIResponder *) r
{
    if(self = [self initWithFrame:CGRectZero])
    {
        self.responder = r;        
        self.items = [NSArray arrayWithObject:[self createCloseButton]];
    }
    
    return self;
}



-(id) initWithDoneButtonAndResponder:(UIResponder *)r
{
    if(self = [self initWithFrame:CGRectZero])
    {
        self.responder = r;
        
        NSMutableArray * items = [[NSMutableArray alloc] init];
        [items addObject:[self createCloseButton]];

        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil]
        ];
        
        
        [items addObject:[[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                          style:UIBarButtonItemStyleDone
                                                         target:self
                                                         action:@selector(handleDoneButtonTapped:)]];
        
        self.items = items;
    }
    
    return self;
}


-(id) initWithNextButtonAndResponder:(UIResponder *) r
{
    if(self = [self initWithFrame:CGRectZero])
    {
        self.responder = r;
        
        NSMutableArray * items = [[NSMutableArray alloc] init];
        [items addObject:[self createCloseButton]];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil]
         ];
        
        
        [items addObject:[[UIBarButtonItem alloc] initWithTitle:@"Next"
                                                          style:UIBarButtonItemStyleDone
                                                         target:self
                                                         action:@selector(handleNextButtonTapped:)]];
        
        self.items = items;
    }
    
    return self;

}


-(id) initWithCloseButtonAndResponder:(UIResponder *)r
                 secondaryButtonTitle:(NSString *) secondaryButtonTitle
{
    if(self = [self initWithFrame:CGRectZero])
    {
        self.responder = r;
        
        NSMutableArray * items = [[NSMutableArray alloc] init];
        [items addObject:[self createCloseButton]];
        
        [items addObject:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                       target:nil
                                                                       action:nil]
         ];
        
        
        [items addObject:[[UIBarButtonItem alloc] initWithTitle:secondaryButtonTitle
                                                          style:UIBarButtonItemStyleDone
                                                         target:self
                                                         action:@selector(handleSecondaryButtonTapped:)]];
        
        self.items = items;
    }
    
    return self;
}



-(UIBarButtonItem *) createCloseButton
{
    UIBarButtonItem * closeButton = [[UIBarButtonItem alloc] initWithTitle:@"Close"
                                                                     style:UIBarButtonItemStylePlain
                                                                    target:self
                                                                    action:@selector(handleCloseButtonTapped:)];
    return closeButton;
}


-(void) handleCloseButtonTapped:(id) sender
{
    [self.responder resignFirstResponder];
}

-(void) handleDoneButtonTapped:(id) sender
{
    if(self.doneButtonTapped != nil)
    {
        self.doneButtonTapped();
    }
}
-(void) handleSecondaryButtonTapped:(id) sender
{
    if(self.secondaryButtonTapped != nil)
    {
        self.secondaryButtonTapped();
    }
}

-(void) handleNextButtonTapped:(id) sender
{
    if(self.nextButtonTapped != nil)
    {
        self.nextButtonTapped();
    }
}





@end
