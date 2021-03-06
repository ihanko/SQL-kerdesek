﻿/* Feladatsor 1. */

/* 01.	Mely rendelések nincsenek kiszállítva? */
SELECT
  r.Rendeléskód
FROM rendelések r
  WHERE r.SzállításDátuma IS NULL;

/* 02.	Listázzuk ki azoknak a vevőknek a neveit (cégnév),
  akik határidő után kaptak meg legalább egy rendelést! */
SELECT DISTINCT v.Cégnév
FROM rendelések r
  INNER JOIN vevők v
    ON r.Vevőkód = v.Vevőkód
WHERE r.SzállításDátuma > r.Határidő;


/* 03.	Listázza ki az 1000 Ft-nál olcsóbb italokat! */
SELECT
  t.Terméknév
FROM termékek t
  INNER JOIN kategóriák k
    ON t.Kategóriakód = k.Kategóriakód
WHERE k.Kategórianév = 'Italok'
AND t.Egységár < 1000;

/* 04.	Listázza ki a 1995-ös év rendeléseit! */
SELECT * FROM rendelések r
  WHERE YEAR(r.RendelésDátuma)=1995;

/* 05.	A Vevő (Cégnév) 3. vagy negyedik betűje „R”-betű. */
SELECT v.Cégnév FROM vevők v
  WHERE v.Cégnév LIKE '__R%' OR 
        v.Cégnév LIKE '___R%';


/* 06.	Határozzuk meg a kategóriánkénti kifutott termékek számát és
        átlagos egységárát!
        Az átlagos egységár legyen két tizedesjegyre kerekítve
        A darabszám mögött jelenjen meg a "db" mértékegység! */
SELECT
  k.Kategórianév,
  ROUND(AVG(t.Egységár),2) AS ÁtlagosEgységár,
  CONCAT(COUNT(*), ' db') AS Darabszám
FROM termékek t
  INNER JOIN kategóriák k
    ON t.Kategóriakód = k.Kategóriakód
WHERE t.Kifutott IS TRUE
GROUP BY k.Kategórianév;


/* 07.	Határozza meg országonként és városonként a vevők számát! 
        Csak azok a városok jelenjenek meg,
        ahol a vevők száma nagyobb, mint 1!
        A lista legyen vevők száma alapján csökkenő rendben! */
SELECT
  v.Ország,
  v.Város,
  COUNT(v.Vevőkód) AS VevőkSzáma
FROM vevők v
GROUP BY v.Ország,
         v.Város
  HAVING VevőkSzáma > 1
  ORDER BY VevőkSzáma DESC;

/* 08.	Listázza ki csökkenő sorrendben azt a 10 vevőt,
        akik a legtöbb pénzt hagyták a kasszában? */
SELECT
  v.Cégnév,
  FORMAT(SUM(rr.Egységár*rr.Mennyiség*(1-rr.Engedmény)), 0) AS Fizet
FROM rendelések r
  INNER JOIN vevők v
    ON r.Vevőkód = v.Vevőkód
  INNER JOIN rendelésrészletei rr
    ON rr.Rendeléskód = r.Rendeléskód
  GROUP BY v.Cégnév
  ORDER BY SUM(rr.Egységár*rr.Mennyiség*(1-rr.Engedmény)) DESC
  LIMIT 10;

/* 09.	Határozza meg a páros években az évenkénti rendelések számát! */
SELECT
  YEAR(r.RendelésDátuma) AS Év,
  COUNT(r.Rendeléskód)
FROM rendelések r
  WHERE YEAR(r.RendelésDátuma) MOD 2 = 0 /* itt nem használható az álnév (Év) */
  GROUP BY Év;

/* 10.	Határozza meg a páros években eladott (rendelés dátuma alapján)
        termékek számát! */
SELECT
  YEAR(r.RendelésDátuma) AS Év,
  SUM(rr.Mennyiség) AS db
FROM rendelésrészletei rr
  INNER JOIN rendelések r
    ON rr.Rendeléskód = r.Rendeléskód
  WHERE YEAR(r.RendelésDátuma) MOD 2 = 0
GROUP BY Év;


/* 11.	Üzletkötőnként határozza meg az össze engedmény értékét! */
SELECT
  a.Vezetéknév,
  a.Keresztnév,
  SUM(rr.Egységár*rr.Mennyiség*rr.Engedmény) AS Engedmény
FROM rendelések r
  INNER JOIN alkalmazottak a
    ON r.Alkalmazottkód = a.Alkalmazottkód
  INNER JOIN rendelésrészletei rr
    ON rr.Rendeléskód = r.Rendeléskód
WHERE a.Beosztás = 'Üzletkötő'
  GROUP BY a.Alkalmazottkód;


