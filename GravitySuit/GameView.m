//
//  GameView.m
//  GravitySuit
//
//  Created by berk on 5/6/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import "GameView.h"
#import <AudioToolbox/AudioServices.h>

@implementation GameView
@synthesize suit,meteoroids,bullet;
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
    _ammo = 0;
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
        [suit setDy:2.4];
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
    backgroundLayer.zPosition = -5;
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
        [[NSUserDefaults standardUserDefaults] setInteger:_highScore forKey:@"gravityHighScore"];
    }
    [_scoreLabel setText:[NSString stringWithFormat:@"Score: %ld",_currentScore]];
    [_highScoreLabel setText:[NSString stringWithFormat:@"Best: %ld",_highScore]];
}

-(void)addMeteroid{
        CGRect bounds = [self bounds];
        u_int32_t random = arc4random_uniform(3);
        Meteoroid *meto;
        if(random == 0){
            meto = [[Meteoroid alloc] initWithFrame:CGRectMake(0, 0, (int)(bounds.size.width * .08),(int)(bounds.size.height * .12))];
            [meto setDx:4];
            meto.layer.zPosition = -1;
            [meto setImage:[UIImage imageNamed:@"meteoroid.png"]];
        }
        else if(random == 1){
            meto = [[Meteoroid alloc] initWithFrame:CGRectMake(0, 0, (int)(bounds.size.width * .12),(int)(bounds.size.height * .18))];
            [meto setDx:3];
            meto.layer.zPosition = -2;
            [meto setImage:[UIImage imageNamed:@"meteoroid2.png"]];

        }
        else if(random == 2){
            meto = [[Meteoroid alloc] initWithFrame:CGRectMake(0, 0, (int)(bounds.size.width * .24),(int)(bounds.size.height * .24))];
            [meto setDx:2.4];
            meto.layer.zPosition = -3;
            [meto setImage:[UIImage imageNamed:@"meteoroid3.png"]];
        }
        [self addSubview:meto];
        CGPoint metoCenter = CGPointMake((int)((bounds.size.width) + meto.frame.size.width/2), rand() % (int)(bounds.size.height - meto.frame.size.height) + meto.frame.size.height/2);
        if(metoCenter.y <= meto.frame.size.height/2)
            metoCenter.y += meto.frame.size.height/2;
        [meto setCenter:metoCenter];
        [meteoroids addObject:meto];
    
}
-(void)moveMeteroids{
    for (int i=0; i < [meteoroids count]; i++){
        Meteoroid *meto =[meteoroids objectAtIndex:i];
        CGPoint p = [meto center];
        p.x -= [meto dx];
        if(p.x < -meto.frame.size.width/2){
            [meteoroids removeObject:meto];
            [meto removeFromSuperview];            
            _currentScore += 10;
        }
        else{
            [meto setCenter:p];
        }
    }
}

-(void)shoot{
    if(_ammo == 1){
        _ammo--;
        CGPoint p = [suit center];
        CGRect f = [suit frame];
        bullet = [[Bullet alloc] initWithFrame:CGRectMake(p.x + f.size.width/2, p.y , 27,9)];
        [bullet setImage:[UIImage imageNamed:@"laserBullet.png"]];
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"shoot" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        SystemSoundID audioEffect;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
        [self addSubview:bullet];
    }
    else{
        NSString *path  = [[NSBundle mainBundle] pathForResource:@"blip" ofType:@"wav"];
        NSURL *pathURL = [NSURL fileURLWithPath : path];
        SystemSoundID audioEffect;
        AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
        AudioServicesPlaySystemSound(audioEffect);
        [self addSubview:bullet];
    }
}
-(void)play:(CADisplayLink *)sender{
    
    if(_counter == 6)
        [self scrollBackground];
    
    if(_counter % 480 == 0){
        _ammo = 1;
    }
    
    if(_counter % 60 == 0){
        if(_ammo == 1)
             [_bulletLabel setText:[NSString stringWithFormat:@"Bullet Ready"]];
        else
            [_bulletLabel setText:[NSString stringWithFormat:@"Bullet Ready In: %ld",8-(_counter%480)/60]];
    }
    CGPoint bulletP = [bullet center];
    bulletP.x += 5;

    CGPoint p = [suit center];
    CGRect f = [suit frame];
    p.y += [suit dy];
    [self moveMeteroids];
    
    CGRect fakeFrame = CGRectMake(suit.center.x-f.size.width/2, suit.center.y-f.size.height/2, suit.frame.size.width-12, suit.frame.size.height-12);
    
    if(p.x + f.size.width/2 > [self bounds].size.width){
        p.x -=  [self bounds].size.width;
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
        CGRect fakeMeto;
        if(meteoroid.layer.zPosition == -1)
            fakeMeto = CGRectMake(meteoroid.center.x-b.size.width/2, meteoroid.center.y-b.size.height/2, meteoroid.frame.size.width-4, meteoroid.frame.size.height-4);
        else if(meteoroid.layer.zPosition == -2)
            fakeMeto = CGRectMake(meteoroid.center.x-b.size.width/2, meteoroid.center.y-b.size.height/2, meteoroid.frame.size.width-8, meteoroid.frame.size.height-8);
        else if(meteoroid.layer.zPosition == -3)
            fakeMeto = CGRectMake(meteoroid.center.x-b.size.width/2, meteoroid.center.y-b.size.height/2, meteoroid.frame.size.width-21, meteoroid.frame.size.height-16);

        
        if (CGRectIntersectsRect(fakeMeto, fakeFrame) && ![meteoroid touched])
        {
            [meteoroid setTouched:TRUE];
            NSString *path  = [[NSBundle mainBundle] pathForResource:@"cancel" ofType:@"wav"];
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            SystemSoundID audioEffect;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            AudioServicesPlaySystemSound(audioEffect);

            [delegate gameOver];
             [sender invalidate];
            [self pauseLayer:backgroundLayer];
        }
        if(CGRectIntersectsRect(b, [bullet frame]) && ![meteoroid touched]){
            [meteoroid setTouched:TRUE];
            NSString *path  = [[NSBundle mainBundle] pathForResource:@"confirm" ofType:@"wav"];
            NSURL *pathURL = [NSURL fileURLWithPath : path];
            SystemSoundID audioEffect;
            AudioServicesCreateSystemSoundID((__bridge CFURLRef) pathURL, &audioEffect);
            AudioServicesPlaySystemSound(audioEffect);
            [meteoroid removeFromSuperview];
            [bullet removeFromSuperview];
            bullet = nil;
            if(meteoroid.layer.zPosition == -1)
                _currentScore += 50;
            else if(meteoroid.layer.zPosition == -2)
                 _currentScore += 40;
            else if(meteoroid.layer.zPosition == -3)
                 _currentScore += 30;
        }
    }
    
    [suit setCenter:p];
    [bullet setCenter:bulletP];
    [self updateScore];
    if(_counter % 90 == 0){
        [self addMeteroid];
    }
    _counter++;
}

@end



