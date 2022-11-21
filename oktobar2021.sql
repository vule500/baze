create table sportista (
    broj number(5) constraint sportista_pk primary key,
    ime varchar2(20) not null,
    prezime varchar2(20),
    brtel varchar2(10),
    god_rod number(4) not null,
    grad varchar2(20),
    plata number(6)
);

create table klub(
    broj number(5) constraint klub_pk primary key,
    naziv varchar2(20) unique,
    lokacija varchar2(20),
    god_osnivanja number(4) not null,
    sport varchar2(20) not null
);

create table clan (
    broj number(5) constraint clan_pk primary key,
    sportista number(5) constraint sportista_fk references sportista(broj),
    klub number(5) constraint klub_fk references klub(broj),
    datum_od date not null,
    datum_do date null,
    uloga varchar2(5) not null constraint uloga_ck check(uloga in ('škola', 'prvi', 'mladi'))
);

-- b)
select naziv || ' ' || lokacija as Naziv_i_Lokacija, god_osnivanja
from klub
where sport = 'odbojka' and god_osnivanja < year(sysdate) - 20
order by god_osnivanja desc;
-- c)
select sportista.ime, sportista.prezime, clan.uloga
from sportista join clan on sportista.broj = clan.sportista join klub on klub.broj = clan.klub
where year(sysdate) - sportista.god_rod < 30 and sportista.grad <> klub.lokacija;
-- d)
select klub.naziv, klub.sport
from klub join clan on klub.broj = clan.klub join sportista on clan.sportista = sportista.broj
where year(sysdate) - sportista.god_rod < 15
group by klub.naziv, klub.sport
having count(*) = (select max(count(*))
                    from klub join clan on klub.broj = clan.klub 
                            join sportista on clan.sportista = sportista.broj
                    where year(sysdate) - sportista.god_rod < 15);
-- e)
select klub.naziv, klub.lokacija
from klub
where klub.sport = 'vaterpolo' and 
(select count(*) 
    from sportista join clan on clan.sportista = sportista.broj
    where clan.uloga = 'mladi'
    group by klub.broj
    having sportista.plata > (select avg(plata)
                                  from sportista join clan on clan.sportista = sportista.broj
                                  where klub.broj = clan.klub and clan.uloga = 'prvi')) > 2
intersect
select klub.naziv, klub.lokacija
from klub join clan on klub.broj = clan.klub
where klub.sport = 'vaterpolo' and not exists (select 0 from sportista
                                                where sportista.broj = clan.sportista and sportista.plata > 20000
                                                        and sportista.mesto = 'Novi Sad');

 