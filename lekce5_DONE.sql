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
    cpc.name AS food_category,
    cp.value AS price,
    cpib.name AS industry,
    cpay.value AS average_wages,
    TO_CHAR(cp.date_from, 'DD. Month YYYY') AS price_measured_from,
    TO_CHAR(cp.date_to, 'DD.MM.YYYY') AS price_measured_to,
    cpay.payroll_year
FROM
    czechia_price AS cp
	JOIN czechia_payroll AS cpay
	    ON date_part('year', cp.date_from) = cpay.payroll_year
	    AND cpay.value_type_code = 5958    
	    AND cp.region_code IS NULL
	JOIN czechia_price_category AS cpc
	    ON cp.category_code = cpc.code
	JOIN czechia_payroll_industry_branch AS cpib    
	    ON cpay.industry_branch_code = cpib.code;

SELECT 
	* 
FROM 
	czechia_price;


SELECT 
	* 
FROM 
	czechia_payroll;

SELECT 
	*
FROM
	czechia_price AS cp
	JOIN czechia_payroll AS cpay
	    ON date_part('year', cp.date_from) = cpay.payroll_year
	    AND cpay.value_type_code = 5958 
	    AND cp.region_code IS NULL;

SELECT
    cp.value AS price,
    cpay.value AS average_wages,
    cp.date_from AS price_measured_from,
    cp.date_to AS price_measured_to,
    cpay.payroll_year,
    cpay.payroll_quarter
FROM
    czechia_price AS cp
	JOIN czechia_payroll AS cpay
	    ON date_part('year', cp.date_from) = cpay.payroll_year
	    AND cpay.value_type_code = 5958    
	    AND cp.region_code IS NULL;


    

--------------
--  HAVING  --
--------------

-- Úkol 1: Vypište z tabulky covid19_basic_differences země s více než 5 000 000 potvrzenými případy COVID-19 
-- (data jsou za rok 2020 a část roku 2021).


-- nefunkční dotaz -> nutnost použít HAVING
SELECT
	country, 
	sum(confirmed) AS total_confirmed
FROM covid19_basic_differences
WHERE sum(confirmed) > 5000000
GROUP BY country;

SELECT
	country, 
	sum(confirmed) AS total_confirmed
FROM covid19_basic_differences
GROUP BY country
HAVING sum(confirmed) > 5000000;

-- Úkol 2: Vyberte z tabulky economies roky a oblasti s populací nad 4 miliardy.

SELECT
	country, 
	year, 
	sum(population) AS overall_population
FROM economies e
GROUP BY 
	country, 
	year
HAVING sum(population) > 4000000000
ORDER BY overall_population DESC;


-------------------------------
--  COMMON TABLE EXPRESSION  --
-------------------------------

-- Úkol 1: Pomocí operátoru WITH připravte tabulku s cenami nad 150 Kč. 
-- S její pomocí následně vypište jména takových kategorií potravin, které do této cenové hladiny spadají.

WITH high_price AS (
    SELECT category_code AS code
    FROM czechia_price
    WHERE value > 150
)
SELECT DISTINCT cpc.name
FROM high_price hp
JOIN czechia_price_category cpc
    ON hp.code = cpc.code;


WITH high_price AS (
    SELECT DISTINCT category_code AS code
    FROM czechia_price
    WHERE value > 150
)
SELECT DISTINCT cpc.name
FROM high_price hp
JOIN czechia_price_category cpc
    ON hp.code = cpc.code;


-- Úkol 2: Zjistěte, ve kterých okresech mají všichni praktičtí lékaři vyplněný telefon, fax, nebo e-mail. 
-- Pro tyto účely si připravte dočasnou tabulku s výčtem okresů, ve kterých tato podmínka naopak splněna není, 
-- pod názvem not_completed_provider_info_district.

WITH not_completed_provider_info_district AS (
    SELECT DISTINCT district_code
    FROM healthcare_provider
    WHERE 
        phone IS NULL 
        AND email IS NULL 
        AND fax IS NULL 
        AND provider_type = 'Samost. ordinace všeob. prakt. lékaře'
)
SELECT *
FROM czechia_district
WHERE code NOT IN (
    SELECT *
    FROM not_completed_provider_info_district
);

-- Úkol 3: Vypište z tabulky economies průměr světových daní, při HDP vyšším než 70 miliard.
-- + zaokrouhlete průměr daní na 2 desetinná místa
    
WITH large_gdp_area AS (
    SELECT *
    FROM economies
    WHERE GDP > 70000000000
)
SELECT
    round(avg(taxes)::numeric, 2) AS taxes_average
	--round(avg(taxes), 2) AS taxes_average
FROM large_gdp_area;


------------------
--  TEMP TABLE  --
------------------

