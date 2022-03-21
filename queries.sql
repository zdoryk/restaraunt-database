use resto_zasb;
go

/*
#################  Kwerendy: ################
*/


/*
1. Podać ile dań zawierających składnik 'lemon juice' było sprzedano przez pracownika "Roby Gorton"?
*/

select count(*) 'liczba dan'
from Recipe
where ingredient_id in
        (
            select Warehouse.ingredient_id
            from Warehouse
            where ingredient_name = 'lemon juice'
        )
and dish_id in (
        select dish_id
        from [Order/Dish]
        where order_id in (
                select order_id
                from [Order]
                where employee_id in (
                        select employee_id
                        from Employees
                        where last_name = 'Gorton'
                        and first_name = 'Roby'
                    )
            )
    )

/*
2. Jakie dania zawierają skłądniki które kosztują więcej niż 4.50?
*/
select distinct dish_title
from Dish
where dish_id in (
    select  dish_id
    from Recipe
    where ingredient_id in
          (
              select Warehouse.ingredient_id
              from Warehouse
              where price > 4.50
          )
)
/*
3. Ile dań o cenie mniejszej niż 30 nie możemy przygotować w związku z brakiem składników na magazynie
*/


select count(distinct dish_id) 'liczba'
from Recipe
where ingredient_id in
    (
        select ingredient_id
        from Warehouse
        where Recipe.weight < Warehouse.amount
    )
and Recipe.dish_id in (
    select Dish.dish_id
    from Dish
    where price < 30
)


/*
4. Ile mamy dań zawierających ingredient który kosztuje więcej niż 4 oraz
ma słowo 'Homemade' w nazwie?
*/


select count(*) 'Liczba dań'
from Recipe
where ingredient_id in (
        select ingredient_id
        from Warehouse
        where price > 4
)
and dish_id in (
        select dish_id
        from Dish
        where dish_title LIKE '%Homemade%'
);

/*
5. Podać nazwę oraz ilość ingredientów zostało na magazynie
   dla dań z ceną większą niż 30 oraz masą mniejszą za 100;
*/


select ingredient_name, amount
from Warehouse
where ingredient_id in (
        select ingredient_id
        from Recipe
        where dish_id in (
                select dish_id
                from Dish
                where price > 30
                and weight < 100
            )
    )




/*      Danya
6. Ile dań mają cenę niższą niż cena sumarna
    składników wchodzoncyh do tego dania
*/

select count(*)
from Dish
where price < (
	select sum(Warehouse.price)
	from Warehouse
	where ingredient_id in (
			select ingredient_id
			from Recipe
			where Recipe.dish_id = Dish.dish_id
	    )
    )

/*
7. Podać nazwę najpopularniejszego dania
*/

select dish_title
From Dish
where dish_id in (
    select top 1 dish_id
    from [Order/Dish]
    group by dish_id
    order by count(*) desc
)


/*
8. Podać nazwę najpopularniejszego dania w piątki
*/

select dish_title
From Dish
where dish_id in (
    select top 1 dish_id
    from [Order/Dish]
    where order_id in
        (
            select order_id
            from [Order]
            where datepart(dw, order_date) = 5
        )
    group by dish_id
    order by count(*) desc
)

/*
9. Wyświetl liczbe sprzedanych dań zawierające składnik 'olive oil'
*/

select count(*)
from [Order/Dish]
where dish_id in
    (
        select distinct dish_id
        from Recipe
        where ingredient_id in
            (
                select ingredient_id
                from Warehouse
                where ingredient_name = 'olive oil'
            )
    )

/*
10. Podać imię, nazwisko i pensji kelnera, który zarabia najwięcej?
*/

select top 1 first_name, last_name, max(salary) 'pensja'
from Employees
where job_id =
    (
        select job_id
        from Jobs
        where job_name = 'Waiter'
    )
group by first_name, last_name
order by max(salary) desc

