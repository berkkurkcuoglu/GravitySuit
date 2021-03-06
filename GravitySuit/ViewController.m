//
//  ViewController.m
//  GravitySuit
//
//  Created by berk on 5/6/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import "ViewController.h"
#import <AVFoundation/AVAudioPlayer.h>

@interface ViewController ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@property(nonatomic, strong) AVAudioPlayer *backgroundMusic;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSURL *musicFile = [[NSBundle mainBundle] URLForResource:@"spaceLoop"
                                               withExtension:@"wav"];
    self.backgroundMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:musicFile
                                                                  error:nil];
    self.backgroundMusic.numberOfLoops = -1;
    [self.backgroundMusic play];
    _gameView.currentScore = 0;
    _gameView.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"gravityHighScore"];
    _gameView.delegate = self;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:_gameView selector:@selector(play:)];
    [_displayLink setPreferredFramesPerSecond:60];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    UIImage *btnImage = [UIImage imageNamed:@"pause.png"];
    [_pauseButton setImage:btnImage forState:UIControlStateNormal];
    UIImage *fireImage = [UIImage imageNamed:@"fireButton.png"];
    [_fireButton setImage:fireImage forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapped:(id)sender {    
    if(_gameView.suit.dy > 0){
        [_gameView.suit setDy:-2.4];
        [_gameView.suit setImage:[UIImage imageNamed:@"upSuit.png"]];
    }
    else{
        [_gameView.suit setDy:2.4];
        [_gameView.suit setImage:[UIImage imageNamed:@"suit.png"]];
    }
}

- (IBAction)pause:(id)sender {
    self.displayLink.paused = YES;
    [_gameView pauseLayer:_gameView.backgroundLayer];
    [self.backgroundMusic pause];
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Paused"
                                  message:[NSString stringWithFormat:@""]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* resume = [UIAlertAction
                             actionWithTitle:@"Resume"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 self.displayLink.paused = NO;
                                 [_gameView resumeLayer:_gameView.backgroundLayer];
                                 [self.backgroundMusic play];
                                 [alert dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    UIAlertAction* menu = [UIAlertAction
                           actionWithTitle:@"Main Menu"
                           style:UIAlertActionStyleDefault
                           handler:^(UIAlertAction * action)
                           {
                               [self performSegueWithIdentifier:@"menuSegue" sender:nil];
                               [alert dismissViewControllerAnimated:YES completion:nil];
                           }];
    
    [alert addAction:menu];
    [alert addAction:resume];
    [self presentViewController:alert animated:YES completion:nil];
}
- (IBAction)shoot:(id)sender {
    [_gameView shoot];
}

-(void)gameOver
{
    UIAlertController * alert=   [UIAlertController
                                  alertControllerWithTitle:@"Game Over!!!"
                                  message:[NSString stringWithFormat:@"High Score: %lu \n\nYour Score: %lu",[_gameView highScore],[_gameView currentScore]]
                                  preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [self performSegueWithIdentifier:@"menuSegue" sender:nil];
                             [alert dismissViewControllerAnimated:YES completion:nil];
                         }];
    
    [alert addAction:ok];
    [self presentViewController:alert animated:YES completion:nil];
    
}

@end
