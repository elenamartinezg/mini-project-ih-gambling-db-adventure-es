USE GAMBLING_DB;
USE GAMBLING_DB.GAMBLING_SCHEMA;

-- ## Preguntas

-- - **Pregunta 01**: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre Título, Nombre y Apellido y Fecha de Nacimiento para cada uno de los clientes. No necesitarás hacer nada en Excel para esta.
SELECT TITLE, FIRSTNAME, LASTNAME, DATEOFBIRTH
FROM CUSTOMER;

-- - **Pregunta 02**: Usando la tabla o pestaña de clientes, por favor escribe una consulta SQL que muestre el número de clientes en cada grupo de clientes (Bronce, Plata y Oro). Puedo ver visualmente que hay 4 Bronce, 3 Plata y 3 Oro pero si hubiera un millón de clientes ¿cómo lo haría en Excel?

-- En Excel sería con el CONTAR.SI

SELECT CUSTOMERGROUP, COUNT(*)
FROM CUSTOMER
GROUP BY CUSTOMERGROUP;

-- - **Pregunta 03**: El gerente de CRM me ha pedido que proporcione una lista completa de todos los datos para esos clientes en la tabla de clientes pero necesito añadir el código de moneda de cada jugador para que pueda enviar la oferta correcta en la moneda correcta. Nota que el código de moneda no existe en la tabla de clientes sino en la tabla de cuentas. Por favor, escribe el SQL que facilitaría esto. ¿Cómo lo haría en Excel si tuviera un conjunto de datos mucho más grande?

SELECT c.*, a.CURRENCYCODE 
FROM CUSTOMER c
JOIN ACCOUNT a ON c.CUSTID = a.CUSTID;

-- - **Pregunta 04**: Ahora necesito proporcionar a un gerente de producto un informe resumen que muestre, por producto y por día, cuánto dinero se ha apostado en un producto particular. TEN EN CUENTA que las transacciones están almacenadas en la tabla de apuestas y hay un código de producto en esa tabla que se requiere buscar (classid & categoryid) para determinar a qué familia de productos pertenece esto. Por favor, escribe el SQL que proporcionaría el informe. Si imaginas que esto fue un conjunto de datos mucho más grande en Excel, ¿cómo proporcionarías este informe en Excel?

SELECT 
    b.BETDATE,
    p.CLASSID, 
    p.CATEGORYID, 
    SUM(b.BET_AMT) AS TOTAL_BET_AMOUNT
FROM BETTING b
JOIN PRODUCT p ON b.CLASSID = p.CLASSID AND b.CATEGORYID = p.CATEGORYID
GROUP BY P.CLASSID, p.CATEGORYID, b.BETDATE
ORDER BY b.BETDATE;


-- - **Pregunta 05**: Acabas de proporcionar el informe de la pregunta 4 al gerente de producto, ahora él me ha enviado un correo electrónico y quiere que se cambie. ¿Puedes por favor modificar el informe resumen para que solo resuma las transacciones que ocurrieron el 1 de noviembre o después y solo quiere ver transacciones de Sportsbook. Nuevamente, por favor escribe el SQL abajo que hará esto. Si yo estuviera entregando esto vía Excel, ¿cómo lo haría?

SELECT 
    b.BETDATE, 
    p.CLASSID,
    p.CATEGORYID, 
    p.PRODUCT, 
    SUM(b.BET_AMT) AS TOTAL_BET_AMOUNT
FROM BETTING b
JOIN PRODUCT p ON b.CLASSID = p.CLASSID AND b.CATEGORYID = p.CATEGORYID
WHERE b.BETDATE >= '2012-11-01' AND p.PRODUCT = 'Sportsbook'
GROUP BY p.CLASSID, p.PRODUCT, p.CATEGORYID, b.BETDATE
ORDER BY b.BETDATE;

-- - **Pregunta 06**: Como suele suceder, el gerente de producto ha mostrado su nuevo informe a su director y ahora él también quiere una versión diferente de este informe. Esta vez, quiere todos los productos pero divididos por el código de moneda y el grupo de clientes del cliente, en lugar de por día y producto. También le gustaría solo transacciones que ocurrieron después del 1 de diciembre. Por favor, escribe el código SQL que hará esto.

