-- Create table and import csv 

create table foods(
	food_id bigint,
	item_name varchar(255),
	storage_type varchar(255),
	package_size int,
	package_size_uom varchar(255),
	brand_name varchar(255),
	package_price decimal(10,2),
	price_last_updated_ts timestamp without time zone
)

/*
  update null value
*/

update foods
	set storage_type = 'dry'
		where food_id = 13
		or food_id = 14


/*
	change the package_size_uom field output name to something that is easier for an end-user to understand
*/

select
	f.price_last_updated_ts,
	f.food_id,
	f.item_name,
	f.storage_type,
	f.package_size,
	f.package_size_uom as package_size_unit_of_measurement,
	f.brand_name,
	f.package_price
from
	foods f
where
	brand_name = 'H-E-B (private label)'


/*
	case sensitivity in where clause; food_id 19
*/

select
	f.price_last_updated_ts,
	f.food_id,
	f.item_name,
	f.storage_type,
	f.package_size,
	f.package_size_uom as package_size_unit_of_measurement,
	f.brand_name,
	f.package_price
from
	foods f
where
	lower(brand_name) = 'h-e-b (private label)'


/*
	add column for is_canned_yn; ilike used to make the match case insensitive
*/

select
	f.price_last_updated_ts,
	f.food_id,
	f.item_name,
	f.storage_type,
	f.package_size,
	f.package_size_uom as package_size_unit_of_measurement,
	f.brand_name,
	f.package_price,
	case when item_name ilike '%canned' then 'Y' else 'N' end as is_canned_yn
from
	foods f


/*
	get the percent of private label brands
	
	steps
	1. get the total nuumber of records that are heb private label
	2. get the total number of records acrooss the table
	3. take #1 divided by #2
	4. cast data type to decimal
*/

select
	cast(n.heb_records as decimal(10,2)) / cast(d.total_records as decimal(10,2))
from
	(
		select
			count(*) as heb_records
		from
			foods f
		where
			f.brand_name ilike 'h-e-b (private label)'
	) n -- numerator
		cross join (
						select
							count(*) as total_records
						from
							foods f
					) d -- denominator
