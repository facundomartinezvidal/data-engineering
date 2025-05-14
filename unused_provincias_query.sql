SELECT p.provincia_cod, p.provincia_desc
FROM provincias p
LEFT JOIN fabricantes f
    ON p.provincia_cod = f.provincia_cod
WHERE f.provincia_cod IS NULL;