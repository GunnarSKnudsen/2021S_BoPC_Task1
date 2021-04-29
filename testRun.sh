
rm outputTest.dat
python ./julia_par.py --nprocs 7 --size 1000 --patch 30 -o outputTest.png >> outputTest.dat
cat outputTest.dat
