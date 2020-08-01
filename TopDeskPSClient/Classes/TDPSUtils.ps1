class TDPSUtils {

    static [string] ExporttdpsObject([string]$FilePath, [psobject]$ExportObject) {
        $_stream = [System.IO.FileStream]::Null
        [System.Runtime.Serialization.IFormatter] $_formatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
        try {
            [System.IO.Path]::ChangeExtension($FilePath,'bin')
            $_stream = [System.IO.FileStream]::new($FilePath, [System.IO.FileMode]::Create, [System.IO.FileAccess]::Write, [System.IO.FileShare]::None)
            $_formatter.Serialize($_stream, $ExportObject)
            $_stream.Close()
            $_xh = (Get-FileHash -Path $FilePath -Algorithm SHA512).Hash
            $_stream = [System.IO.FileStream]::new($($FilePath.Replace('.bin','_.bin')), [System.IO.FileMode]::Create, [System.IO.FileAccess]::write, [System.IO.FileShare]::None)
            $_formatter.Serialize($_stream, $_xh)
            $_stream.Close()
            return (Get-Item -LiteralPath $FilePath).FullName
        }
        catch {
            $thiserror = $_
            if ($null -ne $_stream) { $_stream.Close() }
            $PSCmdlet.ThrowTerminatingError($thiserror)
            return $thiserror
        }
    }

    static [psobject] ImporttdpsObject([string]$FilePath) {
        $_stream = [System.IO.FileStream]::Null
        [System.Runtime.Serialization.IFormatter] $_formatter = New-Object System.Runtime.Serialization.Formatters.Binary.BinaryFormatter
        try {
            [System.IO.Path]::ChangeExtension($FilePath,'bin')
            $_stream = [System.IO.FileStream]::new($($FilePath.Replace('.bin','_.bin')), [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
            $_xh = ($_formatter.Deserialize($_stream))
            $_stream.Close()
            $_ih = (Get-FileHash -Path $FilePath -Algorithm SHA512).Hash
            if($_xh -eq $_ih) {
                $_stream = [System.IO.FileStream]::new($FilePath, [System.IO.FileMode]::Open, [System.IO.FileAccess]::Read, [System.IO.FileShare]::Read)
                $returnval = $_formatter.Deserialize($_stream)
                $_stream.Close()
                return $returnval
            }
            else {
                $_Name = Split-Path -Path $FilePath -Leaf
                return [PSCustomObject]@{
                    Name = $_Name
                    Status = -2
                }
            }
        }
        catch {
            $thiserror = $_
            if ($null -ne $_stream) { $_stream.Close() }
            $PSCmdlet.ThrowTerminatingError($thiserror)
            return $thiserror
        }
    }
}