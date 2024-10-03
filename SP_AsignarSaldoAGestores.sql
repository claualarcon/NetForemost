use master
go
--Creo una Base de datos
create database Netforemost;
go

use Netforemost;
go

--Creo el procedimiento almacenado AsignarSaldosaGestores

CREATE PROCEDURE AsignarSaldosAGestores
AS
BEGIN
	--Creamos las tablas temporales gestores y Saldos y variables a utilizar
	DECLARE @Gestores TABLE (GestorID INT, Nombre VARCHAR(15));
	DECLARE @Saldos TABLE(Saldo DECIMAL(10,2), GestorID INT NULL);
	DECLARE @TotalSaldos INT;
	DECLARE @TotalIteraciones INT;
	DECLARE @GestorID INT = 1;
	DECLARE @TotalGestores INT = 10;
	DECLARE @IteracionActual INT = 1;

	--Agregamos datos a la tabla temporal gestor
	INSERT INTO @Gestores (GestorID, Nombre)
	SELECT ROW_NUMBER() OVER(ORDER BY(SELECT NULL)) AS GestorID, 'Gestor ' + CAST(ROW_NUMBER() OVER(ORDER BY (SELECT NULL)) AS VARCHAR(15)) AS Nombre
	FROM (VALUES(1),(2),(3),(4),(5),(6),(7),(8),(9),(10)) AS Gestores(Numero);

	----Agregamos datos a la tabla temporal saldos.

	INSERT INTO @Saldos (Saldo)
	Values (2277), (3953), (4726), (1414), (627), (1784), (1634), (3958), (2156), (1347),
    (2166), (820), (2325), (3613), (2389), (4130), (2007), (3027), (2591), (3940),
    (3888), (2975), (4470), (2291), (3393), (3588), (3286), (2293), (4353), (3315),
    (4900), (794), (4424), (4505), (2643), (2217), (4193), (2893), (4120), (3352),
    (2355), (3219), (3064), (4893), (272), (1299), (4725), (1900), (4927), (4011);

	--Ordenamos los saldos de manera Descendiente 
	DECLARE SaldoCursor CURSOR FOR
	SELECT Saldo From @Saldos ORDER BY Saldo DESC;

	--Cuenta total de saldos
	SELECT @TotalSaldos = COUNT(*) FROM @Saldos;

	--Calculo el numero de iteraciones necesarias redondeando hacia arriba
	SET @TotalIteraciones = CEILING(@TotalSaldos / @TotalGestores);

	DECLARE @Saldo DECIMAL(10,2);

	--Abro cursor
	OPEN SaldoCursor;
	FETCH NEXT FROM SaldoCursor INTO @Saldo;

	--Inicia el proceso de asignacion de saldos
	WHILE @@FETCH_STATUS = 0
			BEGIN

				--Asignamos el saldo al gestor actual
				UPDATE @Saldos
				SET GestorID = @GestorID
				WHERE Saldo = @Saldo;

				--Cambiamos al siguiente gestor, o reiniciamos si ya llegamos al ultimo
				SET @GestorID = @GestorID +1;

				--Si llegamos al numero maximo de gestores, reiniciamos el ciclo de asignacion
				IF @GestorID > @TotalGestores 
				BEGIN
					SET @GestorID = 1;
					SET @IteracionActual =@IteracionActual +1;

					--SI ya completamos todas las iteraciones necesarias, salimos del buble
					IF @IteracionActual > @TotalIteraciones
							BREAK;
				END;
	
				FETCH NEXT FROM SaldoCursor INTO @Saldo;
			END;
	CLOSE SaldoCursor;
	DEALLOCATE SaldoCursor;

	--Devolvemos los saldos asignados
	SELECT s.Saldo, g.Nombre AS Gestor
	FROM @Saldos s 
	JOIN @Gestores g ON s.GestorID = g.GestorID;
END;

--EXEC AsignarSaldosAGestores;

