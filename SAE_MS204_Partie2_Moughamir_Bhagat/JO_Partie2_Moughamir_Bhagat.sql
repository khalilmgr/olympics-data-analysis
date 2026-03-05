-- 1. Chargement de la base JO_2024




-- a) Insertion dans les tables TYPESITE, PANIER, DEPARTEMENT 


INSERT INTO TYPESITE VALUES (1, 'Centre aquatique');
INSERT INTO TYPESITE VALUES (2, 'Espace urbain emblématique');
INSERT INTO TYPESITE VALUES (3, 'Salle intérieure');
INSERT INTO TYPESITE VALUES (4, 'Site naturel/plein air');
INSERT INTO TYPESITE VALUES (5, 'Stade');
INSERT INTO TYPESITE VALUES (6, 'Vélodrome');



INSERT INTO PANIER VALUES (1, 'Préliminaires/Séries');
INSERT INTO PANIER VALUES (2, 'Qualifications');
INSERT INTO PANIER VALUES (3, 'Demi-finales');
INSERT INTO PANIER VALUES (4, 'Finales');
INSERT INTO PANIER VALUES (5, 'Eliminatoires');
INSERT INTO PANIER VALUES (6, 'Repêchage');
INSERT INTO PANIER VALUES (7, 'Match pour le bronze');
INSERT INTO PANIER VALUES (8, 'Entraînements');
INSERT INTO PANIER VALUES (9, 'Match de classement');
INSERT INTO PANIER VALUES (10, 'Inclassables');



INSERT INTO DEPARTEMENT VALUES ('06', 'Alpes-Maritimes');
INSERT INTO DEPARTEMENT VALUES ('13', 'Bouches-du-Rhône');
INSERT INTO DEPARTEMENT VALUES ('33', 'Gironde');
INSERT INTO DEPARTEMENT VALUES ('36', 'Indre');
INSERT INTO DEPARTEMENT VALUES ('42', 'Loire');
INSERT INTO DEPARTEMENT VALUES ('44', 'Loire-Atlantique');
INSERT INTO DEPARTEMENT VALUES ('59', 'Nord');
INSERT INTO DEPARTEMENT VALUES ('69', 'Rhône');
INSERT INTO DEPARTEMENT VALUES ('75', 'Paris');
INSERT INTO DEPARTEMENT VALUES ('77', 'Seine-et-Marne');
INSERT INTO DEPARTEMENT VALUES ('78', 'Yvelines');
INSERT INTO DEPARTEMENT VALUES ('92', 'Hauts-de-Seine');
INSERT INTO DEPARTEMENT VALUES ('93', 'Seine-Saint-Denis');
INSERT INTO DEPARTEMENT VALUES ('987', 'Nouvelle-Calédonie');

-- b) Importation des données dans SITE via interface SQL Developer (import CSV)

-- c) DISCIPLINE + ATHLETE

INSERT INTO DISCIPLINE (CDDISCIP, LIBDISCIPFR, LIBDISCIPAN)
SELECT CDDISCIP, LIBDISCIPFR, LIBDISCIPAN
FROM JO2024.DISCIPLINE_IMPORT
WHERE CDDISCIP IS NOT NULL
  AND LIBDISCIPFR IS NOT NULL
  AND LIBDISCIPAN IS NOT NULL;
  

ALTER TABLE ATHLETE
ADD CONSTRAINT fk_discipline FOREIGN KEY (cdDiscip)
REFERENCES DISCIPLINE(cdDiscip);

UPDATE ATHLETE a
SET cdDiscip = (
    SELECT joa.DISCIPLINE
    FROM JO2024.ATHLETE_IMPORT joa
    WHERE joa.NUMERO = a.NUMATH
)
WHERE EXISTS (
    SELECT 1
    FROM JO2024.ATHLETE_IMPORT joa
    WHERE joa.NUMERO = a.NUMATH
);



-- d) EPREUVE

