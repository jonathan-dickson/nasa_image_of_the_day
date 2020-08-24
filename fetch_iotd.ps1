Function Set-WallPaper($Image) {
    <#
     
        .SYNOPSIS
        Applies a specified wallpaper to the current user's desktop
        
        .PARAMETER Image
        Provide the exact path to the image
      
        .EXAMPLE
        Set-WallPaper -Image "C:\Wallpaper\Default.jpg"
      
    #>
      
    Add-Type -TypeDefinition @'
    using System; 
    using System.Runtime.InteropServices;
      
    public class Params
    { 
        [DllImport("User32.dll",CharSet=CharSet.Unicode)] 
        public static extern int SystemParametersInfo (Int32 uAction, 
                                                       Int32 uParam, 
                                                       String lpvParam, 
                                                       Int32 fuWinIni);
    }
'@

    $SPI_SETDESKWALLPAPER = 0x0014
    $UpdateIniFile = 0x01
    $SendChangeEvent = 0x02
    
    $fWinIni = $UpdateIniFile -bor $SendChangeEvent
    
    $ret = [Params]::SystemParametersInfo($SPI_SETDESKWALLPAPER, 0, $Image, $fWinIni)
     
}


# This is the API from NASA.
# Check out all of their open APIs: https://api.nasa.gov/api.html  
Function Download-And-Save {
    <#
    .SYNOPSIS
    This function will call the public API on NASA to fetch the image of the day, and save it to  %USERPROFILE%\OneDrive\Pictures\NASA

    .RETURN
    Returns the absolute path to the image that was saved.
    #>

    $request     ="https://api.nasa.gov/planetary/apod?api_key=DEMO_KEY"
    $user_image_path  ="$env:USERPROFILE\OneDrive\Pictures\NASA"
    
    $apiresponse =Invoke-WebRequest $request | ConvertFrom-Json | Select hdurl, title
    
    $title       =$apiresponse.title -replace ':',''
    $hdurl       =$apiresponse.hdurl
    $image_absolute_path   ="$user_image_path\$title.jpg"

    # The path is pretty standard, just change it if you want
    Invoke-WebRequest $hdurl.toString() -OutFile $image_absolute_path

    return $image_absolute_path
}

$image_path = Download-And-Save
Set-WallPaper -Image $image_path

<#
# set the wallpaper
Set-ItemProperty -path 'HKCU:\Control Panel\Desktop\' -name wallpaper -value "$image_path\$title.jpg"
# Refresh the user properties.
RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True
#>