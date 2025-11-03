# Database Normalization — Case Study

**Learning objectives**

* Understand the concepts of 1NF, 2NF, and 3NF
* Identify partial and transitive dependencies
* Decompose a given unnormalized table into normalized tables
* Write `CREATE TABLE` and `INSERT` SQL statements for each normal form

---

## Problem statement (base data — unnormalized)

You are given a single unnormalized table `posts_unnormalized` that stores social media posts, user details, plan pricing, tags (multiple in one cell), and likes.

```sql
CREATE TABLE posts_unnormalized (
    PostID INT,
    Username VARCHAR(50),
    UserEmail VARCHAR(100),
    UserPlan VARCHAR(20),
    PlanPrice DECIMAL(10,2),
    PostContent TEXT,
    Tags VARCHAR(200),  -- Multiple values in one cell!
    LikeCount INT
);

INSERT INTO posts_unnormalized VALUES
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Beautiful sunset!', 'nature,sunset,photography', 150),
(2, 'bob_builder', 'bob@email.com', 'Free', 0.00,
 'New project completed', 'work,project', 45),
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Morning coffee', 'coffee,morning,lifestyle', 89);
```

---

## Assignment tasks (for students)

1. **Explain in one sentence** why the `Tags` column violates 1NF.
2. **Convert the table into 1NF**: write `CREATE TABLE posts_1nf` and `INSERT` statements that make `Tag` atomic (one tag per row). Use `PostID` and `Tag` to identify each row uniquely.
3. **Identify the primary key** of your `posts_1nf` table and explain if any partial dependencies exist.
4. **Convert to 2NF**: Show how to split data to remove partial dependencies. Provide `CREATE TABLE` and `INSERT` statements for the tables you design. Explain why your decomposition removes partial dependencies.
5. **Convert to 3NF**: Identify any transitive dependencies in the 2NF design. Decompose into 3NF tables with `CREATE TABLE` and `INSERT` statements. Explain why the final design is in 3NF.
6. **Write two sample queries** on the 3NF schema:

   * a) Find all tags for `PostID = 1`.
   * b) Find the plan name and price for the user who wrote `PostID = 3`.

---

## Hints (for students)

* 1NF requires *atomic* values: split comma-separated tags into separate rows.
* In 1NF the key may become composite (for example `(PostID, Tag)`). If so, check whether any non-key attribute depends on part of that composite key — that indicates a **partial dependency**.
* 2NF: move attributes that depend only on part of the composite key into their own table(s).
* 3NF: check that non-key attributes do not depend on other non-key attributes (transitive dependency). If they do, separate them.

---

## Step-by-step solution (answer key)

> **Note to instructors:** below is a stepwise solution you can provide or show after students attempt the exercise.

### 1) Why `Tags` violates 1NF (model answer)

* Because `Tags` contains multiple comma-separated tag values in a single cell (non-atomic). 1NF requires each field to hold an indivisible value.

---

### 2) Convert to **1NF** — SQL and explanation

**Design choice:** keep all post and user fields but ensure `Tag` is atomic (one tag per row). Table name: `posts_1nf`.

```sql
CREATE TABLE posts_1nf (
    PostID INT,
    Username VARCHAR(50),
    UserEmail VARCHAR(100),
    UserPlan VARCHAR(20),
    PlanPrice DECIMAL(10,2),
    PostContent TEXT,
    Tag VARCHAR(50),   -- atomic
    LikeCount INT
);

INSERT INTO posts_1nf VALUES
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Beautiful sunset!', 'nature', 150),
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Beautiful sunset!', 'sunset', 150),
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Beautiful sunset!', 'photography', 150),
(2, 'bob_builder', 'bob@email.com', 'Free', 0.00,
 'New project completed', 'work', 45),
(2, 'bob_builder', 'bob@email.com', 'Free', 0.00,
 'New project completed', 'project', 45),
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Morning coffee', 'coffee', 89),
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Morning coffee', 'morning', 89),
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Morning coffee', 'lifestyle', 89);
```

**Key point:** `Tag` is atomic. However, `Username` and plan fields repeat across multiple rows for the same `PostID` — that's acceptable in 1NF but signals further normalization is needed.

---

### 3) Primary key of `posts_1nf` and partial dependency check

* **Primary key candidate:** `(PostID, Tag)` — together they uniquely identify each row.
* **Partial dependency:** columns like `Username`, `UserEmail`, `UserPlan`, `PlanPrice`, `PostContent`, `LikeCount` depend only on `PostID` (part of the composite key). Hence partial dependencies exist and we must move those attributes into a table keyed by `PostID`.

