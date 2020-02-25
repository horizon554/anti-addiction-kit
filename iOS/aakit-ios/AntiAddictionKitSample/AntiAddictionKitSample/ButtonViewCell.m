
#import "ButtonViewCell.h"

@implementation ButtonViewCell

- (instancetype)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self didInitialize];
    }
    return self;
}

- (void)didInitialize {
    _textLabel = [UILabel new];
    _textLabel.frame = self.contentView.bounds;
    [self.contentView addSubview:_textLabel];
    _textLabel.font = [UIFont boldSystemFontOfSize:15];
    _textLabel.numberOfLines = 0;
    _textLabel.textAlignment = NSTextAlignmentCenter;
    _textLabel.textColor = UIColor.systemBlueColor;
    
    self.contentView.clipsToBounds = YES;
    self.contentView.layer.cornerRadius = 8;
    self.contentView.layer.borderWidth = 1;
    self.contentView.layer.borderColor = UIColor.systemBlueColor.CGColor;
}

@end
