#include <fcntl.h>
#include <unistd.h>
#include <stdio.h>
#include <dlfcn.h>
#include <stdbool.h>
#include <stdlib.h>
#include <errno.h>
#include <sys/mman.h>
#include <pthread.h>
#include <android/log.h> 
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, "xmono", __VA_ARGS__)

extern unsigned long _shellcode_start;
extern unsigned long _shellcode_end;
extern unsigned long _hookstub_enter;
extern unsigned long _hookstub_leave;
extern unsigned long _old_function_addr;
extern unsigned long _mutex;
extern unsigned long _thread_lock;
extern unsigned long _thread_unlock;

void hook_wrapper(void *symbol, void *replace, void **result)
{
	typedef void (*MSHookFunction_ptr)(void *,void *,void **);
	MSHookFunction_ptr MSHookFunction =NULL;
	
	void *pHandle=dlopen("/data/local/tmp/libsubstrate.so",RTLD_LAZY);
	MSHookFunction = (MSHookFunction_ptr)dlsym(pHandle,"MSHookFunction");
	MSHookFunction(symbol, replace, result);
	dlclose(pHandle);
	pHandle=0;
}

int change_page_property(void *pAddress, size_t size)
{
    if(pAddress == NULL)
    {
        return 0;
    }
    
    //计算包含的页数、对齐起始地址
    unsigned long ulPageSize = sysconf(_SC_PAGESIZE);
    int iProtect = PROT_READ | PROT_WRITE | PROT_EXEC;
    unsigned long ulNewPageStartAddress = (unsigned long)(pAddress) & ~(ulPageSize - 1);
    long lPageCount = (size / ulPageSize) + 1;
    
    long l = 0;
    while(l < lPageCount)
    {
        //利用mprotect改页属性
        int iRet = mprotect((const void *)(ulNewPageStartAddress), ulPageSize, iProtect);
        if(-1 == iRet)
        {
            return iRet;
        }
        l++; 
    }
    
    return 1;
}


void hook(void * target, void * enter, void * leave)
{
	//pthread_mutex_t *pMutex = (pthread_mutex_t *)&_mutex;
	//*(void **)&_thread_lock = pthread_mutex_lock;
	//*(void **)&_thread_unlock = pthread_mutex_unlock;
	*(void **)&_hookstub_enter = enter;
	*(void **)&_hookstub_leave = leave;
	
	int shellcodeSize = &_shellcode_end - &_shellcode_start;
	void *pNewShellcode = malloc(shellcodeSize);
	change_page_property(pNewShellcode, shellcodeSize);
	
	hook_wrapper(target, pNewShellcode, (void **)&_old_function_addr);
	memcpy(pNewShellcode, &_shellcode_start, shellcodeSize);
	
	LOGI("hook transport addr %08x, size %d", (int)pNewShellcode, shellcodeSize);
}

int i=0;
void stub_start()
{
	i++;
	LOGI("s\t%d", i);
}

void stub_end()
{
	LOGI("e\t%d", i);
	i--;
}

void mainthread()
{
	// 等待libmono.so加载
	void *pLibMono=0;
	do
	{
		pLibMono=dlopen("libmono.so", RTLD_LAZY);
		usleep(200000);
	}while(pLibMono==0);
	
	sleep(5);
	
	void* mono_runtime_invoke = dlsym(pLibMono, "mono_runtime_invoke");
	hook(mono_runtime_invoke, stub_start, stub_end);
	dlclose(pLibMono);
	pLibMono=0;
}

__attribute__ ((__constructor__))
void main()
{
	pthread_t id;
	pthread_create(&id, NULL, (void *)mainthread, NULL);
}