INSERT INTO EPREUVE (
    CDSITE, NUMEPR, CDPANIER, CDDISCIP,
    NOMEPR, PHASE, GENREEPR, TYPEEPR,
    DATEDEB, DATEFIN, TARIF, TARIFR
)
SELECT
    CDSITE, NUMEPR, CDPANIER, CDDISCIP,
    NOMEPR, PHASE, GENREEPR, TYPEEPR,
    DATEDEB, DATEFIN, TARIF, TARIFR
FROM JO2024.EPREUVE_IMPORT;


-- d) PARTICIPATIONJO

INSERT INTO PARTICIPATIONJO (NUMATH, CDSITE, NUMEPR)
SELECT DISTINCT p.NUMATH, p.CDSITE, p.NUMEPR
FROM JO2024.PARTICIPATION_IMPORT p
WHERE p.NUMATH IN (SELECT NUMATH FROM ATHLETE)
AND NOT EXISTS (
    SELECT 1 FROM PARTICIPATIONJO pj
    WHERE pj.NUMATH = p.NUMATH
      AND pj.CDSITE = p.CDSITE
      AND pj.NUMEPR = p.NUMEPR
);


-- e) Table ACCUEIL

-- Création de la table ACCUEIL avec deux colonnes :
-- - cdDiscip : référence à une discipline (clé étrangère)
-- - cdSite   : référence à un site (clé étrangère)
-- Les deux colonnes composent également la clé primaire.
CREATE TABLE ACCUEIL (
    cdDiscip CHAR(4) NOT NULL,
    cdSite CHAR(3) NOT NULL,
    CONSTRAINT pk_accueil PRIMARY KEY (cdDiscip, cdSite)
);

-- Suppression des lignes de la table ACCUEIL dont le code discipline
-- ne correspond à aucune ligne dans la table DISCIPLINE
-- (pour éviter une erreur lors de l'ajout de la contrainte FK)
DELETE FROM ACCUEIL
WHERE cdDiscip NOT IN (
    SELECT cdDiscip FROM DISCIPLINE
);


-- Ajout de la contrainte de clé étrangère sur cdDiscip
-- qui doit exister dans la table DISCIPLINE
ALTER TABLE ACCUEIL ADD CONSTRAINT fk_accueil_discipline
FOREIGN KEY (cdDiscip) REFERENCES DISCIPLINE(cdDiscip);

--f) Table ACHAT

-- Insertion de la personne 201 (Khalil Moughamir)
INSERT INTO PERSONNE (
    NUMPERS, NOMPERS, PNOMPERS, DATENAIS, VILLE, REGION, CDPAYS
) VALUES (
    201, 'Moughamir', 'Khalil', TO_DATE('2001-04-12', 'YYYY-MM-DD'), 'Paris', 'Île-de-France', 'FRA'
);

-- Achats à toutes les épreuves prévues au Trocadéro
INSERT INTO ACHAT VALUES (201, 'TRO', 1, SYSDATE - 30, 2, 1, 'CB');
INSERT INTO ACHAT VALUES (201, 'TRO', 2, SYSDATE - 60, 1, 0, 'ESP');
INSERT INTO ACHAT VALUES (201, 'TRO', 3, SYSDATE - 90, 3, 0, 'CHQ');
INSERT INTO ACHAT VALUES (201, 'TRO', 4, SYSDATE - 100, 1, 2, 'CB');
INSERT INTO ACHAT VALUES (201, 'TRO', 5, SYSDATE - 200, 2, 0, 'ESP');

-- + Une épreuve hors de Paris
INSERT INTO ACHAT VALUES (201, 'AQC', 1, SYSDATE - 10, 1, 1, 'CB');


-- Insertion des personnes 202 à 206 pour les achats dans les Aréna

