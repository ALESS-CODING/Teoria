create database Minimarket CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
use Minimarket;

select * from Usuario;
create table TipoUsuario(
codTipoUsu int primary key,
descTipoUsu varchar(10) not null
);
select * from Usuario;
create table Usuario(
codUsu int auto_increment primary key,
nombreUsu varchar(10) not null unique,
contrasenaUsu varchar(10) not null,
codTipoUsu int,
foreign key (codTipoUsu) references TipoUsuario(codTipoUsu)
)auto_increment=1001;

create table Cliente(
codCli int auto_increment primary key,
nombres varchar(80) not null,
apellidos varchar(80) not null,
direccion varchar(150) not null,
telef varchar(20) not null,
dni varchar(8) unique,
codUsu INT,
foreign key (codUsu) references Usuario(codUsu)
)auto_increment=2001;

create table Categoria(
idCat int primary key,
descCat varchar(25) not null
);

create table Marca(
codMarca int primary key,
nombreMarca varchar(20) not null unique
);

create table Producto(
codPro int auto_increment primary key,
nombrePro varchar(80) not null,
codMarca int,
descripcion varchar(250) not null,
precioPro double not null,
idCat int,
imgPro longblob,
foreign key (idCat) references Categoria(idCat),
foreign key (codMarca) references Marca(codMarca)
)auto_increment=7001;

create table EstadoPedido(
codEst int primary key,
descripEstado varchar(10)
);

create table HojaReparto(
codHoj int auto_increment primary key,
fechaReparto Date not null,
cantidadPed int not null
)auto_increment=6001;

create table Pedido(
codPed int auto_increment primary key,
codCli int,
codHoj int,
fechaPedido Date not null,
montoTotal double,
codEst int,
foreign key (codCli) references Cliente(codCli),
foreign key (codEst) references EstadoPedido(codEst),
foreign key (codHoj) references HojaReparto(codHoj)
)auto_increment=10001;

create table Carrito(
codCar int auto_increment primary key,
codPed int,
codPro int,
cantidad int not null,
montoCar double not null,
foreign key (codPro) references Producto(codPro),
foreign key (codPed) references Pedido(codPed)
);

create table Boleta(
codBol int auto_increment primary key,
fechaBoleta date not null,
codPed int,
IGVFinal double not null,
montoFinal double not null,
foreign key (codPed) references Pedido(codPed)
)auto_increment=9001;


/*---Procedimientos almacenados---*/
-- Logueo general:
DELIMITER $$
CREATE PROCEDURE LoginUsuario(
    IN p_nombreUsu VARCHAR(10),
    IN p_contrasenaUsu VARCHAR(10),
    OUT p_codUsu INT,
    OUT p_codCli INT,
    OUT p_nombres VARCHAR(80),
    OUT p_apellidos VARCHAR(80),
    OUT p_direccion VARCHAR(150),
    OUT p_telef VARCHAR(20),
    OUT p_dni VARCHAR(8),
    OUT p_nombreUsuRes VARCHAR(10),
    OUT p_contrasenaUsuRes VARCHAR(10),
    OUT p_codTipoUsu INT,
    OUT p_descTipoUsu VARCHAR(10)
)
BEGIN
    DECLARE v_codUsu INT;
    DECLARE v_codCli INT;
    DECLARE v_codTipoUsu INT;

    SELECT codUsu, codTipoUsu INTO v_codUsu, v_codTipoUsu
    FROM Usuario
    WHERE nombreUsu = p_nombreUsu AND contrasenaUsu = p_contrasenaUsu;

    IF v_codTipoUsu=1 THEN
        SELECT c.codCli, c.nombres, c.apellidos, c.direccion, c.telef, c.dni, u.nombreUsu, u.contrasenaUsu, u.codTipoUsu, t.descTipoUsu
        INTO p_codCli, p_nombres, p_apellidos, p_direccion, p_telef, p_dni, p_nombreUsuRes, p_contrasenaUsuRes, p_codTipoUsu, p_descTipoUsu
        FROM Cliente c
        JOIN Usuario u ON c.codUsu = u.codUsu
        JOIN TipoUsuario t ON u.codTipoUsu = t.codTipoUsu
        WHERE c.codUsu = v_codUsu;
		SET p_codUsu = v_codUsu;
    ELSE
        SELECT u.codUsu, NULL, NULL, NULL, NULL, NULL, u.nombreUsu, u.contrasenaUsu, u.codTipoUsu, t.descTipoUsu
        INTO p_codUsu, p_codCli, p_nombres, p_apellidos, p_direccion, p_telef, p_nombreUsuRes, p_contrasenaUsuRes, p_codTipoUsu, p_descTipoUsu
        FROM Usuario u JOIN TipoUsuario t ON u.codTipoUsu = t.codTipoUsu
        WHERE u.nombreUsu = p_nombreUsu AND u.contrasenaUsu = p_contrasenaUsu;
    END IF;
END $$ DELIMITER ;

