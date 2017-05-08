//
//  GameView.h
//  GravitySuit
//
//  Created by berk on 5/6/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import <UIKit/UIKit.h>
#include "Suit.h"
#include "Meteoroid.h"
#include "Bullet.h"

@protocol GameOverDelegate;

@interface GameView : UIImageView

@property (nonatomic, strong) Suit *suit;
@property (nonatomic, strong) NSMutableArray *meteoroids;
@property (nonatomic, strong) Bullet *bullet;
@property (nonatomic) NSInteger ammo;
@property (nonatomic) NSInteger highScore;
@property (nonatomic) NSInteger currentScore;
@property (nonatomic) NSInteger counter;
@property (strong, nonatomic) IBOutlet UILabel *scoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *highScoreLabel;
@property (strong, nonatomic) IBOutlet UILabel *bulletLabel;
@property (strong, nonatomic) id<GameOverDelegate>delegate;
@property (nonatomic) CALayer *backgroundLayer;
-(void)play:(CADisplayLink *)sender;
-(void)pauseLayer:(CALayer*)layer;
-(void)resumeLayer:(CALayer*)layer;
-(void)shoot;
@end


@protocol GameOverDelegate
-(void)gameOver;
@end

