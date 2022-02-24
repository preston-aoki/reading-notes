param(
    [Parameter(Mandatory=$true)][string]$directory,
    [switch]$excludeRhino = $false,
    [switch]$excludeCad = $false
)

# Helper print functions in case i want them later
function Debug($msg) {
    Write-Host "$msg" -ForegroundColor cyan
}

function Warn($msg) {
    Write-Host "$msg" -ForegroundColor DarkMagenta
}

function Error($msg) {
    Write-Host "$msg" -ForegroundColor Red
}

# Idiot-proof info
if ($null -eq $directory) {
    Warn "you must supply a fully-qualified folder path"
}

# declare valid extensions
function getValidExtensions{
    $validExtensions = @()
    $cadExtensions = @(".dwg", ".model", ".prt", ".asm", ".ipt", ".iam", ".dgn", ".sldprt", ".sldasm")
    $rhinoExtensions = @(".3dm", ".3dmbak", ".3ds", ".rws", ".3mf", ".amf", ".sat", ".ai", ".dwg", ".dxf", ".dae", ".cd", ".svg")
    
    if ($excludeRhino -ne $true){
        $validExtensions += $rhinoExtensions
    }
    
    if ($excludeCad -ne $true){
        $validExtensions += $cadExtensions
    }
    
    return $validExtensions
}

# the actual logic
function touchFile($path) {
    # get a list of valid files based on file extension
    $validExtensions = (getValidExtensions)
    
    # early termination if all excluded
    if ($validExtensions.Length -lt 1) {
        Error "All file types excluded. Nothing to update."
        exit
    }
    
    $files = Get-ChildItem -Path $path -File | Where-Object{$validExtensions.Contains($_.Extension)}
    
    # select a random number of the files to "work" on
    $iterations = Get-Random -Minimum 1 -Maximum $files.Length
    
    for ($i=0; $i -lt $iterations; $i++) {
        # random offsets so the files don't all look like they were touched at the same time
        $minOffset = (Get-Random -Minimum 0 -Maximum 30)
        $secOffset = (Get-Random -Minimum 0 -Maximum 36)
        
        # pick a random file from the list of valid files
        $file = (Get-Random -InputObject $files)
        
        # update only to a LastWriteTime that is later than the current so Dropbox sync triggers
        $currentWriteTime = $file.LastWriteTime;
        $newTime = ((Get-Date).AddMinutes(-$minOffset).AddSeconds(-$secOffset));
        
        if ($newTime -gt $currentWriteTime) {
            $file.LastWriteTime = ((Get-Date).AddMinutes(-$minOffset).AddSeconds(-$secOffset))
        }
        else {
            Debug "$($file.Name) ->  proposed time ($newTime) older than current file time ($currentWriteTime). skipping..."
        }
    }
}

# call the thing
touchFile $directory
