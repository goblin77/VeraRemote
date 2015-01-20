//
//  TableViewCellWithTextFieldCell.h
//  Time Tracker
//
//  Created by Dmitry Miller on 11/26/12.
//  Copyright (c) 2012 Dmitry Miller. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCellWithTextField : UITableViewCell
{
    UITableViewCellStyle cellStyle;
}


@property (nonatomic, strong) UITextField * textField;

//for UITableViewStyleValue2
@property (nonatomic, assign) CGFloat leftColumnWidth;



- (id)initWithReuseIdentifier:(NSString *)reuseIdentifier;


@end
