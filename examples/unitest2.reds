Red/System []

#include %../src/utils/unicode.reds

u: #{604F7D590CFF520065006400ED8B008A01FF0000}
s: type-string/load-unicode u
type-string/uprint s
print lf
type-string/release s

u2: as byte-ptr! "你好，Red语言！"
s: type-string/load-utf8 u2
type-string/uprint s
print lf
type-string/release s


