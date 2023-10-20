#!/bin/bash
codipais='XX'
codiestat='XX'
resposta='XX'

while [ "resposta" != 'q' ]; do
        echo "q: SORTIR"
        echo "lp: LLISTAR PAÏSOS"
        echo "sc: SELECCIONAR PAÍS"
        echo "se: SELECCIONAR ESTAT"
        echo "le: LLISTAR ELS ESTATS DEL PAÍS SELECCIONAT"
        echo "lcp: LLISTAR LES POBLACIONS DEL PAÍS SELECCIONAT"
        echo "ecp: EXTREURE LES POBLACIONS DEL PAÍS SELECCIONAT"
        echo "lce: LLISTAR LES POBLACIONS DE L'ESTAT SELECCIONAT"
        echo "ece: EXTREURE LES POBLACIONS DE L'ESTAT SELECCIONAT"
        echo "gwd: OBTENIR DADES D'UNA CIUTAT DE LA WIKIDATA"
        echo "est: OBTENIR ESTADÍSTIQUES"
        read resposta
        case "$resposta" in

q)
read -n 1 -p "Prem 'q' per a sortir de l'aplicació: " input
if [[ "$input" == "q" ]]; then
        echo -e "\nSortint de l'aplicació"
break
fi
;;

lp)
cut -d ',' -f7,8 cities.csv | uniq
;;

sc)
echo "Nom del país: "
read nompais

if [[ -z "$nompais" ]];then
        codipais="XX"
        echo "$codipais"
else
        codipais=$(cut -d',' -f7,8 cities.csv | grep -m 1 "$nompais" | cut -d',' -f1)

        if [[ -z "$codipais" ]];then
                codipais="XX"
                echo "$codipais"
        else
                awk -F ',' -v codi="$codipais" '$7 == codi {OFS=","; print $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11}' cities.csv > pais.csv
        fi
fi
;;

se)
echo "Nom del estat: "
read nomestat
if [[ $nomestat == "" ]];then
        codiestat=$codiestat
else
        if [[ $(cut -d',' -f5 pais.csv | grep "$nomestat") = "" ]];then
                codiestat="XX"
                echo "$codiestat"
        else
                codiestat=$(cut -d',' -f4,5 pais.csv | grep -m 1 "$nomestat" | cut -d',' -f1)
                echo "$codiestat"
        fi
fi
;;

le)
cut -d',' -f4,5 pais.csv | uniq
;;

lcp)
cut -d',' -f2,11 pais.csv
;;

ecp)
file="${codipais}.csv" # Corrección: Agrega un punto para separar el nombre del país y la extensión .csv
echo "S'està generant un arxiu $file amb les poblacions del país seleccionat $codipais"
awk -F',' -v country="$codipais" '($7 == country) { print $2 "," $11 } ' pais.csv > "$file"
echo "L'arxiu $file ha sigut generat amb èxit."
;;

lce)
echo "Estat $codiestat i país $codipais seleccionats"
if [ "$codiestat" == "XX" ]; then
    echo "No has seleccionat un estat d'ordre se."
else
    echo "Llistat de poblacions de l'estat $codiestat i país $codipais seleccionat:"
    awk -F ',' -v country="$codipais" -v state="$codiestat" '$7 == country && $4 == state { print $2, $11 }' cities.csv
fi
;;

ece)
echo "Estat $codiestat i país $codipais seleccionats"
if [ "$codiestat" == "XX" ]; then
    echo "No has seleccionat un estat d'ordre se."
else
    file="${codipais}_${codiestat}.csv"
    echo "Extracció de poblacions de l'estat $codiestat i país $codipais seleccionat:"
    awk -F',' -v country="$codipais" -v state="$codiestat" '$7 == country && $5 == state { printf "%s,%s\n", $2, $11 }' cities.csv > "$file"
    echo "Les poblacions s'han guardat a l'arxiu $file."
fi
;;

gwd)
echo "Selecciona una població: "
read nompoblacio
echo "$nompoblacio"
# Utiliza awk para obtener el wikidataId basado en la población seleccionada
wdid=$(awk -F ',' -v pais="$codipais" -v estat="$codiestat" -v poblacio="$nompoblacio" '$7 == pais && $4 == estat && $2 == poblacio { print $11 }' cities.csv)

if [ -z "$wdid" ]; then
    echo "No 'ha trobat el wikidataId per a la població seleccionada."
else
    # Utiliza el wikidataId obtenido para descargar los datos de Wikidata en formato JSON
        wikidataUrl="https://www.wikidata.org/wiki/Special:EntityData/$wdid.json" #Busca al web les dades de la població (utilitznat la variable WikidataId en funció de la poblac>        curl -o "$wdid.json" "$wikidataUrl" #Utilitza la comanda curl per descarregar la informació en format JSON

fi
;;

est)
hemisferi_nord=0
hemisferi_sud=0
hemisferi_oriental=0
hemisferi_occidental=0
longitud_i_latitud_0=0
no_wikiDataId=0

awk -F ',' 'NR > 1 {
id_pais = $1
latitud = $9
longitud = $10
wikiDataId = $11

if (latitud > 0) {
        hemisferi_nord++
}
if (latitud < 0) {
        hemisferi_sud++
}
if (longitud > 0) {
        hemisferi_oriental++
}
if (longitud < 0) {
        hemisferi_occidental++
}
if (latitud == 0 && longitud == 0) {
        longitud_i_latitud_0++
}
if (length(wikiDataId) == 0) {
        no_wikiDataId++
}
}
END {
print "Nord: " hemisferi_nord
print "Sud: " hemisferi_sud
print "Oriental: " hemisferi_oriental
print "Occidental: " hemisferi_occidental
print "Sense ubicació: " longitud_i_latitud_0
print "Sense wikiDataId: " no_wikiDataId
}' cities.csv
;;

*)
echo "La variable interna se li assignarà el valor XX"
;;

"")
echo "El valor de la variable interna no canvia"
;;

esac
done
