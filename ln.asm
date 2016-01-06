
_ln:     file format elf32-i386


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
   f:	89 cb                	mov    %ecx,%ebx
  if(argc != 3){
  11:	83 3b 03             	cmpl   $0x3,(%ebx)
  14:	74 17                	je     2d <main+0x2d>
    printf(2, "Usage: ln old new\n");
  16:	83 ec 08             	sub    $0x8,%esp
  19:	68 00 08 00 00       	push   $0x800
  1e:	6a 02                	push   $0x2
  20:	e8 25 04 00 00       	call   44a <printf>
  25:	83 c4 10             	add    $0x10,%esp
    exit();
  28:	e8 9e 02 00 00       	call   2cb <exit>
  }
  if(link(argv[1], argv[2]) < 0)
  2d:	8b 43 04             	mov    0x4(%ebx),%eax
  30:	83 c0 08             	add    $0x8,%eax
  33:	8b 10                	mov    (%eax),%edx
  35:	8b 43 04             	mov    0x4(%ebx),%eax
  38:	83 c0 04             	add    $0x4,%eax
  3b:	8b 00                	mov    (%eax),%eax
  3d:	83 ec 08             	sub    $0x8,%esp
  40:	52                   	push   %edx
  41:	50                   	push   %eax
  42:	e8 e4 02 00 00       	call   32b <link>
  47:	83 c4 10             	add    $0x10,%esp
  4a:	85 c0                	test   %eax,%eax
  4c:	79 21                	jns    6f <main+0x6f>
    printf(2, "link %s %s: failed\n", argv[1], argv[2]);
  4e:	8b 43 04             	mov    0x4(%ebx),%eax
  51:	83 c0 08             	add    $0x8,%eax
  54:	8b 10                	mov    (%eax),%edx
  56:	8b 43 04             	mov    0x4(%ebx),%eax
  59:	83 c0 04             	add    $0x4,%eax
  5c:	8b 00                	mov    (%eax),%eax
  5e:	52                   	push   %edx
  5f:	50                   	push   %eax
  60:	68 13 08 00 00       	push   $0x813
  65:	6a 02                	push   $0x2
  67:	e8 de 03 00 00       	call   44a <printf>
  6c:	83 c4 10             	add    $0x10,%esp
  exit();
  6f:	e8 57 02 00 00       	call   2cb <exit>

00000074 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  74:	55                   	push   %ebp
  75:	89 e5                	mov    %esp,%ebp
  77:	57                   	push   %edi
  78:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  79:	8b 4d 08             	mov    0x8(%ebp),%ecx
  7c:	8b 55 10             	mov    0x10(%ebp),%edx
  7f:	8b 45 0c             	mov    0xc(%ebp),%eax
  82:	89 cb                	mov    %ecx,%ebx
  84:	89 df                	mov    %ebx,%edi
  86:	89 d1                	mov    %edx,%ecx
  88:	fc                   	cld    
  89:	f3 aa                	rep stos %al,%es:(%edi)
  8b:	89 ca                	mov    %ecx,%edx
  8d:	89 fb                	mov    %edi,%ebx
  8f:	89 5d 08             	mov    %ebx,0x8(%ebp)
  92:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  95:	90                   	nop
  96:	5b                   	pop    %ebx
  97:	5f                   	pop    %edi
  98:	5d                   	pop    %ebp
  99:	c3                   	ret    

0000009a <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  9a:	55                   	push   %ebp
  9b:	89 e5                	mov    %esp,%ebp
  9d:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  a0:	8b 45 08             	mov    0x8(%ebp),%eax
  a3:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  a6:	90                   	nop
  a7:	8b 45 08             	mov    0x8(%ebp),%eax
  aa:	8d 50 01             	lea    0x1(%eax),%edx
  ad:	89 55 08             	mov    %edx,0x8(%ebp)
  b0:	8b 55 0c             	mov    0xc(%ebp),%edx
  b3:	8d 4a 01             	lea    0x1(%edx),%ecx
  b6:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  b9:	0f b6 12             	movzbl (%edx),%edx
  bc:	88 10                	mov    %dl,(%eax)
  be:	0f b6 00             	movzbl (%eax),%eax
  c1:	84 c0                	test   %al,%al
  c3:	75 e2                	jne    a7 <strcpy+0xd>
    ;
  return os;
  c5:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  c8:	c9                   	leave  
  c9:	c3                   	ret    

000000ca <strcmp>:

