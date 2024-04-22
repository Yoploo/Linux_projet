# Projet

Ce projet est fait dans le cadre du cours d'administration Linux avancée de la deuxième année à l'ESGI.

Il consiste d'une part à mettre en place des scripts pour automatiser certaines actions, et d'autre part à construire un duo de serveurs DNS (primaire et secondaire).

Vous trouverez ici la première partie dudit projet : les scripts.

## 1 - createUsers.sh

L'objectif de ce script est de créer les utilisateurs donnés dans la liste accountsSource.

La liste contient des informations sur les users, ils doivent être créés en tenant compte de ces informations.

Chaque ligne de la liste doivent être de la forme :

    prénom:nom:groupePrimaire,groupeSecondaire1:sudo:password

Le format et l'intégrité des données saisies dans chaque ligne de la liste sont vérifiés par un script AWK annexe.

- Prénom et nom : Mot composé de lettres.
- Groupes : Peut être vide, mots séparés par des virgules
- Nom de groupe : Mot composé de chiffres et/ou de lettres
- sudo : "oui" ou "non"
- password : Doit faire minimum 8 caractères

## 2 - listUsers.sh

Ce script sert à donner les informations sur des utilisateurs humains.

Par défaut, il donne les informations de tous les utilisateurs humains.

Les informations données sont :

    Nom d'utilisateur, Prénom, Nom, Groupe primaire, groupes secondaires, taille du répertoire personnel, sudo

Ce script peut prendre 4 paramètres en entrée :

### -G : Fitrer par groupe primaire

Ce paramètre prend en valeur une chaîne de caractère.

Ne seront listés que les utilisateurs dont le nom du groupe primaire correspond à la chaîne donnée.

### -g : Filtrer par groupe secondaire

Ce paramètre prend en valeur une chaîne de caractère.

Ne seront listés que les utilisateurs dont le nom d'un des groupes secondaires correspond à la chaîne donnée.

### -u

Ce paramètre prend en valeur une chaîne de caractère.

Ne seront listés que les utilisateurs dont le nom d'utilisateur ou le nom complet (prénom + nom) correspond à la chaîne donnée.

### -s

Ce paramètre prend en valeur 0 ou 1.

Si le paramètre vaut 0, le script retournera les utilisateurs non-sudoers.

Si le paramètre vaut 1, le script retournera les utilisateurs sudoers.

## 3 - modifList.sh