---

### 4) Convert to **2NF** — SQL and explanation

**Design choice:** separate post-level details from tags. Table names: `posts_2nf` and `post_tags_2nf`.

```sql
CREATE TABLE posts_2nf (
    PostID INT PRIMARY KEY,
    Username VARCHAR(50),
    UserEmail VARCHAR(100),
    UserPlan VARCHAR(20),
    PlanPrice DECIMAL(10,2),
    PostContent TEXT,
    LikeCount INT
);

INSERT INTO posts_2nf VALUES
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Beautiful sunset!', 150),
(2, 'bob_builder', 'bob@email.com', 'Free', 0.00,
 'New project completed', 45),
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Morning coffee', 89);

CREATE TABLE post_tags_2nf (
    PostID INT,
    Tag VARCHAR(50),
    FOREIGN KEY (PostID) REFERENCES posts_2nf(PostID)
);

INSERT INTO post_tags_2nf VALUES
(1, 'nature'),(1, 'sunset'),(1, 'photography'),
(2, 'work'),(2, 'project'),
(3, 'coffee'),(3, 'morning'),(3, 'lifestyle');
```

**Why this removes partial dependencies:** `posts_2nf` stores attributes that depend only on `PostID` (no attribute in `posts_2nf` depends on `Tag`). `post_tags_2nf` stores the many-to-many relationship between posts and tags.

---

### 5) Convert to **3NF** — SQL and explanation

**Design choice:** separate user-specific attributes into a `users_3nf` table to remove transitive dependency.

```sql
CREATE TABLE users_3nf (
    UserID INT PRIMARY KEY,
    Username VARCHAR(50),
    UserEmail VARCHAR(100),
    UserPlan VARCHAR(20),
    PlanPrice DECIMAL(10,2)
);

INSERT INTO users_3nf VALUES
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99),
(2, 'bob_builder', 'bob@email.com', 'Free', 0.00);

CREATE TABLE posts_3nf (
    PostID INT PRIMARY KEY,
    UserID INT,
    PostContent TEXT,
    LikeCount INT,
    FOREIGN KEY (UserID) REFERENCES users_3nf(UserID)
);

INSERT INTO posts_3nf VALUES
(1, 1, 'Beautiful sunset!', 150),
(2, 2, 'New project completed', 45),
(3, 1, 'Morning coffee', 89);

CREATE TABLE post_tags_3nf (
    PostID INT,
    Tag VARCHAR(50),
    FOREIGN KEY (PostID) REFERENCES posts_3nf(PostID)
);

INSERT INTO post_tags_3nf VALUES
(1, 'nature'),(1, 'sunset'),(1, 'photography'),
(2, 'work'),(2, 'project'),
(3, 'coffee'),(3, 'morning'),(3, 'lifestyle');
```

**Why this is 3NF:** `users_3nf` holds user attributes that depend only on `UserID`. `posts_3nf` holds attributes that depend only on `PostID` and references user by `UserID`. No non-key attribute depends on another non-key attribute.

---

### 6) Two sample queries (on 3NF schema)

**a) Find all tags for `PostID = 1`:**

```sql
SELECT Tag FROM post_tags_3nf WHERE PostID = 1;
```

**b) Find the plan name and price for the user who wrote `PostID = 3`:**

```sql
SELECT u.UserPlan, u.PlanPrice
FROM posts_3nf p
JOIN users_3nf u ON p.UserID = u.UserID
WHERE p.PostID = 3;
```

---

## Grading rubric (suggested)

* Task 1 (explain 1NF violation): 5 points
* Task 2 (1NF SQL correct and atomic tags): 20 points
* Task 3 (identify PK and partial dependency): 10 points
* Task 4 (2NF decomposition correct + SQL): 25 points
* Task 5 (3NF decomposition correct + SQL): 25 points
* Task 6 (sample queries correct): 15 points

**Total:** 100 points

---

## Extra challenge (optional, +bonus marks)

1. Show a BCNF decomposition and explain if BCNF gives any change for this dataset.
2. Add indexes to speed up tag queries and explain which columns to index and why.
3. Write a query to list users and their number of posts (use `GROUP BY`).

---

## Quick instructor notes

* Encourage students to write short explanations for each decomposition step — reasoning is as important as SQL accuracy.
* If students use `UserEmail` as a candidate key instead of `UserID`, accept it but ask them to justify uniqueness.
* For larger assignments, ask students to implement the schema in a real RDBMS and run the sample queries to validate results.

---

**End of assignment document.**
