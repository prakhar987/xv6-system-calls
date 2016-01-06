
_time:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"
#include "fs.h"

int main (int argc,char *argv[])
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

 int pid;
 int status,a=3,b=4;	
  14:	c7 45 ec 03 00 00 00 	movl   $0x3,-0x14(%ebp)
  1b:	c7 45 e8 04 00 00 00 	movl   $0x4,-0x18(%ebp)
 pid = fork ();
  22:	e8 c4 02 00 00       	call   2eb <fork>
  27:	89 45 f0             	mov    %eax,-0x10(%ebp)
 if (pid == 0)
  2a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
  2e:	75 34                	jne    64 <main+0x64>
   {	
   exec(argv[1],argv);
  30:	8b 43 04             	mov    0x4(%ebx),%eax
  33:	83 c0 04             	add    $0x4,%eax
  36:	8b 00                	mov    (%eax),%eax
  38:	83 ec 08             	sub    $0x8,%esp
  3b:	ff 73 04             	pushl  0x4(%ebx)
  3e:	50                   	push   %eax
  3f:	e8 e7 02 00 00       	call   32b <exec>
  44:	83 c4 10             	add    $0x10,%esp
    printf(1, "exec %s failed\n", argv[1]);
  47:	8b 43 04             	mov    0x4(%ebx),%eax
  4a:	83 c0 04             	add    $0x4,%eax
  4d:	8b 00                	mov    (%eax),%eax
  4f:	83 ec 04             	sub    $0x4,%esp
  52:	50                   	push   %eax
  53:	68 28 08 00 00       	push   $0x828
  58:	6a 01                	push   $0x1
  5a:	e8 13 04 00 00       	call   472 <printf>
  5f:	83 c4 10             	add    $0x10,%esp
  62:	eb 16                	jmp    7a <main+0x7a>
    }
  else
 {
    status=waitx(&a,&b);
  64:	83 ec 08             	sub    $0x8,%esp
  67:	8d 45 e8             	lea    -0x18(%ebp),%eax
  6a:	50                   	push   %eax
  6b:	8d 45 ec             	lea    -0x14(%ebp),%eax
  6e:	50                   	push   %eax
  6f:	e8 1f 03 00 00       	call   393 <waitx>
  74:	83 c4 10             	add    $0x10,%esp
  77:	89 45 f4             	mov    %eax,-0xc(%ebp)
 }  
 printf(1, "Wait Time = %d\n Run Time = %d with Status %d \n",a,b,status); 
  7a:	8b 55 e8             	mov    -0x18(%ebp),%edx
  7d:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80:	83 ec 0c             	sub    $0xc,%esp
  83:	ff 75 f4             	pushl  -0xc(%ebp)
  86:	52                   	push   %edx
  87:	50                   	push   %eax
  88:	68 38 08 00 00       	push   $0x838
  8d:	6a 01                	push   $0x1
  8f:	e8 de 03 00 00       	call   472 <printf>
  94:	83 c4 20             	add    $0x20,%esp
 exit();
  97:	e8 57 02 00 00       	call   2f3 <exit>

0000009c <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
  9c:	55                   	push   %ebp
  9d:	89 e5                	mov    %esp,%ebp
  9f:	57                   	push   %edi
  a0:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
  a1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  a4:	8b 55 10             	mov    0x10(%ebp),%edx
  a7:	8b 45 0c             	mov    0xc(%ebp),%eax
  aa:	89 cb                	mov    %ecx,%ebx
  ac:	89 df                	mov    %ebx,%edi
  ae:	89 d1                	mov    %edx,%ecx
  b0:	fc                   	cld    
  b1:	f3 aa                	rep stos %al,%es:(%edi)
  b3:	89 ca                	mov    %ecx,%edx
  b5:	89 fb                	mov    %edi,%ebx
  b7:	89 5d 08             	mov    %ebx,0x8(%ebp)
  ba:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
  bd:	90                   	nop
  be:	5b                   	pop    %ebx
  bf:	5f                   	pop    %edi
  c0:	5d                   	pop    %ebp
  c1:	c3                   	ret    

