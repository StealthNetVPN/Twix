#import <Foundation/Foundation.h>
#import <dlfcn.h>
#import <substrate.h>

typedef struct { uint32_t platform; uint32_t version; } dyld_build_version_t;

static bool (*orig_sdk_at_least)(dyld_build_version_t);

static bool new_sdk_at_least(dyld_build_version_t v) {
    // 0x001A0000 = 26.0, для любых версий >= 26 отвечаем "нет"
    if (v.version >= 0x001A0000) return false;
    return orig_sdk_at_least(v);
}

%ctor {
    void *sym = dlsym(RTLD_DEFAULT, "dyld_program_sdk_at_least");
    if (sym) {
        MSHookFunction(sym, (void *)new_sdk_at_least, (void **)&orig_sdk_at_least);
    }
}
