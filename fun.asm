
_fun:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"
#include "fs.h"
int main ()
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
 	
	printf(2, "~~HELLO~~");
  11:	83 ec 08             	sub    $0x8,%esp
  14:	68 bc 07 00 00       	push   $0x7bc
  19:	6a 02                	push   $0x2
  1b:	e8 e6 03 00 00       	call   406 <printf>
  20:	83 c4 10             	add    $0x10,%esp
	return 0;
  23:	b8 00 00 00 00       	mov    $0x0,%eax
}
  28:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  2b:	c9                   	leave  
  2c:	8d 61 fc             	lea    -0x4(%ecx),%esp
  2f:	c3                   	ret    

00000030 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  30:	55                   	push   %ebp
  31:	89 e5                	mov    %esp,%ebp
  33:	57                   	push   %edi
  34:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  35:	8b 4d 08             	mov    0x8(%ebp),%ecx
  38:	8b 55 10             	mov    0x10(%ebp),%edx
  3b:	8b 45 0c             	mov    0xc(%ebp),%eax
  3e:	89 cb                	mov    %ecx,%ebx
  40:	89 df                	mov    %ebx,%edi
  42:	89 d1                	mov    %edx,%ecx
  44:	fc                   	cld    
  45:	f3 aa                	rep stos %al,%es:(%edi)
  47:	89 ca                	mov    %ecx,%edx
  49:	89 fb                	mov    %edi,%ebx
  4b:	89 5d 08             	mov    %ebx,0x8(%ebp)
  4e:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  51:	90                   	nop
  52:	5b                   	pop    %ebx
  53:	5f                   	pop    %edi
  54:	5d                   	pop    %ebp
  55:	c3                   	ret    

00000056 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  56:	55                   	push   %ebp
  57:	89 e5                	mov    %esp,%ebp
  59:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  5c:	8b 45 08             	mov    0x8(%ebp),%eax
  5f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  62:	90                   	nop
  63:	8b 45 08             	mov    0x8(%ebp),%eax
  66:	8d 50 01             	lea    0x1(%eax),%edx
  69:	89 55 08             	mov    %edx,0x8(%ebp)
  6c:	8b 55 0c             	mov    0xc(%ebp),%edx
  6f:	8d 4a 01             	lea    0x1(%edx),%ecx
  72:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  75:	0f b6 12             	movzbl (%edx),%edx
  78:	88 10                	mov    %dl,(%eax)
  7a:	0f b6 00             	movzbl (%eax),%eax
  7d:	84 c0                	test   %al,%al
  7f:	75 e2                	jne    63 <strcpy+0xd>
    ;
  return os;
  81:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  84:	c9                   	leave  
  85:	c3                   	ret    

00000086 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  86:	55                   	push   %ebp
  87:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  89:	eb 08                	jmp    93 <strcmp+0xd>
    p++, q++;
  8b:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  8f:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  93:	8b 45 08             	mov    0x8(%ebp),%eax
  96:	0f b6 00             	movzbl (%eax),%eax
  99:	84 c0                	test   %al,%al
  9b:	74 10                	je     ad <strcmp+0x27>
  9d:	8b 45 08             	mov    0x8(%ebp),%eax
  a0:	0f b6 10             	movzbl (%eax),%edx
  a3:	8b 45 0c             	mov    0xc(%ebp),%eax
  a6:	0f b6 00             	movzbl (%eax),%eax
  a9:	38 c2                	cmp    %al,%dl
  ab:	74 de                	je     8b <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  ad:	8b 45 08             	mov    0x8(%ebp),%eax
  b0:	0f b6 00             	movzbl (%eax),%eax
  b3:	0f b6 d0             	movzbl %al,%edx
  b6:	8b 45 0c             	mov    0xc(%ebp),%eax
  b9:	0f b6 00             	movzbl (%eax),%eax
  bc:	0f b6 c0             	movzbl %al,%eax
  bf:	29 c2                	sub    %eax,%edx
  c1:	89 d0                	mov    %edx,%eax
}
  c3:	5d                   	pop    %ebp
  c4:	c3                   	ret    

000000c5 <strlen>:

uint
strlen(char *s)
{
  c5:	55                   	push   %ebp
  c6:	89 e5                	mov    %esp,%ebp
  c8:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  cb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  d2:	eb 04                	jmp    d8 <strlen+0x13>
  d4:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
  d8:	8b 55 fc             	mov    -0x4(%ebp),%edx
  db:	8b 45 08             	mov    0x8(%ebp),%eax
  de:	01 d0                	add    %edx,%eax
  e0:	0f b6 00             	movzbl (%eax),%eax
  e3:	84 c0                	test   %al,%al
  e5:	75 ed                	jne    d4 <strlen+0xf>
    ;
  return n;
  e7:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  ea:	c9                   	leave  
  eb:	c3                   	ret    

000000ec <memset>:

void*
memset(void *dst, int c, uint n)
{
  ec:	55                   	push   %ebp
  ed:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
  ef:	8b 45 10             	mov    0x10(%ebp),%eax
  f2:	50                   	push   %eax
  f3:	ff 75 0c             	pushl  0xc(%ebp)
  f6:	ff 75 08             	pushl  0x8(%ebp)
  f9:	e8 32 ff ff ff       	call   30 <stosb>
  fe:	83 c4 0c             	add    $0xc,%esp
  return dst;
 101:	8b 45 08             	mov    0x8(%ebp),%eax
}
 104:	c9                   	leave  
 105:	c3                   	ret    

00000106 <strchr>:

char*
strchr(const char *s, char c)
{
 106:	55                   	push   %ebp
 107:	89 e5                	mov    %esp,%ebp
 109:	83 ec 04             	sub    $0x4,%esp
 10c:	8b 45 0c             	mov    0xc(%ebp),%eax
 10f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 112:	eb 14                	jmp    128 <strchr+0x22>
    if(*s == c)
 114:	8b 45 08             	mov    0x8(%ebp),%eax
 117:	0f b6 00             	movzbl (%eax),%eax
 11a:	3a 45 fc             	cmp    -0x4(%ebp),%al
 11d:	75 05                	jne    124 <strchr+0x1e>
      return (char*)s;
 11f:	8b 45 08             	mov    0x8(%ebp),%eax
 122:	eb 13                	jmp    137 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 124:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 128:	8b 45 08             	mov    0x8(%ebp),%eax
 12b:	0f b6 00             	movzbl (%eax),%eax
 12e:	84 c0                	test   %al,%al
 130:	75 e2                	jne    114 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 132:	b8 00 00 00 00       	mov    $0x0,%eax
}
 137:	c9                   	leave  
 138:	c3                   	ret    

00000139 <gets>:

char*
gets(char *buf, int max)
{
 139:	55                   	push   %ebp
 13a:	89 e5                	mov    %esp,%ebp
 13c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 13f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 146:	eb 42                	jmp    18a <gets+0x51>
    cc = read(0, &c, 1);
 148:	83 ec 04             	sub    $0x4,%esp
 14b:	6a 01                	push   $0x1
 14d:	8d 45 ef             	lea    -0x11(%ebp),%eax
 150:	50                   	push   %eax
 151:	6a 00                	push   $0x0
 153:	e8 47 01 00 00       	call   29f <read>
 158:	83 c4 10             	add    $0x10,%esp
 15b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 15e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 162:	7e 33                	jle    197 <gets+0x5e>
      break;
    buf[i++] = c;
 164:	8b 45 f4             	mov    -0xc(%ebp),%eax
 167:	8d 50 01             	lea    0x1(%eax),%edx
 16a:	89 55 f4             	mov    %edx,-0xc(%ebp)
 16d:	89 c2                	mov    %eax,%edx
 16f:	8b 45 08             	mov    0x8(%ebp),%eax
 172:	01 c2                	add    %eax,%edx
 174:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 178:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 17a:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 17e:	3c 0a                	cmp    $0xa,%al
 180:	74 16                	je     198 <gets+0x5f>
 182:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 186:	3c 0d                	cmp    $0xd,%al
 188:	74 0e                	je     198 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 18a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 18d:	83 c0 01             	add    $0x1,%eax
 190:	3b 45 0c             	cmp    0xc(%ebp),%eax
 193:	7c b3                	jl     148 <gets+0xf>
 195:	eb 01                	jmp    198 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 197:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 198:	8b 55 f4             	mov    -0xc(%ebp),%edx
 19b:	8b 45 08             	mov    0x8(%ebp),%eax
 19e:	01 d0                	add    %edx,%eax
 1a0:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1a3:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1a6:	c9                   	leave  
 1a7:	c3                   	ret    

000001a8 <stat>:

int
stat(char *n, struct stat *st)
{
 1a8:	55                   	push   %ebp
 1a9:	89 e5                	mov    %esp,%ebp
 1ab:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ae:	83 ec 08             	sub    $0x8,%esp
 1b1:	6a 00                	push   $0x0
 1b3:	ff 75 08             	pushl  0x8(%ebp)
 1b6:	e8 0c 01 00 00       	call   2c7 <open>
 1bb:	83 c4 10             	add    $0x10,%esp
 1be:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1c1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1c5:	79 07                	jns    1ce <stat+0x26>
    return -1;
 1c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1cc:	eb 25                	jmp    1f3 <stat+0x4b>
  r = fstat(fd, st);
 1ce:	83 ec 08             	sub    $0x8,%esp
 1d1:	ff 75 0c             	pushl  0xc(%ebp)
 1d4:	ff 75 f4             	pushl  -0xc(%ebp)
 1d7:	e8 03 01 00 00       	call   2df <fstat>
 1dc:	83 c4 10             	add    $0x10,%esp
 1df:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 1e2:	83 ec 0c             	sub    $0xc,%esp
 1e5:	ff 75 f4             	pushl  -0xc(%ebp)
 1e8:	e8 c2 00 00 00       	call   2af <close>
 1ed:	83 c4 10             	add    $0x10,%esp
  return r;
 1f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 1f3:	c9                   	leave  
 1f4:	c3                   	ret    

000001f5 <atoi>:

int
atoi(const char *s)
{
 1f5:	55                   	push   %ebp
 1f6:	89 e5                	mov    %esp,%ebp
 1f8:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 1fb:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 202:	eb 25                	jmp    229 <atoi+0x34>
    n = n*10 + *s++ - '0';
 204:	8b 55 fc             	mov    -0x4(%ebp),%edx
 207:	89 d0                	mov    %edx,%eax
 209:	c1 e0 02             	shl    $0x2,%eax
 20c:	01 d0                	add    %edx,%eax
 20e:	01 c0                	add    %eax,%eax
 210:	89 c1                	mov    %eax,%ecx
 212:	8b 45 08             	mov    0x8(%ebp),%eax
 215:	8d 50 01             	lea    0x1(%eax),%edx
 218:	89 55 08             	mov    %edx,0x8(%ebp)
 21b:	0f b6 00             	movzbl (%eax),%eax
 21e:	0f be c0             	movsbl %al,%eax
 221:	01 c8                	add    %ecx,%eax
 223:	83 e8 30             	sub    $0x30,%eax
 226:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	0f b6 00             	movzbl (%eax),%eax
 22f:	3c 2f                	cmp    $0x2f,%al
 231:	7e 0a                	jle    23d <atoi+0x48>
 233:	8b 45 08             	mov    0x8(%ebp),%eax
 236:	0f b6 00             	movzbl (%eax),%eax
 239:	3c 39                	cmp    $0x39,%al
 23b:	7e c7                	jle    204 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 23d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 240:	c9                   	leave  
 241:	c3                   	ret    

00000242 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 242:	55                   	push   %ebp
 243:	89 e5                	mov    %esp,%ebp
 245:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 248:	8b 45 08             	mov    0x8(%ebp),%eax
 24b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 24e:	8b 45 0c             	mov    0xc(%ebp),%eax
 251:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 254:	eb 17                	jmp    26d <memmove+0x2b>
    *dst++ = *src++;
 256:	8b 45 fc             	mov    -0x4(%ebp),%eax
 259:	8d 50 01             	lea    0x1(%eax),%edx
 25c:	89 55 fc             	mov    %edx,-0x4(%ebp)
 25f:	8b 55 f8             	mov    -0x8(%ebp),%edx
 262:	8d 4a 01             	lea    0x1(%edx),%ecx
 265:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 268:	0f b6 12             	movzbl (%edx),%edx
 26b:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 26d:	8b 45 10             	mov    0x10(%ebp),%eax
 270:	8d 50 ff             	lea    -0x1(%eax),%edx
 273:	89 55 10             	mov    %edx,0x10(%ebp)
 276:	85 c0                	test   %eax,%eax
 278:	7f dc                	jg     256 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 27a:	8b 45 08             	mov    0x8(%ebp),%eax
}
 27d:	c9                   	leave  
 27e:	c3                   	ret    

0000027f <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 27f:	b8 01 00 00 00       	mov    $0x1,%eax
 284:	cd 40                	int    $0x40
 286:	c3                   	ret    

00000287 <exit>:
SYSCALL(exit)
 287:	b8 02 00 00 00       	mov    $0x2,%eax
 28c:	cd 40                	int    $0x40
 28e:	c3                   	ret    

0000028f <wait>:
SYSCALL(wait)
 28f:	b8 03 00 00 00       	mov    $0x3,%eax
 294:	cd 40                	int    $0x40
 296:	c3                   	ret    

00000297 <pipe>:
SYSCALL(pipe)
 297:	b8 04 00 00 00       	mov    $0x4,%eax
 29c:	cd 40                	int    $0x40
 29e:	c3                   	ret    

0000029f <read>:
SYSCALL(read)
 29f:	b8 05 00 00 00       	mov    $0x5,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <write>:
SYSCALL(write)
 2a7:	b8 10 00 00 00       	mov    $0x10,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <close>:
SYSCALL(close)
 2af:	b8 15 00 00 00       	mov    $0x15,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <kill>:
SYSCALL(kill)
 2b7:	b8 06 00 00 00       	mov    $0x6,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <exec>:
SYSCALL(exec)
 2bf:	b8 07 00 00 00       	mov    $0x7,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <open>:
SYSCALL(open)
 2c7:	b8 0f 00 00 00       	mov    $0xf,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <mknod>:
SYSCALL(mknod)
 2cf:	b8 11 00 00 00       	mov    $0x11,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <unlink>:
SYSCALL(unlink)
 2d7:	b8 12 00 00 00       	mov    $0x12,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <fstat>:
SYSCALL(fstat)
 2df:	b8 08 00 00 00       	mov    $0x8,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <link>:
SYSCALL(link)
 2e7:	b8 13 00 00 00       	mov    $0x13,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <mkdir>:
SYSCALL(mkdir)
 2ef:	b8 14 00 00 00       	mov    $0x14,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <chdir>:
SYSCALL(chdir)
 2f7:	b8 09 00 00 00       	mov    $0x9,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <dup>:
SYSCALL(dup)
 2ff:	b8 0a 00 00 00       	mov    $0xa,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <getpid>:
SYSCALL(getpid)
 307:	b8 0b 00 00 00       	mov    $0xb,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <sbrk>:
SYSCALL(sbrk)
 30f:	b8 0c 00 00 00       	mov    $0xc,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <sleep>:
SYSCALL(sleep)
 317:	b8 0d 00 00 00       	mov    $0xd,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <uptime>:
SYSCALL(uptime)
 31f:	b8 0e 00 00 00       	mov    $0xe,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <fun>:
SYSCALL(fun)
 327:	b8 16 00 00 00       	mov    $0x16,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 32f:	55                   	push   %ebp
 330:	89 e5                	mov    %esp,%ebp
 332:	83 ec 18             	sub    $0x18,%esp
 335:	8b 45 0c             	mov    0xc(%ebp),%eax
 338:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 33b:	83 ec 04             	sub    $0x4,%esp
 33e:	6a 01                	push   $0x1
 340:	8d 45 f4             	lea    -0xc(%ebp),%eax
 343:	50                   	push   %eax
 344:	ff 75 08             	pushl  0x8(%ebp)
 347:	e8 5b ff ff ff       	call   2a7 <write>
 34c:	83 c4 10             	add    $0x10,%esp
}
 34f:	90                   	nop
 350:	c9                   	leave  
 351:	c3                   	ret    

00000352 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 352:	55                   	push   %ebp
 353:	89 e5                	mov    %esp,%ebp
 355:	53                   	push   %ebx
 356:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 359:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 360:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 364:	74 17                	je     37d <printint+0x2b>
 366:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 36a:	79 11                	jns    37d <printint+0x2b>
    neg = 1;
 36c:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 373:	8b 45 0c             	mov    0xc(%ebp),%eax
 376:	f7 d8                	neg    %eax
 378:	89 45 ec             	mov    %eax,-0x14(%ebp)
 37b:	eb 06                	jmp    383 <printint+0x31>
  } else {
    x = xx;
 37d:	8b 45 0c             	mov    0xc(%ebp),%eax
 380:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 383:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 38a:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 38d:	8d 41 01             	lea    0x1(%ecx),%eax
 390:	89 45 f4             	mov    %eax,-0xc(%ebp)
 393:	8b 5d 10             	mov    0x10(%ebp),%ebx
 396:	8b 45 ec             	mov    -0x14(%ebp),%eax
 399:	ba 00 00 00 00       	mov    $0x0,%edx
 39e:	f7 f3                	div    %ebx
 3a0:	89 d0                	mov    %edx,%eax
 3a2:	0f b6 80 20 0a 00 00 	movzbl 0xa20(%eax),%eax
 3a9:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3ad:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3b0:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3b3:	ba 00 00 00 00       	mov    $0x0,%edx
 3b8:	f7 f3                	div    %ebx
 3ba:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3bd:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3c1:	75 c7                	jne    38a <printint+0x38>
  if(neg)
 3c3:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3c7:	74 2d                	je     3f6 <printint+0xa4>
    buf[i++] = '-';
 3c9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3cc:	8d 50 01             	lea    0x1(%eax),%edx
 3cf:	89 55 f4             	mov    %edx,-0xc(%ebp)
 3d2:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 3d7:	eb 1d                	jmp    3f6 <printint+0xa4>
    putc(fd, buf[i]);
 3d9:	8d 55 dc             	lea    -0x24(%ebp),%edx
 3dc:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3df:	01 d0                	add    %edx,%eax
 3e1:	0f b6 00             	movzbl (%eax),%eax
 3e4:	0f be c0             	movsbl %al,%eax
 3e7:	83 ec 08             	sub    $0x8,%esp
 3ea:	50                   	push   %eax
 3eb:	ff 75 08             	pushl  0x8(%ebp)
 3ee:	e8 3c ff ff ff       	call   32f <putc>
 3f3:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 3f6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 3fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 3fe:	79 d9                	jns    3d9 <printint+0x87>
    putc(fd, buf[i]);
}
 400:	90                   	nop
 401:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 404:	c9                   	leave  
 405:	c3                   	ret    

00000406 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 406:	55                   	push   %ebp
 407:	89 e5                	mov    %esp,%ebp
 409:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 40c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 413:	8d 45 0c             	lea    0xc(%ebp),%eax
 416:	83 c0 04             	add    $0x4,%eax
 419:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 41c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 423:	e9 59 01 00 00       	jmp    581 <printf+0x17b>
    c = fmt[i] & 0xff;
 428:	8b 55 0c             	mov    0xc(%ebp),%edx
 42b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 42e:	01 d0                	add    %edx,%eax
 430:	0f b6 00             	movzbl (%eax),%eax
 433:	0f be c0             	movsbl %al,%eax
 436:	25 ff 00 00 00       	and    $0xff,%eax
 43b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 43e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 442:	75 2c                	jne    470 <printf+0x6a>
      if(c == '%'){
 444:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 448:	75 0c                	jne    456 <printf+0x50>
        state = '%';
 44a:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 451:	e9 27 01 00 00       	jmp    57d <printf+0x177>
      } else {
        putc(fd, c);
 456:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 459:	0f be c0             	movsbl %al,%eax
 45c:	83 ec 08             	sub    $0x8,%esp
 45f:	50                   	push   %eax
 460:	ff 75 08             	pushl  0x8(%ebp)
 463:	e8 c7 fe ff ff       	call   32f <putc>
 468:	83 c4 10             	add    $0x10,%esp
 46b:	e9 0d 01 00 00       	jmp    57d <printf+0x177>
      }
    } else if(state == '%'){
 470:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 474:	0f 85 03 01 00 00    	jne    57d <printf+0x177>
      if(c == 'd'){
 47a:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 47e:	75 1e                	jne    49e <printf+0x98>
        printint(fd, *ap, 10, 1);
 480:	8b 45 e8             	mov    -0x18(%ebp),%eax
 483:	8b 00                	mov    (%eax),%eax
 485:	6a 01                	push   $0x1
 487:	6a 0a                	push   $0xa
 489:	50                   	push   %eax
 48a:	ff 75 08             	pushl  0x8(%ebp)
 48d:	e8 c0 fe ff ff       	call   352 <printint>
 492:	83 c4 10             	add    $0x10,%esp
        ap++;
 495:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 499:	e9 d8 00 00 00       	jmp    576 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 49e:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4a2:	74 06                	je     4aa <printf+0xa4>
 4a4:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4a8:	75 1e                	jne    4c8 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4aa:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ad:	8b 00                	mov    (%eax),%eax
 4af:	6a 00                	push   $0x0
 4b1:	6a 10                	push   $0x10
 4b3:	50                   	push   %eax
 4b4:	ff 75 08             	pushl  0x8(%ebp)
 4b7:	e8 96 fe ff ff       	call   352 <printint>
 4bc:	83 c4 10             	add    $0x10,%esp
        ap++;
 4bf:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4c3:	e9 ae 00 00 00       	jmp    576 <printf+0x170>
      } else if(c == 's'){
 4c8:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4cc:	75 43                	jne    511 <printf+0x10b>
        s = (char*)*ap;
 4ce:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4d1:	8b 00                	mov    (%eax),%eax
 4d3:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 4d6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 4da:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 4de:	75 25                	jne    505 <printf+0xff>
          s = "(null)";
 4e0:	c7 45 f4 c6 07 00 00 	movl   $0x7c6,-0xc(%ebp)
        while(*s != 0){
 4e7:	eb 1c                	jmp    505 <printf+0xff>
          putc(fd, *s);
 4e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 4ec:	0f b6 00             	movzbl (%eax),%eax
 4ef:	0f be c0             	movsbl %al,%eax
 4f2:	83 ec 08             	sub    $0x8,%esp
 4f5:	50                   	push   %eax
 4f6:	ff 75 08             	pushl  0x8(%ebp)
 4f9:	e8 31 fe ff ff       	call   32f <putc>
 4fe:	83 c4 10             	add    $0x10,%esp
          s++;
 501:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 505:	8b 45 f4             	mov    -0xc(%ebp),%eax
 508:	0f b6 00             	movzbl (%eax),%eax
 50b:	84 c0                	test   %al,%al
 50d:	75 da                	jne    4e9 <printf+0xe3>
 50f:	eb 65                	jmp    576 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 511:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 515:	75 1d                	jne    534 <printf+0x12e>
        putc(fd, *ap);
 517:	8b 45 e8             	mov    -0x18(%ebp),%eax
 51a:	8b 00                	mov    (%eax),%eax
 51c:	0f be c0             	movsbl %al,%eax
 51f:	83 ec 08             	sub    $0x8,%esp
 522:	50                   	push   %eax
 523:	ff 75 08             	pushl  0x8(%ebp)
 526:	e8 04 fe ff ff       	call   32f <putc>
 52b:	83 c4 10             	add    $0x10,%esp
        ap++;
 52e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 532:	eb 42                	jmp    576 <printf+0x170>
      } else if(c == '%'){
 534:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 538:	75 17                	jne    551 <printf+0x14b>
        putc(fd, c);
 53a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 53d:	0f be c0             	movsbl %al,%eax
 540:	83 ec 08             	sub    $0x8,%esp
 543:	50                   	push   %eax
 544:	ff 75 08             	pushl  0x8(%ebp)
 547:	e8 e3 fd ff ff       	call   32f <putc>
 54c:	83 c4 10             	add    $0x10,%esp
 54f:	eb 25                	jmp    576 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 551:	83 ec 08             	sub    $0x8,%esp
 554:	6a 25                	push   $0x25
 556:	ff 75 08             	pushl  0x8(%ebp)
 559:	e8 d1 fd ff ff       	call   32f <putc>
 55e:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 561:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 564:	0f be c0             	movsbl %al,%eax
 567:	83 ec 08             	sub    $0x8,%esp
 56a:	50                   	push   %eax
 56b:	ff 75 08             	pushl  0x8(%ebp)
 56e:	e8 bc fd ff ff       	call   32f <putc>
 573:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 576:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 57d:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 581:	8b 55 0c             	mov    0xc(%ebp),%edx
 584:	8b 45 f0             	mov    -0x10(%ebp),%eax
 587:	01 d0                	add    %edx,%eax
 589:	0f b6 00             	movzbl (%eax),%eax
 58c:	84 c0                	test   %al,%al
 58e:	0f 85 94 fe ff ff    	jne    428 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 594:	90                   	nop
 595:	c9                   	leave  
 596:	c3                   	ret    

00000597 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 597:	55                   	push   %ebp
 598:	89 e5                	mov    %esp,%ebp
 59a:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 59d:	8b 45 08             	mov    0x8(%ebp),%eax
 5a0:	83 e8 08             	sub    $0x8,%eax
 5a3:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5a6:	a1 3c 0a 00 00       	mov    0xa3c,%eax
 5ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5ae:	eb 24                	jmp    5d4 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5b0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5b3:	8b 00                	mov    (%eax),%eax
 5b5:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5b8:	77 12                	ja     5cc <free+0x35>
 5ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5bd:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5c0:	77 24                	ja     5e6 <free+0x4f>
 5c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5c5:	8b 00                	mov    (%eax),%eax
 5c7:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5ca:	77 1a                	ja     5e6 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5cc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5cf:	8b 00                	mov    (%eax),%eax
 5d1:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5d4:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5d7:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5da:	76 d4                	jbe    5b0 <free+0x19>
 5dc:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5df:	8b 00                	mov    (%eax),%eax
 5e1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5e4:	76 ca                	jbe    5b0 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 5e6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5e9:	8b 40 04             	mov    0x4(%eax),%eax
 5ec:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 5f3:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5f6:	01 c2                	add    %eax,%edx
 5f8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5fb:	8b 00                	mov    (%eax),%eax
 5fd:	39 c2                	cmp    %eax,%edx
 5ff:	75 24                	jne    625 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 601:	8b 45 f8             	mov    -0x8(%ebp),%eax
 604:	8b 50 04             	mov    0x4(%eax),%edx
 607:	8b 45 fc             	mov    -0x4(%ebp),%eax
 60a:	8b 00                	mov    (%eax),%eax
 60c:	8b 40 04             	mov    0x4(%eax),%eax
 60f:	01 c2                	add    %eax,%edx
 611:	8b 45 f8             	mov    -0x8(%ebp),%eax
 614:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 617:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61a:	8b 00                	mov    (%eax),%eax
 61c:	8b 10                	mov    (%eax),%edx
 61e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 621:	89 10                	mov    %edx,(%eax)
 623:	eb 0a                	jmp    62f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 625:	8b 45 fc             	mov    -0x4(%ebp),%eax
 628:	8b 10                	mov    (%eax),%edx
 62a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 62f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 632:	8b 40 04             	mov    0x4(%eax),%eax
 635:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 63c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63f:	01 d0                	add    %edx,%eax
 641:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 644:	75 20                	jne    666 <free+0xcf>
    p->s.size += bp->s.size;
 646:	8b 45 fc             	mov    -0x4(%ebp),%eax
 649:	8b 50 04             	mov    0x4(%eax),%edx
 64c:	8b 45 f8             	mov    -0x8(%ebp),%eax
 64f:	8b 40 04             	mov    0x4(%eax),%eax
 652:	01 c2                	add    %eax,%edx
 654:	8b 45 fc             	mov    -0x4(%ebp),%eax
 657:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 65a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65d:	8b 10                	mov    (%eax),%edx
 65f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 662:	89 10                	mov    %edx,(%eax)
 664:	eb 08                	jmp    66e <free+0xd7>
  } else
    p->s.ptr = bp;
 666:	8b 45 fc             	mov    -0x4(%ebp),%eax
 669:	8b 55 f8             	mov    -0x8(%ebp),%edx
 66c:	89 10                	mov    %edx,(%eax)
  freep = p;
 66e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 671:	a3 3c 0a 00 00       	mov    %eax,0xa3c
}
 676:	90                   	nop
 677:	c9                   	leave  
 678:	c3                   	ret    

00000679 <morecore>:

static Header*
morecore(uint nu)
{
 679:	55                   	push   %ebp
 67a:	89 e5                	mov    %esp,%ebp
 67c:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 67f:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 686:	77 07                	ja     68f <morecore+0x16>
    nu = 4096;
 688:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 68f:	8b 45 08             	mov    0x8(%ebp),%eax
 692:	c1 e0 03             	shl    $0x3,%eax
 695:	83 ec 0c             	sub    $0xc,%esp
 698:	50                   	push   %eax
 699:	e8 71 fc ff ff       	call   30f <sbrk>
 69e:	83 c4 10             	add    $0x10,%esp
 6a1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6a4:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6a8:	75 07                	jne    6b1 <morecore+0x38>
    return 0;
 6aa:	b8 00 00 00 00       	mov    $0x0,%eax
 6af:	eb 26                	jmp    6d7 <morecore+0x5e>
  hp = (Header*)p;
 6b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6b4:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6b7:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6ba:	8b 55 08             	mov    0x8(%ebp),%edx
 6bd:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6c3:	83 c0 08             	add    $0x8,%eax
 6c6:	83 ec 0c             	sub    $0xc,%esp
 6c9:	50                   	push   %eax
 6ca:	e8 c8 fe ff ff       	call   597 <free>
 6cf:	83 c4 10             	add    $0x10,%esp
  return freep;
 6d2:	a1 3c 0a 00 00       	mov    0xa3c,%eax
}
 6d7:	c9                   	leave  
 6d8:	c3                   	ret    

000006d9 <malloc>:

void*
malloc(uint nbytes)
{
 6d9:	55                   	push   %ebp
 6da:	89 e5                	mov    %esp,%ebp
 6dc:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 6df:	8b 45 08             	mov    0x8(%ebp),%eax
 6e2:	83 c0 07             	add    $0x7,%eax
 6e5:	c1 e8 03             	shr    $0x3,%eax
 6e8:	83 c0 01             	add    $0x1,%eax
 6eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 6ee:	a1 3c 0a 00 00       	mov    0xa3c,%eax
 6f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
 6f6:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 6fa:	75 23                	jne    71f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 6fc:	c7 45 f0 34 0a 00 00 	movl   $0xa34,-0x10(%ebp)
 703:	8b 45 f0             	mov    -0x10(%ebp),%eax
 706:	a3 3c 0a 00 00       	mov    %eax,0xa3c
 70b:	a1 3c 0a 00 00       	mov    0xa3c,%eax
 710:	a3 34 0a 00 00       	mov    %eax,0xa34
    base.s.size = 0;
 715:	c7 05 38 0a 00 00 00 	movl   $0x0,0xa38
 71c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 71f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 722:	8b 00                	mov    (%eax),%eax
 724:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 727:	8b 45 f4             	mov    -0xc(%ebp),%eax
 72a:	8b 40 04             	mov    0x4(%eax),%eax
 72d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 730:	72 4d                	jb     77f <malloc+0xa6>
      if(p->s.size == nunits)
 732:	8b 45 f4             	mov    -0xc(%ebp),%eax
 735:	8b 40 04             	mov    0x4(%eax),%eax
 738:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 73b:	75 0c                	jne    749 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 73d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 740:	8b 10                	mov    (%eax),%edx
 742:	8b 45 f0             	mov    -0x10(%ebp),%eax
 745:	89 10                	mov    %edx,(%eax)
 747:	eb 26                	jmp    76f <malloc+0x96>
      else {
        p->s.size -= nunits;
 749:	8b 45 f4             	mov    -0xc(%ebp),%eax
 74c:	8b 40 04             	mov    0x4(%eax),%eax
 74f:	2b 45 ec             	sub    -0x14(%ebp),%eax
 752:	89 c2                	mov    %eax,%edx
 754:	8b 45 f4             	mov    -0xc(%ebp),%eax
 757:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 75a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75d:	8b 40 04             	mov    0x4(%eax),%eax
 760:	c1 e0 03             	shl    $0x3,%eax
 763:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 766:	8b 45 f4             	mov    -0xc(%ebp),%eax
 769:	8b 55 ec             	mov    -0x14(%ebp),%edx
 76c:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 76f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 772:	a3 3c 0a 00 00       	mov    %eax,0xa3c
      return (void*)(p + 1);
 777:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77a:	83 c0 08             	add    $0x8,%eax
 77d:	eb 3b                	jmp    7ba <malloc+0xe1>
    }
    if(p == freep)
 77f:	a1 3c 0a 00 00       	mov    0xa3c,%eax
 784:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 787:	75 1e                	jne    7a7 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 789:	83 ec 0c             	sub    $0xc,%esp
 78c:	ff 75 ec             	pushl  -0x14(%ebp)
 78f:	e8 e5 fe ff ff       	call   679 <morecore>
 794:	83 c4 10             	add    $0x10,%esp
 797:	89 45 f4             	mov    %eax,-0xc(%ebp)
 79a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 79e:	75 07                	jne    7a7 <malloc+0xce>
        return 0;
 7a0:	b8 00 00 00 00       	mov    $0x0,%eax
 7a5:	eb 13                	jmp    7ba <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7a7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7aa:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7ad:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b0:	8b 00                	mov    (%eax),%eax
 7b2:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7b5:	e9 6d ff ff ff       	jmp    727 <malloc+0x4e>
}
 7ba:	c9                   	leave  
 7bb:	c3                   	ret    