/*             ???????????????????????
11. Podać imię, nazwisko kelnera, który
    sprzedał najwięcej dań 'Homemade Ketchup'?
*/

select last_name, first_name from Employees where employee_id in (
select employee_id from [Order] where order_id in (
select order_id from [Order/Dish]
where dish_id = (select dish_id from Dish where dish_title= 'Homemade Ketchup'))
group by employee_id
having count(*) =
    (
        select TOP 1 count(*)  from [Order] where order_id in (
                        select order_id from [Order/Dish]
                        where dish_id = (select dish_id from Dish where dish_title= 'Homemade Ketchup'))
                        group by employee_id
                        order by count(*) DESC
    )
);

/*
12. Który kelner sprzedał dań na największą kwotę?
*/

select first_name, last_name
from Employees
where employee_id =
      (
          select top 1 employee_id
          from Dish
                   RIGHT Join [Order/Dish] OD on Dish.dish_id = OD.dish_id
                   Join [Order] O on OD.order_id = O.order_id
          where employee_id in
                (
                    select employee_id
                    from Employees
                    where job_id = (select job_id from Jobs where job_name = 'Waiter')
                )
          group by employee_id
          order by sum(price) desc
      )

/*
13. Ile osób pracuję na każdym stanowisku?
*/

select (select job_name from Jobs where Jobs.job_id  = Employees.job_id) 'Stanowisko', count(*) 'liczba'
from Employees
group by job_id;

/*
select job_name, E.liczba
from Jobs
JOIN
    (
        select distinct job_id, count(*) 'liczba'
        from Employees E
        group by job_id
    ) E on E.job_id = Jobs.job_id
*/


/*
14. Podać imiona, nazwiaska oraz nazwy tych stanowisk na których
    pracownicy zarabiają minimalną
    czy maksymaksymalną stawkę na swoim stanowisku
*/

select (select job_name from Jobs where Jobs.job_id  = Employees.job_id), first_name, last_name, 'max' as 'salary'
from Employees
where salary = (select max_salary from jobs where job_id = Employees.job_id)
union all
select (select job_name from Jobs where Jobs.job_id  = Employees.job_id), first_name, last_name, 'min' as 'salary'
from Employees
where salary = (select min_salary from jobs where job_id = Employees.job_id)

/*
15. Ile dni upłynęło między datą zatrudnienia pierwszego pracownika
    a datą pierwszego zamówienia
*/

select DATEDIFF(day, (select min(hire_date) from Employees),(select min(order_date) from [Order]))


/*
###                                   ###
####                                 ####
#####       Procedury i funkcja     #####
####
###
*/


/*
1. Procedura służy do zwiększenia pensji pracowników na
określony procent. Jako argument do procedury podajemy nazwę stanowiska.
Jeśli podana wartość będzie równa się 'None'
to pensja będzie zwiększona dla wszystkich pracowników.
*/

ALTER PROCEDURE salary_increase
(
    @percentage as float = 10,
    @job_name as varchar(15) = 'None'
)
AS
BEGIN
    IF @job_name = 'None'
        BEGIN
            UPDATE Employees SET salary += salary * (@percentage/100)
            PRINT ('q')
        end
    ELSE
        BEGIN
            UPDATE Employees SET salary += salary * (@percentage/100)
            WHERE job_id =
                    (
                        select job_id
                        from Jobs
                        where job_name = @job_name
                    )
            PRINT ('2')
        end
END;

EXEC salary_increase @percentage=20
EXEC salary_increase @job_name='Waiter'
EXEC salary_increase

/*
2. Procedura służy do dodania nowego stanowisku do tabeli [Jobs].
Jako argumeny podajemy do procedury ID stanowiska, jego nazwę,
minimalną a maksymalną pensję. Jeśli podany ID już istnieje w
tabeli, to zostanie wyświetlony komunikat.
*/

CREATE PROCEDURE insert_jobs
    (
        @job_id AS INT,
        @job_name AS VARCHAR(15),
        @min_salary AS INT,
        @max_salary AS INT
    )
