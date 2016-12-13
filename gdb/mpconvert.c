#include <stdio.h>
#include <string.h>
main()
{
  char line[200];
  char *data = line + 8;
  int i;
  int count = 0;

  printf ("unsigned char programflash[] = {\n ");
  while (fgets (line, 200, stdin))
    {
      if (strncmp (line, "S1", 2) != 0)
        continue;
      for (i = 0; i < strlen(data) - 4; i += 2)
        {
          printf ("0x");
          putchar (data[i]);
          putchar (data[i+1]);
          printf (", ");
          count++;
          if (!(count % 8))
            printf("\n ");
        }
    }
    printf(" };\n");
    printf("#define BDM12_PROGRAMFLASH_SIZE %d\n", count);
    exit(0);
}
