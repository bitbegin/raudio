Red/System []

this!: alias struct! [vtbl [int-ptr!]]
com-ptr!: alias struct! [value [this!]]

interface!: alias struct! [
	ptr [this!]
]

QueryInterface!: alias function! [
	this		[this!]
	riid		[int-ptr!]
	ppvObject	[interface!]
	return:		[integer!]
]

AddRef!: alias function! [
	this		[this!]
	return:		[integer!]
]

Release!: alias function! [
	this		[this!]
	return:		[integer!]
]

IUnknown: alias struct! [
	QueryInterface			[QueryInterface!]
	AddRef					[AddRef!]
	Release					[Release!]
]

#import [
	"ole32.dll" stdcall [
		CoInitializeEx: "CoInitializeEx" [
			reserved	[integer!]
			dwCoInit	[integer!]
			return:		[integer!]
		]
		CoUninitialize: "CoUninitialize" []
		CoCreateInstance: "CoCreateInstance" [
			rclsid		 [int-ptr!]
			pUnkOuter	 [integer!]
			dwClsContext [integer!]
			riid		 [int-ptr!]
			ppv			 [com-ptr!]
			return:		 [integer!]
		]
		CoTaskMemFree: "CoTaskMemFree" [
			pv		[integer!]
		]
		PropVariantClear: "PropVariantClear" [
			pvar	[int-ptr!]
			return:	[integer!]
		]
	]
]

#define COINIT_APARTMENTTHREADED	2

#define CLSCTX_INPROC_SERVER 	1
#define CLSCTX_INPROC_HANDLER	2
#define CLSCTX_INPROC           3						;-- CLSCTX_INPROC_SERVER or CLSCTX_INPROC_HANDLER

;-- 00000000-0000-0000-C000-000000000046
IID_IUnknown: [00000000h 00000000h 000000C0h 46000000h]

GUID!: alias struct! [
	guid1	[integer!]
	guid2	[integer!]
	guid3	[integer!]
	guid4	[integer!]
]

copy-guid: func [
	dst		[GUID!]
	src		[GUID!]
][
	dst/guid1: src/guid1
	dst/guid2: src/guid2
	dst/guid3: src/guid3
	dst/guid4: src/guid4
]
