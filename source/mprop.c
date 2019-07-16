#include <unistd.h>
#include <ctype.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <memory.h>
#include <string.h>
#include <sys/ptrace.h>
#include <sys/system_properties.h>



#define PROP_NAME_MAX   32
#define PROP_VALUE_MAX  92
 
static void dump_hex(const char* buf, int len)
{
    const uint8_t *data = (const uint8_t*)buf;
    int i;
    char ascii_buf[17];
 
    ascii_buf[16] = '\0';
 
    for (i = 0; i < len; i++) {
        int val = data[i];
        int off = i % 16;
 
        if (off == 0)
            printf("%08x  ", i);
        printf("%02x ", val);
        ascii_buf[off] = isprint(val) ? val : '.';
        if (off == 15)
            printf(" %-16s\n", ascii_buf);
    }
 
    i %= 16;
    if (i) {
        ascii_buf[i] = '\0';
        while (i++ < 16)
            printf("   ");
        printf(" %-16s\n", ascii_buf);
    }
}
 
#define ORI_INST  0x2e6f72
#define HACK_INST 0x2e6f73
 
int main(int argc, char **argv) 
{
    FILE *fp;
    int  m, rc;
    int  patch_count;
    unsigned long maps, mape, addr, mlen;
    unsigned long real_val, real_vaddr;
 
    char perms[5];
    char line[512];
    char *buffer, *ro;
    char* name = NULL, *value = NULL;
 
    uint32_t tmp;
    uint32_t dest_inst = ORI_INST;
    uint32_t mod_inst = HACK_INST;
 
    int restore = 0, verbose = 0;
 
    for (m = 1; m < argc; m++) {
        if (argv[m] == NULL)
            continue;
 
        if (argv[m][0] != '-') {
            break;
        } 
 
        if (argv[m][1] == 'r') {
            restore = 1;
            dest_inst = HACK_INST;
            mod_inst = ORI_INST;
        } else if (argv[m][1] == 'v') {
            verbose = 1;
        }
    }
 
    if (restore) {
        fprintf(stderr, "restore ...\n"); 
    }
    else {
        if (argc - m >= 2) {
            // fprintf(stderr, "Usage: %s [-r] [-v] [prop_name] [prop_value]\n"
            //                 "e.g.:  %s ro.debuggable 1\n", argv[0], argv[0]);
            name = argv[m];
            value = argv[m+1];
        } 
        
        fprintf(stderr, "start hacking ...\n"); 
    }
     
    fp = fopen("/proc/1/maps", "r");
    if (!fp) {
        perror("!! fopen ");
        return 1;
    }
 
    // 00008000-000cb000 r-xp 00000000 00:01 6999       /init
    memset(line, 0, sizeof(line));
    while (fgets(line, sizeof(line), fp)) {
        int main_exe = (strstr(line, "/init") != NULL) ? 1 : 0;
        if (main_exe) {
            rc = sscanf(line, "%lx-%lx %4s ", &maps, &mape, perms);
            if (rc < 3) {
                perror("!! sscanf ");
                return 1;
            }
            if (perms[0] == 'r' && perms[1] == '-' && perms[2] == 'x' && perms[3] == 'p') {
                break;    
            }
        }
    }
    fclose(fp);
 
    fprintf(stderr, "target mapped area: 0x%lx-0x%lx\n", maps, mape); 
 
    mlen = mape - maps;
    buffer = (char *) calloc(1, mlen + 16);
    if (!buffer) {
        perror("!! malloc ");
        return 1;
    }
    rc = ptrace(PTRACE_ATTACH, 1, 0, 0);
    if (rc < 0) {
        perror("!! ptrace ");
        return rc;
    }
    for (addr = maps; addr < mape; addr += 4) {
        tmp = ptrace(PTRACE_PEEKTEXT, 1, (void *) addr, 0);
        *((uint32_t*)(buffer + addr - maps)) = tmp;
    }
     
    if (verbose) {
        dump_hex(buffer, mlen);
    }
   
    for (m = 0; m < mlen; ++m) {
        if (dest_inst == *(uint32_t*)(buffer+m)) { // 72 6F 2E 00  == ro.\0
            break;
        }
    }
 
    if (m >= mlen) {
        fprintf(stderr, ">> inject position not found, may be already patched!\n");
    } 
    else {
        real_vaddr = maps + m;
        real_val = *(uint32_t*)(buffer+m);
        fprintf(stderr, ">> patching at: 0x%lx [0x%lx -> 0x%08x]\n", real_vaddr, real_val, mod_inst);
         
        tmp = mod_inst;
        rc = ptrace(PTRACE_POKETEXT, 1, (void *)real_vaddr, (void*)tmp);
        if (rc < 0) {
            perror("!! patching failed ");
        }
 
        tmp = ptrace(PTRACE_PEEKTEXT, 1, (void *)real_vaddr, 0);
        fprintf(stderr, ">> %s reread: [0x%lx] => 0x%08x\n", restore ? "restored!" : "patched!", real_vaddr, tmp);       
    }
 
    free(buffer);
    rc = ptrace(PTRACE_DETACH, 1, 0, 0);
 
    if (!restore && (name && value && name[0] != 0)) {
        char propbuf[PROP_VALUE_MAX];
        fprintf(stderr, "-- setprop: [%s] = [%s]\n", name, value);
        __system_property_set(name, value);
        usleep(400000);
        __system_property_get(name, propbuf);
        fprintf(stderr, "++ getprop: [%s] = [%s]\n", name, propbuf);
         
    }
    return rc;
}