-- Cambiar la contraseña de un usuario:
DELIMITER //
CREATE PROCEDURE CambiarContrasenaUsuario(
    IN p_codUsu INT,
    IN p_contrasenaNueva VARCHAR(10)
)
BEGIN
    UPDATE Usuario
    SET contrasenaUsu = p_contrasenaNueva
    WHERE codUsu = p_codUsu;
END //DELIMITER ;

-- Mostrar detalle del pedido (carrito):
DELIMITER $$
CREATE PROCEDURE MostrarDetallePedido(p_codPed INT)
BEGIN
    SELECT c.codPro, p.nombrePro, p.imgPro, c.cantidad,p.precioPro, c.montoCar, m.nombreMarca
    FROM Carrito c JOIN Producto p ON c.codPro=p.codPro
    JOIN Marca m ON p.codMarca=m.codMarca
    WHERE c.codPed = p_codPed;
END $$ DELIMITER ;


-- ---------------------------------------------- BUSQUEDAS ----------------------------------------------------------

-- Busqueda de productos por nombre:
DELIMITER $$
CREATE PROCEDURE BuscarProductosPorNombre(
    IN p_nombre VARCHAR(100)
)
BEGIN
    SELECT p.codPro,p.nombrePro,m.nombreMarca,p.descripcion,p.precioPro,p.imgPro,c.descCat
    FROM Producto p JOIN Marca m on p.codMarca=m.codMarca
    JOIN Categoria c on p.idCat=c.idCat
    WHERE p.nombrePro LIKE CONCAT('%', p_nombre, '%');
END $$ DELIMITER ;

-- Busqueda de productos por marca:
DELIMITER $$
CREATE PROCEDURE BuscarProductosPorMarca(
    IN p_marca VARCHAR(100)
)
BEGIN
    SELECT p.codPro,p.nombrePro,m.nombreMarca,p.descripcion,p.precioPro,p.imgPro,c.descCat
    FROM Producto p JOIN Marca m on p.codMarca=m.codMarca
    JOIN Categoria c on p.idCat=c.idCat
    WHERE m.nombreMarca LIKE CONCAT('%', p_marca, '%');
END $$ DELIMITER ;

-- Busqueda de productos por categoria:
DELIMITER $$
Create PROCEDURE BuscarProductoporCategoria(IN p_idCat INT, IN txt varchar (80) )
BEGIN
    SELECT codPro, nombrePro, descripcion, precioPro, imgPro
    FROM Producto
    WHERE idCat = p_idCat and nombrePro like CONCAT('%', txt, '%');
END $$ DELIMITER ;

-- Busqueda general de productos por codigo:
DELIMITER $$
create PROCEDURE BuscarProductos(IN p_codPro INT) 
BEGIN
    SELECT P.codPro, P.nombrePro, P.descripcion, P.precioPro, P.imgPro, M.nombreMarca
    FROM Producto P JOIN Marca M ON P.codMarca=M.codMarca
    WHERE codPro = p_codPro ;
END $$ DELIMITER ;

-- Busqueda de pedido por estado:
DELIMITER $$
create PROCEDURE BuscarPedidoEstado(IN p_descripEstado Varchar(10)) 
BEGIN
    SELECT p.codPed,p.codCli,c.nombres,c.apellidos,c.direccion,c.telef,p.fechaPedido,p.montoTotal,e.descripEstado
    FROM Pedido p JOIN EstadoPedido e ON p.codEst=e.codEst
    JOIN Cliente c ON p.codCli=c.codCli
    WHERE e.descripEstado like CONCAT('%', p_descripEstado, '%')
    ORDER BY p.codPed desc;
END $$ DELIMITER ;

-- Buscar usuario por teléfono
DELIMITER $$
CREATE PROCEDURE BuscarUsuarioXTelefono(U_nombreUsu Varchar (10), C_telef Varchar (20) )
BEGIN
    select C.codUsu, U.nombreUsu, C.telef
	from Usuario U inner join Cliente C on C.codUsu = U.codUsu
    WHERE U.nombreUsu = U_nombreUsu and C.telef = C_telef;
END $$ DELIMITER ;

-- ---------------------------------------------- CRUD CLIENTE ----------------------------------------------------------

-- Crear un nuevo cliente y su usuario asociado:
DELIMITER $$
CREATE PROCEDURE CrearCliente(
    IN p_nombres VARCHAR(80),
    IN p_apellidos VARCHAR(80),
    IN p_direccion VARCHAR(150),
    IN p_telef VARCHAR(20),
    IN p_dni VARCHAR(8),
    IN p_nombreUsu VARCHAR(10),
    IN p_contrasenaUsu VARCHAR(10)
)
BEGIN
    DECLARE nuevo_codUsu INT;
    INSERT INTO Usuario (nombreUsu, contrasenaUsu, codTipoUsu) VALUES (p_nombreUsu, p_contrasenaUsu, 1);
    SET nuevo_codUsu = LAST_INSERT_ID();
    INSERT INTO Cliente (nombres, apellidos, direccion, telef, dni, codUsu) VALUES (p_nombres, p_apellidos, p_direccion, p_telef, p_dni, nuevo_codUsu);