SELECT 
    a.CURRENCYCODE,
    c.CUSTOMERGROUP,
    p.CLASSID,
    p.CATEGORYID,
    SUM(B.BET_AMT) AS TOTAL_BET_AMOUNT, 
FROM CUSTOMER c
JOIN ACCOUNT a ON c.CUSTID = a.CUSTID
JOIN BETTING b ON a.ACCOUNTNO = b.ACCOUNTNO
JOIN PRODUCT p ON b.CLASSID = p.CLASSID AND b.CATEGORYID = p.CATEGORYID
WHERE b.BETDATE > '2012-12-01'
GROUP BY a.CURRENCYCODE, c.CUSTOMERGROUP, p.CLASSID, p.CATEGORYID
ORDER BY a.CURRENCYCODE, c.CUSTOMERGROUP;

-- - **Pregunta 07**: Nuestro equipo VIP ha pedido ver un informe de todos los jugadores independientemente de si han hecho algo en el marco de tiempo completo o no. En nuestro ejemplo, es posible que no todos los jugadores hayan estado activos. Por favor, escribe una consulta SQL que muestre a todos los jugadores Título, Nombre y Apellido y un resumen de su cantidad de apuesta para el período completo de noviembre.

SELECT 
    c.TITLE,
    c.FIRSTNAME,
    c.LASTNAME,
    SUM(b.BET_AMT) AS TOTAL_BET_AMOUNT
FROM CUSTOMER c
LEFT JOIN 
    ACCOUNT a ON c.CUSTID = a.CUSTID
LEFT JOIN 
    BETTING b ON a.ACCOUNTNO = b.ACCOUNTNO 
    AND b.BETDATE BETWEEN '2012-11-01' AND '2012-11-30'
GROUP BY c.TITLE, c.FIRSTNAME, c.LASTNAME
ORDER BY c.LASTNAME, c.FIRSTNAME;

-- - **Pregunta 08**: Nuestros equipos de marketing y CRM quieren medir el número de jugadores que juegan más de un producto. ¿Puedes por favor escribir 2 consultas, una que muestre el número de productos por jugador y otra que muestre jugadores que juegan tanto en Sportsbook como en Vegas?


SELECT 
    c.CUSTID,
    c.FIRSTNAME,
    c.LASTNAME,
    COUNT(DISTINCT p.PRODUCT) AS NUMBER_OF_PRODUCTS
FROM CUSTOMER c
JOIN ACCOUNT a ON c.CUSTID = a.CUSTID
JOIN BETTING b ON a.ACCOUNTNO = b.ACCOUNTNO
JOIN PRODUCT p ON b.CLASSID = p.CLASSID AND b.CATEGORYID = p.CATEGORYID
GROUP BY c.CUSTID, c.FIRSTNAME, c.LASTNAME
ORDER BY NUMBER_OF_PRODUCTS DESC;


SELECT 
    c.CUSTID,
    c.FIRSTNAME,
    c.LASTNAME,
    COUNT(DISTINCT p.PRODUCT) AS NUMBER_OF_PRODUCTS
FROM CUSTOMER c
JOIN ACCOUNT a ON c.CUSTID = a.CUSTID
JOIN BETTING b ON a.ACCOUNTNO = b.ACCOUNTNO
JOIN PRODUCT p ON b.CLASSID = p.CLASSID AND b.CATEGORYID = p.CATEGORYID
WHERE p.PRODUCT = 'Sportsbook' OR p.PRODUCT = 'Vegas'
GROUP BY c.CUSTID, c.FIRSTNAME, c.LASTNAME
HAVING COUNT(DISTINCT p.PRODUCT) = 2;


-- - **Pregunta 09**: Ahora nuestro equipo de CRM quiere ver a los jugadores que solo juegan un producto, por favor escribe código SQL que muestre a los jugadores que solo juegan en sportsbook, usa bet_amt > 0 como la clave. Muestra cada jugador y la suma de sus apuestas para ambos productos.

