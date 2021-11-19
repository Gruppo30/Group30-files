#include<stdio.h>
#include<stdlib.h>

#define N 1 /// order of the filter
#define NB 14  /// number of bits

const int b0 = 3447; /// coefficient b0
const int b[N]={3447}; /// b array
const int a[N]={-1298}; /// a array

/// Perform fixed point filtering assuming direct form II
///\param x is the new input sample
///\return the new output sample
int myfilter(int x)
{

    //ELABORAZIONE FILTRO CON LOOK AHEAD
    static int first_run = 0; /// for cleaning the shift register
    int i;
    static long reg_1,reg_2,reg_3;
    long add2,m1,m2,m3,m4,y,a_quadro_troncata;

    //INIZIALIZZO I REGISTRI
    if (first_run == 0)
    {
        first_run = 1;
        for ( i=0; i<N; i++)
            reg_1 = 0;
            reg_2 = 0;
            reg_3 = 0;
    }

    //OPERAZIONI
    m1=(a[0]*reg_1)>>13;
    a_quadro_troncata = (1298*1298)>>13;
    m2=(a_quadro_troncata*reg_3)>>13;
    add2=m2+x-m1;
    m3=(add2*b0)>>13;
    m4=(reg_2*b[0])>>13;
    y=m3+m4;

    //UPDATE DEI REGISTRI
    reg_1=x;
    reg_3=reg_2;
    reg_2=add2;
    
    return (int)y;
}

int main (int argc, char **argv)
{
    FILE *fp_in;
    FILE *fp_out;

    int x;
    int y;
/*
    /// check the command line
    if (argc != 3)
    {
        printf("Use: %s <input_file> <output_file>\n", argv[0]);
        exit(1);
    }*/

    /// open files
    fp_in = fopen("samples14.txt", "r");
    if (fp_in == NULL)
    {
        printf("Error: cannot open %s\n");
        exit(2);
    }
    fp_out = fopen("output_cprog.txt", "w");

    /// get samples and apply filter
    fscanf(fp_in, "%d", &x);
    do{
        y = myfilter(x);
        fprintf(fp_out,"%d\n", y);
        fscanf(fp_in, "%d", &x);
    } while (!feof(fp_in));

    fclose(fp_in);
    fclose(fp_out);

    return 0;

}
