USE online_bookstore;

-- Additional indexes for better performance
CREATE INDEX idx_books_featured ON books(is_featured);
CREATE INDEX idx_books_bestseller ON books(is_bestseller);
CREATE INDEX idx_books_rating ON books(rating);
CREATE INDEX idx_reviews_rating ON reviews(rating);
CREATE INDEX idx_orders_date_status ON orders(order_date, order_status);

-- Trigger to update book rating when a review is added
DELIMITER //
CREATE TRIGGER update_book_rating_after_review_insert
AFTER INSERT ON reviews
FOR EACH ROW
BEGIN
    UPDATE books 
    SET rating = (
        SELECT ROUND(AVG(rating), 2) 
        FROM reviews 
        WHERE book_id = NEW.book_id
    ),
    total_reviews = (
        SELECT COUNT(*) 
        FROM reviews 
        WHERE book_id = NEW.book_id
    )
    WHERE book_id = NEW.book_id;
END//

-- Trigger to update book rating when a review is updated
CREATE TRIGGER update_book_rating_after_review_update
AFTER UPDATE ON reviews
FOR EACH ROW
BEGIN
    UPDATE books 
    SET rating = (
        SELECT ROUND(AVG(rating), 2) 
        FROM reviews 
        WHERE book_id = NEW.book_id
    ),
    total_reviews = (
        SELECT COUNT(*) 
        FROM reviews 
        WHERE book_id = NEW.book_id
    )
    WHERE book_id = NEW.book_id;
END//

-- Trigger to update book rating when a review is deleted
CREATE TRIGGER update_book_rating_after_review_delete
AFTER DELETE ON reviews
FOR EACH ROW
BEGIN
    UPDATE books 
    SET rating = COALESCE((
        SELECT ROUND(AVG(rating), 2) 
        FROM reviews 
        WHERE book_id = OLD.book_id
    ), 0.00),
    total_reviews = (
        SELECT COUNT(*) 
        FROM reviews 
        WHERE book_id = OLD.book_id
    )
    WHERE book_id = OLD.book_id;
END//

-- Trigger to update order total when order items are modified
CREATE TRIGGER update_order_total_after_item_insert
AFTER INSERT ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders 
    SET total_amount = (
        SELECT SUM(total_price) 
        FROM order_items 
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END//

CREATE TRIGGER update_order_total_after_item_update
AFTER UPDATE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders 
    SET total_amount = (
        SELECT SUM(total_price) 
        FROM order_items 
        WHERE order_id = NEW.order_id
    )
    WHERE order_id = NEW.order_id;
END//

CREATE TRIGGER update_order_total_after_item_delete
AFTER DELETE ON order_items
FOR EACH ROW
BEGIN
    UPDATE orders 
    SET total_amount = (
        SELECT COALESCE(SUM(total_price), 0) 
        FROM order_items 
        WHERE order_id = OLD.order_id
    )
    WHERE order_id = OLD.order_id;
END//

DELIMITER ;
