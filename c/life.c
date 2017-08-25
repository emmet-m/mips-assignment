#include <stdio.h>
#include <stdlib.h>

#include "board1.h"

int neighbours(int, int);
void copyBackAndShow();

int main(void)
{
    int maxiters;
    printf("# Iterations: ");
    scanf("%d", &maxiters);
    for (int n = 1; n <= maxiters; n++) {
      for (int i = 0; i < N; i++) {
         for (int j = 0; j < N; j++) {
            int nn = neighbours(i,j);
            if (board[i][j] == 1) {
               if (nn < 2)
                  newboard[i][j] = 0;
               else if (nn ==2 || nn == 3)
                  newboard[i][j] = 1;
               else
                  newboard[i][j] = 0;
            }
            else if (nn == 3)
               newboard[i][j] = 1;
            else
               newboard[i][j] = 0;
         }
      }
      printf("=== After iteration %d ===\n", n);
      copyBackAndShow();
   }
   return 0;
}

int neighbours(int i, int j)
{
    int nn = 0;
   for (int x = -1; x <= 1; x++) {
      for (int y = -1; y <= 1; y++) {
         if (i+x < 0 || i+x > N-1) continue;
         if (j+y < 0 || j+y > N-1) continue;
         if (x == 0 && y == 0) continue;
         if (board[i+x][j+y] == 1) nn++;
        }
    }
   return nn;
}

void copyBackAndShow()
{
   for (int i = 0; i < N; i++) {
      for (int j = 0; j < N; j++) {
         board[i][j] = newboard[i][j];
         if (board[i][j] == 0)
            putchar('.');
         else
            putchar('#');
      }
      putchar('\n');
   }
}
