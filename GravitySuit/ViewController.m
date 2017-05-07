//
//  ViewController.m
//  GravitySuit
//
//  Created by berk on 5/6/17.
//  Copyright © 2017 berk. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (nonatomic, strong) CADisplayLink *displayLink;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _gameView.currentScore = 0;
    _gameView.highScore = [[NSUserDefaults standardUserDefaults] integerForKey:@"gravityHighScore"];
    _gameView.delegate = self;
    
    _displayLink = [CADisplayLink displayLinkWithTarget:_gameView selector:@selector(play:)];
    [_displayLink setPreferredFramesPerSecond:60];
    [_displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSDefaultRunLoopMode];
    
    UIImage *btnImage = [UIImage imageNamed:@"pause.png"];
    [_pauseButton setImage:btnImage forState:UIControlStateNormal];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)tapped:(id)sender {
    //_gameView.suit.jump = [_gameView bounds].size.height/8;
    if(_gameView.suit.dy > 0){
        [_gameView.suit setDy:-1.6];
        [_gameView.suit setImage:[UIImage imageNamed:@"upSuit.png"]];
    }
    else{
        [_gameView.suit setDy:1.6];
        [_gameView.suit setImage:[UIImage imageNamed:@"suit.png"]];
    }
}

- (IBAction)backed:(id)sender {
    [self.displayLink invalidate];
}

- (IBAction)pause:(id)sender {
    self.displayLink.paused = YES;
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

-(void)gameOver
{
    //NSLog(@"Game over");
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