000000c2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, char *t)
{
  c2:	55                   	push   %ebp
  c3:	89 e5                	mov    %esp,%ebp
  c5:	83 ec 10             	sub    $0x10,%esp
  char *os;

  os = s;
  c8:	8b 45 08             	mov    0x8(%ebp),%eax
  cb:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while((*s++ = *t++) != 0)
  ce:	90                   	nop
  cf:	8b 45 08             	mov    0x8(%ebp),%eax
  d2:	8d 50 01             	lea    0x1(%eax),%edx
  d5:	89 55 08             	mov    %edx,0x8(%ebp)
  d8:	8b 55 0c             	mov    0xc(%ebp),%edx
  db:	8d 4a 01             	lea    0x1(%edx),%ecx
  de:	89 4d 0c             	mov    %ecx,0xc(%ebp)
  e1:	0f b6 12             	movzbl (%edx),%edx
  e4:	88 10                	mov    %dl,(%eax)
  e6:	0f b6 00             	movzbl (%eax),%eax
  e9:	84 c0                	test   %al,%al
  eb:	75 e2                	jne    cf <strcpy+0xd>
    ;
  return os;
  ed:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
  f0:	c9                   	leave  
  f1:	c3                   	ret    

000000f2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f2:	55                   	push   %ebp
  f3:	89 e5                	mov    %esp,%ebp
  while(*p && *p == *q)
  f5:	eb 08                	jmp    ff <strcmp+0xd>
    p++, q++;
  f7:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  fb:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strcmp(const char *p, const char *q)
{
  while(*p && *p == *q)
  ff:	8b 45 08             	mov    0x8(%ebp),%eax
 102:	0f b6 00             	movzbl (%eax),%eax
 105:	84 c0                	test   %al,%al
 107:	74 10                	je     119 <strcmp+0x27>
 109:	8b 45 08             	mov    0x8(%ebp),%eax
 10c:	0f b6 10             	movzbl (%eax),%edx
 10f:	8b 45 0c             	mov    0xc(%ebp),%eax
 112:	0f b6 00             	movzbl (%eax),%eax
 115:	38 c2                	cmp    %al,%dl
 117:	74 de                	je     f7 <strcmp+0x5>
    p++, q++;
  return (uchar)*p - (uchar)*q;
 119:	8b 45 08             	mov    0x8(%ebp),%eax
 11c:	0f b6 00             	movzbl (%eax),%eax
 11f:	0f b6 d0             	movzbl %al,%edx
 122:	8b 45 0c             	mov    0xc(%ebp),%eax
 125:	0f b6 00             	movzbl (%eax),%eax
 128:	0f b6 c0             	movzbl %al,%eax
 12b:	29 c2                	sub    %eax,%edx
 12d:	89 d0                	mov    %edx,%eax
}
 12f:	5d                   	pop    %ebp
 130:	c3                   	ret    

00000131 <strlen>:

uint
strlen(char *s)
{
 131:	55                   	push   %ebp
 132:	89 e5                	mov    %esp,%ebp
 134:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
 137:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
 13e:	eb 04                	jmp    144 <strlen+0x13>
 140:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
 144:	8b 55 fc             	mov    -0x4(%ebp),%edx
 147:	8b 45 08             	mov    0x8(%ebp),%eax
 14a:	01 d0                	add    %edx,%eax
 14c:	0f b6 00             	movzbl (%eax),%eax
 14f:	84 c0                	test   %al,%al
 151:	75 ed                	jne    140 <strlen+0xf>
    ;
  return n;
 153:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 156:	c9                   	leave  
 157:	c3                   	ret    

00000158 <memset>:

void*
memset(void *dst, int c, uint n)
{
 158:	55                   	push   %ebp
 159:	89 e5                	mov    %esp,%ebp
  stosb(dst, c, n);
 15b:	8b 45 10             	mov    0x10(%ebp),%eax
 15e:	50                   	push   %eax
 15f:	ff 75 0c             	pushl  0xc(%ebp)
 162:	ff 75 08             	pushl  0x8(%ebp)
 165:	e8 32 ff ff ff       	call   9c <stosb>
 16a:	83 c4 0c             	add    $0xc,%esp
  return dst;
 16d:	8b 45 08             	mov    0x8(%ebp),%eax
}
 170:	c9                   	leave  
 171:	c3                   	ret    

00000172 <strchr>:

char*
strchr(const char *s, char c)
{
 172:	55                   	push   %ebp
 173:	89 e5                	mov    %esp,%ebp
 175:	83 ec 04             	sub    $0x4,%esp
 178:	8b 45 0c             	mov    0xc(%ebp),%eax
 17b:	88 45 fc             	mov    %al,-0x4(%ebp)
  for(; *s; s++)
 17e:	eb 14                	jmp    194 <strchr+0x22>
    if(*s == c)
 180:	8b 45 08             	mov    0x8(%ebp),%eax
 183:	0f b6 00             	movzbl (%eax),%eax
 186:	3a 45 fc             	cmp    -0x4(%ebp),%al
 189:	75 05                	jne    190 <strchr+0x1e>
      return (char*)s;
 18b:	8b 45 08             	mov    0x8(%ebp),%eax
 18e:	eb 13                	jmp    1a3 <strchr+0x31>
}

char*
strchr(const char *s, char c)
{
  for(; *s; s++)
 190:	83 45 08 01          	addl   $0x1,0x8(%ebp)
 194:	8b 45 08             	mov    0x8(%ebp),%eax
 197:	0f b6 00             	movzbl (%eax),%eax
 19a:	84 c0                	test   %al,%al
 19c:	75 e2                	jne    180 <strchr+0xe>
    if(*s == c)
      return (char*)s;
  return 0;
 19e:	b8 00 00 00 00       	mov    $0x0,%eax
}
 1a3:	c9                   	leave  
 1a4:	c3                   	ret    

000001a5 <gets>:

char*
gets(char *buf, int max)
{
 1a5:	55                   	push   %ebp
 1a6:	89 e5                	mov    %esp,%ebp
 1a8:	83 ec 18             	sub    $0x18,%esp
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
 1b2:	eb 42                	jmp    1f6 <gets+0x51>
    cc = read(0, &c, 1);
 1b4:	83 ec 04             	sub    $0x4,%esp
 1b7:	6a 01                	push   $0x1
 1b9:	8d 45 ef             	lea    -0x11(%ebp),%eax
 1bc:	50                   	push   %eax
 1bd:	6a 00                	push   $0x0
 1bf:	e8 47 01 00 00       	call   30b <read>
 1c4:	83 c4 10             	add    $0x10,%esp
 1c7:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(cc < 1)
 1ca:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 1ce:	7e 33                	jle    203 <gets+0x5e>
      break;
    buf[i++] = c;
 1d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1d3:	8d 50 01             	lea    0x1(%eax),%edx
 1d6:	89 55 f4             	mov    %edx,-0xc(%ebp)
 1d9:	89 c2                	mov    %eax,%edx
 1db:	8b 45 08             	mov    0x8(%ebp),%eax
 1de:	01 c2                	add    %eax,%edx
 1e0:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1e4:	88 02                	mov    %al,(%edx)
    if(c == '\n' || c == '\r')
 1e6:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1ea:	3c 0a                	cmp    $0xa,%al
 1ec:	74 16                	je     204 <gets+0x5f>
 1ee:	0f b6 45 ef          	movzbl -0x11(%ebp),%eax
 1f2:	3c 0d                	cmp    $0xd,%al
 1f4:	74 0e                	je     204 <gets+0x5f>
gets(char *buf, int max)
{
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 1f9:	83 c0 01             	add    $0x1,%eax
 1fc:	3b 45 0c             	cmp    0xc(%ebp),%eax
 1ff:	7c b3                	jl     1b4 <gets+0xf>
 201:	eb 01                	jmp    204 <gets+0x5f>
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
 203:	90                   	nop
    buf[i++] = c;
    if(c == '\n' || c == '\r')
      break;
  }
  buf[i] = '\0';
 204:	8b 55 f4             	mov    -0xc(%ebp),%edx
 207:	8b 45 08             	mov    0x8(%ebp),%eax
 20a:	01 d0                	add    %edx,%eax
 20c:	c6 00 00             	movb   $0x0,(%eax)
  return buf;
 20f:	8b 45 08             	mov    0x8(%ebp),%eax
}
 212:	c9                   	leave  
 213:	c3                   	ret    

00000214 <stat>:

int
stat(char *n, struct stat *st)
{
 214:	55                   	push   %ebp
 215:	89 e5                	mov    %esp,%ebp
 217:	83 ec 18             	sub    $0x18,%esp
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 21a:	83 ec 08             	sub    $0x8,%esp
 21d:	6a 00                	push   $0x0
 21f:	ff 75 08             	pushl  0x8(%ebp)
 222:	e8 0c 01 00 00       	call   333 <open>
 227:	83 c4 10             	add    $0x10,%esp
 22a:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(fd < 0)
 22d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 231:	79 07                	jns    23a <stat+0x26>
    return -1;
 233:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
 238:	eb 25                	jmp    25f <stat+0x4b>
  r = fstat(fd, st);
 23a:	83 ec 08             	sub    $0x8,%esp
 23d:	ff 75 0c             	pushl  0xc(%ebp)
 240:	ff 75 f4             	pushl  -0xc(%ebp)
 243:	e8 03 01 00 00       	call   34b <fstat>
 248:	83 c4 10             	add    $0x10,%esp
 24b:	89 45 f0             	mov    %eax,-0x10(%ebp)
  close(fd);
 24e:	83 ec 0c             	sub    $0xc,%esp
 251:	ff 75 f4             	pushl  -0xc(%ebp)
 254:	e8 c2 00 00 00       	call   31b <close>
 259:	83 c4 10             	add    $0x10,%esp
  return r;
 25c:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
 25f:	c9                   	leave  
 260:	c3                   	ret    

00000261 <atoi>:

int
atoi(const char *s)
{
 261:	55                   	push   %ebp
 262:	89 e5                	mov    %esp,%ebp
 264:	83 ec 10             	sub    $0x10,%esp
  int n;

  n = 0;
 267:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
  while('0' <= *s && *s <= '9')
 26e:	eb 25                	jmp    295 <atoi+0x34>
    n = n*10 + *s++ - '0';
 270:	8b 55 fc             	mov    -0x4(%ebp),%edx
 273:	89 d0                	mov    %edx,%eax
 275:	c1 e0 02             	shl    $0x2,%eax
 278:	01 d0                	add    %edx,%eax
 27a:	01 c0                	add    %eax,%eax
 27c:	89 c1                	mov    %eax,%ecx
 27e:	8b 45 08             	mov    0x8(%ebp),%eax
 281:	8d 50 01             	lea    0x1(%eax),%edx
 284:	89 55 08             	mov    %edx,0x8(%ebp)
 287:	0f b6 00             	movzbl (%eax),%eax
 28a:	0f be c0             	movsbl %al,%eax
 28d:	01 c8                	add    %ecx,%eax
 28f:	83 e8 30             	sub    $0x30,%eax
 292:	89 45 fc             	mov    %eax,-0x4(%ebp)
atoi(const char *s)
{
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 295:	8b 45 08             	mov    0x8(%ebp),%eax
 298:	0f b6 00             	movzbl (%eax),%eax
 29b:	3c 2f                	cmp    $0x2f,%al
 29d:	7e 0a                	jle    2a9 <atoi+0x48>
 29f:	8b 45 08             	mov    0x8(%ebp),%eax
 2a2:	0f b6 00             	movzbl (%eax),%eax
 2a5:	3c 39                	cmp    $0x39,%al
 2a7:	7e c7                	jle    270 <atoi+0xf>
    n = n*10 + *s++ - '0';
  return n;
 2a9:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
 2ac:	c9                   	leave  
 2ad:	c3                   	ret    

000002ae <memmove>:

void*
memmove(void *vdst, void *vsrc, int n)
{
 2ae:	55                   	push   %ebp
 2af:	89 e5                	mov    %esp,%ebp
 2b1:	83 ec 10             	sub    $0x10,%esp
  char *dst, *src;
  
  dst = vdst;
 2b4:	8b 45 08             	mov    0x8(%ebp),%eax
 2b7:	89 45 fc             	mov    %eax,-0x4(%ebp)
  src = vsrc;
 2ba:	8b 45 0c             	mov    0xc(%ebp),%eax
 2bd:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0)
 2c0:	eb 17                	jmp    2d9 <memmove+0x2b>
    *dst++ = *src++;
 2c2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 2c5:	8d 50 01             	lea    0x1(%eax),%edx
 2c8:	89 55 fc             	mov    %edx,-0x4(%ebp)
 2cb:	8b 55 f8             	mov    -0x8(%ebp),%edx
 2ce:	8d 4a 01             	lea    0x1(%edx),%ecx
 2d1:	89 4d f8             	mov    %ecx,-0x8(%ebp)
 2d4:	0f b6 12             	movzbl (%edx),%edx
 2d7:	88 10                	mov    %dl,(%eax)
{
  char *dst, *src;
  
  dst = vdst;
  src = vsrc;
  while(n-- > 0)
 2d9:	8b 45 10             	mov    0x10(%ebp),%eax
 2dc:	8d 50 ff             	lea    -0x1(%eax),%edx
 2df:	89 55 10             	mov    %edx,0x10(%ebp)
 2e2:	85 c0                	test   %eax,%eax
 2e4:	7f dc                	jg     2c2 <memmove+0x14>
    *dst++ = *src++;
  return vdst;
 2e6:	8b 45 08             	mov    0x8(%ebp),%eax
}
 2e9:	c9                   	leave  
 2ea:	c3                   	ret    

000002eb <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2eb:	b8 01 00 00 00       	mov    $0x1,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <exit>:
SYSCALL(exit)
 2f3:	b8 02 00 00 00       	mov    $0x2,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <wait>:
SYSCALL(wait)
 2fb:	b8 03 00 00 00       	mov    $0x3,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <pipe>:
SYSCALL(pipe)
 303:	b8 04 00 00 00       	mov    $0x4,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <read>:
SYSCALL(read)
 30b:	b8 05 00 00 00       	mov    $0x5,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <write>:
SYSCALL(write)
 313:	b8 10 00 00 00       	mov    $0x10,%eax
 318:	cd 40                	int    $0x40
 31a:	c3                   	ret    

0000031b <close>:
SYSCALL(close)
 31b:	b8 15 00 00 00       	mov    $0x15,%eax
 320:	cd 40                	int    $0x40
 322:	c3                   	ret    

00000323 <kill>:
SYSCALL(kill)
 323:	b8 06 00 00 00       	mov    $0x6,%eax
 328:	cd 40                	int    $0x40
 32a:	c3                   	ret    

0000032b <exec>:
SYSCALL(exec)
 32b:	b8 07 00 00 00       	mov    $0x7,%eax
 330:	cd 40                	int    $0x40
 332:	c3                   	ret    

00000333 <open>:
SYSCALL(open)
 333:	b8 0f 00 00 00       	mov    $0xf,%eax
 338:	cd 40                	int    $0x40
 33a:	c3                   	ret    

0000033b <mknod>:
SYSCALL(mknod)
 33b:	b8 11 00 00 00       	mov    $0x11,%eax
 340:	cd 40                	int    $0x40
 342:	c3                   	ret    

00000343 <unlink>:
SYSCALL(unlink)
 343:	b8 12 00 00 00       	mov    $0x12,%eax
 348:	cd 40                	int    $0x40
 34a:	c3                   	ret    

0000034b <fstat>:
SYSCALL(fstat)
 34b:	b8 08 00 00 00       	mov    $0x8,%eax
 350:	cd 40                	int    $0x40
 352:	c3                   	ret    

00000353 <link>:
SYSCALL(link)
 353:	b8 13 00 00 00       	mov    $0x13,%eax
 358:	cd 40                	int    $0x40
 35a:	c3                   	ret    

0000035b <mkdir>:
SYSCALL(mkdir)
 35b:	b8 14 00 00 00       	mov    $0x14,%eax
 360:	cd 40                	int    $0x40
 362:	c3                   	ret    

00000363 <chdir>:
SYSCALL(chdir)
 363:	b8 09 00 00 00       	mov    $0x9,%eax
 368:	cd 40                	int    $0x40
 36a:	c3                   	ret    

0000036b <dup>:
SYSCALL(dup)
 36b:	b8 0a 00 00 00       	mov    $0xa,%eax
 370:	cd 40                	int    $0x40
 372:	c3                   	ret    

00000373 <getpid>:
SYSCALL(getpid)
 373:	b8 0b 00 00 00       	mov    $0xb,%eax
 378:	cd 40                	int    $0x40
 37a:	c3                   	ret    

0000037b <sbrk>:
SYSCALL(sbrk)
 37b:	b8 0c 00 00 00       	mov    $0xc,%eax
 380:	cd 40                	int    $0x40
 382:	c3                   	ret    

00000383 <sleep>:
SYSCALL(sleep)
 383:	b8 0d 00 00 00       	mov    $0xd,%eax
 388:	cd 40                	int    $0x40
 38a:	c3                   	ret    

0000038b <uptime>:
SYSCALL(uptime)
 38b:	b8 0e 00 00 00       	mov    $0xe,%eax
 390:	cd 40                	int    $0x40
 392:	c3                   	ret    

00000393 <waitx>:
SYSCALL(waitx)
 393:	b8 16 00 00 00       	mov    $0x16,%eax
 398:	cd 40                	int    $0x40
 39a:	c3                   	ret    

0000039b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 39b:	55                   	push   %ebp
 39c:	89 e5                	mov    %esp,%ebp
 39e:	83 ec 18             	sub    $0x18,%esp
 3a1:	8b 45 0c             	mov    0xc(%ebp),%eax
 3a4:	88 45 f4             	mov    %al,-0xc(%ebp)
  write(fd, &c, 1);
 3a7:	83 ec 04             	sub    $0x4,%esp
 3aa:	6a 01                	push   $0x1
 3ac:	8d 45 f4             	lea    -0xc(%ebp),%eax
 3af:	50                   	push   %eax
 3b0:	ff 75 08             	pushl  0x8(%ebp)
 3b3:	e8 5b ff ff ff       	call   313 <write>
 3b8:	83 c4 10             	add    $0x10,%esp
}
 3bb:	90                   	nop
 3bc:	c9                   	leave  
 3bd:	c3                   	ret    

000003be <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3be:	55                   	push   %ebp
 3bf:	89 e5                	mov    %esp,%ebp
 3c1:	53                   	push   %ebx
 3c2:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789ABCDEF";
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
 3c5:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  if(sgn && xx < 0){
 3cc:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
 3d0:	74 17                	je     3e9 <printint+0x2b>
 3d2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
 3d6:	79 11                	jns    3e9 <printint+0x2b>
    neg = 1;
 3d8:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
    x = -xx;
 3df:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e2:	f7 d8                	neg    %eax
 3e4:	89 45 ec             	mov    %eax,-0x14(%ebp)
 3e7:	eb 06                	jmp    3ef <printint+0x31>
  } else {
    x = xx;
 3e9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ec:	89 45 ec             	mov    %eax,-0x14(%ebp)
  }

  i = 0;
 3ef:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
 3f6:	8b 4d f4             	mov    -0xc(%ebp),%ecx
 3f9:	8d 41 01             	lea    0x1(%ecx),%eax
 3fc:	89 45 f4             	mov    %eax,-0xc(%ebp)
 3ff:	8b 5d 10             	mov    0x10(%ebp),%ebx
 402:	8b 45 ec             	mov    -0x14(%ebp),%eax
 405:	ba 00 00 00 00       	mov    $0x0,%edx
 40a:	f7 f3                	div    %ebx
 40c:	89 d0                	mov    %edx,%eax
 40e:	0f b6 80 bc 0a 00 00 	movzbl 0xabc(%eax),%eax
 415:	88 44 0d dc          	mov    %al,-0x24(%ebp,%ecx,1)
  }while((x /= base) != 0);
 419:	8b 5d 10             	mov    0x10(%ebp),%ebx
 41c:	8b 45 ec             	mov    -0x14(%ebp),%eax
 41f:	ba 00 00 00 00       	mov    $0x0,%edx
 424:	f7 f3                	div    %ebx
 426:	89 45 ec             	mov    %eax,-0x14(%ebp)
 429:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 42d:	75 c7                	jne    3f6 <printint+0x38>
  if(neg)
 42f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 433:	74 2d                	je     462 <printint+0xa4>
    buf[i++] = '-';
 435:	8b 45 f4             	mov    -0xc(%ebp),%eax
 438:	8d 50 01             	lea    0x1(%eax),%edx
 43b:	89 55 f4             	mov    %edx,-0xc(%ebp)
 43e:	c6 44 05 dc 2d       	movb   $0x2d,-0x24(%ebp,%eax,1)

  while(--i >= 0)
 443:	eb 1d                	jmp    462 <printint+0xa4>
    putc(fd, buf[i]);
 445:	8d 55 dc             	lea    -0x24(%ebp),%edx
 448:	8b 45 f4             	mov    -0xc(%ebp),%eax
 44b:	01 d0                	add    %edx,%eax
 44d:	0f b6 00             	movzbl (%eax),%eax
 450:	0f be c0             	movsbl %al,%eax
 453:	83 ec 08             	sub    $0x8,%esp
 456:	50                   	push   %eax
 457:	ff 75 08             	pushl  0x8(%ebp)
 45a:	e8 3c ff ff ff       	call   39b <putc>
 45f:	83 c4 10             	add    $0x10,%esp
    buf[i++] = digits[x % base];
  }while((x /= base) != 0);
  if(neg)
    buf[i++] = '-';

  while(--i >= 0)
 462:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
 466:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 46a:	79 d9                	jns    445 <printint+0x87>
    putc(fd, buf[i]);
}
 46c:	90                   	nop
 46d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 470:	c9                   	leave  
 471:	c3                   	ret    

00000472 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, char *fmt, ...)
{
 472:	55                   	push   %ebp
 473:	89 e5                	mov    %esp,%ebp
 475:	83 ec 28             	sub    $0x28,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
 478:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  ap = (uint*)(void*)&fmt + 1;
 47f:	8d 45 0c             	lea    0xc(%ebp),%eax
 482:	83 c0 04             	add    $0x4,%eax
 485:	89 45 e8             	mov    %eax,-0x18(%ebp)
  for(i = 0; fmt[i]; i++){
 488:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
 48f:	e9 59 01 00 00       	jmp    5ed <printf+0x17b>
    c = fmt[i] & 0xff;
 494:	8b 55 0c             	mov    0xc(%ebp),%edx
 497:	8b 45 f0             	mov    -0x10(%ebp),%eax
 49a:	01 d0                	add    %edx,%eax
 49c:	0f b6 00             	movzbl (%eax),%eax
 49f:	0f be c0             	movsbl %al,%eax
 4a2:	25 ff 00 00 00       	and    $0xff,%eax
 4a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(state == 0){
 4aa:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
 4ae:	75 2c                	jne    4dc <printf+0x6a>
      if(c == '%'){
 4b0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 4b4:	75 0c                	jne    4c2 <printf+0x50>
        state = '%';
 4b6:	c7 45 ec 25 00 00 00 	movl   $0x25,-0x14(%ebp)
 4bd:	e9 27 01 00 00       	jmp    5e9 <printf+0x177>
      } else {
        putc(fd, c);
 4c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c5:	0f be c0             	movsbl %al,%eax
 4c8:	83 ec 08             	sub    $0x8,%esp
 4cb:	50                   	push   %eax
 4cc:	ff 75 08             	pushl  0x8(%ebp)
 4cf:	e8 c7 fe ff ff       	call   39b <putc>
 4d4:	83 c4 10             	add    $0x10,%esp
 4d7:	e9 0d 01 00 00       	jmp    5e9 <printf+0x177>
      }
    } else if(state == '%'){
 4dc:	83 7d ec 25          	cmpl   $0x25,-0x14(%ebp)
 4e0:	0f 85 03 01 00 00    	jne    5e9 <printf+0x177>
      if(c == 'd'){
 4e6:	83 7d e4 64          	cmpl   $0x64,-0x1c(%ebp)
 4ea:	75 1e                	jne    50a <printf+0x98>
        printint(fd, *ap, 10, 1);
 4ec:	8b 45 e8             	mov    -0x18(%ebp),%eax
 4ef:	8b 00                	mov    (%eax),%eax
 4f1:	6a 01                	push   $0x1
 4f3:	6a 0a                	push   $0xa
 4f5:	50                   	push   %eax
 4f6:	ff 75 08             	pushl  0x8(%ebp)
 4f9:	e8 c0 fe ff ff       	call   3be <printint>
 4fe:	83 c4 10             	add    $0x10,%esp
        ap++;
 501:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 505:	e9 d8 00 00 00       	jmp    5e2 <printf+0x170>
      } else if(c == 'x' || c == 'p'){
 50a:	83 7d e4 78          	cmpl   $0x78,-0x1c(%ebp)
 50e:	74 06                	je     516 <printf+0xa4>
 510:	83 7d e4 70          	cmpl   $0x70,-0x1c(%ebp)
 514:	75 1e                	jne    534 <printf+0xc2>
        printint(fd, *ap, 16, 0);
 516:	8b 45 e8             	mov    -0x18(%ebp),%eax
 519:	8b 00                	mov    (%eax),%eax
 51b:	6a 00                	push   $0x0
 51d:	6a 10                	push   $0x10
 51f:	50                   	push   %eax
 520:	ff 75 08             	pushl  0x8(%ebp)
 523:	e8 96 fe ff ff       	call   3be <printint>
 528:	83 c4 10             	add    $0x10,%esp
        ap++;
 52b:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 52f:	e9 ae 00 00 00       	jmp    5e2 <printf+0x170>
      } else if(c == 's'){
 534:	83 7d e4 73          	cmpl   $0x73,-0x1c(%ebp)
 538:	75 43                	jne    57d <printf+0x10b>
        s = (char*)*ap;
 53a:	8b 45 e8             	mov    -0x18(%ebp),%eax
 53d:	8b 00                	mov    (%eax),%eax
 53f:	89 45 f4             	mov    %eax,-0xc(%ebp)
        ap++;
 542:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
        if(s == 0)
 546:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 54a:	75 25                	jne    571 <printf+0xff>
          s = "(null)";
 54c:	c7 45 f4 67 08 00 00 	movl   $0x867,-0xc(%ebp)
        while(*s != 0){
 553:	eb 1c                	jmp    571 <printf+0xff>
          putc(fd, *s);
 555:	8b 45 f4             	mov    -0xc(%ebp),%eax
 558:	0f b6 00             	movzbl (%eax),%eax
 55b:	0f be c0             	movsbl %al,%eax
 55e:	83 ec 08             	sub    $0x8,%esp
 561:	50                   	push   %eax
 562:	ff 75 08             	pushl  0x8(%ebp)
 565:	e8 31 fe ff ff       	call   39b <putc>
 56a:	83 c4 10             	add    $0x10,%esp
          s++;
 56d:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      } else if(c == 's'){
        s = (char*)*ap;
        ap++;
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 571:	8b 45 f4             	mov    -0xc(%ebp),%eax
 574:	0f b6 00             	movzbl (%eax),%eax
 577:	84 c0                	test   %al,%al
 579:	75 da                	jne    555 <printf+0xe3>
 57b:	eb 65                	jmp    5e2 <printf+0x170>
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 57d:	83 7d e4 63          	cmpl   $0x63,-0x1c(%ebp)
 581:	75 1d                	jne    5a0 <printf+0x12e>
        putc(fd, *ap);
 583:	8b 45 e8             	mov    -0x18(%ebp),%eax
 586:	8b 00                	mov    (%eax),%eax
 588:	0f be c0             	movsbl %al,%eax
 58b:	83 ec 08             	sub    $0x8,%esp
 58e:	50                   	push   %eax
 58f:	ff 75 08             	pushl  0x8(%ebp)
 592:	e8 04 fe ff ff       	call   39b <putc>
 597:	83 c4 10             	add    $0x10,%esp
        ap++;
 59a:	83 45 e8 04          	addl   $0x4,-0x18(%ebp)
 59e:	eb 42                	jmp    5e2 <printf+0x170>
      } else if(c == '%'){
 5a0:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
 5a4:	75 17                	jne    5bd <printf+0x14b>
        putc(fd, c);
 5a6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5a9:	0f be c0             	movsbl %al,%eax
 5ac:	83 ec 08             	sub    $0x8,%esp
 5af:	50                   	push   %eax
 5b0:	ff 75 08             	pushl  0x8(%ebp)
 5b3:	e8 e3 fd ff ff       	call   39b <putc>
 5b8:	83 c4 10             	add    $0x10,%esp
 5bb:	eb 25                	jmp    5e2 <printf+0x170>
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 5bd:	83 ec 08             	sub    $0x8,%esp
 5c0:	6a 25                	push   $0x25
 5c2:	ff 75 08             	pushl  0x8(%ebp)
 5c5:	e8 d1 fd ff ff       	call   39b <putc>
 5ca:	83 c4 10             	add    $0x10,%esp
        putc(fd, c);
 5cd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5d0:	0f be c0             	movsbl %al,%eax
 5d3:	83 ec 08             	sub    $0x8,%esp
 5d6:	50                   	push   %eax
 5d7:	ff 75 08             	pushl  0x8(%ebp)
 5da:	e8 bc fd ff ff       	call   39b <putc>
 5df:	83 c4 10             	add    $0x10,%esp
      }
      state = 0;
 5e2:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
  for(i = 0; fmt[i]; i++){
 5e9:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
 5ed:	8b 55 0c             	mov    0xc(%ebp),%edx
 5f0:	8b 45 f0             	mov    -0x10(%ebp),%eax
 5f3:	01 d0                	add    %edx,%eax
 5f5:	0f b6 00             	movzbl (%eax),%eax
 5f8:	84 c0                	test   %al,%al
 5fa:	0f 85 94 fe ff ff    	jne    494 <printf+0x22>
        putc(fd, c);
      }
      state = 0;
    }
  }
}
 600:	90                   	nop
 601:	c9                   	leave  
 602:	c3                   	ret    

00000603 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 603:	55                   	push   %ebp
 604:	89 e5                	mov    %esp,%ebp
 606:	83 ec 10             	sub    $0x10,%esp
  Header *bp, *p;

  bp = (Header*)ap - 1;
 609:	8b 45 08             	mov    0x8(%ebp),%eax
 60c:	83 e8 08             	sub    $0x8,%eax
 60f:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 612:	a1 d8 0a 00 00       	mov    0xad8,%eax
 617:	89 45 fc             	mov    %eax,-0x4(%ebp)
 61a:	eb 24                	jmp    640 <free+0x3d>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 61c:	8b 45 fc             	mov    -0x4(%ebp),%eax
 61f:	8b 00                	mov    (%eax),%eax
 621:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 624:	77 12                	ja     638 <free+0x35>
 626:	8b 45 f8             	mov    -0x8(%ebp),%eax
 629:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 62c:	77 24                	ja     652 <free+0x4f>
 62e:	8b 45 fc             	mov    -0x4(%ebp),%eax
 631:	8b 00                	mov    (%eax),%eax
 633:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 636:	77 1a                	ja     652 <free+0x4f>
free(void *ap)
{
  Header *bp, *p;

  bp = (Header*)ap - 1;
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 638:	8b 45 fc             	mov    -0x4(%ebp),%eax
 63b:	8b 00                	mov    (%eax),%eax
 63d:	89 45 fc             	mov    %eax,-0x4(%ebp)
 640:	8b 45 f8             	mov    -0x8(%ebp),%eax
 643:	3b 45 fc             	cmp    -0x4(%ebp),%eax
 646:	76 d4                	jbe    61c <free+0x19>
 648:	8b 45 fc             	mov    -0x4(%ebp),%eax
 64b:	8b 00                	mov    (%eax),%eax
 64d:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 650:	76 ca                	jbe    61c <free+0x19>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
 652:	8b 45 f8             	mov    -0x8(%ebp),%eax
 655:	8b 40 04             	mov    0x4(%eax),%eax
 658:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 65f:	8b 45 f8             	mov    -0x8(%ebp),%eax
 662:	01 c2                	add    %eax,%edx
 664:	8b 45 fc             	mov    -0x4(%ebp),%eax
 667:	8b 00                	mov    (%eax),%eax
 669:	39 c2                	cmp    %eax,%edx
 66b:	75 24                	jne    691 <free+0x8e>
    bp->s.size += p->s.ptr->s.size;
 66d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 670:	8b 50 04             	mov    0x4(%eax),%edx
 673:	8b 45 fc             	mov    -0x4(%ebp),%eax
 676:	8b 00                	mov    (%eax),%eax
 678:	8b 40 04             	mov    0x4(%eax),%eax
 67b:	01 c2                	add    %eax,%edx
 67d:	8b 45 f8             	mov    -0x8(%ebp),%eax
 680:	89 50 04             	mov    %edx,0x4(%eax)
    bp->s.ptr = p->s.ptr->s.ptr;
 683:	8b 45 fc             	mov    -0x4(%ebp),%eax
 686:	8b 00                	mov    (%eax),%eax
 688:	8b 10                	mov    (%eax),%edx
 68a:	8b 45 f8             	mov    -0x8(%ebp),%eax
 68d:	89 10                	mov    %edx,(%eax)
 68f:	eb 0a                	jmp    69b <free+0x98>
  } else
    bp->s.ptr = p->s.ptr;
 691:	8b 45 fc             	mov    -0x4(%ebp),%eax
 694:	8b 10                	mov    (%eax),%edx
 696:	8b 45 f8             	mov    -0x8(%ebp),%eax
 699:	89 10                	mov    %edx,(%eax)
  if(p + p->s.size == bp){
 69b:	8b 45 fc             	mov    -0x4(%ebp),%eax
 69e:	8b 40 04             	mov    0x4(%eax),%eax
 6a1:	8d 14 c5 00 00 00 00 	lea    0x0(,%eax,8),%edx
 6a8:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ab:	01 d0                	add    %edx,%eax
 6ad:	3b 45 f8             	cmp    -0x8(%ebp),%eax
 6b0:	75 20                	jne    6d2 <free+0xcf>
    p->s.size += bp->s.size;
 6b2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6b5:	8b 50 04             	mov    0x4(%eax),%edx
 6b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6bb:	8b 40 04             	mov    0x4(%eax),%eax
 6be:	01 c2                	add    %eax,%edx
 6c0:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6c3:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6c6:	8b 45 f8             	mov    -0x8(%ebp),%eax
 6c9:	8b 10                	mov    (%eax),%edx
 6cb:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6ce:	89 10                	mov    %edx,(%eax)
 6d0:	eb 08                	jmp    6da <free+0xd7>
  } else
    p->s.ptr = bp;
 6d2:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6d5:	8b 55 f8             	mov    -0x8(%ebp),%edx
 6d8:	89 10                	mov    %edx,(%eax)
  freep = p;
 6da:	8b 45 fc             	mov    -0x4(%ebp),%eax
 6dd:	a3 d8 0a 00 00       	mov    %eax,0xad8
}
 6e2:	90                   	nop
 6e3:	c9                   	leave  
 6e4:	c3                   	ret    