END $$ DELIMITER ;

-- Actualizar información de un cliente y su usuario:
DELIMITER $$
CREATE PROCEDURE ActualizarCliente(
    IN p_codCli INT,
    IN p_nombres VARCHAR(80),
    IN p_apellidos VARCHAR(80),
    IN p_direccion VARCHAR(150),
    IN p_telef VARCHAR(20),
    IN p_dni VARCHAR(8),
    IN p_nombreUsu VARCHAR(10),
    IN p_contrasenaUsu VARCHAR(10)
)
BEGIN
    DECLARE v_codUsu INT;

    SELECT codUsu INTO v_codUsu
    FROM Cliente
    WHERE codCli = p_codCli;

    UPDATE Cliente
    SET nombres = p_nombres, apellidos = p_apellidos, direccion = p_direccion, telef = p_telef, dni = p_dni
    WHERE codCli = p_codCli;

    UPDATE Usuario
    SET nombreUsu = p_nombreUsu, contrasenaUsu = p_contrasenaUsu
    WHERE codUsu = v_codUsu;
END $$ DELIMITER ;

-- Eliminar un usuario y cliente:
DELIMITER $$
CREATE PROCEDURE EliminarUsuarioYCliente(
    IN p_codUsu INT
)
BEGIN
    DELETE FROM Cliente WHERE codUsu = p_codUsu;
    DELETE FROM Usuario WHERE codUsu = p_codUsu;
END $$ DELIMITER ;

-- Obtener información detallada de un cliente y su usuario asociado:
DELIMITER $$
CREATE PROCEDURE ObtenerInformacionCliente(
    IN p_codCli INT,
    OUT p_nombres VARCHAR(80),
    OUT p_apellidos VARCHAR(80),
    OUT p_direccion VARCHAR(150),
    OUT p_telef VARCHAR(20),
    OUT p_dni VARCHAR(8),
    OUT p_codUsu INT,
    OUT p_nombreUsu VARCHAR(10),
    OUT p_contrasenaUsu VARCHAR(10)
)
BEGIN
    SELECT C.nombres, C.apellidos, C.direccion, C.telef, C.dni, U.codUsu, U.nombreUsu, U.contrasenaUsu, U.codTipoUsu
    INTO p_nombres, p_apellidos, p_direccion, p_telef, p_dni, p_codUsu, p_nombreUsu, p_contrasenaUsu
    FROM Cliente C
    INNER JOIN Usuario U ON C.codUsu = U.codUsu
    WHERE C.codCli = p_codCli;
END $$ DELIMITER ;

-- Listar todos los clientes y sus usuarios:
DELIMITER $$
CREATE PROCEDURE listardatosCliente(
)
BEGIN
    SELECT C.codCli, C.nombres, C.apellidos, C.direccion, C.telef, C.dni, U.codUsu, U.nombreUsu, U.contrasenaUsu, U.codTipoUsu
    FROM Cliente C
    INNER JOIN Usuario U ON C.codUsu = U.codUsu;
END $$ DELIMITER ;

-- ---------------------------------------------- CRUD PRODUCTO ----------------------------------------------------------
-- Agregar nuevo producto
DELIMITER $$
CREATE PROCEDURE InsertarProducto(
    IN p_nombrePro VARCHAR(80),
    IN p_codMarca INT,
    IN p_descripcion VARCHAR(250),
    IN p_precioPro DOUBLE,
    IN p_imgPro longblob,
    IN p_idCat INT
)
BEGIN
    INSERT INTO Producto(nombrePro, codMarca, descripcion, precioPro,imgPro,idCat)
    VALUES (p_nombrePro, p_codMarca, p_descripcion, p_precioPro, p_imgPro, p_idCat);
END $$
DELIMITER ;

-- Obtener producto
DELIMITER $$
CREATE PROCEDURE ObtenerProducto(
    IN p_codPro INT,
    OUT p_nombrePro VARCHAR(80),
    OUT p_codMarca INT,
    OUT p_descripcion VARCHAR(250),
    OUT p_precioPro DOUBLE,
    OUT p_imgPro longblob,
    OUT p_idCat INT
)
BEGIN
    SELECT nombrePro, codMarca, descripcion, precioPro, imgPro, idCat
    INTO p_nombrePro, p_codMarca, p_descripcion, p_precioPro, p_imgPro, p_idCat
    FROM Producto
    WHERE codPro = p_codPro;
END $$
DELIMITER ;

