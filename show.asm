
_show:     file format elf32-i386


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
   e:	83 ec 24             	sub    $0x24,%esp
      int *a;
      int *b;

      int c=4,d=5;
  11:	c7 45 e8 04 00 00 00 	movl   $0x4,-0x18(%ebp)
  18:	c7 45 e4 05 00 00 00 	movl   $0x5,-0x1c(%ebp)
       a=&c;b=&d;
  1f:	8d 45 e8             	lea    -0x18(%ebp),%eax
  22:	89 45 f4             	mov    %eax,-0xc(%ebp)
  25:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  28:	89 45 f0             	mov    %eax,-0x10(%ebp)
       int x=waitx(a,b);
  2b:	83 ec 08             	sub    $0x8,%esp
  2e:	ff 75 f0             	pushl  -0x10(%ebp)
  31:	ff 75 f4             	pushl  -0xc(%ebp)
  34:	e8 1f 03 00 00       	call   358 <waitx>
  39:	83 c4 10             	add    $0x10,%esp
  3c:	89 45 ec             	mov    %eax,-0x14(%ebp)
      //  int   x=3;	
	printf(1, "!!%d!!",x);
  3f:	83 ec 04             	sub    $0x4,%esp
  42:	ff 75 ec             	pushl  -0x14(%ebp)
  45:	68 ed 07 00 00       	push   $0x7ed
  4a:	6a 01                	push   $0x1
  4c:	e8 e6 03 00 00       	call   437 <printf>
  51:	83 c4 10             	add    $0x10,%esp
	return 0;
  54:	b8 00 00 00 00       	mov    $0x0,%eax
}
  59:	8b 4d fc             	mov    -0x4(%ebp),%ecx
  5c:	c9                   	leave  
  5d:	8d 61 fc             	lea    -0x4(%ecx),%esp
  60:	c3                   	ret    

00000061 <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  61:	55                   	push   %ebp
  62:	89 e5                	mov    %esp,%ebp
  64:	57                   	push   %edi
  65:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  69:	8b 55 10             	mov    0x10(%ebp),%edx
  6c:	8b 45 0c             	mov    0xc(%ebp),%eax
  6f:	89 cb                	mov    %ecx,%ebx
  71:	89 df                	mov    %ebx,%edi
  73:	89 d1                	mov    %edx,%ecx
  75:	fc                   	cld    
  76:	f3 aa                	rep stos %al,%es:(%edi)
  78:	89 ca                	mov    %ecx,%edx
  7a:	89 fb                	mov    %edi,%ebx
  7c:	89 5d 08             	mov    %ebx,0x8(%ebp)
  7f:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  82:	90                   	nop
  83:	5b                   	pop    %ebx
  84:	5f                   	pop    %edi
  85:	5d                   	pop    %ebp
  86:	c3                   	ret    

00000087 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  87:	55                   	push   %ebp
  88:	89 e5                	mov    %esp,%ebp
  8a:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  8d:	8b 45 08             	mov    0x8(%ebp),%eax
  90:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  93:	90                   	nop
  94:	8b 45 08             	mov    0x8(%ebp),%eax
  97:	8d 50 01             	lea    0x1(%eax),%edx
  9a:	89 55 08             	mov    %edx,0x8(%ebp)
  9d:	8b 55 0c             	mov    0xc(%ebp),%edx
  a0:	8d 4a 01             	lea    0x1(%edx),%ecx
  a3:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  a6:	0f b6 12             	movzbl (%edx),%edx
  a9:	88 10                	mov    %dl,(%eax)
  ab:	0f b6 00             	movzbl (%eax),%eax
  ae:	84 c0                	test   %al,%al
  b0:	75 e2                	jne    94 <strcpy+0xd>
    ;
  return os;
  b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  b5:	c9                   	leave  
  b6:	c3                   	ret    

000000b7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  b7:	55                   	push   %ebp
  b8:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  ba:	eb 08                	jmp    c4 <strcmp+0xd>
    p++, q++;
  bc:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  c0:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  c4:	8b 45 08             	mov    0x8(%ebp),%eax
  c7:	0f b6 00             	movzbl (%eax),%eax
  ca:	84 c0                	test   %al,%al
  cc:	74 10                	je     de <strcmp+0x27>
  ce:	8b 45 08             	mov    0x8(%ebp),%eax
  d1:	0f b6 10             	movzbl (%eax),%edx
  d4:	8b 45 0c             	mov    0xc(%ebp),%eax
  d7:	0f b6 00             	movzbl (%eax),%eax
  da:	38 c2                	cmp    %al,%dl
  dc:	74 de                	je     bc <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
  de:	8b 45 08             	mov    0x8(%ebp),%eax
  e1:	0f b6 00             	movzbl (%eax),%eax
  e4:	0f b6 d0             	movzbl %al,%edx
  e7:	8b 45 0c             	mov    0xc(%ebp),%eax
  ea:	0f b6 00             	movzbl (%eax),%eax
  ed:	0f b6 c0             	movzbl %al,%eax
  f0:	29 c2                	sub    %eax,%edx
  f2:	89 d0                	mov    %edx,%eax
}
  f4:	5d                   	pop    %ebp
  f5:	c3                   	ret    

