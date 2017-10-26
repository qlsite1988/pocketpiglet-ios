#import <GoogleMobileAds/GADMobileAds.h>
#import <GoogleMobileAds/GADRequest.h>
#import <GoogleMobileAds/GADRewardBasedVideoAd.h>
#import <GoogleMobileAds/GADRewardBasedVideoAdDelegate.h>

#include <QtCore/QDebug>

#include "admobhelper.h"

const QString AdMobHelper::ADMOB_APP_ID                    ("ca-app-pub-2455088855015693~5306005769");
const QString AdMobHelper::ADMOB_REWARDBASEDVIDEOAD_UNIT_ID("ca-app-pub-3940256099942544/1712485313");
const QString AdMobHelper::ADMOB_TEST_DEVICE_ID            ("");

AdMobHelper *AdMobHelper::Instance = NULL;

@interface RewardBasedVideoAdDelegate : NSObject<GADRewardBasedVideoAdDelegate>

- (id)init;
- (void)loadAd;

@end

@implementation RewardBasedVideoAdDelegate

- (id)init
{
    self = [super init];

    if (self) {
        [GADRewardBasedVideoAd sharedInstance].delegate = self;
    }

    return self;
}

- (void)loadAd
{
    GADRequest *request = [GADRequest request];

    if (AdMobHelper::ADMOB_TEST_DEVICE_ID != "") {
        request.testDevices = @[ AdMobHelper::ADMOB_TEST_DEVICE_ID.toNSString() ];
    }

    [[GADRewardBasedVideoAd sharedInstance] loadRequest:request
                                            withAdUnitID:AdMobHelper::ADMOB_REWARDBASEDVIDEOAD_UNIT_ID.toNSString()];
}

- (void)rewardBasedVideoAdDidReceiveAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    Q_UNUSED(rewardBasedVideoAd)
}

- (void)rewardBasedVideoAdDidOpen:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    Q_UNUSED(rewardBasedVideoAd)

    AdMobHelper::setRewardBasedVideoAdActive(true);
}

- (void)rewardBasedVideoAdDidStartPlaying:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    Q_UNUSED(rewardBasedVideoAd)
}

- (void)rewardBasedVideoAdDidClose:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    Q_UNUSED(rewardBasedVideoAd)

    AdMobHelper::setRewardBasedVideoAdActive(false);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:0.0];
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didRewardUserWithReward:(GADAdReward *)reward {
    Q_UNUSED(rewardBasedVideoAd)

    AdMobHelper::rewardBasedVideoAdDidReward(QString::fromNSString(reward.type), (int)[reward.amount integerValue]);
}

- (void)rewardBasedVideoAdWillLeaveApplication:(GADRewardBasedVideoAd *)rewardBasedVideoAd {
    Q_UNUSED(rewardBasedVideoAd)
}

- (void)rewardBasedVideoAd:(GADRewardBasedVideoAd *)rewardBasedVideoAd didFailToLoadWithError:(NSError *)error {
    Q_UNUSED(rewardBasedVideoAd)

    qWarning() << QString::fromNSString([error localizedDescription]);

    [self performSelector:@selector(loadAd) withObject:nil afterDelay:10.0];
}

@end

AdMobHelper::AdMobHelper(QObject *parent) : QObject(parent)
{
    Initialized                        = false;
    RewardBasedVideoAdActive           = false;
    Instance                           = this;
    RewardBasedVideoAdDelegateInstance = NULL;
}

AdMobHelper::~AdMobHelper()
{
    if (Initialized) {
        [RewardBasedVideoAdDelegateInstance release];
    }
}

bool AdMobHelper::rewardBasedVideoAdReady() const
{
    if (Initialized) {
        return [[GADRewardBasedVideoAd sharedInstance] isReady];
    } else {
        return false;
    }
}

bool AdMobHelper::rewardBasedVideoAdActive() const
{
    return RewardBasedVideoAdActive;
}

void AdMobHelper::initialize()
{
    if (!Initialized) {
        [GADMobileAds configureWithApplicationID:ADMOB_APP_ID.toNSString()];

        RewardBasedVideoAdDelegateInstance = [[RewardBasedVideoAdDelegate alloc] init];

        [RewardBasedVideoAdDelegateInstance loadAd];

        Initialized = true;
    }
}

void AdMobHelper::showRewardBasedVideoAd()
{
    if (Initialized) {
        UIViewController * __block rootViewController = nil;

        [[[UIApplication sharedApplication] windows] enumerateObjectsUsingBlock:^(UIWindow * _Nonnull window, NSUInteger, BOOL * _Nonnull stop) {
            rootViewController = [window rootViewController];

            *stop = (rootViewController != nil);
        }];

        if ([[GADRewardBasedVideoAd sharedInstance] isReady]) {
            [[GADRewardBasedVideoAd sharedInstance] presentFromRootViewController:rootViewController];
        }
    }
}

void AdMobHelper::setRewardBasedVideoAdActive(const bool &active)
{
    Instance->RewardBasedVideoAdActive = active;

    emit Instance->rewardBasedVideoAdActiveChanged(Instance->RewardBasedVideoAdActive);
}

void AdMobHelper::rewardBasedVideoAdDidReward(const QString &type, const int &amount)
{
    emit Instance->rewardBasedVideoAdNewReward(type, amount);
}