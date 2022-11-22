create table knjiga (
    broj number(5) constraint knjiga_pk primary key,
    pisac number(5) constraint pisak_fk references pisac(broj),
    naslov varchar2(30) not null,
    godina_publ number(4) not null,
    broj_strana number(4),
    cena_knjige number(5),
    tiraz number(5)
);

create table pisac (
    broj number(5) constraint pisac_pk primary key,
    ime varchar2(20) not null,
    prezime varchar2(20) not null,
    pol varchar2(1) constraint pol_ck check (pol in ('M', 'Z')),
    godina_rodjenja number(4)
);

create table poglavlje (
    broj number(5) constraint poglavlje_pk primary key,
    rod_pogl_broj number(5) constraint poglavlje_fk references poglavlje(broj),
    knjiga number(5) constraint knjiga_fk references knjiga(broj),
    broj_reci number(9),
    broj_slika number(5),
    broj_tabela number(5)
);

-- 2)
select knjiga.naslov, pisac.ime || ' ' || pisac.prezime as ime_pisca
from knjiga join pisac on knjiga.pisac = pisac.broj
where knjiga.tiraz > 10000 and knjiga.godina_publ > 2005.
order by knjiga.tiraz desc;

-- 3)
select pisac.ime, pisac.prezime, knjiga.naslov
from pisac join knjiga on pisac.broj = knjiga.pisac
where pol = 'M' and (select sum(broj_reci) from poglavlje where poglavlje.knjiga = knjiga.broj) < 1000000
order by knjiga.naslov desc;

-- 4)
select distinct pisac.ime, pisac.prezime
from pisac join knjiga on knjiga.pisac = pisac.broj
where pol = 'M' and exists (select 0 from poglavlje where poglavlje.knjiga = knjiga.broj and poglavlje.broj_tabela > 10)
intersect
select distinct pisac.ime, pisac.prezime
from pisac
where pol = 'M' and not exists (select 0 from knjiga join poglavlje
                                on knjiga.broj = poglavlje.knjiga
                                where pisac.broj = knjiga.pisac
                                group by knjiga.broj
                                having count(*) < 10);
                                
-- 5)
select knjiga.naslov
from knjiga join poglavlje on knjiga.broj = poglavlje.knjiga
where poglavlje.broj_reci = (select max(broj_reci)
                             from poglavlje
                             where poglavlje.rod_pogl_broj is not null);