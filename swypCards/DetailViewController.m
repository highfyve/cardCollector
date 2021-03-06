//
//  DetailViewController.m
//  swypCards
//
//  Created by Alexander List on 1/28/12.
//  Copyright (c) 2012 ExoMachina. All rights reserved.
//

#import "DetailViewController.h"
#import <QuartzCore/QuartzCore.h>


@interface DetailViewController ()
@property (strong, nonatomic) UIPopoverController *masterPopoverController;
- (void)configureView;
@end

@implementation DetailViewController

@synthesize cardDetailItem = _cardDetailItem;
@synthesize detailDescriptionLabel = _detailDescriptionLabel;
@synthesize masterPopoverController = _masterPopoverController;
@synthesize swypWorkspace = _swypWorkspace;


#pragma mark DYNAMIX
-(void) setupDynamicBehavior{
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.view];
    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self.cardImageView]];
    self.boundaryCollision = [[UICollisionBehavior alloc] initWithItems:@[self.cardImageView]];
//    self.boundaryCollision.translatesReferenceBoundsIntoBoundary = YES;//the walls just seem to cause crashes, but give feeling to the experience
    [self.boundaryCollision addBoundaryWithIdentifier:@"top" fromPoint:CGPointMake(-2000, 0) toPoint:CGPointMake(2000, 0)];
    
    self.stringAttachment = [[UIAttachmentBehavior alloc]initWithItem:self.cardImageView offsetFromCenter:UIOffsetMake(0, -100) attachedToItem:self.anchorImageView offsetFromCenter:UIOffsetZero];
    [self.stringAttachment setDamping:0];
    
    [self.animator addBehavior:[[UIAttachmentBehavior alloc] initWithItem:self.anchorImageView attachedToAnchor:self.anchorImageView.center]];
    
    [self.animator addBehavior:self.stringAttachment];
//    [self.animator addBehavior:self.boundaryCollision];
    [self.animator addBehavior:self.gravity];
    
    
    __weak DetailViewController * weakDetail = self;
    self.motionManager = [[CMMotionManager alloc] init];
    [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
        CMAcceleration gravity = motion.gravity;
        dispatch_async(dispatch_get_main_queue(), ^{
            weakDetail.gravity.gravityDirection = CGVectorMake(gravity.x/5, -gravity.y + .2);
        });
    }];
   
}




#pragma mark - User Interface Cruft
-(void) activateSwypButtonPressed:(id)sender{
	[_swypWorkspace presentContentWorkspaceAtopViewController:self];
}

-(void)frameActivateButtonWithSize:(CGSize)theSize {
	CGSize thisViewSize	=	[[self view] size];
//	if (deviceIsPad){
//	    [_activateSwypButton setFrame:CGRectMake(((thisViewSize.width)-theSize.width)/2, thisViewSize.height-theSize.height, theSize.width, theSize.height)];	
//	}else{
		[_activateSwypButton setFrame:CGRectMake((thisViewSize.width-theSize.width), (thisViewSize.height-theSize.height), theSize.width, theSize.height)];
//	}
}


-(void) tapGestureChanged:(UITapGestureRecognizer*)recognizer{
	if (recognizer.state == UIGestureRecognizerStateRecognized){
		if (_currentCardState == cardViewStateCover){
			[self transitionToState:cardViewStateInside];
		}else if (_currentCardState == cardViewStateInside){
			[self transitionToState:cardViewStateCover];
		}
	}
}

-(void)	transitionToState:(cardViewState)cardState{
	
	if (cardState != _currentCardState){
		_currentCardState = cardState;
		if (cardState == cardViewStateInside){
			[UIView transitionWithView:_cardImageView duration:1 options:UIViewAnimationOptionTransitionFlipFromTop animations:^{[self setupViewForState:cardState];} completion:nil];
		}else if (cardState == cardViewStateCover){
			[UIView transitionWithView:_cardImageView duration:1 options:UIViewAnimationOptionTransitionFlipFromBottom animations:^{[self setupViewForState:cardState];} completion:nil];
		}
//		[self setupViewForState:cardState];
	}
}

-(void) setupViewForState:(cardViewState)cardState{
	UIImage * cardImage	=	nil;
	switch (cardState) {
		case cardViewStateCover:
			_cardLabel.text	=	NSLocalizedString(@"tap to open", @"on detail view");
			if (_cardDetailItem.coverImage == nil){
				[_cardImageView setBackgroundColor:[UIColor grayColor]];
				[_cardImageView setImage:nil];
			}else{
				cardImage	=	[UIImage imageWithData:[_cardDetailItem coverImage]];
			}
			break;
		case cardViewStateInside:
			_cardLabel.text	=	NSLocalizedString(@"tap to view cover", @"on detail view");
			if (_cardDetailItem.insideImage == nil){
				[_cardImageView setBackgroundColor:[UIColor grayColor]];
				[_cardImageView setImage:nil];
			}else{
				cardImage	=	[UIImage imageWithData:[_cardDetailItem insideImage]];
			}
			break;
	}
	
	if (cardImage){
		[self setupCardImageViewForCurrentStateWithImage:cardImage];
	}
}

