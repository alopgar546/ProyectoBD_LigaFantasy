use proyectofinalbd_alg;


-- TRIGGERS

-- TRIGGER PARA ACTUALIZAR EL ID_PROPIETARIO DE JUGADOR

delimiter &&

create trigger actualizar_propietario_jugador
after insert on traspaso_jug
for each row
begin
    -- cambiar el propietario del jugador
    update jugadores
    set id_propietario = new.id_comprador
    where id_jugadores = new.id_jugadores;
end &&

delimiter ;

-- TRIGGER PARA ACTUALIZAR EL ID_PROPIETARIO DE ENTRENADOR

delimiter &&

create trigger actualizar_propietario_entrenador
after insert on traspaso_ent
for each row
begin
    -- cambiar el propietario del jugador
    update entrenadores
    set id_propietario = new.id_comprador
    where id_entrenadores = new.id_entrenadores;
end &&

delimiter ;


--  TRIGGER PARA ACTUALIZAR EL PRESUPUESTO EN TRASPASO_JUG
delimiter &&

create trigger validar_y_actualizar_presupuesto_traspaso_jug
before insert on traspaso_jug
for each row
begin
    declare presupuesto_actual int;

    -- verificar el presupuesto del comprador
    select presupuesto into presupuesto_actual
    from usuario
    where id_usuario = new.id_comprador;

    if presupuesto_actual < new.precio_traspaso then
        
    

    -- restar el precio del comprador
    update usuario
    set presupuesto = presupuesto - new.precio_traspaso
    where id_usuario = new.id_comprador;

    -- sumar el precio al vendedor
    update usuario
    set presupuesto = presupuesto + new.precio_traspaso
    where id_usuario = new.id_vendedor;
   
	end if;
end &&

delimiter ;


--  TRIGGER PARA ACTUALIZAR EL PRESUPUESTO EN TRASPASO_ENT
delimiter &&

create trigger validar_y_actualizar_presupuesto_traspaso_ent
before insert on traspaso_ent
for each row
begin
    declare presupuesto_actual int;

    -- verificar el presupuesto del comprador
    select presupuesto into presupuesto_actual
    from usuario
    where id_usuario = new.id_comprador;

    if presupuesto_actual < new.precio_traspaso then
   

    -- restar el precio del comprador
    update usuario
    set presupuesto = presupuesto - new.precio_traspaso
    where id_usuario = new.id_comprador;

    -- sumar el precio al vendedor
    update usuario
    set presupuesto = presupuesto + new.precio_traspaso
    where id_usuario = new.id_vendedor;
   
    end if;
end &&

delimiter ;





-- PROCEDIMIENTOS
-- 
-- 
-- VER TODOS LOS JUGADORES DE UN USUARIO
delimiter &&

create procedure obtener_jugadores_usuario(in id_usuario int)
begin
    select u.nombre as usuario, j.id_jugadores, j.nombre as jugadores, j.valor
    from jugadores j inner join usuario u
    	on u.id_usuario = j.id_propietario
    where j.id_propietario = id_usuario and id_usuario= u.id_usuario;
end &&

delimiter ;

call obtener_jugadores_usuario(111);


-- VER LOS EQUIPOS MAS CAROS

delimiter &&

create procedure obtener_precio_equipos_usuario()
begin
    select u.id_usuario, u.nombre as usuario, sum(j.valor) as precio_total_equipo, count(j.id_jugadores) as numero_jugadores
    from usuario u left join jugadores j 
    	on u.id_usuario = j.id_propietario
    group by u.id_usuario, u.nombre
    order by precio_total_equipo desc;
end &&

delimiter ;

call obtener_precio_equipos_usuario();


-- VER CLASIFICACION USUARIOS

delimiter &&

create procedure clasificacion_usuarios()
begin
    select u.id_usuario, u.nombre, obtener_puntos_usuario(u.id_usuario) as total_puntos
    from usuario u
    order by total_puntos desc;
end &&

delimiter ;

call clasificacion_usuarios();


-- FUNCIONES
-- 
--   
-- FUNCION VER PUNTOS DEL USUARIO

delimiter &&

create function obtener_puntos_usuario(id_usuario_param int) 
returns int 
deterministic
begin
    declare total_puntos int default 0;

    select ifnull(sum(cj.puntos), 0) + ifnull(sum(ce.puntos), 0) into total_puntos
    from usuario u
    left join jugadores j on u.id_usuario = j.id_propietario
    left join clasificacion_jug cj on j.id_jugadores = cj.id_jugadores
    left join entrenadores e on u.id_usuario = e.id_propietario
    left join clasificacion_ent ce on e.id_entrenadores = ce.id_entrenadores
    where u.id_usuario = id_usuario_param;

    return total_puntos;
end &&

delimiter ;

select obtener_puntos_usuario(110);


-- VER CANTIDAD DE JUGADORES DE UN USUARIO

delimiter &&

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

select obtener_total_jugadores(111);

-- 
-- 
-- 
-- VISTAS


-- VER PUNTOS TOTALES DE LOS JUGADORES

create view vista_clasificacion_jugadores as
select j.id_jugadores, j.nombre as jugador, j.equipo, sum(c.puntos) as puntos_totales
from jugadores j
join clasificacion_jug c on j.id_jugadores = c.id_jugadores
group by j.id_jugadores, j.nombre, j.equipo
order by puntos_totales desc;


-- VISTA PARA VER CANTIDAD GASTADA POR USUARIO

create view vista_resumen_traspasos_usuario as
select u.id_usuario, u.nombre as usuario, sum(t.precio_traspaso) as total_gastado
from traspaso_jug t inner join usuario u on t.id_comprador = u.id_usuario
group by u.id_usuario, u.nombre
order by total_gastado desc;









