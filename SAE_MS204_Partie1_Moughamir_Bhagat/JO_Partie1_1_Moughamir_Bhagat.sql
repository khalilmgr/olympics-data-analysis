-- maConnexionBD19 (moug0045) 

-- b) Création de la table PERSONNE
CREATE TABLE PERSONNE (
    numPers    NUMBER,
    nomPers    VARCHAR2(30),
    pnomPers   VARCHAR2(30),
    dateNais   DATE,
    pays       VARCHAR2(55),
    region     VARCHAR2(55),
    ville      VARCHAR2(50)
);



ALTER TABLE PERSONNE
ADD CONSTRAINT pk_personne PRIMARY KEY (numPers);



-- c) Table des pays
CREATE TABLE PAYS (
    cdAlpha2       CHAR(2),
    cdAlpha3       CHAR(3),
    codeNum        NUMBER,
    nomFr          VARCHAR2(60),
    nomAng         VARCHAR2(60),
    capitale       VARCHAR2(60),
    estIndep       VARCHAR2(3),
    continent      VARCHAR2(30),
    nationalite    VARCHAR2(60)
);


-- On ajoute la contrainte de clé primaire 
ALTER TABLE PAYS
ADD CONSTRAINT pk_pays PRIMARY KEY (cdPays);
DESC PAYS;



-- d) Relier les deux tables

-- 1
SELECT DISTINCT pays as "Pays"
FROM PERSONNE
WHERE pays NOT IN (SELECT nomAng
                   FROM PAYS)
ORDER BY pays;

-- 2. 
-- Suppression des espaces superflus à la fin du nom français
UPDATE PAYS
SET nomFr = SUBSTR(nomFr, 1, LENGTH(nomFr))
WHERE nomFr IS NOT NULL;

-- Suppression des espaces superflus à la fin du nom anglais
UPDATE PAYS
SET nomAng = SUBSTR(nomAng, 1, LENGTH(nomAng))
WHERE nomAng IS NOT NULL;

--3. Corrections dans PERSONNE pour harmoniser avec les noms anglais de PAYS

UPDATE PERSONNE
SET pays = 'Viet nam'
WHERE UPPER(SUBSTR(pays, 1, LENGTH(pays))) = 'VIETNAM';

UPDATE PERSONNE
SET pays = 'Korea (the Republic of)'
WHERE UPPER(SUBSTR(pays, 1, LENGTH(pays))) = 'SOUTH KOREA';

UPDATE PERSONNE
SET pays = 'United Kingdom of Great Britain and Northern Ireland'
WHERE UPPER(SUBSTR(pays, 1, LENGTH(pays))) = 'UNITED KINGDOM';

UPDATE PERSONNE
SET pays = 'United States of America'
WHERE UPPER(SUBSTR(pays, 1, LENGTH(pays))) = 'UNITED STATES';

--4 Ajout d’une colonne cdPays dans la table PERSONNE

ALTER TABLE PERSONNE ADD cdPays CHAR(3);

--5 Remplissage de cette colonne avec le code alpha-3 (cdPays) à partir du nom anglais

UPDATE PERSONNE p
SET cdPays = (
    SELECT py.cdPays 
    FROM PAYS py
    WHERE UPPER(SUBSTR(p.pays, 1, LENGTH(p.pays))) = UPPER(SUBSTR(py.nomAng, 1, LENGTH(py.nomAng)))
);

--6 Suppression de la colonne pays (devenue inutile)

ALTER TABLE PERSONNE DROP COLUMN pays;

--7 Ajout de la contrainte de clé étrangère entre PERSONNE et PAYS

ALTER TABLE PERSONNE
ADD CONSTRAINT fk_personne_pays FOREIGN KEY (cdPays)
REFERENCES PAYS(cdPays);


--8 Test de suppression d'un pays présent dans PERSONNE

DELETE FROM PAYS WHERE nomFr = 'France';
-- Cette suppression échouera car la clé étrangère empêche de supprimer une valeur encore référencée
-- Justification : Violation de l'intégrité référentielle, car des enregistrements de PERSONNE utilisent cdPays = 'FRA'
-- (ou autre code selon les données)



--e)  Requêtes sur les tables PERSONNE et PAYS

-- R1 : Nombre de pays différents représentés dans la table PERSONNE
SELECT COUNT(DISTINCT cdPays) AS "Nombre pays représentés"
FROM PERSONNE;

-- R2 : Nombre de personnes par région de France ou de Belgique
SELECT p.cdPays, region, COUNT(*) AS "Nombre personnes par région"
FROM PERSONNE p
JOIN PAYS pa ON p.cdPays = pa.cdPays
WHERE pa.nomFr IN ('France', 'Belgique')
GROUP BY p.cdPays, region
ORDER BY p.cdPays, region;

-- R3 : Nombre de personnes par pays, uniquement pour les pays recensant plus de 8 personnes
SELECT cdPays, COUNT(*) AS "Nombre personnes"
FROM PERSONNE
GROUP BY cdPays
HAVING COUNT(*) > 8;

-- R4 : Nom et prénom de la personne la plus âgée, tous pays confondus
SELECT nomPers as "Nom", pnomPers "Prénom"
FROM PERSONNE
WHERE dateNais = (
    SELECT MIN(dateNais) FROM PERSONNE
);

-- R5 : Pays avec le plus grand nombre de personnes
SELECT cdPays as "Pays"
FROM PERSONNE
GROUP BY cdPays
ORDER BY COUNT(*) DESC
FETCH FIRST 1 ROWS ONLY;

-- R6 : Pour chaque pays présent dans la table PERSONNE, nom, prénom et âge du doyen du pays
SELECT cdPays as "Pays", nomPers as "Nom", pnomPers as "Prénom", 
       FLOOR(MONTHS_BETWEEN(SYSDATE, dateNais)/12) AS age
FROM PERSONNE p1
WHERE dateNais = (
    SELECT MIN(dateNais)
    FROM PERSONNE p2
    WHERE p2.cdPays = p1.cdPays
)
ORDER BY cdPays, age DESC;

-- R7 : Nombre de personnes de chaque pays du continent OCEANIE
-- dont le nom français contient la lettre A et se termine par la lettre E

SELECT pa.nomFr, COUNT(pe.numPers) AS "Nombres Personnes"
FROM PAYS pa
LEFT JOIN PERSONNE pe ON pe.cdPays = pa.cdPays
WHERE UPPER(pa.continent) = 'OCÉANIE'
  AND UPPER(pa.nomFr) LIKE '%A%'
  AND UPPER(pa.nomFr) LIKE '%E'
GROUP BY pa.nomFr;