-(void) setupCardImageViewForCurrentStateWithImage:(UIImage*)image{
	
	CGRect cardMaxRect	=	CGRectInset(self.view.frame, 35, 50);
	CGPoint cardCenter	=	rectCenter(cardMaxRect);
	CGSize maxSize		=	cardMaxRect.size;
	
	UIImage * properlySizedImage	=	[self constrainImage:image toSize:CGSizeMake(maxSize.width * _cardImageView.layer.contentsScale, maxSize.height * _cardImageView.layer.contentsScale)];
	
	[_cardImageView setSize:properlySizedImage.size];
	[_cardImageView setCenter:cardCenter];
	
	[_cardImageView setImage:properlySizedImage];
	
	CALayer	*layer	=	_cardImageView.layer;
	CGMutablePathRef shadowPath		=	CGPathCreateMutable();
	CGPathAddRect(shadowPath, NULL, CGRectMake(0, 0, _cardImageView.size.width, _cardImageView.size.height));
	[layer setShadowPath:shadowPath];
	CFRelease(shadowPath);
	
}

-(UIImage*)	constrainImage:(UIImage*)image toSize:(CGSize)maxSize{
	if (image == nil)
		return nil;
	
	CGSize oversize = CGSizeMake([image size].width - maxSize.width, [image size].height - maxSize.height);
	
	CGSize iconSize			=	CGSizeZero;
	
	if (oversize.width > 0 || oversize.height > 0){
		if (oversize.height > oversize.width){
			double scaleQuantity	=	maxSize.height/ image.size.height;
			iconSize		=	CGSizeMake(scaleQuantity * image.size.width, maxSize.height);
		}else{
			double scaleQuantity	=	maxSize.width/ image.size.width;	
			iconSize		=	CGSizeMake(maxSize.width, scaleQuantity * image.size.height);		
		}
	}else{
		return image;
	}
	
	UIGraphicsBeginImageContextWithOptions(iconSize, NO, 1);
	[image drawInRect:CGRectMake(0,0,iconSize.width,iconSize.height)];
	UIImage* constrainedImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	
	return constrainedImage;
}


#pragma mark - Managing the detail item

- (void)setCardDetailItem:(Card*)newDetailItem
{
    if (_cardDetailItem != newDetailItem) {
        _cardDetailItem = newDetailItem;
        
		_currentCardState	=	cardViewStateCover;
        // Update the view.
        [self configureView];
		[_delegate datasourceSignificantlyModifiedContent:self];
    }

    if (self.masterPopoverController != nil) {
        [self.masterPopoverController dismissPopoverAnimated:YES];
    }        
}


#pragma mark view configuration
- (void)configureView
{
    // Update the user interface for the detail item.

	if (self.cardDetailItem) {
	    self.detailDescriptionLabel.text	=	[self.cardDetailItem description];
		self.title							=	[_cardDetailItem personName];
		[self setupViewForState:_currentCardState];
	}
	
	[_delegate datasourceSignificantlyModifiedContent:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

	//You definitely DO NOT want to set this in the nib creation routine... it only inits the parent view.
	swypSwypableContentSuperview * contentSuperView	=	[[swypSwypableContentSuperview alloc] initWithContentDelegate:self workspaceDelegate:[self swypWorkspace] frame:self.view.frame];
	
	//just swap from the nib created view
	for (UIView * view in [self.view subviews]){
		[contentSuperView addSubview:view];
	}
	self.view = contentSuperView;
	
	[self.view setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"fake_luxury.png"]]];
	
	[_cardImageView setBackgroundColor:[UIColor grayColor]];
	[_cardImageView setFrame:CGRectInset(self.view.frame, 35, 83)];
	
	
	CALayer	*layer	=	_cardImageView.layer;
	[layer setBorderColor: [[UIColor whiteColor] CGColor]];
	[layer setBorderWidth:8.0f];
	[layer setShadowColor: [[UIColor blackColor] CGColor]];
	[layer setShadowOpacity:0.9f];
	[layer setShadowOffset: CGSizeMake(1, 3)];
	[layer setShadowRadius:4.0];
	[_cardImageView setClipsToBounds:NO];
	
	
	UITapGestureRecognizer * recognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureChanged:)];
	[recognizer setNumberOfTapsRequired:1];
	[_cardImageView addGestureRecognizer:recognizer];
    
    UIPanGestureRecognizer * pullCordRecognizer = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(cardImageViewPanned:)];
	[_cardImageView addGestureRecognizer:pullCordRecognizer];
    
	[_cardImageView setUserInteractionEnabled:TRUE];
	
	[self.anchorImageView.layer setCornerRadius:12];
    
	_activateSwypButton	=	[UIButton buttonWithType:UIButtonTypeCustom];
	UIImage *	swypActivateImage	=	[UIImage imageNamed:@"swypButton"];
	[_activateSwypButton setBackgroundImage:swypActivateImage forState:UIControlStateNormal];
	_activateSwypButton.alpha = 0;
	[self frameActivateButtonWithSize:swypActivateImage.size];
	[_activateSwypButton addTarget:self action:@selector(activateSwypButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
	

	UISwipeGestureRecognizer *swipeUpRecognizer = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(activateSwypButtonPressed:)];
	swipeUpRecognizer.direction = UISwipeGestureRecognizerDirectionUp;
	[_activateSwypButton addGestureRecognizer:swipeUpRecognizer];
    
    
	[self.navigationItem setRightBarButtonItem:[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(exportPhotosButtonPressed:)]];
    
	[self.view addSubview:_activateSwypButton];
	
	[self configureView];
    
    [self setupDynamicBehavior];
}

