#include <stdarg.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdbool.h>

typedef struct arena *arena_t;
struct arena
{
  int size;
  int current;
  int copy;
  bool flip;
  int64_t* elements;
};

int ARENA_SIZE = 1024;

arena_t create_arena(int size)
{
  arena_t arena = malloc(sizeof(struct arena));
  
  arena->size = size;
  arena->current = 0;
  arena->copy = size; // used while copying only
  arena->flip = false;
  
  arena->elements = malloc(size * 2 * sizeof(int64_t));

  return arena;
}

void arena_free(arena_t a)
{
  free(a->elements);
  free(a);
}

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

int64_t *heapCopy(arena_t heap,  int64_t *addr){
  int64_t *newAddr = lookup(addr, copied);
  if (newAddr == NULL){
    int64_t size = *addr;
    newAddr = heap->elements + heap->copy;
    heap->copy += size;
    int64_t *copyTo = newAddr;
    copied = cons(addr, newAddr, copied);
    newAddr[0] = size;
    int64_t pos;
    for (pos = 1; pos < size; pos++){
      int64_t heapVal = addr[pos];
      if (!(heapVal & 1) && (int64_t*)heapVal >= heapBottom && (int64_t*)heapVal < heapTop){
        newAddr[pos] = (int64_t)heapCopy(heap, (int64_t*)heapVal);
      } else {
        newAddr[pos] = heapVal;
      }
    }
  }
  return newAddr;
}

void garbage_collect(arena_t heap) {
  copied = (list)NULL;
  heapBottom = heap->elements;
  if (heap->flip){
    heapBottom += heap->size;
  }
  heapTop = heapBottom + heap->size;
  int64_t *topOfStack;
  asm ("movq %%rbp, %0;" : "=r" (topOfStack));
  int64_t *stackPtr = bottomOfStack;
  while (topOfStack < stackPtr){
    int64_t stackVal = *stackPtr;
    if (!(stackVal & 1) && (int64_t*)stackVal >= heapBottom && (int64_t*)stackVal < heapTop){
      // stack value is actually a heap pointer
      int64_t newVal = (int64_t)heapCopy(heap, (int64_t*)stackVal);
      *stackPtr = newVal;
    }
    stackPtr -= 1;
  }
  heap->current = heap->copy;
 heap->flip = !heap->flip;
 if (heap->flip){
  heap->copy = 0;
 } else {
  heap->copy = heap->size;
 }
}

int64_t sp;
int64_t *alloc(arena_t heap, int64_t n) {
  asm ("movq %%rsp, %0" : "=r" (sp) );
  if (sp & 8){
    asm ("pushq %rbx" );
  }

  int limit = heap->flip ? heap->size * 2 : heap->size;
  if (limit < heap->current + n){
    garbage_collect(heap);
    limit = heap->flip ? heap->size * 2 : heap->size;
    if (limit < heap->current + n){
      fprintf(stderr, "heap space exhausted\n");
      exit(1);
    }
  }

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
int main() {
  // TODO: Check pointer gets copied correctly
  // simple way to get range for root set
  asm ("movq %%rsp, %0;" : "=r" (bottomOfStack));

  arena_t heap = create_arena(ARENA_SIZE);
  printf("%ld\n", giria(heap) >> 1); /* Shift to decode (div by 2 would round negatives incorrectly) */
  arena_free (heap);
  return 0;
}
