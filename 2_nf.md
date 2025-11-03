
## Goal of 2NF

A table is in **2NF** if:

1. It is already in **1NF**, and
2. **All non-key attributes depend on the entire primary key**, not just part of it.

That means:

> No **partial dependency** — every non-key column should depend on the full key.

---

### Step 1: Identify the current primary key in `posts_1nf`

In the 1NF table, each row is uniquely identified by the combination of:

```
(PostID, Tag)
```

since a single post can have multiple tags.

---

### Step 2: Identify partial dependencies

We can now see that:

* `Username`, `UserEmail`, `UserPlan`, `PlanPrice`, `PostContent`, and `LikeCount` all depend only on `PostID` (not on `Tag`).
* Only `Tag` depends on both `PostID` and `Tag`.

So, these non-key attributes depend **partially** on the key `(PostID, Tag)`.
Hence, we must **separate** the data into multiple tables — one for posts, one for tags (and possibly one for users later).

---

### Step 3: Decompose into two tables

We'll separate the data into:

1. **`posts_2nf`** – stores details unique to each post
2. **`post_tags_2nf`** – stores the relationship between posts and their tags (many-to-many link)

---

### `posts_2nf` table

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
```

---

### `post_tags_2nf` table

```sql
CREATE TABLE post_tags_2nf (
    PostID INT,
    Tag VARCHAR(50),
    FOREIGN KEY (PostID) REFERENCES posts_2nf(PostID)
);

INSERT INTO post_tags_2nf VALUES
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

### Explanation

* **`posts_2nf`** stores post-level data that depends only on `PostID`.
* **`post_tags_2nf`** stores each tag associated with its post (link table).
* This removes **partial dependency** — now every non-key column in each table depends on the **entire primary key**.

---

**Result: Table is now in 2NF**

However, you might notice that **user information (Username, UserEmail, UserPlan, PlanPrice)** repeats for `alice_wonder` in multiple rows — this is a **transitive dependency**, which violates **3NF**.
