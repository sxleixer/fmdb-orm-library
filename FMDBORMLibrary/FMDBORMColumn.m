//
//  FMDBORMColumn.m
//  Team Wurzel
//
//  Created by Ralf Schleicher on 30.12.13.
//  Copyright (c) 2013 Team Wurzel. All rights reserved.
//

#import "FMDBORMColumn.h"

// Type Strings
NSString* const FMDBORMTypeNull = @"NULL";
NSString* const FMDBORMTypeInteger = @"INTEGER";
NSString* const FMDBORMTypeText = @"TEXT";
NSString* const FMDBORMTypeReal = @"REAL";
NSString* const FMDBORMTypeBlob = @"BLOB";

// Extra Strings
NSString* const FMDBORMExtraPrimaryKey = @"PRIMARY KEY";
NSString* const FMDBORMExtraAutoIncrement = @"AUTOINCREMENT";
NSString* const FMDBORMExtraUnique = @"UNIQUE";
NSString* const FMDBORMExtraNotNull = @"NOT NULL";

@implementation FMDBORMColumn {
    NSArray *_extras;
}

-(id)initWithColumnName:(NSString *)columnName andType:(NSString *)typeName {
    self = [self initWithColumnName:columnName andType:typeName andExtraModifier:@[]];
    return self;
}

- (id)initWithColumnName:(NSString *)columnName andType:(NSString *)typeName andExtraModifier:(NSArray *)extras {
    self = [super init];
    
    if (self) {
        self.name = columnName;
        self.type = typeName;
        self.extraModifier = extras;
    }
    
    return self;
}

-(NSArray *)extraModifier {
    return _extras;
}

-(void)setExtraModifier:(NSArray *)extras {
    NSMutableArray *extrasArray = [[NSMutableArray alloc] initWithCapacity:extras.count];
    for (NSString* extra in extras) {
        [extrasArray addObject:[extra uppercaseString]];
    }
    _extras = [NSArray arrayWithArray:extras];
}

-(NSString *)description {
    NSMutableArray *outArray = [[NSMutableArray alloc] initWithCapacity:3];
    [outArray addObject:self.name];
    [outArray addObject:self.type];
    if (self.extraModifier.count > 0) {
        [outArray addObject:[self.extraModifier componentsJoinedByString:@" "]];
    }
    return [outArray componentsJoinedByString:@" "];
}
@end