SELECT 
    c.CUSTID,
    c.FIRSTNAME,
    c.LASTNAME,
    COUNT(DISTINCT p.PRODUCT) AS NUMBER_OF_PRODUCTS,
    SUM(b.BETCOUNT) AS TOTAL_BETCOUNT
FROM CUSTOMER c
JOIN ACCOUNT a ON c.CUSTID = a.CUSTID
JOIN BETTING b ON a.ACCOUNTNO = b.ACCOUNTNO
JOIN PRODUCT p ON b.CLASSID = p.CLASSID AND b.CATEGORYID = p.CATEGORYID
WHERE p.PRODUCT = 'Sportsbook' AND b.BET_AMT > 0
GROUP BY c.CUSTID, c.FIRSTNAME, c.LASTNAME;

-- - **Pregunta 10**: La última pregunta requiere que calculemos y determinemos el producto favorito de un jugador. Esto se puede determinar por la mayor cantidad de dinero apostado. Por favor, escribe una consulta que muestre el producto favorito de cada jugador

WITH TotalApuestas AS (
    SELECT
        a.CUSTID,
        b.CLASSID,
        b.CATEGORYID,
        SUM(b.BET_AMT) AS TOTAL_BET
    FROM BETTING b
    JOIN ACCOUNT a ON b.ACCOUNTNO = a.ACCOUNTNO
    GROUP BY a.CUSTID, b.CLASSID, b.CATEGORYID
),
MaxApuestas AS (
    SELECT
        CUSTID,
        MAX(TOTAL_BET) AS MAX_BET
    FROM TotalApuestas
    GROUP BY CUSTID
)
SELECT
    c.CUSTID,
    c.FIRSTNAME,
    c.LASTNAME,
    ta.CLASSID,
    ta.CATEGORYID,
    ta.TOTAL_BET AS TOTAL_BET,
    p.PRODUCT,
    p.SUB_PRODUCT,
    p.DESCRIPTION
FROM TotalApuestas ta
JOIN MaxApuestas ma ON ta.CUSTID = ma.CUSTID AND ta.TOTAL_BET = ma.MAX_BET
JOIN PRODUCT p ON ta.CLASSID = p.CLASSID AND ta.CATEGORYID = p.CATEGORYID
JOIN CUSTOMER c ON ta.CUSTID = c.CUSTID
ORDER BY c.CUSTID;
    
-- Mirando los datos abstractos en la pestaña "Student_School" en la hoja de cálculo de Excel, por favor responde las siguientes preguntas:

-- - **Pregunta 11**: Escribe una consulta que devuelva a los 5 mejores estudiantes basándose en el GPA

SELECT *
FROM STUDENT
ORDER BY GPA DESC
LIMIT 5;

-- - **Pregunta 12**: Escribe una consulta que devuelva el número de estudiantes en cada escuela. (¡una escuela debería estar en la salida incluso si no tiene estudiantes!)

SELECT 
    sc.SCHOOL_ID,
    sc.SCHOOL_NAME,
    COUNT(st.STUDENT_ID) AS STUDENT_COUNT
FROM SCHOOL sc
LEFT JOIN STUDENT st ON sc.SCHOOL_ID = st.SCHOOL_ID
GROUP BY sc.SCHOOL_ID, sc.SCHOOL_NAME
ORDER BY sc.SCHOOL_ID;


-- - **Pregunta 13**: Escribe una consulta que devuelva los nombres de los 3 estudiantes con el GPA más alto de cada universidad.

SELECT x.STUDENT_NAME, s.SCHOOL_NAME, x.SCHOOL_ID, x.GPA
FROM (
    SELECT STUDENT_NAME, SCHOOL_ID, GPA,
           ROW_NUMBER() OVER (PARTITION BY SCHOOL_ID ORDER BY GPA DESC) AS rn
    FROM STUDENT
) AS x -- best students by school
JOIN SCHOOL AS s ON x.SCHOOL_ID = s.SCHOOL_ID
WHERE x.rn <= 3;
