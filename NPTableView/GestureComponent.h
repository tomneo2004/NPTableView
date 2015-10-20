//
//  GestureComponent.h
//  NPTableView
//
//  Created by User on 16/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NPTableCellView.h"

@interface GestureComponent : NSObject<UIGestureRecognizerDelegate, UIScrollViewDelegate>{
    
    @protected
    NPTableView *_tableView;
    UIGestureRecognizer *_gestureRecognizer;
}

/**
 * Gesture component's priority
 * The lower priority value the higher priority it is
 * Higher priority receive event earlier when tableView gesture happen
 */
@property (getter=getPriority, readonly, nonatomic) NSInteger priority;

/**
 * UIGestureRecognizer that is used in this gesture component
 */
@property (getter=getGestureRecognizer, readonly, nonatomic) UIGestureRecognizer *gestureRecognizer;

/**
 * Assign delegate to receive gesture component event
 */
@property (weak, nonatomic) id delegate;

/**
 * Create gesture component
 * The lower priority value the higher priority it is
 */
- (id)initWithTableView:(NPTableView *)tableView WithPriority:(NSInteger)priority;

/**
 * Add a gesture recognizer to tableview
 */
- (void)addGestureRecognizer:(UIGestureRecognizer *)gestureRecognizer WithDelegate:(id<UIGestureRecognizerDelegate>)delegate;

/**
 * Same as "requireGestureRecognizerToFail" but use GestureComponent
 */
- (void)requireGestureComponentToFail:(GestureComponent *)component;

@end