000006e5 <morecore>:

static Header*
morecore(uint nu)
{
 6e5:	55                   	push   %ebp
 6e6:	89 e5                	mov    %esp,%ebp
 6e8:	83 ec 18             	sub    $0x18,%esp
  char *p;
  Header *hp;

  if(nu < 4096)
 6eb:	81 7d 08 ff 0f 00 00 	cmpl   $0xfff,0x8(%ebp)
 6f2:	77 07                	ja     6fb <morecore+0x16>
    nu = 4096;
 6f4:	c7 45 08 00 10 00 00 	movl   $0x1000,0x8(%ebp)
  p = sbrk(nu * sizeof(Header));
 6fb:	8b 45 08             	mov    0x8(%ebp),%eax
 6fe:	c1 e0 03             	shl    $0x3,%eax
 701:	83 ec 0c             	sub    $0xc,%esp
 704:	50                   	push   %eax
 705:	e8 71 fc ff ff       	call   37b <sbrk>
 70a:	83 c4 10             	add    $0x10,%esp
 70d:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(p == (char*)-1)
 710:	83 7d f4 ff          	cmpl   $0xffffffff,-0xc(%ebp)
 714:	75 07                	jne    71d <morecore+0x38>
    return 0;
 716:	b8 00 00 00 00       	mov    $0x0,%eax
 71b:	eb 26                	jmp    743 <morecore+0x5e>
  hp = (Header*)p;
 71d:	8b 45 f4             	mov    -0xc(%ebp),%eax
 720:	89 45 f0             	mov    %eax,-0x10(%ebp)
  hp->s.size = nu;
 723:	8b 45 f0             	mov    -0x10(%ebp),%eax
 726:	8b 55 08             	mov    0x8(%ebp),%edx
 729:	89 50 04             	mov    %edx,0x4(%eax)
  free((void*)(hp + 1));
 72c:	8b 45 f0             	mov    -0x10(%ebp),%eax
 72f:	83 c0 08             	add    $0x8,%eax
 732:	83 ec 0c             	sub    $0xc,%esp
 735:	50                   	push   %eax
 736:	e8 c8 fe ff ff       	call   603 <free>
 73b:	83 c4 10             	add    $0x10,%esp
  return freep;
 73e:	a1 d8 0a 00 00       	mov    0xad8,%eax
}
 743:	c9                   	leave  
 744:	c3                   	ret    

