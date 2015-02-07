//
//  SceneTableViewCell.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 1/23/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "SceneTableViewCell.h"
#import "Buttons.h"
#import "StyleUtils.h"
#import "ObserverUtils.h"


@interface SceneTableViewCell ()
{
    BOOL dataChanged;
    CGSize oldSize;
}

@end

@implementation SceneTableViewCell

-(id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    if(self = [super initWithStyle:UITableViewCellStyleDefault reuseIdentifier:reuseIdentifier])
    {
        self.statusView = [[CircularShapeView alloc] initWithFrame:CGRectMake(0, 0, 15, 15)];
        self.statusView.fillColor = [UIColor redColor];
        self.statusView.strokeColor = [UIColor blackColor];
        self.statusView.hidden = YES;
        [self.contentView addSubview:self.statusView];
        
        self.progressView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectZero];
        self.progressView.color = [UIColor blueColor];
        [self.progressView sizeToFit];
        self.progressView.hidden = YES;
        [self.contentView addSubview:self.progressView];
        
        
        self.nameLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        [StyleUtils applyDefaultStyleOnTableTitleLabel:self.nameLabel];
        [self.contentView addSubview:self.nameLabel];
        
        self.goButton = [Buttons buttonWithTitle:@"Run"
                                      titleColor:[UIColor blackColor]
                                 backgroundColor:[UIColor colorWithRGBHex:0xf0f0f0]
                                            size:CGSizeMake(60, 40)
                                    cornerRadius:5];
        [self.goButton setTitleColor:[UIColor lightGrayColor] forState:UIControlStateDisabled];
        [self.goButton addTarget:self action:@selector(handleGoButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.contentView addSubview:self.goButton];
        
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        
        
        oldSize = self.bounds.size;
        dataChanged = NO;
        
        [ObserverUtils addObserver:self toObject:self forKeyPaths:[self observerPaths] withOptions:NSKeyValueObservingOptionInitial | NSKeyValueObservingOptionNew];
    }
    
    return self;
}


-(void) dealloc
{
    [ObserverUtils removeObserver:self fromObject:self forKeyPaths:[self observerPaths]];
}


-(void) layoutSubviews
{
    [super layoutSubviews];
    
    
    static CGFloat columnGap = 3;
    static CGFloat rightMargin = 10;
    
    if(!CGSizeEqualToSize(oldSize, self.bounds.size))
    {
        CGFloat contentWidth = self.contentView.bounds.size.width;
        
        // status and progress column
        CGFloat columnWidth  = 26;
        CGFloat x = (columnWidth - self.statusView.bounds.size.width) / 2;
        CGFloat y = (self.contentView.bounds.size.height - self.statusView.bounds.size.height) / 2;
        
        self.statusView.frame = CGRectOffset(self.statusView.bounds, x, y);
        
        x = (columnWidth - self.progressView.bounds.size.width) / 2;
        y = (self.contentView.bounds.size.height - self.progressView.bounds.size.height) / 2;
        self.progressView.frame = CGRectOffset(self.progressView.bounds, x, y);
        
        
        // device name
        
        x += columnWidth;
        columnWidth = contentWidth - x - rightMargin - self.goButton.bounds.size.width;
        y = (self.contentView.bounds.size.height - self.nameLabel.font.lineHeightPx) / 2;
        
        self.nameLabel.frame = CGRectMake(x, y, columnWidth - columnGap, self.nameLabel.font.lineHeightPx);
        x += columnWidth;
        
        y = (self.contentView.bounds.size.height - self.goButton.bounds.size.height)/2;
        self.goButton.frame = CGRectOffset(self.goButton.bounds, x, y);
        
        oldSize = self.contentView.bounds.size;
    }
    
    
    if(dataChanged)
    {
        BOOL busy = self.scene.manualOverride || self.scene.state == DeviceStateBusy;
        if(busy)
        {
            self.statusView.hidden = YES;
            self.progressView.hidden = NO;
            [self.progressView startAnimating];
        }
        else
        {
            if(self.scene.active || self.scene.state == DeviceStateError)
            {
                self.statusView.hidden = NO;
                self.statusView.fillColor = self.scene.state == DeviceStateError ?  [UIColor redColor] : [UIColor colorWithRGBHex:0x85d966];
            }
            else
            {
                self.statusView.hidden = YES;
            }
            self.progressView.hidden = YES;
            [self.progressView stopAnimating];
        }
        
        self.nameLabel.text = self.scene.name;
        self.goButton.enabled = !busy;
        
        dataChanged = NO;
    }
    
}

#pragma mark -
#pragma mark events 
-(void)handleGoButtonTapped:(id) sender
{
    if(self.didLaunchScene != nil)
    {
        self.didLaunchScene(self);
    }
}

#pragma mark -
#pragma mark KVO
-(void) observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    dataChanged = YES;
    [self setNeedsLayout];
}


-(NSArray *) observerPaths
{
    static NSArray * paths = nil;
    if(paths == nil)
    {
        paths = @[@"scene.active",@"scene.name",@"scene.state",@"scene.manualOverride"];
    }
    
    return paths;
}



@end
