//
//  NPTouchDown.m
//  NPTableView
//
//  Created by User on 19/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "NPTouchDownUp.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation NPTouchDownUp{
    
    __weak UIView *_touchView;
    
    CGPoint beginTouchLocation;
}

@synthesize moveDistance = _moveDistance;
@synthesize deadzoneRadius = _deadzoneRadius;
@synthesize touchChanged = _touchChanged;
@synthesize touchDownLocation = _touchDownLocation;

- (id)initWithTarget:(id)target action:(SEL)action view:(UIView *)view{
    
    if(self = [super initWithTarget:target action:action]){
        
        _deadzoneRadius = 0.5f;
        _touchView = view;
    }
    
    return self;
}

- (BOOL)touchChanged{
    
    if(_moveDistance > _deadzoneRadius){
        
        return YES;
    }
    
    return NO;
}

- (CGPoint)touchDownLocation{
    
    return beginTouchLocation;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    if(self.state == UIGestureRecognizerStatePossible){
        
        beginTouchLocation = [[touches anyObject] locationInView:_touchView];
        
        self.state = UIGestureRecognizerStateBegan;
    }
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    CGPoint cTouch = [[touches anyObject] locationInView:_touchView];
    _moveDistance = sqrt(pow(cTouch.x-beginTouchLocation.x, 2)+pow(cTouch.y-beginTouchLocation.y, 2));
    
    self.state = UIGestureRecognizerStateChanged;
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.state = UIGestureRecognizerStateEnded;
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    
    self.state = UIGestureRecognizerStateCancelled;
}

- (BOOL)canBePreventedByGestureRecognizer:(UIGestureRecognizer *)preventingGestureRecognizer{
    
    //we don't want this gesture recognizer to be prevented by other gesture recognizer
    return NO;
}

- (BOOL)canPreventGestureRecognizer:(UIGestureRecognizer *)preventedGestureRecognizer{
    
    //we don't want to prevent other gesture recognizer
    return NO;
}



@end
