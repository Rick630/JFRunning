//
//  CFJourneyDao.m
//  JFRunning
//
//  Created by Rick on 1/19/17.
//  Copyright © 2017 RIck. All rights reserved.
//

#import "CFJourneyDao.h"

#define JOURNEY_TABLE @"Journey"

@implementation CFJourneyDao

@synthesize context = _context;
@synthesize coordinator = _coordinator;
@synthesize objectModel = _objectModel;

#pragma mark - lazyloading
- (NSManagedObjectModel *)objectModel
{
    if(_objectModel)
    {
        return _objectModel;
    }
    
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"DB" withExtension:@"momd"];
    _objectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelUrl];
    
    return _objectModel;
}

- (NSManagedObjectContext *)context
{
    if(_context)
    {
        return _context;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self coordinator];
    if(coordinator)
    {
        _context = [[NSManagedObjectContext alloc] initWithConcurrencyType:NSPrivateQueueConcurrencyType];
        [_context setPersistentStoreCoordinator:coordinator];
    }
    
    return _context;
}

- (NSPersistentStoreCoordinator *)coordinator
{
    if(_coordinator)
    {
        return _coordinator;
    }
    
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"JourneyDB.sqlite"];
    
    NSError *error = nil;
    _coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self objectModel]];
    
    if(![_coordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:nil error:&error])
    {
        NSLog(@"error : %@", error.userInfo);
        abort();
    }
    
    return _coordinator;
}
#pragma mark - api
- (void)insertJourney:(CFJourney *)journey
{
    Journey *dbModel = [NSEntityDescription insertNewObjectForEntityForName:JOURNEY_TABLE inManagedObjectContext:self.context];
    
    dbModel.startTime = journey.startTime;
    dbModel.finishTime = journey.finishTime;
    dbModel.distance = journey.distance;
    dbModel.locations = [NSKeyedArchiver archivedDataWithRootObject:journey.locations];
    dbModel.maxV = journey.maxV;
    dbModel.minV = journey.minV;
    
    [self saveContext];
}

- (void)deleteJourney:(CFJourney *)journey
{
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:JOURNEY_TABLE inManagedObjectContext:self.context];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entityDesc];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"startTime = %@", journey.startTime];
    [request setPredicate:predicate];
    
    NSError *error = nil;
    NSArray *queryList = [self.context executeFetchRequest:request error:&error];
    
    for(Journey *r in queryList)
    {
        [self.context deleteObject:r];
        [self saveContext];
    }
}

- (NSArray<CFJourney *> *)queryWithPage:(NSInteger)page
{
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setFetchLimit:DB_PAGE_SIZE]; //每页10条
    [request setFetchOffset:page];
    
    NSEntityDescription *entityDesc = [NSEntityDescription entityForName:JOURNEY_TABLE inManagedObjectContext:self.context];
    [request setEntity:entityDesc];
    
    NSSortDescriptor *sort = [[NSSortDescriptor alloc] initWithKey:@"startTime" ascending:NO];
    [request setSortDescriptors:@[sort]];
    
    NSError *error = nil;
    NSArray *queryList = [self.context executeFetchRequest:request error:&error];
    
    NSMutableArray *list = [NSMutableArray new];
    for(Journey *r in queryList)
    {
        CFJourney *journey = [CFJourney new];
        journey.startTime = r.startTime;
        journey.finishTime = r.finishTime;
        journey.locations = [NSKeyedUnarchiver unarchiveObjectWithData:r.locations];
        journey.distance = r.distance;
        journey.maxV = r.maxV;
        journey.minV = r.minV;
        
        [list addObject:journey];
    }
    
    return list.copy;
}

#pragma mark - function

- (void)saveContext
{
    if(self.context == nil) return;
    
    NSError *error = nil;
    if([self.context hasChanges] && ![self.context save:&error])
    {
        NSLog(@"error : %@", error.userInfo);
        abort();
    }
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