000000f6 <strlen>:

uint
strlen(char *s)
{
  f6:	55                   	push   %ebp
  f7:	89 e5                	mov    %esp,%ebp
  f9:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
  fc:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 103:	eb 04                	jmp    109 <strlen+0x13>
 105:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 109:	8b 55 fc             	mov    -0x4(%ebp),%edx
 10c:	8b 45 08             	mov    0x8(%ebp),%eax
 10f:	01 d0                	add    %edx,%eax
 111:	0f b6 00             	movzbl (%eax),%eax
 114:	84 c0                	test   %al,%al
 116:	75 ed                	jne    105 <strlen+0xf>
    ;
  return n;
 118:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 11b:	c9                   	leave  
 11c:	c3                   	ret    

0000011d <memset>:

void*
memset(void *dst, int c, uint n)
{
 11d:	55                   	push   %ebp
 11e:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 120:	8b 45 10             	mov    0x10(%ebp),%eax
 123:	50                   	push   %eax
 124:	ff 75 0c             	pushl  0xc(%ebp)
 127:	ff 75 08             	pushl  0x8(%ebp)
 12a:	e8 32 ff ff ff       	call   61 <stosb>
 12f:	83 c4 0c             	add    $0xc,%esp
  return dst;
 132:	8b 45 08             	mov    0x8(%ebp),%eax
}
 135:	c9                   	leave  
 136:	c3                   	ret    

00000137 <strchr>:

char*
strchr(const char *s, char c)
{
 137:	55                   	push   %ebp
 138:	89 e5                	mov    %esp,%ebp
 13a:	83 ec 04             	sub    $0x4,%esp
 13d:	8b 45 0c             	mov    0xc(%ebp),%eax
 140:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 143:	eb 14                	jmp    159 <strchr+0x22>
    if(*s == c)
 145:	8b 45 08             	mov    0x8(%ebp),%eax
 148:	0f b6 00             	movzbl (%eax),%eax
 14b:	3a 45 fc             	cmp    -0x4(%ebp),%al
 14e:	75 05                	jne    155 <strchr+0x1e>
      return (char*)s;
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	eb 13                	jmp    168 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 155:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 159:	8b 45 08             	mov    0x8(%ebp),%eax
 15c:	0f b6 00             	movzbl (%eax),%eax
 15f:	84 c0                	test   %al,%al
 161:	75 e2                	jne    145 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 163:	b8 00 00 00 00       	mov    $0x0,%eax
}
 168:	c9                   	leave  
 169:	c3                   	ret    

0000016a <gets>:

char*
gets(char *buf, int max)
{
 16a:	55                   	push   %ebp
 16b:	89 e5                	mov    %esp,%ebp
 16d:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 170:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 177:	eb 42                	jmp    1bb <gets+0x51>
    cc = read(0, &c, 1);
 179:	83 ec 04             	sub    $0x4,%esp
 17c:	6a 01                	push   $0x1
 17e:	8d 45 ef             	lea    -0x11(%ebp),%eax
 181:	50                   	push   %eax
 182:	6a 00                	push   $0x0
 184:	e8 47 01 00 00       	call   2d0 <read>
 189:	83 c4 10             	add    $0x10,%esp
 18c:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 18f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 193:	7e 33                	jle    1c8 <gets+0x5e>
      break;
    buf[i++] = c;
 195:	8b 45 f4             	mov    -0xc(%ebp),%eax
 198:	8d 50 01             	lea    0x1(%eax),%edx
 19b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 19e:	89 c2                	mov    %eax,%edx
 1a0:	8b 45 08             	mov    0x8(%ebp),%eax
 1a3:	01 c2                	add    %eax,%edx
 1a5:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1a9:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1ab:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1af:	3c 0a                	cmp    $0xa,%al
 1b1:	74 16                	je     1c9 <gets+0x5f>
 1b3:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1b7:	3c 0d                	cmp    $0xd,%al
 1b9:	74 0e                	je     1c9 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1be:	83 c0 01             	add    $0x1,%eax
 1c1:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1c4:	7c b3                	jl     179 <gets+0xf>
 1c6:	eb 01                	jmp    1c9 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 1c8:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 1c9:	8b 55 f4             	mov    -0xc(%ebp),%edx
 1cc:	8b 45 08             	mov    0x8(%ebp),%eax
 1cf:	01 d0                	add    %edx,%eax
 1d1:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 1d4:	8b 45 08             	mov    0x8(%ebp),%eax
}
 1d7:	c9                   	leave  
 1d8:	c3                   	ret    

000001d9 <stat>:

int
stat(char *n, struct stat *st)
{
 1d9:	55                   	push   %ebp
 1da:	89 e5                	mov    %esp,%ebp
 1dc:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1df:	83 ec 08             	sub    $0x8,%esp
 1e2:	6a 00                	push   $0x0
 1e4:	ff 75 08             	pushl  0x8(%ebp)
 1e7:	e8 0c 01 00 00       	call   2f8 <open>
 1ec:	83 c4 10             	add    $0x10,%esp
 1ef:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 1f2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 1f6:	79 07                	jns    1ff <stat+0x26>
    return -1;
 1f8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 1fd:	eb 25                	jmp    224 <stat+0x4b>
  r = fstat(fd, st);
 1ff:	83 ec 08             	sub    $0x8,%esp
 202:	ff 75 0c             	pushl  0xc(%ebp)
 205:	ff 75 f4             	pushl  -0xc(%ebp)
 208:	e8 03 01 00 00       	call   310 <fstat>
 20d:	83 c4 10             	add    $0x10,%esp
 210:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 213:	83 ec 0c             	sub    $0xc,%esp
 216:	ff 75 f4             	pushl  -0xc(%ebp)
 219:	e8 c2 00 00 00       	call   2e0 <close>
 21e:	83 c4 10             	add    $0x10,%esp
  return r;
 221:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 224:	c9                   	leave  
 225:	c3                   	ret    

00000226 <atoi>:

int
atoi(const char *s)
{
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
 229:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 22c:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 233:	eb 25                	jmp    25a <atoi+0x34>
    n = n*10 + *s++ - '0';
 235:	8b 55 fc             	mov    -0x4(%ebp),%edx
 238:	89 d0                	mov    %edx,%eax
 23a:	c1 e0 02             	shl    $0x2,%eax
 23d:	01 d0                	add    %edx,%eax
 23f:	01 c0                	add    %eax,%eax
 241:	89 c1                	mov    %eax,%ecx
 243:	8b 45 08             	mov    0x8(%ebp),%eax
 246:	8d 50 01             	lea    0x1(%eax),%edx
 249:	89 55 08             	mov    %edx,0x8(%ebp)
 24c:	0f b6 00             	movzbl (%eax),%eax
 24f:	0f be c0             	movsbl %al,%eax
 252:	01 c8                	add    %ecx,%eax
 254:	83 e8 30             	sub    $0x30,%eax
 257:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25a:	8b 45 08             	mov    0x8(%ebp),%eax
 25d:	0f b6 00             	movzbl (%eax),%eax
 260:	3c 2f                	cmp    $0x2f,%al
 262:	7e 0a                	jle    26e <atoi+0x48>
 264:	8b 45 08             	mov    0x8(%ebp),%eax
 267:	0f b6 00             	movzbl (%eax),%eax
 26a:	3c 39                	cmp    $0x39,%al
 26c:	7e c7                	jle    235 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 26e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 271:	c9                   	leave  
 272:	c3                   	ret    

00000273 <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 273:	55                   	push   %ebp
 274:	89 e5                	mov    %esp,%ebp
 276:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 279:	8b 45 08             	mov    0x8(%ebp),%eax
 27c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 27f:	8b 45 0c             	mov    0xc(%ebp),%eax
 282:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 285:	eb 17                	jmp    29e <memmove+0x2b>
    *dst++ = *src++;
 287:	8b 45 fc             	mov    -0x4(%ebp),%eax
 28a:	8d 50 01             	lea    0x1(%eax),%edx
 28d:	89 55 fc             	mov    %edx,-0x4(%ebp)
 290:	8b 55 f8             	mov    -0x8(%ebp),%edx
 293:	8d 4a 01             	lea    0x1(%edx),%ecx
 296:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 299:	0f b6 12             	movzbl (%edx),%edx
 29c:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 29e:	8b 45 10             	mov    0x10(%ebp),%eax
 2a1:	8d 50 ff             	lea    -0x1(%eax),%edx
 2a4:	89 55 10             	mov    %edx,0x10(%ebp)
 2a7:	85 c0                	test   %eax,%eax
 2a9:	7f dc                	jg     287 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2ab:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2ae:	c9                   	leave  
 2af:	c3                   	ret    

000002b0 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2b0:	b8 01 00 00 00       	mov    $0x1,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <exit>:
SYSCALL(exit)
 2b8:	b8 02 00 00 00       	mov    $0x2,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <wait>:
SYSCALL(wait)
 2c0:	b8 03 00 00 00       	mov    $0x3,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <pipe>:
SYSCALL(pipe)
 2c8:	b8 04 00 00 00       	mov    $0x4,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <read>:
SYSCALL(read)
 2d0:	b8 05 00 00 00       	mov    $0x5,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <write>:
SYSCALL(write)
 2d8:	b8 10 00 00 00       	mov    $0x10,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <close>:
SYSCALL(close)
 2e0:	b8 15 00 00 00       	mov    $0x15,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <kill>:
SYSCALL(kill)
 2e8:	b8 06 00 00 00       	mov    $0x6,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <exec>:
SYSCALL(exec)
 2f0:	b8 07 00 00 00       	mov    $0x7,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <open>:
SYSCALL(open)
 2f8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <mknod>:
SYSCALL(mknod)
 300:	b8 11 00 00 00       	mov    $0x11,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <unlink>:
SYSCALL(unlink)
 308:	b8 12 00 00 00       	mov    $0x12,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <fstat>:
SYSCALL(fstat)
 310:	b8 08 00 00 00       	mov    $0x8,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <link>:
SYSCALL(link)
 318:	b8 13 00 00 00       	mov    $0x13,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <mkdir>:
SYSCALL(mkdir)
 320:	b8 14 00 00 00       	mov    $0x14,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <chdir>:
SYSCALL(chdir)
 328:	b8 09 00 00 00       	mov    $0x9,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <dup>:
SYSCALL(dup)
 330:	b8 0a 00 00 00       	mov    $0xa,%eax
 335:	cd 40                	int    $0x40
 337:	c3                   	ret    

00000338 <getpid>:
SYSCALL(getpid)
 338:	b8 0b 00 00 00       	mov    $0xb,%eax
 33d:	cd 40                	int    $0x40
 33f:	c3                   	ret    

00000340 <sbrk>:
SYSCALL(sbrk)
 340:	b8 0c 00 00 00       	mov    $0xc,%eax
 345:	cd 40                	int    $0x40
 347:	c3                   	ret    

00000348 <sleep>:
SYSCALL(sleep)
 348:	b8 0d 00 00 00       	mov    $0xd,%eax
 34d:	cd 40                	int    $0x40
 34f:	c3                   	ret    

00000350 <uptime>:
SYSCALL(uptime)
 350:	b8 0e 00 00 00       	mov    $0xe,%eax
 355:	cd 40                	int    $0x40
 357:	c3                   	ret    

00000358 <waitx>:
SYSCALL(waitx)
 358:	b8 16 00 00 00       	mov    $0x16,%eax
 35d:	cd 40                	int    $0x40
 35f:	c3                   	ret    

00000360 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 360:	55                   	push   %ebp
 361:	89 e5                	mov    %esp,%ebp
 363:	83 ec 18             	sub    $0x18,%esp
 366:	8b 45 0c             	mov    0xc(%ebp),%eax
 369:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 36c:	83 ec 04             	sub    $0x4,%esp
 36f:	6a 01                	push   $0x1
 371:	8d 45 f4             	lea    -0xc(%ebp),%eax
 374:	50                   	push   %eax
 375:	ff 75 08             	pushl  0x8(%ebp)
 378:	e8 5b ff ff ff       	call   2d8 <write>
 37d:	83 c4 10             	add    $0x10,%esp
}
 380:	90                   	nop
 381:	c9                   	leave  
 382:	c3                   	ret    

00000383 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 383:	55                   	push   %ebp
 384:	89 e5                	mov    %esp,%ebp
 386:	53                   	push   %ebx
 387:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 38a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 391:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 395:	74 17                	je     3ae <printint+0x2b>
 397:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 39b:	79 11                	jns    3ae <printint+0x2b>
    neg = 1;
 39d:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3a4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a7:	f7 d8                	neg    %eax
 3a9:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ac:	eb 06                	jmp    3b4 <printint+0x31>
  } else {
    x = xx;
 3ae:	8b 45 0c             	mov    0xc(%ebp),%eax
 3b1:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3b4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3bb:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3be:	8d 41 01             	lea    0x1(%ecx),%eax
 3c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3c4:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3ca:	ba 00 00 00 00       	mov    $0x0,%edx
 3cf:	f7 f3                	div    %ebx
 3d1:	89 d0                	mov    %edx,%eax
 3d3:	0f b6 80 4c 0a 00 00 	movzbl 0xa4c(%eax),%eax
 3da:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 3de:	8b 5d 10             	mov    0x10(%ebp),%ebx
 3e1:	8b 45 ec             	mov    -0x14(%ebp),%eax
 3e4:	ba 00 00 00 00       	mov    $0x0,%edx
 3e9:	f7 f3                	div    %ebx
 3eb:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3ee:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 3f2:	75 c7                	jne    3bb <printint+0x38>
  if(neg)
 3f4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 3f8:	74 2d                	je     427 <printint+0xa4>
    buf[i++] = '-';
 3fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
 3fd:	8d 50 01             	lea    0x1(%eax),%edx
 400:	89 55 f4             	mov    %edx,-0xc(%ebp)
 403:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 408:	eb 1d                	jmp    427 <printint+0xa4>
    putc(fd, buf[i]);
 40a:	8d 55 dc             	lea    -0x24(%ebp),%edx
 40d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 410:	01 d0                	add    %edx,%eax
 412:	0f b6 00             	movzbl (%eax),%eax
 415:	0f be c0             	movsbl %al,%eax
 418:	83 ec 08             	sub    $0x8,%esp
 41b:	50                   	push   %eax
 41c:	ff 75 08             	pushl  0x8(%ebp)
 41f:	e8 3c ff ff ff       	call   360 <putc>
 424:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 427:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 42b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 42f:	79 d9                	jns    40a <printint+0x87>
    putc(fd, buf[i]);
}
 431:	90                   	nop
 432:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 435:	c9                   	leave  
 436:	c3                   	ret    

00000437 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 437:	55                   	push   %ebp
 438:	89 e5                	mov    %esp,%ebp
 43a:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 43d:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 444:	8d 45 0c             	lea    0xc(%ebp),%eax
 447:	83 c0 04             	add    $0x4,%eax
 44a:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 44d:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 454:	e9 59 01 00 00       	jmp    5b2 <printf+0x17b>
    c = fmt[i] & 0xff;
 459:	8b 55 0c             	mov    0xc(%ebp),%edx
 45c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 45f:	01 d0                	add    %edx,%eax
 461:	0f b6 00             	movzbl (%eax),%eax
 464:	0f be c0             	movsbl %al,%eax
 467:	25 ff 00 00 00       	and    $0xff,%eax
 46c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 46f:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 473:	75 2c                	jne    4a1 <printf+0x6a>
      if(c == '%'){
 475:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 479:	75 0c                	jne    487 <printf+0x50>
        state = '%';
 47b:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 482:	e9 27 01 00 00       	jmp    5ae <printf+0x177>
      } else {
        putc(fd, c);
 487:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 48a:	0f be c0             	movsbl %al,%eax
 48d:	83 ec 08             	sub    $0x8,%esp
 490:	50                   	push   %eax
 491:	ff 75 08             	pushl  0x8(%ebp)
 494:	e8 c7 fe ff ff       	call   360 <putc>
 499:	83 c4 10             	add    $0x10,%esp
 49c:	e9 0d 01 00 00       	jmp    5ae <printf+0x177>
      }
    } else if(state == '%'){
 4a1:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4a5:	0f 85 03 01 00 00    	jne    5ae <printf+0x177>
      if(c == 'd'){
 4ab:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4af:	75 1e                	jne    4cf <printf+0x98>
        printint(fd, *ap, 10, 1);
 4b1:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4b4:	8b 00                	mov    (%eax),%eax
 4b6:	6a 01                	push   $0x1
 4b8:	6a 0a                	push   $0xa
 4ba:	50                   	push   %eax
 4bb:	ff 75 08             	pushl  0x8(%ebp)
 4be:	e8 c0 fe ff ff       	call   383 <printint>
 4c3:	83 c4 10             	add    $0x10,%esp
        ap++;
 4c6:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4ca:	e9 d8 00 00 00       	jmp    5a7 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 4cf:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 4d3:	74 06                	je     4db <printf+0xa4>
 4d5:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 4d9:	75 1e                	jne    4f9 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 4db:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4de:	8b 00                	mov    (%eax),%eax
 4e0:	6a 00                	push   $0x0
 4e2:	6a 10                	push   $0x10
 4e4:	50                   	push   %eax
 4e5:	ff 75 08             	pushl  0x8(%ebp)
 4e8:	e8 96 fe ff ff       	call   383 <printint>
 4ed:	83 c4 10             	add    $0x10,%esp
        ap++;
 4f0:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 4f4:	e9 ae 00 00 00       	jmp    5a7 <printf+0x170>
      } else if(c == 's'){
 4f9:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 4fd:	75 43                	jne    542 <printf+0x10b>
        s = (char*)*ap;
 4ff:	8b 45 e8             	mov    -0x18(%ebp),%eax
 502:	8b 00                	mov    (%eax),%eax
 504:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 507:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 50b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 50f:	75 25                	jne    536 <printf+0xff>
          s = "(null)";
 511:	c7 45 f4 f4 07 00 00 	movl   $0x7f4,-0xc(%ebp)
        while(*s != 0){
 518:	eb 1c                	jmp    536 <printf+0xff>
          putc(fd, *s);
 51a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 51d:	0f b6 00             	movzbl (%eax),%eax
 520:	0f be c0             	movsbl %al,%eax
 523:	83 ec 08             	sub    $0x8,%esp
 526:	50                   	push   %eax
 527:	ff 75 08             	pushl  0x8(%ebp)
 52a:	e8 31 fe ff ff       	call   360 <putc>
 52f:	83 c4 10             	add    $0x10,%esp
          s++;
 532:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 536:	8b 45 f4             	mov    -0xc(%ebp),%eax
 539:	0f b6 00             	movzbl (%eax),%eax
 53c:	84 c0                	test   %al,%al
 53e:	75 da                	jne    51a <printf+0xe3>
 540:	eb 65                	jmp    5a7 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 542:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 546:	75 1d                	jne    565 <printf+0x12e>
        putc(fd, *ap);
 548:	8b 45 e8             	mov    -0x18(%ebp),%eax
 54b:	8b 00                	mov    (%eax),%eax
 54d:	0f be c0             	movsbl %al,%eax
 550:	83 ec 08             	sub    $0x8,%esp
 553:	50                   	push   %eax
 554:	ff 75 08             	pushl  0x8(%ebp)
 557:	e8 04 fe ff ff       	call   360 <putc>
 55c:	83 c4 10             	add    $0x10,%esp
        ap++;
 55f:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 563:	eb 42                	jmp    5a7 <printf+0x170>
      } else if(c == '%'){
 565:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 569:	75 17                	jne    582 <printf+0x14b>
        putc(fd, c);
 56b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 56e:	0f be c0             	movsbl %al,%eax
 571:	83 ec 08             	sub    $0x8,%esp
 574:	50                   	push   %eax
 575:	ff 75 08             	pushl  0x8(%ebp)
 578:	e8 e3 fd ff ff       	call   360 <putc>
 57d:	83 c4 10             	add    $0x10,%esp
 580:	eb 25                	jmp    5a7 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 582:	83 ec 08             	sub    $0x8,%esp
 585:	6a 25                	push   $0x25
 587:	ff 75 08             	pushl  0x8(%ebp)
 58a:	e8 d1 fd ff ff       	call   360 <putc>
 58f:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 592:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 595:	0f be c0             	movsbl %al,%eax
 598:	83 ec 08             	sub    $0x8,%esp
 59b:	50                   	push   %eax
 59c:	ff 75 08             	pushl  0x8(%ebp)
 59f:	e8 bc fd ff ff       	call   360 <putc>
 5a4:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5a7:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5ae:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5b2:	8b 55 0c             	mov    0xc(%ebp),%edx
 5b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5b8:	01 d0                	add    %edx,%eax
 5ba:	0f b6 00             	movzbl (%eax),%eax
 5bd:	84 c0                	test   %al,%al
 5bf:	0f 85 94 fe ff ff    	jne    459 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 5c5:	90                   	nop
 5c6:	c9                   	leave  
 5c7:	c3                   	ret    

000005c8 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5c8:	55                   	push   %ebp
 5c9:	89 e5                	mov    %esp,%ebp
 5cb:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5ce:	8b 45 08             	mov    0x8(%ebp),%eax
 5d1:	83 e8 08             	sub    $0x8,%eax
 5d4:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5d7:	a1 68 0a 00 00       	mov    0xa68,%eax
 5dc:	89 45 fc             	mov    %eax,-0x4(%ebp)
 5df:	eb 24                	jmp    605 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5e1:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5e4:	8b 00                	mov    (%eax),%eax
 5e6:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5e9:	77 12                	ja     5fd <free+0x35>
 5eb:	8b 45 f8             	mov    -0x8(%ebp),%eax
 5ee:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 5f1:	77 24                	ja     617 <free+0x4f>
 5f3:	8b 45 fc             	mov    -0x4(%ebp),%eax
 5f6:	8b 00                	mov    (%eax),%eax
 5f8:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 5fb:	77 1a                	ja     617 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5fd:	8b 45 fc             	mov    -0x4(%ebp),%eax
 600:	8b 00                	mov    (%eax),%eax
 602:	89 45 fc             	mov    %eax,-0x4(%ebp)
 605:	8b 45 f8             	mov    -0x8(%ebp),%eax
 608:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 60b:	76 d4                	jbe    5e1 <free+0x19>
 60d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 610:	8b 00                	mov    (%eax),%eax
 612:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 615:	76 ca                	jbe    5e1 <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 617:	8b 45 f8             	mov    -0x8(%ebp),%eax
 61a:	8b 40 04             	mov    0x4(%eax),%eax
 61d:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 624:	8b 45 f8             	mov    -0x8(%ebp),%eax
 627:	01 c2                	add    %eax,%edx
 629:	8b 45 fc             	mov    -0x4(%ebp),%eax
 62c:	8b 00                	mov    (%eax),%eax
 62e:	39 c2                	cmp    %eax,%edx
 630:	75 24                	jne    656 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 632:	8b 45 f8             	mov    -0x8(%ebp),%eax
 635:	8b 50 04             	mov    0x4(%eax),%edx
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 00                	mov    (%eax),%eax
 63d:	8b 40 04             	mov    0x4(%eax),%eax
 640:	01 c2                	add    %eax,%edx
 642:	8b 45 f8             	mov    -0x8(%ebp),%eax
 645:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64b:	8b 00                	mov    (%eax),%eax
 64d:	8b 10                	mov    (%eax),%edx
 64f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 652:	89 10                	mov    %edx,(%eax)
 654:	eb 0a                	jmp    660 <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 656:	8b 45 fc             	mov    -0x4(%ebp),%eax
 659:	8b 10                	mov    (%eax),%edx
 65b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 65e:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 660:	8b 45 fc             	mov    -0x4(%ebp),%eax
 663:	8b 40 04             	mov    0x4(%eax),%eax
 666:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 66d:	8b 45 fc             	mov    -0x4(%ebp),%eax
 670:	01 d0                	add    %edx,%eax
 672:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 675:	75 20                	jne    697 <free+0xcf>
    p->s.size += bp->s.size;
 677:	8b 45 fc             	mov    -0x4(%ebp),%eax
 67a:	8b 50 04             	mov    0x4(%eax),%edx
 67d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 680:	8b 40 04             	mov    0x4(%eax),%eax
 683:	01 c2                	add    %eax,%edx
 685:	8b 45 fc             	mov    -0x4(%ebp),%eax
 688:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 68b:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68e:	8b 10                	mov    (%eax),%edx
 690:	8b 45 fc             	mov    -0x4(%ebp),%eax
 693:	89 10                	mov    %edx,(%eax)
 695:	eb 08                	jmp    69f <free+0xd7>
  } else
    p->s.ptr = bp;
 697:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69a:	8b 55 f8             	mov    -0x8(%ebp),%edx
 69d:	89 10                	mov    %edx,(%eax)
  freep = p;
 69f:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6a2:	a3 68 0a 00 00       	mov    %eax,0xa68
}
 6a7:	90                   	nop
 6a8:	c9                   	leave  
 6a9:	c3                   	ret    

000006aa <morecore>:

static Header*
morecore(uint nu)
{
 6aa:	55                   	push   %ebp
 6ab:	89 e5                	mov    %esp,%ebp
 6ad:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6b0:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6b7:	77 07                	ja     6c0 <morecore+0x16>
    nu = 4096;
 6b9:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6c0:	8b 45 08             	mov    0x8(%ebp),%eax
 6c3:	c1 e0 03             	shl    $0x3,%eax
 6c6:	83 ec 0c             	sub    $0xc,%esp
 6c9:	50                   	push   %eax
 6ca:	e8 71 fc ff ff       	call   340 <sbrk>
 6cf:	83 c4 10             	add    $0x10,%esp
 6d2:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 6d5:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 6d9:	75 07                	jne    6e2 <morecore+0x38>
    return 0;
 6db:	b8 00 00 00 00       	mov    $0x0,%eax
 6e0:	eb 26                	jmp    708 <morecore+0x5e>
  hp = (Header*)p;
 6e2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 6e5:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 6e8:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6eb:	8b 55 08             	mov    0x8(%ebp),%edx
 6ee:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 6f1:	8b 45 f0             	mov    -0x10(%ebp),%eax
 6f4:	83 c0 08             	add    $0x8,%eax
 6f7:	83 ec 0c             	sub    $0xc,%esp
 6fa:	50                   	push   %eax
 6fb:	e8 c8 fe ff ff       	call   5c8 <free>
 700:	83 c4 10             	add    $0x10,%esp
  return freep;
 703:	a1 68 0a 00 00       	mov    0xa68,%eax
}
 708:	c9                   	leave  
 709:	c3                   	ret    

0000070a <malloc>:

void*
malloc(uint nbytes)
{
 70a:	55                   	push   %ebp
 70b:	89 e5                	mov    %esp,%ebp
 70d:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 710:	8b 45 08             	mov    0x8(%ebp),%eax
 713:	83 c0 07             	add    $0x7,%eax
 716:	c1 e8 03             	shr    $0x3,%eax
 719:	83 c0 01             	add    $0x1,%eax
 71c:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 71f:	a1 68 0a 00 00       	mov    0xa68,%eax
 724:	89 45 f0             	mov    %eax,-0x10(%ebp)
 727:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 72b:	75 23                	jne    750 <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 72d:	c7 45 f0 60 0a 00 00 	movl   $0xa60,-0x10(%ebp)
 734:	8b 45 f0             	mov    -0x10(%ebp),%eax
 737:	a3 68 0a 00 00       	mov    %eax,0xa68
 73c:	a1 68 0a 00 00       	mov    0xa68,%eax
 741:	a3 60 0a 00 00       	mov    %eax,0xa60
    base.s.size = 0;
 746:	c7 05 64 0a 00 00 00 	movl   $0x0,0xa64
 74d:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 750:	8b 45 f0             	mov    -0x10(%ebp),%eax
 753:	8b 00                	mov    (%eax),%eax
 755:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 758:	8b 45 f4             	mov    -0xc(%ebp),%eax
 75b:	8b 40 04             	mov    0x4(%eax),%eax
 75e:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 761:	72 4d                	jb     7b0 <malloc+0xa6>
      if(p->s.size == nunits)
 763:	8b 45 f4             	mov    -0xc(%ebp),%eax
 766:	8b 40 04             	mov    0x4(%eax),%eax
 769:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 76c:	75 0c                	jne    77a <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 76e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 771:	8b 10                	mov    (%eax),%edx
 773:	8b 45 f0             	mov    -0x10(%ebp),%eax
 776:	89 10                	mov    %edx,(%eax)
 778:	eb 26                	jmp    7a0 <malloc+0x96>
      else {
        p->s.size -= nunits;
 77a:	8b 45 f4             	mov    -0xc(%ebp),%eax
 77d:	8b 40 04             	mov    0x4(%eax),%eax
 780:	2b 45 ec             	sub    -0x14(%ebp),%eax
 783:	89 c2                	mov    %eax,%edx
 785:	8b 45 f4             	mov    -0xc(%ebp),%eax
 788:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 78b:	8b 45 f4             	mov    -0xc(%ebp),%eax
 78e:	8b 40 04             	mov    0x4(%eax),%eax
 791:	c1 e0 03             	shl    $0x3,%eax
 794:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 797:	8b 45 f4             	mov    -0xc(%ebp),%eax
 79a:	8b 55 ec             	mov    -0x14(%ebp),%edx
 79d:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7a0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7a3:	a3 68 0a 00 00       	mov    %eax,0xa68
      return (void*)(p + 1);
 7a8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ab:	83 c0 08             	add    $0x8,%eax
 7ae:	eb 3b                	jmp    7eb <malloc+0xe1>
    }
    if(p == freep)
 7b0:	a1 68 0a 00 00       	mov    0xa68,%eax
 7b5:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7b8:	75 1e                	jne    7d8 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7ba:	83 ec 0c             	sub    $0xc,%esp
 7bd:	ff 75 ec             	pushl  -0x14(%ebp)
 7c0:	e8 e5 fe ff ff       	call   6aa <morecore>
 7c5:	83 c4 10             	add    $0x10,%esp
 7c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
 7cb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 7cf:	75 07                	jne    7d8 <malloc+0xce>
        return 0;
 7d1:	b8 00 00 00 00       	mov    $0x0,%eax
 7d6:	eb 13                	jmp    7eb <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7d8:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7db:	89 45 f0             	mov    %eax,-0x10(%ebp)
 7de:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e1:	8b 00                	mov    (%eax),%eax
 7e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 7e6:	e9 6d ff ff ff       	jmp    758 <malloc+0x4e>
}
 7eb:	c9                   	leave  
 7ec:	c3                   	ret    