-- Actualizar producto
DELIMITER $$
CREATE PROCEDURE ActualizarProducto(
    IN p_codPro INT,
    IN p_nombrePro VARCHAR(80),
    IN p_codMarca INT,
    IN p_descripcion VARCHAR(250),
    IN p_precioPro DOUBLE,
    IN p_imgPro longblob,
    IN p_idCat INT
)
BEGIN
    UPDATE Producto
    SET nombrePro = p_nombrePro, codMarca = p_codMarca, descripcion = p_descripcion, precioPro = p_precioPro, imgPro=p_imgPro, idCat = p_idCat
    WHERE codPro = p_codPro;
END $$
DELIMITER ;

-- Eliminar producto
DELIMITER $$
CREATE PROCEDURE EliminarProducto(
    IN p_codPro INT
)
BEGIN
    DELETE FROM Producto
    WHERE codPro = p_codPro;
END $$
DELIMITER ;

-- Listar todos los productos(Mantenimiento):
DELIMITER $$
CREATE PROCEDURE ListarProductos()
	SELECT p.codPro,p.nombrePro,m.nombreMarca,p.descripcion,p.precioPro,p.imgPro,c.descCat
    FROM Producto p JOIN Marca m on p.codMarca=m.codMarca
    JOIN Categoria c on p.idCat=c.idCat
    order by p.codPro desc
$$ DELIMITER ;

-- Listar todos los productos(Principal):
DELIMITER $$
CREATE PROCEDURE ListarProductosGeneral()
	SELECT p.codPro,p.nombrePro,m.nombreMarca,p.descripcion,p.precioPro,p.imgPro,c.descCat
    FROM Producto p JOIN Marca m on p.codMarca=m.codMarca
    JOIN Categoria c on p.idCat=c.idCat
$$ DELIMITER ;

-- Obtener los productos de una categoría:
DELIMITER $$
CREATE PROCEDURE ObtenerProductosCategoria(IN p_idCat INT)
BEGIN
    SELECT p.codPro,p.nombrePro,m.nombreMarca,p.descripcion,p.precioPro,p.imgPro,c.descCat
    FROM Producto p JOIN Marca m on p.codMarca=m.codMarca
    JOIN Categoria c on p.idCat=c.idCat
    WHERE p.idCat = p_idCat;
END $$ DELIMITER ;

-- ---------------------------------------------- CRUD USUARIO ----------------------------------------------------------

-- Crear un nuevo usuario (solo crea vendedores):
DELIMITER $$
CREATE PROCEDURE CrearUsuarioVendedor(
    IN p_nombreUsu VARCHAR(10),
    IN p_contrasenaUsu VARCHAR(10)
)
BEGIN
    INSERT INTO Usuario (nombreUsu, contrasenaUsu, codTipoUsu) VALUES (p_nombreUsu, p_contrasenaUsu, 2);
END $$ DELIMITER ;

-- Eliminar usuario (solo de tipo vendedor):
DELIMITER $$
CREATE PROCEDURE EliminarUsuario(IN p_codUsu INT)
BEGIN
    DECLARE v_codTipoUsu INT;
    SELECT codTipoUsu INTO v_codTipoUsu
    FROM Usuario
    WHERE codUsu = p_codUsu;
    IF v_codTipoUsu = 2  THEN
        DELETE FROM Usuario
        WHERE codUsu = p_codUsu;
    END IF;
END $$ DELIMITER ;

-- Modificar usuario:
DELIMITER $$
CREATE PROCEDURE ModificarUsuario(IN p_codUsu INT, IN p_nombreUsu varchar(10), IN p_contrasenaUsu varchar(10))
BEGIN
	UPDATE Usuario
	SET nombreUsu=p_nombreUsu, contrasenaUsu=p_contrasenaUsu
	WHERE codUsu = p_codUsu;
END $$ DELIMITER ;

-- Listar usuarios:
DELIMITER $$
CREATE PROCEDURE ListarUsuarios()
BEGIN
    SELECT codUsu, nombreUsu, contrasenaUsu, descTipoUsu, u.codTipoUsu
    FROM Usuario u JOIN TipoUsuario tu ON u.codTipoUsu=tu.codTipoUsu
    ORDER BY u.codUsu;
END $$ DELIMITER ;

-- ---------------------------------------------- CRUD PEDIDO ----------------------------------------------------------

