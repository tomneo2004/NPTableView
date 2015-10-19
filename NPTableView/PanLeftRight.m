//
//  PanToDeleteComplete.m
//  NPTableView
//
//  Created by User on 16/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "PanLeftRight.h"


@implementation PanLeftRight{
 
    //cell we are going to work on
    __weak NPTableCellView *_tempCell;
    
    NSInteger _cellIndex;
    
    //cell original center
    CGPoint _cellOriginalCenter;
    
    //true if pan left happen
    BOOL _leftOnDragRelease;
    
    //true if pan right happen
    BOOL _rightOnDragRelease;
}

@synthesize panLeftSnapBackAnim = _panLeftSnapBackAnim;
@synthesize panRightSnapBackAnim = _panRightSnapBackAnim;

#pragma mark - ovrride
- (id)initWithTableView:(NPTableView *)tableView WithPriority:(NSInteger)priority{
    
    if(self = [super initWithTableView:tableView WithPriority:priority]){
        
        _panLeftSnapBackAnim = NO;
        _panRightSnapBackAnim = NO;
        
        UIGestureRecognizer *recoginzer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(onPan:)];
        [self addGestureRecognizer:recoginzer WithDelegate:self];
    }
    
    return self;
}

- (BOOL)gestureRecognizerShouldBegin:(UIPanGestureRecognizer *)gestureRecognizer{
    
    //we only want gesture to happen when user move more on horizontal than vertical
    CGPoint translate = [gestureRecognizer translationInView:_tableView.scrollView];
    
    if(fabs(translate.x) > fabs(translate.y))
        return YES;
    else
        return NO;
}

#pragma mark - internal
- (void)onPan:(UIPanGestureRecognizer *)recognizer{
    
    if(recognizer.state == UIGestureRecognizerStateBegan){
        
        CGPoint touchPoint = [recognizer locationOfTouch:0 inView:_tableView.scrollView];
        
        //find which we are going to work on
        _tempCell = [_tableView findCellByPoint:touchPoint];
        
        //get index of cell
        _cellIndex = [_tableView findCellIndexByPoint:touchPoint];

        //store cell's original center
        _cellOriginalCenter = _tempCell.center;
    }
    
    if(recognizer.state == UIGestureRecognizerStateChanged && _tempCell != nil){
        
        //get translation in cell
        CGPoint translate = [recognizer translationInView:_tempCell];
        
        //move cell
        _tempCell.center = CGPointMake(_cellOriginalCenter.x + translate.x, _cellOriginalCenter.y);
        
        //determine if drag distance is long enough to delete
        _leftOnDragRelease = _tempCell.frame.origin.x < -_tempCell.bounds.size.width/2;
        
        //determine if drag distance is long enough to complete
        _rightOnDragRelease = _tempCell.frame.origin.x > _tempCell.bounds.size.width/2;
        
        //panning left
        if(_tempCell.frame.origin.x < 0){
            
            if([self.delegate respondsToSelector:@selector(onPanningLeftWithDelta:AtCellIndex:)]){
                
                //find out delta
                CGFloat delta = MIN(1.0f, fabs(_tempCell.frame.origin.x / (_tempCell.bounds.size.width / 2.0f)));
                
                //tell delegate panning left
                [self.delegate onPanningLeftWithDelta:delta AtCellIndex:_cellIndex];
                                                          
            }
        }
        else if(_tempCell.frame.origin.x > 0){//panning right
            
            if([self.delegate respondsToSelector:@selector(onPanningRightWithDelta:AtCellIndex:)]){
                
                //find out delta
                CGFloat delta = MIN(1.0f, fabs(_tempCell.frame.origin.x / (_tempCell.bounds.size.width / 2.0f)));
                
                //tell delegate panning right
                [self.delegate onPanningRightWithDelta:delta AtCellIndex:_cellIndex];
                
            }
        }
        
    }
    
    if(recognizer.state == UIGestureRecognizerStateEnded){
        
        CGRect originalFrame = CGRectMake(0, _tempCell.frame.origin.y, _tempCell.frame.size.width, _tempCell.frame.size.height);
        
        if(_leftOnDragRelease){
            
            if(_panLeftSnapBackAnim){
                
                //retrun to original frame
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     _tempCell.frame = originalFrame;
                                 }
                 ];
            }
            
            //tell delegate pan left
            if([self.delegate respondsToSelector:@selector(onPanLeftAtCellIndex:)]){
                
                [self.delegate onPanLeftAtCellIndex:_cellIndex];
            }
            
        }
        else if(_rightOnDragRelease){
            
            if(_panRightSnapBackAnim){
                
                //retrun to original frame
                [UIView animateWithDuration:0.2
                                 animations:^{
                                     _tempCell.frame = originalFrame;
                                 }
                 ];
            }
            
            //tell delegate pan right
            if([self.delegate respondsToSelector:@selector(onPanRightAtCellIndex:)]){
                
                [self.delegate onPanRightAtCellIndex:_cellIndex];
            }
        }
        else
        {
            // if the cell is not complete pan right or left, snap back to the original location
            [UIView animateWithDuration:0.2
                             animations:^{
                                 _tempCell.frame = originalFrame;
                             }
             ];
        }
        
        _tempCell = nil;
        _cellOriginalCenter = CGPointZero;
        _leftOnDragRelease = NO;
        _rightOnDragRelease = NO;
    }
}

@end
