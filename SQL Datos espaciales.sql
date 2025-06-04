use tempdb
go

select * from sys.spatial_reference_systems


select * from sys.spatial_reference_systems
where spatial_reference_id = 4326


select distinct unit_of_measure, unit_conversion_factor
from sys.spatial_reference_systems


-- geometry: representa los datos en un sistema de coordenadas euclidiano (plano)
-- geography: representa los espaciales sobre la superficie de la Tierra, utilizando un modelo esférico. El SRID 4326 es el más común y representa el sistema de coordenadas WGS 84 (el estándar GPS)

-- Para geometry:
-- POINT(x y).

DECLARE @punto1 geometry = geometry::STGeomFromText('POINT(10 10)', 0);
DECLARE @punto2 geometry = geometry::STGeomFromText('POINT(15 15)', 0);

SELECT @punto1.STDistance(@punto2) AS Distancia;

-- LINESTRING(x1 y1, x2 y2, ...)

DECLARE @Linea geometry = geometry::STGeomFromText('LINESTRING(5 5, 15 10)',0)
SELECT
    @Linea.STLength() AS Longitud,
    @Linea.STStartPoint().ToString() AS PuntoInicial,
    @Linea.STEndPoint().ToString() AS PuntoFinal,
    @Linea.STNumPoints() AS CantidadDePuntos,
    @Linea.STIsSimple() AS EsSimple,
    @Linea.STIsValid() AS EsValida;


-- POLYGON((x1 y1, x2 y2, ..., x1 y1)) ← el primero y último punto deben cerrar la figura

Declare @shape geometry;
Set @shape = geometry::STGeomFromText('POLYGON((10 10, 25 15, 35 15, 40 10, 10 10))', 0);
Select @shape;


--Dibujar dos formas usando geometry
Declare @shape1 geometry;
Declare @shape2 geometry;

Set @shape1 = geometry::STGeomFromText('POLYGON((10 10, 25 15, 35 15, 40 10, 10 10))', 0);
Set @shape2 = geometry::STGeomFromText('POLYGON((10 10, 10 5, 35 5, 40 10, 10 10))', 0);

Select @shape1
Union all
Select @shape2;

--Dibujar dos formas y unirlas
Declare @shape1 geometry;
Declare @shape2 geometry;

Set @shape1 = geometry::STGeomFromText('POLYGON((10 10, 25 15, 35 15, 40 10, 10 10))', 0);
Set @shape2 = geometry::STGeomFromText('POLYGON((10 10, 10 5, 35 5, 40 10, 10 10))', 0);

Select @shape1.STUnion(@shape2);

-- multipoligono

DECLARE @g3 geometry = 'MULTIPOLYGON(((2 2, 2 -2, -2 -2, -2 2, 2 2)),((1 1, 3 1, 3 3, 1 3, 1 1)))';
select @g3


-- geografy

DECLARE @Paris geography = geography::Point(48.87, 2.33, 4326);
DECLARE @Berlin geography = geography::Point(52.52, 13.4, 4326);
SELECT @Paris.STDistance(@Berlin);




-- Ejercicios 

-- 1. Direcciones más cercanas
-- Dado un punto con coordenadas geográficas (latitud 47.6062, longitud -122.3321), 
-- encuentra las 10 direcciones más cercanas.

SELECT 
    AddressID,
    address_text,
    ST_Distance(
        geom, 
        ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)
    ) AS distance_meters
FROM addresses
ORDER BY 
    ST_Distance(
        geom, 
        ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)
    )
LIMIT 10
GO

-- Alternativa usando ST_DWithin para mejor performance en tablas grandes:
SELECT 
    AddressID,
    address_text,
    ST_Distance(
        geom, 
        ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)
    ) AS distance_meters
FROM addresses
WHERE ST_DWithin(
    geom, 
    ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326), 
    1000  -- Radio en metros para pre-filtrar
)
ORDER BY distance_meters
LIMIT 10;


-- 2. Direcciones dentro de un radio
-- Obtén todas las direcciones que se encuentran dentro de un radio de 50 kilómetros 
-- desde el mismo punto anterior.

SELECT 
    AddressID,
    address_text,
    ST_Distance(
        geom, 
        ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)
    ) AS distance_meters
FROM addresses
WHERE ST_DWithin(
    geom, 
    ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326), 
    50000  -- 50 kilómetros en metros
)
ORDER BY distance_meters;

