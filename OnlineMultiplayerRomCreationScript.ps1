Add-Type -AssemblyName System.Windows.Forms

##########
# ADJUST #
##########

$romname = "MK64-HootingTime" #YOUR ROM NAME WITHOUT VERSION
$example_version = "1.40" #VERSION EXAMPLE (ONLY RELEVANT FOR MAX LENGTH CHECK)
    
$success_message = "Have a Hooting Time!" #SUCCESS MESSAGE OF THE SCRIPT

##########
# HELPER #
##########

function Red
{
    process { Write-Host $_ -ForegroundColor Red }
}

function Green
{
    process { Write-Host $_ -ForegroundColor Green }
}

################### 
# ADUSTMENT CHECK #
###################

$romname_length = $romname.Length
$version_length = $example_version.Length  
$max_length = $romname_length + $version_length 

if ($max_length -gt 20)     
{
    Write-Output "`nROM NAME SET TOO LONG! MAX: 20 CHARACTERS!`n" | Red
    pause
    exit
}

###############
# ROM OFFSETS #
###############

$offsetName = 0x20 #OFFSET OF ROM NAME
$offsetPlayer = 0xbe9160 #ONLINE PLAYER MARKER ROM OFFSET | USES EMPTY SPACE
$offsetVersion = $offsetName + $romname.Length

########
# CODE #
########

#OPEN & CHECK ROM
Write-Output "`nSelect $romname ROM!"

$string = ""
$path = ""
while($romname -ne $string)
{
    #OPEN USER FILE DIALOG
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ 
        InitialDirectory = [Environment]::GetFolderPath('Desktop') 
        Filter = 'N64 ROM (*.z64)|*.z64'
    }

    if ($FileBrowser.ShowDialog() -ne "Cancel") 
    {
        $path = Split-Path -Parent $FileBrowser.FileName

        #READ FILE WHOLE/RAW
        Write-Output "`nReading ROM..."
        [byte[]]$file = Get-Content $FileBrowser.FileName -Encoding Byte -Raw


        #CHECK ROM
        $string = ""
        For ($i=0; $i -le 15; $i++) 
        {
            $string += [char]$file[$offsetName + $i]
        }

        if ($romname -ne $string)
        {
            Write-Output "`nSelected ROM is not $romname!`n" | Red
        }
    } 
}

Write-Output "`n$romname found" | Green

#GET ROM VERSION
$version = ""
For ($i=0; $i -lt $version_length; $i++) 
{
    if ([char]$file[$offsetVersion + $i])
    {
        $version += [char]$file[$offsetVersion + $i]
    }
}


#CREATE MP ROMS
For ($i=0; $i -le 3; $i++) 
{
    $player = $i + 1

    Write-Output "`nCreating P$player ROM..."
    $file[$offsetPlayer] = $i
    [IO.File]::WriteAllBytes("$path\$romname($version)_P$player.z64", $file) #USE IO, Set-Content takes forever
}


Write-Output "`nDone! $success_message" | Green
