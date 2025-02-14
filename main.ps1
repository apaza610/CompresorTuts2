Add-Type -AssemblyName System.Windows.Forms

$miFormulario = New-Object System.Windows.Forms.Form
$miFormulario.Text = "Compresor de videos"
$miFormulario.Size = New-Object System.Drawing.Size(300,190)

$miLabel = New-Object System.Windows.Forms.Label
$miLabel.Location = New-Object System.Drawing.Point(10,10)
$miLabel.Size = New-Object System.Drawing.Size(200,20)
$miLabel.Text = "Carpeta de videos a editar"

$miCajaTexto = New-Object System.Windows.Forms.TextBox
$miCajaTexto.Location = New-Object System.Drawing.Point(10,30)
$miCajaTexto.Size = New-Object System.Drawing.Size(200,20)

$miGroupBox = New-Object System.Windows.Forms.GroupBox
$radioButtonCompresion = New-Object System.Windows.Forms.RadioButton
$radioButtonCompresion.Text = "Comprime"
$radioButtonCompresion.Checked = $true
$radioButtonRedimension = New-Object System.Windows.Forms.RadioButton
$radioButtonRedimension.Text = "Resize+Compr"
$miGroupBox.Controls.AddRange(($radioButtonCompresion, $radioButtonRedimension))
$miGroupBox.Location = New-Object System.Drawing.Point(10,60)
$radioButtonCompresion.Location = New-Object System.Drawing.Point(10,10)
$radioButtonRedimension.Location = New-Object System.Drawing.Point(115,10)
$miGroupBox.Size = New-Object System.Drawing.Size(260,40)

$miBoton = New-Object System.Windows.Forms.Button
$miBoton.Location = New-Object System.Drawing.Point(10,110)
$miBoton.Size = New-Object System.Drawing.Size(100,20)
$miBoton.Text = "Procesar"
$miBoton.Add_Click({
    $inputFolder = $miCajaTexto.Text
    $outputFolder = Join-Path $inputFolder "salida\"

    if(!(Test-Path $outputFolder)){
        New-Item -ItemType Directory -Path $outputFolder | Out-Null
    }

    Get-ChildItem -Path $inputFolder -Filter *.mp4 | ForEach-Object{
        $inputFile = $_.FullName
        $outputFile = Join-Path $outputFolder $_.Name

        Write-Output "Procesando file: $inputFile"

        if($radioButtonCompresion.Checked){
            ffmpeg -i $inputFile -c:v libx265 -crf 28 -preset medium -c:a copy $outputFile
        }else {
            ffmpeg -i $inputFile -c:v libx265 -crf 28 -preset medium -vf "scale=1280:720" -c:a copy $outputFile
        }

        [System.Media.SystemSounds]::Exclamation.Play()
    }
})

$miFormulario.Controls.Add($miCajaTexto)
$miFormulario.Controls.Add($miLabel)
$miFormulario.Controls.Add($miBoton)
$miFormulario.Controls.Add($miGroupBox)
$miFormulario.ShowDialog()