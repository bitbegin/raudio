Red/System []

#include %../src/utils/unicode.reds


u: #{604F7D590CFF520065006400ED8B008A01FF0000}

len: 0
unicode/to-utf8 u null :len

t: allocate len
unicode/to-utf8 u t :len

len2: 0
unicode/to-unicode t null :len2

t2: allocate len2
unicode/to-unicode t t2 :len2

print-line [size? u " " len " " len2]

printf ["%ls^/" t2]
free t
free t2

u: as byte-ptr! "你好，Red语言！"
len3: 0
unicode/to-unicode u null :len3
t3: allocate len3
unicode/to-unicode u t3 :len3
printf ["%ls^/" t3]
free t3
