#           _____                    _____                   _______                  _______               _____          
#          /\    \                  /\    \                 /::\    \                /::\    \             /\    \         
#         /::\    \                /::\    \               /::::\    \              /::::\    \           /::\    \        
#        /::::\    \              /::::\    \             /::::::\    \            /::::::\    \          \:::\    \       
#       /::::::\    \            /::::::\    \           /::::::::\    \          /::::::::\    \          \:::\    \      
#      /:::/\:::\    \          /:::/\:::\    \         /:::/~~\:::\    \        /:::/~~\:::\    \          \:::\    \     
#     /:::/  \:::\    \        /:::/__\:::\    \       /:::/    \:::\    \      /:::/    \:::\    \          \:::\    \    
#    /:::/    \:::\    \      /::::\   \:::\    \     /:::/    / \:::\    \    /:::/    / \:::\    \         /::::\    \   
#   /:::/    / \:::\    \    /::::::\   \:::\    \   /:::/____/   \:::\____\  /:::/____/   \:::\____\       /::::::\    \  
#  /:::/    /   \:::\ ___\  /:::/\:::\   \:::\____\ |:::|    |     |:::|    ||:::|    |     |:::|    |     /:::/\:::\    \ 
# /:::/____/  ___\:::|    |/:::/  \:::\   \:::|    ||:::|____|     |:::|    ||:::|____|     |:::|    |    /:::/  \:::\____\
# \:::\    \ /\  /:::|____|\::/   |::::\  /:::|____| \:::\    \   /:::/    /  \:::\    \   /:::/    /    /:::/    \::/    /
#  \:::\    /::\ \::/    /  \/____|:::::\/:::/    /   \:::\    \ /:::/    /    \:::\    \ /:::/    /    /:::/    / \/____/ 
#   \:::\   \:::\ \/____/         |:::::::::/    /     \:::\    /:::/    /      \:::\    /:::/    /    /:::/    /          
#    \:::\   \:::\____\           |::|\::::/    /       \:::\__/:::/    /        \:::\__/:::/    /    /:::/    /           
#     \:::\  /:::/    /           |::| \::/____/         \::::::::/    /          \::::::::/    /     \::/    /            
#      \:::\/:::/    /            |::|  ~|                \::::::/    /            \::::::/    /       \/____/             
#       \::::::/    /             |::|   |                 \::::/    /              \::::/    /                            
#        \::::/    /              \::|   |                  \::/____/                \::/____/                             
#         \::/____/                \:|   |                   ~~                       ~~
param(
    [string]$PRTGServer = "https://votreServeurPrtg", # URL du serveur PRTG
    [string]$UserName = "votreUtilisateur",            # Nom d'utilisateur pour accéder à l'API PRTG
    [string]$Passhash = "votrePassHash",         # Hash de mot de passe pour l'authentification API
    [string]$OutputFilePath = "$HOME\PRTG-Export.csv" # Chemin du fichier CSV de sortie
)

# Fonction pour récupérer les appareils depuis l'API PRTG
function Get-PRTGDevices {
    param (
        [string]$Server,    # URL du serveur PRTG
        [string]$Username,  # Nom d'utilisateur pour l'API
        [string]$Passhash   # Hash de mot de passe pour l'API
    )

    # Construction de l'URL pour la requête API
    $ApiUri = "$Server/api/table.json?content=devices&output=json&columns=objid,device,group,host&username=$Username&passhash=$Passhash"

    try {
        # Appel API et récupération des données
        $Response = Invoke-RestMethod -Uri $ApiUri -Method Get -ErrorAction Stop
        # Tri des appareils par ordre alphabétique de leur nom et retour des résultats
        return $Response.devices | Sort-Object device
    } catch {
        # Gestion des erreurs lors de l'appel API
        Write-Error "Erreur lors de l'appel API à PRTG : $_"
        return $null
    }
}

# Fonction pour exporter les appareils vers un fichier CSV
function Export-DevicesToCSV {
    param (
        [Array]$Devices,        # Liste des appareils à exporter
        [string]$OutputFilePath # Chemin du fichier CSV de sortie
    )

    if ($null -eq $Devices) {
        Write-Error "Aucun appareil à exporter."
        return
    }
    
    # Exportation des appareils vers un fichier CSV
    $Devices | ForEach-Object {
        # Création d'un objet personnalisé pour chaque appareil
        [PSCustomObject]@{
            "ID Appareil" = $_.objid
            "Appareil"    = $_.device
            "Groupe"      = $_.group
            "Hote"        = $_.host
        }
    } | Export-Csv -Path $OutputFilePath -NoTypeInformation -Delimiter ";" -Encoding UTF8
}

# Fonction principale
function Main {
    # Format de la date au format jour-mois-année et ajout de l'heure au format heure-minutes
    $DateTimeFormat = (Get-Date -Format "dd-MM-yyyy-HHmm")
    
    # Vérification de la présence de tous les paramètres requis
    if (-not $PRTGServer -or -not $UserName -or -not $Passhash) {
        Write-Host "Tous les paramètres sont obligatoires." -ForegroundColor Red
        return
    }

    # Début du processus d'extraction
    Write-Host "Début de l'extraction de la liste des équipements de PRTG..."
    # Récupération des appareils depuis PRTG
    $Devices = Get-PRTGDevices -Server $PRTGServer -Username $UserName -Passhash $Passhash
    # Vérification si la récupération a réussi
    if ($Devices -ne $null) {
        # Ajout de la date et de l'heure au fichier de sortie
        $OutputFilePath = "$OutputFilePath-$DateTimeFormat.csv"
        # Exportation des appareils vers un fichier CSV
        Export-DevicesToCSV -Devices $Devices -OutputFilePath $OutputFilePath
        # Confirmation de l'exportation réussie
        Write-Host "La liste des équipements a été exportée avec succès vers $OutputFilePath"
        # Ouverture du fichier CSV dans Excel (à décommenter pour activer)
        # Start-Process -FilePath $OutputFilePath
    } else {
        Write-Error "Échec de la récupération des équipements depuis PRTG."
    }
}

# Exécution du script
Main
