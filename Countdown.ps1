

[console]::CursorVisible = $false
$rotate = @( '\', '|', '/', '-')
$i = 0
do{
    start-sleep -Milliseconds 500

    Clear-Host

    $days = (New-TimeSpan -start (get-date) -end "Monday, May 3, 2021 8:30:00 AM")

    write-host -ForegroundColor ([System.ConsoleColor](Get-Random -Min 0 -Max ([System.ConsoleColor].GetFields().Count - 1))) -object "Paul Will be Back in $($days.days) days $($days.hours) hours and $($days.minutes) minutes"

    write-host $rotate[$i]
    if ($i -le 2){ 
        $i = $i + 1
    }else{
        $i = 0
    }


    
}while ($true)