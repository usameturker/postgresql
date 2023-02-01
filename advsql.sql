------------ Create Variable -------------

do $$ -- Anonymous block -- $ ozel karakterler oncesinde '' isaretlerini kullanmamak icin
declare
	counter integer :=1; -- counter isminde degisken olusturuldu ve default deger olarak 1 verildi
	first_name varchar(50) := 'Ahmet';
	last_name varchar(50) := 'Gok';
	payment numeric(4,2) :=20.5; -- (4,2) toplamda 4 basamakli 2 basamak virgulden sonra. 38e kadar deger alabiliyor
begin
	raise notice '% % % has been paid % USD', counter,first_name,last_name,payment;
	
end $$;

----------- Bekletme Komudu ------------

do $$
declare
	create_at time :=now();
begin 
raise notice '%' , create_at;
perform pg_sleep(5); -- 5 saniye bekle
raise notice '%' , create_at;
end $$;


----------- Tablodan Data tipini Kopyalama -------
do $$
declare
	film_title film.title%type;
	featured_title film.title%type
begin
-- id'si 1 olan filmin ismini getir
select title from film into film_title where id=1;

------ Row Type----------

do $$
declare
   selected_actor actor%rowtype;
begin
   -- select actor with id 1   
   select * 
   from actor
   into selected_actor
   where id = 1;

   -- show the number of actor
   raise notice 'The actor name is % %',
      selected_actor.first_name,
      selected_actor.last_name;
end; $$



------ Sub Blocks ---------

do $$
<<outer_blok>>
declare  -- outher blok
	counter integer := 0;
begin
	counter := counter +1;
	raise notice 'counter değerim : %', counter;
	
	declare -- inner blok
		counter integer :=0;
		
	begin -- inner blok
		counter := counter +10 ;
		raise notice 'iç blokdaki counter değerim : % ', counter;
		raise notice 'dış blokdaki counter değerim : % ', outer_blok.counter;
	
	end; -- inner blok sonu
	
	raise notice 'dış blokdaki counter değerim : %', counter;
end $$ ;

-- ********** Constant **************** 

-- selling_price := net_price * 0.1 ;
-- selling_price := net_price + net_price * vat ;
do $$
declare 
	vat constant numeric := 0.1;
	net_price numeric := 20.5;
begin
	raise notice 'Satış fiyatı : %', net_price*(1+vat);
	-- vat := 0.05;   constant bir ifadeyi değiştirmeye çalışırsak hata alırız
end $$ ;

-- constant bir ifadeye RT de değer verebilir miyim ???

do $$ 
declare 
	start_at constant time := now();
begin
	raise notice 'bloğun çalışma zamanı : %', start_at;
end $$ ;

-- ******************** If Statement ****************
/*
if condition then 
		statement;
end if ;     */

-- Task : 0 id li filmi bulalım eğer yoksa ekrana uyarı yazısı verelim
do $$
declare
	selected_film film%rowtype;
	input_film_id film.id%type :=1;
begin
	select * from film
	into selected_film
	where id = input_film_id;
	
	if not found then
		raise notice 'Girdiğiniz id li film bulunamadı : %', input_film_id;
	else
     raise notice 'The film title is %', selected_film.title;
	end if;
end $$;


--------- IF - ELSE Statement ---------------


do $$
declare
   v_film film%rowtype;
   len_description varchar(100);
begin  

  select * from film
  into v_film
  where id = 4;
  
  if not found then
     raise notice 'Film not found';
  else
      if v_film.length >0 and v_film.length <= 50 then
		 len_description := 'Short';
	  elsif v_film.length > 50 and v_film.length < 120 then
		 len_description := 'Medium';
	  elsif v_film.length > 120 then
		 len_description := 'Long';
	  else 
		 len_description := 'N/A';
	  end if;
    
	  raise notice 'The % film is %.',
	     v_film.title,  
	     len_description;
  end if;
end $$


----------  LOOP - Fibonacci Series -------------

do $$
declare
   n integer:= 7;
   fib integer := 0;
   counter integer := 0 ; 
   i integer := 0 ; 
   j integer := 1 ;
begin
	if (n < 1) then
		fib := 0 ;
	end if; 
	loop 
		exit when counter = n ; 
		counter := counter + 1 ; 
		 select j, i + j into i,j ;
	end loop; 
	fib := i;
    raise notice '%', fib; 
end; $$



-------- While Loop --------


do $$
declare 
   counter integer := 0;
begin
   while counter < 5 loop
      raise notice 'Counter %', counter;
	  counter := counter + 1;
   end loop;
end$$;


----------- For Loop ----------

-- In --

do $$
begin
   for counter in 1..5 loop   ---- counter degiskenini tanimlamaya gerek yok
	raise notice 'counter: %', counter;
   end loop;
end; $$

--Reverse In --

do $$
begin
   for counter in reverse 5..1 loop
      raise notice 'counter: %', counter;
   end loop;
end; $$

-- In and By --

do $$
begin 
  for counter in 1..6 by 2 loop
    raise notice 'counter: %', counter;
  end loop;
end; $$

-- Get Data from Database by using For Loop --
do $$
declare a record;
begin
for a in select title, length from film order by length desc
loop
raise  notice '% (% mins)', a.title ,a.length;
end loop;
end; $$