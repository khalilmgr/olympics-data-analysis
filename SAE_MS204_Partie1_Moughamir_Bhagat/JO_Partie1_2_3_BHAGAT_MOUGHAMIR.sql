/*==============================================================*/
/* Nom de SGBD :  ORACLE Version 11g                            */
/* Date de cr�ation :  14/05/2025 18:41:32                      */
/*==============================================================*/


drop table ACHAT cascade constraints;

drop table DEPARTEMENT cascade constraints;

drop table DISCIPLINE cascade constraints;

drop table EPREUVE cascade constraints;

drop table PANIER cascade constraints;

drop table SITE cascade constraints;

drop table TYPESITE cascade constraints;

drop table ATHLETE cascade constraints;

drop table PARTICIPATIONJO cascade constraints;


/*==============================================================*/
/* Table : DEPARTEMENT                                          */
/*==============================================================*/
create table DEPARTEMENT 
(
   cdDpt                CHAR(3)              not null,
   nomDpt               VARCHAR2(60)         not null,
   constraint PK_DEPARTEMENT primary key (cdDpt)
);

/*==============================================================*/
/* Table : TYPESITE                                             */
/*==============================================================*/
create table TYPESITE 
(
   numTpSite            INTEGER              not null,
   libTpSite            VARCHAR2(60)         not null,
   constraint PK_TYPESITE primary key (numTpSite)
);

/*==============================================================*/
/* Table : SITE                                                 */
/*==============================================================*/
create table SITE 
(
   cdSite               CHAR(3)              not null,
   numTpSite            INTEGER              not null,
   cdDpt                CHAR(3)              not null,
   nomSite              VARCHAR2(60)         not null,
   arrond               INTEGER             
      constraint CKC_ARROND_SITE check (arrond is null or (arrond between 1 and 20)),
   longitude            NUMBER(11,8),
   latitude             NUMBER(11,8),
   constraint PK_SITE primary key (cdSite),
   constraint FK_SITE_LOCALISER_DEPARTEM foreign key (cdDpt)
         references DEPARTEMENT (cdDpt),
   constraint FK_SITE_CARACTERI_TYPESITE foreign key (numTpSite)
         references TYPESITE (numTpSite)
);

/*==============================================================*/
/* Table : PANIER                                               */
/*==============================================================*/
create table PANIER 
(
   cdpanier             INTEGER              not null,
   libPanier            VARCHAR2(60)         not null,
   constraint PK_PANIER primary key (cdpanier)
);

/*==============================================================*/
/* Table : DISCIPLINE                                           */
/*==============================================================*/
create table DISCIPLINE 
(
   cdDiscip             CHAR(4)              not null,
   libDiscipFr          VARCHAR2(60)         not null,
   libDiscipAn          VARCHAR2(60)         not null,
   constraint PK_DISCIPLINE primary key (cdDiscip)
);

/*==============================================================*/
/* Table : EPREUVE                                              */
/*==============================================================*/
create table EPREUVE 
(
   cdSite               CHAR(3)              not null,
   numEpr               INTEGER              not null,
   cdpanier             INTEGER              not null,
   cdDiscip             CHAR(4)              not null,
   nomEpr               VARCHAR2(60)         not null,
   phase                VARCHAR2(60)         not null,
   genreEpr             CHAR(1)              not null
      constraint CKC_GENREEPR_EPREUVE check (genreEpr in ('M','W','O','X')),
   typeEpr              CHAR(5)              not null
      constraint CKC_TYPEEPR_EPREUVE check (typeEpr in ('ATH','HATH','TEAM','HTEAM','COUP','HCOUP')),
   dateDeb              DATE,
   dateFin              DATE,
   tarif                NUMBER(6,2),
   tarifR               NUMBER(6,2),
   constraint PK_EPREUVE primary key (cdSite, numEpr),
   constraint FK_EPREUVE_ORGANISER_SITE foreign key (cdSite)
         references SITE (cdSite),
   constraint FK_EPREUVE_REGROUPER_PANIER foreign key (cdpanier)
         references PANIER (cdpanier),
   constraint FK_EPREUVE_RATTACHER_DISCIPLI foreign key (cdDiscip)
         references DISCIPLINE (cdDiscip)
);

/*==============================================================*/
/* Table : ACHAT                                                */
/*==============================================================*/
create table ACHAT 
(
   numPers              INTEGER              not null,
   cdSite               CHAR(3)              not null,
   numEpr               INTEGER              not null,
   dateAchat            DATE                 not null,
   nbBil                INTEGER,
   nbBilTR              INTEGER,
   modeReglt            CHAR(3)              not null
      constraint CKC_MODEREGLT_ACHAT check (modeReglt in ('CB','ESP','CHQ')),
   constraint PK_ACHAT primary key (numPers, cdSite, numEpr, dateAchat),
   constraint FK_ACHAT_EFFECTUER_PERSONNE foreign key (numPers)
         references PERSONNE (numPers),
   constraint FK_ACHAT_CONCERNER_EPREUVE foreign key (cdSite, numEpr)
         references EPREUVE (cdSite, numEpr)
);


