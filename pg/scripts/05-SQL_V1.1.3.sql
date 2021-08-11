-- Début de la procédure de déploiement automatisé : 
-- Création de la version
DO $$
BEGIN 
   call AAQ_CreerVersion('1.1.3');
END
$$ language plpgsql;

-- Mise à jour du schéma de base de données
DO $$
DECLARE
	FaireMAJSchema BOOLEAN;
BEGIN 
	SELECT AAQ_DeployerVersion('1.1.3','schema') INTO FaireMAJSchema;
	IF FaireMAJSchema THEN
		-- Agrandissement colonne doc_type pour accepter plus de type de documents
		alter table DOCUMENT ALTER COLUMN doc_type TYPE VARCHAR(500);

		-- Création d'une table pouvant accueillir du paramétrage pour l'activation ou désactivation de modules 
		-- Afin de permettre de d'activer des modules en intégration mais pas en Prod
		-- Permettra également de définir des variables métier si besoin
		CREATE TABLE parametres (
				par_id bigint not null,
				par_code varchar(20) not null,
				par_description varchar(100),
				par_valeur varchar(200),
		constraint PK_PARAMETRES primary key (par_id));

		CREATE INDEX "IDX_PARAM_CODE"
			ON public.parametres USING btree
			(par_code ASC NULLS LAST)
			TABLESPACE pg_default;

		-- Déploiement du Schéma effectué
		call AAQ_VersionDeployee('1.1.3','schema');
		raise notice '%','Mise à jour du schéma effectué';
	ELSE
		raise notice '%','Pas de mise à jour schéma à faire';
	END IF;
END
$$ language plpgsql;


-- Mise à jour des données
DO $$
DECLARE
	FaireMAJData BOOLEAN;
