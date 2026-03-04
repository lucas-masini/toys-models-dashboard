use toys_and_models;

-- KPI RH --

-- Performances des représentants commerciaux
SELECT 
    e.employeeNumber,  -- Identifiant unique de l'employé (clé primaire)
    CONCAT(e.firstName, ' ', e.lastName) AS commercial,  -- nom complet du commercial
    e.jobTitle,  -- Titre de poste 
    SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires  -- CA total réel généré par le commercial
FROM employees e
-- on part de la table des employés (chaque commercial est un employé)
JOIN customers c 
    ON e.employeeNumber = c.salesRepEmployeeNumber
-- on relie chaque employé aux clients dont il est responsable
JOIN orders o 
    ON c.customerNumber = o.customerNumber
-- on relie chaque client aux commandes qu'il a passées
JOIN orderdetails od 
    ON o.orderNumber = od.orderNumber
-- on relie chaque commande à ses lignes (pour récupérer quantité et prix)
WHERE e.jobTitle LIKE '%Sales Rep%'  -- on limite aux représentants commerciaux
  AND o.status LIKE 'Shipped'  -- on exclut les commandes annulées et en cours
GROUP BY e.employeeNumber, commercial, e.jobTitle
-- on regroupe les données par commercial pour calculer un total par vendeur
ORDER BY chiffre_affaires DESC;
-- on trie les commerciaux avec un CA du plus élevé au moins élevé


-- Performance des bureaux

SELECT 
    ofi.officeCode,  -- Identifiant unique du bureau 
    ofi.city AS ville,    -- nom de la ville du bureau 
    SUM(od.quantityOrdered * od.priceEach) AS chiffre_affaires  -- CA total généré par ce bureau
FROM offices ofi
-- on part de la table des bureaux 
JOIN employees e
    ON ofi.officeCode = e.officeCode
-- on relie chaque bureau aux employés 
JOIN customers c 
    ON e.employeeNumber = c.salesRepEmployeeNumber
-- on relie ces employés aux clients d
JOIN orders o 
    ON c.customerNumber = o.customerNumber
-- on relie chaque client aux commandes q
JOIN orderdetails od 
    ON o.orderNumber = od.orderNumber
WHERE o.status LIKE 'Shipped'  -- on exclut les commandes annulées et en cours
-- on relie chaque commande à ses lignes pour récupérer prix et quantités
GROUP BY ofi.officeCode, ofi.city
-- on regroupe les résultats par bureau pour calculer le CA total
ORDER BY chiffre_affaires DESC;
-- on classe les bureaux du plus performant au moins performant


-- Calculer ratio + ecart commandes/paiements

-- On calcule les commandes (CA) générées par chaque commercial
WITH commandes_par_rep AS (
    SELECT 
        e.employeeNumber,                                        -- identifiant unique du commercial
        CONCAT(e.firstName, ' ', e.lastName) AS commercial,      -- nom complet du commercial
        SUM(od.quantityOrdered * od.priceEach) AS total_commandes -- chiffre d'affaires total généré par ses commandes
    FROM employees e
    JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber -- lier chaque commercial à ses clients
    JOIN orders o ON c.customerNumber = o.customerNumber            -- lier les clients à leurs commandes
    JOIN orderdetails od ON o.orderNumber = od.orderNumber          -- détail des commandes (prix × quantité)
    WHERE e.jobTitle LIKE '%Sales Rep%'                          -- ne garder que les représentants commerciaux
    GROUP BY e.employeeNumber, commercial                           -- regrouper par commercial
),

-- On calcule les paiements réellement reçus pour chaque commercial
paiements_par_rep AS (
    SELECT 
        e.employeeNumber,                                        -- identifiant unique du commercial
        SUM(p.amount) AS total_paiements                        -- total des paiements encaissés
    FROM employees e
    JOIN customers c ON e.employeeNumber = c.salesRepEmployeeNumber -- lier commercial → clients
    JOIN payments p ON c.customerNumber = p.customerNumber          -- lier clients → paiements
    WHERE e.jobTitle LIKE '%Sales Rep%'                             -- toujours uniquement les commerciaux
    GROUP BY e.employeeNumber                                       -- regrouper par commercial
)

-- Comparaison commandes vs paiements
SELECT 
    c.employeeNumber,               -- identifiant du commercial
    c.commercial,                   -- nom complet
    c.total_commandes,              -- chiffre d'affaires commandé 
    p.total_paiements,              -- montant réellement payé (encaissé)
    ROUND(p.total_paiements / c.total_commandes, 2) AS ratio_paiement, -- ratio paiement / commande
    ROUND(c.total_commandes - p.total_paiements, 2) AS ecart            -- écart entre commandé et réellement payé
FROM commandes_par_rep c
JOIN paiements_par_rep p 
    ON c.employeeNumber = p.employeeNumber -- jointure sur le commercial
