-- Una fila por fecha_venta
select
    fecha_venta,
    count(*)                         as numero_ventas,
    sum(cantidad)                    as unidades_vendidas,
    sum(cantidad * precio_unitario)  as ingreso_total   -- INTEGER x DECIMAL(12,2) conserva la precisión decimal
from {{ ref('stg_ventas') }}
group by fecha_venta
