Red []

to-unicode: function [
	s			[string!]
	return:		[binary!]
][
	ret: make binary! 10
	forall s [
		append ret copy/part reverse to binary! to integer! s/1 2
	]
	append ret #{0000}
	ret
]

print to-unicode "你好，Red语言！"
