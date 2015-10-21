//
//  NPTableCellController.m
//  NPTableView
//
//  Created by User on 12/10/15.
//  Copyright © 2015 ArcTech. All rights reserved.
//

#import "NPTableCellView.h"

@interface NPTableCellView ()

@end

@implementation NPTableCellView{
    
    UIView *_selectedBackgroundView;
}

@synthesize selectBackgroundView = _selectBackgroundView;

+ (id)cellWithNibName:(NSString *)nibName{
    
    if([[NSBundle mainBundle] pathForResource:nibName ofType:@"nib"]){
        
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:nil options:nil];
        
        if(nibContents == nil || nibContents.count == 0){
            
            NSLog(@"Init class %@ fail, no nib file found in main bundle", NSStringFromClass([self class]));
            
            return nil;
        }
        
        UIView *nibView = [nibContents objectAtIndex:0];

        return nibView;
    }
    
    return nil;
}

- (id)initWithNibName:(NSString *)nibName{
    
    self = [super initWithFrame:CGRectNull];
    
    if(self != nil){
        
        NSArray *nibContents = [[NSBundle mainBundle] loadNibNamed:nibName owner:self options:nil];
        
        if(nibContents == nil || nibContents.count == 0){
            
            NSLog(@"Init class %@ fail, no nib file found in main bundle", NSStringFromClass([self class]));
            
            return nil;
        }
        
        UIView *nibView = [nibContents objectAtIndex:0];
        
        self = (id)nibView;
    }
    
    return self;
}

- (void)setSelect:(BOOL)selected{
    
    if(selected){
        
        //if there is a selectBackgroundView assigned, we need to perform highlight animation
        if(_selectedBackgroundView != nil){
            
            _selectedBackgroundView.frame = CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height);
            [self insertSubview:_selectedBackgroundView atIndex:0];
            
            [self beginHighlight:selected];
            
        }
        else{
            
            [self setHighlight:selected];
        }
    }
    else{
        
        //if there is a selectBackgroundView assigned, we need to perform unhighlight animation
        if(_selectedBackgroundView != nil){
            
            [self beginHighlight:selected];
        }
        else{
            
            [self setHighlight:selected];
        }
    }
}

- (void)beginHighlight:(BOOL)highlighted{
    
    
    if(highlighted){
        
        _selectedBackgroundView.alpha = 0.0f;
        

        [UIView animateWithDuration:0.5f animations:^{
            
            _selectedBackgroundView.alpha = 1.0f;
            
        } completion:^(BOOL finished){
        
            [self setHighlight:YES];
        }];
    }
    else{
        

        [UIView animateWithDuration:0.5f animations:^{
        
            _selectedBackgroundView.alpha = 0.0f;
            
        } completion:^(BOOL finished){
        
            [self setHighlight:NO];
        }];
    }
}

- (void)setHighlight:(BOOL)highlighted{
    
    
}

- (UIView *)selectBackgroundView{
    
    return _selectedBackgroundView;
}

- (void)setSelectBackgroundView:(UIView *)selectBackgroundView{
    
    _selectedBackgroundView = selectBackgroundView;
}


- (void)willRecycle{
    
}

- (void)didRecycle{
    
}

@end
