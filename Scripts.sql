USE TestCrud
GO

-- Crear tabla alquileres
create table tAlquileres (
	id int IDENTITY(1,1) not null,
	pelicula int not null,
	dias_alquilados int not null,
	fecha datetime not null,
	comprador int not null,
	precio int not null,
	devuelta bit not null,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

-- Crear tabla alquileres
create table tCompras (
	id int IDENTITY(1,1) not null,
	pelicula int not null,
	fecha datetime not null,
	comprador int not null,
	precio int not null,
PRIMARY KEY CLUSTERED 
(
	[id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY]

GO

-- Crear stored procedure para insertar usuarios
create procedure InsertarUsuario
    @username nvarchar(50),   
    @password nvarchar(50),   
	@name nvarchar(200),   
    @lastname nvarchar(200),   
    @document nvarchar(50),
	@rol int
as
if exists (select * from tUsers where nro_doc = @document)
    begin
        print ('ERROR: Ya existe un usuario con ese documento')
		return 0
    end
else
    begin
		insert into tUsers values (@username, @password, @name, @lastname, @document, @rol, 1)
		print ('Usuario creado con exito')
		return 1
	end
go  

-- Crear stored procedure para Crear/Borrar/Modificar peliculas
create procedure ABMPeliculas
    @cod_pelicula int,   
    @descripcion nvarchar(500),   
	@cant_alquiler int,   
    @cant_venta int,   
    @precio_alquiler numeric(18,2),
	@precio_venta numeric(18,2),
	@Accion varchar(20)
as
if @Accion = 'Borrar'
    begin
        update tPelicula set cant_disponibles_alquiler = 0, cant_disponibles_venta = 0 where cod_pelicula = @cod_pelicula
		return 1
    end
else if @Accion = 'Modificar'
    begin
		update tPelicula set 
			txt_desc = @descripcion, 
			cant_disponibles_alquiler = @cant_alquiler, 
			cant_disponibles_venta = @cant_venta,  
			precio_alquiler = @precio_alquiler,
			precio_venta = @precio_venta
		where cod_pelicula = @cod_pelicula
		return 1
	end
else if @Accion = 'Crear'
    begin
		insert into tPelicula values (
			@descripcion, 
			@cant_alquiler, 
			@cant_venta,  
			@precio_alquiler,
			@precio_venta)
		return 1
	end
return 0
go  


-- Crear stored procedure para insertar generos
create procedure InsertarGenero 
    @descripcion nvarchar(50)
as
if exists (select * from tGenero where txt_desc = @descripcion)
    begin
        print ('ERROR: Ya existe un genero con esa descripcion')
		return 0
    end
else
    begin
		insert into tGenero values (@descripcion)
		print ('Genero creado con exito')
		return 1
	end
go  

-- Crear stored procedure para asignar genero a pelicula
create procedure AsignarGenero
    @pelicula int,
	@genero int
as
if (select cod_genero from tGeneroPelicula where cod_pelicula = @pelicula) is not null
    begin
        print ('ERROR: La pelicula indicada ya tiene asignado un genero')
		return 0
    end
else
    begin
		update tGeneroPelicula set cod_genero = @genero where cod_pelicula = @pelicula
		print ('Genero asignado con exito')
		return 1
	end
go  

-- Crear stored procedure para alquilar peliculas
create procedure AlquilarPelicula
	@pelicula int,
	@dias_alquilados int,
	@comprador int,
	@precio int
as
declare @cant_disp int;
set @cant_disp = (select cant_disponibles_alquiler from tPelicula where cod_pelicula = @pelicula)
if @cant_disp < 1
    begin
        print ('ERROR: La pelicula indicada ya no tiene stock disponible para alquilar')
		return 0
    end
else
    begin
		insert into tAlquileres values (@pelicula, @dias_alquilados, GETDATE(), @comprador, @precio, 0)
		update tPelicula set cant_disponibles_alquiler = (@cant_disp -1) where cod_pelicula = @pelicula
		print ('Pelicual alquilada con exito')
		return 1
	end
go  

-- Crear stored procedure para comprar peliculas
create procedure ComprarPelicula
	@pelicula int,
	@dias_alquilados int,
	@comprador int,
	@precio int
as
declare @cant_disp int;
set @cant_disp = (select cant_disponibles_venta from tPelicula where cod_pelicula = @pelicula)
if @cant_disp < 1
    begin
        print ('ERROR: La pelicula indicada ya no tiene stock disponible para comprar')
		return 0
    end
else
    begin
		insert into tCompras values (@pelicula, GETDATE(), @comprador, @precio)
		update tPelicula set cant_disponibles_venta = (@cant_disp -1) where cod_pelicula = @pelicula
		print ('Pelicual comprada con exito')
		return 1
	end
go  

-- Crear stored procedure para obtener peliculas en stock para alquilar
create procedure ObtenerPeliculasAlquilar
as
	select * from tPelicula where cant_disponibles_alquiler > 0
go  

-- Crear stored procedure para obtener peliculas en stock para comprar
create procedure ObtenerPeliculasComprar
as
	select * from tPelicula where cant_disponibles_venta > 0
go  

-- Los puntos 8 y 9 son iguales al punto 5

-- Crear stored procedure para devolver pelicula alquilada
create procedure DevolverPelicula
	@pelicula int
as
	update tAlquileres set devuelta = 1 where pelicula = @pelicula
go  

-- Crear stored procedure para ver peliculas no devueltas y que usuarios las tienen
create procedure VerPeliculasNoDevueltas
as
	select p.txt_desc, u.txt_nombre, u.txt_apellido, u.nro_doc from tPelicula p
	right join tAlquileres a on a.pelicula = p.cod_pelicula
	left join tUsers u on a.comprador = u.cod_usuario
	where a.devuelta = 0
go  

-- Crear stored procedure para ver peliculas alquiladas, que usuarios las alquilaron y que dia
create procedure VerAlquileres
as
	select p.txt_desc, u.txt_nombre, u.txt_apellido, u.nro_doc, a.fecha from tAlquileres a
	left join tUsers u on a.comprador = u.cod_usuario
	left join tPelicula p on a.pelicula = p.cod_pelicula
go  

-- Crear stored procedure para ver todas las peliculas, cuantos alquileres y dinero recaudado
create procedure VerPeliculasResumen
as
	select p.cod_pelicula, p.txt_desc, count(a.id) as Cantidad_alquileres, (sum(a.precio) + sum(c.precio)) as Dinero_recaudado from tPelicula p
	inner join tAlquileres a on a.pelicula = p.cod_pelicula
	inner join tCompras c on c.pelicula = p.cod_pelicula
	group by p.cod_pelicula, p.txt_desc
go  