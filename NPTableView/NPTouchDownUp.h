//
//  NPTouchDown.h
//  NPTableView
//
//  Created by User on 19/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface NPTouchDownUp : UIGestureRecognizer

/**
 * The distance from touch begin to current
 */
@property (nonatomic, readonly) CGFloat moveDistance;

/**
 * Touch dead zone radius
 */
@property (nonatomic, readonly) CGFloat deadzoneRadius;

/**
 * Is this touch moved
 */
@property (nonatomic, readonly) BOOL touchChanged;

/**
 * The location of beginning touch
 */
@property (nonatomic, readonly) CGPoint touchDownLocation;

- (id)initWithTarget:(id)target action:(SEL)action view:(UIView *)view;

@end
