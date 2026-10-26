-------------------------------------------------1

SELECT COUNT(*) as total_rental_amount
FROM lease_agreement
group by property_id
having count(*) < 2;

-------------------------------------------------2

SELECT p.adress, count (l.lease_id) as total_leases
FROM lease_agreement l
right JOIN Property p ON l.property_id = p.property_id
GROUP BY p.property_id, p.adress;

-------------------------------------------------3