Add-Type -AssemblyName System.Windows.Forms

##############
# ADJUST ROM #
##############

$romname = "MK64-HootingTime" #YOUR ROM NAME WITHOUT VERSION
$example_version = "1.40" #VERSION EXAMPLE (ONLY RELEVANT FOR MAX LENGTH CHECK)
    
$romhash = "579c48e211ae952530ffc8738709f078d5dd215e" #MK64 EXAMPLE SHA-1

#################
# ADJUST SCRIPT #
#################

$script_header = 
"                                                                                                                                   
                                                       ####          ####                                                          
 ##  ##   ####    ####  ####### ## ###  ##  #####       #### ++++++ ###        #####     ##   #######  ####  ##  ## ###### #####   
 ###### ### ### ### ###   ##    ## #### ## ## ##          #####++#####         ##  ##   ####    ##    ##     ###### #####  ## ###  
 ##  ## ### ### ### ###   ##    ## ## #### ### ##        #+++++##+++++##       #####   ######   ##    ##     ### ## ###    #####   
 ##  ##  ####     ###     ##    ## ##   ##  #####       +#+++++##+++++##       ##      #    #   ##     ####  ### ## ###### ##   #  
                                                   ++++#+######++######+##+++                                                      
"
$script_wrongRom = "`nYou need the USA ROM in .z64 format!`nSHA-1 must be: $romhash"

###############
# ROM OFFSETS #
###############

$offsetName = 0x20 #OFFSET OF ROM NAME
$offsetPlayer = 0xbe9160 #ONLINE PLAYER MARKER ROM OFFSET | USES EMPTY SPACE
$offsetVersion = $offsetName + $romname.Length

##########
# HELPER #
##########

function useColor ($color){
    process { Write-Host $_ -ForegroundColor $color }
}

########
# VARS #
########

[byte[]]$global:file
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
    InitialDirectory = Get-Location 
}

$patch_Path = ""
$sourceRom_Path = ""
$targetRom_Path = ""

#########
# FUNCS #
#########

function adjustmentCheck
{
    $max_length = $romname.Length + $example_version.Length  

    if ($max_length -gt 20) #20 MAX     
    {
        Write-Output "`nROM NAME SET TOO LONG! MAX: 20 CHARACTERS!`n" | useColor Red
        pause
        exit #ABORT
    }
}

function isTargetRomCheck
{
    $string = ""

    if ($global:file -ne $null)#($global:file.Length > 0) #$global:file != null  && 
    {
        For ($i=0; $i -le $romname.Length -1; $i++) 
        {
            $string += [char]$global:file[$offsetName + $i]
        }

        $romname -eq $string

        if ($romname -eq $string)
        {
            return 1
        }
    }

    return 0
}

function getTargetRomVersion
{
    $string = ""

    For ($i=0; $i -lt $example_version.Length; $i++) 
    {
        if ([char]$global:file[$offsetVersion + $i])
        {
            $string += [char]$global:file[$offsetVersion + $i]
        }
    }

    return $string
}

