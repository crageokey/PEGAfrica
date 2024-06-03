--Discount--
select  CAST(a.CreatedAt AS DATE) as date_invoice,
'Discount' as journal_id,
b.customerid as partner_id,
b.contractid as "reference/description",
'Bulk Payment' as "invoice_line_ids/product_id",
'Promotion Sakanal' as "invoice_line_ids/name",
673000 as "invoice_line_ids/account_id",
a.Amount as "invoice_line_ids/price_unit",
'TVA Discount' as "invoice_line_ids/invoice_line_tax_ids",
productType as "invoice_line_ids/analytic_account",
a.accountnumber
FROM private.dlight_incomingtransaction a
Join private.dlight_paymenttransaction b on a.IncomingTransactionId=b.IncomingTransactionId
JOIN public.dlight_mashup c on b.contractid = c.contractid 
where b.paymentStatusTypeEntity='COMPLETED' 
and a.source = 'BULK_PURCHASE_CREDIT'
and a.CountryId= 'CDI' 
and a.inactivedate isNull
and b.inactivedate isNull  
and c.date_of_activity = CURRENT_DATE -1
AND Payment_Plan_Name NOT LIKE '%Demo%'
AND CustomerStatus not like '%Demo%'
and customerstatus not ilike 'PAID_OFF'
and customerstatus not ilike 'Finished Payment'
and a.CreatedAt between '2022-03-01' and '2022-05-30'
order by CAST(a.CreatedAt AS DATE);