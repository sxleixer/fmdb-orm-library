//
//  FMDBORMModel.m
//  Team Wurzel
//
//  Created by Ralf Schleicher on 16.01.14.
//  Copyright (c) 2014 Team Wurzel. All rights reserved.
//

#import "FMDBORMModel.h"

@interface FMDBORMModel ()
+(NSString*)cachedStatementWithDictionary:(NSMutableDictionary* __strong *)cacheDictRef andSelector:(SEL)selector;
@end

@implementation FMDBORMModel
static NSMutableDictionary *_cachedInsertStatements;
static NSMutableDictionary *_cachedSelectStatements;
static NSMutableDictionary *_cachedUpdateStatements;
static NSMutableDictionary *_cachedDeleteStatements;

/*!
 * marks current class as abstract class
 */
+(BOOL)isAbstract {
    return YES;
}

/*!
 * Raises an error in every case.
 *
 * @return nil
 */
+(NSString *)tableName {
    [NSException raise:@"DerivationError" format:@"FMDBORMModel is designed to be an abstract class, if you're deriving from some of its subclasses please implement the tableName class method."];
    return nil;
}

/*!
 * @return a create statement for the object's table if object is not abstract
 */
+(NSString *)createStatement {
    if ([self isAbstract]) {
        [NSException raise:@"DerivationError" format:@"%@ is designed to be an abstract class, creating a table from it is discouraged", self.description];
    }
    return [FMDBORMHelper createStatementForClass:self];
}

/*!
 * @return a drop statement for the object's table
 */
+(NSString *)dropStatement {
    return [FMDBORMHelper dropStatementForClass:self];
}

/*!
 * @return a generic insert statement for every class which inherits from this class
 */
+(NSString *)genericInsertStatement {
    return [self cachedStatementWithDictionary:&_cachedInsertStatements andSelector:@selector(insertStatementForClass:)];
}

/*!
 * @return a generic select statement for every class which inherits from this class
 */
+(NSString *)genericSelectStatement {
    return [self cachedStatementWithDictionary:&_cachedSelectStatements andSelector:@selector(selectStatementForClass:)];
}

/*!
 * @return a generic update statement for every class which inherits from this class
 */
+(NSString *)genericUpdateStatement {
    return [self cachedStatementWithDictionary:&_cachedUpdateStatements andSelector:@selector(updateStatementForClass:)];
}

/*!
 * @return a generic delete statement for every class which inherits from this class
 */
+(NSString *)genericDeleteStatement {
    return [self cachedStatementWithDictionary:&_cachedDeleteStatements andSelector:@selector(deleteStatementForClass:)];
}

/*!
 * This method gets the cached statement or generates it an then caches it into a given dictionary.
 *
 * @param cacheDictRef # reference to a dictionary to save the value into
 * @param selector # selector of the FMDBORMHelper class method to use
 *
 * @return the cached statement for the given parameters
 */
+(NSString*)cachedStatementWithDictionary:(NSMutableDictionary* __strong *)cacheDictRef andSelector:(SEL)selector {
    // Get the referenced cache dictionary
    NSMutableDictionary *cacheDict = *cacheDictRef;
    
    // If the dictionary is not yet available create it.
    if (!cacheDict) {
        *cacheDictRef = [[NSMutableDictionary alloc] init];
        cacheDict = *cacheDictRef;
    }
    
    // get the class' name as dictionary key and get the cached statement from dictionary
    NSString *className = self.description;
    NSString *cachedStatement = [cacheDict objectForKey:className];
    
    // if the statement is not yet available, generate it and save it to dictionary
    if (!cachedStatement) {
        cachedStatement = [FMDBORMHelper performSelector:selector withObject:self];
        [cacheDict setObject:cachedStatement forKey:className];
    }
    
    return cachedStatement;
}

/*!
 * NOTICE: If overriding this method don't forget to call [super mapping] and merge the resulting dictionary into your own.
 *
 * @return the mapping of a uid to every class which inherits from this class
 */
+(NSDictionary *)mapping {
    FMDBORMColumn *uidColumn = [[FMDBORMColumn alloc] initWithColumnName:@"uid" andType:FMDBORMTypeInteger andExtraModifier:@[FMDBORMExtraPrimaryKey, FMDBORMExtraAutoIncrement]];
    return @{@"uid": uidColumn};
}

/*!
 * @return a new object of an arbitrary inherited class from a result set
 */
+(id)newObjectWithResultSet:(FMResultSet *)set {
    // get mapping
    NSDictionary *mapping = [self mapping];
    
    // create the object of desired class
    FMDBORMModel* object = [[self alloc] init];
    int idx = 0;
    for (NSString *key in mapping) {
        NSObject *obj = [set objectForColumnIndex:idx];
        [object setValue:obj forKey:key];
        idx += 1;
    }

    return object;
}

/*!
 * @return an array made up by an arbitrary inherited class from a result set
 */
+(NSMutableArray*)newObjectsWithResultSet:(FMResultSet*)set {
    // create an array for the set
    NSMutableArray *objectArray = [[NSMutableArray alloc] init];
    
    // traverse through every row and get the related objects from it
    while([set next]) {
        id object = [self newObjectWithResultSet:set];
        [objectArray addObject:object];
    }
    
    return objectArray;
}

/*!
 * @return an object of an arbitrary inherited class from a json object
 */