ORDER BY ratio_paiement DESC;              -- trier du meilleur ratio au moins bon

-- KPI VENTES --

-- Point 1: Chiffre d’affaires par mois et par région + taux d’évolution mensuel

-- Partie A: Partie 1 = CA par mois et région
SELECT 
  MONTH(o.orderDate) AS mois,
  SUM(od.quantityOrdered * od.priceEach) AS chiffre_aff,
  c.country
FROM orders o
JOIN orderdetails od ON o.orderNumber = od.orderNumber
	JOIN customers c ON o.customerNumber = c.customerNumber
GROUP BY MONTH(o.orderDate), c.Country
ORDER BY mois AND c.country;
-- Note perso: pour regrouper les ventes par mois, il faut une date de commande et non de paiement

-- Partie B: Taux d’évolution Mensuel
SELECT
	pr.productline,
    pr.productName,
    SUM(od.quantityOrdered * od.priceEach) AS vente_totale
FROM
	products pr
JOIN
	orderdetails od ON pr.productCode = od.productCode
GROUP BY
	pr.productline, pr.productName
-- On va chercher le max de chaque produits
-- -- Condition pour chercher le max de chaque somme de chaque produits
HAVING SUM(od.quantityOrdered * od.priceEach) = (
  SELECT 
    MAX(SUM(od2.quantityOrdered * od2.priceEach))
  FROM products pr2
  JOIN orderdetails od2 ON pr2.productCode = od2.productCode
  WHERE pr2.productLine = pr.productLine
  GROUP BY pr2.productName
    );

