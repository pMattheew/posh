function Add-Property {
    param(
        [PSCustomObject] $obj,
        [string] $name,
        [object] $value
    )

    Add-Member -InputObject $obj -MemberType NoteProperty -Name $name -Value $value
}

function Add-Method {
    param(
        [PSCustomObject] $obj,
        [string] $name,
        [scriptblock] $value
    )
    Add-Member -InputObject $obj -MemberType ScriptMethod -Name $name -Value $value
}

function Wait-Task {
    param (
        [Parameter(ValueFromPipeline=$true, Mandatory=$true)]
        $task
    )

    process {
        while (-not $task.AsyncWaitHandle.WaitOne(200)) { }
        $task.GetAwaiter().GetResult()
    }
}