-- Generar Pedido(Devuelve el codigo del pedido creado como respuesta):
DELIMITER $$
CREATE PROCEDURE GenerarPedido(
    IN p_codCli INT,
    IN p_carrito JSON
)
BEGIN
    DECLARE v_codPed INT;
    DECLARE v_codHoj INT;
    DECLARE v_montoTotal DOUBLE;
    DECLARE v_cantPed INT;
    
    IF NOT EXISTS (SELECT 1 FROM HojaReparto WHERE fechaReparto = DATE_ADD(CURDATE(), INTERVAL 1 DAY)) THEN
        INSERT INTO HojaReparto (fechaReparto, cantidadPed)
        VALUES (DATE_ADD(CURDATE(), INTERVAL 1 DAY), 0);
    END IF;
    
    SELECT codHoj INTO v_codHoj FROM HojaReparto WHERE fechaReparto = DATE_ADD(CURDATE(), INTERVAL 1 DAY);
    
    INSERT INTO Pedido (codCli,codHoj,fechaPedido, montoTotal, codEst)
    VALUES (p_codCli,v_codHoj,CURDATE(), 0, 1);
    
    SET v_codPed = LAST_INSERT_ID();
    
    INSERT INTO Carrito (codPed, codPro, cantidad, montoCar)
    SELECT v_codPed, jt.codPro, jt.cantidad, jt.montoCar
    FROM JSON_TABLE(p_carrito, '$.carrito[*]' COLUMNS (
        codPro INT PATH '$.producto.codPro',
        cantidad INT PATH '$.cantidad',
        montoCar DOUBLE PATH '$.subTotal'
    )) AS jt;
    
    SELECT SUM(montoCar) INTO v_montoTotal FROM Carrito WHERE codPed = v_codPed;
    
    UPDATE Pedido SET montoTotal = v_montoTotal WHERE codPed = v_codPed;
        
    SELECT v_codPed AS codPed;
END $$ DELIMITER ;

-- Obtener los pedidos de un cliente:
DELIMITER $$
CREATE PROCEDURE ObtenerPedidosCliente(IN p_codCli INT)
BEGIN
    SELECT P.codPed, P.montoTotal, B.fechaBoleta
    FROM Pedido P
    LEFT JOIN Boleta B ON P.codPed = B.codPed
    WHERE P.codCli = p_codCli;
END $$ DELIMITER ;

-- Obtener la información detallada de un pedido, incluyendo los datos del cliente asociado:
DELIMITER $$
CREATE PROCEDURE ObtenerInformacionPedidoCli(IN p_codPed INT)
BEGIN
    SELECT P.codPed, P.montoTotal, P.codCli, C.nombres, C.apellidos, C.direccion, C.telef, C.dni
    FROM Pedido P
    INNER JOIN Cliente C ON P.codCli = C.codCli
    WHERE P.codPed = p_codPed;
END $$ DELIMITER ;

-- Actualizar el estado de un pedido:
DELIMITER $$
CREATE PROCEDURE ActualizarEstadoPedido(IN p_codPed INT, IN p_codEst INT)
BEGIN
    UPDATE Pedido
    SET codEst = p_codEst
    WHERE codPed = p_codPed;
END $$ DELIMITER ;

-- Listar pedidos:
DELIMITER $$
CREATE PROCEDURE ListarPedidos()
BEGIN
    SELECT p.codPed,p.codCli,c.nombres,c.apellidos,c.direccion,c.telef,p.fechaPedido,p.montoTotal,p.codEst,e.descripEstado
    FROM Pedido p JOIN EstadoPedido e ON p.codEst=e.codEst
    JOIN Cliente c ON p.codCli=c.codCli
    ORDER BY p.codPed DESC;
END $$ DELIMITER ;


-- -----------------------------------------BOLETA / HOJA DE REPARTO-------------------------------------------------

-- Generar una boleta de venta a partir de un pedido
DELIMITER $$
CREATE PROCEDURE GenerarBoleta(IN p_codPed INT)
BEGIN
    DECLARE total DOUBLE;
    DECLARE igv DOUBLE;
    IF NOT EXISTS (SELECT 1 FROM Boleta WHERE codPed = p_codPed) THEN
		SELECT montoTotal INTO total FROM Pedido WHERE codPed = p_codPed;
		SET igv = ROUND(total * 0.18, 2);
		INSERT INTO Boleta (fechaBoleta, codPed, IGVFinal, montoFinal) VALUES (CURDATE(), p_codPed, igv, total);
	END IF;
END $$ DELIMITER ;

-- Imprimir una boleta:
DELIMITER $$
CREATE PROCEDURE MostrarBoleta(
    IN p_codPed INT
)
BEGIN
    SELECT b.codBol,b.fechaBoleta,p.codPed,b.IGVFinal,b.montoFinal,c.nombres,c.apellidos,c.direccion,c.telef,
    c.dni,pro.nombrePro,m.nombreMarca,pro.precioPro,car.cantidad,car.montoCar
    FROM Pedido p join Boleta b ON p.codPed=b.codPed
    JOIN Cliente c ON p.codCli=c.codCli
    JOIN Carrito car ON p.codPed=car.codPed
    JOIN Producto Pro ON car.codPro=pro.codPro
    JOIN Marca m ON pro.codMarca=m.codMarca
    WHERE car.codPed = p_codPed;
END $$ DELIMITER ;

-- Obtener la hoja de reparto(solo pedidos con estado 'Reparto'):
DELIMITER $$
CREATE PROCEDURE ObtenerHojaReparto(IN p_codHoj INT)
BEGIN
    SELECT H.codHoj, P.codPed, B.codBol, H.fechaReparto, C.nombres, C.apellidos, C.direccion, C.telef, P.montoTotal,H.cantidadPed
    FROM Boleta B JOIN Pedido P ON B.codPed = P.codPed
    JOIN Cliente C ON P.codCli=C.codCli
    JOIN HojaReparto H ON P.codHoj = H.codHoj
    WHERE H.codHoj = p_codHoj and P.codEst=3
    ORDER BY P.codPed;
