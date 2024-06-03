--callnotes--
with base_script as (
select 
dc.contractid,dc.accountnumber, date(dc.createdat) as swaprequest_date, callnotes,rp.replacementdate,dm.sc_name, 
case when dm.producttype in ('X500','X500P','X500M','X450') then 'X500'
	 when dm.producttype in ('X740','X740P') then 'X740'
	 when dm.producttype in ('X1000','X1000P','X1000 New','X850 Plus') then 'X1000'
	 when dm.producttype in ('X1200','X1200M','X1200P','X1200S') then 'X1200'
	 else dm.producttype end as product_type,  
case when (callnotes ilike '%#comp#PEG to collect%' and callnotes ilike '%#Battery%') then 1
	 when (callnotes ilike '%#comp#Device collected by UNKNOWN agent%' and callnotes ilike '%#Battery%') then 2
	 when (callnotes ilike '%#comp#Device collected by known PEG agent%' and callnotes ilike '%#Battery%') then 3
	 when (callnotes ilike '%#comp#Device collected by GO agent%' and callnotes ilike '%#Battery%') then 4
	 when (callnotes ilike '%#comp#Device collected by DSR agent%' and callnotes ilike '%#Battery%') then 5
	 when (callnotes ilike '%#comp#troubleshooting ongoing with customer%' and callnotes ilike '%#Battery%') then 6
	 when (callnotes ilike '%#comp#Will drop at SC%' and callnotes ilike '%#Battery%') then 7
	 when (callnotes ilike '%#comp#Device confirmed at SC%' and callnotes ilike '%#Battery%') then 8 end as faultstatus,
customerstatus, writtenoff 
from private.dlight_callrecords dc
left join 
	(select date(createdat) as replacementdate, contractid,accountnumber,calltypeentity, componenttype from (
 	SELECT createdat, contractid,accountnumber,calltypeentity, componenttype, 
 	ROW_NUMBER() OVER (PARTITION BY contractid ORDER BY date(createdat) desc) AS ROWNUM 
    from private.dlight_callrecords dc 
	where calltypeentity = 'WARRANTY_REPLACEMENT'
	--and date(createdat) > '2021-09-30' 
	and countryid = 11 
	and componenttype = 'BASE_UNIT')
  WHERE ROWNUM = 1) rp on dc.contractid = rp.contractid 
left join 
	(select contractid,customerstatus,sc_name,producttype,writtenoff 
	from public.dlight_mashup 
	where countryid = 'GH' 
	and date(date_of_activity) = CURRENT_DATE - 1) dm on dc.contractid = dm.contractid
where countryid = 11
and (callnotes ilike '%ANSWER BY CUSTOMER TALKED%' or callnotes ilike '%ANSWER BY FIELD STAFF_TALKED TO CUSTOMER%'
     or callnotes ilike '%ANSWER BY MOMO_TALKED TO CUSTOMER%' or callnotes ilike '%ANSWER BY ALT CONTACT_TALKED TO CUSTOMER%')
--and date(createdat) > '2021-12-30'
)
, pending_swaps as (
SELECT contractid,accountnumber,product_type,sc_name,swaprequest_date,callnotes,
replacementdate,faultstatus, CURRENT_DATE - swaprequest_date as ageindays, 
case when CURRENT_DATE - swaprequest_date <= 30 then '1mth'
	when CURRENT_DATE - swaprequest_date <= 90 then '2-3mths'
	when CURRENT_DATE - swaprequest_date <= 180 then '4-6mths' 
	else '6mths+' end as agegroup, customerstatus, writtenoff 
FROM (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY contractid ORDER BY swaprequest_date desc) AS ROWNUM 
    FROM base_script where faultstatus is not null and product_type != 'D30'
    and (replacementdate is null or swaprequest_date > replacementdate)
    and customerstatus not in ('Suspended','Cancelled','Finished Payment','Repair Return')
    )
  WHERE ROWNUM = 1)
select * from pending_swaps 
where accountnumber in  ('450335686','465850409','502244035','676050003','646901963','335029671','396713203','363004292','311030718','339692073','400231855','373575386','939783222','917244492','975435144','965100235','751808523','818941354','978939234','961384730','853247770','829019013','949850670','789619824','898986830'
)
order by swaprequest_date desc  