-- Point 2: Produits les plus/moins vendus par catégorie

    -- Étape 1 : chiffre d’affaires par produit (CTE #1)
WITH ventes AS (
  SELECT 
    pr.productLine,
    pr.productName,
    SUM(od.quantityOrdered * od.priceEach) AS vente_totale
  FROM products pr
  JOIN orderdetails od ON pr.productCode = od.productCode
  GROUP BY pr.productLine, pr.productName
),

-- Étape 2 : max par catégorie (CTE #2)
max_ventes AS (
  SELECT 
    productLine,
    MAX(vente_totale) AS max_vente
  FROM ventes
  GROUP BY productLine
)

-- Étape 3 : jointure pour ne garder que les meilleurs
SELECT 
  v.productLine,
  v.productName,
  v.vente_totale
FROM ventes v
JOIN max_ventes m ON v.productLine = m.productLine AND v.vente_totale = m.max_vente;


-- Point 3 : La marge brute par produit et par catégorie
SELECT
  p.productName,
  p.productLine,
  SUM((od.priceEach - p.buyPrice) * od.quantityOrdered) AS marge_totale         -- Marge totale des ventes
FROM
  products p
JOIN
  orderdetails od ON p.productCode = od.productCode                     		-- joindre infos
GROUP BY
  p.productName, p.productLine
ORDER BY
  marge_totale DESC;

-- KPI FINANCES -

-- 1 - CLIENTS QUI GENERENT LE PLUS DE REVENUS

SELECT 
customerName as Nom_client, # pour un affichage clair on renomme le titre de colonne
SUM(amount) as Revenus_generes # faire la somme des montants payés car les clients ont plusieurs commandes
FROM
payments
JOIN customers ON payments.customerNumber = customers.customerNumber # on croise table client et la table paiement
GROUP by customerName # on veut un affichage des montants par client
ORDER By sum(amount) DESC # on veut un affichage par valeur plus importante
LIMIT 10; # on limite à 10
-- CLIENTS QUI GENERENT LE MOINS DE REVENUS
SELECT
customerName as Nom_client,# pour un affichage clair on renomme le titre de colonne
SUM(amount) as Revenus_generes # faire la somme des montants payés car les clients ont plusieurs commandes
FROM
payments
JOIN customers ON payments.customerNumber = customers.customerNumber # on croise table client et la table paiement
GROUP by customerName # on veut un affichage des montants par client
ORDER By sum(amount) ASC # on veut un affichage par valeur moins importante
LIMIT 10; # on limite à 10
-- 2 - TAUX DE RECOUVREMENT - statut shipped (livré) seulement car certains sont en cancel et ne doivent pas etres pris en compte
-- Calcul du taux de recouvrement des créances par client
WITH total_commandes AS ( -- pour calculer le détails des commandes par client
  SELECT 
    c.customerNumber,
    SUM(od.quantityOrdered * od.priceEach) AS total_commande
  FROM customers c
  JOIN orders o ON c.customerNumber = o.customerNumber
  JOIN orderdetails od ON o.orderNumber = od.orderNumber
  WHERE o.status = 'shipped'  -- Filtre pour les commandes expédiées
  GROUP BY c.customerNumber
),
total_paiements AS ( -- pour calculer le détails des paiements par client
  SELECT 
    p.customerNumber,
    SUM(p.amount) AS total_paye
  FROM payments p
  GROUP BY p.customerNumber
)
SELECT 
  c.customerNumber AS Numero_du_client,
  c.customerName AS Nom_du_client,
  ROUND( -- calcul du taux de recouvrement
	  -- utilisation de COALESCE si jamais le total payé est nul, cela renverra "0" au lieu de NULL
	  -- But principal : éviter les NULL qui bloquent les calculs.
    (COALESCE(tp.total_paye, 0) / tc.total_commande) * 100,
    2 -- arrondi à 2 avec ROUND()
  ) AS Taux_de_recouvrement,
  ROUND(tc.total_commande, 2) AS Montant_du_total_des_commandes,
  ROUND(COALESCE(tp.total_paye, 0), 2) AS Montant_total_deja_paye,
-- ajout d'une colonne avec le montant des impayés qui est une information intéressante au delà du taux de recouvrement
  ROUND(tc.total_commande - COALESCE(tp.total_paye, 0), 2) AS Montant_impaye
FROM customers c
JOIN total_commandes tc ON c.customerNumber = tc.customerNumber
JOIN total_paiements tp ON c.customerNumber = tp.customerNumber
ORDER BY Taux_de_recouvrement ASC;

-- KPI LOGISTIQUE -

-- LOGISTIQUE : KPI 1
-- Stock des produits sous seuil critique : Identifier les produits dont le stock est faible pour éviter les ruptures.
SELECT
	productName AS nom_du_produit,
    productCode AS code_du_produit,
    quantityInStock AS quantite_restante
FROM products
WHERE quantityInStock < 100
ORDER BY quantite_restante;


-- LOGISTIQUE : KPI 2
-- Durée moyenne de traitement des commandes + commandes au-dessus de la moyenne de livraison : 
-- Mesurer l’efficacité opérationnelle en analysant le temps entre la date de commande et la date d’expédition.
SELECT 
	-- sélection des colonnes pertinentes qui seront affichées
    orderNumber,
    orderDate,
    shippedDate,
    -- utilisation de DATEDIFF() pour calculer le temps de livraison (= la différence entre la date de commande et la date de livraison)
    DATEDIFF (shippedDate, orderdate) AS "temps_de_livraison_en_jours"
FROM orders
WHERE
	shippedDate IS NOT NULL -- rajout de cette partie au cas où le produit ne serait pas encore envoyé
	AND DATEDIFF (shippedDate, orderdate) > ( -- sous-requête pour comparer le temps de livraison avec le temps moyen de livraison
												SELECT AVG (DATEDIFF (shippedDate, orderdate))
												FROM orders
												WHERE shippedDate IS NOT NULL -- idem 1er WHERE
											)
ORDER BY temps_de_livraison_en_jours DESC; -- livraison classées de la plus longue à la plus rapide

-- KPI 3 -- moyen détourné suite conversation avec Claire
-- pour connaitre le nombre de produits dans la base :
SELECT COUNT(*)
FROM products;
-- il y a 110 produits dans la base
-- maintenant je vais calculer combien d'unités sont vendues par an (sur la base de 2023) et par mois pour chaque produits
-- en les classant des plus vendues au moins vendues
SELECT
	p.productName,
    SUM(od.quantityOrdered) AS quantite_vendue_en_2023,
    ROUND((SUM(od.quantityOrdered) / 12), 0) AS moyenne_d_unites_vendues_par_mois
FROM products p
JOIN orderdetails od ON p.productCode = od.productCode
JOIN orders o ON o.orderNumber = od.orderNumber -- je fais une jointure aussi avec la table orders pour récupérer la date
WHERE YEAR (o.orderDate) = 2023 -- je regarde 2023, car c'est la seule année complète (année de référence)
GROUP BY p.productName
ORDER BY quantite_vendue_en_2023 DESC;


-- LOGISTIQUE : KPI 4
-- Taux de commandes livrées en retard : Identifier les problèmes logistiques et améliorer les délais de livraison.
-- Je me base sur la table orders qui contient la date de commande (orderDate), la date de livraison demandée (requireDate) et la date de livraison réelle (shippedDate)
-- Pour Calculer le pourcentage de commandes livrées après la date requise, je divise le nombre de commandes livrées en retard par le nombre total de commandes livrées, multiplié par 100.
SELECT
	ROUND( -- FONCTION round() pour arrondir mon resultat à 2 décimales
			-- calcul du nombre de commandes livrées en retard
			(
			SELECT COUNT(orderNumber)
			FROM orders
			WHERE shippedDate IS NOT NULL AND shippedDate > requiredDate
			)
			/ -- division par le nombre total de commandes livrées
			(
			SELECT COUNT(orderNumber)
			FROM orders
			WHERE shippedDate IS NOT NULL
			)
			-- multiplié par 100 pour obtenir le taux de commandes en retard
			* 100
		, 2) -- fin de la FONCTION round() arrondir mon resultat à 2 décimales
	AS "taux_de_commandes_en_retard";
