# README pour le Script d'Exportation PRTG
### Gregory EL BAJOURY | 02/11/2023
## Description
Ce script PowerShell est conçu pour interroger l'API PRTG Network Monitor afin de récupérer la liste des appareils surveillés et les exporter vers un fichier CSV. 

## Prérequis
- PowerShell 5.1 ou supérieur.
- Accès au serveur PRTG Network Monitor avec les privilèges API nécessaires.
- Connexion internet si le serveur PRTG est hébergé en ligne.

## Configuration
Modifiez les paramètres suivants dans le script pour l'adapter à votre environnement PRTG :
- `$PRTGServer`: URL du serveur PRTG.
- `$UserName`: Nom d'utilisateur pour accéder à l'API PRTG.
- `$Passhash`: Hash de mot de passe pour l'authentification API.

Le hash de mot de passe peut être trouvé dans les paramètres de votre compte utilisateur PRTG, sous "Paramètres du Compte" -> "Paramètres PRTG API".

## Utilisation
Pour exécuter le script :
1. Ouvrez PowerShell.
2. Naviguez jusqu'au répertoire contenant le script.
3. Exécutez le script : 
   ```powershell
   .\listerEquipementsPRTG.ps1
   ````

   Remplacez listerEquipementsPRTG.ps1 par le nom de fichier de votre script.

Le script va générer un fichier CSV dans le répertoire personnel de l'utilisateur ($HOME) avec la date et l'heure actuelles comme partie du nom de fichier.

## Paramètres
`PRTGServer`: L'URL de votre serveur PRTG (ex : "https://prtg.example.com").
`UserName`: Le nom d'utilisateur pour accéder à l'API PRTG.
`Passhash`: Le hash de mot de passe pour l'authentification API.
`OutputFilePath`: Chemin de base pour le fichier CSV de sortie (sans extension).
