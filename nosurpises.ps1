#no surprises by Cameron

$i=450

function Play-Sound {
    param ([string] $note
        
    )
    $note = import-csv -path $psscriptroot\notes2hz.csv
    [console]::beep($note, $i)
    write-host "$note"
}
do{
    start-sleep -Milliseconds $i
    play-sound(A5)



# [console]::beep(880, 450)
# [console]::beep(523.3, 450)
# [console]::beep(698.5, 450)
# [console]::beep(523.3, 450)
# [console]::beep(880, 450)
# [console]::beep(523.3, 450)
# [console]::beep(698.5, 450)
# [console]::beep(523.3, 450)
# [console]::beep(880, 450) 
# [console]::beep(523.3, 450)
# [console]::beep(698.5, 450)
# [console]::beep(523.3, 450)
# [console]::beep(466.2, 450)
# [console]::beep(554.4, 450)
# [console]::beep(698.5, 450)
# [console]::beep(784, 450)
# [console]::beep(880, 450) 
# [console]::beep(523.3, 450)
# [console]::beep(698.5, 450)
# [console]::beep(523.3, 450)
# [console]::beep(880, 450) 
# [console]::beep(523.3, 450)
# [console]::beep(698.5, 450)
# [console]::beep(523.3, 450)
# [console]::beep(880, 450) 
# [console]::beep(523.3, 450)
# [console]::beep(698.5, 450)
# [console]::beep(523.3, 450)
# [console]::beep(466.2, 450)
# [console]::beep(554.4, 450)
# [console]::beep(698.5, 450)
# [console]::beep(784, 450)
}while($true)