# Goal for 1NF

1NF requires that every column contain **atomic** (indivisible) values and that there are **no repeating groups** (no multi-valued cells). Your `Tags` column currently contains multiple comma-separated values in a single cell — that breaks 1NF. To fix this we must make the tags atomic. A common 1NF approach is to put one tag per row (so a post with three tags becomes three rows, each with the same PostID and post fields but a single Tag value).

# New table name

`posts_1nf` (different from your original `posts_unnormalized`)

# SQL — create table and insert (1NF)

```sql
CREATE TABLE posts_1nf (
    PostID INT,
    Username VARCHAR(50),
    UserEmail VARCHAR(100),
    UserPlan VARCHAR(20),
    PlanPrice DECIMAL(10,2),
    PostContent TEXT,
    Tag VARCHAR(50),   -- now atomic: one tag per row
    LikeCount INT
);

INSERT INTO posts_1nf VALUES
-- PostID 1 (3 tags)
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Beautiful sunset!', 'nature', 150),
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Beautiful sunset!', 'sunset', 150),
(1, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Beautiful sunset!', 'photography', 150),

-- PostID 2 (2 tags)
(2, 'bob_builder', 'bob@email.com', 'Free', 0.00,
 'New project completed', 'work', 45),
(2, 'bob_builder', 'bob@email.com', 'Free', 0.00,
 'New project completed', 'project', 45),

-- PostID 3 (3 tags)
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Morning coffee', 'coffee', 89),
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Morning coffee', 'morning', 89),
(3, 'alice_wonder', 'alice@email.com', 'Premium', 9.99,
 'Morning coffee', 'lifestyle', 89);

-- view
SELECT * FROM posts_1nf;
```

# What changed / why this is 1NF

* `Tags` is now atomic: **one tag per row** in the `Tag` column.
* There are **no multi-valued cells** anymore.
* You can now run tag-level queries (`WHERE Tag = 'sunset'`) easily.
* **Important caveat:** This still has redundancy — user data (`Username`, `UserEmail`, `UserPlan`, `PlanPrice`) and post-level fields (`PostContent`, `LikeCount`) repeat across multiple rows for the same `PostID`. That’s okay for 1NF, but it signals we should normalize further (2NF) to remove these redundancies and update anomalies.
