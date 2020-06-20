Red/System []

#include %../../src/audio.reds

play: context [
	dev: as AUDIO-DEVICE! 0
	set-type: 0
	real-type: 0
	buffer: as byte-ptr! 0
	ebuffer: as byte-ptr! 0
	buf-len: 0
	pos: 0
	M1FLOAT32: as float32! 32768.0
	M2FLOAT32: as float32! 2.147483648E9

	wave-cb: func [
		dev				[AUDIO-DEVICE!]
		io				[AUDIO-DEVICE-IO!]
		/local
			out			[AUDIO-BUFFER!]
			frame		[integer!]
			count		[integer!]
			sw			[integer!]
			rw			[integer!]
			soff		[integer!]
			roff		[integer!]
			charr		[int-ptr!]
			rch			[int-ptr!]
			rbuf		[byte-ptr!]
			rfp			[pointer! [float32!]]
			rip			[int-ptr!]
			sch			[byte-ptr!]
			sbuf		[byte-ptr!]
			itemp		[integer!]
			ftemp		[float32!]
			bp			[byte-ptr!]
	][
		if null? io/buffer [exit]
		out: io/buffer
		frame: 0
		sw: either set-type = ASAMPLE-TYPE-I16 [2][4]
		rw: either real-type = ASAMPLE-TYPE-I16 [2][4]
		charr: as int-ptr! out/channels
		loop out/frames-count [
			count: 0
			soff: frame * out/stride * sw
			roff: frame * out/stride * rw
			loop out/channels-count [
				rch: charr + count
				rbuf: as byte-ptr! rch/1
				rbuf: rbuf + roff
				rfp: as pointer! [float32!] rbuf
				rip: as int-ptr! rbuf
				sch: buffer + (count * sw)
				sbuf: sch + soff
				case [
					real-type = ASAMPLE-TYPE-F32 [
						case [
							set-type = ASAMPLE-TYPE-I16 [
								itemp: as integer! sbuf/1
								itemp: (as integer! sbuf/2) << 8 + itemp
								if itemp >= 32768 [
									bp: as byte-ptr! :itemp
									bp/3: #"^(FF)"
									bp/4: #"^(FF)"
								]
								rfp/1: as float32! itemp
								rfp/1: rfp/1 / M1FLOAT32
							]
							set-type = ASAMPLE-TYPE-I32 [
								itemp: as integer! sbuf/1
								itemp: (as integer! sbuf/2) << 8 + itemp
								itemp: (as integer! sbuf/3) << 16 + itemp
								itemp: (as integer! sbuf/4) << 24 + itemp
								rfp/1: as float32! itemp
								rfp/1: rfp/1 / M2FLOAT32
							]
							set-type = ASAMPLE-TYPE-F32 [
								ftemp: as float32! 0.0
								bp: as byte-ptr! :ftemp
								bp/1: sbuf/1
								bp/2: sbuf/2
								bp/3: sbuf/3
								bp/4: sbuf/4
								rfp/1: ftemp
							]
						]
					]
					real-type = ASAMPLE-TYPE-I32 [
						case [
							set-type = ASAMPLE-TYPE-I16 [
								rbuf/1: #"^(00)"
								rbuf/2: #"^(00)"
								rbuf/3: sbuf/1
								rbuf/4: sbuf/2
							]
							set-type = ASAMPLE-TYPE-I32 [
								rbuf/1: sbuf/1
								rbuf/2: sbuf/2
								rbuf/3: sbuf/3
								rbuf/4: sbuf/4
							]
							set-type = ASAMPLE-TYPE-F32 [
								ftemp: as float32! 0.0
								bp: as byte-ptr! :ftemp
								bp/1: sbuf/1
								bp/2: sbuf/2
								bp/3: sbuf/3
								bp/4: sbuf/4
								rip/1: as integer! ftemp
							]
						]
					]
					real-type = ASAMPLE-TYPE-I16 [
						case [
							set-type = ASAMPLE-TYPE-I16 [
								rbuf/1: sbuf/1
								rbuf/2: sbuf/2
							]
							set-type = ASAMPLE-TYPE-I32 [
								rbuf/1: sbuf/3
								rbuf/2: sbuf/4
							]
							set-type = ASAMPLE-TYPE-F32 [
								ftemp: as float32! 0.0
								bp: as byte-ptr! :ftemp
								bp/1: sbuf/1
								bp/2: sbuf/2
								bp/3: sbuf/3
								bp/4: sbuf/4
								rbuf/1: as byte! ((as integer! ftemp) >> 16)
								rbuf/2: as byte! ((as integer! ftemp) >> 24)
							]
						]
					]
				]
				count: count + 1
			]
			frame: frame + 1
		]
		buffer: buffer + (out/frames-count * out/stride * sw)
		if buffer >= ebuffer [
			audio-device/inner-stop dev
		]
	]

	init: func [
		type		[AUDIO-SAMPLE-TYPE!]
		rtype		[int-ptr!]
		channel		[CHANNEL-TYPE!]
		rate		[integer!]
		return:		[logic!]
	][
		audio/init
		dev: audio/default-output-device
		if null? dev [
			print-line "can't find default playback device"
			return false
		]
		rtype/1: type
		unless audio-device/set-sample-format dev type [
			unless audio-device/set-sample-format dev ASAMPLE-TYPE-F32 [
				print-line "no support sample format"
				return false
			]
			print-line "warning: using float32! sample format"
			rtype/1: ASAMPLE-TYPE-F32
		]
		unless audio-device/set-channels-type dev channel [
			print-line ["can't set channel: " channel]
			return false
		]
		unless audio-device/set-sample-rate dev rate [
			print-line ["can't set rate: " rate]
			return false
		]
		audio/dump-device dev
		set-type: type
		real-type: rtype/1
		true
	]
	run: func [
		buf			[byte-ptr!]
		blen		[integer!]
		return:		[logic!]
	][
		buffer: buf
		buf-len: blen
		ebuffer: buf + blen
		pos: 0
		unless audio-device/connect dev as int-ptr! :wave-cb [
			print-line "can't connect device"
			return false
		]
		unless audio-device/start dev null null [
			print-line "can't start device"
			return false
		]
		audio-device/wait dev
		true
	]
	close: func [][
		audio/free-device dev
		audio/close
	]
]