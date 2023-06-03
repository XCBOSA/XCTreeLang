//
//  ViewController.m
//  TestApp
//
//  Created by 邢铖 on 2023/6/1.
//

#import "RootViewController.h"
#import <XCTreeLang/XCTreeLang.h>

char *kRootViewControllerKVOKey = "kRootViewControllerKVOKey";

@interface RootViewController () <UITextViewDelegate, XCTLStreamDelegate>

@property (nonatomic, strong) UITextView *sourceTextView;
@property (nonatomic, strong) UITextView *terminalTextView;
@property (nonatomic, strong) UIButton *runButton;
@property (nonatomic, strong) UIView *previewViewControllerContext;
@property (nonatomic, strong) UIViewController *previewViewController;
@property (nonatomic, copy) NSArray<NSLayoutConstraint *> *previewConstraints;

@property (nonatomic, strong) UIView *testView;

@end

@implementation RootViewController

- (UIView *)testView {
    if (!_testView) {
        _testView = [[UIButton alloc] initWithFrame:CGRectMake(100, 100, 100, 100)];
    }
    return _testView;
}

- (void)viewDidLoad {
    [self.view addSubview:self.sourceTextView];
    [self.view addSubview:self.terminalTextView];
    [self.view addSubview:self.runButton];
    [self.view addSubview:self.previewViewControllerContext];
    
    [self.previewViewControllerContext.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor].active = true;
    [self.previewViewControllerContext.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = true;
    [self.previewViewControllerContext.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = true;
    [self.previewViewControllerContext.widthAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.widthAnchor multiplier:0.3].active = true;
    
    [self.sourceTextView.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor].active = true;
    [self.sourceTextView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = true;
    [self.sourceTextView.rightAnchor constraintEqualToAnchor:self.previewViewControllerContext.leftAnchor].active = true;
    [self.sourceTextView.heightAnchor constraintEqualToAnchor:self.terminalTextView.heightAnchor multiplier:2].active = true;
    
    [self.terminalTextView.topAnchor constraintEqualToAnchor:self.sourceTextView.bottomAnchor].active = true;
    [self.terminalTextView.leftAnchor constraintEqualToAnchor:self.sourceTextView.leftAnchor].active = true;
    [self.terminalTextView.rightAnchor constraintEqualToAnchor:self.sourceTextView.rightAnchor].active = true;
    [self.terminalTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = true;
    
    [self.runButton.rightAnchor constraintEqualToAnchor:self.sourceTextView.rightAnchor constant:-10].active = true;
    [self.runButton.bottomAnchor constraintEqualToAnchor:self.sourceTextView.bottomAnchor constant:-10].active = true;
    [self.runButton.widthAnchor constraintEqualToConstant:108].active = true;
    [self.runButton.heightAnchor constraintEqualToConstant:38].active = true;
    
    [self addObserver:self
           forKeyPath:@"previewViewController"
              options:NSKeyValueObservingOptionOld
              context:kRootViewControllerKVOKey];
    
    [self addObserver:self
           forKeyPath:@"previewViewController"
              options:NSKeyValueObservingOptionNew
              context:kRootViewControllerKVOKey];
    
    [super viewDidLoad];
}

- (UITextView *)makeTextView {
    UITextView *textView = [UITextView new];
    textView.translatesAutoresizingMaskIntoConstraints = false;
    textView.font = [UIFont fontWithName:@"Menlo" size:16];
    textView.backgroundColor = UIColor.systemBackgroundColor;
    textView.allowsEditingTextAttributes = false;
    textView.contentMode = UIViewContentModeRedraw;
    textView.autocorrectionType = UITextAutocorrectionTypeNo;
    textView.smartQuotesType = UITextSmartQuotesTypeNo;
    textView.smartDashesType = UITextSmartDashesTypeNo;
    textView.smartInsertDeleteType = UITextSmartInsertDeleteTypeNo;
    textView.autocapitalizationType = UITextAutocapitalizationTypeNone;
    textView.spellCheckingType = UITextSpellCheckingTypeNo;
    textView.textContentType = nil;
    textView.tintColor = UIColor.systemOrangeColor;
    textView.editable = true;
    return textView;
}

- (UITextView *)sourceTextView {
    if (!_sourceTextView) {
        _sourceTextView = [self makeTextView];
        _sourceTextView.backgroundColor = UIColor.systemBackgroundColor;
        NSString *savedCode = [NSUserDefaults.standardUserDefaults stringForKey:@"code"];
        if (savedCode == nil || savedCode.length == 0) {
            savedCode = [NSString stringWithContentsOfFile:[NSBundle.mainBundle pathForResource:@"InitialContent" ofType:@"xct"]
                                                  encoding:NSUTF8StringEncoding
                                                     error:nil];
        }
        _sourceTextView.text = savedCode;
        _sourceTextView.delegate = self;
    }
    return _sourceTextView;
}

- (UITextView *)terminalTextView {
    if (!_terminalTextView) {
        _terminalTextView = [self makeTextView];
        _terminalTextView.backgroundColor = UIColor.tertiarySystemBackgroundColor;
        _terminalTextView.editable = false;
    }
    return _terminalTextView;
}

- (UIButton *)runButton {
    if (!_runButton) {
        _runButton = [UIButton new];
        _runButton.translatesAutoresizingMaskIntoConstraints = false;
        _runButton.layer.cornerRadius = 10;
        _runButton.backgroundColor = UIColor.systemFillColor;
        [_runButton setTitleColor:UIColor.systemOrangeColor forState:UIControlStateNormal];
        [_runButton setTitle:@"Run Code" forState:UIControlStateNormal];
        [_runButton addTarget:self
                       action:@selector(runButtonDidTouchUp)
             forControlEvents:UIControlEventTouchUpInside];
    }
    return _runButton;
}

- (UIView *)previewViewControllerContext {
    if (!_previewViewControllerContext) {
        _previewViewControllerContext = [UIView new];
        _previewViewControllerContext.translatesAutoresizingMaskIntoConstraints = false;
        _previewViewControllerContext.backgroundColor = UIColor.secondarySystemBackgroundColor;
    }
    return _previewViewControllerContext;
}

- (void)runButtonDidTouchUp {
    [self clearPreviewWithViewController:self.previewViewController];
    _previewViewController = nil;
    
    self.terminalTextView.text = @"";
    XCTLAST *program = [XCTLEngine.shared compileWithCode:self.sourceTextView.text];
    if (program == NULL) {
        self.terminalTextView.text = [self.terminalTextView.text stringByAppendingString:@"Compile failed, see program log for more details."];
        return;
    }
    program.stdoutDelegate = self;
    NSError *error;
    [XCTLEngine.shared evaluateWithAst:program
                          sourceObject:self
                                 error:&error];
    if (error) {
        self.terminalTextView.text = [self.terminalTextView.text stringByAppendingString:error.localizedDescription];
    }
}

- (void)updatePreview {
    if (self.previewViewController) {
        [self addChildViewController:self.previewViewController];
        [self.previewViewControllerContext addSubview:self.previewViewController.view];
        self.previewViewController.view.translatesAutoresizingMaskIntoConstraints = false;
        self.previewConstraints = @[
            [self.previewViewController.view.leftAnchor constraintEqualToAnchor:self.previewViewControllerContext.leftAnchor],
            [self.previewViewController.view.topAnchor constraintEqualToAnchor:self.previewViewControllerContext.topAnchor],
            [self.previewViewController.view.rightAnchor constraintEqualToAnchor:self.previewViewControllerContext.rightAnchor],
            [self.previewViewController.view.bottomAnchor constraintEqualToAnchor:self.previewViewControllerContext.bottomAnchor]
        ];
        for (NSLayoutConstraint *constraint in self.previewConstraints) {
            constraint.active = true;
        }
    }
}

- (void)clearPreviewWithViewController:(UIViewController *)viewController {
    if (self.previewConstraints) {
        [self.previewViewControllerContext removeConstraints:self.previewConstraints];
        self.previewConstraints = nil;
    }
    if (viewController) {
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kRootViewControllerKVOKey) {
        if ([@"previewViewController" isEqualToString:keyPath]) {
            UIViewController *oldValue = change[NSKeyValueChangeOldKey];
            if (oldValue) {
                if ([oldValue isKindOfClass:UIViewController.class]) {
                    [self clearPreviewWithViewController:oldValue];
                }
            } else {
                [self updatePreview];
            }
        }
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)stream:(XCTLStream *)stream appendText:(NSString *)text {
    self.terminalTextView.text = [self.terminalTextView.text stringByAppendingString:text];
}

- (void)textViewDidChange:(UITextView *)textView {
    [NSUserDefaults.standardUserDefaults setValue:textView.text forKey:@"code"];
}

- (void)dealloc {
    [self removeObserver:self
              forKeyPath:@"previewViewController"
                 context:kRootViewControllerKVOKey];
}

@end