int
strcmp(const char *p, const char *q)
{
  ca:	55                   	push   %ebp
  cb:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  cd:	eb 08                	jmp    d7 <strcmp+0xd>
    p++, q++;
  cf:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  d3:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  d7:	8b 45 08             	mov    0x8(%ebp),%eax
  da:	0f b6 00             	movzbl (%eax),%eax
  dd:	84 c0                	test   %al,%al
  df:	74 10                	je     f1 <strcmp+0x27>
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	0f b6 10             	movzbl (%eax),%edx
  e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  ea:	0f b6 00             	movzbl (%eax),%eax
  ed:	38 c2                	cmp    %al,%dl
  ef:	74 de                	je     cf <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  f1:	8b 45 08             	mov    0x8(%ebp),%eax
  f4:	0f b6 00             	movzbl (%eax),%eax
  f7:	0f b6 d0             	movzbl %al,%edx
  fa:	8b 45 0c             	mov    0xc(%ebp),%eax
  fd:	0f b6 00             	movzbl (%eax),%eax
 100:	0f b6 c0             	movzbl %al,%eax
 103:	29 c2                	sub    %eax,%edx
 105:	89 d0                	mov    %edx,%eax
}
 107:	5d                   	pop    %ebp
 108:	c3                   	ret    

00000109 <strlen>:

uint
strlen(char *s)
{
 109:	55                   	push   %ebp
 10a:	89 e5                	mov    %esp,%ebp
 10c:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 10f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 116:	eb 04                	jmp    11c <strlen+0x13>
 118:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 11c:	8b 55 fc             	mov    -0x4(%ebp),%edx
 11f:	8b 45 08             	mov    0x8(%ebp),%eax
 122:	01 d0                	add    %edx,%eax
 124:	0f b6 00             	movzbl (%eax),%eax
 127:	84 c0                	test   %al,%al
 129:	75 ed                	jne    118 <strlen+0xf>
    ;
  return n;
 12b:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 12e:	c9                   	leave  
 12f:	c3                   	ret    

00000130 <memset>:

void*
memset(void *dst, int c, uint n)
{
 130:	55                   	push   %ebp
 131:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 133:	8b 45 10             	mov    0x10(%ebp),%eax
 136:	50                   	push   %eax
 137:	ff 75 0c             	pushl  0xc(%ebp)
 13a:	ff 75 08             	pushl  0x8(%ebp)
 13d:	e8 32 ff ff ff       	call   74 <stosb>
 142:	83 c4 0c             	add    $0xc,%esp
  return dst;
 145:	8b 45 08             	mov    0x8(%ebp),%eax
}
 148:	c9                   	leave  
 149:	c3                   	ret    

0000014a <strchr>:

char*
strchr(const char *s, char c)
{
 14a:	55                   	push   %ebp
 14b:	89 e5                	mov    %esp,%ebp
 14d:	83 ec 04             	sub    $0x4,%esp
 150:	8b 45 0c             	mov    0xc(%ebp),%eax
 153:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 156:	eb 14                	jmp    16c <strchr+0x22>
    if(*s == c)
 158:	8b 45 08             	mov    0x8(%ebp),%eax
 15b:	0f b6 00             	movzbl (%eax),%eax
 15e:	3a 45 fc             	cmp    -0x4(%ebp),%al
 161:	75 05                	jne    168 <strchr+0x1e>
      return (char*)s;
 163:	8b 45 08             	mov    0x8(%ebp),%eax
 166:	eb 13                	jmp    17b <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 168:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 16c:	8b 45 08             	mov    0x8(%ebp),%eax
 16f:	0f b6 00             	movzbl (%eax),%eax
 172:	84 c0                	test   %al,%al
 174:	75 e2                	jne    158 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 176:	b8 00 00 00 00       	mov    $0x0,%eax
}
 17b:	c9                   	leave  
 17c:	c3                   	ret    

0000017d <gets>:

char*
gets(char *buf, int max)
{
 17d:	55                   	push   %ebp
 17e:	89 e5                	mov    %esp,%ebp
 180:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 183:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 18a:	eb 42                	jmp    1ce <gets+0x51>
    cc = read(0, &c, 1);
 18c:	83 ec 04             	sub    $0x4,%esp
 18f:	6a 01                	push   $0x1
 191:	8d 45 ef             	lea    -0x11(%ebp),%eax
 194:	50                   	push   %eax
 195:	6a 00                	push   $0x0
 197:	e8 47 01 00 00       	call   2e3 <read>
 19c:	83 c4 10             	add    $0x10,%esp
 19f:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1a2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1a6:	7e 33                	jle    1db <gets+0x5e>
      break;
    buf[i++] = c;
 1a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1ab:	8d 50 01             	lea    0x1(%eax),%edx
 1ae:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1b1:	89 c2                	mov    %eax,%edx
 1b3:	8b 45 08             	mov    0x8(%ebp),%eax
 1b6:	01 c2                	add    %eax,%edx
 1b8:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1bc:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1be:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1c2:	3c 0a                	cmp    $0xa,%al
 1c4:	74 16                	je     1dc <gets+0x5f>
 1c6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ca:	3c 0d                	cmp    $0xd,%al
 1cc:	74 0e                	je     1dc <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ce:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d1:	83 c0 01             	add    $0x1,%eax
 1d4:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1d7:	7c b3                	jl     18c <gets+0xf>
 1d9:	eb 01                	jmp    1dc <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1db:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1df:	8b 45 08             	mov    0x8(%ebp),%eax
 1e2:	01 d0                	add    %edx,%eax
 1e4:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1e7:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1ea:	c9                   	leave  
 1eb:	c3                   	ret    

000001ec <stat>:

int
stat(char *n, struct stat *st)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f2:	83 ec 08             	sub    $0x8,%esp
 1f5:	6a 00                	push   $0x0
 1f7:	ff 75 08             	pushl  0x8(%ebp)
 1fa:	e8 0c 01 00 00       	call   30b <open>
 1ff:	83 c4 10             	add    $0x10,%esp
 202:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 205:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 209:	79 07                	jns    212 <stat+0x26>
    return -1;
 20b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 210:	eb 25                	jmp    237 <stat+0x4b>
  r = fstat(fd, st);
 212:	83 ec 08             	sub    $0x8,%esp
 215:	ff 75 0c             	pushl  0xc(%ebp)
 218:	ff 75 f4             	pushl  -0xc(%ebp)
 21b:	e8 03 01 00 00       	call   323 <fstat>
 220:	83 c4 10             	add    $0x10,%esp
 223:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 226:	83 ec 0c             	sub    $0xc,%esp
 229:	ff 75 f4             	pushl  -0xc(%ebp)
 22c:	e8 c2 00 00 00       	call   2f3 <close>
 231:	83 c4 10             	add    $0x10,%esp
  return r;
 234:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 237:	c9                   	leave  
 238:	c3                   	ret    

00000239 <atoi>:

int
atoi(const char *s)
{
 239:	55                   	push   %ebp
 23a:	89 e5                	mov    %esp,%ebp
 23c:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 23f:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 246:	eb 25                	jmp    26d <atoi+0x34>
    n = n*10 + *s++ - '0';
 248:	8b 55 fc             	mov    -0x4(%ebp),%edx
 24b:	89 d0                	mov    %edx,%eax
 24d:	c1 e0 02             	shl    $0x2,%eax
 250:	01 d0                	add    %edx,%eax
 252:	01 c0                	add    %eax,%eax
 254:	89 c1                	mov    %eax,%ecx
 256:	8b 45 08             	mov    0x8(%ebp),%eax
 259:	8d 50 01             	lea    0x1(%eax),%edx
 25c:	89 55 08             	mov    %edx,0x8(%ebp)
 25f:	0f b6 00             	movzbl (%eax),%eax
 262:	0f be c0             	movsbl %al,%eax
 265:	01 c8                	add    %ecx,%eax
 267:	83 e8 30             	sub    $0x30,%eax
 26a:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 26d:	8b 45 08             	mov    0x8(%ebp),%eax
 270:	0f b6 00             	movzbl (%eax),%eax
 273:	3c 2f                	cmp    $0x2f,%al
 275:	7e 0a                	jle    281 <atoi+0x48>
 277:	8b 45 08             	mov    0x8(%ebp),%eax
 27a:	0f b6 00             	movzbl (%eax),%eax
 27d:	3c 39                	cmp    $0x39,%al
 27f:	7e c7                	jle    248 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 281:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 284:	c9                   	leave  
 285:	c3                   	ret    

00000286 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 286:	55                   	push   %ebp
 287:	89 e5                	mov    %esp,%ebp
 289:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 28c:	8b 45 08             	mov    0x8(%ebp),%eax
 28f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 292:	8b 45 0c             	mov    0xc(%ebp),%eax
 295:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 298:	eb 17                	jmp    2b1 <memmove+0x2b>
    *dst++ = *src++;
 29a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 29d:	8d 50 01             	lea    0x1(%eax),%edx
 2a0:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2a3:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2a6:	8d 4a 01             	lea    0x1(%edx),%ecx
 2a9:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2ac:	0f b6 12             	movzbl (%edx),%edx
 2af:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2b1:	8b 45 10             	mov    0x10(%ebp),%eax
 2b4:	8d 50 ff             	lea    -0x1(%eax),%edx
 2b7:	89 55 10             	mov    %edx,0x10(%ebp)
 2ba:	85 c0                	test   %eax,%eax
 2bc:	7f dc                	jg     29a <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2be:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2c1:	c9                   	leave  
 2c2:	c3                   	ret    

000002c3 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2c3:	b8 01 00 00 00       	mov    $0x1,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <exit>:
SYSCALL(exit)
 2cb:	b8 02 00 00 00       	mov    $0x2,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <wait>:
SYSCALL(wait)
 2d3:	b8 03 00 00 00       	mov    $0x3,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <pipe>:
SYSCALL(pipe)
 2db:	b8 04 00 00 00       	mov    $0x4,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <read>:
SYSCALL(read)
 2e3:	b8 05 00 00 00       	mov    $0x5,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <write>:
SYSCALL(write)
 2eb:	b8 10 00 00 00       	mov    $0x10,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <close>:
SYSCALL(close)
 2f3:	b8 15 00 00 00       	mov    $0x15,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <kill>:
SYSCALL(kill)
 2fb:	b8 06 00 00 00       	mov    $0x6,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <exec>:
SYSCALL(exec)
 303:	b8 07 00 00 00       	mov    $0x7,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <open>:
SYSCALL(open)
 30b:	b8 0f 00 00 00       	mov    $0xf,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <mknod>:
SYSCALL(mknod)
 313:	b8 11 00 00 00       	mov    $0x11,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <unlink>:
SYSCALL(unlink)
 31b:	b8 12 00 00 00       	mov    $0x12,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <fstat>:
SYSCALL(fstat)
 323:	b8 08 00 00 00       	mov    $0x8,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <link>:
SYSCALL(link)
 32b:	b8 13 00 00 00       	mov    $0x13,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <mkdir>:
SYSCALL(mkdir)
 333:	b8 14 00 00 00       	mov    $0x14,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <chdir>:
SYSCALL(chdir)
 33b:	b8 09 00 00 00       	mov    $0x9,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <dup>:
SYSCALL(dup)
 343:	b8 0a 00 00 00       	mov    $0xa,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <getpid>:
SYSCALL(getpid)
 34b:	b8 0b 00 00 00       	mov    $0xb,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <sbrk>:
SYSCALL(sbrk)
 353:	b8 0c 00 00 00       	mov    $0xc,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <sleep>:
SYSCALL(sleep)
 35b:	b8 0d 00 00 00       	mov    $0xd,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <uptime>:
SYSCALL(uptime)
 363:	b8 0e 00 00 00       	mov    $0xe,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <waitx>:
SYSCALL(waitx)
 36b:	b8 16 00 00 00       	mov    $0x16,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 373:	55                   	push   %ebp
 374:	89 e5                	mov    %esp,%ebp
 376:	83 ec 18             	sub    $0x18,%esp
 379:	8b 45 0c             	mov    0xc(%ebp),%eax
 37c:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 37f:	83 ec 04             	sub    $0x4,%esp
 382:	6a 01                	push   $0x1
 384:	8d 45 f4             	lea    -0xc(%ebp),%eax
 387:	50                   	push   %eax
 388:	ff 75 08             	pushl  0x8(%ebp)
 38b:	e8 5b ff ff ff       	call   2eb <write>
 390:	83 c4 10             	add    $0x10,%esp
}
 393:	90                   	nop
 394:	c9                   	leave  
 395:	c3                   	ret    

00000396 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 396:	55                   	push   %ebp
 397:	89 e5                	mov    %esp,%ebp
 399:	53                   	push   %ebx
 39a:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 39d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3a4:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3a8:	74 17                	je     3c1 <printint+0x2b>
 3aa:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3ae:	79 11                	jns    3c1 <printint+0x2b>
    neg = 1;
 3b0:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3b7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ba:	f7 d8                	neg    %eax
 3bc:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3bf:	eb 06                	jmp    3c7 <printint+0x31>
  } else {
    x = xx;
 3c1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3c7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3ce:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3d1:	8d 41 01             	lea    0x1(%ecx),%eax
 3d4:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3d7:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3da:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3dd:	ba 00 00 00 00       	mov    $0x0,%edx
 3e2:	f7 f3                	div    %ebx
 3e4:	89 d0                	mov    %edx,%eax
 3e6:	0f b6 80 7c 0a 00 00 	movzbl 0xa7c(%eax),%eax
 3ed:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3f1:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3f4:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3f7:	ba 00 00 00 00       	mov    $0x0,%edx
 3fc:	f7 f3                	div    %ebx
 3fe:	89 45 ec             	mov    %eax,-0x14(%ebp)
 401:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 405:	75 c7                	jne    3ce <printint+0x38>
  if(neg)
 407:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 40b:	74 2d                	je     43a <printint+0xa4>
    buf[i++] = '-';
 40d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 410:	8d 50 01             	lea    0x1(%eax),%edx
 413:	89 55 f4             	mov    %edx,-0xc(%ebp)
 416:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 41b:	eb 1d                	jmp    43a <printint+0xa4>
    putc(fd, buf[i]);
 41d:	8d 55 dc             	lea    -0x24(%ebp),%edx
 420:	8b 45 f4             	mov    -0xc(%ebp),%eax
 423:	01 d0                	add    %edx,%eax
 425:	0f b6 00             	movzbl (%eax),%eax
 428:	0f be c0             	movsbl %al,%eax
 42b:	83 ec 08             	sub    $0x8,%esp
 42e:	50                   	push   %eax
 42f:	ff 75 08             	pushl  0x8(%ebp)
 432:	e8 3c ff ff ff       	call   373 <putc>
 437:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 43a:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 43e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 442:	79 d9                	jns    41d <printint+0x87>
    putc(fd, buf[i]);
}
 444:	90                   	nop
 445:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 448:	c9                   	leave  
 449:	c3                   	ret    

0000044a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 44a:	55                   	push   %ebp
 44b:	89 e5                	mov    %esp,%ebp
 44d:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 450:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 457:	8d 45 0c             	lea    0xc(%ebp),%eax
 45a:	83 c0 04             	add    $0x4,%eax
 45d:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 460:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 467:	e9 59 01 00 00       	jmp    5c5 <printf+0x17b>
    c = fmt[i] & 0xff;
 46c:	8b 55 0c             	mov    0xc(%ebp),%edx
 46f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 472:	01 d0                	add    %edx,%eax
 474:	0f b6 00             	movzbl (%eax),%eax
 477:	0f be c0             	movsbl %al,%eax
 47a:	25 ff 00 00 00       	and    $0xff,%eax
 47f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 482:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 486:	75 2c                	jne    4b4 <printf+0x6a>
      if(c == '%'){
 488:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 48c:	75 0c                	jne    49a <printf+0x50>
        state = '%';
 48e:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 495:	e9 27 01 00 00       	jmp    5c1 <printf+0x177>
      } else {
        putc(fd, c);
 49a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 49d:	0f be c0             	movsbl %al,%eax
 4a0:	83 ec 08             	sub    $0x8,%esp
 4a3:	50                   	push   %eax
 4a4:	ff 75 08             	pushl  0x8(%ebp)
 4a7:	e8 c7 fe ff ff       	call   373 <putc>
 4ac:	83 c4 10             	add    $0x10,%esp
 4af:	e9 0d 01 00 00       	jmp    5c1 <printf+0x177>
      }
    } else if(state == '%'){
 4b4:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4b8:	0f 85 03 01 00 00    	jne    5c1 <printf+0x177>
      if(c == 'd'){
 4be:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4c2:	75 1e                	jne    4e2 <printf+0x98>
        printint(fd, *ap, 10, 1);
 4c4:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4c7:	8b 00                	mov    (%eax),%eax
 4c9:	6a 01                	push   $0x1
 4cb:	6a 0a                	push   $0xa
 4cd:	50                   	push   %eax
 4ce:	ff 75 08             	pushl  0x8(%ebp)
 4d1:	e8 c0 fe ff ff       	call   396 <printint>
 4d6:	83 c4 10             	add    $0x10,%esp
        ap++;
 4d9:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4dd:	e9 d8 00 00 00       	jmp    5ba <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4e2:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4e6:	74 06                	je     4ee <printf+0xa4>
 4e8:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4ec:	75 1e                	jne    50c <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4ee:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4f1:	8b 00                	mov    (%eax),%eax
 4f3:	6a 00                	push   $0x0
 4f5:	6a 10                	push   $0x10
 4f7:	50                   	push   %eax
 4f8:	ff 75 08             	pushl  0x8(%ebp)
 4fb:	e8 96 fe ff ff       	call   396 <printint>
 500:	83 c4 10             	add    $0x10,%esp
        ap++;
 503:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 507:	e9 ae 00 00 00       	jmp    5ba <printf+0x170>
      } else if(c == 's'){
 50c:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 510:	75 43                	jne    555 <printf+0x10b>
        s = (char*)*ap;
 512:	8b 45 e8             	mov    -0x18(%ebp),%eax
 515:	8b 00                	mov    (%eax),%eax
 517:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 51a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 51e:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 522:	75 25                	jne    549 <printf+0xff>
          s = "(null)";
 524:	c7 45 f4 27 08 00 00 	movl   $0x827,-0xc(%ebp)
        while(*s != 0){
 52b:	eb 1c                	jmp    549 <printf+0xff>
          putc(fd, *s);
 52d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 530:	0f b6 00             	movzbl (%eax),%eax
 533:	0f be c0             	movsbl %al,%eax
 536:	83 ec 08             	sub    $0x8,%esp
 539:	50                   	push   %eax
 53a:	ff 75 08             	pushl  0x8(%ebp)
 53d:	e8 31 fe ff ff       	call   373 <putc>
 542:	83 c4 10             	add    $0x10,%esp
          s++;
 545:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 549:	8b 45 f4             	mov    -0xc(%ebp),%eax
 54c:	0f b6 00             	movzbl (%eax),%eax
 54f:	84 c0                	test   %al,%al
 551:	75 da                	jne    52d <printf+0xe3>
 553:	eb 65                	jmp    5ba <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 555:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 559:	75 1d                	jne    578 <printf+0x12e>
        putc(fd, *ap);
 55b:	8b 45 e8             	mov    -0x18(%ebp),%eax
 55e:	8b 00                	mov    (%eax),%eax
 560:	0f be c0             	movsbl %al,%eax
 563:	83 ec 08             	sub    $0x8,%esp
 566:	50                   	push   %eax
 567:	ff 75 08             	pushl  0x8(%ebp)
 56a:	e8 04 fe ff ff       	call   373 <putc>
 56f:	83 c4 10             	add    $0x10,%esp
        ap++;
 572:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 576:	eb 42                	jmp    5ba <printf+0x170>
      } else if(c == '%'){
 578:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 57c:	75 17                	jne    595 <printf+0x14b>
        putc(fd, c);
 57e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 581:	0f be c0             	movsbl %al,%eax
 584:	83 ec 08             	sub    $0x8,%esp
 587:	50                   	push   %eax
 588:	ff 75 08             	pushl  0x8(%ebp)
 58b:	e8 e3 fd ff ff       	call   373 <putc>
 590:	83 c4 10             	add    $0x10,%esp
 593:	eb 25                	jmp    5ba <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 595:	83 ec 08             	sub    $0x8,%esp
 598:	6a 25                	push   $0x25
 59a:	ff 75 08             	pushl  0x8(%ebp)
 59d:	e8 d1 fd ff ff       	call   373 <putc>
 5a2:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5a5:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a8:	0f be c0             	movsbl %al,%eax
 5ab:	83 ec 08             	sub    $0x8,%esp
 5ae:	50                   	push   %eax
 5af:	ff 75 08             	pushl  0x8(%ebp)
 5b2:	e8 bc fd ff ff       	call   373 <putc>
 5b7:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5ba:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5c1:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5c5:	8b 55 0c             	mov    0xc(%ebp),%edx
 5c8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5cb:	01 d0                	add    %edx,%eax
 5cd:	0f b6 00             	movzbl (%eax),%eax
 5d0:	84 c0                	test   %al,%al
 5d2:	0f 85 94 fe ff ff    	jne    46c <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5d8:	90                   	nop
 5d9:	c9                   	leave  
 5da:	c3                   	ret    

000005db <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5db:	55                   	push   %ebp
 5dc:	89 e5                	mov    %esp,%ebp
 5de:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5e1:	8b 45 08             	mov    0x8(%ebp),%eax
 5e4:	83 e8 08             	sub    $0x8,%eax
 5e7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5ea:	a1 98 0a 00 00       	mov    0xa98,%eax
 5ef:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5f2:	eb 24                	jmp    618 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5f4:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f7:	8b 00                	mov    (%eax),%eax
 5f9:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5fc:	77 12                	ja     610 <free+0x35>
 5fe:	8b 45 f8             	mov    -0x8(%ebp),%eax
 601:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 604:	77 24                	ja     62a <free+0x4f>
 606:	8b 45 fc             	mov    -0x4(%ebp),%eax
 609:	8b 00                	mov    (%eax),%eax
 60b:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 60e:	77 1a                	ja     62a <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 610:	8b 45 fc             	mov    -0x4(%ebp),%eax
 613:	8b 00                	mov    (%eax),%eax
 615:	89 45 fc             	mov    %eax,-0x4(%ebp)
 618:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61b:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 61e:	76 d4                	jbe    5f4 <free+0x19>
 620:	8b 45 fc             	mov    -0x4(%ebp),%eax
 623:	8b 00                	mov    (%eax),%eax
 625:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 628:	76 ca                	jbe    5f4 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 62a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 62d:	8b 40 04             	mov    0x4(%eax),%eax
 630:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 637:	8b 45 f8             	mov    -0x8(%ebp),%eax
 63a:	01 c2                	add    %eax,%edx
 63c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63f:	8b 00                	mov    (%eax),%eax
 641:	39 c2                	cmp    %eax,%edx
 643:	75 24                	jne    669 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 645:	8b 45 f8             	mov    -0x8(%ebp),%eax
 648:	8b 50 04             	mov    0x4(%eax),%edx
 64b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64e:	8b 00                	mov    (%eax),%eax
 650:	8b 40 04             	mov    0x4(%eax),%eax
 653:	01 c2                	add    %eax,%edx
 655:	8b 45 f8             	mov    -0x8(%ebp),%eax
 658:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 65b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 65e:	8b 00                	mov    (%eax),%eax
 660:	8b 10                	mov    (%eax),%edx
 662:	8b 45 f8             	mov    -0x8(%ebp),%eax
 665:	89 10                	mov    %edx,(%eax)
 667:	eb 0a                	jmp    673 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 669:	8b 45 fc             	mov    -0x4(%ebp),%eax
 66c:	8b 10                	mov    (%eax),%edx
 66e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 671:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 673:	8b 45 fc             	mov    -0x4(%ebp),%eax
 676:	8b 40 04             	mov    0x4(%eax),%eax
 679:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 680:	8b 45 fc             	mov    -0x4(%ebp),%eax
 683:	01 d0                	add    %edx,%eax
 685:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 688:	75 20                	jne    6aa <free+0xcf>
    p->s.size += bp->s.size;
 68a:	8b 45 fc             	mov    -0x4(%ebp),%eax
 68d:	8b 50 04             	mov    0x4(%eax),%edx
 690:	8b 45 f8             	mov    -0x8(%ebp),%eax
 693:	8b 40 04             	mov    0x4(%eax),%eax
 696:	01 c2                	add    %eax,%edx
 698:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 69e:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6a1:	8b 10                	mov    (%eax),%edx
 6a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a6:	89 10                	mov    %edx,(%eax)
 6a8:	eb 08                	jmp    6b2 <free+0xd7>
  } else
    p->s.ptr = bp;
 6aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ad:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6b0:	89 10                	mov    %edx,(%eax)
  freep = p;
 6b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b5:	a3 98 0a 00 00       	mov    %eax,0xa98
}
 6ba:	90                   	nop
 6bb:	c9                   	leave  
 6bc:	c3                   	ret    

000006bd <morecore>:

static Header*
morecore(uint nu)
{
 6bd:	55                   	push   %ebp
 6be:	89 e5                	mov    %esp,%ebp
 6c0:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6c3:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6ca:	77 07                	ja     6d3 <morecore+0x16>
    nu = 4096;
 6cc:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6d3:	8b 45 08             	mov    0x8(%ebp),%eax
 6d6:	c1 e0 03             	shl    $0x3,%eax
 6d9:	83 ec 0c             	sub    $0xc,%esp
 6dc:	50                   	push   %eax
 6dd:	e8 71 fc ff ff       	call   353 <sbrk>
 6e2:	83 c4 10             	add    $0x10,%esp
 6e5:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6e8:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6ec:	75 07                	jne    6f5 <morecore+0x38>
    return 0;
 6ee:	b8 00 00 00 00       	mov    $0x0,%eax
 6f3:	eb 26                	jmp    71b <morecore+0x5e>
  hp = (Header*)p;
 6f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6f8:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6fe:	8b 55 08             	mov    0x8(%ebp),%edx
 701:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 704:	8b 45 f0             	mov    -0x10(%ebp),%eax
 707:	83 c0 08             	add    $0x8,%eax
 70a:	83 ec 0c             	sub    $0xc,%esp
 70d:	50                   	push   %eax
 70e:	e8 c8 fe ff ff       	call   5db <free>
 713:	83 c4 10             	add    $0x10,%esp
  return freep;
 716:	a1 98 0a 00 00       	mov    0xa98,%eax
}
 71b:	c9                   	leave  
 71c:	c3                   	ret    

0000071d <malloc>:

void*
malloc(uint nbytes)
{
 71d:	55                   	push   %ebp
 71e:	89 e5                	mov    %esp,%ebp
 720:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 723:	8b 45 08             	mov    0x8(%ebp),%eax
 726:	83 c0 07             	add    $0x7,%eax
 729:	c1 e8 03             	shr    $0x3,%eax
 72c:	83 c0 01             	add    $0x1,%eax
 72f:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 732:	a1 98 0a 00 00       	mov    0xa98,%eax
 737:	89 45 f0             	mov    %eax,-0x10(%ebp)
 73a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 73e:	75 23                	jne    763 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 740:	c7 45 f0 90 0a 00 00 	movl   $0xa90,-0x10(%ebp)
 747:	8b 45 f0             	mov    -0x10(%ebp),%eax
 74a:	a3 98 0a 00 00       	mov    %eax,0xa98
 74f:	a1 98 0a 00 00       	mov    0xa98,%eax
 754:	a3 90 0a 00 00       	mov    %eax,0xa90
    base.s.size = 0;
 759:	c7 05 94 0a 00 00 00 	movl   $0x0,0xa94
 760:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 763:	8b 45 f0             	mov    -0x10(%ebp),%eax
 766:	8b 00                	mov    (%eax),%eax
 768:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 76b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 76e:	8b 40 04             	mov    0x4(%eax),%eax
 771:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 774:	72 4d                	jb     7c3 <malloc+0xa6>
      if(p->s.size == nunits)
 776:	8b 45 f4             	mov    -0xc(%ebp),%eax
 779:	8b 40 04             	mov    0x4(%eax),%eax
 77c:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 77f:	75 0c                	jne    78d <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 781:	8b 45 f4             	mov    -0xc(%ebp),%eax
 784:	8b 10                	mov    (%eax),%edx
 786:	8b 45 f0             	mov    -0x10(%ebp),%eax
 789:	89 10                	mov    %edx,(%eax)
 78b:	eb 26                	jmp    7b3 <malloc+0x96>
      else {
        p->s.size -= nunits;
 78d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 790:	8b 40 04             	mov    0x4(%eax),%eax
 793:	2b 45 ec             	sub    -0x14(%ebp),%eax
 796:	89 c2                	mov    %eax,%edx
 798:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 79e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a1:	8b 40 04             	mov    0x4(%eax),%eax
 7a4:	c1 e0 03             	shl    $0x3,%eax
 7a7:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7b0:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7b3:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b6:	a3 98 0a 00 00       	mov    %eax,0xa98
      return (void*)(p + 1);
 7bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7be:	83 c0 08             	add    $0x8,%eax
 7c1:	eb 3b                	jmp    7fe <malloc+0xe1>
    }
    if(p == freep)
 7c3:	a1 98 0a 00 00       	mov    0xa98,%eax
 7c8:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7cb:	75 1e                	jne    7eb <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7cd:	83 ec 0c             	sub    $0xc,%esp
 7d0:	ff 75 ec             	pushl  -0x14(%ebp)
 7d3:	e8 e5 fe ff ff       	call   6bd <morecore>
 7d8:	83 c4 10             	add    $0x10,%esp
 7db:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7de:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7e2:	75 07                	jne    7eb <malloc+0xce>
        return 0;
 7e4:	b8 00 00 00 00       	mov    $0x0,%eax
 7e9:	eb 13                	jmp    7fe <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7eb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ee:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7f4:	8b 00                	mov    (%eax),%eax
 7f6:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7f9:	e9 6d ff ff ff       	jmp    76b <malloc+0x4e>
}
 7fe:	c9                   	leave  
 7ff:	c3                   	ret    
