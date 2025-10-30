# Database Normalization

## Why Normalization Matters 
When all data is stored in a single table, several critical problems emerge:

**Data Redundancy**: Information gets repeated multiple times, wasting storage space and creating maintenance headaches. In the university example from your lecture, student names and advisor information appear in multiple rows.

**Update Anomaly**: Changing a single piece of information requires updating multiple rows. If Bob changes his name, you'd need to update every row containing his information.

**Insert Anomaly**: You cannot add certain data without providing unrelated information. For instance, you can't add a new course without assigning it to a student.

**Delete Anomaly**: Removing a record can cause loss of other important information. If Ethan withdraws from the Art course, you lose the information that the Art course exists and is taught by Dr. Joshi.

## The Three Normal Forms Explained
### First Normal Form (1NF): "One Value Per Cell"
**Rule**: Each table cell should contain only a single, atomic value.

**Requirements**:
- Each cell contains exactly one value
- Each row must be unique
- All values in a column must be of the same data type

**Example**: Instead of storing "Math, History" in a single cell, create separate rows for each subject.

### Second Normal Form (2NF): "Eliminate Partial Dependencies"
**Rule**: Every non-key attribute must depend on the whole primary key, not just part of it.

**Requirements**:
- Must be in 1NF first
- Remove partial dependencies by creating separate tables
- Each table should focus on one main entity

**Example**: If advisor information depends only on the course (not on the student-course combination), create a separate Courses table.[1]

### Third Normal Form (3NF): "Eliminate Transitive Dependencies"
**Rule**: Remove transitive dependencies where one non-key attribute depends on another non-key attribute.

**Requirements**:
- Must be in 2NF first
- Every non-key column depends directly on the primary key
- No indirect dependencies through other columns

**Example**: If course advisor depends on advisor ID rather than directly on course ID, separate the advisor information into its own table.

## Hands-On Example: Gaming Club Database
Let's work through a complete normalization example using a gaming club database:

### Starting Point: Unnormalized Table (0NF)```
PlayerID | PlayerName | Games           | MembershipType | MembershipFee
1        | Alice      | Minecraft, FIFA | Premium        | 50
2        | Bob        | Fortnite        | Basic          | 25
3        | Charlie    | Minecraft, FIFA | Premium        | 50
```

**Problems**: Multi-valued attributes, repeated membership fees, update anomalies.

### Step 1: First Normal Form (1NF)Split multi-valued attributes into atomic values:
```
PlayerID | PlayerName | Game      | MembershipType | MembershipFee
1        | Alice      | Minecraft | Premium        | 50
1        | Alice      | FIFA      | Premium        | 50
2        | Bob        | Fortnite  | Basic          | 25
3        | Charlie    | Minecraft | Premium        | 50
3        | Charlie    | FIFA      | Premium        | 50
```

**Achievement**: Each cell now contains exactly one value.

### Step 2: Second Normal Form (2NF)Remove partial dependencies by creating separate tables:

**Players Table**:
```
PlayerID | PlayerName | MembershipType | MembershipFee
1        | Alice      | Premium        | 50
2        | Bob        | Basic          | 25
3        | Charlie    | Premium        | 50
```

**Games Table**:
```
Game      | GameCategory
Minecraft | Sandbox
FIFA      | Sports
Fortnite  | Battle Royale
```

**PlayerGames Table**:
```
PlayerID | Game
1        | Minecraft
1        | FIFA
2        | Fortnite
3        | Minecraft
3        | FIFA
```

### Step 3: Third Normal Form (3NF)Remove the transitive dependency where MembershipFee depends on MembershipType:

**Players Table** (Updated):
```
PlayerID | PlayerName | MembershipType
1        | Alice      | Premium
2        | Bob        | Basic
3        | Charlie    | Premium
```

**Membership Table** (New):
```
MembershipType | MembershipFee | Benefits
Premium        | 50            | Full access + tournaments
Basic          | 25            | Limited access
```

## SQL ImplementationHere's how to implement the normalized structure:

```sql
-- Create the membership lookup table
CREATE TABLE Membership (
    MembershipType VARCHAR(20) PRIMARY KEY,
    MembershipFee DECIMAL(10,2) NOT NULL,
    Benefits TEXT
);

-- Create the main players table
CREATE TABLE Players (
    PlayerID INT PRIMARY KEY,
    PlayerName VARCHAR(50) NOT NULL,
    MembershipType VARCHAR(20),
    JoinDate DATE NOT NULL,
    FOREIGN KEY (MembershipType) REFERENCES Membership(MembershipType)
);

-- Create the games catalog
CREATE TABLE Games (
    Game VARCHAR(50) PRIMARY KEY,
    GameCategory VARCHAR(50) NOT NULL
);

-- Create the many-to-many relationship table
CREATE TABLE PlayerGames (
    PlayerID INT,
    Game VARCHAR(50),
    PRIMARY KEY (PlayerID, Game),
    FOREIGN KEY (PlayerID) REFERENCES Players(PlayerID),
    FOREIGN KEY (Game) REFERENCES Games(Game)
);
```

## The Transformation Impact**Before Normalization**:
- Update Premium membership fee → Change 3 rows
- Add new game → Requires fake player data
- Delete player → Lose game information

**After Normalization**:
- Update Premium membership fee → Change 1 row in Membership table
- Add new game → Simple INSERT into Games table
- Delete player → Game information preserved

**Storage Efficiency**: The normalized structure reduces data cells by 17% while eliminating all redundancy.

## Benefits of Normalization1. **Data Integrity**: Each fact stored in exactly one place
2. **Efficient Updates**: Change data once, affects all related records automatically
3. **No Anomalies**: Safe insert, update, and delete operations
4. **Storage Optimization**: Eliminates redundant data storage
5. **Query Flexibility**: Easy to construct complex queries using JOINs
6. **Scalability**: Simple to extend with new data types

## Practice ChallengeTry normalizing this library management table:

```
BookID | Title        | Author         | Genres           | MemberID | MemberName | MembershipFee
1      | Harry Potter | J.K. Rowling   | Fantasy, Adventure| 101     | Alice      | 100
2      | The Hobbit   | J.R.R. Tolkien | Fantasy, Adventure| 101     | Alice      | 100
```

**Questions to Consider**:
- What are the multi-valued attributes?
- Where do you see redundant data?
- What dependencies can you identify?
- How would you structure the normalized tables?

## Key TakeawaysDatabase normalization follows a systematic approach:
- **1NF**: Ensure atomic values in each cell
- **2NF**: Remove partial dependencies on composite keys  
- **3NF**: Eliminate transitive dependencies

Each normal form builds upon the previous one, creating a more organized and maintainable database structure. While normalization may increase query complexity due to JOINs, it significantly improves data integrity and long-term maintainability.

Remember: normalization is about logical organization - each table should represent one concept, and each fact should be stored in exactly one place. Master these fundamentals through hands-on practice with your own data examples!
