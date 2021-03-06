/*
 * (c) 2015 Good Technology Corporation. All rights reserved.
 */

#import "SentegrityTAF_AuthWarningViewController.h"
#import "DAFSupport/DAFAppBase.h"
#import <QuartzCore/QuartzCore.h>

@interface SentegrityTAF_AuthWarningViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *goodLogo;
@property (weak, nonatomic) IBOutlet UIImageView *warningIcon;
@property (weak, nonatomic) IBOutlet UILabel *warningMessage;
@property (weak, nonatomic) IBOutlet UILabel *optionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *okButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;

@end

@implementation SentegrityTAF_AuthWarningViewController

@synthesize result;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    [self setUpLogoInImageView: self.goodLogo];
    [self setUpAppIconLayer];
    [self setupOptionsLabel];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    [self updateWarningLabels];
}

- (void)setUpLogoInImageView:(UIImageView* )goodImageView
{
    // get image from bundle
    
    UIImage *goodLogoImage = [UIImage imageNamed:@"Blackberry_small_logo"];
    
    // set image to imageView
    [goodImageView setImage:goodLogoImage];
    
    // adjust image size
    CGSize imageSize = goodLogoImage.size;
    goodImageView.contentMode = UIViewContentModeScaleAspectFit;
    goodImageView.frame = CGRectMake(goodImageView.frame.origin.x,
                                     goodImageView.frame.origin.y,
                                     imageSize.width, imageSize.height );
}

- (void)setUpAppIconLayer
{
    self.warningIcon.layer.masksToBounds = YES;
    self.warningIcon.layer.cornerRadius = 12;
}

- (void)setupOptionsLabel
{
    NSString* currentAppName = [[[NSBundle mainBundle] infoDictionary] objectForKey:(NSString *)kCFBundleNameKey];;
    self.optionsLabel.text = [self.optionsLabel.text stringByReplacingOccurrencesOfString:@"[App Name]" withString:currentAppName];
}

- (void)updateWarningLabels
{
    DAFAuthenticationWarning *warning = [DAFAppBase getInstance].authWarning;

    if (warning == nil)
    {
        NSLog(@"SentegrityTAF_AuthWarningViewController: invoked when no warning available!");
        return;
    }

    self.warningIcon.image = warning.icon;
    self.warningMessage.text = warning.message;
    [self.okButton setTitle:warning.okActionText forState:UIControlStateNormal];
    [self.cancelButton setTitle:warning.cancelActionText forState:UIControlStateNormal];
}

- (void)updateUIForNotification:(enum DAFUINotification)event
{
    if (event==AuthWithWarnCancelled)
    {
        // We were interrupted by another request
        // Ensure this VC is dismissed if it's showing, and the result is cancelled
        NSLog(@"SentegrityTAF_AuthWarningViewController: cancelling");
        [self dismissViewControllerAnimated:NO completion: ^{
            if ( result != nil )
            {
                [result setError:[NSError errorWithDomain:@"SentegrityTAF_AuthWarningViewController"
                                                     code:101
                                                 userInfo:@{NSLocalizedDescriptionKey:@"AuthWithWarn VC interrupted"} ]];
            }
            result = nil;
        }];
    }
}

- (IBAction)onContinueEasyActivation:(id)sender
{
    NSLog(@"SentegrityTAF_AuthWarningViewController: onContinueEasyActivation");
    
    [self dismissViewControllerAnimated:NO completion: ^{
        NSLog(@"SentegrityTAF_AuthWarningViewController: delivering auth token");
#warning dummy
        NSData *authToken = [NSData dataWithBytes:"dummy" length:5];
        [result setResult:authToken];
        result = nil;
    }];
}

- (IBAction)onCancel:(id)sender {
    [self dismissViewControllerAnimated:NO completion: ^{
        [[DAFAppBase getInstance] cancelAuthenticateWithWarn:result];
        result = nil;
    }];
}

@end