00000745 <malloc>:

void*
malloc(uint nbytes)
{
 745:	55                   	push   %ebp
 746:	89 e5                	mov    %esp,%ebp
 748:	83 ec 18             	sub    $0x18,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 74b:	8b 45 08             	mov    0x8(%ebp),%eax
 74e:	83 c0 07             	add    $0x7,%eax
 751:	c1 e8 03             	shr    $0x3,%eax
 754:	83 c0 01             	add    $0x1,%eax
 757:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((prevp = freep) == 0){
 75a:	a1 d8 0a 00 00       	mov    0xad8,%eax
 75f:	89 45 f0             	mov    %eax,-0x10(%ebp)
 762:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
 766:	75 23                	jne    78b <malloc+0x46>
    base.s.ptr = freep = prevp = &base;
 768:	c7 45 f0 d0 0a 00 00 	movl   $0xad0,-0x10(%ebp)
 76f:	8b 45 f0             	mov    -0x10(%ebp),%eax
 772:	a3 d8 0a 00 00       	mov    %eax,0xad8
 777:	a1 d8 0a 00 00       	mov    0xad8,%eax
 77c:	a3 d0 0a 00 00       	mov    %eax,0xad0
    base.s.size = 0;
 781:	c7 05 d4 0a 00 00 00 	movl   $0x0,0xad4
 788:	00 00 00 
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 78b:	8b 45 f0             	mov    -0x10(%ebp),%eax
 78e:	8b 00                	mov    (%eax),%eax
 790:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(p->s.size >= nunits){
 793:	8b 45 f4             	mov    -0xc(%ebp),%eax
 796:	8b 40 04             	mov    0x4(%eax),%eax
 799:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 79c:	72 4d                	jb     7eb <malloc+0xa6>
      if(p->s.size == nunits)
 79e:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7a1:	8b 40 04             	mov    0x4(%eax),%eax
 7a4:	3b 45 ec             	cmp    -0x14(%ebp),%eax
 7a7:	75 0c                	jne    7b5 <malloc+0x70>
        prevp->s.ptr = p->s.ptr;
 7a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7ac:	8b 10                	mov    (%eax),%edx
 7ae:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7b1:	89 10                	mov    %edx,(%eax)
 7b3:	eb 26                	jmp    7db <malloc+0x96>
      else {
        p->s.size -= nunits;
 7b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7b8:	8b 40 04             	mov    0x4(%eax),%eax
 7bb:	2b 45 ec             	sub    -0x14(%ebp),%eax
 7be:	89 c2                	mov    %eax,%edx
 7c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 7c6:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7c9:	8b 40 04             	mov    0x4(%eax),%eax
 7cc:	c1 e0 03             	shl    $0x3,%eax
 7cf:	01 45 f4             	add    %eax,-0xc(%ebp)
        p->s.size = nunits;
 7d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7d5:	8b 55 ec             	mov    -0x14(%ebp),%edx
 7d8:	89 50 04             	mov    %edx,0x4(%eax)
      }
      freep = prevp;
 7db:	8b 45 f0             	mov    -0x10(%ebp),%eax
 7de:	a3 d8 0a 00 00       	mov    %eax,0xad8
      return (void*)(p + 1);
 7e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
 7e6:	83 c0 08             	add    $0x8,%eax
 7e9:	eb 3b                	jmp    826 <malloc+0xe1>
    }
    if(p == freep)
 7eb:	a1 d8 0a 00 00       	mov    0xad8,%eax
 7f0:	39 45 f4             	cmp    %eax,-0xc(%ebp)
 7f3:	75 1e                	jne    813 <malloc+0xce>
      if((p = morecore(nunits)) == 0)
 7f5:	83 ec 0c             	sub    $0xc,%esp
 7f8:	ff 75 ec             	pushl  -0x14(%ebp)
 7fb:	e8 e5 fe ff ff       	call   6e5 <morecore>
 800:	83 c4 10             	add    $0x10,%esp
 803:	89 45 f4             	mov    %eax,-0xc(%ebp)
 806:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
 80a:	75 07                	jne    813 <malloc+0xce>
        return 0;
 80c:	b8 00 00 00 00       	mov    $0x0,%eax
 811:	eb 13                	jmp    826 <malloc+0xe1>
  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
  if((prevp = freep) == 0){
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 813:	8b 45 f4             	mov    -0xc(%ebp),%eax
 816:	89 45 f0             	mov    %eax,-0x10(%ebp)
 819:	8b 45 f4             	mov    -0xc(%ebp),%eax
 81c:	8b 00                	mov    (%eax),%eax
 81e:	89 45 f4             	mov    %eax,-0xc(%ebp)
      return (void*)(p + 1);
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
 821:	e9 6d ff ff ff       	jmp    793 <malloc+0x4e>
}
 826:	c9                   	leave  
 827:	c3                   	ret    
