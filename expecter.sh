#!/usr/bin/expect

set timeout -1

spawn ./install.sh

expect "Press" {send "\r"}

for {set i 1} {$i < 100} {incr i 1} {
 send -- " " 
}


expect "Type \"accept\" to continue or \"decline\" to go back to the previous menu:"

send -- "\r"

send -- "accept\r"

expect "Please type a selection:"

send -- "2\r" 

expect "Please type a selection or press \"Enter\" to accept default choice \\\[ 1 \\\]:"

send -- "\r"

for {set i 1} {$i < 10} {incr i 1} {
 send -- " " 
}

send -- "\r"

expect "Please type a selection or press \"Enter\" to accept default choice \\\[ 1 \\\]:"

send -- "1\r"

expect "Please type a selection or press \"Enter\" to accept default choice \\\[ 1 \\\]:"

send -- "1\r"

expect "Press \"Enter\" key to quit:"

send -- "\r"