function patchROM
{
    #OPEN PATCH
    $FileBrowser.Filter = 'Patch (*.bps)|*.bps'
    Write-Output "`nSelect $romname Patch..."

    $patch_Name = ""
    while(1)
    {
        if ($FileBrowser.ShowDialog() -ne "Cancel") 
        {
            $patch_Path = $FileBrowser.FileName #Split-Path -Parent $FileBrowser.FileName
            $FileBrowser.SafeFileName -match '^[\w]*'
            $patch_Name = $matches[0]  
            break
        } 
    }

    #OPEN ORIGINAL ROM
    $FileBrowser.Filter = 'N64 ROM (*.z64)|*.z64'
    Write-Output "`nSelect $romname original ROM..."

    while(1)
    {
        if ($FileBrowser.ShowDialog() -ne "Cancel") 
        {
            $sourceRom_Path = $FileBrowser.FileName
            $FileHash = Get-FileHash -Algorithm SHA1 $sourceRom_Path

            if ($FileHash.Hash -eq $romhash)
            {
                break
            }
            else
            {
                Write-Output "Wrong ROM!" | useColor Red
                Write-Output $script_wrongRom 
            } 
        } 
    }

    #CREATE ROM
    Write-Output "True"
    Write-Output "`nCreating $romname ROM..."
    $targetRom_Path = "$PSScriptRoot\$patch_Name.z64"
    cmd.exe /c "Flips\flips --apply $patch_Path $sourceRom_Path $targetRom_Path"

    #RENAME ROM
    $global:file = Get-Content $targetRom_Path -Encoding Byte -Raw

    if (isTargetRomCheck)
    {
        Write-Output "`nRenaming $romname ROM..."
        $version = getTargetRomVersion
        Rename-Item -Path $targetRom_Path -NewName "$romname($version).z64"
        $targetRom_Path = "$PSScriptRoot\$romname($version).z64"

        Write-Output "`n$romname successfully patched :)" | useColor Green
    }
    else
    {
        Write-Output "`nROM successfully patched :)" | useColor Green
    }
}

function generateMpROMS
{
    Write-Output "`nCreating Multiplayer ROMS..."
    
    $isTargetRom = isTargetRomCheck
    
    if ($isTargetRom) #ROM PREVIOUSLY PATCHED -> ALL DATA SET
    {       
        #GET ROM VERSION
        $version = getTargetRomVersion

        #CREATE MP ROMS
        For ($i=0; $i -le 3; $i++) 
        {
            $player = $i + 1

            $global:file[$offsetPlayer] = 0x00
            $global:file[$offsetPlayer +1] = $i
            [IO.File]::WriteAllBytes("$PSScriptRoot\$romname($version)_P$player.z64", $global:file) #USE IO, Set-Content takes forever
        
            Write-Output "P$player ROM Done!"
        }

        Write-Output "`nMultiplayer ROMS successfully created :)" | useColor Green
    }
    else #USER DIALOGS NEEDED
    {
        #OPEN ROM
        $FileBrowser.Filter = 'N64 ROM (*.z64)|*.z64'
        Write-Output "`nSelect $romname ROM!"

        #$path = ""
        while($isTargetRom -eq 0)
        {

            if ($FileBrowser.ShowDialog() -ne "Cancel") 
            {
                #READ FILE WHOLE/RAW
                Write-Output "`nReading ROM..."
                $global:file = Get-Content $FileBrowser.FileName -Encoding Byte -Raw

                #CHECK ROM
                $isTargetRom = isTargetRomCheck

                if ($isTargetRom -eq 0)
                {
                    Write-Output "`nSelected ROM is not $romname!`n" | useColor Red
                }
            } 
        }

        Write-Output "`n$romname found" | useColor Green

        #GET ROM VERSION
        $version = getTargetRomVersion

        #CREATE MP ROMS
        For ($i=0; $i -le 3; $i++) 
        {
            $player = $i + 1

            $global:file[$offsetPlayer] = $i
            [IO.File]::WriteAllBytes("$PSScriptRoot\$romname($version)_P$player.z64", $global:file) #USE IO, Set-Content takes forever
        
            Write-Output "P$player ROM Done!"
        }

        Write-Output "`nMultiplayer ROMS successfully created :)" | useColor Green
    }
}

function showMenu
{
    Write-Output $script_header

    Write-Output "`nWhat do you want to do?`n
    1: Patch ROM + generate Multiplayer ROMS
    2: Patch ROM
    3: Generate Multiplayer ROMS (needs patched ROM)"

    $choice = Read-Host -Prompt "`nChoose"

    switch ($choice)                         
    {                        
        1 {patchROM 
           generateMpROMS}                        
        2 {patchROM}                        
        3 {generateMpROMS}                                                
        Default {"`nWrong choice! Try again!" | useColor Red}                        
    }    
}

####### 
# RUN #
#######

adjustmentCheck

while(1)
{
    showMenu
    pause
}
