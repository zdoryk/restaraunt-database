# restaraunt-database 
  
### Database system for restaraunt 
  
This project was made at the end of 2021 while I was learning "Advanced database systems". I got 100% for this project.<br/> 
This project was written in polish language - so all documentation and comments in code are written in polish. 
  
### Requirements for 60% grade: 
- Define a topic for database systems.  
- The database schema reflects all the real attributes and dependencies of objects occurring within the given topic. 
- Database schema consists of at least 5 tables. 
- Each table consists of columns of defined types and imposed appropriate constraints. 
- There are must be links between the tables based on primary and foreign keys. 
- Individual tables are pre-filled with sample data, taking into account the differences between individual occurrences of the same object. 
- The data in the database can be viewed through appropriate inquiries. 
- Choosing - a minimum of 15 queries should be considered. 
- As part of queries, aggregation functions and clauses learned during the class should be used. 
- Entering, deleting, and updating data is done by appropriate SQL commands. 
- Make a diagram of the database. 
  
### Requirements for 85% grade: 
All requirements for a satisfactory assessment and additionally procedures (minimum 3) and functions (minimum 1) facilitating data management (entering, modifying, deleting, and selecting) with the following limitations: 
- Procedures must differ in the way they work. 
- Each of the procedures / functions uses different data. 
- Procedures / functions are called with a different number of arguments and can return values of different types. 
  
### Requirements for 100% grade: 
- All requirements for a good grade and additionally a minimum of 3 triggers of different types (after / instead of) fired for different DML commands (update, insert, delete). 
  
#### Here you can see the diagram of the database. As you can see it consists of 7 tables with different primary and foreign keys. 
  
![diagram](https://user-images.githubusercontent.com/63752476/159244807-93119555-9976-4a24-a623-d42961b6215e.jpg) 
  
__SQL Server was chosen to manage the database.__ 
  
On repo you can find 5 files: 
- diagram.jpg 
> Diagram of the database. 
- db_setup.sql 
> DDL commands that create all tables with attributes, keys, references, and constraints. 
- queries.sql 
> All queries, triggers, procedures, and functions of this project. 
- data.sql 
> Sample data which was generated using Python, then converted from .csv to SQL inserts. 
- Założenia.pdf  
> Database structure description, but only in polish, cause I am studying in Poland. 
  
 
