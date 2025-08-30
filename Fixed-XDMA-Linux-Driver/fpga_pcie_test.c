#include <stdio.h>
#include <stdint.h>
#include <unistd.h>
#include <time.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>

#include <sys/mman.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/types.h>

const char DevName[] = "/dev/xdma0_h2c_0";
char Buf[64];
static void *MappedAddress;

__uint32_t aaa[10];

int main(void)
{
    int FpgaFd;
    ssize_t Rc;
    // char *Buf;cd 
    
    // Buf = (char *)posix_memalign(4096, 64);

    for (int i = 0; i < 64; i++)
    {
        Buf[i] = 3*i;
    }

    FpgaFd = open(DevName, O_RDWR);

    if (FpgaFd < 0)
    {
        printf("Fpga Open Failed!\r\n");
        goto OUT;
    }

    // MappedAddress = mmap(NULL, 40960, PROT_READ | PROT_WRITE, MAP_SHARED, FpgaFd, 0);

    // if (MappedAddress == MAP_FAILED)
    // {
    //     printf("Map Failed\r\n");
    //     printf("mmap error : %d\r\n", errno);
    //     goto OUT;
    // }

    // for (int i = 0; i < 10; i++)
    // {
    //     *((__uint64_t *)(MappedAddress + 8 * i)) = 2;
    // }

    // for (int i = 0; i < 10; i++)
    // {
    //     aaa[i] = *((__uint32_t *)(MappedAddress + 8 * i));
    //     printf("aaa[%d]:%d", i, aaa[i]);
    // }

    lseek(FpgaFd, 0x100, SEEK_SET);
    Rc = write(FpgaFd, Buf, 32);
    
    if (Rc < 0) {
        perror("write file error.\r\n");
        goto OUT;
    }

    printf("fpga write successfully!\r\n");
    
    OUT:
    close(FpgaFd);
    return 0;
}