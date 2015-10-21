//
//  LongPress.m
//  NPTableView
//
//  Created by User on 21/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "LongPress.h"

@implementation LongPress{
    
    NSInteger _pressedCellIndex;
}

#pragma mark - override
- (id)initWithTableView:(NPTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        UILongPressGestureRecognizer *recognizer = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(onLongPress:)];
        [self addGestureRecognizer:recognizer WithDelegate:self];
    }
    
    return self;
}

- (void)onLongPress:(UILongPressGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
        _pressedCellIndex = [_tableView findCellIndexByPoint:[recognizer locationOfTouch:0 inView:_tableView.scrollView]];
        
        if([self.delegate respondsToSelector:@selector(onLongPressAtCellIndex:)]){
            
            [self.delegate onLongPressAtCellIndex:_pressedCellIndex];
        }
    }
}

@end
