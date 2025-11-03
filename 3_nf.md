
## Goal of 3NF

A table is in **3NF** if:

1. It is already in **2NF**, and
2. **All non-key attributes depend only on the primary key**,
   not on other non-key attributes.

This means:

> No **transitive dependency** — one non-key column should not depend on another non-key column.

---

### Step 1: Identify transitive dependencies in our 2NF structure

In the `posts_2nf` table:

```
(PostID, Username, UserEmail, UserPlan, PlanPrice, PostContent, LikeCount)
```

The problem:

* `Username`, `UserEmail`, `UserPlan`, and `PlanPrice` describe the **user** — not the post.
* These fields depend on `Username` (or `UserEmail`), not directly on `PostID`.

So we still have **transitive dependency**:

```
PostID → Username → (UserEmail, UserPlan, PlanPrice)
```

---

### Step 2: Decompose further to remove transitive dependency

We’ll separate user-related data into its own table.

We’ll now have **three tables** in 3NF:

1. **`users_3nf`** – stores unique user information
2. **`posts_3nf`** – stores post-specific details, referencing the user
3. **`post_tags_3nf`** – remains as is from 2NF, linking posts and tags

---

### `users_3nf` table

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
```

---

### `posts_3nf` table

```sql
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
```

---

### `post_tags_3nf` table

```sql
CREATE TABLE post_tags_3nf (
    PostID INT,
    Tag VARCHAR(50),
    FOREIGN KEY (PostID) REFERENCES posts_3nf(PostID)
);

INSERT INTO post_tags_3nf VALUES
(1, 'nature'),
(1, 'sunset'),
(1, 'photography'),
(2, 'work'),
(2, 'project'),
(3, 'coffee'),
(3, 'morning'),
(3, 'lifestyle');
```

---

### Explanation of 3NF design

| Table             | Purpose                                      | Key Dependencies                                    |
| ----------------- | -------------------------------------------- | --------------------------------------------------- |
| **users_3nf**     | Contains each user’s unique info             | `UserID → Username, UserEmail, UserPlan, PlanPrice` |
| **posts_3nf**     | Contains post-specific info, references user | `PostID → PostContent, LikeCount, UserID`           |
| **post_tags_3nf** | Connects each post to its tags               | `(PostID, Tag)` is composite key                    |

Now:

* Each table has attributes **only depending on its own primary key**.
* There’s **no duplication** of user info across posts.
* The design is clean, efficient, and in **Third Normal Form (3NF)**.
