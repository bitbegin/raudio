Red/System []


AUDIO-CLOCK!: alias struct! [
	t1				[integer!]
	t2				[integer!]
	t3				[integer!]
	t4				[integer!]
]

OS-audio: context [

	dev-monitor: declare integer!

	#import [
		LIBC-file cdecl [
			usleep: "usleep" [
				us			[integer!]
				return:		[integer!]
			]
			sec.sleep: "sleep" [
				s			[integer!]
				return:		[integer!]
			]
		]
	]

	#import [
		"libasound.so.2" cdecl [
			snd_pcm_type_name: "snd_pcm_type_name" [
				type		[integer!]
				return:		[c-string!]
			]
			snd_pcm_stream_name: "snd_pcm_stream_name" [
				stream		[integer!]
				return:		[c-string!]
			]
			snd_pcm_access_name: "snd_pcm_access_name" [
				access		[integer!]
				return:		[c-string!]
			]
			snd_pcm_format_name: "snd_pcm_format_name" [
				format		[integer!]
				return:		[c-string!]
			]
			snd_pcm_format_description: "snd_pcm_format_description" [
				format		[integer!]
				return:		[c-string!]
			]
			snd_pcm_subformat_name: "snd_pcm_subformat_name" [
				subformat	[integer!]
				return:		[c-string!]
			]
			snd_pcm_subformat_description: "snd_pcm_subformat_description" [
				subformat	[integer!]
				return:		[c-string!]
			]
			snd_pcm_format_value: "snd_pcm_format_value" [
				name		[c-string!]
				return:		[integer!]
			]
			snd_pcm_tstamp_mode_name: "snd_pcm_tstamp_mode_name" [
				mode		[integer!]
				return:		[c-string!]
			]
			snd_pcm_state_name: "snd_pcm_state_name" [
				state		[integer!]
				return:		[c-string!]
			]
			snd_device_name_hint: "snd_device_name_hint" [
				card		[integer!]
				iface		[c-string!]
				hints		[int-ptr!]
				return:		[integer!]
			]
			snd_device_name_free_hint: "snd_device_name_free_hint" [
				hints		[integer!]
				return:		[integer!]
			]
			snd_device_name_get_hint: "snd_device_name_get_hint" [
				hint		[int-ptr!]
				id			[c-string!]
				return:		[c-string!]
			]
		]
	]

	ALSA-DEVICE!: alias struct! [
		type			[AUDIO-DEVICE-TYPE!]
		id				[unicode-string!]				;-- unicode format
		name			[unicode-string!]				;-- unicode format
		sample-type		[AUDIO-SAMPLE-TYPE!]
		io-cb			[int-ptr!]
		stop-cb			[int-ptr!]
		running?		[logic!]
		buffer-size		[integer!]
	]

	init: func [
		return:		[logic!]
	][
		dev-monitor: 0
		true
	]

	close: does [
		0
	]

	get-device-name: func [
		hint		[int-ptr!]
		return:		[unicode-string!]
		/local
			name	[c-string!]
			ustr	[unicode-string!]
	][
		name: snd_device_name_get_hint hint "NAME"
		if null? name [return null]
		ustr: type-string/load-utf8 as byte-ptr! name
		free as byte-ptr! name
		ustr
	]

	get-device-type: func [
		hint		[int-ptr!]
		;return:		[unicode-string!]
		/local
			name	[c-string!]
			;ustr	[unicode-string!]
	][
		name: snd_device_name_get_hint hint "IOID"
		if null? name [exit]
		print-line name
		;ustr: type-string/load-utf8 as byte-ptr! name
		free as byte-ptr! name
		;ustr
	]

	init-device: func [
		dev			[ALSA-DEVICE!]
		hint		[int-ptr!]
	][
		set-memory as byte-ptr! dev #"^(00)" size? ALSA-DEVICE!
		dev/name: get-device-name hint
		get-device-type hint
		dev/running?: no
	]

	dump-device: func [
		dev			[AUDIO-DEVICE!]
		/local
			adev	[ALSA-DEVICE!]
	][
		if null? dev [print-line "null device!" exit]
		adev: as ALSA-DEVICE! dev
		print-line "================================"
		print-line ["dev: " dev]
		either adev/type = ADEVICE-TYPE-OUTPUT [
			print-line "    type: speaker"
		][
			print-line "    type: microphone"
		]
		;print-line ["    id: " cdev/id]
		print "    name: "
		type-string/uprint adev/name
		print lf
		;print-line ["^/    channels: " cdev/buff-list/mBuffers/mNumberChannels]
		;print-line ["    sample rate: " sample-rate dev]
		;print-line ["    buffer frames: " buffer-size dev]
		print-line "================================"
	]

	default-device: func [
		type		[AUDIO-DEVICE-TYPE!]
		return:		[AUDIO-DEVICE!]
		/local
			hints	[integer!]
			hint	[int-ptr!]
			hr		[integer!]
			name	[c-string!]
			ioid	[c-string!]
			adev	[ALSA-DEVICE!]
	][
		hints: 0
		hr: snd_device_name_hint -1 "pcm" :hints
		if hr <> 0 [return null]
		hint: as int-ptr! hints
		while [hint/1 <> 0][
			name: snd_device_name_get_hint as int-ptr! hint/1 "NAME"
			if 0 = compare-memory as byte-ptr! name as byte-ptr! "default" 8 [
				ioid: snd_device_name_get_hint as int-ptr! hint/1 "IOID"
				if any [
					null? ioid
					all [
						0 = compare-memory as byte-ptr! ioid as byte-ptr! "Input" 6
						type = ADEVICE-TYPE-INPUT
					]
					all [
						0 = compare-memory as byte-ptr! ioid as byte-ptr! "Output" 7
						type = ADEVICE-TYPE-OUTPUT
					]
				][
					adev: as ALSA-DEVICE! allocate size? ALSA-DEVICE!
					set-memory as byte-ptr! adev #"^(00)" size? ALSA-DEVICE!
					adev/name: type-string/load-utf8 as byte-ptr! name
					adev/type: type
					adev/running?: no
					free as byte-ptr! name
					unless null? ioid [
						free as byte-ptr! ioid
					]
					snd_device_name_free_hint hints
					return as AUDIO-DEVICE! adev
				]
			]
			hint: hint + 1
		]
		snd_device_name_free_hint hints
		null
	]

	default-input-device: func [
		return: [AUDIO-DEVICE!]
	][
		default-device ADEVICE-TYPE-INPUT
	]

	default-output-device: func [
		return: [AUDIO-DEVICE!]
	][
		default-device ADEVICE-TYPE-OUTPUT
	]

	get-devices: func [
		type		[AUDIO-DEVICE-TYPE!]
		count		[int-ptr!]			;-- number of input devices
		return:		[AUDIO-DEVICE!]		;-- an array of AUDIO-DEVICE!
		/local
			hints	[integer!]
			hint	[int-ptr!]
			num		[integer!]
			ioid	[c-string!]
			hr		[integer!]
			list	[int-ptr!]
			iter	[int-ptr!]
			adev	[ALSA-DEVICE!]
	][
		count/1: 0
		hints: 0
		hr: snd_device_name_hint -1 "pcm" :hints
		if hr <> 0 [return null]
		hint: as int-ptr! hints
		num: 0
		while [hint/1 <> 0][
			ioid: snd_device_name_get_hint as int-ptr! hint/1 "IOID"
			if any [
				null? ioid
				all [
					0 = compare-memory as byte-ptr! ioid as byte-ptr! "Input" 6
					type = ADEVICE-TYPE-INPUT
				]
				all [
					0 = compare-memory as byte-ptr! ioid as byte-ptr! "Output" 7
					type = ADEVICE-TYPE-OUTPUT
				]
			][
				num: num + 1
				unless null? ioid [
					free as byte-ptr! ioid
				]
			]
			hint: hint + 1
		]
		if num = 0 [
			snd_device_name_free_hint hints
			return null
		]
		count/1: num
		list: as int-ptr! allocate num + 1 * 4
		iter: list + num
		iter/1: 0
		iter: list
		hint: as int-ptr! hints
		while [hint/1 <> 0][
			ioid: snd_device_name_get_hint as int-ptr! hint/1 "IOID"
			if any [
				null? ioid
				all [
					0 = compare-memory as byte-ptr! ioid as byte-ptr! "Input" 6
					type = ADEVICE-TYPE-INPUT
				]
				all [
					0 = compare-memory as byte-ptr! ioid as byte-ptr! "Output" 7
					type = ADEVICE-TYPE-OUTPUT
				]
			][
				unless null? ioid [
					free as byte-ptr! ioid
				]
				adev: as ALSA-DEVICE! allocate size? ALSA-DEVICE!
				set-memory as byte-ptr! adev #"^(00)" size? ALSA-DEVICE!
				adev/name: get-device-name as int-ptr! hint/1
				adev/type: type
				adev/running?: no
				iter/1: as integer! adev
				iter: iter + 1
			]
			hint: hint + 1
		]
		snd_device_name_free_hint hints
		list
	]

	input-devices: func [
		count		[int-ptr!]				;-- number of input devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		get-devices ADEVICE-TYPE-INPUT count
	]

	output-devices: func [
		count		[int-ptr!]				;-- number of output devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
	][
		get-devices ADEVICE-TYPE-OUTPUT count
	]

	all-devices: func [
		count		[int-ptr!]				;-- number of devices
		return:		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
		/local
			count1	[integer!]
			list1	[int-ptr!]
			count2	[integer!]
			list2	[int-ptr!]
			total	[integer!]
			list	[int-ptr!]
			end		[int-ptr!]
	][
		count/1: 0
		count1: 0
		list1: output-devices :count1
		if null? list1 [count1: 0]
		count2: 0
		list2: input-devices :count2
		if null? list2 [count2: 0]
		if all [count1 = 0 count2 = 0][return null]
		total: count1 + count2
		list: as int-ptr! allocate total + 1 * 4
		end: list + count/1
		end/1: 0
		if count1 <> 0 [
			copy-memory as byte-ptr! list as byte-ptr! list1 count1 * 4
			free as byte-ptr! list1
		]
		if count2 <> 0 [
			copy-memory as byte-ptr! list + count1 as byte-ptr! list2 count2 * 4
			free as byte-ptr! list2
		]
		count/1: total
		list
	]

	free-device: func [
		dev			[AUDIO-DEVICE!]
		/local
			adev	[ALSA-DEVICE!]
	][
		if null? dev [exit]
		;-- stop dev
		adev: as ALSA-DEVICE! dev
		type-string/release adev/name
		free as byte-ptr! adev
	]

	free-devices: func [
		devs		[AUDIO-DEVICE!]			;-- an array of AUDIO-DEVICE!
		count		[integer!]				;-- number of devices
		/local
			p		[byte-ptr!]
	][
		if null? devs [exit]
		p: as byte-ptr! devs
		loop count [
			free-device as AUDIO-DEVICE! devs/1
			devs: devs + 1
		]
		free p
	]

	name: func [
		dev			[AUDIO-DEVICE!]
		return:		[unicode-string!]
	][
		null
	]

	id: func [
		dev			[AUDIO-DEVICE!]
		return:		[int-ptr!]
	][
		null
	]

	channels-count: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		0
	]

	buffer-size: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		0
	]

	set-buffer-size: func [
		dev			[AUDIO-DEVICE!]
		count		[integer!]
		return:		[logic!]
	][
		true
	]

	sample-rate: func [
		dev			[AUDIO-DEVICE!]
		return:		[integer!]
	][
		0
	]

	set-sample-rate: func [
		dev			[AUDIO-DEVICE!]
		rate		[integer!]
		return:		[logic!]
	][
		true
	]

	input?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		false
	]

	output?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		false
	]

	running?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		no
	]

	has-unprocessed-io?: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		no
	]

	connect: func [
		dev			[AUDIO-DEVICE!]
		stype		[AUDIO-SAMPLE-TYPE!]
		io-cb		[int-ptr!]
		return:		[logic!]
	][
		true
	]

	start: func [
		dev			[audio-device!]
		start-cb	[int-ptr!]				;-- audio-device-callback!
		stop-cb		[int-ptr!]				;-- audio-device-callback!
		return:		[logic!]
	][
		yes
	]

	stop: func [
		dev			[AUDIO-DEVICE!]
		return:		[logic!]
	][
		true
	]

	wait: func [
		dev			[AUDIO-DEVICE!]
	][
		0
	]

	sleep: func [
		ms			[integer!]
		/local
			s		[integer!]
			r		[integer!]
	][
		s: ms / 1000
		if s <> 0 [
			sec.sleep s
		]
		r: ms - (s * 1000)
		if r <> 0 [
			r: r * 1000
			usleep r
		]
	]

	init-monitor: func [
	][
		0
	]

	free-monitor: func [
	][
		0
	]

	set-device-changed-callback: func [
		event			[AUDIO-DEVICE-EVENT!]
		cb				[int-ptr!]				;-- audio-changed-callback!
	][
		0
	]

	free-device-changed-callback: func [
	][
		0
		free-monitor
	]
]

