
//
//  ViewController.m
//  wechatplus
//
//  Created by JohnTai on 10/16/15.
//  Copyright © 2015 baozoumanhua. All rights reserved.
//

#import "ViewController.h"
#import <HealthKit/HealthKit.h>

#import "HealthManager.h"

@interface ViewController ()


@property (nonatomic,strong) HKHealthStore *healthStore;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.inputField setPlaceholder:@"请输入要增加的步数"];
    
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)buttonClicked:(id)sender {

  //  [self getStep];
   // return;
    
    
    [self.inputField resignFirstResponder];
    
    //define unit.
    NSString *unitIdentifier = HKQuantityTypeIdentifierStepCount;
    
    //define quantityType.
    HKQuantityType *quantityTypeIdentifier = [HKObjectType quantityTypeForIdentifier:unitIdentifier];
    
    //init quantity.
    HKQuantity *quantity = [HKQuantity quantityWithUnit:[HKUnit countUnit] doubleValue:[self.inputField.text integerValue]];
    
    //init quantity sample.
    HKQuantitySample *temperatureSample = [HKQuantitySample quantitySampleWithType:quantityTypeIdentifier quantity:quantity startDate:[NSDate date] endDate:[NSDate date] metadata:nil];
    
    //init store object.
    HKHealthStore *store = [[HKHealthStore alloc] init];
    
    //save.
    [store saveObject:temperatureSample withCompletion:^(BOOL success, NSError *error) {
        if (success) {
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"保存成功" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
        }else {
            
            dispatch_async(dispatch_get_main_queue(), ^(){
                UIAlertView * alertView = [[UIAlertView alloc] initWithTitle:@"保存失败" message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
                [alertView show];
            });
        }
    }];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
    [self.inputField resignFirstResponder];
}


- (void)getStep{
    
    [[HealthManager shareInstance] getKilocalorieUnit:[HealthManager predicateForSamplesToday] quantityType:[HKQuantityType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned] completionHandler:^(double value, NSError *error) {
        if(error)
        {
            NSLog(@"error = %@",[error.userInfo objectForKey:NSLocalizedDescriptionKey]);
        }
        else
        {
            NSLog(@"获取到的卡路里 ＝ %.2lf",value);
        }
    }];
    
    [[HealthManager shareInstance] getRealTimeStepCountCompletionHandler:^(double value, NSError *error) {
        if(!error)
        {
            NSLog(@"当天行走步数 = %.2lf",value);
            self.inputField.text = [NSString stringWithFormat:@"%.f",value];

        }
    }];
    
    
    
    //获取十天内的步数
    //日期在十天之内:
    NSDate *endDate = [NSDate date];
    NSTimeInterval timeInterval= [endDate timeIntervalSinceReferenceDate];
    timeInterval -=3600*24*10;
    NSDate *beginDate = [NSDate dateWithTimeIntervalSinceReferenceDate:timeInterval];
    //对coredata进行筛选(假设有fetchRequest)
    NSPredicate *predicate_date =
    [NSPredicate predicateWithFormat:@"endDate >= %@ AND startDate <= %@", beginDate,endDate];
    
    [[HealthManager shareInstance] getStepCount:predicate_date completionHandler:^(double value, NSError *error) {
        if(!error)
        NSLog(@"10天行走步数 = %.2lf",value);
    }];
    
    

}



- (void)isCheck{
    if ([HKHealthStore isHealthDataAvailable]) {
        self.healthStore = [[HKHealthStore alloc] init];
        NSSet *writeDataTypes = [self dataTypesToWrite];
        NSSet *readDataTypes = [self dataTypesToRead];
        [self.healthStore requestAuthorizationToShareTypes:writeDataTypes readTypes:readDataTypes completion:^(BOOL success, NSError *error) {
            
            if (!success) {
                NSLog(@"You didn't allow HealthKit to access these read/write data types. In your app, try to handle this error gracefully when a user decides not to provide access. The error was: %@. If you're using a simulator, try it on a device.", error);
                return; }
            else{
                    [self getStep];
                }
            
         
        }];
    }
}
- (NSSet *)dataTypesToWrite {
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    return [NSSet setWithObjects:stepCountType,  nil];
}

// Returns the types of data that Fit wishes to read from HealthKit.
- (NSSet *)dataTypesToRead {
    HKQuantityType *dietaryCalorieEnergyType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierDietaryEnergyConsumed];
    HKQuantityType *activeEnergyBurnType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierActiveEnergyBurned];
    HKQuantityType *heightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierHeight];
    HKQuantityType *weightType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBodyMass];
    HKCharacteristicType *birthdayType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierDateOfBirth];
    HKCharacteristicType *biologicalSexType = [HKObjectType characteristicTypeForIdentifier:HKCharacteristicTypeIdentifierBiologicalSex];
    
    
    HKQuantityType *HKQuant = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierBasalEnergyBurned];
    
    
    
    //步数
    HKQuantityType *stepCountType = [HKObjectType quantityTypeForIdentifier:HKQuantityTypeIdentifierStepCount];
    
    return [NSSet setWithObjects: dietaryCalorieEnergyType, activeEnergyBurnType, heightType, weightType, birthdayType,  HKQuant,stepCountType, biologicalSexType, nil];
}

@end