INSERT INTO PERSONNE VALUES (202, 'Ziani', 'Lina', TO_DATE('2000-01-15','YYYY-MM-DD'), 'Lyon', 'Auvergne-Rhône-Alpes', 'FRA');
INSERT INTO PERSONNE VALUES (203, 'Benali', 'Amine', TO_DATE('1999-04-20','YYYY-MM-DD'), 'Marseille', 'Provence-Alpes-Côte d’Azur', 'FRA');
INSERT INTO PERSONNE VALUES (204, 'Rahmani', 'Sofia', TO_DATE('1998-09-03','YYYY-MM-DD'), 'Toulouse', 'Occitanie', 'FRA');
INSERT INTO PERSONNE VALUES (205, 'Ndiaye', 'Malick', TO_DATE('2001-11-12','YYYY-MM-DD'), 'Lille', 'Hauts-de-France', 'FRA');
INSERT INTO PERSONNE VALUES (206, 'Djebbar', 'Sara', TO_DATE('2002-06-30','YYYY-MM-DD'), 'Strasbourg', 'Grand Est', 'FRA');


-- Personne 202
INSERT INTO ACHAT VALUES (202, 'CDM', 319, SYSDATE - 15, 2, 0, 'CB');  -- Finale @ Arena Champ de Mars
INSERT INTO ACHAT VALUES (202, 'CPL', 29,  SYSDATE - 20, 1, 1, 'CHQ'); -- Prélim/Séries @ Arena Porte de la Chapelle

-- Personne 203
INSERT INTO ACHAT VALUES (203, 'CDM', 718, SYSDATE - 30, 1, 0, 'ESP'); -- Finale @ Arena Champ de Mars
INSERT INTO ACHAT VALUES (203, 'CPL', 32,  SYSDATE - 35, 2, 0, 'CB');  -- Prélim/Séries @ Arena Porte de la Chapelle

-- Personne 204
INSERT INTO ACHAT VALUES (204, 'BCY', 39,  SYSDATE - 60, 3, 1, 'CHQ'); -- Finale @ Arena Bercy
INSERT INTO ACHAT VALUES (204, 'CPL', 35,  SYSDATE - 65, 1, 0, 'ESP'); -- Prélim/Séries @ Arena Porte de la Chapelle

-- Personne 205
INSERT INTO ACHAT VALUES (205, 'BCY', 40,  SYSDATE - 90, 2, 0, 'CB');  -- Finale @ Arena Bercy
INSERT INTO ACHAT VALUES (205, 'CPL', 221, SYSDATE - 95, 1, 2, 'CHQ'); -- Prélim/Séries @ Arena Porte de la Chapelle

-- Personne 206
INSERT INTO ACHAT VALUES (206, 'CDM', 622, SYSDATE - 120,1, 1, 'ESP'); -- Finale @ Arena Champ de Mars
INSERT INTO ACHAT VALUES (206, 'CPL', 224, SYSDATE - 125,2, 0, 'CB');  -- Prélim/Séries @ Arena Porte de la Chapelle



-- Insertion des personnes 207 à 210
INSERT INTO PERSONNE VALUES (207, 'Martin', 'Lucas', TO_DATE('2000-03-10','YYYY-MM-DD'), 'Paris', 'Île-de-France', 'FRA');
INSERT INTO PERSONNE VALUES (208, 'Tran', 'Nina', TO_DATE('1997-07-22','YYYY-MM-DD'), 'Nanterre', 'Île-de-France', 'FRA');
INSERT INTO PERSONNE VALUES (209, 'Gonzalez', 'Leo', TO_DATE('1996-12-01','YYYY-MM-DD'), 'Marseille', 'Provence-Alpes-Côte d’Azur', 'FRA');
INSERT INTO PERSONNE VALUES (210, 'Durand', 'Claire', TO_DATE('2002-05-25','YYYY-MM-DD'), 'Nice', 'Provence-Alpes-Côte d’Azur', 'FRA');

