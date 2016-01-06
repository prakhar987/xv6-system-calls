
_mkdir:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

int
main(int argc, char *argv[])
{
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	53                   	push   %ebx
   e:	51                   	push   %ecx
   f:	83 ec 10             	sub    $0x10,%esp
  12:	89 cb                	mov    %ecx,%ebx
  int i;

  if(argc < 2){
  14:	83 3b 01             	cmpl   $0x1,(%ebx)
  17:	7f 17                	jg     30 <main+0x30>
    printf(2, "Usage: mkdir files...\n");
  19:	83 ec 08             	sub    $0x8,%esp
  1c:	68 1c 08 00 00       	push   $0x81c
  21:	6a 02                	push   $0x2
  23:	e8 3e 04 00 00       	call   466 <printf>
  28:	83 c4 10             	add    $0x10,%esp
    exit();
  2b:	e8 b7 02 00 00       	call   2e7 <exit>
  }

  for(i = 1; i < argc; i++){
  30:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  37:	eb 4b                	jmp    84 <main+0x84>
    if(mkdir(argv[i]) < 0){
  39:	8b 45 f4             	mov    -0xc(%ebp),%eax
  3c:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  43:	8b 43 04             	mov    0x4(%ebx),%eax
  46:	01 d0                	add    %edx,%eax
  48:	8b 00                	mov    (%eax),%eax
  4a:	83 ec 0c             	sub    $0xc,%esp
  4d:	50                   	push   %eax
  4e:	e8 fc 02 00 00       	call   34f <mkdir>
  53:	83 c4 10             	add    $0x10,%esp
  56:	85 c0                	test   %eax,%eax
  58:	79 26                	jns    80 <main+0x80>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
  5a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  5d:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
  64:	8b 43 04             	mov    0x4(%ebx),%eax
  67:	01 d0                	add    %edx,%eax
  69:	8b 00                	mov    (%eax),%eax
  6b:	83 ec 04             	sub    $0x4,%esp
  6e:	50                   	push   %eax
  6f:	68 33 08 00 00       	push   $0x833
  74:	6a 02                	push   $0x2
  76:	e8 eb 03 00 00       	call   466 <printf>
  7b:	83 c4 10             	add    $0x10,%esp
      break;
  7e:	eb 0b                	jmp    8b <main+0x8b>
  if(argc < 2){
    printf(2, "Usage: mkdir files...\n");
    exit();
  }

  for(i = 1; i < argc; i++){
  80:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
  84:	8b 45 f4             	mov    -0xc(%ebp),%eax
  87:	3b 03                	cmp    (%ebx),%eax
  89:	7c ae                	jl     39 <main+0x39>
      printf(2, "mkdir: %s failed to create\n", argv[i]);
      break;
    }
  }

  exit();
  8b:	e8 57 02 00 00       	call   2e7 <exit>

00000090 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  90:	55                   	push   %ebp
  91:	89 e5                	mov    %esp,%ebp
  93:	57                   	push   %edi
  94:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  95:	8b 4d 08             	mov    0x8(%ebp),%ecx
  98:	8b 55 10             	mov    0x10(%ebp),%edx
  9b:	8b 45 0c             	mov    0xc(%ebp),%eax
  9e:	89 cb                	mov    %ecx,%ebx
  a0:	89 df                	mov    %ebx,%edi
  a2:	89 d1                	mov    %edx,%ecx
  a4:	fc                   	cld    
  a5:	f3 aa                	rep stos %al,%es:(%edi)
  a7:	89 ca                	mov    %ecx,%edx
  a9:	89 fb                	mov    %edi,%ebx
  ab:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ae:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  b1:	90                   	nop
  b2:	5b                   	pop    %ebx
  b3:	5f                   	pop    %edi
  b4:	5d                   	pop    %ebp
  b5:	c3                   	ret    

000000b6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  b6:	55                   	push   %ebp
  b7:	89 e5                	mov    %esp,%ebp
  b9:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  bc:	8b 45 08             	mov    0x8(%ebp),%eax
  bf:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  c2:	90                   	nop
  c3:	8b 45 08             	mov    0x8(%ebp),%eax
  c6:	8d 50 01             	lea    0x1(%eax),%edx
  c9:	89 55 08             	mov    %edx,0x8(%ebp)
  cc:	8b 55 0c             	mov    0xc(%ebp),%edx
  cf:	8d 4a 01             	lea    0x1(%edx),%ecx
  d2:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  d5:	0f b6 12             	movzbl (%edx),%edx
  d8:	88 10                	mov    %dl,(%eax)
  da:	0f b6 00             	movzbl (%eax),%eax
  dd:	84 c0                	test   %al,%al
  df:	75 e2                	jne    c3 <strcpy+0xd>
    ;
  return os;
  e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  e4:	c9                   	leave  
  e5:	c3                   	ret    

000000e6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e6:	55                   	push   %ebp
  e7:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  e9:	eb 08                	jmp    f3 <strcmp+0xd>
    p++, q++;
  eb:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  ef:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  f3:	8b 45 08             	mov    0x8(%ebp),%eax
  f6:	0f b6 00             	movzbl (%eax),%eax
  f9:	84 c0                	test   %al,%al
  fb:	74 10                	je     10d <strcmp+0x27>
  fd:	8b 45 08             	mov    0x8(%ebp),%eax
 100:	0f b6 10             	movzbl (%eax),%edx
 103:	8b 45 0c             	mov    0xc(%ebp),%eax
 106:	0f b6 00             	movzbl (%eax),%eax
 109:	38 c2                	cmp    %al,%dl
 10b:	74 de                	je     eb <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 10d:	8b 45 08             	mov    0x8(%ebp),%eax
 110:	0f b6 00             	movzbl (%eax),%eax
 113:	0f b6 d0             	movzbl %al,%edx
 116:	8b 45 0c             	mov    0xc(%ebp),%eax
 119:	0f b6 00             	movzbl (%eax),%eax
 11c:	0f b6 c0             	movzbl %al,%eax
 11f:	29 c2                	sub    %eax,%edx
 121:	89 d0                	mov    %edx,%eax
}
 123:	5d                   	pop    %ebp
 124:	c3                   	ret    

00000125 <strlen>:

uint
strlen(char *s)
{
 125:	55                   	push   %ebp
 126:	89 e5                	mov    %esp,%ebp
 128:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 12b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 132:	eb 04                	jmp    138 <strlen+0x13>
 134:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 138:	8b 55 fc             	mov    -0x4(%ebp),%edx
 13b:	8b 45 08             	mov    0x8(%ebp),%eax
 13e:	01 d0                	add    %edx,%eax
 140:	0f b6 00             	movzbl (%eax),%eax
 143:	84 c0                	test   %al,%al
 145:	75 ed                	jne    134 <strlen+0xf>
    ;
  return n;
 147:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 14a:	c9                   	leave  
 14b:	c3                   	ret    

0000014c <memset>:

void*
memset(void *dst, int c, uint n)
{
 14c:	55                   	push   %ebp
 14d:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 14f:	8b 45 10             	mov    0x10(%ebp),%eax
 152:	50                   	push   %eax
 153:	ff 75 0c             	pushl  0xc(%ebp)
 156:	ff 75 08             	pushl  0x8(%ebp)
 159:	e8 32 ff ff ff       	call   90 <stosb>
 15e:	83 c4 0c             	add    $0xc,%esp
  return dst;
 161:	8b 45 08             	mov    0x8(%ebp),%eax
}
 164:	c9                   	leave  
 165:	c3                   	ret    

00000166 <strchr>:

char*
strchr(const char *s, char c)
{
 166:	55                   	push   %ebp
 167:	89 e5                	mov    %esp,%ebp
 169:	83 ec 04             	sub    $0x4,%esp
 16c:	8b 45 0c             	mov    0xc(%ebp),%eax
 16f:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 172:	eb 14                	jmp    188 <strchr+0x22>
    if(*s == c)
 174:	8b 45 08             	mov    0x8(%ebp),%eax
 177:	0f b6 00             	movzbl (%eax),%eax
 17a:	3a 45 fc             	cmp    -0x4(%ebp),%al
 17d:	75 05                	jne    184 <strchr+0x1e>
      return (char*)s;
 17f:	8b 45 08             	mov    0x8(%ebp),%eax
 182:	eb 13                	jmp    197 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 184:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 188:	8b 45 08             	mov    0x8(%ebp),%eax
 18b:	0f b6 00             	movzbl (%eax),%eax
 18e:	84 c0                	test   %al,%al
 190:	75 e2                	jne    174 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 192:	b8 00 00 00 00       	mov    $0x0,%eax
}
 197:	c9                   	leave  
 198:	c3                   	ret    

00000199 <gets>:

char*
gets(char *buf, int max)
{
 199:	55                   	push   %ebp
 19a:	89 e5                	mov    %esp,%ebp
 19c:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1a6:	eb 42                	jmp    1ea <gets+0x51>
    cc = read(0, &c, 1);
 1a8:	83 ec 04             	sub    $0x4,%esp
 1ab:	6a 01                	push   $0x1
 1ad:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1b0:	50                   	push   %eax
 1b1:	6a 00                	push   $0x0
 1b3:	e8 47 01 00 00       	call   2ff <read>
 1b8:	83 c4 10             	add    $0x10,%esp
 1bb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1be:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1c2:	7e 33                	jle    1f7 <gets+0x5e>
      break;
    buf[i++] = c;
 1c4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1c7:	8d 50 01             	lea    0x1(%eax),%edx
 1ca:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1cd:	89 c2                	mov    %eax,%edx
 1cf:	8b 45 08             	mov    0x8(%ebp),%eax
 1d2:	01 c2                	add    %eax,%edx
 1d4:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1d8:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1da:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1de:	3c 0a                	cmp    $0xa,%al
 1e0:	74 16                	je     1f8 <gets+0x5f>
 1e2:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e6:	3c 0d                	cmp    $0xd,%al
 1e8:	74 0e                	je     1f8 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ed:	83 c0 01             	add    $0x1,%eax
 1f0:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1f3:	7c b3                	jl     1a8 <gets+0xf>
 1f5:	eb 01                	jmp    1f8 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1f7:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1f8:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1fb:	8b 45 08             	mov    0x8(%ebp),%eax
 1fe:	01 d0                	add    %edx,%eax
 200:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 203:	8b 45 08             	mov    0x8(%ebp),%eax
}
 206:	c9                   	leave  
 207:	c3                   	ret    

00000208 <stat>:

int
stat(char *n, struct stat *st)
{
 208:	55                   	push   %ebp
 209:	89 e5                	mov    %esp,%ebp
 20b:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 20e:	83 ec 08             	sub    $0x8,%esp
 211:	6a 00                	push   $0x0
 213:	ff 75 08             	pushl  0x8(%ebp)
 216:	e8 0c 01 00 00       	call   327 <open>
 21b:	83 c4 10             	add    $0x10,%esp
 21e:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 221:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 225:	79 07                	jns    22e <stat+0x26>
    return -1;
 227:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 22c:	eb 25                	jmp    253 <stat+0x4b>
  r = fstat(fd, st);
 22e:	83 ec 08             	sub    $0x8,%esp
 231:	ff 75 0c             	pushl  0xc(%ebp)
 234:	ff 75 f4             	pushl  -0xc(%ebp)
 237:	e8 03 01 00 00       	call   33f <fstat>
 23c:	83 c4 10             	add    $0x10,%esp
 23f:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 242:	83 ec 0c             	sub    $0xc,%esp
 245:	ff 75 f4             	pushl  -0xc(%ebp)
 248:	e8 c2 00 00 00       	call   30f <close>
 24d:	83 c4 10             	add    $0x10,%esp
  return r;
 250:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 253:	c9                   	leave  
 254:	c3                   	ret    

00000255 <atoi>:

int
atoi(const char *s)
{
 255:	55                   	push   %ebp
 256:	89 e5                	mov    %esp,%ebp
 258:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 25b:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 262:	eb 25                	jmp    289 <atoi+0x34>
    n = n*10 + *s++ - '0';
 264:	8b 55 fc             	mov    -0x4(%ebp),%edx
 267:	89 d0                	mov    %edx,%eax
 269:	c1 e0 02             	shl    $0x2,%eax
 26c:	01 d0                	add    %edx,%eax
 26e:	01 c0                	add    %eax,%eax
 270:	89 c1                	mov    %eax,%ecx
 272:	8b 45 08             	mov    0x8(%ebp),%eax
 275:	8d 50 01             	lea    0x1(%eax),%edx
 278:	89 55 08             	mov    %edx,0x8(%ebp)
 27b:	0f b6 00             	movzbl (%eax),%eax
 27e:	0f be c0             	movsbl %al,%eax
 281:	01 c8                	add    %ecx,%eax
 283:	83 e8 30             	sub    $0x30,%eax
 286:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 289:	8b 45 08             	mov    0x8(%ebp),%eax
 28c:	0f b6 00             	movzbl (%eax),%eax
 28f:	3c 2f                	cmp    $0x2f,%al
 291:	7e 0a                	jle    29d <atoi+0x48>
 293:	8b 45 08             	mov    0x8(%ebp),%eax
 296:	0f b6 00             	movzbl (%eax),%eax
 299:	3c 39                	cmp    $0x39,%al
 29b:	7e c7                	jle    264 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 29d:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2a0:	c9                   	leave  
 2a1:	c3                   	ret    

000002a2 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2a2:	55                   	push   %ebp
 2a3:	89 e5                	mov    %esp,%ebp
 2a5:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2a8:	8b 45 08             	mov    0x8(%ebp),%eax
 2ab:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 2b1:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2b4:	eb 17                	jmp    2cd <memmove+0x2b>
    *dst++ = *src++;
 2b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2b9:	8d 50 01             	lea    0x1(%eax),%edx
 2bc:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2bf:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2c2:	8d 4a 01             	lea    0x1(%edx),%ecx
 2c5:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2c8:	0f b6 12             	movzbl (%edx),%edx
 2cb:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2cd:	8b 45 10             	mov    0x10(%ebp),%eax
 2d0:	8d 50 ff             	lea    -0x1(%eax),%edx
 2d3:	89 55 10             	mov    %edx,0x10(%ebp)
 2d6:	85 c0                	test   %eax,%eax
 2d8:	7f dc                	jg     2b6 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2da:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2dd:	c9                   	leave  
 2de:	c3                   	ret    

000002df <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2df:	b8 01 00 00 00       	mov    $0x1,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <exit>:
SYSCALL(exit)
 2e7:	b8 02 00 00 00       	mov    $0x2,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <wait>:
SYSCALL(wait)
 2ef:	b8 03 00 00 00       	mov    $0x3,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <pipe>:
SYSCALL(pipe)
 2f7:	b8 04 00 00 00       	mov    $0x4,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <read>:
SYSCALL(read)
 2ff:	b8 05 00 00 00       	mov    $0x5,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <write>:
SYSCALL(write)
 307:	b8 10 00 00 00       	mov    $0x10,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <close>:
SYSCALL(close)
 30f:	b8 15 00 00 00       	mov    $0x15,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <kill>:
SYSCALL(kill)
 317:	b8 06 00 00 00       	mov    $0x6,%eax
 31c:	cd 40                	int    $0x40
 31e:	c3                   	ret    

0000031f <exec>:
SYSCALL(exec)
 31f:	b8 07 00 00 00       	mov    $0x7,%eax
 324:	cd 40                	int    $0x40
 326:	c3                   	ret    

00000327 <open>:
SYSCALL(open)
 327:	b8 0f 00 00 00       	mov    $0xf,%eax
 32c:	cd 40                	int    $0x40
 32e:	c3                   	ret    

0000032f <mknod>:
SYSCALL(mknod)
 32f:	b8 11 00 00 00       	mov    $0x11,%eax
 334:	cd 40                	int    $0x40
 336:	c3                   	ret    

00000337 <unlink>:
SYSCALL(unlink)
 337:	b8 12 00 00 00       	mov    $0x12,%eax
 33c:	cd 40                	int    $0x40
 33e:	c3                   	ret    

0000033f <fstat>:
SYSCALL(fstat)
 33f:	b8 08 00 00 00       	mov    $0x8,%eax
 344:	cd 40                	int    $0x40
 346:	c3                   	ret    

00000347 <link>:
SYSCALL(link)
 347:	b8 13 00 00 00       	mov    $0x13,%eax
 34c:	cd 40                	int    $0x40
 34e:	c3                   	ret    

0000034f <mkdir>:
SYSCALL(mkdir)
 34f:	b8 14 00 00 00       	mov    $0x14,%eax
 354:	cd 40                	int    $0x40
 356:	c3                   	ret    

00000357 <chdir>:
SYSCALL(chdir)
 357:	b8 09 00 00 00       	mov    $0x9,%eax
 35c:	cd 40                	int    $0x40
 35e:	c3                   	ret    

0000035f <dup>:
SYSCALL(dup)
 35f:	b8 0a 00 00 00       	mov    $0xa,%eax
 364:	cd 40                	int    $0x40
 366:	c3                   	ret    

00000367 <getpid>:
SYSCALL(getpid)
 367:	b8 0b 00 00 00       	mov    $0xb,%eax
 36c:	cd 40                	int    $0x40
 36e:	c3                   	ret    

0000036f <sbrk>:
SYSCALL(sbrk)
 36f:	b8 0c 00 00 00       	mov    $0xc,%eax
 374:	cd 40                	int    $0x40
 376:	c3                   	ret    

00000377 <sleep>:
SYSCALL(sleep)
 377:	b8 0d 00 00 00       	mov    $0xd,%eax
 37c:	cd 40                	int    $0x40
 37e:	c3                   	ret    

0000037f <uptime>:
SYSCALL(uptime)
 37f:	b8 0e 00 00 00       	mov    $0xe,%eax
 384:	cd 40                	int    $0x40
 386:	c3                   	ret    

00000387 <waitx>:
SYSCALL(waitx)
 387:	b8 16 00 00 00       	mov    $0x16,%eax
 38c:	cd 40                	int    $0x40
 38e:	c3                   	ret    

0000038f <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 38f:	55                   	push   %ebp
 390:	89 e5                	mov    %esp,%ebp
 392:	83 ec 18             	sub    $0x18,%esp
 395:	8b 45 0c             	mov    0xc(%ebp),%eax
 398:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 39b:	83 ec 04             	sub    $0x4,%esp
 39e:	6a 01                	push   $0x1
 3a0:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3a3:	50                   	push   %eax
 3a4:	ff 75 08             	pushl  0x8(%ebp)
 3a7:	e8 5b ff ff ff       	call   307 <write>
 3ac:	83 c4 10             	add    $0x10,%esp
}
 3af:	90                   	nop
 3b0:	c9                   	leave  
 3b1:	c3                   	ret    

000003b2 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3b2:	55                   	push   %ebp
 3b3:	89 e5                	mov    %esp,%ebp
 3b5:	53                   	push   %ebx
 3b6:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3b9:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3c0:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3c4:	74 17                	je     3dd <printint+0x2b>
 3c6:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3ca:	79 11                	jns    3dd <printint+0x2b>
    neg = 1;
 3cc:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3d3:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d6:	f7 d8                	neg    %eax
 3d8:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3db:	eb 06                	jmp    3e3 <printint+0x31>
  } else {
    x = xx;
 3dd:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3e3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3ea:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3ed:	8d 41 01             	lea    0x1(%ecx),%eax
 3f0:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3f3:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3f6:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f9:	ba 00 00 00 00       	mov    $0x0,%edx
 3fe:	f7 f3                	div    %ebx
 400:	89 d0                	mov    %edx,%eax
 402:	0f b6 80 a4 0a 00 00 	movzbl 0xaa4(%eax),%eax
 409:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 40d:	8b 5d 10             	mov    0x10(%ebp),%ebx
 410:	8b 45 ec             	mov    -0x14(%ebp),%eax
 413:	ba 00 00 00 00       	mov    $0x0,%edx
 418:	f7 f3                	div    %ebx
 41a:	89 45 ec             	mov    %eax,-0x14(%ebp)
 41d:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 421:	75 c7                	jne    3ea <printint+0x38>
  if(neg)
 423:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 427:	74 2d                	je     456 <printint+0xa4>
    buf[i++] = '-';
 429:	8b 45 f4             	mov    -0xc(%ebp),%eax
 42c:	8d 50 01             	lea    0x1(%eax),%edx
 42f:	89 55 f4             	mov    %edx,-0xc(%ebp)
 432:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 437:	eb 1d                	jmp    456 <printint+0xa4>
    putc(fd, buf[i]);
 439:	8d 55 dc             	lea    -0x24(%ebp),%edx
 43c:	8b 45 f4             	mov    -0xc(%ebp),%eax
 43f:	01 d0                	add    %edx,%eax
 441:	0f b6 00             	movzbl (%eax),%eax
 444:	0f be c0             	movsbl %al,%eax
 447:	83 ec 08             	sub    $0x8,%esp
 44a:	50                   	push   %eax
 44b:	ff 75 08             	pushl  0x8(%ebp)
 44e:	e8 3c ff ff ff       	call   38f <putc>
 453:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 456:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 45a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 45e:	79 d9                	jns    439 <printint+0x87>
    putc(fd, buf[i]);
}
 460:	90                   	nop
 461:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 464:	c9                   	leave  
 465:	c3                   	ret    

00000466 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 466:	55                   	push   %ebp
 467:	89 e5                	mov    %esp,%ebp
 469:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 46c:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 473:	8d 45 0c             	lea    0xc(%ebp),%eax
 476:	83 c0 04             	add    $0x4,%eax
 479:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 47c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 483:	e9 59 01 00 00       	jmp    5e1 <printf+0x17b>
    c = fmt[i] & 0xff;
 488:	8b 55 0c             	mov    0xc(%ebp),%edx
 48b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 48e:	01 d0                	add    %edx,%eax
 490:	0f b6 00             	movzbl (%eax),%eax
 493:	0f be c0             	movsbl %al,%eax
 496:	25 ff 00 00 00       	and    $0xff,%eax
 49b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 49e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4a2:	75 2c                	jne    4d0 <printf+0x6a>
      if(c == '%'){
 4a4:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4a8:	75 0c                	jne    4b6 <printf+0x50>
        state = '%';
 4aa:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4b1:	e9 27 01 00 00       	jmp    5dd <printf+0x177>
      } else {
        putc(fd, c);
 4b6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4b9:	0f be c0             	movsbl %al,%eax
 4bc:	83 ec 08             	sub    $0x8,%esp
 4bf:	50                   	push   %eax
 4c0:	ff 75 08             	pushl  0x8(%ebp)
 4c3:	e8 c7 fe ff ff       	call   38f <putc>
 4c8:	83 c4 10             	add    $0x10,%esp
 4cb:	e9 0d 01 00 00       	jmp    5dd <printf+0x177>
      }
    } else if(state == '%'){
 4d0:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4d4:	0f 85 03 01 00 00    	jne    5dd <printf+0x177>
      if(c == 'd'){
 4da:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4de:	75 1e                	jne    4fe <printf+0x98>
        printint(fd, *ap, 10, 1);
 4e0:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4e3:	8b 00                	mov    (%eax),%eax
 4e5:	6a 01                	push   $0x1
 4e7:	6a 0a                	push   $0xa
 4e9:	50                   	push   %eax
 4ea:	ff 75 08             	pushl  0x8(%ebp)
 4ed:	e8 c0 fe ff ff       	call   3b2 <printint>
 4f2:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f5:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f9:	e9 d8 00 00 00       	jmp    5d6 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4fe:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 502:	74 06                	je     50a <printf+0xa4>
 504:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 508:	75 1e                	jne    528 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 50a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 50d:	8b 00                	mov    (%eax),%eax
 50f:	6a 00                	push   $0x0
 511:	6a 10                	push   $0x10
 513:	50                   	push   %eax
 514:	ff 75 08             	pushl  0x8(%ebp)
 517:	e8 96 fe ff ff       	call   3b2 <printint>
 51c:	83 c4 10             	add    $0x10,%esp
        ap++;
 51f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 523:	e9 ae 00 00 00       	jmp    5d6 <printf+0x170>
      } else if(c == 's'){
 528:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 52c:	75 43                	jne    571 <printf+0x10b>
        s = (char*)*ap;
 52e:	8b 45 e8             	mov    -0x18(%ebp),%eax
 531:	8b 00                	mov    (%eax),%eax
 533:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 536:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 53a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 53e:	75 25                	jne    565 <printf+0xff>
          s = "(null)";
 540:	c7 45 f4 4f 08 00 00 	movl   $0x84f,-0xc(%ebp)
        while(*s != 0){
 547:	eb 1c                	jmp    565 <printf+0xff>
          putc(fd, *s);
 549:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54c:	0f b6 00             	movzbl (%eax),%eax
 54f:	0f be c0             	movsbl %al,%eax
 552:	83 ec 08             	sub    $0x8,%esp
 555:	50                   	push   %eax
 556:	ff 75 08             	pushl  0x8(%ebp)
 559:	e8 31 fe ff ff       	call   38f <putc>
 55e:	83 c4 10             	add    $0x10,%esp
          s++;
 561:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 565:	8b 45 f4             	mov    -0xc(%ebp),%eax
 568:	0f b6 00             	movzbl (%eax),%eax
 56b:	84 c0                	test   %al,%al
 56d:	75 da                	jne    549 <printf+0xe3>
 56f:	eb 65                	jmp    5d6 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 571:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 575:	75 1d                	jne    594 <printf+0x12e>
        putc(fd, *ap);
 577:	8b 45 e8             	mov    -0x18(%ebp),%eax
 57a:	8b 00                	mov    (%eax),%eax
 57c:	0f be c0             	movsbl %al,%eax
 57f:	83 ec 08             	sub    $0x8,%esp
 582:	50                   	push   %eax
 583:	ff 75 08             	pushl  0x8(%ebp)
 586:	e8 04 fe ff ff       	call   38f <putc>
 58b:	83 c4 10             	add    $0x10,%esp
        ap++;
 58e:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 592:	eb 42                	jmp    5d6 <printf+0x170>
      } else if(c == '%'){
 594:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 598:	75 17                	jne    5b1 <printf+0x14b>
        putc(fd, c);
 59a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 59d:	0f be c0             	movsbl %al,%eax
 5a0:	83 ec 08             	sub    $0x8,%esp
 5a3:	50                   	push   %eax
 5a4:	ff 75 08             	pushl  0x8(%ebp)
 5a7:	e8 e3 fd ff ff       	call   38f <putc>
 5ac:	83 c4 10             	add    $0x10,%esp
 5af:	eb 25                	jmp    5d6 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5b1:	83 ec 08             	sub    $0x8,%esp
 5b4:	6a 25                	push   $0x25
 5b6:	ff 75 08             	pushl  0x8(%ebp)
 5b9:	e8 d1 fd ff ff       	call   38f <putc>
 5be:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5c1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5c4:	0f be c0             	movsbl %al,%eax
 5c7:	83 ec 08             	sub    $0x8,%esp
 5ca:	50                   	push   %eax
 5cb:	ff 75 08             	pushl  0x8(%ebp)
 5ce:	e8 bc fd ff ff       	call   38f <putc>
 5d3:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5d6:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5dd:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5e1:	8b 55 0c             	mov    0xc(%ebp),%edx
 5e4:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5e7:	01 d0                	add    %edx,%eax
 5e9:	0f b6 00             	movzbl (%eax),%eax
 5ec:	84 c0                	test   %al,%al
 5ee:	0f 85 94 fe ff ff    	jne    488 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5f4:	90                   	nop
 5f5:	c9                   	leave  
 5f6:	c3                   	ret    

000005f7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5f7:	55                   	push   %ebp
 5f8:	89 e5                	mov    %esp,%ebp
 5fa:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5fd:	8b 45 08             	mov    0x8(%ebp),%eax
 600:	83 e8 08             	sub    $0x8,%eax
 603:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 606:	a1 c0 0a 00 00       	mov    0xac0,%eax
 60b:	89 45 fc             	mov    %eax,-0x4(%ebp)
 60e:	eb 24                	jmp    634 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 610:	8b 45 fc             	mov    -0x4(%ebp),%eax
 613:	8b 00                	mov    (%eax),%eax
 615:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 618:	77 12                	ja     62c <free+0x35>
 61a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61d:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 620:	77 24                	ja     646 <free+0x4f>
 622:	8b 45 fc             	mov    -0x4(%ebp),%eax
 625:	8b 00                	mov    (%eax),%eax
 627:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 62a:	77 1a                	ja     646 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 62c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62f:	8b 00                	mov    (%eax),%eax
 631:	89 45 fc             	mov    %eax,-0x4(%ebp)
 634:	8b 45 f8             	mov    -0x8(%ebp),%eax
 637:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 63a:	76 d4                	jbe    610 <free+0x19>
 63c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63f:	8b 00                	mov    (%eax),%eax
 641:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 644:	76 ca                	jbe    610 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 646:	8b 45 f8             	mov    -0x8(%ebp),%eax
 649:	8b 40 04             	mov    0x4(%eax),%eax
 64c:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 653:	8b 45 f8             	mov    -0x8(%ebp),%eax
 656:	01 c2                	add    %eax,%edx
 658:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65b:	8b 00                	mov    (%eax),%eax
 65d:	39 c2                	cmp    %eax,%edx
 65f:	75 24                	jne    685 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 661:	8b 45 f8             	mov    -0x8(%ebp),%eax
 664:	8b 50 04             	mov    0x4(%eax),%edx
 667:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66a:	8b 00                	mov    (%eax),%eax
 66c:	8b 40 04             	mov    0x4(%eax),%eax
 66f:	01 c2                	add    %eax,%edx
 671:	8b 45 f8             	mov    -0x8(%ebp),%eax
 674:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 677:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67a:	8b 00                	mov    (%eax),%eax
 67c:	8b 10                	mov    (%eax),%edx
 67e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 681:	89 10                	mov    %edx,(%eax)
 683:	eb 0a                	jmp    68f <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
 688:	8b 10                	mov    (%eax),%edx
 68a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68d:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 68f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 692:	8b 40 04             	mov    0x4(%eax),%eax
 695:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 69c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69f:	01 d0                	add    %edx,%eax
 6a1:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6a4:	75 20                	jne    6c6 <free+0xcf>
    p->s.size += bp->s.size;
 6a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a9:	8b 50 04             	mov    0x4(%eax),%edx
 6ac:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6af:	8b 40 04             	mov    0x4(%eax),%eax
 6b2:	01 c2                	add    %eax,%edx
 6b4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b7:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6ba:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bd:	8b 10                	mov    (%eax),%edx
 6bf:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c2:	89 10                	mov    %edx,(%eax)
 6c4:	eb 08                	jmp    6ce <free+0xd7>
  } else
    p->s.ptr = bp;
 6c6:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c9:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6cc:	89 10                	mov    %edx,(%eax)
  freep = p;
 6ce:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d1:	a3 c0 0a 00 00       	mov    %eax,0xac0
}
 6d6:	90                   	nop
 6d7:	c9                   	leave  
 6d8:	c3                   	ret    

000006d9 <morecore>:

static Header*
morecore(uint nu)
{
 6d9:	55                   	push   %ebp
 6da:	89 e5                	mov    %esp,%ebp
 6dc:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6df:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6e6:	77 07                	ja     6ef <morecore+0x16>
    nu = 4096;
 6e8:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6ef:	8b 45 08             	mov    0x8(%ebp),%eax
 6f2:	c1 e0 03             	shl    $0x3,%eax
 6f5:	83 ec 0c             	sub    $0xc,%esp
 6f8:	50                   	push   %eax
 6f9:	e8 71 fc ff ff       	call   36f <sbrk>
 6fe:	83 c4 10             	add    $0x10,%esp
 701:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 704:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 708:	75 07                	jne    711 <morecore+0x38>
    return 0;
 70a:	b8 00 00 00 00       	mov    $0x0,%eax
 70f:	eb 26                	jmp    737 <morecore+0x5e>
  hp = (Header*)p;
 711:	8b 45 f4             	mov    -0xc(%ebp),%eax
 714:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 717:	8b 45 f0             	mov    -0x10(%ebp),%eax
 71a:	8b 55 08             	mov    0x8(%ebp),%edx
 71d:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 720:	8b 45 f0             	mov    -0x10(%ebp),%eax
 723:	83 c0 08             	add    $0x8,%eax
 726:	83 ec 0c             	sub    $0xc,%esp
 729:	50                   	push   %eax
 72a:	e8 c8 fe ff ff       	call   5f7 <free>
 72f:	83 c4 10             	add    $0x10,%esp
  return freep;
 732:	a1 c0 0a 00 00       	mov    0xac0,%eax
}
 737:	c9                   	leave  
 738:	c3                   	ret    

00000739 <malloc>:

void*
malloc(uint nbytes)
{
 739:	55                   	push   %ebp
 73a:	89 e5                	mov    %esp,%ebp
 73c:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 73f:	8b 45 08             	mov    0x8(%ebp),%eax
 742:	83 c0 07             	add    $0x7,%eax
 745:	c1 e8 03             	shr    $0x3,%eax
 748:	83 c0 01             	add    $0x1,%eax
 74b:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 74e:	a1 c0 0a 00 00       	mov    0xac0,%eax
 753:	89 45 f0             	mov    %eax,-0x10(%ebp)
 756:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 75a:	75 23                	jne    77f <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 75c:	c7 45 f0 b8 0a 00 00 	movl   $0xab8,-0x10(%ebp)
 763:	8b 45 f0             	mov    -0x10(%ebp),%eax
 766:	a3 c0 0a 00 00       	mov    %eax,0xac0
 76b:	a1 c0 0a 00 00       	mov    0xac0,%eax
 770:	a3 b8 0a 00 00       	mov    %eax,0xab8
    base.s.size = 0;
 775:	c7 05 bc 0a 00 00 00 	movl   $0x0,0xabc
 77c:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 77f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 782:	8b 00                	mov    (%eax),%eax
 784:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 787:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78a:	8b 40 04             	mov    0x4(%eax),%eax
 78d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 790:	72 4d                	jb     7df <malloc+0xa6>
      if(p->s.size == nunits)
 792:	8b 45 f4             	mov    -0xc(%ebp),%eax
 795:	8b 40 04             	mov    0x4(%eax),%eax
 798:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 79b:	75 0c                	jne    7a9 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 79d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a0:	8b 10                	mov    (%eax),%edx
 7a2:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a5:	89 10                	mov    %edx,(%eax)
 7a7:	eb 26                	jmp    7cf <malloc+0x96>
      else {
        p->s.size -= nunits;
 7a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ac:	8b 40 04             	mov    0x4(%eax),%eax
 7af:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7b2:	89 c2                	mov    %eax,%edx
 7b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b7:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7bd:	8b 40 04             	mov    0x4(%eax),%eax
 7c0:	c1 e0 03             	shl    $0x3,%eax
 7c3:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7cc:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7d2:	a3 c0 0a 00 00       	mov    %eax,0xac0
      return (void*)(p + 1);
 7d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7da:	83 c0 08             	add    $0x8,%eax
 7dd:	eb 3b                	jmp    81a <malloc+0xe1>
    }
    if(p == freep)
 7df:	a1 c0 0a 00 00       	mov    0xac0,%eax
 7e4:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7e7:	75 1e                	jne    807 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7e9:	83 ec 0c             	sub    $0xc,%esp
 7ec:	ff 75 ec             	pushl  -0x14(%ebp)
 7ef:	e8 e5 fe ff ff       	call   6d9 <morecore>
 7f4:	83 c4 10             	add    $0x10,%esp
 7f7:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7fa:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7fe:	75 07                	jne    807 <malloc+0xce>
        return 0;
 800:	b8 00 00 00 00       	mov    $0x0,%eax
 805:	eb 13                	jmp    81a <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 807:	8b 45 f4             	mov    -0xc(%ebp),%eax
 80a:	89 45 f0             	mov    %eax,-0x10(%ebp)
 80d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 810:	8b 00                	mov    (%eax),%eax
 812:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 815:	e9 6d ff ff ff       	jmp    787 <malloc+0x4e>
}
 81a:	c9                   	leave  
 81b:	c3                   	ret    
