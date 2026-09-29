echo "compiling"
g++ -g ../mapper.cpp -o mapper
g++ -g ../reducer.cpp -o reducer

# generate matrices of 3 shapes:
# 1xm mxn
# mxn nx1
# mxn nxo

# [1000, 2000]
m=$(($RANDOM%1000+1000))
n=$(($RANDOM%1000+1000))
o=$(($RANDOM%1000+1000))

# 1. run each one in current directory
# 2. run sequential version to compare
# 3. simply overwrite the files A, B, map_, out
# TODO. different number of tasks

# 1xm mxn
printf "0 " > A
for i in $(seq 1 $m); do
    printf "$(($RANDOM%1000)) " >> A
done
printf "\n" >> A

printf "" > B
for i in $(seq 1 $m); do
    printf "$((i-1)) " >> B
    for j in $(seq 1 $n); do
        printf "$(($RANDOM%1000)) " >> B
    done
    printf "\n" >> B
done

echo "\n\n1xm mxn"
sbatch run.sh
python verify.py

# mxn nx1
printf "" > A
for i in $(seq 1 $m); do
    printf "$((i-1)) " >> A
    for j in $(seq 1 $n); do
        printf "$(($RANDOM%1000)) " >> A
    done
    printf "\n" >> A
done

printf "" > B
for i in $(seq 1 $m); do
    printf "$((i-1)) $(($RANDOM%1000))\n" >> B
done

echo "\n\nmxn nx1"
sbatch run.sh
python verify.py

# mxn nxo
printf "" > A
for i in $(seq 1 $m); do
    printf "$((i-1)) " >> A
    for j in $(seq 1 $n); do
        printf "$(($RANDOM%1000)) " >> A
    done
    printf "\n" >> A
done

printf "" > B
for i in $(seq 1 $n); do
    printf "$((i-1)) " >> B
    for j in $(seq 1 $o); do
        printf "$(($RANDOM%1000)) " >> B
    done
    printf "\n" >> B
done

echo "\n\nmxn nxo"
sbatch run.sh
python verify.py