END $$ DELIMITER ;

-- Listar hojas de reparto:
DELIMITER $$
CREATE PROCEDURE ListarHojasReparto()
BEGIN
	UPDATE HojaReparto 
    SET cantidadPed = (
        SELECT COUNT(*)
        FROM Pedido p
        WHERE p.fechaPedido = CURDATE()
        AND p.codEst = 3
    ) WHERE fechaReparto = DATE_ADD(CURDATE(), INTERVAL 1 DAY) and codHoj!=0;
    SELECT *
    FROM HojaReparto
    ORDER BY codHoj desc;
END $$ DELIMITER ;

-- ---------------------------------------Inserts básicos de ejemplo para las tablas-----------------------------

INSERT INTO TipoUsuario VALUES (1,'Cliente');
INSERT INTO TipoUsuario VALUES (2,'Vendedor');
INSERT INTO TipoUsuario VALUES (3,'Admin');

INSERT INTO Usuario VALUES (1001,'Admin','123',3);
INSERT INTO Usuario VALUES (1002,'Vendedor1','123',2);
INSERT INTO Usuario VALUES (1003,'Vendedor2','123',2);
INSERT INTO Usuario VALUES (1004,'luarce','123',1);
INSERT INTO Usuario VALUES (1005,'fravero','123',1);
INSERT INTO Usuario VALUES (1006,'aller','123',1);
INSERT INTO Usuario VALUES (1007,'viedo','123',1);

INSERT INTO Cliente VALUES (2001,'Luis Miguel','Arce Salazar','Jr. Las Acacias 998',930920445,78493028,1004);
INSERT INTO Cliente VALUES (2002,'Francisco Sandro','Cavero Linares','Ca. Los Pinos 789',984550290,49021344,1005);
INSERT INTO Cliente VALUES (2003,'Alberto Franz','Weller Frentz','Av. La Peruanidad 1489',999888999,68349902,1006);
INSERT INTO Cliente VALUES (2004,'Viviana Sofia','Talledo Linares','Ca. Los Nogales 193',999999999,40129385,1007);

INSERT INTO Categoria VALUES (1,'Abarrotes');
INSERT INTO Categoria VALUES (2,'Frutas y verduras');
INSERT INTO Categoria VALUES (3,'Lácteos y carnes');
INSERT INTO Categoria VALUES (4,'Aseo y limpieza');
INSERT INTO Categoria VALUES (5,'Bebidas');
INSERT INTO Categoria VALUES (6,'Licores');
INSERT INTO Categoria VALUES (7,'Librería');

INSERT INTO EstadoPedido VALUES (1,'Creado');
INSERT INTO EstadoPedido VALUES (2,'Confirmado');
INSERT INTO EstadoPedido VALUES (3,'Reparto');
INSERT INTO EstadoPedido VALUES (4,'Entregado');
INSERT INTO EstadoPedido VALUES (5,'Cancelado');

INSERT INTO Marca VALUES (1,'Sin Marca');
INSERT INTO Marca VALUES (2,'Cocinero');
INSERT INTO Marca VALUES (3,'Costeño');
INSERT INTO Marca VALUES (4,'Florida');
INSERT INTO Marca VALUES (5,'3 ositos');
INSERT INTO Marca VALUES (6,'Cartavio');
INSERT INTO Marca VALUES (7,'Kirma');
INSERT INTO Marca VALUES (8,'Favorita');
INSERT INTO Marca VALUES (9,'Universal');
INSERT INTO Marca VALUES (10,'Nicolini');
INSERT INTO Marca VALUES (11,'Gloria');
INSERT INTO Marca VALUES (12,'Paracas');
INSERT INTO Marca VALUES (13,'Moncler');
INSERT INTO Marca VALUES (14,'Savital');
INSERT INTO Marca VALUES (15,'Doctor');
INSERT INTO Marca VALUES (16,'Colgate');
INSERT INTO Marca VALUES (17,'Sapolio');
INSERT INTO Marca VALUES (18,'Bolivar');
INSERT INTO Marca VALUES (19,'Clorox');
INSERT INTO Marca VALUES (20,'Cielo');
INSERT INTO Marca VALUES (21,'San Luis');
INSERT INTO Marca VALUES (22,'San Mateo');
INSERT INTO Marca VALUES (23,'Inka Kola');
INSERT INTO Marca VALUES (24,'Coca Cola');
INSERT INTO Marca VALUES (25,'Concordia');
INSERT INTO Marca VALUES (26,'Frugos Valle');
INSERT INTO Marca VALUES (27,'Tampico');
INSERT INTO Marca VALUES (28,'Volt');
INSERT INTO Marca VALUES (29,'Cusqueña');
INSERT INTO Marca VALUES (30,'Cristal');
INSERT INTO Marca VALUES (31,'Pilsen');
INSERT INTO Marca VALUES (32,'Tabernero');
INSERT INTO Marca VALUES (33,'Baileys');
INSERT INTO Marca VALUES (34,'Johnnie Walker');
INSERT INTO Marca VALUES (35,'Portón');
INSERT INTO Marca VALUES (36,'Piscano');
INSERT INTO Marca VALUES (37,'Class & Work');
INSERT INTO Marca VALUES (38,'Faber Castell');
INSERT INTO Marca VALUES (39,'Standford');
INSERT INTO Marca VALUES (40,'Artesco');
INSERT INTO Marca VALUES (41,'Pegafan');

