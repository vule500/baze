create table kompanija (
    ide number(5) constraint kompanija_pk primary key,
    naziv varchar2(30) unique,
    ulica varchar2(20) not null,
    broj number(3) not null,
    grad varchar2(20) not null,
    postanski_broj number(6) not null,
    drzava varchar2(20),
    pib number(20)
);

create table faktura (
    ide number(5) constraint faktura_pk primary key,
    dat_placanja date not null,
    dat_kreiranja date not null,
    valuta varchar2(3) constraint valuta_ck check (valuta in ('eur', 'rsd')),
    iznos number(10),
    porez number(10),
    komp_salje number(5) constraint kompanija_fk references kompanija(ide),
    komp_prima number(5) constraint kompanija2_fk references kompanija(ide)
    
);

create table stavka (
    ide number(5) constraint stavka_pk primary key,
    naziv varchar2(30) not null,
    kolicina number(6),
    iznos number(10),
    popust number(3) constraint popust_ck check(popust between 0 and 100),
    porez number(10),
    fakt_ide number(5) constraint faktura_fk references faktura(ide)
);

-- b)
select faktura.komp_salje, faktura.komp_prima, faktura.dat_placanja
from faktura join stavka on stavka.fakt_ide = faktura.ide
where faktura.dat_kreiranja > sysdate - 30
group by faktura.ide, faktura.komp_salje, faktura.komp_prima, faktura.dat_placanja
having count(*) > 3
order bt faktura.dat_placanja asc;

-- c)
select faktura.komp_naziv, faktura.kompa_prima
from faktura join stavka on stavka.fakt_ide = faktura.ide
where iznos + porez > 50000 and not exists (select 0 from stavka 
                                            where stavka.fakt_ide = faktura.ide
                                                 and stavka.popust > 10)
group by faktura.ide, faktura.komp_salje, faktura.komp_prima
having count(*) >= 2;

-- d)
select kompanija.naziv
from kompanija join faktura on kompanija.ide = faktura.komp_prima
where faktura.dat_placanja < sysdate - 7
group by kompanija.naziv
having count(*) = (select max(count(*)) from kompanija join faktura 
                                        on kompanija.ide = faktura.komp_prima
                                        group by kompanija.naziv);




