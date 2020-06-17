Red/System []

#either OS = 'Windows [
	#import [
		LIBC-file cdecl [
			_open: "_open" [
				filename	[c-string!]
				oflag		[integer!]
				mode		[integer!]
				return:		[integer!]
			]
			_read:	"_read" [
				file		[integer!]
				buffer		[byte-ptr!]
				bytes		[integer!]
				return:		[integer!]
			]
			_close:	"_close" [
				file		[integer!]
				return:		[integer!]
			]
		]
	]
	#define _O_BINARY		8000h
][
	#import [
		LIBC-file cdecl [
			_open:	"open" [
				filename	[c-string!]
				flags		[integer!]
				mode		[integer!]
				return:		[integer!]
			]
			_read:	"read" [
				file		[integer!]
				buffer		[byte-ptr!]
				bytes		[integer!]
				return:		[integer!]
			]
			_close:	"close" [
				file		[integer!]
				return:		[integer!]
			]
		]
	]
	#define _O_BINARY		0
]

read-bin: func [
	filename	[c-string!]
	buffer		[byte-ptr!]
	bytes		[integer!]
	return:		[integer!]
	/local
		fd		[integer!]
		ret		[integer!]
][
	fd: _open filename _O_BINARY 0100h
	if fd < 0 [return fd]
	ret: _read fd buffer bytes
	_close fd
	ret
]
