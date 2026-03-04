 Dashboard de pilotage – Toys & Models
 Contexte du projet

Dans ce projet, j’ai été missionné pour analyser les données d’une entreprise spécialisée dans la vente de modèles et maquettes.

L’entreprise dispose déjà d’une base de données contenant des informations sur :

les clients

les commandes

les paiements

les produits

les employés

les bureaux

Le directeur souhaite disposer d’un tableau de bord dynamique, actualisable quotidiennement, afin de suivre les performances de l’entreprise et faciliter la prise de décision.

L’objectif du projet est donc de transformer les données de la base SQL en indicateurs métiers exploitables, puis de les visualiser dans un dashboard interactif Power BI.

Objectifs du projet

Créer un tableau de bord permettant de suivre la performance de l’entreprise autour de quatre axes principaux :

 Ventes

 Finances

 Logistique

 Ressources humaines

Les indicateurs clés (KPI) ont été calculés à partir de requêtes SQL puis intégrés dans Power BI pour la visualisation.

 Outils utilisés

MySQL  → interrogation de la base de données

SQL → calcul des indicateurs et préparation des données

Power BI → création du tableau de bord interactif

 Analyse des données avec SQL

La première étape du projet consistait à écrire des requêtes SQL permettant de calculer les principaux indicateurs de performance (KPI).

Ces indicateurs ont été organisés autour de plusieurs domaines métier.

 Ressources humaines

Chiffre d’affaires généré par chaque commercial

Ratio commandes / paiements par commercial

Performance des bureaux (revenus générés)

Ces indicateurs permettent d’évaluer la performance des équipes commerciales et des différents bureaux.

 Ventes

Chiffre d’affaires par mois et par région

Produits les plus vendus par catégorie

Marge brute par produit et par catégorie

Taux d'évolution mensuel

Ces analyses permettent d’identifier les produits performants et les tendances de ventes.

 Finances

Clients générant le plus et le moins de revenus

Taux de recouvrement par client

Croissance des ventes par trimestre

Ces indicateurs permettent de suivre la santé financière et la valeur des clients.

 Logistique

Produits avec un stock sous le seuil critique

Durée moyenne de traitement des commandes

Commandes livrées en retard

Rotation des stocks

Ces analyses permettent d’évaluer l’efficacité opérationnelle et la gestion des stocks.

 Modélisation des données

La base de données fournie est construite selon un schéma transactionnel (OLTP), optimisé pour les opérations métiers mais peu adapté à l’analyse.

Afin d’améliorer les performances dans Power BI, le modèle a été transformé en schéma analytique (modèle en étoile).

Cela consiste à organiser les données autour de :

Table de faits

Contenant les données quantitatives nécessaires au calcul des indicateurs (ventes, paiements, stocks).

Tables de dimensions

Contenant les informations descriptives permettant d’analyser les données sous différents angles :

clients

produits

employés

bureaux

dates

 Dashboard Power BI

Les vues SQL créées ont été importées dans Power BI afin de construire un tableau de bord interactif.

Le dashboard permet notamment de :

suivre les performances commerciales

analyser les ventes par région et par produit

identifier les meilleurs clients

surveiller les niveaux de stock

évaluer les performances des commerciaux

 Structure du projet
toys-dashboard
│
├── sql
│   └── requetes_kpi.sql
│
├── powerbi
│   └── dashboard.pbix
│
├── images
│   └── dashboard_preview.png
│
└── README.md

 Difficultés rencontrées

Travail sur une base transactionnelle nécessitant de nombreuses jointures

Optimisation des requêtes pour l’utilisation dans Power BI

Construction d’un modèle de données analytique

 Compétences développées

À travers ce projet j’ai pu :

écrire des requêtes SQL analytiques

comprendre la différence entre modèle transactionnel et analytique

construire un modèle en étoile

créer un dashboard interactif Power BI

traduire des besoins métiers en indicateurs de performance