-- Úkol 1: Vytvořte dočasnou tabulku temp_{jmeno}_{prijemni}_orders. 
-- V tabulce budou sloupce order_id (s PK), customer_id (int), amount (numeric) a order_date (date).

CREATE TEMP TABLE temp_engeto_lektor_orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT,
    amount NUMERIC(10, 2),
    order_date DATE
);


-- Úkol 2: Přidejte do tabulky temp_{jmeno}_{prijemni}_orders dva řádky s hodnotami.
-- Zákazník č. 1 utratil 250 Kč dne 1.1.2024 a zákazník č. 5 utratil 300,50 Kč dne 2.1.2024.

INSERT INTO temp_engeto_lektor_orders (customer_id, amount, order_date) 
VALUES (1, 250.00, '2024-01-01'),
    (5, 300.50, '2024-01-02');


-- Úkol 3: Hodnoty ve sloupci amount v tabulce temp_{jmeno}_{prijemni}_orders nyní 
-- přenásobte koeficientem 1.1 = hodnoty zvýšíme o 10%.

UPDATE temp_engeto_lektor_orders
SET amount = amount * 1.1
WHERE order_date = '2024-01-01';


-- Úkol 4: Smažte tabulku temp_engeto_lektor_orders

DROP TABLE IF EXISTS temp_engeto_lektor_orders;


-------------------------
--  MATERIALIZED VIEW  --
-------------------------

-- Úkol 1: Vytvořte mat. pohled s názvem mv_healthcare_provider_subset pro tabulku healthcare_provider. 
-- Do pohledu zahrňte sloupce provider_id, name, region_code, district_code. 
-- U sloupce name použijte funkci pro odstranění prázdných znaků.

CREATE MATERIALIZED VIEW mv_healthcare_provider_subset AS 
    SELECT
	    hp.provider_id,
	    trim(hp.name) AS name,
        hp.region_code,
	    hp.district_code
	FROM healthcare_provider hp 
	
	
-- Úkol 2: Vytvořte SELECT se zobrazením materializovaného pohledu.
	
SELECT * FROM mv_healthcare_provider_subset;


-- Úkol 3: Aktualizujte data v pohledu.
REFRESH MATERIALIZED VIEW mv_healthcare_provider_subset;


-- Úkol 4: Smažte pohled z databáze.
DROP MATERIALIZED VIEW IF EXISTS mv_healthcare_provider_subset;

---------------------
--  WINDOW FUNKCE  --
---------------------

-- Úkol 1: Vyzkoušejte si dotaz s funkci sum jako window function.

WITH sales_data AS (
    SELECT '2023-03-01' AS date, 'product 1' AS product, 40 AS sales
    UNION ALL
    SELECT '2023-03-02', 'product 1', 66
    UNION ALL
    SELECT '2023-03-03', 'product 1', 50
    UNION ALL
    SELECT '2023-03-03', 'product 1', 50
    UNION ALL
    SELECT '2023-03-05', 'product 1', 9
    UNION ALL
    SELECT '2023-03-05', 'product 2', 15
)
SELECT 
    *,  
    SUM(sales) OVER (PARTITION BY product ORDER BY date) AS value_cumulative_sum_default,  
    SUM(sales) OVER (PARTITION BY product ORDER BY date ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS value_cumulative_sum,  
    SUM(sales) OVER (PARTITION BY product ORDER BY date ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS value_cumulative_sum_last_2,  
    SUM(sales) OVER (PARTITION BY product ORDER BY date ROWS BETWEEN 1 PRECEDING AND 1 FOLLOWING) AS value_cumulative_sum_last_1_next_1
FROM sales_data;


-- Úkol 2: Vyzkoušejte si i další window funkce.

WITH sales_data AS (
    SELECT '2023-03-01' AS date, 'product 1' AS product, 40 AS sales
    UNION ALL
    SELECT '2023-03-02', 'product 1', 66
    UNION ALL
    SELECT '2023-03-03', 'product 1', 50
    UNION ALL
    SELECT '2023-03-03', 'product 1', 50
    UNION ALL
    SELECT '2023-03-05', 'product 1', 9
    UNION ALL
    SELECT '2023-03-05', 'product 2', 15
)
SELECT 
    *,
    RANK() OVER (PARTITION BY product ORDER BY date) AS value_rank,
    DENSE_RANK() OVER (PARTITION BY product ORDER BY date) AS value_dense_rank,
    ROW_NUMBER() OVER (PARTITION BY product ORDER BY date) AS value_row_number,
    LAG(sales) OVER (PARTITION BY product ORDER BY date) AS value_lag,
    LEAD(sales) OVER (PARTITION BY product ORDER BY date) AS value_lead,	
    LAST_VALUE(sales) OVER (PARTITION BY product ORDER BY product) AS value_last,
    FIRST_VALUE(sales) OVER (PARTITION BY product ORDER BY product) AS value_first
FROM sales_data