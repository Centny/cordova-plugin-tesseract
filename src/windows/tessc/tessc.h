#pragma once

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers
// Windows Header Files
#include <windows.h>
#include <stdint.h>

#ifdef __cplusplus
extern "C" {
#endif
	//tess_bootstrap will create new tess object and init it, if fail return NULL;
	extern __declspec(dllexport) void* tess_bootstrap(const char* datapath, const char* language);

	//tess_shutdown will free the tess object.
	extern __declspec(dllexport) void tess_shutdown(void* tess);

	//tess_recognize will recognize the image and copy the result to buffer, returning text length. if fail return <0.
	extern __declspec(dllexport) int tess_recognize(void* tess, uint8_t* buffer, uint8_t* image, size_t image_size, int x, int y, int w, int h);

#ifdef __cplusplus
}
#endif