-- Abarrotes:
insert into producto values(null,'Aceite', 2, 'Aceite vegetal en botella de 1L', 11.0,1,null);
insert into producto values(null,'Arroz', 3, 'Arroz extra graneado en bolsa de 750 g', 4.00,1,null);
insert into producto values(null,'Atún', 4, 'Filete de atún en lata de 170 g', 6.50,1,null);
insert into producto values(null,'Avena', 5, 'Avena clásica en bolsa de 120 g', 1.30,1,null);
insert into producto values(null,'Azúcar', 6, 'Azucar blanca en bolsa de 1 kg', 4.50,1,null);
insert into producto values(null,'Café', 7, 'Café instantaneo Doypack de 45 g', 7.60,1,null);
insert into producto values(null,'Harina', 8, 'Harina sin preparar en bolsa de 250 g', 1.10,1,null);
insert into producto values(null,'Gelatina', 9, 'Gelatina sabor a fresa en bolsa de 150 g', 3.50,1,null);
insert into producto values(null,'Fideo', 10, 'Fideo spaghetti en bolsa de 250 g', 2.10,1,null);

-- Frutas y verduras:
insert into producto values(null,'Mandarina', 1, 'Mandarina Satsuma sin pepa por 1 Kg', 2.50,2,null);
insert into producto values(null,'Manzana', 1, 'Manzana Israel por 1 Kg', 5.50,2,null);
insert into producto values(null,'Naranja', 1, 'Naranja para jugo por 1 Kg', 2.50,2,null);
insert into producto values(null,'Papaya', 1, 'Papaya entera por 2 Kg aprox.', 8.40,2,null);
insert into producto values(null,'Plátano', 1, 'Plátano de seda por 5 unidades', 2.60,2,null);
insert into producto values(null,'Cebolla', 1, 'Cebolla roja por 1 Kg', 3.30,2,null);
insert into producto values(null,'Limón', 1, 'Limón ácido por 1 Kg', 4.00,2,null);
insert into producto values(null,'Papa', 1, 'Papa blanca tipo yungay por 1 Kg', 2.20,2,null);
insert into producto values(null,'Tomate', 1, 'Tomate italiano por 1 Kg', 3.80,2,null);

-- Lácteos y carnes:
insert into producto values(null,'Leche evaporada', 11, 'Leche evaporada en lata de 400 g', 3.60,3,null);
insert into producto values(null,'Leche UHT', 11, 'Leche UHT en caja de 1 L', 4.80,3,null);
insert into producto values(null,'Mantequilla', 11, 'Mantequilla con sal en barra de 100 g', 4.40,3,null);
insert into producto values(null,'Queso Fresco', 1, 'Queso fresco en molde por porciones de 100 g', 2.70,3,null);
insert into producto values(null,'Huevo', 1, 'Huevo pardo a granel en malla de 1 Kg', 8.50,3,null);
insert into producto values(null,'Yogurt', 11, 'Yogurt semi-descremado en botella de 1 Kg', 6.10,3,null);
insert into producto values(null,'Pollo fresco', 1, 'Pollo entero con menudencia de 2 Kg aprox.', 8.50,3,null);
insert into producto values(null,'Milanesa de pollo', 1, 'Milanesa de pollo en paquete de 3 unidades', 6.00,3,null);
insert into producto values(null,'Carne molida', 1, 'Carne molida de res por porciones de 100 g', 2.60,3,null);

-- Aseo y limpieza:
insert into producto values(null,'Papel Higiénico', 12, 'Papel Higiénico doble hoja negro en paquete de 2 unidades ', 7.60,4,null);
insert into producto values(null,'Jabón', 13, 'Jabón corporal Nutri care en caja de 1 unidad', 4.00,4,null);
insert into producto values(null,'Shampoo', 14, 'Shampoo de palta y sábila en frasco de 530 ml', 9.90,4,null);
insert into producto values(null,'Pasta dental', 15, 'Pasta dental Ultra Fluor en tubo de 220 g', 6.90,4,null);
insert into producto values(null,'Pack cepillos', 16, 'Cepillos de cerda dura en pack de 2 unidades', 7.00,4,null);
insert into producto values(null,'Detergente', 17, 'Detergente aroma bebé en bolsa de 450 g', 5.30,4,null);
insert into producto values(null,'Jabón', 18, 'Jabón de ropa clásico en barra de 190 g', 3.20,4,null);
insert into producto values(null,'Lejía', 19, 'Lejía tradicional en frasco de 680 g', 1.90,4,null);
insert into producto values(null,'Limpiatodo', 17, 'Limpiatodo con esencia de lavanda en frasco de 900 ml', 3.50,4,null);

