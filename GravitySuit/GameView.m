//
//  GameView.m
//  GravitySuit
//
//  Created by berk on 5/6/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import "GameView.h"


@implementation GameView
@synthesize suit,meteoroids;
@synthesize delegate;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/
-(id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _scoreLabel.adjustsFontSizeToFitWidth = YES;
    _scoreLabel.minimumScaleFactor = 0.4;
    _highScoreLabel.adjustsFontSizeToFitWidth = YES;
    _highScoreLabel.minimumScaleFactor = 0.4;
    [_highScoreLabel setText:[NSString stringWithFormat:@"Best: %ld",_highScore]];
    [self updateScore];
    [self setImage:[UIImage imageNamed:@"background.jpg"]];    
    if (self)
    {
        CGRect bounds = [self bounds];
        suit = [[Suit alloc] initWithFrame:CGRectMake(50, bounds.size.height/2, 40 , 40)];
        [suit setImage:[UIImage imageNamed:@"suit.png"]];
        [self addSubview:suit];
        [suit setDy:1.6];
        [suit setDx:2];        
        //[self setup];
    }
    return self;
}

-(void)updateScore{
    if(_currentScore > _highScore){
        _highScore = _currentScore;
        [[NSUserDefaults standardUserDefaults] setInteger:_highScore forKey:@"suitHighScore"];
    }
    [_scoreLabel setText:[NSString stringWithFormat:@"Score: %ld",_currentScore]];
    [_highScoreLabel setText:[NSString stringWithFormat:@"Best: %ld",_highScore]];
}

-(void)play:(CADisplayLink *)sender{
    
    
    CGPoint p = [suit center];
    CGRect f = [suit frame];
    p.x += [suit dx];
    
    
    if(p.x + f.size.width/2 > [self bounds].size.width){
        p.x -=  [self bounds].size.width;
                _currentScore += 100;
    }
    
    if(p.y > [self bounds].size.height - f.size.height/2){
        p.y = [self bounds].size.height - f.size.height/2 ;
    }
    if(p.y < f.size.height/2){
        p.y = f.size.height/2;
    }    
    
    [suit setCenter:p];
    [self updateScore];
    _counter--;
}

@end



