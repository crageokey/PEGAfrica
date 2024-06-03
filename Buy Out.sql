--Buy out---
select 
date(closedat) as date_invoice, 
customerStatus,
'Discount' as journal_id,
customerid as partner_id,
contractid as "reference/description",
'Bulk Payment' as "invoice_line_ids/product_id",
'Buy-Out Discount' as "invoice_line_ids/name",
658800 as "invoice_line_ids/account_id",
applieddiscount as "invoice_line_ids/price_unit",
'TVA Discount' as "invoice_line_ids/invoice_line_tax_ids",
productType as "invoice_line_ids/analytic_account",
accountnumber
FROM public.dlight_mashup 
where date_of_activity = '2022-05-30'
AND date(closedat) between '2022-03-01' and '2022-05-30'
and countryid= 'CDI'
and customerstatus not ilike 'PAID_OFF'
and customerStatus ='Finished Payment'
and paymentmethod = 'FINANCED'
order by date(closedat)
