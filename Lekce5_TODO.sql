--        _________________________________________
--________|         __        _    __      ___    |_______
--\       |   |    |__  |_/  / '  |__     |___    |      /
-- \      |   |__  |__  | \  \_.  |__      ___|.  |     /
-- /      |_______________________________________|     \
--/__________)                                (__________\
--
-- Lektor: Jiří Dvořák (Discord: Jirka D.)


------------
--  JOIN  --
------------
   
-- 7. úloha z minulé lekce: Spojte informace z tabulek cen a mezd (pouze informace o průměrných mzdách). 
-- Vypište z každé z nich základní informace, celé názvy odvětví a kategorií potravin a datumy měření, 
-- které vhodně naformátujete.

SELECT 
	cp.value AS Price_value,
	cpc."name" AS Category_name,
	cpib."name" AS Industry_name,
	cpay.payroll_year AS Payroll_measurement_year,
	TO_CHAR(cp.date_from, 'DD. Month YYYY') AS Price_measurement_from,
	TO_CHAR(cp.date_to, 'DD. Month YYYY') AS Price_measurement_to
FROM
	data_academy_content.czechia_price AS cp
	JOIN data_academy_content.czechia_payroll cpay
		ON date_part('year', cp.date_from) = cpay.payroll_year
		AND cpay.value_type_code = 5958
		AND cp.region_code IS NULL
	JOIN czechia_price_category AS cpc 
		ON cp.category_code = cpc.code
	JOIN czechia_payroll_industry_branch AS cpib 
		ON cpay.industry_branch_code = cpib.code;

-- 100.52
SELECT 
	AVG(value)
FROM 
	czechia_price
WHERE
	date_from = '2006-11-20 01:00:00.000 +0100'
	AND category_code = 115101
	AND region_code IS NOT NULL;

-- také 100.52 -> NULL region odpovídá průměru za všechny regiony
SELECT 
	*
FROM 
	czechia_price
WHERE
	date_from = '2006-11-20 01:00:00.000 +0100'
	AND category_code = 115101
	AND region_code IS NULL;




--------------
--  HAVING  --
--------------

-- Úkol 1: Vypište z tabulky covid19_basic_differences země s více než 5 000 000 potvrzenými případy COVID-19 
-- (data jsou za rok 2020 a část roku 2021).

-- NEFUKČNÍ - WHERE neakceptuje agregační funkce
SELECT
	country,
	SUM(confirmed) AS total_confirmed
FROM
	covid19_basic_differences AS cbd
WHERE 
	SUM(confirmed) > 5000000
GROUP BY country;

SELECT
	country AS country_yay,
	SUM(confirmed) AS total_confirmed
FROM
	covid19_basic_differences AS cbd
GROUP BY country
HAVING SUM(confirmed) > 5000000;

-- Úkol 2: Vyberte z tabulky economies roky a oblasti s populací nad 4 miliardy.

SELECT 
	country,
	"year",
	sum(population) AS total_population
FROM
	economies AS e
GROUP BY
	country, 
	"year"
HAVING 
	sum(population) > 4000000000
ORDER BY 
	total_population DESC;



>>>>> 19:10 POKRAČOVÁNÍ




-------------------------------
--  COMMON TABLE EXPRESSION  --
-------------------------------

-- Úkol 1: Pomocí operátoru WITH připravte tabulku s cenami nad 150 Kč. 
-- S její pomocí následně vypište jména takových kategorií potravin, které do této cenové hladiny spadají.


-- Úkol 2: Zjistěte, ve kterých okresech mají všichni praktičtí lékaři vyplněný telefon, fax, nebo e-mail. 
-- Pro tyto účely si připravte dočasnou tabulku s výčtem okresů, ve kterých tato podmínka naopak splněna není, 
-- pod názvem not_completed_provider_info_district.


-- Úkol 3: Vypište z tabulky economies průměr světových daní, při HDP vyšším než 70 miliard.
-- + zaokrouhlete průměr daní na 2 desetinná místa


------------------
--  TEMP TABLE  --
------------------

-- Úkol 1: Vytvořte dočasnou tabulku temp_{jmeno}_{prijemni}_orders. 
-- V tabulce budou sloupce order_id (s PK), customer_id (int), amount (numeric) a order_date (date).


-- Úkol 2: Přidejte do tabulky temp_{jmeno}_{prijemni}_orders dva řádky s hodnotami.
-- Zákazník č. 1 utratil 250 Kč dne 1.1.2024 a zákazník č. 5 utratil 300,50 Kč dne 2.1.2024.


-- Úkol 3: Hodnoty ve sloupci amount v tabulce temp_{jmeno}_{prijemni}_orders nyní 
-- přenásobte koeficientem 1.1 = hodnoty zvýšíme o 10%.


-- Úkol 4: Smažte tabulku temp_engeto_lektor_orders



-------------------------
--  MATERIALIZED VIEW  --
-------------------------

-- Úkol 1: Vytvořte mat. pohled s názvem mv_healthcare_provider_subset pro tabulku healthcare_provider. 
-- Do pohledu zahrňte sloupce provider_id, name, region_code, district_code. 
-- U sloupce name použijte funkci pro odstranění prázdných znaků.
	
	
-- Úkol 2: Vytvořte SELECT se zobrazením materializovaného pohledu.
	


-- Úkol 3: Aktualizujte data v pohledu.


-- Úkol 4: Smažte pohled z databáze.

---------------------
--  WINDOW FUNKCE  --
---------------------

-- Úkol 1: Vyzkoušejte si dotaz s funkci sum jako window function.


-- Úkol 2: Vyzkoušejte si i další window funkce.

