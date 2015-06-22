//
//  TipJarSectionHeaderView.m
//  Vera Remote Control
//
//  Created by Dmitry Miller on 6/8/15.
//  Copyright (c) 2015 Dmitry Miller. All rights reserved.
//

#import "TipJarSectionHeaderView.h"
#import "StyleUtils.h"

@implementation TipJarSectionHeaderView

- (id)initWithFrame:(CGRect)frame
{
    if(self = [super initWithFrame:frame])
    {
        self.titleLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        self.titleLabel.font = [UIFont defaultFontWithSize:14];
        self.titleLabel.numberOfLines = 0;
        self.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
        self.titleLabel.textColor = [StyleUtils defaultTextColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        [self addSubview:self.titleLabel];
    }
    
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGSize textSize = [self.titleLabel sizeThatFits:CGSizeMake(self.bounds.size.width - 30, 0)];
    CGFloat x = (self.bounds.size.width - textSize.width) / 2;
    CGFloat y = (self.bounds.size.height - textSize.height) / 2;
    self.titleLabel.frame = CGRectMake(x, y, textSize.width, textSize.height);
}


@end