-- Création de la table ATHLETE à partir de JO2024.ATHLETE_IMPORT
CREATE TABLE ATHLETE AS
SELECT 
   NUMERO             AS numAth,
   CDPAYS             AS cdPays,
   CDNATION           AS cdNation,
   NOM                AS nomAth,
   PRENOM             AS pnomAth,
   CASE 
      WHEN UPPER(GENRE) = 'FEMALE' THEN 'F'
      WHEN UPPER(GENRE) = 'MALE' THEN 'M'
      ELSE NULL
   END                AS genreAth,
   BIRTH_DATE         AS dateNais
FROM JO2024.ATHLETE_IMPORT
Where numero is not null
AND discipline is not null
AND cdNation is not null
AND cdPays is not null
AND nom is not null
And prenom is not null
AND genre is not null
;


-- Contraintes sur la table ATHLETE
ALTER TABLE ATHLETE
ADD CONSTRAINT PK_ATHLETE PRIMARY KEY (numAth);

ALTER TABLE ATHLETE ADD CONSTRAINT FK_ATHLETE_REPRESENTE_PAYS FOREIGN KEY (cdPays)
REFERENCES PAYS(cdPays)
ON DELETE SET NULL;

ALTER TABLE ATHLETE ADD CONSTRAINT FK_ATHLETE_NATIONALITE_PAYS FOREIGN KEY (cdNation)
REFERENCES PAYS(cdPays)
ON DELETE SET NULL;

ALTER TABLE ATHLETE
ADD CONSTRAINT CK_GENRE_ATH CHECK (genreAth IN ('F', 'M'));

-- dateNais reste nullable (aucune modification ici)
ALTER TABLE ATHLETE MODIFY (
    numAth INTEGER not null,
    cdPays CHAR(3) not null,
    cdnation CHAR(3) not null,
    nomAth VARCHAR2(50) not null,
    pnomAth VARCHAR2(50) not null,
    genreAth CHAR(1) not null,
    dateNais DATE
);


-- Création de la table PARTICIPATIONJO
CREATE TABLE PARTICIPATIONJO (
   numAth   INTEGER     NOT NULL,
   cdSite   CHAR(3)     NOT NULL,
   numEpr   INTEGER     NOT NULL,
   PRIMARY KEY (numAth, cdSite, numEpr),
   CONSTRAINT FK_PARTICIPATIONJO_ATHLETE FOREIGN KEY (numAth)
      REFERENCES ATHLETE(numAth)
      ON DELETE CASCADE,
   CONSTRAINT FK_PARTICIPATIONJO_EPREUVE FOREIGN KEY (cdSite, numEpr)
      REFERENCES EPREUVE(cdSite, numEpr)
      ON DELETE CASCADE
);



--  créer une colonne virtuelle dureeEp
ALTER TABLE EPREUVE
ADD dureeEp GENERATED ALWAYS AS (dateFin - dateDeb) VIRTUAL;


-- Une contrainte de domaine de votre choix (ayant un intérêt)
ALTER TABLE EPREUVE
ADD CONSTRAINT CK_TARIF_POSITIF
CHECK (tarif >= 0);




-- • BONUS : 
-- Index sur les clés étrangères de la table PERSONNE
CREATE INDEX fk_prsn_pays ON PERSONNE(cdPays);
CREATE INDEX fk_epreuve_associati_discipli ON EPREUVE(cdDiscip);
CREATE INDEX fk_epreuve_regrouper_panier ON EPREUVE(cdpanier);

-- Index sur les clés étrangères de la table ATHLETE
CREATE INDEX fk_cdnation ON ATHLETE(cdnation);
CREATE INDEX fk_cdPays ON ATHLETE(cdPays);

-- Index sur les clés étrangères de la table PARTICIPATIONJO
CREATE INDEX fk_participation_athlete ON PARTICIPATIONJO(numAth);
CREATE INDEX fk_participation_epreuve ON PARTICIPATIONJO(cdSite, numEpr);

-- Le nom des sites
CREATE INDEX index_nomSite ON SITE(nomSite);

-- Les noms-prénoms des athlètes
CREATE INDEX index_nom_pnom_athlete ON ATHLETE(nomAth, pnomAth);

-- Le nom des épreuves.
CREATE INDEX index_nomEpr ON EPREUVE(nomEpr);