-- Alternativa usando ST_Distance:
SELECT 
    AddressID,
    address_text,
    ST_Distance(
        geom, 
        ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)
    ) AS distance_meters
FROM addresses
WHERE ST_Distance(
    geom, 
    ST_SetSRID(ST_MakePoint(-122.3321, 47.6062), 4326)
) <= 50000
ORDER BY distance_meters;


-- 3. Direcciones con representación en WKT
-- Muestra la dirección y la representación espacial del campo SpatialLocation en formato WKT.

SELECT 
    AddressID,
    address_text,
    ST_AsText(SpatialLocation) AS wkt_representation
FROM addresses
ORDER BY AddressID;

-- Si necesitas también información adicional sobre la geometría:
SELECT 
    AddressID,
    address_text,
    ST_AsText(SpatialLocation) AS wkt_representation,
    ST_GeometryType(SpatialLocation) AS geometry_type,
    ST_SRID(SpatialLocation) AS srid
FROM addresses
ORDER BY AddressID;


-- 4. Distancia entre dos direcciones
-- Calcula la distancia en metros entre las direcciones con AddressID = 1 y AddressID = 2.

SELECT 
    ST_Distance(
        (SELECT SpatialLocation FROM addresses WHERE AddressID = 1),
        (SELECT SpatialLocation FROM addresses WHERE AddressID = 2)
    ) AS distance_meters;

-- Alternativa más descriptiva:
SELECT 
    a1.AddressID as address1_id,
    a1.address_text as address1_text,
    a2.AddressID as address2_id,
    a2.address_text as address2_text,
    ST_Distance(a1.SpatialLocation, a2.SpatialLocation) AS distance_meters
FROM addresses a1, addresses a2
WHERE a1.AddressID = 1 AND a2.AddressID = 2;


-- 5. Ruta y longitud total
-- Define una ruta geográfica entre las tres locaciones de id más bajo 
-- utilizando un LineString y calcula su longitud total en metros.

-- Primero, identificar las 3 locaciones con ID más bajo:
WITH lowest_locations AS (
    SELECT 
        AddressID,
        SpatialLocation,
        ROW_NUMBER() OVER (ORDER BY AddressID) as rn
    FROM addresses
    WHERE SpatialLocation IS NOT NULL
    ORDER BY AddressID
    LIMIT 3
),
route_points AS (
    SELECT 
        STRING_AGG(
            ST_X(SpatialLocation)::text || ' ' || ST_Y(SpatialLocation)::text, 
            ',' ORDER BY AddressID
        ) as points_string
    FROM lowest_locations
)
SELECT 
    'LINESTRING(' || points_string || ')' as route_wkt,
    ST_Length(
        ST_GeomFromText('LINESTRING(' || points_string || ')', 4326)
    ) as length_meters
FROM route_points;

-- Alternativa más robusta creando el LineString directamente:
WITH lowest_locations AS (
    SELECT 
        AddressID,
        SpatialLocation
    FROM addresses
    WHERE SpatialLocation IS NOT NULL
    ORDER BY AddressID
    LIMIT 3
)
SELECT 
    ST_AsText(
        ST_MakeLine(
            ARRAY(SELECT SpatialLocation FROM lowest_locations ORDER BY AddressID)
        )
    ) as route_wkt,
    ST_Length(
        ST_MakeLine(
            ARRAY(SELECT SpatialLocation FROM lowest_locations ORDER BY AddressID)
        )
    ) as length_meters;

-- Si trabajas con coordenadas proyectadas para mayor precisión:
WITH lowest_locations AS (
    SELECT 
        AddressID,
        ST_Transform(SpatialLocation, 3857) as geom_projected  -- Web Mercator
    FROM addresses
    WHERE SpatialLocation IS NOT NULL
    ORDER BY AddressID
    LIMIT 3
)
SELECT 
    ST_AsText(
        ST_Transform(
            ST_MakeLine(ARRAY(SELECT geom_projected FROM lowest_locations ORDER BY AddressID)),
            4326
        )
    ) as route_wkt_wgs84,
    ST_Length(
        ST_MakeLine(ARRAY(SELECT geom_projected FROM lowest_locations ORDER BY AddressID))
    ) as length_meters_accurate
FROM lowest_locations
LIMIT 1;