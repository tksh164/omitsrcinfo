[CmdletBinding()]
param (
    [Parameter(Mandatory = $true)]
    [string] $TargetPath
)

function ConvertTo-SuppressedLog
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [string] $Line
    )

    begin {}

    process
    {
        if ($Line.StartsWith('Unknown('))
        {
            $Line
        }
        else
        {
            $parts = $Line -split ' ', 6, 'SimpleMatch'

            # Omit the source file name, line number and function name.
            $suppressedLineParts = $parts[0..2]
            $suppressedLineParts += $parts[5]
            $suppressedLine = $suppressedLineParts -join ' '

            $suppressedLine
        }
    }

    end {}
}

function ConvertTo-SuppressedLogFile
{
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [IO.FileInfo] $LogFile
    )

    begin {}

    process
    {
        Write-Verbose -Message $LogFile.FullName

        $outputFilePath = $LogFile.FullName + '.txt'

        Set-Content -LiteralPath $outputFilePath -Value '' -NoNewline

        Get-Content -LiteralPath $LogFile.FullName -ReadCount 1 |
            ConvertTo-SuppressedLog |
            Add-Content -LiteralPath $outputFilePath -Encoding UTF8
    }

    end {}
}


if (Test-Path -PathType Container -LiteralPath $TargetPath)
{
    Get-ChildItem -File -Path $TargetPath -Filter '*.log' |
        ConvertTo-SuppressedLogFile
}
else
{
    Get-Item -LiteralPath $TargetPath |
        ConvertTo-SuppressedLogFile
}
