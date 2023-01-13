; void *memset( void *dest, int c, size_t count );
memset proto far c dest:word, char:word, count:word

; int memcmp( const void *buf1, const void *buf2, size_t count );
memcmp proto far c buf1:word, buf2:word, count:word

; void *memcpy( void *dest, const void *src, size_t count );
memcpy proto far c dest:word, src:word, count:word

; size_t strlen( const char *string );
strlen proto far c string:word

; int strcmp( const char *string1, const char *string2 );
strcmp proto far c string1:word, string2:word

; char *strcpy( char *strDestination, const char *strSource );
strcpy proto far c strDestination:word, strSource:word

; char *strcat( char *strDestination, const char *strSource );
strcat proto far c strDestination:word, strSource:word
