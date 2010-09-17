//
//  PineappleAppDelegate.h
//  Pineapple
//
//  Created by Sean Soper on 9/16/10.
//  Copyright 2010 Intridea. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Presently.h"

@interface PineappleAppDelegate : NSObject <UIApplicationDelegate, UITextFieldDelegate, PresentlySessionDelegate> {
  UIWindow *window;
  UINavigationController *rootViewController;
  UITextField *fieldUsername, *fieldPassword, *fieldOrganization;
  Presently *presently;
  UIView *logoView;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *rootViewController;
@property (nonatomic, retain) IBOutlet UITextField *fieldUsername, *fieldPassword, *fieldOrganization;
@property (nonatomic, retain) Presently *presently;
@property (nonatomic, retain) IBOutlet UIView *logoView;

- (IBAction) loginButtonPressed;

@end

