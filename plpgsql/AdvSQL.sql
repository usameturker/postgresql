-- açıklama 

-- **************  DEĞİŞKEN TANIMLAMA *****************************

do $$ -- anonymous blok , dolar işaretini özel karakterler öncesinde tırnak işaretlerini kullanmamak için
declare
	counter integer := 1 ; -- counter isminde değişken oluşturuldu ve default değeri verildi
	first_name varchar(50) := 'Ahmet' ;
	last_name varchar(50) := 'Gok'; 
	payment numeric(4,2) := 20.5 ; -- numeric(precision , scale)-> precision : 1 den 38 e kadar değer girebiliyorum
begin
	raise notice '% % % has been paid % USD',
		counter,
		first_name,
		last_name,
		payment;
end $$ ;

-- Task 1 : değişkenler oluşturarak ekrana  Ahmet ve Mehmet beyler 120 tl ye bilet aldılar.  
	--cümlesini ekrana basınız
do $$
declare
	first_person varchar(50) := 'Ahmet';
	second_person varchar(50) := 'Mehmet';
	payment numeric(3) := 120;
begin
	raise notice '% ve % Beyler % TL ye bilet aldılar',
		first_person,
		second_person,
		payment;
end $$;


-- ********  BEKLETME KOMUDU **************
do $$
declare
	create_at time := now(); -- atama yapıldı
begin	
	raise notice '%' , create_at;
	perform pg_sleep(5); -- 5 saniye bekle
	raise notice '%' , create_at;
end $$;
	

-- ******** TABLODAN DATA TİPİNİ KOPYALAMA ********
do $$ 
declare
	film_title film.title%type;   -- film_title text ;
	--featured_title film.title%type;
begin
	-- 1 id li filmin ismini getirelim
	select title -- text
	from film
	into film_title  -- film_title := 'Kuzuların Sessizliği'
	where id=1;
	
	raise notice 'Film title with id 1 : %', film_title;
end $$ ;

-- ***************** ROW TYPE ********************
do $$
declare
	selected_actor actor%rowtype; 
begin
	-- id si 1 olan actoru getir
	select *
	from actor
	into selected_actor
	where id =1;
	
	raise notice 'The actor name is : % %',
		selected_actor.first_name,
		selected_actor.last_name;
end $$ ;

-- ******* Record Type *********************

do $$
declare
	rec record;
begin 
	-- filmi seçiyoruz
	select id, title, type
	into rec
	from film
	where id=2;
	
	raise notice '% % %', rec.id, rec.title, rec.type;
end $$ ;

-- ******** İç İÇE BLOK ********************

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


-- //////////////////// Control Structures ///////////////////////

-- ******************** If Statement ****************

-- syntax :

if condition then 
		statement;
end if ;

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
	end if;
end $$;

-- ************** IF-THEN-ELSE ****************

/* 
		if condition then
  			statements;
		else
  			alternative-statements;
		END if;
*/


do $$
declare
	selected_film film%rowtype;
	input_film_id film.id%type := 1;
begin
	select * from film
	into selected_film
	where id= input_film_id;
	
	if not found then
		raise notice 'Girmiş olduğunuz id li film bulunamadı : % ', input_film_id;
	else 
		raise notice 'Filmin ismi : %' , selected_film.title;
	end if;

end $$;

-- ************* IF-THEN-ELSE-IF ************************


-- syntax :

if condition_1 then
  		statement_1;
		
	elsif condition_2 then
  		statement_2
		...
		
	elsif condition_n then
  		statement_n;
		
	else
  		else-statement;
		
	end if;

/*
 	Task : 1 id li film varsa ; 
			süresi 50 dakikanın altında ise Short, 
			50<length<120 ise Medium, 
			length>120 ise Long yazalım
*/
do $$
declare
	v_film film%rowtype;
	len_description varchar(50);

begin
	select * from film
	into v_film
	where id = 3;
	
	if not found then 
		raise notice 'Filim bulunamadı';
	else 
		if v_film.length > 0 and v_film.length <= 50 then
				len_description='Kısa';
			elseif v_film.length>50 and v_film.length<120 then
				len_description='Orta';
			elseif v_film.length>120  then
				len_description='Uzun';
			else
				len_description='Tanımlanamıyor';
		 end if;
	
	raise notice ' % filminin süresi : %  ', v_film.title, len_description;
	end if;

end $$;

-- ******** Case Statement **************************

case search-expression
   when expression_1 [, expression_2, ...] then
   	statements
  [ ... ]
  [else
      else-statements ]
END case;

