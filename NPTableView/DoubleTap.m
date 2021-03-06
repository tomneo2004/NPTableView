//
//  DoubleTap.m
//  NPTableView
//
//  Created by User on 19/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "DoubleTap.h"

@implementation DoubleTap{
    
    NSInteger _tappedCellIndex;
}

#pragma mark - override
- (id)initWithTableView:(NPTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        
        UITapGestureRecognizer *recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onDoubleTap:)];
        [recognizer setNumberOfTapsRequired:2];
        [recognizer setNumberOfTouchesRequired:1];
        [self addGestureRecognizer:recognizer WithDelegate:self];
    }
    
    return self;
}

- (void)onDoubleTap:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        
        _tappedCellIndex = [_tableView findCellIndexByPoint:[recognizer locationOfTouch:0 inView:_tableView.scrollView]];
        
        if([self.delegate respondsToSelector:@selector(onDoubleTapAtCellIndex:)]){
            
            [self.delegate onDoubleTapAtCellIndex:_tappedCellIndex];
        }
    }
}

@end