-- Achats à Paris (EIF)
INSERT INTO ACHAT VALUES (207, 'EIF', 1, SYSDATE - 20, 1, 0, 'CB');
INSERT INTO ACHAT VALUES (208, 'EIF', 2, SYSDATE - 5, 2, 1, 'ESP');

-- Achats hors Paris (MAM)
INSERT INTO ACHAT VALUES (209, 'MAM', 1, SYSDATE - 45, 1, 2, 'CHQ');
INSERT INTO ACHAT VALUES (210, 'MAM', 3, SYSDATE - 15, 2, 0, 'CB');









--2. Extractions de la base

--a) Figures imposées

-- Requête 1 : version avec JOINTURES
-- Liste des personnes ayant acheté au moins un billet pour une épreuve hors Paris
-- Nb lignes obtenues : 3


SELECT DISTINCT
    p.nomPers || '-' || p.pnomPers AS "Nom complet",
    UPPER(pa.nomFR) AS "Pays"
FROM achat a
JOIN site s ON a.cdSite = s.cdSite
JOIN personne p ON a.numPers = p.numPers
JOIN pays pa ON p.cdPays = pa.cdPays
WHERE s.cdDpt <> '75';


-- version avec une SOUS-REQUÊTE
-- Même liste, en filtrant d'abord les personnes concernées

SELECT
    p.nomPers || '-' || p.pnomPers AS "Nom complet",
    UPPER(pa.nomFR) AS "Pays"
FROM personne p
JOIN pays pa ON p.cdPays = pa.cdPays
WHERE p.numPers IN (
    SELECT DISTINCT a.numPers
    FROM achat a
    JOIN site s ON a.cdSite = s.cdSite
    WHERE s.cdDpt <> '75'
);


-- Requête 2 : Épreuves finales individuelles dans une Aréna avec recette calculée à partir de ACHAT
-- Nb lignes obtenues : 3
SELECT
    e.nomEpr AS "LibEpr",
    p.libPanier,
    s.nomSite,
    SUM(a.nbBil) AS nbBil,
    SUM(a.nbBilTR) AS nbBilTR,
    e.tarif,
    e.tarifR,
    SUM(a.nbBil * e.tarif + a.nbBilTR * e.tarifR) AS recette
FROM epreuve e
JOIN panier p ON e.cdPanier = p.cdPanier
JOIN site s ON e.cdSite = s.cdSite
JOIN achat a ON a.numepr = e.numepr AND a.cdsite = e.cdsite
WHERE LOWER(p.libPanier) LIKE '%final%'
  AND e.typeEpr IN ('ATH', 'HATH')
  AND LOWER(s.nomSite) LIKE '%arena%'
GROUP BY e.nomEpr, p.libPanier, s.nomSite, e.tarif, e.tarifR
ORDER BY p.libPanier;


-- Requête a.3 : Sites de type "espace urbain" et disciplines qu’ils peuvent accueillir
-- Nb lignes obtenues : 19

SELECT
    s.nomSite,
    d.libDiscipFR
FROM site s
JOIN typesite ts ON s.numTpSite = ts.numTpSite
LEFT JOIN accueil a ON a.cdSite = s.cdSite
LEFT JOIN discipline d ON d.cdDiscip = a.cdDiscip
WHERE LOWER(ts.libTpSite) LIKE 'espace urbain%'
ORDER BY s.nomSite, d.libDiscipFR;

-- Requête a.4.1 : Athlètes représentant un autre pays, ne participant à aucune épreuve (avec NOT EXISTS)
-- Nb lignes obtenues : 8

SELECT
    a.nomAth AS nom,
    a.pnomAth AS prenom,
    d.libDiscipFR AS discipline
FROM athlete a
JOIN discipline d ON a.cdDiscip = d.cdDiscip
WHERE a.cdNation <> a.cdPays
AND NOT EXISTS (
    SELECT 1
    FROM participationjo p
    WHERE p.numAth = a.numAth
);

-- Requête a.4.2 : Variante avec LEFT JOIN et IS NULL

