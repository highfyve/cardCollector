//
//  DetailViewController.h
//  swypCards
//
//  Created by Alexander List on 1/28/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Card.h"
#import <CoreMotion/CoreMotion.h>

typedef enum{
	cardViewStateCover,
	cardViewStateInside
}cardViewState;

@interface DetailViewController : UIViewController <UIActionSheetDelegate, UISplitViewControllerDelegate,swypContentDataSourceProtocol, swypConnectionSessionDataDelegate, swypSwypableContentSuperviewContentDelegate>{
	
	__weak id<swypContentDataSourceDelegate>	_delegate;
	
	cardViewState				_currentCardState;
	
	IBOutlet UILabel *			_cardLabel;
	
	UIButton *						_activateSwypButton;
	
	swypWorkspaceViewController*	_swypWorkspace;
	NSManagedObjectContext *		_objectContext;
    
    
    UIDynamicAnimator * animator;
}

@property (nonatomic, strong) UIDynamicAnimator* animator;
@property (nonatomic, strong) UIGravityBehavior* gravity;
@property (nonatomic, strong) UICollisionBehavior * boundaryCollision;
@property (nonatomic, strong) UIAttachmentBehavior * stringAttachment;
@property (nonatomic, strong) UIAttachmentBehavior * pullOnImageAttachment;
@property (nonatomic, strong) CMMotionManager * motionManager;

@property (nonatomic, strong) IBOutlet UIImageView *		cardImageView;
@property (weak, nonatomic) IBOutlet UIView *anchorImageView;


-(id) initWithSwypWorkspace:(swypWorkspaceViewController*)workspace managedObjectContext:(NSManagedObjectContext*)context;

@property (strong, nonatomic) swypWorkspaceViewController * swypWorkspace;
@property (strong, nonatomic) Card* cardDetailItem;

@property (strong, nonatomic) IBOutlet UILabel *detailDescriptionLabel;


-(void) setupViewForState:(cardViewState)cardState;
-(void)	transitionToState:(cardViewState)cardState;
-(void) setupCardImageViewForCurrentStateWithImage:(UIImage*)image;
-(UIImage*)	constrainImage:(UIImage*)image toSize:(CGSize)maxSize;
@end
