create database JJbookshopping;
CREATE TABLE Author (
AuthorID INT PRIMARY KEY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Biography TEXT
);
INSERT INTO Author (AuthorId,FirstName, LastName, Biography) VALUES
(1,'J.K.', 'Rowling', 'British author of Harry Potter.'),
(2,'George', 'Orwell', 'Famous for dystopian novels like 1984.'),
(3,'Agatha', 'Christie', 'The best-selling novelist of all time.'),
(4,'Stephen', 'King', 'Master of horror and suspense.'),
(5,'J.R.R.', 'Tolkien', 'Author of The Lord of the Rings.'),
(6,'Ernest', 'Hemingway', 'Nobel Prize-winning American novelist.'),
(7,'Mark', 'Twain', 'The father of American literature.'),
(8,'Jane', 'Austen', 'Known for her social commentary in Pride and Prejudice.');
CREATE TABLE Customer (
CustomerID INT PRIMARY KEY,
FirstName VARCHAR(50) NOT NULL,
LastName VARCHAR(50) NOT NULL,
Email VARCHAR(100) UNIQUE NOT NULL,
Phone VARCHAR(20)
);
INSERT INTO Customer (CustomerID,FirstName, LastName, Email,Phone) VALUES
(1,'Alice', 'Smith', 'alice@mail.com',12345678),
(2,'Bob', 'Jones', 'bob@mail.com',12345678),
(3,'Charlie', 'Brown', 'charlie@mail.com',12345678),
(4,'David', 'Wilson', 'david@mail.com',12345678),
(5,'Eve', 'Davis', 'eve@mail.com',12345678),
(6,'Frank', 'Miller', 'frank@mail.com',12345678),
(7,'Grace', 'Lee', 'grace@mail.com',12345678),
(8,'Hank', 'Moore', 'hank@mail.com',12345678);
CREATE TABLE book (
BookID INT PRIMARY KEY ,
Title VARCHAR(200) NOT NULL,
Price DECIMAL(10, 2) NOT NULL CHECK (Price > 0), -- Requirement b: Check Constraint
StockQuantity INT DEFAULT 0 CHECK (StockQuantity >= 0),
AuthorID INT,
FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID) ON DELETE CASCADE -- Requirement b:
Referential Integrity
);
INSERT INTO book (BookID,Title, Price, StockQuantity, AuthorID) VALUES
(1,'Harry Potter', 25.99, 50, 1),
(2,'1984', 15.50, 30, 2),
(3,'Murder on Orient Express', 12.99, 20, 3),
(4,'The Shining', 18.00, 15, 4),
(5,'The Hobbit', 22.50, 25, 5),
(6,'Old Man and the Sea', 10.99, 40, 6),
(7,'Tom Sawyer', 11.50, 10, 7),
(8,'Emma', 14.25, 12, 8);
CREATE TABLE Orders (
OrderID INT PRIMARY KEY ,
OrderDate DATETIME,
CustomerID INT,
BookID INT, --
StockQuantity INT ,
TotalAmount DECIMAL(10, 2),
FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID) ON DELETE CASCADE,
FOREIGN KEY (BookID) REFERENCES Book(BookID) ON DELETE CASCADE
);
INSERT INTO Orders (OrderID,OrderDate,CustomerID, BookID,StockQuantity, TotalAmount) VALUES
(1,'2026-01-01',1, 1,50, 25.99),
(2,'2026-01-01',2, 2, 30,15.50),
(3,'2026-01-01',3, 3,20, 12.99),
(4,'2026-01-01',4, 4,15, 18.00),
(5,'2026-01-01',5, 5,25, 22.50),
(6,'2026-01-01',6, 6, 40,10.99), -- Frank bought Old Man and the Sea
(7,'2026-01-01',7, 7,10, 11.50), -- Grace bought Tom Sawyer
(8,'2026-01-01',8, 8,12, 14.25); -- Hank bought Emma
CREATE TABLE OrderDetail (
OrderDetailID INT PRIMARY KEY,
OrderID INT,
BookID INT,
StockQuantity INT NOT NULL DEFAULT 1 CHECK (StockQuantity > 0),
UnitPrice DECIMAL(10, 2),
FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
FOREIGN KEY (BookID) REFERENCES Book(BookID)
);
CREATE TABLE Users (
UserID INT PRIMARY KEY,
Username VARCHAR(50) UNIQUE NOT NULL,
Passwordhash VARCHAR(255) NOT NULL,
UserRole VARCHAR(20) NOT NULL
DEFAULT 'CUSTOMER'
CHECK(USERROLE IN('Admin', 'Customer'))
);
INSERT INTO Users(UserID,Username, PasswordHash, UserRole) VALUES
(1,'admin1', 'adminpass', 'Admin'),
(2,'admin2', 'adminpass', 'Admin'),
(3,'alice88', 'userpass', 'Customer'),
(4,'bobbyJ', 'userpass', 'Customer'),
(5,'charlieB', 'userpass', 'Customer'),
(6,'daveW', 'userpass', 'Customer');
CREATE LOGIN admin1 WITH PASSWORD = 'abcd@1234';
CREATE LOGIN admin2 WITH PASSWORD = 'abcd@12345';
CREATE LOGIN alice88 WITH PASSWORD = '1234';
CREATE LOGIN bobbyJ WITH PASSWORD = 'abcd';
CREATE LOGIN charlieB WITH PASSWORD = 'pass';
CREATE LOGIN daveW WITH PASSWORD = '1111';
CREATE USER admin1 FOR LOGIN admin1;
CREATE USER admin2 FOR LOGIN admin2;
CREATE USER alice88 FOR LOGIN alice88;
CREATE USER bobbyJ FOR LOGIN bobbyJ;
CREATE USER charlieB FOR LOGIN charlieB;
CREATE USER daveW FOR LOGIN daveW;
CREATE ROLE AdminRole;
CREATE ROLE CustomerRole;
GRANT SELECT, INSERT, UPDATE, DELETE
TO AdminRole;
GRANT SELECT ON Book TO CustomerRole;
GRANT INSERT ON Orders TO CustomerRole;
GRANT INSERT ON OrderDetail TO CustomerRole;
GRANT SELECT ON Orders TO CustomerRole;
GRANT SELECT ON OrderDetail TO CustomerRole;
DENY INSERT, UPDATE, DELETE ON Book TO CustomerRole;
DENY INSERT, UPDATE, DELETE ON Author TO CustomerRole;
DENY INSERT, UPDATE, DELETE ON Users TO CustomerRole;
ALTER ROLE AdminRole ADD MEMBER admin1;
ALTER ROLE AdminRole ADD MEMBER admin2;
ALTER ROLE CustomerRole ADD MEMBER alice88;
ALTER ROLE CustomerRole ADD MEMBER bobbyJ;
ALTER ROLE CustomerRole ADD MEMBER charlieB;
ALTER ROLE CustomerRole ADD MEMBER daveW;
CREATE PROCEDURE AddNewBook1
@BookID int,
@Title VARCHAR(200),
@Price DECIMAL(10,2),
@StockQuantity INT,
@AuthorID INT
as
BEGIN
INSERT INTO Book (BookID,Title, Price, StockQuantity, AuthorID)
VALUES (@BookID,@Title, @Price, @StockQuantity, @AuthorID)
END;
create procedure addnewauther
@Authorid int,
@FirstName VARCHAR(50),
@LastName VARCHAR(50),
@Biography TEXT
as
begin
insert into Author(AuthorID,FirstName,LastName,Biography)
values(@AuthorID,@FirstName,@LastName,@Biography)
end;
CREATE PROCEDURE UpdateBookPrice1
@BookID INT,
@NewPrice DECIMAL(10,2)
as
BEGIN
UPDATE Book
SET Price = @NewPrice
WHERE BookID = @BookID
END;
CREATE PROCEDURE GetAllBooks
AS
BEGIN
SELECT b.BookID, b.Title, b.Price, b.StockQuantity,
a.FirstName, a.LastName
FROM Book b
JOIN Author a ON b.AuthorID = a.AuthorID;
END;
CREATE TRIGGER trg_after_insert_order
ON OrderDetail
AFTER INSERT
AS
BEGIN
-- Calculate TotalAmount based on Quantity * Price
UPDATE OrderDetail
SET OrderDetail.UnitPrice = NEW.StockQuantity * NEW.UnitPrice
FROM OrderDetail, inserted NEW
WHERE OrderDetail.OrderDetailID = NEW.OrderDetailID;
-- Optional: reduce stock in the Book table
UPDATE Book
SET Book.StockQuantity = Book.StockQuantity - NEW.StockQuantity
FROM book,inserted NEW
WHERE Book.BookID = NEW.BookID;
END;
EXEC AddNewBook1 10,'FIKER ESKE MEKABER', 20.99, 10, 9;
exec addnewauther 1,'bealu','grma','good author';
EXEC UpdateBookPrice1 1, 30.00;
EXEC GetAllBooks;
INSERT INTO OrderDetail(OrderDetailID, OrderID,BookID, StockQuantity, UnitPrice)
VALUES (1,1, 1, 2, 25.99);
select * from Orders;
SELECT * FROM OrderDetail WHERE OrderDetailID = 1;
SELECT * FROM Book WHERE BookID = 1;
exec addnewauther 9,'Haddis','Alemayew','well known Ethiopian writer';
select * from Author;
delete from Customer
where CustomerID=1;
select USERID, Username,userrole
from Users
where Username='alice88'
and Passwordhash='userpass';
select * from Author;
select * from book;
select * from book,Author
where Author.FirstName = 'Mark';
