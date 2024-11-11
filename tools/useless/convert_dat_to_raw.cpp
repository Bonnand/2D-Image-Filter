//#include "stdafx.h"//stdafx.h"
#include <fstream>
#include <iostream>
#include <string>
#include "math.h"

using namespace std;
int main(int argc, char * argv[])
{  ifstream fichier_dat("C:/Users/abonn/Desktop/Cours ESIREM/4eme_Annee/Archi_Reconfigurable/Projet_TP/Projet_TP.sim/sim_1/behav/xsim/Lena128x128g_8bits_r.dat", ios::in | ios::binary);
   ofstream fichier_bmp("C:/Users/abonn/Desktop/Cours ESIREM/4eme_Annee/Archi_Reconfigurable/Projet_TP/tools/Lena128x128g_8bits_r.raw", ios::out | ios::binary |ios::trunc );
   if(fichier_dat)
   {  string ligne;
      while(getline(fichier_dat, ligne))
      {  double addition=0;
         for (int i=0; i<8; i++){
            int k=7-i;
            if(ligne.at(i)=='1') addition+=pow(2.0,k);
         }
         char mot=addition;
         fichier_bmp<<mot;;
      }
      fichier_dat.close();
      fichier_bmp.close();
   }
   else
      cerr << "Impossible d'ouvrir le fichier !" << endl;
   return 0;
}