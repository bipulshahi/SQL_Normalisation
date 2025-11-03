CREATE DATABASE IF NOT EXISTS social_media_demo;
USE social_media_demo;

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
 
 
 SELECT * FROM posts_unnormalized;
 