AS
BEGIN
    IF @job_id not in (select job_id from Jobs)
        INSERT INTO Jobs VALUES (@job_id, @job_name, @min_salary, @max_salary)
    ELSE
        PRINT 'This job_id already exists, try another one'
end

EXEC insert_jobs 300, 'Leather man', 300, 300


/*
3. Procedura służy do usunięcia wszystkich dań z tabeli [Dish]
i przepisów z tabeli [Recipe] którzy zawierają składnik, który
jest podany jako argument do tej procedury.
 */

CREATE PROCEDURE delete_dish_with_ingredient
    (
        @ingredient_name AS VARCHAR(25)
    )
AS
BEGIN
    DELETE Dish
    where dish_id in
        (
            select dish_id
            from Recipe
            where ingredient_id in
                (
                    select ingredient_id
                    from Warehouse
                    where ingredient_name = @ingredient_name
                )
        )
end


ALTER PROCEDURE delete_dish_with_ingredient_and_return_dish_list
    (
        @ingredient_name AS VARCHAR(25),
        @dish_list VARCHAR(MAX) = '' OUTPUT
    )
AS
BEGIN
    DECLARE cursor_ CURSOR FOR
        SELECT dish_id, dish_title FROM Dish
        where dish_id in
            (
                select dish_id
                from Recipe
                where ingredient_id in
                    (
                        select ingredient_id
                        from Warehouse
                        where ingredient_name = @ingredient_name
                    )
            )

    DECLARE
        @dish_id AS INT,
        @dish_title AS VARCHAR(15)

    OPEN cursor_
        FETCH NEXT FROM cursor_ into @dish_id, @dish_title

        WHILE @@FETCH_STATUS = 0
            BEGIN
                DELETE Dish
                where dish_id = @dish_id

                SET @dish_list += @dish_title
                FETCH NEXT FROM cursor_ into @dish_id, @dish_title
            end

    CLOSE cursor_
    DEALLOCATE cursor_
end

DECLARE @dishes VARCHAR(MAX)

EXEC delete_dish_with_ingredient_and_return_dish_list
		@ingredient_name='honey'
		,@dish_list = @dishes OUTPUT

PRINT @dishes


EXEC delete_dish_with_ingredient
        @ingredient_name='honey'
/*
1. Funkcja dla podanego pracownika zwraca procent od wszystkich zamówień,
które realizował podany pracownik.
*/


alter function employee_percent_orders(@employee_id int)
returns float
as
begin
	declare @all_orders float, @employee_order float
	set @all_orders = (select count(*) from [Order])
	set @employee_order = (select count(*) from [Order] where employee_id = @employee_id group by employee_id)

	declare @result float
	set @result = (@employee_order / @all_orders) * 100
	return @result
end
go

/*
2. Funkcja zwraca liczbę zamówień, które były realizowane w podany dzień.
*/
create function orders_per_day(@date date)
returns int
as
begin
	declare @result int

	set @result = (select count(*) from [Order] where order_date = @date)

	return @result

end
go

/*
3. Funkcja wypisująca wszystkie składniki dla dania
*/

create function dish_ingredients(@dish_title varchar(max))
returns varchar(1000)
as
begin
	declare @ingredients varchar(1000), @ingr varchar(50)
	declare @ingredients_cursor cursor

	set @ingredients_cursor = cursor for
		select Warehouse.ingredient_name from Warehouse where ingredient_id in (
		select ingredient_id from Recipe
		where dish_id = (select Dish.dish_id from Dish where dish_title = @dish_title))

	open @ingredients_cursor
	FETCH NEXT from @ingredients_cursor into @ingr
	set @ingredients = @ingr + '|'

	while @@FETCH_STATUS = 0
	begin
		set @ingredients += @ingr + '|'
		FETCH NEXT from @ingredients_cursor into @ingr
	end

	close @ingredients_cursor

	return @ingredients
end
go


/*
###
####
#####       TRIGGERS
####
###
*/

