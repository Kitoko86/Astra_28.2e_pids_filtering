#!/bin/bash
line=$(grep -coP '(?<=<Frequency FValue=").*?(?=")' "ASTRA.xml")
regex='^(https?)://[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]\.[-A-Za-z0-9\+&@#/%?=~_|!:,.;]*[-A-Za-z0-9\+&@#/%=~_|]$'
until [[ ${url} =~ $regex ]]; do
echo "Enter the URL of the minisatip server:";
read url;
done;
until [[ ${pidS} =~ ^[0-9]+$ ]] && (( pidS <= 8191 )) && (( pidS >= 0 )); do
echo "Enter the starting pid (a value between 0 and 8191) :";
read pidS;
done;
until [[ ${pidE} =~ ^[0-9]+$ ]] && (( pidE <= 8191 )) && (( pidE >= pidS )); do
echo "Enter the ending pid (a value between 0 and 8191) :";
read pidE;
done;
until [[ ${iMin} =~ ^[0-9]+$ ]] && (( iMin <= line )) && (( iMin >= 1 )); do
echo "Enter the starting frequency range to scan (a value between 1 and "$line") :";
read iMin;
done;
until [[ ${iMax} =~ ^[0-9]+$ ]] && (( iMax <= line )) && (( iMax >= iMin )); do
echo "Enter the ending frequency range to scan (a value between 1 and "$line") :";
read iMax;
done;
cal=$(date +%a_%d_%b_%Y_%H"h"%M)
for ((i = iMin;i <= iMax;i++)) do
freq[i]=$(grep -oP '(?<=<Frequency FValue=").*?(?=")' $(find /home -iname ASTRA.xml) | sed -n "${i}p")
pol[i]=$(grep -oP '(?<=<Polarisation Value="0" Name="Linear ).*?(?=orizontal"/>)'\|'(?<=<Polarisation Value="1" Name="Linear ).*?(?=ertical"/>)' $(find /home -iname ASTRA.xml) | sed -n "${i}p")
msys[i]=$(grep -oP '(?<=<ModulationSystem Value="0" Name=").*?(?="/>)'\|'(?<=<ModulationSystem Value="1" Name=").*?(?="/>)' $(find /home -iname ASTRA.xml) | sed -n "${i}p")
sr[i]=$(grep -oP '(?<=<Symbolrate Value=").*?(?="/>)' $(find /home -iname ASTRA.xml) | sed -n "${i}p")
   
    mkdir -p $(echo $HOME"/Documents/"$cal"/"${freq[i]})
    cd $(echo $HOME"/Documents/"$cal"/"${freq[i]})
    for pid in `seq $pidS $pidE`; do
       curl -Y 30000 -y 5 -m 600 -v -o $(echo $pid"_"${freq[i]}"_"${pol[i]}"_"${msys[i]}"_"${sr[i]}" "$url"/?msys="${msys[i]/-/}"&freq="${freq[i]}"&pol="${pol[i]}"&sr="${sr[i]}"&pids="$pid);
       if test -f $(echo $pid"_"${freq[i]}"_"${pol[i]}"_"${msys[i]}"_"${sr[i]}) ; then
          taille=$(du -b $(echo $pid"_"${freq[i]}"_"${pol[i]}"_"${msys[i]}"_"${sr[i]}) | cut -f1);
          if (( taille < 150000 )); then 
              rm $(echo $pid"_"${freq[i]}"_"${pol[i]}"_"${msys[i]}"_"${sr[i]});
          fi     
       fi   
    done;
    if [ -z "$(ls -A $(echo $HOME"/Documents/"$cal"/"${freq[i]}))" ]; then
       rm -r $(echo $HOME"/Documents/"$cal"/"${freq[i]});
    fi
  done;
exit
