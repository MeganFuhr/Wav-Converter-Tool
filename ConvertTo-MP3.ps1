#region XAML Form
$grid = @"
        <Button Name="buttonBrowse" Content="Browse" HorizontalAlignment="Left" Margin="14,44,0,0" VerticalAlignment="Top" Width="89" Height="30"/>
        <Label Name="labelBrowse" Content="Browse to a WAV file to convert to MP3." HorizontalAlignment="Left" Margin="14,10,0,0" VerticalAlignment="Top" Width="235"/>
        <TextBox Name="textBoxBrowse" HorizontalAlignment="Left" Height="22" Margin="118,48,0,0" TextWrapping="Wrap" Text="" VerticalAlignment="Top" Width="323"/>
        <Button Name="buttonConvert" Content="Converto MP3" HorizontalAlignment="Left" Margin="118,79,0,0" VerticalAlignment="Top" Width="323" Height="32"/>
"@

$xaml_form = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
            xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
            xmlns:d="http://schemas.microsoft.com/expression/blend/2008"
            xmlns:mc="http://schemas.openxmlformats.org/markup-compatibility/2006"
            Title="Convert WAV to MP3" Height="149.899" Width="457.093" ResizeMode="NoResize">
        <Grid>
            $($grid)
        </Grid>
    </Window>
"@
#endregion XAML Form

#region XAML Render
$xamlPath = $xaml_Form
function xaml_render {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory=$True,Position=1)]
        [string]$xamlPath
    )

    [xml]$global:xmlWPF=$xamlPath

    try {
        Add-Type -AssemblyName PresentationCore,PresentationFramework,WindowsBase,system.windows.forms
    }
    catch {
        Throw "Failed to load Windows Presentation Framework assemblies."
    }

    $Global:xamGUI = [Windows.Markup.XamlReader]::Load((New-Object System.Xml.XmlNodeReader $xmlWPF))
    
    $xmlWPF.SelectNodes("//*[@Name]") | % {Set-Variable -Name ($_.Name) -Value $xamGUI.FindName($_.name) -Scope Global}
}

xaml_Render -xamlPath $xamlPath
#endregion XAML Render

$global:text = ""

function Update-Form{
    $textboxBrowse.Text = $FileBrowser.FileName
}

function ConvertTo-MP3 {
    $args = "-i $($textBoxBrowse.Text) $($textBoxBrowse.text.Replace('wav','mp3'))"
    Start-Process .\ffmpeg.exe "-i $($textBoxBrowse.Text) $($textBoxBrowse.text.Replace('wav','mp3'))"
    
}

#region Activities
$buttonBrowse.add_click({
    $FileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{ InitialDirectory = "$env:userprofile\Documents\" }
    $FileBrowser.ShowDialog() | Out-Null
    Update-Form    
})

$buttonConvert.add_click({
    ConvertTo-MP3  
})
#endregion Activities


#region Display GUI
$xamGUI.ShowDialog() | Out-Null
#endregion Display GUI