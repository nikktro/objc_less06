//
//  ViewController.m
//  less06
//
//  Created by Nikolay Trofimov on 28.10.2020.
//

#import "ViewController.h"

@interface ViewController ()

@end

// with arguments, // with output
int (^sum)(int, int) = ^(int first, int second) {
    return first + second;
};

// without arguments, // without output
void (^helloWorld)(void) = ^{
    NSLog(@"Hello, World!");
};


// random password generator with length
void (^randomPassword)(int) = ^(int length) {
    NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
    NSMutableString *randomString = [NSMutableString stringWithCapacity: length];
    
    for (int i = 0; i < length; i++) {
        int randomIndex = arc4random() % [letters length];
        [randomString appendString: [letters substringWithRange:NSMakeRange(randomIndex, 1)]];
    }
    NSLog(@"%@", randomString);
};

// return factorial for number
int (^factorial)(int) = ^(int factor) {
    int number = 1;
    for (int i = number; i <= factor; i++) {
        number*=i;
    }
    return number;
};

// func that generates random number 0...10
int randomNumberFunc() {
    return arc4random() % 10;
}

// run function
// block that returns 'randomNumberFunc' output
int (^blockRandomNumber)(void) = ^{
    return randomNumberFunc();
    //return arc4random() % 10;
    
};


//naming block, name IntToString as type
typedef NSString * (^IntToString)(int intValue);
typedef int(^SquareBlock)(int);


@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    // Task 1. Попрактиковаться с применением блоков:
    // создать программу для вывода сообщений в консоль
    // с использованием минимум 6 блоков.
    
    
    // block that returns Sum of inputs
    NSLog(@"%i", sum(5,7));
    
    // no input, nothing returns
    helloWorld(); // Hello, World!
    
    // typedef block IntToString
    NSString *some = [self getStrFrom:12345678 using:^NSString *(int intValue) {
        return [NSString stringWithFormat:@"%d", intValue];
    }];
    NSLog(@"%@", some); // "12345678"
    
    // typedef block SquareBlock
    SquareBlock square = ^(int number) {
        return number * number;
    };
    NSLog(@"%i", square(9)); //81
    
    // random password with length 15 symbols
    randomPassword(15);
    
    // get factorial of 5
    NSLog(@"%i", factorial(5));

    // run function with block (generate random number)
    NSLog(@"%i", blockRandomNumber());
    
    
    // sort array with block
    NSArray *array = @[@4, @1, @0, @2, @5, @3, @2];
    NSArray *sorted = [array sortedArrayUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSInteger first = [obj1 intValue];
        NSInteger second = [obj2 intValue];
        if (first > second) {
            return NSOrderedDescending;
        } else if (first < second) {
            return NSOrderedAscending;
        } else {
            NSLog(@"Sorting: Same values");
            return NSOrderedSame;
        }
    }];
    NSLog(@"Sorted array: %@", sorted); // 0, 1, 2, 2, 3, 4, 5
    
    
    
    //CAPTURING VALUES
    // capturing value when block creates
    int first = 30;
    int second = 20;
    
    int (^substraction)(void) = ^{  // ^(void) {
        return first - second;
    };
    
    int firstResult = substraction();
    NSLog(@"%d - %d = %d (+Correct, new block create+)", first, second, firstResult); // CORRECT 10
    
    first = 50;
    second = 100;
    
    // no new values used, already captured previous values
    int secondResult = substraction();
    NSLog(@"%d - %d = %d (-Wrong, pervious values captured-)", first, second, secondResult); // WRONG 10
    
    // with '__block' block get values from scope
    __block int third = 20;
    __block int forth = 30;
    
    int (^sum)(void) = ^{
        return third + forth;
    };
    
    // used third = 20, forth = 30
    int thirdResult = sum(); // 50
    NSLog(@"%d + %d = %d (+Correct, new block create+)", third, forth, thirdResult); // CORRECT 50
    
    third = 40;
    forth = 20;
    
    // used third = 40, forth = 20
    int forthResult = sum(); // 60
    NSLog(@"%d + %d = %d (+Correct, new values via '__block'+)", third, forth, forthResult); // CORRECT 60
    
    
    // Task 2. Добавить выполнение блоков в различные очереди с применением GCD.
    
    //DISPATCH_QUEUE
    dispatch_queue_t globalQueue = dispatch_get_global_queue(QOS_CLASS_DEFAULT, 0);

    __block int one = 40;
    __block int two = 60;
    
    int (^multiply)(void) = ^{
        return one * two;
    };
    
    NSLog(@"--Sync--");
    // SYNC - step by step. first output 500, then 10000
    dispatch_sync(globalQueue, ^{
        sleep(2);
        one = 20;
        two = 25;
        NSLog(@"%d",multiply()); // 500
    });
    
    dispatch_sync(globalQueue, ^{
        sleep(1);
        one = 100;
        two = 100;
        NSLog(@"%d",multiply()); // 10000
    });
    
    NSLog(@"---can run next with sync---"); // runs AFTER multiply calculation
    
    NSLog(@"--ASync--");
    // ASYNC - parallel running. first output 10000, then 500
    dispatch_async(globalQueue, ^{
        sleep(2);
        one = 20;
        two = 25;
        NSLog(@"%d",multiply()); // 500
    });
    
    dispatch_async(globalQueue, ^{
        sleep(1);
        one = 100;
        two = 100;
        NSLog(@"%d",multiply()); // 10000
    });
    
    NSLog(@"---can run next with ASYNC---"); // runs BEFORE multiply calculation
    
}

- (NSString *)getStrFrom:(int)intValue using:(IntToString)block {
    return block(intValue);
}

@end
