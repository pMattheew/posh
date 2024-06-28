function ConvertTo-Hashtable {
    param (
        [Parameter(ValueFromPipeline = $true, Mandatory = $true)]
        $InputObject
    )

    $outputHash = @{}
    $InputObject.PSObject.Properties | ForEach-Object {
        $outputHash[$_.Name] = $_.Value
    }

    return $outputHash
}

function ConvertTo-SnakeCase {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [object] $obj
    )

    if ($obj -is [pscustomobject]) {
        $obj = ConvertTo-Hashtable $obj
    }

    if ($obj -is [string]) {
        return ([regex]::replace($obj, '(?<=.)(?=[A-Z])', '_')).ToLower()
    }
    elseif ($obj -is [hashtable]) {
        $output = @{}
        foreach ($key in $obj.Keys) {
            $snakeKey = ConvertTo-SnakeCase $key
            $output[$snakeKey] = $obj[$key]
        }
        return $output
    }
    elseif ($obj -is [object[]]) {
        $result = @()
        foreach ($o in $obj) {
            $result += ConvertTo-SnakeCase $o
        }
        return $result
    }
}

filter ConvertTo-EnumsAsStrings ([int] $Depth = 2, [int] $CurrDepth = 0) {
    if ($_ -is [enum]) {
        # enum value -> convert to symbolic name as string
        $_.ToString() 
    }
    elseif ($null -eq $_ -or $_.GetType().IsPrimitive -or $_ -is [string] -or $_ -is [decimal] -or $_ -is [datetime] -or $_ -is [datetimeoffset]) {
        $_
    }
    elseif ($_ -is [Collections.IEnumerable] -and $_ -isnot [Collections.IDictionary]) {
        # enumerable (other than a dictionary)
        , ($_ | ConvertTo-EnumsAsStrings -Depth $Depth -CurrDepth ($CurrDepth + 1))
    }
    else {
        # non-primitive type or dictionary (hashtable) -> recurse on properties / entries
        if ($CurrDepth -gt $Depth) {
            # depth exceeded -> return .ToString() representation
            Write-Warning "Recursion depth $Depth exceeded - reverting to .ToString() representations."
            "$_"
        }
        else {
            $oht = [ordered] @{}
            foreach ($prop in $(if ($_ -is [Collections.IDictionary]) { $_.GetEnumerator() } else { $_.psobject.properties })) {
                if ($prop.Value -is [Collections.IEnumerable] -and $prop.Value -isnot [Collections.IDictionary] -and $prop.Value -isnot [string]) {
                    $oht[$prop.Name] = @($prop.Value | ConvertTo-EnumsAsStrings -Depth $Depth -CurrDepth ($CurrDepth + 1))
                }
                else {      
                    $oht[$prop.Name] = $prop.Value | ConvertTo-EnumsAsStrings -Depth $Depth -CurrDepth ($CurrDepth + 1)
                }
            }
            $oht
        }
    }
}