/* 12.	Az üzletkötők hányszor adtak engedményt? */
SELECT
  CONCAT(a.Vezetéknév,' ',a.Keresztnév) AS Név,
  COUNT(*) AS EngedményDb
FROM rendelések r
  INNER JOIN alkalmazottak a
    ON r.Alkalmazottkód = a.Alkalmazottkód
  INNER JOIN rendelésrészletei rr
    ON rr.Rendeléskód = r.Rendeléskód
WHERE a.Beosztás = 'Üzletkötő' AND rr.Engedmény != 0
  GROUP BY a.Alkalmazottkód;

/* 13.	 Tíznél több terméket tartalmazó kategóriákban
          hány termék szerepel? */
SELECT
  k.Kategórianév,
  COUNT(t.Kategóriakód) AS Darabszám
FROM termékek t
  INNER JOIN kategóriák k
    ON t.Kategóriakód = k.Kategóriakód
GROUP BY k.Kategórianév
  HAVING Darabszám > 10;


/* 14.	A Fizetés mezőben azon üzletkötők jövedelme,
        akiké meghaladja az "Igazgató" vagy "Alelnök" címmel 
        rendelkező minden alkalmazottét. */
SELECT
  a.Vezetéknév,
  a.Beosztás,
  a.Fizetés
FROM alkalmazottak a
WHERE a.Beosztás = 'üzletkötő'
AND a.Fizetés > ALL (SELECT
    a.Fizetés
  FROM alkalmazottak a
  WHERE a.Beosztás LIKE '%igazgató%'
  OR a.Beosztás LIKE '%alelnök%');

/* 15.	A Rendelésösszeg: [Egységár] * [Mennyiség] számított mezőben
        az átlagos rendelésértéknél nagyobb összegű rendelések. */
SELECT
  r.Rendeléskód,
  (rr.Mennyiség * rr.Egységár) AS Rendelésösszeg
FROM rendelésrészletei rr
  INNER JOIN rendelések r
    ON rr.Rendeléskód = r.Rendeléskód
  WHERE (rr.Mennyiség * rr.Egységár) > 
    (SELECT AVG(rr.Egységár*rr.Mennyiség) 
      FROM rendelésrészletei rr);

/* 16.	Azok a termékek,
        melyek egységára megegyezik a Lakkalikööri egységárával.
        A  Lakkalikööri ne jelenjen meg a listában! */

SELECT * FROM termékek t
  WHERE 
    t.Terméknév != 'Lakkalikööri' AND 
    t.Egységár = 
         (SELECT t.Egységár FROM termékek t
          WHERE t.Terméknév='Lakkalikööri');


/* 17.	Kik azok az üzletkötők, akik legalább egy igazgatónál vagy alelnököknél 
        idősebbek? */
SELECT
  a.Vezetéknév,
  a.Beosztás,
  a.SzületésiDátum
FROM alkalmazottak a
WHERE a.Beosztás = 'üzletkötő'
AND a.SzületésiDátum < ANY (SELECT
    a.SzületésiDátum
  FROM alkalmazottak a
  WHERE a.Beosztás LIKE '%igazgató%'
  OR a.Beosztás LIKE '%alelnök%');

/* Feladatsor 2. */

/* 01. Add meg a kifutott termékek nevét és szállítóját! */

/* 02. Töröld az Alkalmazottak táblából a Gyakornok Beosztású rekordokat. */

/* 03. Add meg a B és az M betűvel kezdődő városokból szállított termékek nevét és egységárát. */

/* 04. Add meg a raktáron lévő termékek átlagos egységárát. */

/* 05. Add meg a minimumkészlet alá csökkent nem kifutott termékek nevét és darabszámát terméknév szerinti sorrendben. */

/* 06. Add meg a 10 legnagyobb raktári összértékkel rendelkező termék nevét, beszállítóját, értékszerinti csökkenő sorrendben. */

/* 07.Add meg az 1995 első félévében született rendelések megrendelésszámát, megrendelőjét és az alkalmazott nevét, aki a megrendelést bonyolította. */

/* 08. Add meg annak a 3 alkalmazottnak a nevét, akik 1995-ben a legkevesebb rendeléseket bonyolította. */

/* 09. A következő példa minden olyan rekord Felettes mezőjét 5-re állítja, amelynek jelenleg 2 az értéke. */

/* 10. A következő példa minden olyan termék egységárát megnöveli 10 százalékkal, amely a 8. számú szállítótól származik, és amelyből van raktáron. */

/* 11. A következő példa minden olyan termék egységárát csökkenti 10 százalékkal, amely a Tokyo Traders nevű szállítótól származik, és amelyből van raktáron.  */

/* 12. Add meg a termékek kategóriánkénti átlagos egységárát! */

