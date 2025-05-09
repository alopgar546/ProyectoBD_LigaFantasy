-- https://github.com/alopgar546/ProyectoBD_LigaFantasy.git

use proyectoBD_ligaFantasy_alg;

-- 
-- Consulta 1
-- Los jugadores que hayan hecho mas puntos en cada jornada

select cj.num_jornada, j.nombre as jugador, cj.puntos  
from clasificacion_jug cj inner join jugadores j 
	on cj.id_jugadores = j.id_jugadores  
where cj.puntos = (select max(cj2.puntos)  
    from clasificacion_jug cj2  
    where cj2.num_jornada = cj.num_jornada  )  
order by cj.num_jornada;

-- 
-- Consulta 2
-- Los 5 jugadores que mas veces han sido traspasados

select j.nombre as jugador, count(tj.id_traspaso_jug) as cantidad_traspasos  
from traspaso_jug tj inner join jugadores j 
	on tj.id_jugadores= j.id_jugadores  
group by j.id_jugadores  
order by cantidad_traspasos desc  
limit 5;


-- 
-- Consulta 3
-- Todas las veces que cada usuario ha estado involucrado en una transaccion

select u.nombre as usuario, count(tj.id_traspaso_jug) as cantidad_transacciones  
from traspaso_jug tj inner join usuario u 
on tj.id_comprador = u.id_usuario or tj.id_vendedor= u.id_usuario  
group by u.id_usuario  
order by cantidad_transacciones desc;

-- 
-- Consulta 4
-- Todos los jugadores españoles que hayan estado involucrados en alguna transaccion y que jueguen en una plantilla con una formacion 4-3-3

select j.id_jugadores  as jugador, j.nacionalidad, j.equipo, tj.fecha_traspaso, tj.precio_traspaso, u.nombre as usuario
from traspaso_jug tj inner join jugadores j 
	on tj.id_jugadores= j.id_jugadores  
inner join usuario u 
	on j.id_propietario= u.id_usuario  
inner join plantilla p 
	on u.id_plantilla= p.id_plantilla  
where j.nacionalidad= 'Español' and p.formacion = '4-3-3';

-- 
-- Consulta 5
-- Todos los ugadores que han sido comprados por usuarios que han pagado 
-- una cantidad mayor al promedio de presupuesto de todos los usuarios

select j.nombre as jugador, u.nombre as comprador, tj.precio_traspaso  
from traspaso_jug tj inner join jugadores j 
	on tj.id_jugadores= j.id_jugadores  
inner join usuario u 
	on tj.id_comprador= u.id_usuario  
where tj.precio_traspaso > (  
    select avg(presupuesto)  
    from usuario);


-- Los entrenadores ordenados por sus victorias
select e.nombre as entrenador, count(*) as victorias  
from clasificacion_ent ce inner join entrenadores e 
	on ce.id_entrenadores = e.id_entrenadores  
where ce.puntos = 5  
group by e.id_entrenadores  
order by victorias desc; 






-- PRUEBA DE TRIGGER
INSERT INTO proyectoBD_ligaFantasy_alg.traspaso_jug (ID_COMPRADOR,ID_JUGADORES,ID_VENDEDOR,FECHA_TRASPASO,PRECIO_TRASPASO,ID_TRASPASO_JUG) VALUES
	 (101,10020,102,'2025-01-27 00:10:13',100000000,32);




-- PROCEDURES

-- VER TODOS LOS JUGADORES DE UN USUARIO
/* delimiter &&

create procedure obtener_jugadores_usuario(in id_usuario int)
begin
    select u.nombre as usuario, j.id_jugadores, j.nombre as jugadores, j.valor
    from jugadores j inner join usuario u
    	on u.id_usuario = j.id_propietario
    where j.id_propietario = id_usuario and id_usuario= u.id_usuario;
end &&

delimiter ;
*/

call obtener_jugadores_usuario(111);



-- VER LOS EQUIPOS MAS CAROS

/*delimiter &&

create procedure obtener_precio_equipos_usuario()
begin
    select u.id_usuario, u.nombre as usuario, sum(j.valor) as precio_total_equipo, count(j.id_jugadores) as numero_jugadores
    from usuario u left join jugadores j 
    	on u.id_usuario = j.id_propietario
    group by u.id_usuario, u.nombre
    order by precio_total_equipo desc;
end &&

delimiter ;
*/

call obtener_precio_equipos_usuario();



-- VER CLASIFICACION USUARIOS

/*delimiter &&

create procedure clasificacion_usuarios()
begin
    select u.id_usuario, u.nombre, obtener_puntos_usuario(u.id_usuario) as total_puntos
    from usuario u
    order by total_puntos desc;
end &&

delimiter ;
*/

call clasificacion_usuarios();

-- FUNCIONES

-- FUNCION VER PUNTOS DEL USUARIO

/*delimiter &&

create function obtener_puntos_usuario(id_usuario_param int) 
returns int 
deterministic
begin
    declare total_puntos int default 0;

    select ifnull(sum(cj.puntos), 0) + ifnull(sum(ce.puntos), 0) into total_puntos
    from usuario u left join jugadores j 
	    on u.id_usuario = j.id_propietario
    left join clasificacion_jug cj on j.id_jugadores = cj.id_jugadores
    left join entrenadores e on u.id_usuario = e.id_propietario
    left join clasificacion_ent ce on e.id_entrenadores = ce.id_entrenadores
    where u.id_usuario = id_usuario_param;

    return total_puntos;
end &&

delimiter ;
*/

select obtener_puntos_usuario(110);


-- VER CANTIDAD DE JUGADORES DE UN USUARIO

/*delimiter &&

create function obtener_total_jugadores(id_usuario int)
returns int
deterministic
begin
    declare total_jugadores int default 0;
    
    select count(*) 
    into total_jugadores
    from jugadores j
    where j.id_propietario = id_usuario;
    
    return total_jugadores;
end &&

delimiter ;
*/

select obtener_total_jugadores(111);

select j.nombre
from jugadores j 
where j.ID_PROPIETARIO = 111;



-- VISTAS
-- VER PUNTOS TOTALES DE LOS JUGADORES

/*create view vista_clasificacion_jugadores as
select j.id_jugadores, j.nombre as jugador, j.equipo, sum(c.puntos) as puntos_totales
from jugadores j join clasificacion_jug c 
	on j.id_jugadores = c.id_jugadores
group by j.id_jugadores, j.nombre, j.equipo
order by puntos_totales desc;
*/
select * from vista_clasificacion_jugadores;

-- VISTA PARA VER CANTIDAD GASTADA POR USUARIO

/*create view vista_resumen_traspasos_usuario as
select u.id_usuario, u.nombre as usuario, sum(t.precio_traspaso) as total_gastado
from traspaso_jug t inner join usuario u
	on t.id_comprador = u.id_usuario
group by u.id_usuario, u.nombre
order by total_gastado desc;
*/

select * from vista_resumen_traspasos_usuario;