/*
1. Wyzwalacz który przy wstawieniu nowej wartości wynagrodzenia dla pracownika
    sprawdza czy ta wartość znachodzi w przedziale "min max salary" dla
    stanowiska na którym znajduję ten pracownik
*/

GO
ALTER TRIGGER salary_update
ON Employees
AFTER UPDATE, INSERT
AS
BEGIN
    DECLARE
		@insert_cursor cursor,
        @insEmpID INT, --= (SELECT employee_id from inserted),
        @minSalary money = (SELECT distinct min_salary from jobs, inserted where jobs.job_id = (select distinct job_id from inserted)),
        @maxSalary money = (SELECT distinct max_salary from jobs where jobs.job_id = (select distinct job_id from inserted)),
        @insSalary INT = (select distinct salary from inserted)



		set @insert_cursor = cursor for
			select employee_id from inserted



    IF (@insSalary > @maxSalary)
    BEGIN
		open @insert_cursor
		FETCH NEXT from @insert_cursor into @insEmpID

		update employees
        set salary = @maxSalary
        where employee_id = @insEmpID
        print ('Zmodyfikowano wynagrodzenie do wartosci maksymalnej dla pracownika '
                   + cast(@insEmpID as varchar(5)))

		while @@FETCH_STATUS = 0
		begin
			update employees
			set salary = @maxSalary
			where employee_id = @insEmpID
			print ('Zmodyfikowano wynagrodzenie do wartosci maksymalnej dla pracownika '
					   + cast(@insEmpID as varchar(5)))
			FETCH NEXT from @insert_cursor into @insEmpID
		end
    end


	IF (@insSalary < @minSalary)
    BEGIN
		open @insert_cursor
		FETCH NEXT from @insert_cursor into @insEmpID

        update employees
        set salary = @minSalary
        where employee_id = @insEmpID
        print ('Zmodyfikowano wynagrodzenie do wartosci minimalnej dla pracownika '
                   + cast(@insEmpID as varchar(5)))

		while @@FETCH_STATUS = 0
		begin
			update employees
			set salary = @minSalary
			where employee_id = @insEmpID
			print ('Zmodyfikowano wynagrodzenie do wartosci minimalnej dla pracownika '
					 + cast(@insEmpID as varchar(5)))
			FETCH NEXT from @insert_cursor into @insEmpID

		end
    end
END
GO


-- Sprawdzanie

update Employees
set salary = 10000
where employee_id = 17

insert into Employees VALUES (20, 4, 'Adrian', 'Lalka', 100, '2018-06-14')

/*
2. Wyzwalacz który przy pełnym usuwaniu dania z tabeli "Recipe"
    ustawia kolumnę "state_" w tabeli "Dish" na 0
*/

CREATE TRIGGER dish_state
ON Recipe
AFTER DELETE
AS
BEGIN
    DECLARE
        @del_dish_id INT = (SELECT dish_id from deleted)

    IF NOT EXISTS(Select * from Recipe where dish_id = @del_dish_id)
        BEGIN
            UPDATE Dish
            SET state_ = 0
            where dish_id = @del_dish_id
        end
end

/*
3. Wyzwalacz który po zmodyfikowaniu płacy minimalnej "min_salary" w tabeli "Jobs"
    zmieni place każdemy pracownikowi o taką wartość o jaką zmieniła się
    płaca minimalna dla jego stanowiska. Napisz polecenie uruchamiające wyzwalacz.
*/

GO
Alter trigger min_salary_update
on Jobs
instead of update
as
BEGIN
    declare @job_id varchar(10) = (select job_id from inserted)
	declare @currentMin money = (select min_salary from Jobs where Jobs.job_id = @job_id)
	declare @newMin money = (select min_salary from inserted)
	declare @diff money = @newMin - @currentMin

	update Jobs
	set min_salary = @newMin
	where job_id = @job_id

	update Employees
	set salary = salary + @diff
	where Employees.job_id = @job_id

END

