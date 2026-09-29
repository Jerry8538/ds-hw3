# TODO CANNOT DO DIFFERENT NUMBER OF TASKS THIS WAY, SINCE ALL SBATCH SCRIPTS
# ARE TRYING TO READ AND WRITE TO THE SAME FILES WHICH IS A HUGE SLOWDOWN
# FIX IS TO RUN INDIVIDUALLY AND SEPARATED BY TIME

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

# 1xm mxn
cd type1
printf "1xm mxn\n"
printf "generating matrices\n"

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

for mappers in 2 3 4 5; do
    sbatch --ntasks=$mappers run.sh
done

# mxn nx1
cd ../type2
printf "\nmxn nx1\n"
printf "generating matrices\n"

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

for mappers in 2 3 4 5; do
    sbatch --ntasks=$mappers run.sh
done

# mxn nxo
cd ../type3
printf "\nmxn nxo\n"
printf "generating matrices\n"

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

for mappers in 2 3 4 5; do
    sbatch --ntasks=$mappers run.sh
done
