//
//  TopicCommentCell.m
//  Coding_iOS
//
//  Created by 王 原闯 on 14-8-27.
//  Copyright (c) 2014年 Coding. All rights reserved.
//

#define kTopicCommentCell_FontContent [UIFont systemFontOfSize:15]

#import "TopicCommentCell.h"

#import "UICustomCollectionView.h"
#import "TopicCommentCCell.h"

#import "MJPhotoBrowser.h"

@interface TopicCommentCell ()<UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout>
@property (strong, nonatomic) UIImageView *ownerIconView;
@property (strong, nonatomic) UILabel *timeLabel;
@property (strong, nonatomic) UICustomCollectionView *imageCollectionView;
@end

@implementation TopicCommentCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.backgroundColor = [UIColor clearColor];
        CGFloat curBottomY = 10;
        if (!_ownerIconView) {
            _ownerIconView = [[UIImageView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth, curBottomY, 33, 33)];
            [_ownerIconView doCircleFrame];
            [self.contentView addSubview:_ownerIconView];
        }
        CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
        if (!_contentLabel) {
            _contentLabel = [[UITTTAttributedLabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 40, curBottomY, curWidth, 30)];
            _contentLabel.textColor = [UIColor colorWithHexString:@"0x222222"];
            _contentLabel.font = kTopicCommentCell_FontContent;
            _contentLabel.linkAttributes = kLinkAttributes;
            _contentLabel.activeLinkAttributes = kLinkAttributesActive;
            [self.contentView addSubview:_contentLabel];
        }
        CGFloat commentBtnWidth = 40;
        if (!_timeLabel) {
            _timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(kPaddingLeftWidth +40, 0, curWidth- commentBtnWidth, 20)];
            _timeLabel.textColor = [UIColor colorWithHexString:@"0x999999"];
            _timeLabel.font = [UIFont systemFontOfSize:12];
            [self.contentView addSubview:_timeLabel];
        }
        if ([reuseIdentifier isEqualToString:kCellIdentifier_TopicComment_Media]) {
            if (!self.imageCollectionView) {
                UICollectionViewFlowLayout *layout = [[UICollectionViewFlowLayout alloc] init];
                self.imageCollectionView = [[UICustomCollectionView alloc] initWithFrame:CGRectMake(kPaddingLeftWidth + 40, 0, curWidth, 43) collectionViewLayout:layout];
                self.imageCollectionView.scrollEnabled = NO;
                [self.imageCollectionView setBackgroundView:nil];
                [self.imageCollectionView setBackgroundColor:[UIColor clearColor]];
                [self.imageCollectionView registerClass:[TopicCommentCCell class] forCellWithReuseIdentifier:kCCellIdentifier_TopicCommentCCell];
                self.imageCollectionView.dataSource = self;
                self.imageCollectionView.delegate = self;
                [self.contentView addSubview:self.imageCollectionView];
            }
        }
    }
    return self;
}

- (void)setToComment:(ProjectTopic *)toComment{
    _toComment = toComment;
    
    if (!_toComment) {
        return;
    }
    CGFloat curBottomY = 10;
    CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
    [_ownerIconView sd_setImageWithURL:[_toComment.owner.avatar urlImageWithCodePathResizeToView:_ownerIconView] placeholderImage:kPlaceholderMonkeyRoundView(_ownerIconView)];
    [_contentLabel setLongString:_toComment.content withFitWidth:curWidth];
    
    for (HtmlMediaItem *item in _toComment.htmlMedia.mediaItems) {
        if (item.displayStr.length > 0 && !(item.type == HtmlMediaItemType_Code ||item.type == HtmlMediaItemType_EmotionEmoji)) {
            [_contentLabel addLinkToTransitInformation:[NSDictionary dictionaryWithObject:item forKey:@"value"] withRange:item.range];
        }
    }
    
    curBottomY += [_toComment.content getHeightWithFont:kTopicCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5;
    
    NSInteger imagesCount = _toComment.htmlMedia.imageItems.count;
    if (imagesCount > 0) {
        self.imageCollectionView.hidden = NO;
        [self.imageCollectionView setFrame:CGRectMake(kPaddingLeftWidth +40, curBottomY, curWidth, [TopicCommentCell imageCollectionViewHeightWithCount:imagesCount])];
        [self.imageCollectionView reloadData];
    }else{
        self.imageCollectionView.hidden = YES;
    }
    
    curBottomY += [TopicCommentCell imageCollectionViewHeightWithCount:imagesCount];
    
    [_timeLabel setY:curBottomY];
    _timeLabel.text = [NSString stringWithFormat:@"%@ 发布于 %@", _toComment.owner.name, [_toComment.created_at stringDisplay_HHmm]];
}

+ (CGFloat)cellHeightWithObj:(id)obj{
    CGFloat cellHeight = 0;
    if ([obj isKindOfClass:[ProjectTopic class]]) {
        ProjectTopic *toComment = (ProjectTopic *)obj;
        CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
        cellHeight += 10 +[toComment.content getHeightWithFont:kTopicCommentCell_FontContent constrainedToSize:CGSizeMake(curWidth, CGFLOAT_MAX)] + 5 +20 +10;
        cellHeight += [self imageCollectionViewHeightWithCount:toComment.htmlMedia.imageItems.count];
    }
    return cellHeight;
}

+ (CGFloat)imageCollectionViewHeightWithCount:(NSInteger)countNum{
    if (countNum <= 0) {
        return 0;
    }
    CGFloat curWidth = kScreen_Width - 40 - 2*kPaddingLeftWidth;
    NSInteger numInOneLine = floorf((curWidth +5)/(33 + 5));
    NSInteger numOfline = ceilf(countNum/(float)numInOneLine);
    return (43 *numOfline);
}

#pragma mark Collection M
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return _toComment.htmlMedia.imageItems.count;
}

// The cell that is returned must be retrieved from a call to -dequeueReusableCellWithReuseIdentifier:forIndexPath:
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    TopicCommentCCell *ccell = [collectionView dequeueReusableCellWithReuseIdentifier:kCCellIdentifier_TopicCommentCCell forIndexPath:indexPath];
    ccell.curMediaItem = [_toComment.htmlMedia.imageItems objectAtIndex:indexPath.row];
    return ccell;
}
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [TopicCommentCCell ccellSize];
}
- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    return UIEdgeInsetsZero;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    return 10;
}
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    return 5;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    //        显示大图
    int count = (int)_toComment.htmlMedia.imageItems.count;
    NSMutableArray *photos = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i<count; i++) {
        HtmlMediaItem *imageItem = [_toComment.htmlMedia.imageItems objectAtIndex:i];
        MJPhoto *photo = [[MJPhoto alloc] init];
        photo.url = [NSURL URLWithString:imageItem.src]; // 图片路径
        [photos addObject:photo];
    }
    // 2.显示相册
    MJPhotoBrowser *browser = [[MJPhotoBrowser alloc] init];
    browser.currentPhotoIndex = indexPath.row; // 弹出相册时显示的第一张图片是？
    browser.photos = photos; // 设置所有的图片
    [browser show];
}

@end