SELECT
    a.nomAth AS nom,
    a.pnomAth AS prenom,
    d.libDiscipFR AS discipline
FROM athlete a
JOIN discipline d ON a.cdDiscip = d.cdDiscip
LEFT JOIN participationjo p ON p.numAth = a.numAth
WHERE a.cdNation <> a.cdPays
AND p.numAth IS NULL;

-- Requête a.4.3 : Variante avec IN

SELECT
    a.nomAth AS nom,
    a.pnomAth AS prenom,
    d.libDiscipFR AS discipline
FROM athlete a
JOIN discipline d ON a.cdDiscip = d.cdDiscip
WHERE a.cdNation <> a.cdPays
AND a.numAth NOT IN (
    SELECT numAth
    FROM participationjo
);

-- Requête a.4 BONUS : avec pays représenté et nationalité


SELECT
    a.nomAth AS nom,
    a.pnomAth AS prenom,
    d.libDiscipFR AS discipline,
    UPPER(p1.nomFR) AS "Pays représenté",
    UPPER(p2.nomFR) AS "Nationalité"
FROM athlete a
JOIN discipline d ON a.cdDiscip = d.cdDiscip
JOIN pays p1 ON a.cdNation = p1.cdPays
JOIN pays p2 ON a.cdPays = p2.cdPays
LEFT JOIN participationjo pj ON pj.numAth = a.numAth
WHERE a.cdNation <> a.cdPays
AND pj.numAth IS NULL;




-- Requête a.5 : Français nés avant le 05/10/1985 
-- Nb lignes obtenues : 17

SELECT
    UPPER(p.nomPers) || '-' || p.pnomPers AS "Nom-Prénom",
    EXTRACT(YEAR FROM p.dateNais) AS "Année de naissance",
    'SPECTATEUR' AS type
FROM personne p
WHERE p.cdPays = 'FRA'
  AND p.dateNais < TO_DATE('1985-10-05', 'YYYY-MM-DD')

UNION

SELECT
    UPPER(a.nomAth) || '-' || a.pnomAth AS "Nom-Prénom",
    EXTRACT(YEAR FROM a.dateNais) AS "Année de naissance",
    'ATHLETE' AS type
FROM athlete a
WHERE a.cdPays = 'FRA'
  AND a.dateNais < TO_DATE('1985-10-05', 'YYYY-MM-DD')

ORDER BY 1;




-- b) Figures libres




-- Requête 6 : Montant total des recettes générées par les épreuves de type HATH
-- Elle affiche une seule ligne avec la somme des recettes générées sur tous les achats associés aux épreuves de type HATH

SELECT
    SUM(nbBil * tarif + nbBilTR * tarifR) AS "Recette totale HATH"
FROM (
    SELECT
        a.nbBil,
        a.nbBilTR,
        e.tarif,
        e.tarifR
    FROM achat a
    JOIN epreuve e
      ON a.numEpr = e.numEpr AND a.cdSite = e.cdSite
    WHERE e.typeEpr = 'HATH'
);


-- Requête 7 : Nombre total d’épreuves et nombre d’épreuves estivales (juin-août 2024), par site
-- Fonction d’agrégat : SUM ; Jointure externe ; Filtre BETWEEN sur DATEACHAT


SELECT
    s.nomSite,
    SUM(NVL(a.nbBil, 0) + NVL(a.nbBilTR, 0)) AS "Billets vendus (1er sem. 2024)"
FROM site s
LEFT JOIN achat a ON s.cdSite = a.cdSite
WHERE a.dateAchat BETWEEN TO_DATE('2024-01-01','YYYY-MM-DD') AND TO_DATE('2024-06-30','YYYY-MM-DD')
   OR a.dateAchat IS NULL
GROUP BY s.nomSite
ORDER BY s.nomSite;

-- Requête 8 : Nb d’athlètes par discipline et site
-- Agrégat (COUNT), jointure sur 3 tables, GROUP BY multiple, et filtre sur type ATH

