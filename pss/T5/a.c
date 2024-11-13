int g(int *a, int n, int x) {
    int i=0, j=n-1, h=(i+j+1)/2;
    while (i<=j && a[h]!=x) {
        if (a[h]<x) {
            i= h+1;
        } else {
            j= h-1;
        }
        h= (i+j+1)/2;
    }
    return i<=j ? 1 : 0;
}