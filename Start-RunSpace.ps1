function Start-RunSpace {
    [CmdletBinding()]
    param (
        [scriptblock]$ScriptBlock,
        $syncHash,
        $Functions,
        $Arguments = $null
    )
        
    begin {
            
        $Scope = [System.Management.Automation.ScopedItemOptions]::AllScope
        $InitialSessionState = [System.Management.Automation.Runspaces.InitialSessionState]::CreateDefault()
        foreach ($Function in $Functions) {
            $FunctionName = $Function.Split('\')[1]
            $FunctionDefinition = Get-Content $Function -ErrorAction Stop
            $SessionStateFunction = New-Object -TypeName System.Management.Automation.Runspaces.SessionStateFunctionEntry -ArgumentList $FunctionName, $FunctionDefinition, $Scope, $null
            $InitialSessionState.Commands.Add($SessionStateFunction)
        }
        $Runspace = [runspacefactory]::CreateRunspace($InitialSessionState)
        $Runspace.ApartmentState = "STA"
        $Runspace.ThreadOptions = "ReuseThread"
        #$Runspace = [runspacefactory]::CreateRunspace($InitialSessionState)
        $Runspace.Open()
        $Runspace.SessionStateProxy.SetVariable("syncHash", $syncHash)
        $PowerShell = [powershell]::Create()
        $PowerShell.AddScript($ScriptBlock)
        $PowerShell.Runspace = $Runspace
        foreach ($Argument in $Arguments) {
            $PowerShell.AddArgument($Argument)
        }
    }
        
    process {
        # Start
        $PowerShell.BeginInvoke()
    }

    end {
        Register-ObjectEvent -InputObject $Runspace -EventName AvailabilityChanged -Action {
            Unregister-Event $EventSubscriber.SourceIdentifier # Self remove event
            Remove-Job $EventSubscriber.SourceIdentifier # self remove Event Job
            $MyRunSpace = Get-Runspace -id $event.SourceArgs.id # Get current Runspace (Param : InputObject)
            # If Runspace State is Closing or Busy, Dispose, Can't remove this runspace
            if (-Not ($Runspace.RunspaceStateInfo -eq "closing") -OR -Not ($runspace.RunspaceAvailability -eq "busy")) {
                $MyRunSpace.Close() # Close $this runspace
                $MyRunSpace.Dispose() # Dispose $this Runspace
            }
        }
        
    }
}
