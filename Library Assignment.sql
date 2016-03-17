USE master
GO
/*Checking to make sure that the database doesn't exist already*/
if exists(SELECT * from sysdatabases 
		WHERE name = 'dbLibrary' )
DROP database dbLibrary --Get rid of db if it does
go
--Create new instance of db
CREATE database dbLibrary
go
--Make sure using correct db
USE dbLibrary
GO
--Making the first of many tables

--Book table
create table Book
(
	BookId int primary key,
	Title varchar(50) not null,
	PublisherName varchar(50) null
)
GO
--Authors table 
create table BookAuthors
(
	BookId int primary key,
	AuthorName varchar(50) not null
)
GO
--Publisher Table
Create table Publisher
(
	PublisherID int primary key,
	PublisherName varchar(50) not null,
	p_Address varchar(75) not null,
	p_phone varchar(20) null
)
GO
--Book copies each library owns
Create Table BookCopies
(
	Copies_ID int primary key,
	BookId int not null,
	BranchID int not null,
	NumberOfCopies int not null
)
GO
--Books out on loan to library users
Create Table BookLoans
(
	Out_ID int primary key,
	BookId int not null,
	BranchID int not null,
	CardNumber varchar(20) null,
	CheckOut date null,
	DueDate date null
)
GO
--Library Branch information
Create Table LibraryBranch
(
	BranchID int primary key,
	BranchName Varchar(50) not null,
	br_Address Varchar(75) not null,
)
GO
--Library user information
Create Table Borrowers 
(
	CardNumber int primary Key,
	Name Varchar(50) not null,
	[Address] Varchar(75) not null,
	Phone Varchar(20) not null
)
GO
/*Inserting big quantities of data to populate the database. If you are 
getting errors then check to make sure the txt files exist in the specified
locations as outlined in the from string. Default for unziping the folder 
is C:\Library if you have changed this you will have to update the links for 
each of the following inserts.
-Brook H.*/

--Book Information
bulk insert Book
from 'C:\Library\DBBOOK.txt'
with 
(
	firstrow = 2,
	Rowterminator = '\n',
	tablock
)
GO

--Book Author Information
bulk insert BookAuthors
from 'C:\Library\BookdbAuthors.txt'
with 
(
	firstrow = 2,
	Rowterminator = '\n',
	tablock
)
GO

--Publisher Information
bulk insert Publisher
from 'C:\Library\BookdbPublisher.txt'
with 
(
	firstrow = 2,
	Rowterminator = '\n',
	tablock
)
GO

--Library Borrower Information
bulk insert Borrowers
from 'C:\Library\BookdbBorrowers.txt'
with 
(
	firstrow = 2,
	Rowterminator = '\n',
	tablock
)
Go

--Number of copies for each branch
bulk insert BookCopies
from 'C:\Library\BookdbCopies.txt'
with 
(
	firstrow = 2,
	Rowterminator = '\n',
	tablock
)
GO

--Checked out
bulk insert BookLoans
from 'C:\Library\BookdbCheckedOut.txt'
with 
(
	firstrow = 2,
	Rowterminator = '\n',
	tablock
)
GO

--Library Branch information
bulk insert LibraryBranch
from 'C:\Library\BookdbBranch.txt'
with 
(
	firstrow = 2,
	Rowterminator = '\n',
	tablock
)
Go

/*procedure for how many The Lost Tribe Sharpstown*/
Create Proc GetLostTribeSharpstown
As
select LB.BranchName, B.BookID, B.Title, BC.NumberOfCopies
From BookCopies BC Join LibraryBranch LB on BC.BranchID = LB.BranchID
Join Book B on BC.BookID=B.BookId 
Where B.Title = 'The Lost Tribe' 
and LB.BranchName = 'Sharpstown'
Go

/*Creating procedure for how many copies of The Lost Tribe that each branch has*/
Create Proc GetLostTribeBranches
As
select LB.BranchName, B.BookID, B.Title, BC.NumberOfCopies
From BookCopies BC Join LibraryBranch LB on BC.BranchID = LB.BranchID
Join Book B on BC.BookID=B.BookId 
Where B.Title = 'The Lost Tribe' 
Go

/*Creating procedure for how many books due today from Sharpstown*/

Create Proc GetBooksDueTodaySharpstown
As
declare @Today date
Set @Today = GetDate()
select B.Title, BL.DueDate, BR.Name, BR.[Address]
From BookLoans BL Join LibraryBranch LB on BL.BranchID = LB.BranchID
Join Book B on BL.BookID=B.BookId join Borrowers BR on BL.CardNumber=BR.CardNumber
Where LB.BranchName = 'Sharpstown'
and DueDate=@Today
Go

/*Creating procedure for how many books are checked out from each branch*/

Create Proc GetBooksCheckedOutAll
As
 SELECT LB.BranchName, Count(CheckOut) As Checked_Out  
 FROM LibraryBranch AS LB   
 INNER JOIN BookLoans AS BL  
 ON LB.BranchID = BL.BranchID 
 Group By LB.BranchName 
 Go

 /*Creating procedure for showing borrowers who have 5 or more books checked out*/

Create Proc GetBorrowers5Books
As
select BR.Name As Name, BR.[Address] As [Address], Count(BL.Checkout) As [Checked Out]
From Borrowers BR Join BookLoans BL on BR.CardNumber = BL.CardNumber
Group By BR.Name, BR.[Address] 
having Count(BL.Checkout) >= 5
Go

/*Creating procedure for how many copies of Stephen Kings Book(s) @ Central*/

Create Proc GetKingBooksCentral
As
select LB.BranchName, BA.AuthorName, B.Title, BC.NumberOfCopies
From BookCopies BC Join LibraryBranch LB on BC.BranchID = LB.BranchID
Join Book B on BC.BookID=B.BookId Join BookAuthors BA on B.BookId=BA.BookId
Where BA.AuthorName = 'Stephen King' and LB.BranchName = 'Central'