+(id)newObjectWithJSONObject:(NSDictionary*)jsonObject {
    // create an object
    FMDBORMModel *object = [[self alloc] init];
    
    // get the mapping of the class
    NSDictionary *mapping = [self mapping];
    
    // mapping every key to a objects variable
    for (NSString *key in mapping) {
        // get the referenced column and its name
        FMDBORMColumn *col = [mapping objectForKey:key];
        // set the value for the key and the jsonObject's colname
        [object setValue:[jsonObject objectForKey:col.name] forKey:key];
    }
    
    return object;
}

/*!
 * @return an array made up by an arbitrary inherited class from a json array
 */
+(NSMutableArray *)newObjectsWithJSONObjectArray:(NSArray *)jsonObjectArray {
    // create an array of the dimension of the jsonObjectArray (just to make sure no reallocation has to take place)
    NSMutableArray *objectArray = [[NSMutableArray alloc] initWithCapacity:jsonObjectArray.count];
    
    // for every item in jsonObjectArray create the related object from it
    for (NSDictionary* jsonObject in jsonObjectArray) {
        id object = [self newObjectWithJSONObject:jsonObject];
        [objectArray addObject:object];
    }
    
    return objectArray;
}

/*!
 * Creates a table in the given database
 *
 * @param db # database where to create the table into
 *
 * @return success of the operation
 */
+(BOOL)createTable:(FMDatabase *)db {
    return [db executeUpdate:[self createStatement]];
}

/*!
 * Drops a table in the given database
 *
 * @param db # database where to drop the table from
 *
 * @return success of the operation
 */
+(BOOL)dropTable:(FMDatabase *)db {
    return [db executeUpdate:[self dropStatement]];
}

/*!
 * @return an initialized object
 */
-(id)init {
    self = [super init];
    
    // if the class is explicitly declared abstract
    if ([[self class] isAbstract]) {
        [NSException raise:@"DerivationError" format:@"%@ is designed to be an abstract class. If you want %@ to be non-abstract override the +(void)isAbstract", self.description, self.description];
    }
    
    // implement the default values
    if (!self) {
        self.uid = [NSNumber numberWithInt:0];
    }
    
    return self;
}

/*!
 * In this implementation an object exists if the uid is not equal 0
 *
 * NOTICE: Override this if you want to have some other existence requirements (like a unique key in combination with uid)
 * In most cases this class should to the trick.
 *
 * @param db # database to use for existence proof
 * @return existence
 */
-(BOOL)exists:(FMDatabase*)db {
    if ([self.uid integerValue] == 0) {
        return NO;
    }
    return YES;
}

/*!
 * @return the string used to assure the row is unique
 */
-(NSString*)uniqueWhereCondition {
    return @"`uid` = ?";
}

/*!
 * @return the value used with the uniqueWhereCondition
 */
-(NSObject*)uniqueValue {
    return self.uid;
}

/*!
 * Creates or updates a row in the related object's table.
 *
 * @param db # database to put the row into
 */
-(void)put:(FMDatabase *)db {
    // Get the mapping of the current class
    NSDictionary *mapping = [[self class] mapping];
    
    // get the appropriate update string (insert or update) by defined existence method
    NSString* updateString;
    bool exists = [self exists:db];
    if (!exists) {
        updateString = [[self class] genericInsertStatement];
    } else {
        updateString = [NSString stringWithFormat:@"%@ WHERE %@",[[self class] genericUpdateStatement], [self uniqueWhereCondition]];
    }
    
    // create an array with adaptive capacity
    NSMutableArray* valueArray = [[NSMutableArray alloc] initWithCapacity:mapping.count];
    for (NSString* item in mapping) {
        if ([@"uid" isEqualToString:item]) {
            continue;
        }
        
        // get the value
        NSObject *value = [self valueForKey:item];
        // handle the null pointer problem by placeholder object NSNull
        value = (value == nil ? [NSNull null] : value);
        // add it to the array
        [valueArray addObject:value];
    }
    NSObject *uniqueValue = [self uniqueValue];
    uniqueValue = (uniqueValue == nil) ? [NSNull null] : uniqueValue;
    [valueArray addObject:uniqueValue];
    
    bool successful = [db executeUpdate:updateString withArgumentsInArray:valueArray];
    
    // if successful and not set, save the resulting uid to uid.
    if (successful && [self.uid integerValue] == 0) {
        self.uid = [NSNumber numberWithInt:db.lastInsertRowId];
    }
}

/*!
 * Deletes the object related row in database. Not more, not less.
 *
 * @param db # database to delete from
 */
-(void)erase:(FMDatabase *)db {
    NSString *deleteString = [NSString stringWithFormat:@"%@ WHERE %@",[[self class] genericDeleteStatement], [self uniqueWhereCondition]];
    
    // delete it and if successfully, set uid to zero.
    bool successful = [db executeUpdate:deleteString];
    if (successful) {
        self.uid = [NSNumber numberWithInt:0];
    }
}

/*!
 * @return a jsonObject from given object
 */
-(NSDictionary *)jsonObject {
    // get mapping and create an appropriate sized dictionary
    NSDictionary *mapping = [[self class] mapping];
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] initWithCapacity:mapping.count];
    
    // map every variable to the json object
    for (NSString* item in mapping) {
        FMDBORMColumn *col = [mapping objectForKey:item];
        
        // get value and address the nil pointer problem with the NSNull placeholder object and map it into dictionary
        NSObject *value = [self valueForKey:item];
        value = (value == nil ? [NSNull null] : value);
        [dict setObject:value forKey:col.name];
    }
    
    // return the non mutable variant.
    return [NSDictionary dictionaryWithDictionary:dict];
}

@end
