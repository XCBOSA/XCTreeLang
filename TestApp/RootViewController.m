//
//  ViewController.m
//  TestApp
//
//  Created by 邢铖 on 2023/6/1.
//

#import "RootViewController.h"
#import <XCTreeLang/XCTreeLang.h>

@interface RootViewController () <UITextViewDelegate, XCTLStreamDelegate>

@property (nonatomic, strong) UITextView *sourceTextView;
@property (nonatomic, strong) UITextView *terminalTextView;
@property (nonatomic, strong) UIButton *runButton;

@end

@implementation RootViewController

- (void)viewDidLoad {
    [self.view addSubview:self.sourceTextView];
    [self.view addSubview:self.terminalTextView];
    [self.view addSubview:self.runButton];
    [self.sourceTextView.leftAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.leftAnchor].active = true;
    [self.sourceTextView.topAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.topAnchor].active = true;
    [self.sourceTextView.rightAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.rightAnchor].active = true;
    [self.terminalTextView.topAnchor constraintEqualToAnchor:self.sourceTextView.bottomAnchor].active = true;
    [self.terminalTextView.leftAnchor constraintEqualToAnchor:self.sourceTextView.leftAnchor].active = true;
    [self.terminalTextView.rightAnchor constraintEqualToAnchor:self.sourceTextView.rightAnchor].active = true;
    [self.terminalTextView.bottomAnchor constraintEqualToAnchor:self.view.safeAreaLayoutGuide.bottomAnchor].active = true;
    [self.sourceTextView.heightAnchor constraintEqualToAnchor:self.terminalTextView.heightAnchor multiplier:2].active = true;
    [self.runButton.rightAnchor constraintEqualToAnchor:self.sourceTextView.rightAnchor constant:-10].active = true;
    [self.runButton.bottomAnchor constraintEqualToAnchor:self.sourceTextView.bottomAnchor constant:-10].active = true;
    [self.runButton.widthAnchor constraintEqualToConstant:108].active = true;
    [self.runButton.heightAnchor constraintEqualToConstant:38].active = true;
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
        _sourceTextView.text = [NSUserDefaults.standardUserDefaults stringForKey:@"code"];
        _sourceTextView.delegate = self;
    }
    return _sourceTextView;
}

- (UITextView *)terminalTextView {
    if (!_terminalTextView) {
        _terminalTextView = [self makeTextView];
        _terminalTextView.backgroundColor = UIColor.secondarySystemBackgroundColor;
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

- (void)runButtonDidTouchUp {
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

- (void)stream:(XCTLStream *)stream appendText:(NSString *)text {
    self.terminalTextView.text = [self.terminalTextView.text stringByAppendingString:text];
}

- (void)textViewDidChange:(UITextView *)textView {
    [NSUserDefaults.standardUserDefaults setValue:textView.text forKey:@"code"];
}

@end
