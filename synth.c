#include <stdlib.h>

typedef long long          I;
typedef double             D;

#define DO(n,stm) {I i=0,_n=(n); for(;i<_n;i++){stm}}
#define DECL_ARR(t, v, l) t *v = malloc(sizeof(t)*(l))

void filter(I length, D* a, I lx, D* xc, I ly, D* yc) {
    DECL_ARR(D, x, lx); DECL_ARR(D, y, ly);
    DO(lx, x[i]=0;); DO(ly, y[i]=0;);
    int j, ix=0, iy=0;
    for (j=0; j<length; j++) {
        x[ix++] = a[j]; ix%=lx;
        a[j] = 0;
        DO(lx, a[j] += x[(ix+i)%lx] * xc[i];);
        DO(ly, a[j] += y[(iy+i)%ly] * yc[i];);
        y[iy++] = a[j]; iy%=ly;
    }
    return;
}

void highpass_f(I length, D* a, D* alpha) {
    double prev = a[0];
    int i;
    for (i=1; i<length; i++) {
        double cur = a[i];
        a[i] = alpha[i-1] * (a[i-1] + a[i] - prev);
        prev = cur;
    }
    return;
}