BEGIN 
	SELECT AAQ_DeployerVersion('1.1.3','data') INTO FaireMAJData;
	IF FaireMAJData THEN
      -- Création du rôle Structure référente
    	INSERT INTO utilisateur (rol_id,stu_id,uti_validated,uti_mail,uti_nom,uti_prenom) VALUES (3,1,true,'inconnu@aaq.fr','inconnu','inconnu');  

		-- Ajout d'un paramètre pour l'activation désactivation du bouton france connect
		INSERT INTO PARAMETRES VALUES (1,'CONNEXION_FC','Active ou désactive le bouton de connexion France Connect (0/1)',0);
		-- Ajout d'un paramètre pour l'activation désactivation du bouton utilisateur structure
		INSERT INTO PARAMETRES VALUES (2,'CONNEXION_STRUCTURE','Active ou désactive le bouton de connexion pour les acteurs d''une structure (0/1)',0);

		-- Ajout d'une région pour les COM
		INSERT INTO REGION VALUES (99,'COLLECTIVITÉS D''OUTRE-MER',99);

		-- Ajout de départements de COM
		INSERT INTO DEPARTEMENT VALUES (102,'Saint-Pierre-et-Miquelon',975,99);
		INSERT INTO DEPARTEMENT VALUES (103,'Saint-Barthélemy',977,99);
		INSERT INTO DEPARTEMENT VALUES (104,'Saint-Martin',978,99);
		INSERT INTO DEPARTEMENT VALUES (105,'Terres australes et antarctiques françaises',984,99);
		INSERT INTO DEPARTEMENT VALUES (106,'Wallis-et-Futuna',986,99);
		INSERT INTO DEPARTEMENT VALUES (107,'Polynésie française',987,99);
		INSERT INTO DEPARTEMENT VALUES (108,'Nouvelle-Calédonie',988,99);
		INSERT INTO DEPARTEMENT VALUES (109,'Île de Clipperton',989,99);

		-- Ajout des communes de COM
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36000,'97501','','MIQUELON-LANGLADE','','Miquelon-Langlade',975);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36001,'97502','','SAINT-PIERRE','','Saint-Pierre',975);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36002,'97701','','SAINT-BARTHÉLEMY','','Saint-Barthélemy',977);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36003,'97801','','SAINT-MARTIN','','Saint-Martin',978);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36004,'98411','','ÎLES SAINT-PAUL ET NOUVELLE-AMSTERDAM','','Îles Saint-Paul et Nouvelle-Amsterdam',984);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36005,'98412','','ARCHIPEL DES KERGUELEN','','Archipel des Kerguelen',984);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36006,'98413','','ARCHIPEL DES CROZET','','Archipel des Crozet',984);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36007,'98414','','LA TERRE-ADÉLIE','','La Terre-Adélie',984);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36008,'98415','','ÎLES ÉPARSES DE L''OCÉAN INDIEN','','Îles Éparses de l''océan Indien',984);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36009,'98611','','ALO','','Alo',986);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36010,'98612','','SIGAVE','','Sigave',986);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36011,'98613','','UVEA','','Uvea',986);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36012,'98711','','ANAA','','Anaa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36013,'98712','','ARUE','','Arue',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36014,'98713','','ARUTUA','','Arutua',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36015,'98714','','BORA-BORA','','Bora-Bora',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36016,'98715','','FAAA','','Faaa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36017,'98716','','FAKARAVA','','Fakarava',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36018,'98717','','FANGATAU','','Fangatau',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36019,'98718','','FATU-HIVA','','Fatu-Hiva',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36020,'98719','','GAMBIER','','Gambier',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36021,'98720','','HAO','','Hao',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36022,'98721','','HIKUERU','','Hikueru',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36023,'98722','','HITIAA O TE RA','','Hitiaa O Te Ra',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36024,'98723','','HIVA-OA','','Hiva-Oa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36025,'98724','','HUAHINE','','Huahine',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36026,'98725','','MAHINA','','Mahina',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36027,'98726','','MAKEMO','','Makemo',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36028,'98727','','MANIHI','','Manihi',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36029,'98728','','MAUPITI','','Maupiti',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36030,'98729','','MOOREA-MAIAO','','Moorea-Maiao',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36031,'98730','','NAPUKA','','Napuka',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36032,'98731','','NUKU-HIVA','','Nuku-Hiva',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36033,'98732','','NUKUTAVAKE','','Nukutavake',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36034,'98733','','PAEA','','Paea',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36035,'98734','','PAPARA','','Papara',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36036,'98735','','PAPEETE ','','Papeete ',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36037,'98736','','PIRAE','','Pirae',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36038,'98737','','PUKAPUKA','','Pukapuka',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36039,'98738','','PUNAAUIA','','Punaauia',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36040,'98739','','RAIVAVAE','','Raivavae',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36041,'98740','','RANGIROA','','Rangiroa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36042,'98741','','RAPA','','Rapa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36043,'98742','','REAO','','Reao',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36044,'98743','','RIMATARA','','Rimatara',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36045,'98744','','RURUTU','','Rurutu',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36046,'98745','','TAHAA','','Tahaa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36047,'98746','','TAHUATA','','Tahuata',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36048,'98747','','TAIARAPU-EST','','Taiarapu-Est',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36049,'98748','','TAIARAPU-OUEST','','Taiarapu-Ouest',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36050,'98749','','TAKAROA','','Takaroa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36051,'98750','','TAPUTAPUATEA','','Taputapuatea',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36052,'98751','','TATAKOTO','','Tatakoto',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36053,'98752','','TEVA I UTA','','Teva I Uta',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36054,'98753','','TUBUAI','','Tubuai',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36055,'98754','','TUMARAA','','Tumaraa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36056,'98755','','TUREIA','','Tureia',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36057,'98756','','UA-HUKA','','Ua-Huka',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36058,'98757','','UA-POU','','Ua-Pou',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36059,'98758','','UTUROA','','Uturoa',987);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36060,'98801','','BELEP','','Belep',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36061,'98802','','BOULOUPARI','','Bouloupari',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36062,'98803','','BOURAIL','','Bourail',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36063,'98804','','CANALA','','Canala',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36064,'98805','','DUMBÉA','','Dumbéa',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36065,'98806','','FARINO','','Farino',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36066,'98807','','HIENGHÈNE','','Hienghène',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36067,'98808','','HOUAÏLOU','','Houaïlou',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36068,'98809','(L'')','ÎLE-DES-PINS','(L'')','Île-des-Pins',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36069,'98810','','KAALA-GOMEN','','Kaala-Gomen',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36070,'98811','','KONÉ','','Koné',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36071,'98812','','KOUMAC','','Koumac',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36072,'98813','','LA FOA','','La Foa',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36073,'98814','','LIFOU','','Lifou',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36074,'98815','','MARÉ','','Maré',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36075,'98816','','MOINDOU','','Moindou',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36076,'98817','(LE)','MONT-DORE','(Le)','Mont-Dore',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36077,'98818','','NOUMÉA','','Nouméa',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36078,'98819','','OUÉGOA','','Ouégoa',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36079,'98820','','OUVÉA','','Ouvéa',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36080,'98821','','PAÏTA','','Païta',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36081,'98822','','POINDIMIÉ','','Poindimié',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36082,'98823','','PONÉRIHOUEN','','Ponérihouen',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36083,'98824','','POUÉBO','','Pouébo',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36084,'98825','','POUEMBOUT','','Pouembout',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36085,'98826','','POUM','','Poum',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36086,'98827','','POYA','','Poya',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36087,'98828','','SARRAMÉA','','Sarraméa',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36088,'98829','','THIO','','Thio',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36089,'98830','','TOUHO','','Touho',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36090,'98831','','VOH','','Voh',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36091,'98832','','YATÉ','','Yaté',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36092,'98833','','KOUAOUA','','Kouaoua',988);
		INSERT INTO COMMUNE (COM_ID, CPI_CODEINSEE,COM_ARTMAJ,COM_LIBELLEMAJ,COM_ART,COM_LIBELLE,DEP_NUM) VALUES (36093,'98901','','ÎLE DE CLIPPERTON','','Île de Clipperton',989);


		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('97501','97500');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('97502','97500');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('97701','97133');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('97801','97150');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98411','98411');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98412','98404');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98413','98413');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98414','98414');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98415','98415');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98611','98610');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98612','98620');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98613','98600');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98711','98760');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98712','98701');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98713','98761');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98714','98730');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98715','98704');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98716','98763');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98717','98765');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98718','98740');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98719','98755');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98720','98720');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98721','98768');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98722','98705');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98723','98741');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98724','98731');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98725','98709');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98726','98769');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98727','98771');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98728','98732');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98729','98728');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98730','98772');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98731','98742');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98732','98773');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98733','98711');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98734','98712');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98735','98714');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98736','98716');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98737','98774');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98738','98718');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98739','98750');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98740','98776');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98741','98751');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98742','98779');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98743','98752');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98744','98753');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98745','98733');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98746','98743');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98747','98722');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98748','98722');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98749','98781');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98750','98735');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98751','98783');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98752','98726');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98753','98754');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98754','98735');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98755','98784');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98756','98744');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98757','98745');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98758','98735');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98801','98811');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98802','98812');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98803','98870');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98804','98813');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98805','98830');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98806','98880');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98807','98815');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98808','98816');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98809','98832');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98810','98817');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98811','98860');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98812','98850');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98813','98880');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98814','98820');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98815','98828');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98815','98878');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98816','98819');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98817','98810');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98818','98800');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98819','98821');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98820','98814');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98821','98890');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98822','98822');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98823','98823');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98824','98824');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98825','98825');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98826','98826');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98827','98827');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98828','98880');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98829','98829');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98830','98831');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98831','98833');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98832','98834');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98833','98818');
		insert into CODEPOSTAL_INSEE (cpi_codeinsee, cpi_codepostal) values ('98901','98799');

      -- Déploiement du Schéma effectué
      call AAQ_VersionDeployee('1.1.3','data');
	   raise notice '%','Mise à jour des datas effectué';
	ELSE
		raise notice '%','Pas de mise à jour de datas à faire';
	END IF;
END
$$ language plpgsql;

DO $$
DECLARE
	FaireMAJDroit BOOLEAN;
BEGIN 
	SELECT AAQ_DeployerVersion('1.1.3','droit') INTO FaireMAJDroit;
	IF FaireMAJDroit THEN
      CALL AAQ_AjouteDroitsObjets();
		raise notice '%','Mise à jour des droits';
	ELSE
		raise notice '%','Pas de mise à jour des droits à faire';
	END IF;
END
$$ language plpgsql;