SELECT
    d.libDiscipFR AS "Discipline",
    s.nomSite     AS "Site",
    COUNT(DISTINCT a.numAth) AS "Nb athlètes"
FROM participationjo p
JOIN epreuve e     ON p.numEpr = e.numEpr AND p.cdSite = e.cdSite
JOIN site s        ON e.cdSite = s.cdSite
JOIN athlete a     ON p.numAth = a.numAth
JOIN discipline d  ON a.cdDiscip = d.cdDiscip
WHERE e.typeEpr = 'ATH'  
GROUP BY d.libDiscipFR, s.nomSite
HAVING COUNT(DISTINCT a.numAth) >= 1
ORDER BY d.libDiscipFR, s.nomSite;


-- Requête 9 : Tarif moyen selon présence ou non d’un tarif réduit (tarifR)
-- Fonction d’agrégat AVG, regroupement en deux catégories (NULL / NOT NULL)

SELECT
    CASE
        WHEN tarifR IS NULL THEN 'Sans tarif réduit'
        ELSE 'Avec tarif réduit'
    END AS "Catégorie",
    ROUND(AVG(tarif), 2) AS "Tarif moyen"
FROM epreuve
GROUP BY
    CASE
        WHEN tarifR IS NULL THEN 'Sans tarif réduit'
        ELSE 'Avec tarif réduit'
    END;
    
-- Requête 10 : Spectateurs ayant acheté un billet pour TOUTES les épreuves du site Trocadéro (cdSite = 'TRO')
-- Requête de division : MINUS entre toutes les épreuves du site et celles achetées par le spectateur

SELECT
    p.nomPers || '-' || p.pnomPers AS "Nom-Prénom"
FROM personne p
WHERE NOT EXISTS (
    SELECT e.numEpr
    FROM epreuve e
    WHERE e.cdSite = 'TRO'
    MINUS
    SELECT a.numEpr
    FROM achat a
    WHERE a.cdSite = 'TRO' AND a.numPers = p.numPers
);


-- c) Droits et privilèges


-- 1. Autorisations à accorder

--a)Table SITE (écriture complète) :

GRANT INSERT, UPDATE, DELETE ON site TO bhag0002;

-- b) Table ACHAT (modification partielle + suppression) :

GRANT UPDATE(dateAchat, modeReglt), DELETE ON achat TO bhag0002;

--c) Table EPREUVE — accès filtré via une vue :

CREATE OR REPLACE VIEW epreuve_aout36 AS
SELECT numEpr, cdSite, nomEpr, phase, dateDeb, dateFin
FROM epreuve
WHERE TO_CHAR(dateDeb, 'MMYYYY') = '082024'
  AND cdSite IN (
    SELECT cdSite FROM site WHERE cdDpt = '36'
  );

-- Je lui accorde les droits

GRANT SELECT, INSERT, UPDATE ON epreuve_aout36 TO bhag0002;




-- ------------------------------
-- Requêtes exécutées via le compte de mon binôme BHAG0002 :
-- ------------------------------

-- Mise à jour des dates des épreuves concernées (SKEET MEN - FINAL - août 2024)

-- UPDATE MOUG0045.EPREUVE_AOUT36
-- SET dateDeb = dateDeb + 30,
--     dateFin = dateFin + 30
-- WHERE UPPER(nomEpr) LIKE '%SKEET MEN%'
--   AND UPPER(phase) LIKE '%FINAL%';

-- Suppression des achats dont la date est postérieure à la nouvelle date de fin

-- DELETE FROM MOUG0045.achat a
-- WHERE EXISTS (
--     SELECT 1
--     FROM MOUG0045.EPREUVE_AOUT36 v
--     WHERE v.numEpr = a.numEpr
--       AND v.cdSite = a.cdSite
--       AND a.dateAchat > v.dateFin
-- );







