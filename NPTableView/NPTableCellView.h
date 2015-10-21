//
//  NPTableCellController.h
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "NPTableView.h"

@interface NPTableCellView : UIView

/**
 * If nil build in highlight animation will not be performed
 */
@property (assign, nonatomic)  UIView *selectBackgroundView;

/**
 * Create a cell
 * You can first create and design cell in xib file.
 * Then you can use this method and give xib file name to create cell
 */
+ (id)cellWithNibName:(NSString *)nibName;

/**
 * Create a cell
 * You can first create and design cell in xib file.
 * Then you can use this method and give xib file name to create cell
 */
- (id)initWithNibName:(NSString *)nibName;

/**
 * Set this cell select
 * If override this method make sure you call [super setSelect:(BOOL)selected]
 * if not calling super then you will not receive method "setHighlight"
 */
- (void)setSelect:(BOOL)selected;

/**
 * Set this cell highlight
 * If override this method make sure you call [super setSelect:(BOOL)selected]
 * if not calling super then you will need to manage your own highligh animation
 */
- (void)setHighlight:(BOOL)highlighted;

/**
 * Call when this cell about to be recycled
 * This at this point cell's view is still attached to it's superview
 */
- (void)willRecycle;

/**
 * Call when this cell did recycle
 */
- (void)didRecycle;

@end
