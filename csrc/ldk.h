#pragma once

#if defined(_MSC_VER)
#    define _LDK_EXTERN __declspec(dllexport)
#    define _LDK_ALIGN(x) __declspec(align(x))
#else
#    define _LDK_EXTERN extern
#    define _LDK_ALIGN(x) alignas(x)
#endif

#if defined(__GNUC__) || defined(__clang__)
#    define _LDK_PRIVATE __attribute__((unused)) static
#else
#    define _LDK_PRIVATE static
#endif

#if defined(_MSC_VER)
#    define _LDK_NORETURN __declspec(noreturn)
#    define _LDK_NORETURN_PTR
#elif defined(__GNUC__)
#    define _LDK_NORETURN __attribute__((__noreturn__))
#    define _LDK_NORETURN_PTR __attribute__((__noreturn__))
#else
#    define _LDK_NORETURN
#    define _LDK_NORETURN_PTR
#endif

#if defined(__APPLE__) && defined(__MACH__)
#    define _LDK_APPLE
#    define _LDK_UNIX
#    if defined(__ENVIRONMENT_IPHONE_OS_VERSION_MIN_REQUIRED__)
#        define _LDK_IOS
#        define _LDK_OS_NAME "iOS"
#    else
#        define _LDK_MACOS
#        define _LDK_OS_NAME "macOS"
#    endif
#elif defined(WIN64) || defined(_WIN64) || defined(__WIN64__)
#    define _LDK_WINDOWS
#    define _LDK_WIN64
#    define _LDK_OS_NAME "Windows"
#elif defined(_WIN32) || defined(_WIN32) || defined(__WIN32__)
#    define _LDK_WINDOWS
#    define _LDK_WIN32
#    define _LDK_OS_NAME "Windows"
#elif defined(linux) || defined(__linux) || defined(__linux__) || defined(__gnu_linux__)
#    define _LDK_UNIX
#    define _LDK_LINUX
#    define _LDK_OS_NAME "Linux"
#else
#    error "unsupported OS"
#endif

#if defined(__i386) || defined(__i386__) || defined(_M_IX86)
#    define _LDK_CPU_32
#    define _LDK_CPU_X86
#    define _LDK_CPU_X86_32
#    define _LDK_CPU_ARCH "x86"
#elif defined(__x86_64__) || defined(_M_X64) || defined(_M_AMD64)
#    define _LDK_CPU_64
#    define _LDK_CPU_X86
#    define _LDK_CPU_X86_64
#    define _LDK_CPU_ARCH "x86_64"
#elif defined(__aarch64__) || defined(_M_ARM64)
#    define _LDK_CPU_64
#    define _LDK_CPU_ARM
#    define _LDK_CPU_ARM64
#    define _LDK_CPU_ARCH "arm64"
#elif defined(__arm__) || defined(_M_ARM)
#    define _LDK_CPU_32
#    define _LDK_CPU_ARM
#    define _LDK_CPU_ARCH "arm"
#else
#    error "Unsupported processor"
#endif

// Endianness
#if defined(_LDK_LINUX)
#    include <endian.h>
#elif defined(_LDK_DARWIN)
#    include <machine/endian.h>
#elif defined(_LDK_BSD)
#    include <sys/endian.h>
#endif

#if defined(__ORDER_BIG_ENDIAN__)
#    define _LDK_ORDER_BIG_ENDIAN __ORDER_BIG_ENDIAN__
#else
#    define _LDK_ORDER_BIG_ENDIAN 4321
#endif

#if defined(__ORDER_LITTLE_ENDIAN__)
#    define _LDK_ORDER_LITTLE_ENDIAN __ORDER_LITTLE_ENDIAN__
#else
#    define _LDK_ORDER_LITTLE_ENDIAN 1234
#endif

#if defined(__BYTE_ORDER)
#    if __BYTE_ORDER == __BIG_ENDIAN
#        define _LDK_BYTE_ORDER _LDK_ORDER_BIG_ENDIAN
#    elif __BYTE_ORDER == __LITTLE_ENDIAN
#        define _LDK_BYTE_ORDER _LDK_ORDER_LITTLE_ENDIAN
#    else
#        error "unsupported byte-order"
#    endif
#elif defined(_LDK_CPU_X86)
#    define _LDK_BYTE_ORDER _LDK_ORDER_LITTLE_ENDIAN
#elif defined(_LDK_CPU_ARM)
#    if defined(__ARMEB__) || defined(__THUMBEB__) || defined(__AARCH64EB__)
#        define _LDK_BYTE_ORDER _LDK_ORDER_BIG_ENDIAN
#    elif
#        define _LDK_BYTE_ORDER _LDK_ORDER_LITTLE_ENDIAN
#    endif
#else
#    error "unsupported byte-order"
#endif

#if defined(_LDK_WINDOWS)
#    define _LDK_PATH_DIRSEP '\\'
#    define _LDK_PATH_ALTDIRSEP '/'
#    define _LDK_PATH_PATHSEP ';'
#else
#    define _LDK_PATH_DIRSEP '/'
#    define _LDK_PATH_ALTDIRSEP '/'
#    define _LDK_PATH_PATHSEP ':'
#endif