-(void)cardImageViewPanned:(UIPanGestureRecognizer*)panner{
    if (panner.state == UIGestureRecognizerStateBegan){
        [self.pullOnImageAttachment setAnchorPoint:[panner locationInView:self.view]];
        
        [self.animator addBehavior:self.pullOnImageAttachment];
    }else
        [self.pullOnImageAttachment setAnchorPoint:[panner locationInView:self.view]];
    if (panner.state == UIGestureRecognizerStateChanged){
        
    }else if (panner.state == UIGestureRecognizerStateEnded){
        [self.animator removeBehavior:self.pullOnImageAttachment];
        
    }
}

-(UIAttachmentBehavior*)pullOnImageAttachment{
    if (_pullOnImageAttachment == nil){
        _pullOnImageAttachment = [[UIAttachmentBehavior alloc] initWithItem:self.cardImageView attachedToAnchor:CGPointZero];
    }
    return _pullOnImageAttachment;
}

-(void)exportPhotosButtonPressed:(id)sender{
    
	UIActionSheet * sheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:nil destructiveButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Save Images", @"Card Creator"), nil];
	
	[sheet addButtonWithTitle:NSLocalizedString(@"Cancel", @"UIAlertView hide")];
	[sheet setCancelButtonIndex:[sheet numberOfButtons]-1];
    
	if (deviceIsPad){
		[sheet showFromBarButtonItem:self.navigationItem.rightBarButtonItem animated:NO];
	}else{
		[sheet showInView:self.view];
	}
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
		NSUInteger buttonCount	=	[actionSheet numberOfButtons];
	if (buttonIndex +1 == buttonCount){
		return;
	}

    NSData * jpegFront = self.cardDetailItem.coverImage;
    NSData * jpegInside = self.cardDetailItem.insideImage;
    
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:jpegFront], nil, nil, nil);
    UIImageWriteToSavedPhotosAlbum([UIImage imageWithData:jpegInside], nil, nil, nil);
    
}



#pragma mark - View lifecycle
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}



- (void)viewDidUnload
{
	if (self == [[_swypWorkspace contentManager] contentDataSource])
		[[_swypWorkspace contentManager] setContentDataSource:nil];

	_objectContext	= nil;
	_swypWorkspace	= nil;
	_cardImageView	= nil;
	_cardLabel		= nil;
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	
	[[_swypWorkspace contentManager] setContentDataSource:self];
	[_delegate datasourceSignificantlyModifiedContent:self];
	[self frameActivateButtonWithSize:_activateSwypButton.size];
	[UIView animateWithDuration:.5 animations:^{
		_activateSwypButton.alpha = 1;
	}];

}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
	    return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	} else {
	    return YES;
	}
}
-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    _activateSwypButton.alpha = 0;
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self frameActivateButtonWithSize:_activateSwypButton.size];
	[UIView animateWithDuration:.5 animations:^{
		_activateSwypButton.alpha = 1;
		[self setupViewForState:_currentCardState];
	}];
}

-(id) initWithSwypWorkspace:(swypWorkspaceViewController*)workspace managedObjectContext:(NSManagedObjectContext*)context{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
		_objectContext = context;
		_swypWorkspace = workspace;
		self.title = NSLocalizedString(@"Your Card", @"Your Card");
    }
    return self;
}
							
#pragma mark - Split view

- (void)splitViewController:(UISplitViewController *)splitController willHideViewController:(UIViewController *)viewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController:(UIPopoverController *)popoverController
{
    barButtonItem.title = NSLocalizedString(@"Cards", @"Cards");
    [self.navigationItem setLeftBarButtonItem:barButtonItem animated:YES];
    self.masterPopoverController = popoverController;
}

