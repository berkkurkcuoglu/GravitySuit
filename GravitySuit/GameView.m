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

/*-(void)setup{
    CGRect bounds = [self bounds];
    for (int i=0; i < [meteoroids count]; i++)
    {
        meteoroid *meteoroid = [meteoroids objectAtIndex:i];
        [meteoroid removeFromSuperview];
    }
    meteoroids = [[NSMutableArray alloc] init];
    for(int i =0; i < 3; i++){
        meteoroid *b = [[meteoroid alloc] initWithFrame:CGRectMake(0, 0, (int)(bounds.size.width * .05),(int)(bounds.size.height * .25))];
        [b setImage:[UIImage imageNamed:@"meteoroid.png"]];
        [self addSubview:b];
        [b setTouched:false];
        [b setCenter:CGPointMake((rand() % (int)(bounds.size.width * .5)+(bounds.size.width * .3)), rand() % (int)(bounds.size.height - b.frame.size.height) + b.frame.size.height/2)];
        int tries = 10;
        while([self meteoroidIsOverlapping:b] || --tries > 0)
            [b setCenter:CGPointMake((rand() % (int)(bounds.size.width * .5)+(bounds.size.width * .3)), rand() % (int)(bounds.size.height - b.frame.size.height) + b.frame.size.height/2)];
        [meteoroids addObject:b];
        
    } 
}

-(BOOL)meteoroidIsOverlapping:(meteoroid*) meteoroid{
    CGRect theFrame = [meteoroid frame];
    for (int i=0; i < [meteoroids count]; i++){
        meteoroid *othermeteoroid = [meteoroids objectAtIndex:i];
        CGRect otherFrame = [othermeteoroid frame];
        if(meteoroid != othermeteoroid && (CGRectIntersectsRect(theFrame, otherFrame) || (fabs(meteoroid.center.x-othermeteoroid.center.x) < (suit.frame.size.width*1.6+theFrame.size.width) && fabs(meteoroid.center.y-othermeteoroid.center.y) < (suit.frame.size.height*2+theFrame.size.height))))
            return true;
    }
    for (int i=0; i < [coins count]; i++){
        Coin *otherCoin = [coins objectAtIndex:i];
        CGRect otherFrame = [otherCoin frame];
        if(CGRectIntersectsRect(theFrame, otherFrame))
            return true;
    }
    if(CGRectIntersectsRect(theFrame, [pizza frame]))
        return true;
    
    return false;
}

*/
-(void)play:(CADisplayLink *)sender{
    
    
    CGPoint p = [suit center];
    CGRect f = [suit frame];
    p.x += [suit dx];
    //p.y -= [suit jump];
    //[suit setJump:0];
    //[suit setDy:[suit dy] - .3];
    p.y += [suit dy];
    CGRect fakeFrame = CGRectMake(suit.center.x-f.size.width/2, suit.center.y-f.size.height/2, suit.frame.size.width-12, suit.frame.size.height-12);
    
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
    
    /*
    
    for (int i=0; i < [meteoroids count]; i++)
    {
        meteoroid *meteoroid =[meteoroids objectAtIndex:i];
        CGRect b = [meteoroid frame];
        if (CGRectIntersectsRect(b, fakeFrame) && ![meteoroid touched] && _counter < 0)
        {
     
                [delegate gameOver];
                [sender invalidate];
            }
        }
    }
    

    */
    
    [suit setCenter:p];
    [self updateScore];
    _counter--;
}

@end



