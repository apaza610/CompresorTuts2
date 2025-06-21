Add-Type -AssemblyName System.Windows.Forms

$miFormulario = New-Object System.Windows.Forms.Form
$miFormulario.Text = "CompresorDeVideos"
$miFormulario.Size = New-Object System.Drawing.Size(300,200)

$labelFolderPath = New-Object System.Windows.Forms.Label
$labelFolderPath.Location = New-Object System.Drawing.Point(10,10)
$labelFolderPath.Size = New-Object System.Drawing.Size(63,20)
$labelFolderPath.Text = "FolderPath"

$textboxFolderPath = New-Object System.Windows.Forms.TextBox
$textboxFolderPath.Location = New-Object System.Drawing.Point(80,10)
$textboxFolderPath.Size = New-Object System.Drawing.Size(180,20)
$textboxFolderPath.Text = "E:\win\Videos\"

#----------------------------------------------------------------------
$groupbox2 = New-Object System.Windows.Forms.GroupBox

# $checkboxCompress = New-Object System.Windows.Forms.CheckBox
# $checkboxCompress.Text = "Coooooompress"
# $checkboxCompress.Checked = $true
# $checkboxCompress.Location = New-Object System.Drawing.Point(10,10)
# $checkboxCompress.Size = New-Object System.Drawing.Size(80,20)

$checkboxResize = New-Object System.Windows.Forms.CheckBox
$checkboxResize.Text = "720p"
$checkboxResize.Location = New-Object System.Drawing.Point(100,10)
$checkboxResize.Size = New-Object System.Drawing.Size(80,20)

$checkboxSpeed = New-Object System.Windows.Forms.CheckBox
$checkboxSpeed.Text = "Speed"
$checkboxSpeed.Location = New-Object System.Drawing.Point(180,10)
$checkboxSpeed.Size = New-Object System.Drawing.Size(80,20)
$checkboxSpeed.Add_Click({
    $textboxSpeed.Visible = !$textboxSpeed.Visible
})

$groupbox2.Controls.AddRange($checkboxCompress, $checkboxResize, $checkboxSpeed)
$groupbox2.Location = New-Object System.Drawing.Point(10,40)
$groupbox2.Size = New-Object System.Drawing.Size(260,40)
#----------------------------------------------------------------------

#----------------------------------------------------------------------
$groupbox3 = New-Object System.Windows.Forms.GroupBox
# $radioButtonCompresion = New-Object System.Windows.Forms.RadioButton
# $radioButtonCompresion.Text = "Comprime"
# $radioButtonCompresion.Checked = $true
# $radioButtonRedimension = New-Object System.Windows.Forms.RadioButton
# $radioButtonRedimension.Text = "Resize+Compr"
# $radioButtonCompresion.Location = New-Object System.Drawing.Point(10,10)
# $radioButtonRedimension.Location = New-Object System.Drawing.Point(115,10)

$labelSpeed = New-Object System.Windows.Forms.Label
$labelSpeed.Text = "Desired Speed:"
$labelSpeed.Location = New-Object System.Drawing.Point(10,10)
$labelSpeed.Size = New-Object System.Drawing.Size(100,20)

$textboxSpeed = New-Object System.Windows.Forms.TextBox
$textboxSpeed.Text = "1.0"
$textboxSpeed.Location = New-Object System.Drawing.Point(120,10)
$textboxSpeed.Size = New-Object System.Drawing.Size(80,20)
$textboxSpeed.Visible = $false

$groupbox3.Controls.AddRange($labelSpeed, $textboxSpeed)
$groupbox3.Location = New-Object System.Drawing.Point(10,80)
$groupbox3.Size = New-Object System.Drawing.Size(260,40)
#----------------------------------------------------------------------

$labelMensaje = New-Object System.Windows.Forms.Label
$labelMensaje.Location = New-Object System.Drawing.Point(10,140)
$labelMensaje.Size = New-Object System.Drawing.Size(60,20)
$labelMensaje.Text = "....."

$miBoton = New-Object System.Windows.Forms.Button
$miBoton.Location = New-Object System.Drawing.Point(10,110)
$miBoton.Size = New-Object System.Drawing.Size(100,30)
$miBoton.Text = "Procesar"
$miBoton.Add_Click({
    $inputFolder = $textboxFolderPath.Text
    $outputFolder = Join-Path $inputFolder "salida\"
    
    if(!(Test-Path $outputFolder)){
        New-Item -ItemType Directory -Path $outputFolder | Out-Null
    }


    Get-ChildItem -Path $inputFolder -Filter *.mp4 | ForEach-Object{
        $inputFile = $_.FullName
        $outputFile = Join-Path $outputFolder $_.Name

        $labelMensaje.Text = "....."
        Write-Output "Procesando file: $inputFile"

        $rapidez = $textboxSpeed.Text
        # ffmpeg -i $inputFile -c:v libx265 -crf 28 -preset medium -vf "scale=1280:720" -c:a copy $outputFile
        # $ffmpegCommand = "ffmpeg -i $inputFile -vf `"scale=1280:720,setpts=PTS/1.4`" -af `"atempo=1.4`" -c:v libx265 -crf 28 -preset medium -c:a aac -b:a 128k $outputFile"
        $ffmpegCommand = "ffmpeg -i $inputFile -vf `"scale=1920:1080,setpts=PTS/$rapidez`" -af `"atempo=$rapidez`" -c:v libx265 -crf 28 -preset medium -c:a aac -b:a 128k $outputFile"

        # if($checkboxCompress.Checked -eq $false){
        #     # $ffmpegCommand = $ffmpegCommand.Replace(" -crf 28 -preset medium", "")
        #     $ffmpegCommand = $ffmpegCommand.Replace(" -vf `"scale=1280:720,setpts=PTS/$rapidez`" -af `"atempo=$rapidez`"", "")
        # }
        if($checkboxResize.Checked -eq $true){
            $ffmpegCommand = $ffmpegCommand.Replace("scale=1920:1080,","scale=1280:720,")
        }
        if($checkboxSpeed.Checked -eq $false){
            $ffmpegCommand = $ffmpegCommand.Replace(",setpts=PTS/$rapidez`" -af `"atempo=$rapidez", "")
        }
        Invoke-Expression $ffmpegCommand
    }
    [System.Media.SystemSounds]::Exclamation.Play()
    # Show popup message
    # [System.Windows.Forms.MessageBox]::Show($ffmpegCommand, "Información", [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Information)
    # $ffmpegCommand | Set-Clipboard
    $labelMensaje.Text = "termino..."
})

$miBoton.Location = New-Object System.Drawing.Point(160,130)

$miFormulario.Controls.Add($labelFolderPath)
$miFormulario.Controls.Add($textboxFolderPath)
$miFormulario.Controls.Add($groupbox2)
$miFormulario.Controls.Add($groupbox3)
$miFormulario.Controls.Add($labelMensaje)
$miFormulario.Controls.Add($miBoton)
$miFormulario.ShowDialog()