- (void)splitViewController:(UISplitViewController *)splitController willShowViewController:(UIViewController *)viewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    // Called when the view is shown again in the split view, invalidating the button and popover controller.
    [self.navigationItem setLeftBarButtonItem:nil animated:YES];
    self.masterPopoverController = nil;
}

#pragma mark - swyp
#pragma mark swypSwypableContentSuperviewContentDelegate
-(NSString*)contentIDForSwypableSubview:(UIView *)view withinSwypableContentSuperview:(swypSwypableContentSuperview *)superview{
	NSArray * content = [self idsForAllContent];
	return [content objectAtIndex:0];
}
-(BOOL)subview:(UIView *)subview isSwypableWithSwypableContentSuperview:(swypSwypableContentSuperview *)superview{
	if (subview == _cardImageView){
		NSArray * content = [self idsForAllContent];
		return (ArrayHasItems(content));
	}
	return FALSE;
}

#pragma mark swypConnectionSessionDataDelegate
-(NSArray*)	supportedFileTypesForReceipt{
	
	return [NSArray arrayWithObjects:cardFileFormat, nil];
}

-(BOOL) delegateWillHandleDiscernedStream:(swypDiscernedInputStream*)discernedStream wantsAsData:(BOOL *)wantsProvidedAsNSData inConnectionSession:(swypConnectionSession*)session{
	if ([[self supportedFileTypesForReceipt] containsObject:[discernedStream streamType]]){
		*wantsProvidedAsNSData = TRUE;
		return TRUE;
	}
	return FALSE;
}

-(void)	yieldedData:(NSData*)streamData discernedStream:(swypDiscernedInputStream*)discernedStream inConnectionSession:(swypConnectionSession*)session{
	NSLog(@"GOT DATR %@!", [discernedStream streamType]);
	
	if ([[discernedStream streamType] isFileType:cardFileFormat]){
		Card * newCard	=	[NSEntityDescription insertNewObjectForEntityForName:@"Card" inManagedObjectContext:_objectContext];
		[newCard setValuesFromSerializedData:streamData];

		NSError * error = nil;
        if ([_objectContext hasChanges] && ![_objectContext save:&error]){
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        } 	
		
		[self dismissViewControllerAnimated:true completion:nil];
	}
}

#pragma mark swypContentDataSourceProtocol
- (NSArray*)		idsForAllContent{
	if (_cardDetailItem == nil)
		return nil;
	return [NSArray arrayWithObject:@"MODEL_CURRENT_DETAILED_CARD"];
}
- (UIImage *)		iconImageForContentWithID: (NSString*)contentID ofMaxSize:(CGSize)maxIconSize{
	if (_cardDetailItem == nil){
		return nil;
	}
	UIImage * thumbnail = nil;
	if (_cardDetailItem.thumbnailImage == nil){
		thumbnail = [self constrainImage:[UIImage imageWithData:[_cardDetailItem coverImage]] toSize:maxIconSize];
		[_cardDetailItem setThumbnailImage:UIImageJPEGRepresentation(thumbnail, .8)];
	}else{
		thumbnail	=	[UIImage imageWithData:[_cardDetailItem thumbnailImage]];
		[_cardDetailItem setCardShareCount:[NSNumber numberWithInt:[[_cardDetailItem cardShareCount] intValue]-1]];
	}
	return thumbnail;
}
- (NSArray*)		supportedFileTypesForContentWithID: (NSString*)contentID{
	return [NSArray arrayWithObjects:cardFileFormat,[NSString imageJPEGFileType],[NSString imagePNGFileType], nil];
;
}
- (NSInputStream*)	inputStreamForContentWithID: (NSString*)contentID fileType:	(swypFileTypeString*)type	length: (NSUInteger*)contentLengthDestOrNULL;{
	NSData * streamData = nil;
	if ([type isFileType:[NSString imageJPEGFileType]]){
		streamData = [_cardDetailItem coverImage];
	}else if ([type isFileType:[NSString imagePNGFileType]]){
		streamData = UIImagePNGRepresentation([UIImage imageWithData:[_cardDetailItem coverImage]]);
	}else if ([type isFileType:cardFileFormat]){
		streamData = [_cardDetailItem serializedDataValue];
	}
	
	*contentLengthDestOrNULL	=	[streamData length];
	return [NSInputStream inputStreamWithData:streamData];
}
-(void)	setDatasourceDelegate:			(id<swypContentDataSourceDelegate>)delegate{
	_delegate	=	delegate;
}
-(id<swypContentDataSourceDelegate>)	datasourceDelegate{
	return _delegate;
}
@end