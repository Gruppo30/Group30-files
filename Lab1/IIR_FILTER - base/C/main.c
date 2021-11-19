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
    //ELABORAZIONE FILTRO BASE

    static int sw[N]; /// w shift register
    static int first_run = 0; /// for cleaning the shift register
    int i; /// index
    int w; /// intermediate value (w)
    int y; /// output sample
    int fb, ff; /// feed-back and feed-forward results

    /// clean the buffer
    if (first_run == 0)
    {
        first_run = 1;
        for (i=0; i<N; i++)
            sw[i] = 0;
    }

    /// compute feed-back and feed-forward
    fb = 0;
    ff = 0;
    for (i=0; i<N; i++)
    {
        fb -= (sw[i]*a[i]) >> (NB);
        fb = fb<<1;
        ff += (sw[i]*b[i]) >> (NB);
        ff = ff<<1;
    }

    /// compute intermediate value (w) and output sample
    w = x + fb;
    y = (w*b0) ;
    y = y >> (NB-1);
    y += ff;

    /// update the shift register
    for (i=N-1; i>0; i--)
        sw[i] = sw[i-1];
    sw[0] = w;

    return (int)y;
}

int main (int argc, char **argv)
{
    FILE *fp_in;
    FILE *fp_out;

    int x;
    int y;

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
