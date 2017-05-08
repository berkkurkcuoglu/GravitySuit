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
@synthesize delegate,backgroundLayer;

CABasicAnimation *backgroundLayerAnimation;
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
    _counter = 0;
    _scoreLabel.adjustsFontSizeToFitWidth = YES;
    _scoreLabel.minimumScaleFactor = 0.4;
    _highScoreLabel.adjustsFontSizeToFitWidth = YES;
    _highScoreLabel.minimumScaleFactor = 0.4;
    [_highScoreLabel setText:[NSString stringWithFormat:@"Best: %ld",_highScore]];    
    [self updateScore];
        if (self)
    {
        CGRect bounds = [self bounds];
        suit = [[Suit alloc] initWithFrame:CGRectMake(bounds.size.width/4, bounds.size.height/2, 40 , 40)];
        [suit setImage:[UIImage imageNamed:@"suit.png"]];
        [self addSubview:suit];
        [suit setDy:2];
    }
    meteoroids = [[NSMutableArray alloc] init];
    return self;
}
// adapted code from : http://stackoverflow.com/questions/8790079/animate-infinite-scrolling-of-an-image-in-a-seamless-loop
-(void)scrollBackground {
    UIImage *Image = [UIImage imageNamed:@"background.jpg"];
    UIColor *backgroundPattern = [UIColor colorWithPatternImage:Image];
    backgroundLayer = [CALayer layer];
    backgroundLayer.backgroundColor = (backgroundPattern.CGColor);
    
    backgroundLayer.transform = CATransform3DMakeScale(1, -1, 1);
    
    backgroundLayer.anchorPoint = CGPointMake(0, 1);
    
    CGSize viewSize = self.bounds.size;
    backgroundLayer.frame = CGRectMake(0, 0, viewSize.width * 3, viewSize.height * 1.5);
    
    [self.layer addSublayer:backgroundLayer];
    
    CGPoint startPoint = CGPointZero;
    CGPoint endPoint = CGPointMake(-Image.size.width, 0);
    backgroundLayerAnimation = [CABasicAnimation animationWithKeyPath:@"position"];
    backgroundLayerAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
    backgroundLayerAnimation.fromValue = [NSValue valueWithCGPoint:startPoint];
    backgroundLayerAnimation.toValue = [NSValue valueWithCGPoint:endPoint];
    backgroundLayerAnimation.repeatCount = HUGE_VALF;
    backgroundLayerAnimation.duration = 5;
    [backgroundLayer addAnimation:backgroundLayerAnimation forKey:@"position"];
    backgroundLayer.zPosition = -2;
}

-(void)pauseLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer convertTime:CACurrentMediaTime() fromLayer:nil];
    layer.speed = 0.0;
    layer.timeOffset = pausedTime;
}

-(void)resumeLayer:(CALayer*)layer
{
    CFTimeInterval pausedTime = [layer timeOffset];
    layer.speed = 1.0;
    layer.timeOffset = 0.0;
    layer.beginTime = 0.0;
    CFTimeInterval timeSincePause = [layer convertTime:CACurrentMediaTime() fromLayer:nil] - pausedTime;
    layer.beginTime = timeSincePause;
}

-(void)updateScore{
    if(_currentScore > _highScore){
        _highScore = _currentScore;
        [[NSUserDefaults standardUserDefaults] setInteger:_highScore forKey:@"suitHighScore"];
    }
    [_scoreLabel setText:[NSString stringWithFormat:@"Score: %ld",_currentScore]];
    [_highScoreLabel setText:[NSString stringWithFormat:@"Best: %ld",_highScore]];
}

-(void)addMeteroid{
        CGRect bounds = [self bounds];
    
        Meteoroid *b = [[Meteoroid alloc] initWithFrame:CGRectMake(0, 0, (int)(bounds.size.width * .16),(int)(bounds.size.height * .24))];
        [b setImage:[UIImage imageNamed:@"meteoroid.png"]];
        [self addSubview:b];
        b.layer.zPosition = -1;
        [b setCenter:CGPointMake((int)((bounds.size.width) + b.frame.size.width/2), rand() % (int)(bounds.size.height - b.frame.size.height) + b.frame.size.height/2)];
        [meteoroids addObject:b];
    
}
-(void)moveMeteroids{
    for (int i=0; i < [meteoroids count]; i++){
        Meteoroid *meto =[meteoroids objectAtIndex:i];
        CGPoint p = [meto center];
        p.x -= 2;
        if(p.x < 10){
            [meteoroids removeObject:meto];
            [meto removeFromSuperview];
            _currentScore += 10;
        }
        else{
            [meto setCenter:p];
        }
    }
}

-(void)play:(CADisplayLink *)sender{
    
    if(_counter == 0)
        [self scrollBackground];
    
    CGPoint p = [suit center];
    CGRect f = [suit frame];
    p.y += [suit dy];
    [self moveMeteroids];
    
    CGRect fakeFrame = CGRectMake(suit.center.x-f.size.width/2, suit.center.y-f.size.height/2, suit.frame.size.width-12, suit.frame.size.height-12);
    
    if(p.x + f.size.width/2 > [self bounds].size.width){
        p.x -=  [self bounds].size.width;
        _currentScore += 100;
    }
    
    if(p.y > [self bounds].size.height - f.size.height/2){
        p.y = [self bounds].size.height - f.size.height/2 ;
    }
    if(p.y < f.size.height){
        p.y = f.size.height;
    }
    
    
    for (int i=0; i < [meteoroids count]; i++)
    {
        Meteoroid *meteoroid =[meteoroids objectAtIndex:i];
        CGRect b = [meteoroid frame];
        CGRect fakeMeto = CGRectMake(meteoroid.center.x-b.size.width/2, meteoroid.center.y-b.size.height/2, meteoroid.frame.size.width-16, meteoroid.frame.size.height-16);
        if (CGRectIntersectsRect(fakeMeto, fakeFrame) && ![meteoroid touched])
        {
            [meteoroid setTouched:TRUE];
            [delegate gameOver];
             [sender invalidate];
            [self pauseLayer:backgroundLayer];
        }
    }
    
    [suit setCenter:p];
    [self updateScore];
    if(_counter % 120 == 0){
        [self addMeteroid];
    }
    _counter++;
}

@end



