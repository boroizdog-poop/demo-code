param([string[]]$Only = @())
$ErrorActionPreference = 'Stop'
Add-Type -AssemblyName System.Drawing
$catalog = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'danh-sach.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$syntax = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'mau-cu-phap.json') -Raw -Encoding UTF8 | ConvertFrom-Json
$syntaxBrushes = @{}
$width = 2200
$lineHeight = 44
$maxRows = 26
$codeFont = New-Object Drawing.Font('Consolas',32,[Drawing.FontStyle]::Regular,[Drawing.GraphicsUnit]::Pixel)
$titleFont = New-Object Drawing.Font('Segoe UI',40,[Drawing.FontStyle]::Bold,[Drawing.GraphicsUnit]::Pixel)
$labelFont = New-Object Drawing.Font('Segoe UI',25,[Drawing.FontStyle]::Regular,[Drawing.GraphicsUnit]::Pixel)
$smallFont = New-Object Drawing.Font('Segoe UI',22,[Drawing.FontStyle]::Regular,[Drawing.GraphicsUnit]::Pixel)
$bodyBrush = New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml('#eeeeee'))
$mutedBrush = New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml('#a3a3a3'))
$headerBrush = New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml('#193b37'))
$gutterBrush = New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml('#181818'))
$format = [Drawing.StringFormat]::GenericTypographic.Clone()
$format.FormatFlags = $format.FormatFlags -bor [Drawing.StringFormatFlags]::MeasureTrailingSpaces
$probe = New-Object Drawing.Bitmap(20,20)
$probeGraphics = [Drawing.Graphics]::FromImage($probe)
$charWidth = $probeGraphics.MeasureString('M',$codeFont,1000,$format).Width
$columns = [int][Math]::Floor(($width - 180) / $charWidth) - 2
$probeGraphics.Dispose(); $probe.Dispose()
$measureBitmap = New-Object Drawing.Bitmap(20,20)
$measureGraphics = [Drawing.Graphics]::FromImage($measureBitmap)
$outputItems = @()
if ($Only.Count -gt 0 -and (Test-Path -LiteralPath (Join-Path $PSScriptRoot 'anh-da-tao.json'))) {
    $previousItems = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'anh-da-tao.json') -Raw -Encoding UTF8 | ConvertFrom-Json
    $outputItems = @($previousItems | Where-Object { $_.id -notin $Only })
}
foreach ($item in $catalog.items) {
    if ($Only.Count -gt 0 -and $item.id -notin $Only) { continue }
    $source = [IO.File]::ReadAllText((Join-Path $PSScriptRoot ('trich-doan/'+$item.id+'.txt')))
    $sourceLines = [regex]::Split($source,"`r?`n")
    $rows = New-Object 'Collections.Generic.List[object]'
    for ($index=0; $index -lt $sourceLines.Count; $index++) {
        $line = $sourceLines[$index].Replace("`t",'    ')
        $offset = 0
        do {
            $length = [Math]::Min($columns, $line.Length-$offset)
            if ($length -gt 0 -and $offset+$length -lt $line.Length -and [char]::IsHighSurrogate($line[$offset+$length-1])) { $length-- }
            while ($length -gt 0 -and $measureGraphics.MeasureString($line.Substring($offset,$length),$codeFont,10000,$format).Width -gt $width-180) {
                $length--
                if ($length -gt 0 -and [char]::IsHighSurrogate($line[$offset+$length-1])) { $length-- }
            }
            $chunk = if ($length -gt 0) { $line.Substring($offset,$length) } else { '' }
            $rows.Add([pscustomobject]@{number=$item.start+$index; continuation=($offset -gt 0); text=$chunk; offset=$offset; lineIndex=$index})
            $offset += $length
        } while ($offset -lt $line.Length)
    }
    $pageCount = [int][Math]::Ceiling($rows.Count / $maxRows)
    $pictures = @()
    for ($page=0; $page -lt $pageCount; $page++) {
        $pageRows = @($rows | Select-Object -Skip ($page*$maxRows) -First $maxRows)
        $height = 278 + [Math]::Max(9,$pageRows.Count)*$lineHeight
        $bitmap = New-Object Drawing.Bitmap($width,$height)
        $graphics = [Drawing.Graphics]::FromImage($bitmap)
        $graphics.Clear([Drawing.ColorTranslator]::FromHtml('#101010'))
        $graphics.TextRenderingHint = [Drawing.Text.TextRenderingHint]::AntiAliasGridFit
        $graphics.FillRectangle($headerBrush,0,0,$width,170)
        $graphics.DrawString(('NHÓM '+$item.group+' / '+$item.groupTitle),$labelFont,[Drawing.Brushes]::White,48,22)
        $graphics.DrawString(($item.id+' | '+$item.title),$titleFont,[Drawing.Brushes]::White,48,61)
        $pageLabel = if ($pageCount -gt 1) { ' | Phần '+($page+1)+'/'+$pageCount } else { '' }
        $graphics.DrawString(($item.file+' | Dòng '+$item.start+'–'+$item.end+$pageLabel),$labelFont,[Drawing.Brushes]::White,48,118)
        $graphics.FillRectangle($gutterBrush,24,190,88,($height-278))
        for ($rowIndex=0; $rowIndex -lt $pageRows.Count; $rowIndex++) {
            $row=$pageRows[$rowIndex]; $y=194+$rowIndex*$lineHeight
            $number = if ($row.continuation) { [string]$row.number + '↳' } else { [string]$row.number }
            $graphics.DrawString($number,$codeFont,$mutedBrush,38,$y,$format)
            foreach ($span in $syntax.($item.id)[$row.lineIndex]) {
                $begin=[Math]::Max($row.offset,$span.start)
                $end=[Math]::Min($row.offset+$row.text.Length,$span.start+$span.length)
                if($end -le $begin) { continue }
                $local=$begin-$row.offset
                $prefix=if($local -gt 0){$row.text.Substring(0,$local)}else{''}
                $x=130
                if($prefix.Length){$x+=$graphics.MeasureString($prefix,$codeFont,10000,$format).Width}
                if(!$syntaxBrushes.ContainsKey($span.color)){$syntaxBrushes[$span.color]=New-Object Drawing.SolidBrush([Drawing.ColorTranslator]::FromHtml($span.color))}
                $graphics.DrawString($row.text.Substring($local,$end-$begin),$codeFont,$syntaxBrushes[$span.color],$x,$y,$format)
            }
            if ($graphics.MeasureString($row.text,$codeFont,10000,$format).Width -gt $width-160) { throw ('Code too wide: '+$item.id) }
        }
        $footerY=$height-72
        $graphics.DrawString($item.note,$smallFont,$bodyBrush,48,$footerY)
        $graphics.DrawString('ARTIO · Mã nguồn ngày 16/10/2026 · Dòng dài được ngắt để đọc; ↳ là dòng tiếp nối.',$smallFont,$mutedBrush,48,($footerY+29))
        $name=$item.id+'-'+($page+1).ToString('D2')+'.png'
        $bitmap.Save((Join-Path $PSScriptRoot ('../anh/'+$name)),[Drawing.Imaging.ImageFormat]::Png)
        $pictures+= [pscustomobject]@{file='anh/'+$name; part=$page+1; total=$pageCount; firstLine=$pageRows[0].number; lastLine=$pageRows[-1].number; width=$width; height=$height}
        $graphics.Dispose(); $bitmap.Dispose()
    }
    $outputItems += [pscustomobject]@{id=$item.id; pictures=$pictures}
    Write-Output ($item.id+': '+$pageCount+' ảnh')
}
$outputItems | ConvertTo-Json -Depth 6 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'anh-da-tao.json') -Encoding UTF8
$codeFont.Dispose();$titleFont.Dispose();$labelFont.Dispose();$smallFont.Dispose()
$bodyBrush.Dispose();$mutedBrush.Dispose();$headerBrush.Dispose();$gutterBrush.Dispose();$format.Dispose()
foreach($brush in $syntaxBrushes.Values){$brush.Dispose()}
$measureGraphics.Dispose();$measureBitmap.Dispose()
Write-Output 'Hoàn tất dựng ảnh code.'
