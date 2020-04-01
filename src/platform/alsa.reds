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
			snd_pcm_open: "snd_pcm_open" [
				pcm			[int-ptr!]
				name		[c-string!]
				stream		[integer!]
				mode		[integer!]
				return:		[integer!]
			]
			snd_pcm_close: "snd_pcm_close" [
				pcm			[integer!]
				return:		[integer!]
			]
			snd_strerror: "snd_strerror" [
				errnum		[integer!]
				return:		[c-string!]
			]
			snd_pcm_hw_params_malloc: "snd_pcm_hw_params_malloc" [
				ptr			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_free: "snd_pcm_hw_params_free" [
				obj			[integer!]
			]
			snd_pcm_hw_params_copy: "snd_pcm_hw_params_copy" [
				dst			[integer!]
				src			[integer!]
			]
			snd_pcm_hw_params_any: "snd_pcm_hw_params_any" [
				pcm			[integer!]
				params		[integer!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_channels: "snd_pcm_hw_params_get_channels" [
				params		[integer!]
				val			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_channels_min: "snd_pcm_hw_params_get_channels_min" [
				params		[integer!]
				val			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_get_channels_max: "snd_pcm_hw_params_get_channels_max" [
				params		[integer!]
				val			[int-ptr!]
				return:		[integer!]
			]
			snd_pcm_hw_params_test_format: "snd_pcm_hw_params_test_format" [
				pcm			[integer!]
				params		[integer!]
				val			[integer!]
				return:		[integer!]
			]
		]
	]

	#define SND_PCM_FORMAT_S16_LE		2
	#define SND_PCM_FORMAT_S32_LE		10
	#define SND_PCM_FORMAT_FLOAT_LE		14

	ALSA-DEVICE!: alias struct! [
		type			[AUDIO-DEVICE-TYPE!]
		id				[unicode-string!]				;-- unicode format
		name			[unicode-string!]				;-- unicode format
		sample-type		[AUDIO-SAMPLE-TYPE!]
		io-cb			[int-ptr!]
		stop-cb			[int-ptr!]
		running?		[logic!]
		buffer-size		[integer!]
		params			[integer!]
		pcm				[integer!]
	]

	output-filters: [
		"default"		7
		"pulse"			6
		"sysdefault:"	11
		"front:"		6
		"dmix:"			5
		"hw:"			3
		"plughw:"		7
	]

	input-filters: [
		"default"		7
		"pulse"			6
		"front:"		6
		"hw:"			3
		"plughw:"		7
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

	init-device: func [
		adev		[ALSA-DEVICE!]
		pcm			[integer!]
		/local
			hr		[integer!]
			p		[int-ptr!]
			id		[c-string!]
	][
		adev/running?: no
		hr: snd_pcm_hw_params_malloc :adev/params
		if hr <> 0 [exit]
		p: as int-ptr! adev/id
		id: as c-string! p + 1
		hr: snd_pcm_hw_params_any pcm adev/params
	]

	dump-device: func [
		dev			[AUDIO-DEVICE!]
		/local
			adev	[ALSA-DEVICE!]
			val		[integer!]
			hr		[integer!]
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
		print "    id: "
		type-string/uprint adev/id
		print lf
		print "    name: "
		type-string/uprint adev/name
		print lf
		if adev/params <> 0 [
			val: 0
			hr: snd_pcm_hw_params_get_channels adev/params :val
			print-line ["    channels: " val]
		]
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
			pcm		[integer!]
			desc	[c-string!]
	][
		hints: 0
		hr: snd_device_name_hint -1 "pcm" :hints
		if hr <> 0 [return null]
		hint: as int-ptr! hints
		while [hint/1 <> 0][
			name: snd_device_name_get_hint as int-ptr! hint/1 "NAME"
			if 0 = compare-memory as byte-ptr! name as byte-ptr! "default" 7 [
				pcm: 0
				hr: snd_pcm_open :pcm name type 0
				if hr = 0 [
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
						desc: snd_device_name_get_hint as int-ptr! hint/1 "DESC"
						adev: as ALSA-DEVICE! allocate size? ALSA-DEVICE!
						set-memory as byte-ptr! adev #"^(00)" size? ALSA-DEVICE!
						adev/id: type-string/load-utf8 as byte-ptr! name
						unless null? desc [
							adev/name: type-string/load-utf8 as byte-ptr! desc
							free as byte-ptr! desc
						]
						adev/type: type
						init-device adev pcm
						free as byte-ptr! name
						unless null? ioid [
							free as byte-ptr! ioid
						]
						snd_device_name_free_hint hints
						snd_pcm_close pcm
						return as AUDIO-DEVICE! adev
					]
					snd_pcm_close pcm
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

	filter-name: func [
		type		[AUDIO-DEVICE-TYPE!]
		name		[c-string!]
		return:		[logic!]
		/local
			size	[integer!]
			p		[int-ptr!]
			i		[integer!]
			j		[integer!]
	][
		either type = ADEVICE-TYPE-OUTPUT [
			size: size? output-filters
			p: output-filters
		][
			size: size? input-filters
			p: input-filters
		]
		size: size / 2
		loop size [
			if 0 = compare-memory as byte-ptr! name as byte-ptr! p/1 p/2 [
				return true
			]
			p: p + 2
		]
		false
	]

	get-devices: func [
		type		[AUDIO-DEVICE-TYPE!]
		count		[int-ptr!]			;-- number of input devices
		return:		[AUDIO-DEVICE!]		;-- an array of AUDIO-DEVICE!
		/local
			hints	[integer!]
			hint	[int-ptr!]
			num		[integer!]
			name	[c-string!]
			ioid	[c-string!]
			hr		[integer!]
			list	[int-ptr!]
			iter	[int-ptr!]
			end		[int-ptr!]
			flag	[logic!]
			nlist	[int-ptr!]
			niter	[int-ptr!]
			adev	[ALSA-DEVICE!]
			pcm		[integer!]
			desc	[c-string!]
	][
		count/1: 0
		hints: 0
		hr: snd_device_name_hint -1 "pcm" :hints
		if hr <> 0 [return null]
		hint: as int-ptr! hints
		num: 0
		list: system/stack/allocate 256
		iter: list
		end: list + 256
		end/0: 0
		while [hint/1 <> 0][
			name: snd_device_name_get_hint as int-ptr! hint/1 "NAME"
			if any [
				null? name
				0 = compare-memory as byte-ptr! name as byte-ptr! "null" 5
			][
				unless null? name [
					free as byte-ptr! name
				]
				hint: hint + 1
				continue
			]
			flag: false
			ioid: snd_device_name_get_hint as int-ptr! hint/1 "IOID"
			either null? ioid [
				if filter-name type name [
					flag: true
				]
			][
				if all [
					filter-name type name
					any [
						all [
							0 = compare-memory as byte-ptr! ioid as byte-ptr! "Input" 6
							type = ADEVICE-TYPE-INPUT
						]
						all [
							0 = compare-memory as byte-ptr! ioid as byte-ptr! "Output" 7
							type = ADEVICE-TYPE-OUTPUT
						]
					]
				][
					flag: true
				]
			]
			unless null? ioid [
				free as byte-ptr! ioid
			]
			if flag [
				pcm: 0
				hr: snd_pcm_open :pcm name type 0
				if hr = 0 [
					either iter < end [
						desc: snd_device_name_get_hint as int-ptr! hint/1 "DESC"
						adev: as ALSA-DEVICE! allocate size? ALSA-DEVICE!
						set-memory as byte-ptr! adev #"^(00)" size? ALSA-DEVICE!
						adev/id: type-string/load-utf8 as byte-ptr! name
						unless null? desc [
							adev/name: type-string/load-utf8 as byte-ptr! desc
							free as byte-ptr! desc
						]
						adev/type: type
						init-device adev pcm
						iter/1: as integer! adev
						iter: iter + 1
						num: num + 1
						snd_pcm_close pcm
					][
						free as byte-ptr! name
						snd_pcm_close pcm
						break
					]
				]
			]
			free as byte-ptr! name
			hint: hint + 1
		]
		snd_device_name_free_hint hints
		if num = 0 [
			return null
		]
		iter/1: 0
		count/1: num
		nlist: as int-ptr! allocate num + 1 * 4
		niter: list + num
		niter/1: 0
		copy-memory as byte-ptr! nlist as byte-ptr! list num * 4
		nlist
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
		type-string/release adev/id
		type-string/release adev/name
		if adev/params <> 0 [
			snd_pcm_hw_params_free adev/params
		]
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
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/name
	]

	id: func [
		dev			[AUDIO-DEVICE!]
		return:		[unicode-string!]
		/local
			adev	[ALSA-DEVICE!]
	][
		adev: as ALSA-DEVICE! dev
		adev/id
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
		/local
			adev	[ALSA-DEVICE!]
			format	[integer!]
			p		[int-ptr!]
			id		[c-string!]
			hr		[integer!]
	][
		adev: as ALSA-DEVICE! dev
		if adev/running? [return false]
		format: case [
			stype = ASAMPLE-TYPE-F32 [SND_PCM_FORMAT_FLOAT_LE]
			stype = ASAMPLE-TYPE-I32 [SND_PCM_FORMAT_S32_LE]
			stype = ASAMPLE-TYPE-I16 [SND_PCM_FORMAT_S16_LE]
		]
		p: as int-ptr! adev/id
		id: as c-string! p + 1
		hr: snd_pcm_open :adev/pcm id adev/type 0
		if hr <> 0 [return false]
		hr: snd_pcm_hw_params_test_format adev/pcm adev/params format
		if hr <> 0 [
			snd_pcm_close adev/pcm
			return false
		]
		snd_pcm_close adev/pcm
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

