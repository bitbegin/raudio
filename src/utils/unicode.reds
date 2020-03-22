Red/System []

unicode: context [
	#define U_REPLACEMENT 	FFFDh
	#define NOT_A_CHARACTER FFFEh
	;	choose one of the following options
	;	FFFDh			; U+FFFD = replacement character
	;	1Ah				; U+001A = control SUB (substitute)
	;	241Ah			; U+241A = symbol for substitute
	;	2426h			; U+2426 = symbol for substitute form two
	;	3Fh				; U+003F = question mark
	;	BFh				; U+00BF = inverted question mark
	;	DC00h + b1		; U+DCxx where xx = b1 (never a Unicode codepoint)
	
	;; DFA algorithm: http://bjoern.hoehrmann.de/utf-8/decoder/dfa/#variations
	utf8d: #{
		0000000000000000000000000000000000000000000000000000000000000000
		0000000000000000000000000000000000000000000000000000000000000000
		0000000000000000000000000000000000000000000000000000000000000000
		0000000000000000000000000000000000000000000000000000000000000000
		0101010101010101010101010101010109090909090909090909090909090909
		0707070707070707070707070707070707070707070707070707070707070707
		0808020202020202020202020202020202020202020202020202020202020202
		0A0303030303030303030303030403030B060606050808080808080808080808
		000C18243C60540C0C0C30480C0C0C0C0C0C0C0C0C0C0C0C0C000C0C0C0C0C00
		0C000C0C0C180C0C0C0C0C180C180C0C0C0C0C0C0C0C0C180C0C0C0C0C180C0C
		0C0C0C0C0C180C0C0C0C0C0C0C0C0C240C240C0C0C240C0C0C0C0C240C240C0C
		0C240C0C0C0C0C0C0C0C0C0C 
	}
	utf8d: utf8d + 1									;-- switch it to 0-base indexing

	fast-decode-utf8-char: func [
		p		[byte-ptr!]
		cp		[int-ptr!]
		return: [byte-ptr!]
		/local
			state byte idx type [integer!]
	][
		state: 0
		byte: as-integer p/value
		type: as-integer utf8d/byte
		cp/value: FFh >> type and byte
		idx: 256 + state + type
		state: as-integer utf8d/idx
		p: p + 1
		if zero? state [return p]						;-- fast-path for mono-byte codepoint
		
		forever [
			byte: as-integer p/value
			type: as-integer utf8d/byte
			switch state [
				0		[return p]						;-- ACCEPT
				12		[cp/value: -1 return p]			;-- REJECT
				default [
					cp/value: byte and 3Fh or (cp/value << 6)
					p: p + 1
				]
			]
			idx: 256 + state + type
			state: as-integer utf8d/idx
		]
		as byte-ptr! 0									;-- never reached, just make compiler happy
	]

	;-- Count UTF-8 encoded characters between two positions in a binary buffer
	count-chars: func [s e [byte-ptr!] return: [integer!]
		/local c len [integer!]
	][
		c: len: 0
		while [s < e][
			s: fast-decode-utf8-char s :len
			c: c + 1
		]
		c
	]
	
	;-- Skips a given amount of UTF-8 encoded characters in a binary buffer
	skip-chars: func [s e [byte-ptr!] c [integer!] return: [byte-ptr!]
		/local len [integer!] p [byte-ptr!]
	][
		len: 0
		while [all [c > 0 s < e]][
			s: fast-decode-utf8-char s :len
			c: c - 1
		]
		s
	]

	cp-to-utf8: func [
		cp		[integer!]
		buf		[byte-ptr!]
		return: [integer!]
	][
		case [
			cp <= 7Fh [
				buf/1: as-byte cp
				1
			]
			cp <= 07FFh [
				buf/1: as-byte cp >> 6 or C0h
				buf/2: as-byte cp and 3Fh or 80h
				2
			]
			cp <= 0000FFFFh [
				buf/1: as-byte cp >> 12 or E0h
				buf/2: as-byte cp >> 6 and 3Fh or 80h
				buf/3: as-byte cp	   and 3Fh or 80h
				3
			]
			cp <= 0010FFFFh [
				buf/1: as-byte cp >> 18 or F0h
				buf/2: as-byte cp >> 12 and 3Fh or 80h
				buf/3: as-byte cp >> 6  and 3Fh or 80h
				buf/4: as-byte cp 		and 3Fh or 80h
				4
			]
			true [
				0
			]
		]
	]

	;-- two byte unicode to utf8
	to-utf8: func [
		code	[byte-ptr!]
		utf8	[byte-ptr!]
		len		[int-ptr!]
		return:	[logic!]
		/local
			end		[byte-ptr!]
			temp	[integer!]
			pb		[byte-ptr!]
			unit	[integer!]
			c		[integer!]
	][
		unless null? utf8 [
			end: utf8 + len/1
		]
		len/1: 0
		temp: 0
		pb: as byte-ptr! :temp
		forever [
			unit: (as integer! code/2) << 8
			unit: unit + as integer! code/1
			if unit = 0 [break]
			c: cp-to-utf8 unit pb
			if c = 0 [return false]
			unless null? utf8 [
				either utf8 + c < end [
					copy-memory utf8 pb c
					utf8: utf8 + c
				][return false]
			]
			code: code + 2
			len/1: len/1 + c
		]
		unless null? utf8 [
			utf8/1: #"^(00)"
		]
		len/1: len/1 + 1
		true
	]

	unicode-length?: func [
		code	[byte-ptr!]
		return:	[integer!]
		/local
			unit	[integer!]
			count	[integer!]
	][
		count: 0
		forever [
			unit: (as integer! code/2) << 8
			unit: unit + as integer! code/1
			count: count + 1
			if unit = 0 [break]
			code: code + 2
		]
		count
	]

	to-unicode: func [
		utf8	[byte-ptr!]
		code	[byte-ptr!]
		len		[int-ptr!]
		return:	[logic!]
		/local
			end		[byte-ptr!]
			temp	[integer!]
			low		[integer!]
			high	[integer!]
	][
		unless null? code [
			end: code + len/1
		]
		len/1: 0
		temp: 0
		forever [
			utf8: fast-decode-utf8-char utf8 :temp
			if temp = 0 [break]
			if temp = -1 [return false]
			low: temp and FFFFh
			high: temp >>> 16
			unless null? code [
				either code + 2 < end [
					code/1: as byte! low and FFh
					code/2: as byte! low >>> 8 and FFh
					code: code + 2
				][return false]
				if high <> 0 [
					either code + 2 < end [
						code/1: as byte! high and FFh
						code/2: as byte! high >>> 8 and FFh
						code: code + 2
					][return false]
				]
			]
			either high = 0 [
				len/1: len/1 + 2
			][
				len/1: len/1 + 4
			]
		]
		unless null? code [
			either code + 2 <= end [
				code/1: #"^(00)"
				code/2: #"^(00)"
			][return false]
		]
		len/1: len/1 + 2
		true
	]
]

#import [
	LIBC-file cdecl [
		setlocale: "setlocale" [
			category	[integer!]
			locale		[c-string!]
			return:		[c-string!]
		]
	]
]

#define LC_ALL		0
#define LC_CTYPE	2
setlocale LC_ALL ""