-- Bebidas:
insert into producto values(null,'Agua', 20, 'Agua sin gas en botella de 625 ml', 1.30,5,null);
insert into producto values(null,'Pack agua', 21, 'Agua sin gas en pack de bidones de 7 L c/u', 12.90,5,null);
insert into producto values(null,'Agua', 22, 'Agua sin gas en bidón de 7 L', 6.90,5,null);
insert into producto values(null,'Gaseosa', 23, 'Gaseosa tradicional amarilla en botella de 3 L', 9.90,5,null);
insert into producto values(null,'Gaseosa', 24, 'Gaseosa tradicional negra en botella de 3 L', 9.90,5,null);
insert into producto values(null,'Tripack gaseosa', 25, 'Pack de 3 gaseosas Concordia sabores varios de 3L c/u', 15.50,5,null);
insert into producto values(null,'Pack néctar', 26, 'Néctar de durazno en pack de 2 cajas de 1.5 L c/u', 8.00,5,null);
insert into producto values(null,'Jugo de naranja', 27, 'Jugo de naranja Citrus Punch en botella de 3 L', 8.50,5,null);
insert into producto values(null,'Bebida energizante', 28, 'Energizante sabor ginseng en botella de 300 ml', 2.20,5,null);

-- Licores:
insert into producto values(null,'Six pack cerveza', 29, 'Six pack de cerveza negra en botellas de 310 ml c/u', 24.90,6,null);
insert into producto values(null,'Six pack cerveza', 30, 'Six pack de cerveza rubia en botellas de 330 ml c/u', 23.90,6,null);
insert into producto values(null,'Six pack cerveza', 31, 'Six pack de cerveza rubia en botellas de 305 ml c/u', 19.90,6,null);
insert into producto values(null,'Vino', 32, 'Variedad Rose en botella de 750 ml', 17.90,6,null);
insert into producto values(null,'Licor de crema', 33, 'Variedad Irish Cream en botella de 750 ml', 69.90,6,null);
insert into producto values(null,'Whisky', 34, 'Variedad Black Label en botella de 750 ml', 108.00,6,null);
insert into producto values(null,'Ron', 6, 'Variedad Black en botella de 1 L', 28.90,6,null);
insert into producto values(null,'Pisco', 35, 'Variedad Mosto Verde en botella de 750 ml', 82.90,6,null);
insert into producto values(null,'Pack chilcano', 36, 'Sabor maracuya en pack de 4 botellas de 275 ml c/u', 22.90,6,null);

-- Librería:
insert into producto values(null,'Papel bond', 37, 'Papel bond A-4 en paquete de 500 hojas', 14.90,7,null);
insert into producto values(null,'Colores', 38, 'Caja de colores variados de 15 unidades', 8.20,7,null);
insert into producto values(null,'Lapiceros', 38, 'Caja de lapiceros de colores variados en paquete de 5 unidades', 5.30,7,null);
insert into producto values(null,'Cuaderno', 39, 'Cuaderno cuadriculado Deluxe de 92 hojas', 6.20,7,null);
insert into producto values(null,'Lápices de grafito', 40, 'Caja de lápices de grafito 2B en paquete de 12 unidades', 5.30,7,null);
insert into producto values(null,'Set de témperas', 40, 'Caja de témperas de colores variados de 7 unidades', 8.70,7,null);
insert into producto values(null,'Cinta de embalaje', 41, 'Cinta de embalaje transparente de 2 pulgadas', 5.10,7,null);
insert into producto values(null,'Perforador', 40, 'Perforador escolar M-01 azul en caja de 1 unidad', 7.30,7,null);
insert into producto values(null,'Pack escolar', 40, 'Pack escolar Artesco con 3 lapiceros de colores, marcador y corrector', 7.00,7,null);

-- Redondear todos los productos a *.5 o *.0
DELIMITER //
CREATE PROCEDURE ActualizarPrecios()
BEGIN
    DECLARE done INT DEFAULT FALSE;
    DECLARE id INT;
    DECLARE precio DOUBLE;

    DECLARE cur CURSOR FOR SELECT codPro, precioPro FROM Producto;
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

    OPEN cur;

    read_loop: LOOP
        FETCH cur INTO id, precio;
        IF done THEN
            LEAVE read_loop;
        END IF;

        SET precio = ROUND(precio * 2) / 2;

        UPDATE Producto SET precioPro = precio WHERE codPro = id;
    END LOOP;

    CLOSE cur;
END // DELIMITER ;

CALL ActualizarPrecios;
