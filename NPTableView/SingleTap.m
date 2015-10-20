//
//  Tap.m
//  NPTableView
//
//  Created by User on 19/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "SingleTap.h"

@implementation SingleTap{
    
    NSInteger _tappedCellIndex;
    
    BOOL _onHold;
}

#pragma mark - override
- (id)initWithTableView:(NPTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        
        UITapGestureRecognizer *recoginzer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(onTap:)];
        [recoginzer setNumberOfTapsRequired:1];
        [self addGestureRecognizer:recoginzer WithDelegate:self];
    }
    
    return self;
}


#pragma mark - internal
- (void)onTap:(UITapGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
     
        _tappedCellIndex = [_tableView findCellIndexByPoint:[recognizer locationOfTouch:0 inView:_tableView.scrollView]];
        
        if([self.delegate respondsToSelector:@selector(onSingleTapAtCellIndex:)]){
            
            [self.delegate onSingleTapAtCellIndex:_tappedCellIndex];
        }
         
    }
}


@end
