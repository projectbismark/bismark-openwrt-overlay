#!/bin/bash

## script for merging bismark essential pkgs to a new .config version 

SRC=".config_bismark"                                                 
DST=".config_current"                                                
RES=".config_merge"
                                                                      
cp $DST $RES                                                                                                                        
cat $SRC | \
while read sline; do                                                                                                               
    fc=$(echo $sline | head -c 1) # first char                                                                                     
    [ -z $fc ] && continue

    if [[ $fc != "#" ]]; then
        OLDIFS=$IFS
        IFS="="
        arr=($sline)
        skey=${arr[0]}
        sval=${arr[1]}
        found=false                                                                                                                
        cat $DST |
        {                                                             
        while read dline; do                                          
            #echo "$sline <cp> $dline"                                
            if [[ "$dline" == *"$skey "* ]]; then # unset             
                echo "$sline <ns> $dline"                             
                sed -i "s/$dline/$sline/g" $RES                       
                { found=true;}                                        
                break;                                                
            fi                                                                                                                     
            if [[ "$dline" == *"$skey="* ]]; then # set               
                arr=( $dline )                                        
                dval=${arr[1]}                                        
                if [ $sval != $dval ]; then     #diff vals            
                        { found=true;}                                
                        echo "$sline <df> $dline"                    
                        sed -i "s/$dline/$sline/g" $RES               
                        break;                                        
                fi                                                    
            fi                                                                                                                     
            if [[ "$dline" == "$sline" ]]; then         # set         
                found=true                                            
                break;                                                
            fi                                                        
        done                                                                                                                       
        if [ "$found" != "true" ]; then                               
             echo "** Warning: param ["$skey"] not found!"            
        fi                                                                                                                         
        }                                                             
        IFS=$OLDIFS                                                   
    fi                                                                
doneSRC=".config_bismark"                                                 
DST=".config_current"                                                
RES=".config_res"
                                                                      
cp $DST $RES                                                                                                                        
cat $SRC | \
while read sline; do                                                                                                               
    fc=$(echo $sline | head -c 1) # first char                                                                                     
    [ -z $fc ] && continue

    if [[ $fc != "#" ]]; then
        OLDIFS=$IFS
        IFS="="
        arr=($sline)
        skey=${arr[0]}
        sval=${arr[1]}
        found=false                                                                                                                
        cat $DST |
        {                                                             
        while read dline; do                                          
            #echo "$sline <cp> $dline"                                
            if [[ "$dline" == *"$skey "* ]]; then # unset             
                echo "$sline <ns> $dline"                             
                sed -i "s/$dline/$sline/g" $RES                       
                { found=true;}                                        
                break;                                                
            fi                                                                                                                     
            if [[ "$dline" == *"$skey="* ]]; then # set               
                arr=( $dline )                                        
                dval=${arr[1]}                                        
                if [ $sval != $dval ]; then     #diff vals            
                        { found=true;}                                
                        echo "$sline <df> $dline"                    
                        sed -i "s/$dline/$sline/g" $RES               
                        break;                                        
                fi                                                    
            fi                                                                                                                     
            if [[ "$dline" == "$sline" ]]; then         # set         
                found=true                                            
                break;                                                
            fi                                                        
        done                                                                                                                       
        if [ "$found" != "true" ]; then                               
             echo "** Warning: param ["$skey"] not found!"            
        fi                                                                                                                         
        }                                                             
        IFS=$OLDIFS                                                   
    fi                                                                
done
