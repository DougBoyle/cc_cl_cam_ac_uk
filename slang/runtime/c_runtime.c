#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/* arena's are taken Lab 7 of from https://www.cl.cam.ac.uk/teaching/1819/ProgC/materials.html */ 

typedef struct arena *arena_t;
struct arena
{
  int size;
  int current;
  int64_t* elements;
};

int ARENA_SIZE = 1024;

arena_t create_arena(int size)
{
  arena_t arena = malloc(sizeof(struct arena));
  
  arena->size = size;
  arena->current = 0;
  
  arena->elements = malloc(size * sizeof(int64_t));

  return arena;
}

void arena_free(arena_t a)
{
  free(a->elements);
  free(a);
}


// unsure what return value should be.
// needs to know values on stack + how to traverse
// Don't jump to stack locations while copying, keep a list of copied heap locations
struct node {
  int64_t *oldAddr;
  int64_t *newAddr;
  struct node *next;
};
typedef struct node *list;
list copied;

int64_t *lookup(int64_t *addr, list l){
  if (l == NULL){
    return NULL;
  } else if (l->oldAddr == addr){
    return l->newAddr;
  } else {
    return lookup(addr, l->next);
  }
}

list cons(int64_t *oldAddr, int64_t *newAddr, list l){
  list newl = malloc(sizeof(struct node));
  newl->oldAddr = oldAddr;
  newl->newAddr = newAddr;
  newl->next = l;
  return newl;
}

int64_t* bottomOfStack;
int64_t* heapBottom;
int64_t* heapTop;

int64_t *alloc(arena_t heap, int64_t n);

int64_t *heapCopy(arena_t heap, arena_t copyHeap, int64_t *addr){
  int64_t *newAddr = lookup(addr, copied);
  if (newAddr == NULL){
    int64_t size = *addr;
    newAddr = heap->elements + copyHeap->current;
    // updates 'current'
    int64_t *copyTo = copyHeap->elements + copyHeap->current;
    copyHeap->current = copyHeap->current + size;

    copied = cons(addr, newAddr, copied);
    // copy elements of the heap item
    *copyTo = size;
    int64_t pos;
    for (pos = 1; pos < size; pos++){
      int64_t heapVal = addr[pos];
      if (!(heapVal & 1) && (int64_t*)heapVal >= heapBottom && (int64_t*)heapVal < heapTop){
        copyTo[pos] = (int64_t)heapCopy(heap, copyHeap, (int64_t*)heapVal);
      } else {
        copyTo[pos] = heapVal;
      }
    }
  }
  return newAddr;
}

// Note - can't check stack copying behaving correctly without also doing the memcpy/heap update
arena_t copyHeap;
void garbage_collect(struct arena * const heap) {
  copied = (list)NULL;
  copyHeap->current = 0; // reset working space
  heapBottom = heap->elements;
  heapTop = heapBottom + heap->size;
  //printf("Heap bottom: %p Heap top: %p %p %d\n", heapBottom, heapTop, heapBottom + 19, heap->size);
  int64_t *topOfStack;
  asm ("movq %%rbp, %0;" : "=r" (topOfStack));
  int64_t *stackPtr = bottomOfStack;
  while (topOfStack < stackPtr){
    int64_t stackVal = *stackPtr;
    if (!(stackVal & 1) && (int64_t*)stackVal >= heapBottom && (int64_t*)stackVal < heapTop){
      // stack value is actually a heap pointer
      int64_t newVal = (int64_t)heapCopy(heap, copyHeap, (int64_t*)stackVal);
      *stackPtr = newVal;
    }
    stackPtr -= 1;
  }

  memcpy(heap->elements, copyHeap->elements, copyHeap->current * sizeof(int64_t));

  heap->current = copyHeap->current;
}

int64_t sp;

// needs to call garbage collector
// use memcpy for now to do swap after copy, later allow heap to swap betweeen two arenas
int64_t *alloc(arena_t heap, int64_t n)
{
  asm ("movq %%rsp, %0" : "=r" (sp) );
  if (sp & 8){
    asm ("pushq %rbx" );
  }


  if (heap->size < heap->current +n) {
    garbage_collect(heap);
    if (heap->size < heap->current +n){
      fprintf(stderr, "heap space exhausted\n");
      exit(1);
    }
  }
/*
  // to ensure correctness, try running gc on every allocation:
  garbage_collect(heap);
  if (heap->size < heap->current +n){
    fprintf(stderr, "heap space exhausted\n");
    exit(1);
  }*/

  int64_t *new_record = heap->elements + heap->current;
  heap->current = heap->current + n;
  if (sp & 8){
    asm ("popq %rbx");
  }

  return new_record; 
}

/* read in an integer from the command line */
int64_t read() {
  asm ("movq %%rsp, %0" : "=r" (sp) );
  if (sp & 8){
    asm ("pushq %rbx" );
  }
  int64_t got = 0;
  printf("> ");
  int result = scanf("%ld", &got);
  if (result == EOF) {
    fprintf(stderr, "stdin died :(\n");
    exit(1);
  }
  if (sp & 8){
       asm ("popq %rbx");
    }
  return got*2 + 1; // encoding of ints with 1 at end
}

/* this is the name given to the compiled slang code. */
/* "giria" is "slang" in Portuguese                   */
int64_t giria(arena_t);

/* main : create heap, pass it to giria, print result, free heap, exit */
/* Currently will only correctly print slang integer values.           */
/* A heap-allocated value will be printed as the pointer's address!    */
/* This needs to be fixed! Must put headers on heap-allocated          */
/* records, not just for garbage collection, but to identify what kind */
/* of value it is ...                                                  */
// could now distinguish heap item from int, but can't tell what type of heap item
// could maybe use size_t
int main() {
  /* what is initial stack pointer?
  int64_t a;
  asm ("movq %%rsp, %0;" : "=r" ( a ));
  printf("%ld\n", a); 7FFFCD0D91D0
  */
  // TODO: Check pointer gets copied correctly
  // simple way to get range for root set
  asm ("movq %%rsp, %0;" : "=r" (bottomOfStack));

  arena_t heap = create_arena(ARENA_SIZE);
  copyHeap = create_arena(ARENA_SIZE);
  printf("%ld\n", giria(heap) >> 1); /* Shift to decode (div by 2 would round negatives incorrectly) */
  arena_free (heap);
  return 0;
}
