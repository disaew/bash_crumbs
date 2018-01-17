#!/bin/bash

domain=( domain.ru )
alert=( 90 30 15 10 5 4 3 2 1 )
mailto=
mailfrom=
log=1

#logging the operation

if [ "$log" -eq "1" ]
        then
                start=$(date '+%d/%m/%Y %H:%M:%S');
                printf "\nStarting script at $start with parameters: \n\n"
                printf "domains: \n"
                for d in ${domain[@]}
                        do
                                printf "$d \n"
                        done
                printf "\nalerts: \n"
                for i in ${alert[@]}
                        do
                                printf "$i \n"
                        done
fi

#starting domain loop

for d in ${domain[@]}

        do
                if [ "$log" -eq "1" ]
                        then
                                printf "\n\n-----------------------------------------------\n\n"        
                                printf "\nchecking $d :\n"
                fi

                #grep the date out of whois query and format it to UNIX time
                expires=`whois $d | grep "paid" | awk {'print $2'} | tr "T" "\n" | head -1 | tr -d "-"`
                exp=$(date -d $expires +"%s")

                #get current date and format it to UNIX time
                today=$(date +'%Y%m%d')
                now=$(date -d $today +"%s")

                #calculate difference in days
                dif=$(( ( exp - now )/(60*60*24) ))

                #dates logging

                 if [ "$log" -eq "1" ]
                        then        
                                printf "expires: $expires \n"
                                printf "UNIX time: $exp \n"
                                printf "today: $today \n"
                                printf "UNIX time: $now \n\n"
                                printf "diff: $dif \n\n"

                fi

                #checking each alert date against domain expire period (dif)

                for i in ${alert[@]}

                do
                if [ "$log" -eq "1" ]
                        then        
                                printf "\nalert: $i :\n"
                fi

                if [ "$dif" -eq "$i" ]
                then
                        if [ "$log" -eq "1" ]
                        then        
                                printf "matches period: $dif \n"
                        fi
                        
                        php -r "mail('$mailto', 'TLD $d expire notification', 'Keep in mind, that domain $d expires in $i', '$mailfrom');"

                        if [ "$log" -eq "1" ]
                        then        
                                printf "notification sent for domain $d from $mailfrom to $mailto with stated period: $i"
                        fi

                else
                        if [ "$log" -eq "1" ]
                        then        
                                printf "not matches to $dif - skip \n"
                        fi
                fi
                done
        done

        if [ "$log" -eq "1" ]
                        then    
                                finish=$(date '+%d/%m/%Y %H:%M:%S');
                                printf "\n\nScript finished at $finish\n\n"
                        fi
                     
