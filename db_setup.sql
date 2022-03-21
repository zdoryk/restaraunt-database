if exists(select 1 from master.dbo.sysdatabases where name = 'resto_zsbd') drop database resto_zsbd
GO
CREATE DATABASE resto_zsbd
GO


create table Dish
(
    dish_id    int         not null
        constraint Dish_pk
            primary key nonclustered,
    dish_title varchar(20) not null,
    weight     float       not null,
    price      float       not null,
    state_     bit
)
go

create table Employees
(
    employee_id int         not null
        constraint Employees_pk
            primary key nonclustered,
    job_id      int         not null
        constraint employee__job_id_fk
            references Jobs,
    first_name  varchar(30) not null,
    last_name   varchar(30) not null,
    salary      int         not null,
    hire_date   date        not null
)
go

create unique index Employees_employee_id_uindex
    on Employees (employee_id)
go

create table Jobs
(
    job_id     int         not null
        constraint Jobs_pk
            primary key nonclustered,
    job_name   varchar(15) not null,
    min_salary int         not null,
    max_salary int
)
go

create unique index Jobs_job_id_uindex
    on Jobs (job_id)
go

create unique index Jobs_job_name_uindex
    on Jobs (job_name)
go

create table [Order]
(
    order_id    int  not null
        constraint Order_date_pk
            primary key nonclustered,
    order_date  date not null,
    employee_id int  not null
        constraint order_employee_fk
            references Employees
)
go

create unique index Order_date_order_id_uindex
    on [Order] (order_id)
go

create table [Order/Dish]
(
    dish_id  int not null
        constraint order_dish_fk
            references Dish,
    order_id int not null
        constraint order_dish_order_fk
            references [Order]
)
go

create table Recipe
(
    dish_id       int not null
        constraint recipe_dish_fk
            references Dish
            on delete cascade,
    ingredient_id int not null
        constraint recipe_ingredient_fk
            references Warehouse,
    weight        int not null,
    constraint PK_Recipe
        primary key (ingredient_id, dish_id)
)
go

create table Warehouse
(
    ingredient_id   int         not null
        constraint Warehouse_pk
            primary key nonclustered,
    ingredient_name varchar(25) not null,
    price           float       not null,
    amount          float       not null
)
go

create unique index Warehouse_ingredient_id_uindex
    on Warehouse (ingredient_id)
go