Function Get-TSSessions {

    [CmdletBinding()]   
    Param
    (
        [Parameter(Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            Position = 0)]
            $ComputerName = "localhost"
    )

    Begin {
    }
    Process {

        Try {
            [System.Collections.ArrayList]$fullList = @()
            $queryresult = query user /server:$($ComputerName) 2> $Null
            if (!($queryresult)) { 
                return $Null
            }
            Else {
                Foreach ($resultline in ($queryresult | Select-Object -Skip 1)) {
                    $Parsedline = $resultline.Split(" ", [System.StringSplitOptions]::RemoveEmptyEntries)
                    $ComputerList = [PSCustomObject]@{Name = ''
                        Username                           = ''
                        SessionState                       = ''
                        SessionID                          = ''
                    }
                    switch ($resultline) {
                        { $_ -like '*console*' } {
                            $ComputerList.Name = $ComputerName
                            $ComputerList.SessionID = $Parsedline[2]
                            $ComputerList.SessionState = "Console"
                            $ComputerList.Username = $Parsedline[0].Replace(">", "")
                        }
                        { $_ -like '*Disc*' } {
                            $ComputerList.Name = $ComputerName
                            $ComputerList.SessionID = $Parsedline[1]
                            $ComputerList.SessionState = "Disconnected"
                            $ComputerList.Username = $Parsedline[0]
                        }
                        Default {
                            $ComputerList.Name = $ComputerName
                            $ComputerList.SessionID = $Parsedline[2]
                            $ComputerList.SessionState = "Active"
                            $ComputerList.Username = $Parsedline[0]
                        }
                                
                    }
                    $fullList.Add($ComputerList) | Out-Null
                }
            }
            $fullListCount = $fullList.Count
            if ($fullListCount -gt 0) {
                return ($fullList[0]).username
            }
            return $Null

        }

        catch {
            Write-Host "ERROR : $_" -ForegroundColor Red
            return $Null
        }
    }
}