-- Task : Filmin türüne göre çocuklara uygun olup olmadığını ekrana yazalım

do $$
declare
	tur film.type%type;
	uyari varchar(50);

begin

	select type 
	from film
	into tur
	where id = 1 ;
	
	if found then
		case tur
			when 'Korku' then
				uyari='Çocuklar için uygun değil';
		    when 'Macera' then
				uyari='Çocuklar için uygun';
			when 'Animasyon' then
				uyari='Çocuklar için tavsiye edilir';
			else 
				uyari ='Tanımlanamadı';
		end case;		
		raise notice '%',uyari;
	 end if;

end $$;


--************** LOOP ********************

-- syntax
<<label>>
loop
   statements;
   
end loop;

-- loop u sonlandırmak için loopun içine if yapısını kullanabiliriz
<<label>>
loop
   statements;
   if condition then
      exit; -- loop dan çıkmama sağlayan komut
   end if;
end loop;

-- nested loop 

<<outer>>
loop 
   statements;
   <<inner>>
   loop
     /* ... */
     exit <<inner>>
   end loop;
end loop;

-- Fibonacci Sayiları 1, 1, 2, 3, 5, 8, ....
 -- n integer : 4 ;

do $$
declare
	n integer :=2; -- 2 
	counter integer :=0; 
	i integer :=0;
	j integer :=1;
	fib integer :=0;
begin 
	if(n<1) then
		fib:=0;
	end if;
	loop 
		exit when counter = n;
		counter := counter +1 ;
		select j,i+j into i, j ;  -- 1, 1, 2, 3, 5, 8, 13, 21, ....
	end loop;
	fib := i;
	raise notice '%', fib;
end $$;

-- ************ WHILE LOOP *************************

-- syntax : 
	
[ <<label>> ]
while condition loop
   statements;
end loop;

-- Task : 1 dan 4 e kadar counter değerlerini ekrana basalım

do $$
declare
	n integer:=4;
	counter integer :=0;
begin
	while counter<n loop
		counter:=counter+1;
		
	raise notice '%',counter;
	end loop;
end $$;


-- Cevap 2 : 

do $$
declare 
   counter integer := 0;
begin
   while counter < 5 loop
      raise notice 'Counter %', counter;
      counter := counter + 1;
   end loop;
end$$;

-- **************  FOR LOOP *********************

-- syntax :

[ <<label>> ]
for loop_counter in [ reverse ] from.. to [ by step ] loop
    statements
end loop [ label ];

-- Örnek (in) 

do $$

begin
	for counter in 1..5 loop
		raise notice 'counter: %',counter;
	end loop;
end $$;

-- Örnek (reverse )

do $$

begin
	for counter in reverse 5..1 loop
		raise notice 'counter : %', counter;
	end loop;
end $$;

-- Örnek (by) 

do $$

begin
	for counter in 1..10 by 2 loop
		raise notice 'counter : %', counter;
	end loop;
end $$;

-- Örnek : DB de loop kullanımı

-- syntax :
[ <<label>> ]
for target in query loop
    statements
end loop [ label ];

-- Task : Filmleri süresine göre sıraladığımızda en uzun 2 filmi gösterelim
do $$

declare
	f record;
begin
	for f in select title,length
			 from film
			 order by length desc
			 limit 2
	loop 
		raise notice '% ( % dakika )',f.title,f.length;
	end loop;
end $$;

-- ***************** EXIT *****************

exit when counter > 10;

-- yukardaki ile aşağıdaki aynı işi yapıyor, üst tarafdaki daha kullanışlı

if counter >10 then 
	exit;
end if;

-- Örnek 

do $$ 
begin
	<<inner_block>>
	begin
		exit inner_block;
		raise notice 'inner block dan merhaba';
	
	end ;

	raise notice 'outer block dan Merhaba';
end $$;


-- ************ CONTINUE ******************

-- mevcut iterasyonu atlamak için kullanılır
-- Syntax : 

continue [loop_label] [when condition] -- [] bu kısımlar opsiyoneldir
 
-- Örnek : 

do $$ 

declare
	counter integer :=0;  -- counter isimli değişken oluşturup default degerini girdim

begin
	loop
		counter := counter +1; -- loop içinde counter değerim 1 artırılıyor
		exit when counter >10; -- counter değerim 10 dan büyük olursa loop dan çık
		continue when mod(counter,2)=0; -- counter çift ise bu iterasyonu terk et
		raise notice '%', counter; -- counter değerimi ekrana basıyorum
	end loop;
end $$;
	
	
	
	
	
	
	
	



