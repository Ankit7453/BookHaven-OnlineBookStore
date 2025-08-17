USE online_bookstore;

-- Insert categories
INSERT INTO categories (category_name, description) VALUES
('Fiction', 'Novels, short stories, and fictional literature'),
('Non-Fiction', 'Biographies, self-help, and factual books'),
('Science & Technology', 'Programming, science, and technical books'),
('Business', 'Business, economics, and management books'),
('History', 'Historical books and documentaries'),
('Romance', 'Romantic novels and stories'),
('Mystery & Thriller', 'Mystery, thriller, and suspense books'),
('Children', 'Books for children and young adults'),
('Health & Fitness', 'Health, fitness, and wellness books'),
('Travel', 'Travel guides and adventure books');

-- Insert sample admin
INSERT INTO admins (username, email, password_hash, full_name, role) VALUES
('admin', 'admin@bookstore.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VQ2LMvMRmcVVpGnOmVeVf6dNjkz6bO', 'System Administrator', 'super_admin');
-- Password is 'admin123' (hashed with BCrypt)

-- Insert sample users
INSERT INTO users (name, email, password_hash, phone, address, city, state, zip_code) VALUES
('John Doe', 'john@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VQ2LMvMRmcVVpGnOmVeVf6dNjkz6bO', '555-0101', '123 Main St', 'New York', 'NY', '10001'),
('Jane Smith', 'jane@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VQ2LMvMRmcVVpGnOmVeVf6dNjkz6bO', '555-0102', '456 Oak Ave', 'Los Angeles', 'CA', '90210'),
('Mike Johnson', 'mike@example.com', '$2a$10$N9qo8uLOickgx2ZMRZoMye1VQ2LMvMRmcVVpGnOmVeVf6dNjkz6bO', '555-0103', '789 Pine Rd', 'Chicago', 'IL', '60601');
-- Password is 'password123' for all sample users

-- Updated all book prices to Indian Rupees range 300-500
-- Insert sample books with corrected JPEG image paths and Indian pricing
INSERT INTO books (title, author, isbn, description, price, stock_quantity, category_id, cover_image, publisher, publication_date, pages, is_featured, is_bestseller) VALUES
('The Great Gatsby', 'F. Scott Fitzgerald', '9780743273565', 'A classic American novel set in the Jazz Age', 349.99, 50, 1, 'the_great_gatsby.jpeg', 'Scribner', '1925-04-10', 180, TRUE, TRUE),
('To Kill a Mockingbird', 'Harper Lee', '9780061120084', 'A gripping tale of racial injustice and childhood innocence', 379.99, 45, 1, 'to_kill_a_mockingbird.jpeg', 'J.B. Lippincott & Co.', '1960-07-11', 281, TRUE, TRUE),
('Clean Code', 'Robert C. Martin', '9780132350884', 'A handbook of agile software craftsmanship', 499.99, 30, 3, 'clean_code.jpeg', 'Prentice Hall', '2008-08-01', 464, TRUE, FALSE),
('The Lean Startup', 'Eric Ries', '9780307887894', 'How todays entrepreneurs use continuous innovation', 429.99, 25, 4, 'the_lean_startup.jpeg', 'Crown Business', '2011-09-13', 336, FALSE, TRUE),
('Sapiens', 'Yuval Noah Harari', '9780062316097', 'A brief history of humankind', 459.99, 40, 2, 'sapiens.jpeg', 'Harper', '2014-02-10', 443, TRUE, TRUE),
('The Alchemist', 'Paulo Coelho', '9780062315007', 'A magical story about following your dreams', 329.99, 60, 1, 'the_alchemist.jpeg', 'HarperOne', '1988-01-01', 163, TRUE, TRUE),
('Gone Girl', 'Gillian Flynn', '9780307588364', 'A psychological thriller about a missing wife', 399.99, 35, 7, 'gone_girl.jpeg', 'Crown Publishers', '2012-06-05', 419, FALSE, TRUE),
('Harry Potter and the Sorcerers Stone', 'J.K. Rowling', '9780439708180', 'The first book in the magical Harry Potter series', 319.99, 100, 8, 'harry_potter_and_the_sorcerers_stone.jpeg', 'Scholastic', '1997-06-26', 309, TRUE, TRUE),
('The 7 Habits of Highly Effective People', 'Stephen R. Covey', '9781451639612', 'Powerful lessons in personal change', 449.99, 20, 2, 'the_7_habits_of_highly_effective_people.jpeg', 'Free Press', '1989-08-15', 381, FALSE, FALSE),
('Lonely Planet Italy', 'Lonely Planet', '9781786574454', 'Comprehensive travel guide to Italy', 479.99, 15, 10, 'lonely_planet_italy.jpeg', 'Lonely Planet', '2020-03-01', 672, FALSE, FALSE);

-- Insert sample reviews
INSERT INTO reviews (book_id, user_id, rating, review_text, is_verified_purchase) VALUES
(1, 1, 5, 'An absolute masterpiece! Fitzgeralds writing is beautiful and the story is timeless.', TRUE),
(1, 2, 4, 'Great book, though the ending was a bit sad for my taste.', TRUE),
(2, 1, 5, 'A powerful story that everyone should read. Harper Lee created something truly special.', TRUE),
(3, 3, 5, 'Essential reading for any programmer. Changed how I write code completely.', TRUE),
(4, 2, 4, 'Great insights into startup methodology. Very practical advice.', TRUE),
(5, 1, 5, 'Mind-blowing perspective on human history. Harari is a brilliant writer.', TRUE);

-- Updated coupon minimum amounts to match new Indian pricing
-- Insert sample coupons
INSERT INTO coupons (coupon_code, description, discount_type, discount_value, minimum_order_amount, max_uses, start_date, end_date) VALUES
('WELCOME10', 'Welcome discount for new customers', 'percentage', 10.00, 500.00, 100, '2024-01-01', '2024-12-31'),
('SAVE50', 'Save ₹50 on orders over ₹1000', 'fixed', 50.00, 1000.00, 50, '2024-01-01', '2024-12-31'),
('BOOKWORM15', '15% off for book lovers', 'percentage', 15.00, 800.00, 200, '2024-01-01', '2024-12-31');
