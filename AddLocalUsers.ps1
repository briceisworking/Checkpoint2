# Q.5.7
# 

Function Random-Password
{
    param ([Int]$Length = 8)
    
    $Punc = 46..46
    $Digits = 48..57
    $Letters = 65..90 + 97..122

    $Password = Get-Random -Count $Length -Input ($Punc + $Digits + $Letters) |`
        ForEach -begin { $aa = $null } -process {$aa += [char]$_} -end {$aa}
    Return $Password.ToString()
}

Function ManageAccentsAndCapitalLetters
{
    param ([String]$String)
    
    $StringWithoutAccent = $String -replace '[éèêë]', 'e' -replace '[àâä]', 'a' -replace '[îï]', 'i' -replace '[ôö]', 'o' -replace '[ùûü]', 'u'
    $StringWithoutAccentAndCapitalLetters = $StringWithoutAccent.ToLower()
    $StringWithoutAccentAndCapitalLetters
}

$Path = "C:\Scripts"
$CsvFile = "$Path\Users.csv"
$LogFile = "$Path\Log.log"

# Q.5.3
# Au lieu de mettre -Skip 2 , on met -Skip 1. Ca permet de skip la premiere ligne du fichier Users.csv mais pas la deuxieme
# Le premier utilisateur sera donc pris en compte
# Q.5.5
# Les champs utilisé sont prénom, nom , description et fonction. On supprime donc les inutiles
$Users = Import-Csv -Path $CsvFile -Delimiter ";" `
    -Header "prenom","nom","fonction","description"`
    -Encoding UTF8  | Select-Object -Skip 1

foreach ($User in $Users)
{
    $Prenom = ManageAccentsAndCapitalLetters -String $User.prenom
    $Nom = ManageAccentsAndCapitalLetters -String $User.Nom
    $Name = "$Prenom.$Nom"
    If (-not(Get-LocalUser -Name "$Prenom.$Nom" -ErrorAction SilentlyContinue))
    {
        $Pass = Random-Password
        $Password = (ConvertTo-secureString $Pass -AsPlainText -Force)
        $Description = "$($User.Description) - $($User.Fonction)"
        # Q.5.4
	    # Le champ Description n'était pas indiqué dans le UserInfo . 
        # Q.5.11
	    # Changement du PasswnordNeverExpires en "True", pour que les utilisateurs aient un mot de passe qui n'expire jamais
        $UserInfo = @{
            Name                 = "$Prenom.$Nom"
            FullName             = "$Prenom.$Nom"
            Password             = $Password
	        Description 	     = $Description
            AccountNeverExpires  = $True
            PasswordNeverExpires = $True
        }

        New-LocalUser @UserInfo
        #Q.5.10
	    # Il manque un "s" a Utilisateurs, le groupe "Utilisateur" n'existe pas donc il y avait des erreurs
        Add-LocalGroupMember -Group "Utilisateurs" -Member "$Prenom.$Nom"
        # Q.5.6
	    # Modification du message en ajoutant la fonction Pass dedans, qui affichera le mot de passe créer aléatoirement
        Write-Host "L'utilisateur $Prenom.$Nom a été crée avec le mot de passe $Pass" -ForegroundColor Green
    }
    
    # Q.5.9
    # Rajout d'un Else pour prevenir que le compte est déjà existant
    Else
    {
	Write-Host "L'utilisateur $Prenom.$Nom existe déjà" -ForegroundColor Red
    }
}
