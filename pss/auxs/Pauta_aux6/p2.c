#include "stdlib.h" // malloc, free
#include "stdio.h" // printf y todas las funnciones de archivos.
#include "string.h" // strcmp

typedef struct node {
    void *val;
    struct node *next;
} QueueNode;

typedef struct queue {
    QueueNode *first, **plast;
    int len;
} Queue;

Queue *makeQueue() {
    Queue *q = malloc(sizeof(Queue));
    q->first = NULL;
    q->plast = &q->first;
    q->len = 0;
    return q;
}

void put(Queue *q, void *ptr) {
    QueueNode *node = malloc(sizeof(QueueNode));
    node->val = ptr;
    node->next = NULL;
    *q->plast = node;
    q->plast = &node->next;
    q->len++;
}

void *get(Queue *q) {
    if (q->first == NULL) {
        return NULL;
    }
    void *val = q->first->val;
    QueueNode *next = q->first->next;
    free(q->first);
    q->first = next;
    if (next == NULL) {
        q->plast = &q->first;
    }
    q->len--;
    return val;
}

void *peek(Queue *q) {
    if (q->first == NULL) {
        return NULL;
    } else {
        return q->first->val;
    }
}

int emptyQueue(Queue *q) {
    return q->first == NULL;
}

int queueLength(Queue *q) {
    return q->len;
}

void destroyQueue(Queue *q) {
    QueueNode *node = q->first;
    while (node != NULL) {
        QueueNode *next = node->next;
        free(node);
        node = next;
    }
    free(q);
}

void quicksort(Queue *q, int (*cmp)(void *ptr1, void*ptr2)){
    if (emptyQueue(q))
        return;
    Queue *menor = makeQueue();
    Queue *mayor = makeQueue();
    void *pivote = get(q);
    while (!emptyQueue(q)){
        void *elemento = get(q);
        if (cmp(elemento, pivote) >= 0)
            put(mayor, elemento);
        else
            put(menor, elemento);
    }
    quicksort(mayor, cmp);
    quicksort(menor, cmp);
    while (!emptyQueue(menor)){
        void *em = get(menor);
        put(q, em);
    }
    put(q, pivote);
    while (!emptyQueue(mayor)){
        void *em = get(mayor);
        put(q, em);
    }
    destroyQueue(mayor);
    destroyQueue(menor);
}

int cmp_strings(void *ptr1, void *ptr2) {
    return strcmp(ptr1, ptr2);
}

int cmp_int(void *ptr1, void *ptr2) {
    return *(int*)ptr1 - *(int*)ptr2;
}

int main() {
    char a[] = "pedro";
    char b[] = "juan";
    char c[] = "diego";
    char d[] = "pablo";
    Queue *q = makeQueue();

    put(q,a);
    put(q,b);
    put(q,c);
    put(q,d);

    quicksort(q, cmp_strings);

    while (!emptyQueue(q)){
      char *s = (char *) get(q);
      printf("%s\n",s);
    }
    
    Queue *q2 = makeQueue();
    int a1 = 3;
    int a2 = 2;
    int a3 = 4;
    int a4 = 1;
    put(q2, &a1);
    put(q2, &a2);
    put(q2, &a3);
    put(q2, &a4);
    
    quicksort(q2, cmp_int);
    
    while (!emptyQueue(q2)){
      int *i = (int *) get(q2);
      printf("%d\n",*i);
    }
    return 0;
}
