
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4 0f                	in     $0xf,%al

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 a0 10 00       	mov    $0x10a000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc 50 c6 10 80       	mov    $0x8010c650,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 74 38 10 80       	mov    $0x80103874,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  initlock(&bcache.lock, "bcache");
8010003a:	83 ec 08             	sub    $0x8,%esp
8010003d:	68 78 87 10 80       	push   $0x80108778
80100042:	68 60 c6 10 80       	push   $0x8010c660
80100047:	e8 39 51 00 00       	call   80105185 <initlock>
8010004c:	83 c4 10             	add    $0x10,%esp

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
8010004f:	c7 05 70 05 11 80 64 	movl   $0x80110564,0x80110570
80100056:	05 11 80 
  bcache.head.next = &bcache.head;
80100059:	c7 05 74 05 11 80 64 	movl   $0x80110564,0x80110574
80100060:	05 11 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100063:	c7 45 f4 94 c6 10 80 	movl   $0x8010c694,-0xc(%ebp)
8010006a:	eb 3a                	jmp    801000a6 <binit+0x72>
    b->next = bcache.head.next;
8010006c:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100072:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100075:	89 50 10             	mov    %edx,0x10(%eax)
    b->prev = &bcache.head;
80100078:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010007b:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
    b->dev = -1;
80100082:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100085:	c7 40 04 ff ff ff ff 	movl   $0xffffffff,0x4(%eax)
    bcache.head.next->prev = b;
8010008c:	a1 74 05 11 80       	mov    0x80110574,%eax
80100091:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100094:	89 50 0c             	mov    %edx,0xc(%eax)
    bcache.head.next = b;
80100097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010009a:	a3 74 05 11 80       	mov    %eax,0x80110574

//PAGEBREAK!
  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
  bcache.head.next = &bcache.head;
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010009f:	81 45 f4 18 02 00 00 	addl   $0x218,-0xc(%ebp)
801000a6:	b8 64 05 11 80       	mov    $0x80110564,%eax
801000ab:	39 45 f4             	cmp    %eax,-0xc(%ebp)
801000ae:	72 bc                	jb     8010006c <binit+0x38>
    b->prev = &bcache.head;
    b->dev = -1;
    bcache.head.next->prev = b;
    bcache.head.next = b;
  }
}
801000b0:	90                   	nop
801000b1:	c9                   	leave  
801000b2:	c3                   	ret    

801000b3 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return B_BUSY buffer.
static struct buf*
bget(uint dev, uint blockno)
{
801000b3:	55                   	push   %ebp
801000b4:	89 e5                	mov    %esp,%ebp
801000b6:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  acquire(&bcache.lock);
801000b9:	83 ec 0c             	sub    $0xc,%esp
801000bc:	68 60 c6 10 80       	push   $0x8010c660
801000c1:	e8 e1 50 00 00       	call   801051a7 <acquire>
801000c6:	83 c4 10             	add    $0x10,%esp

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
801000c9:	a1 74 05 11 80       	mov    0x80110574,%eax
801000ce:	89 45 f4             	mov    %eax,-0xc(%ebp)
801000d1:	eb 67                	jmp    8010013a <bget+0x87>
    if(b->dev == dev && b->blockno == blockno){
801000d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000d6:	8b 40 04             	mov    0x4(%eax),%eax
801000d9:	3b 45 08             	cmp    0x8(%ebp),%eax
801000dc:	75 53                	jne    80100131 <bget+0x7e>
801000de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000e1:	8b 40 08             	mov    0x8(%eax),%eax
801000e4:	3b 45 0c             	cmp    0xc(%ebp),%eax
801000e7:	75 48                	jne    80100131 <bget+0x7e>
      if(!(b->flags & B_BUSY)){
801000e9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000ec:	8b 00                	mov    (%eax),%eax
801000ee:	83 e0 01             	and    $0x1,%eax
801000f1:	85 c0                	test   %eax,%eax
801000f3:	75 27                	jne    8010011c <bget+0x69>
        b->flags |= B_BUSY;
801000f5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801000f8:	8b 00                	mov    (%eax),%eax
801000fa:	83 c8 01             	or     $0x1,%eax
801000fd:	89 c2                	mov    %eax,%edx
801000ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100102:	89 10                	mov    %edx,(%eax)
        release(&bcache.lock);
80100104:	83 ec 0c             	sub    $0xc,%esp
80100107:	68 60 c6 10 80       	push   $0x8010c660
8010010c:	e8 fd 50 00 00       	call   8010520e <release>
80100111:	83 c4 10             	add    $0x10,%esp
        return b;
80100114:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100117:	e9 98 00 00 00       	jmp    801001b4 <bget+0x101>
      }
      sleep(b, &bcache.lock);
8010011c:	83 ec 08             	sub    $0x8,%esp
8010011f:	68 60 c6 10 80       	push   $0x8010c660
80100124:	ff 75 f4             	pushl  -0xc(%ebp)
80100127:	e8 79 4d 00 00       	call   80104ea5 <sleep>
8010012c:	83 c4 10             	add    $0x10,%esp
      goto loop;
8010012f:	eb 98                	jmp    801000c9 <bget+0x16>

  acquire(&bcache.lock);

 loop:
  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
80100131:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100134:	8b 40 10             	mov    0x10(%eax),%eax
80100137:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010013a:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
80100141:	75 90                	jne    801000d3 <bget+0x20>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100143:	a1 70 05 11 80       	mov    0x80110570,%eax
80100148:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010014b:	eb 51                	jmp    8010019e <bget+0xeb>
    if((b->flags & B_BUSY) == 0 && (b->flags & B_DIRTY) == 0){
8010014d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100150:	8b 00                	mov    (%eax),%eax
80100152:	83 e0 01             	and    $0x1,%eax
80100155:	85 c0                	test   %eax,%eax
80100157:	75 3c                	jne    80100195 <bget+0xe2>
80100159:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010015c:	8b 00                	mov    (%eax),%eax
8010015e:	83 e0 04             	and    $0x4,%eax
80100161:	85 c0                	test   %eax,%eax
80100163:	75 30                	jne    80100195 <bget+0xe2>
      b->dev = dev;
80100165:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100168:	8b 55 08             	mov    0x8(%ebp),%edx
8010016b:	89 50 04             	mov    %edx,0x4(%eax)
      b->blockno = blockno;
8010016e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100171:	8b 55 0c             	mov    0xc(%ebp),%edx
80100174:	89 50 08             	mov    %edx,0x8(%eax)
      b->flags = B_BUSY;
80100177:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010017a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
      release(&bcache.lock);
80100180:	83 ec 0c             	sub    $0xc,%esp
80100183:	68 60 c6 10 80       	push   $0x8010c660
80100188:	e8 81 50 00 00       	call   8010520e <release>
8010018d:	83 c4 10             	add    $0x10,%esp
      return b;
80100190:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100193:	eb 1f                	jmp    801001b4 <bget+0x101>
  }

  // Not cached; recycle some non-busy and clean buffer.
  // "clean" because B_DIRTY and !B_BUSY means log.c
  // hasn't yet committed the changes to the buffer.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100195:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100198:	8b 40 0c             	mov    0xc(%eax),%eax
8010019b:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010019e:	81 7d f4 64 05 11 80 	cmpl   $0x80110564,-0xc(%ebp)
801001a5:	75 a6                	jne    8010014d <bget+0x9a>
      b->flags = B_BUSY;
      release(&bcache.lock);
      return b;
    }
  }
  panic("bget: no buffers");
801001a7:	83 ec 0c             	sub    $0xc,%esp
801001aa:	68 7f 87 10 80       	push   $0x8010877f
801001af:	e8 b2 03 00 00       	call   80100566 <panic>
}
801001b4:	c9                   	leave  
801001b5:	c3                   	ret    

801001b6 <bread>:

// Return a B_BUSY buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
801001b6:	55                   	push   %ebp
801001b7:	89 e5                	mov    %esp,%ebp
801001b9:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  b = bget(dev, blockno);
801001bc:	83 ec 08             	sub    $0x8,%esp
801001bf:	ff 75 0c             	pushl  0xc(%ebp)
801001c2:	ff 75 08             	pushl  0x8(%ebp)
801001c5:	e8 e9 fe ff ff       	call   801000b3 <bget>
801001ca:	83 c4 10             	add    $0x10,%esp
801001cd:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(!(b->flags & B_VALID)) {
801001d0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801001d3:	8b 00                	mov    (%eax),%eax
801001d5:	83 e0 02             	and    $0x2,%eax
801001d8:	85 c0                	test   %eax,%eax
801001da:	75 0e                	jne    801001ea <bread+0x34>
    iderw(b);
801001dc:	83 ec 0c             	sub    $0xc,%esp
801001df:	ff 75 f4             	pushl  -0xc(%ebp)
801001e2:	e8 0b 27 00 00       	call   801028f2 <iderw>
801001e7:	83 c4 10             	add    $0x10,%esp
  }
  return b;
801001ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801001ed:	c9                   	leave  
801001ee:	c3                   	ret    

801001ef <bwrite>:

// Write b's contents to disk.  Must be B_BUSY.
void
bwrite(struct buf *b)
{
801001ef:	55                   	push   %ebp
801001f0:	89 e5                	mov    %esp,%ebp
801001f2:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
801001f5:	8b 45 08             	mov    0x8(%ebp),%eax
801001f8:	8b 00                	mov    (%eax),%eax
801001fa:	83 e0 01             	and    $0x1,%eax
801001fd:	85 c0                	test   %eax,%eax
801001ff:	75 0d                	jne    8010020e <bwrite+0x1f>
    panic("bwrite");
80100201:	83 ec 0c             	sub    $0xc,%esp
80100204:	68 90 87 10 80       	push   $0x80108790
80100209:	e8 58 03 00 00       	call   80100566 <panic>
  b->flags |= B_DIRTY;
8010020e:	8b 45 08             	mov    0x8(%ebp),%eax
80100211:	8b 00                	mov    (%eax),%eax
80100213:	83 c8 04             	or     $0x4,%eax
80100216:	89 c2                	mov    %eax,%edx
80100218:	8b 45 08             	mov    0x8(%ebp),%eax
8010021b:	89 10                	mov    %edx,(%eax)
  iderw(b);
8010021d:	83 ec 0c             	sub    $0xc,%esp
80100220:	ff 75 08             	pushl  0x8(%ebp)
80100223:	e8 ca 26 00 00       	call   801028f2 <iderw>
80100228:	83 c4 10             	add    $0x10,%esp
}
8010022b:	90                   	nop
8010022c:	c9                   	leave  
8010022d:	c3                   	ret    

8010022e <brelse>:

// Release a B_BUSY buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
8010022e:	55                   	push   %ebp
8010022f:	89 e5                	mov    %esp,%ebp
80100231:	83 ec 08             	sub    $0x8,%esp
  if((b->flags & B_BUSY) == 0)
80100234:	8b 45 08             	mov    0x8(%ebp),%eax
80100237:	8b 00                	mov    (%eax),%eax
80100239:	83 e0 01             	and    $0x1,%eax
8010023c:	85 c0                	test   %eax,%eax
8010023e:	75 0d                	jne    8010024d <brelse+0x1f>
    panic("brelse");
80100240:	83 ec 0c             	sub    $0xc,%esp
80100243:	68 97 87 10 80       	push   $0x80108797
80100248:	e8 19 03 00 00       	call   80100566 <panic>

  acquire(&bcache.lock);
8010024d:	83 ec 0c             	sub    $0xc,%esp
80100250:	68 60 c6 10 80       	push   $0x8010c660
80100255:	e8 4d 4f 00 00       	call   801051a7 <acquire>
8010025a:	83 c4 10             	add    $0x10,%esp

  b->next->prev = b->prev;
8010025d:	8b 45 08             	mov    0x8(%ebp),%eax
80100260:	8b 40 10             	mov    0x10(%eax),%eax
80100263:	8b 55 08             	mov    0x8(%ebp),%edx
80100266:	8b 52 0c             	mov    0xc(%edx),%edx
80100269:	89 50 0c             	mov    %edx,0xc(%eax)
  b->prev->next = b->next;
8010026c:	8b 45 08             	mov    0x8(%ebp),%eax
8010026f:	8b 40 0c             	mov    0xc(%eax),%eax
80100272:	8b 55 08             	mov    0x8(%ebp),%edx
80100275:	8b 52 10             	mov    0x10(%edx),%edx
80100278:	89 50 10             	mov    %edx,0x10(%eax)
  b->next = bcache.head.next;
8010027b:	8b 15 74 05 11 80    	mov    0x80110574,%edx
80100281:	8b 45 08             	mov    0x8(%ebp),%eax
80100284:	89 50 10             	mov    %edx,0x10(%eax)
  b->prev = &bcache.head;
80100287:	8b 45 08             	mov    0x8(%ebp),%eax
8010028a:	c7 40 0c 64 05 11 80 	movl   $0x80110564,0xc(%eax)
  bcache.head.next->prev = b;
80100291:	a1 74 05 11 80       	mov    0x80110574,%eax
80100296:	8b 55 08             	mov    0x8(%ebp),%edx
80100299:	89 50 0c             	mov    %edx,0xc(%eax)
  bcache.head.next = b;
8010029c:	8b 45 08             	mov    0x8(%ebp),%eax
8010029f:	a3 74 05 11 80       	mov    %eax,0x80110574

  b->flags &= ~B_BUSY;
801002a4:	8b 45 08             	mov    0x8(%ebp),%eax
801002a7:	8b 00                	mov    (%eax),%eax
801002a9:	83 e0 fe             	and    $0xfffffffe,%eax
801002ac:	89 c2                	mov    %eax,%edx
801002ae:	8b 45 08             	mov    0x8(%ebp),%eax
801002b1:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801002b3:	83 ec 0c             	sub    $0xc,%esp
801002b6:	ff 75 08             	pushl  0x8(%ebp)
801002b9:	e8 d5 4c 00 00       	call   80104f93 <wakeup>
801002be:	83 c4 10             	add    $0x10,%esp

  release(&bcache.lock);
801002c1:	83 ec 0c             	sub    $0xc,%esp
801002c4:	68 60 c6 10 80       	push   $0x8010c660
801002c9:	e8 40 4f 00 00       	call   8010520e <release>
801002ce:	83 c4 10             	add    $0x10,%esp
}
801002d1:	90                   	nop
801002d2:	c9                   	leave  
801002d3:	c3                   	ret    

801002d4 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
801002d4:	55                   	push   %ebp
801002d5:	89 e5                	mov    %esp,%ebp
801002d7:	83 ec 14             	sub    $0x14,%esp
801002da:	8b 45 08             	mov    0x8(%ebp),%eax
801002dd:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801002e1:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
801002e5:	89 c2                	mov    %eax,%edx
801002e7:	ec                   	in     (%dx),%al
801002e8:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
801002eb:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
801002ef:	c9                   	leave  
801002f0:	c3                   	ret    

801002f1 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801002f1:	55                   	push   %ebp
801002f2:	89 e5                	mov    %esp,%ebp
801002f4:	83 ec 08             	sub    $0x8,%esp
801002f7:	8b 55 08             	mov    0x8(%ebp),%edx
801002fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801002fd:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80100301:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100304:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80100308:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
8010030c:	ee                   	out    %al,(%dx)
}
8010030d:	90                   	nop
8010030e:	c9                   	leave  
8010030f:	c3                   	ret    

80100310 <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
80100310:	55                   	push   %ebp
80100311:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80100313:	fa                   	cli    
}
80100314:	90                   	nop
80100315:	5d                   	pop    %ebp
80100316:	c3                   	ret    

80100317 <printint>:
  int locking;
} cons;

static void
printint(int xx, int base, int sign)
{
80100317:	55                   	push   %ebp
80100318:	89 e5                	mov    %esp,%ebp
8010031a:	53                   	push   %ebx
8010031b:	83 ec 24             	sub    $0x24,%esp
  static char digits[] = "0123456789abcdef";
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
8010031e:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100322:	74 1c                	je     80100340 <printint+0x29>
80100324:	8b 45 08             	mov    0x8(%ebp),%eax
80100327:	c1 e8 1f             	shr    $0x1f,%eax
8010032a:	0f b6 c0             	movzbl %al,%eax
8010032d:	89 45 10             	mov    %eax,0x10(%ebp)
80100330:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100334:	74 0a                	je     80100340 <printint+0x29>
    x = -xx;
80100336:	8b 45 08             	mov    0x8(%ebp),%eax
80100339:	f7 d8                	neg    %eax
8010033b:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010033e:	eb 06                	jmp    80100346 <printint+0x2f>
  else
    x = xx;
80100340:	8b 45 08             	mov    0x8(%ebp),%eax
80100343:	89 45 f0             	mov    %eax,-0x10(%ebp)

  i = 0;
80100346:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  do{
    buf[i++] = digits[x % base];
8010034d:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100350:	8d 41 01             	lea    0x1(%ecx),%eax
80100353:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100356:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100359:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010035c:	ba 00 00 00 00       	mov    $0x0,%edx
80100361:	f7 f3                	div    %ebx
80100363:	89 d0                	mov    %edx,%eax
80100365:	0f b6 80 04 90 10 80 	movzbl -0x7fef6ffc(%eax),%eax
8010036c:	88 44 0d e0          	mov    %al,-0x20(%ebp,%ecx,1)
  }while((x /= base) != 0);
80100370:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80100373:	8b 45 f0             	mov    -0x10(%ebp),%eax
80100376:	ba 00 00 00 00       	mov    $0x0,%edx
8010037b:	f7 f3                	div    %ebx
8010037d:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100380:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80100384:	75 c7                	jne    8010034d <printint+0x36>

  if(sign)
80100386:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010038a:	74 2a                	je     801003b6 <printint+0x9f>
    buf[i++] = '-';
8010038c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010038f:	8d 50 01             	lea    0x1(%eax),%edx
80100392:	89 55 f4             	mov    %edx,-0xc(%ebp)
80100395:	c6 44 05 e0 2d       	movb   $0x2d,-0x20(%ebp,%eax,1)

  while(--i >= 0)
8010039a:	eb 1a                	jmp    801003b6 <printint+0x9f>
    consputc(buf[i]);
8010039c:	8d 55 e0             	lea    -0x20(%ebp),%edx
8010039f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801003a2:	01 d0                	add    %edx,%eax
801003a4:	0f b6 00             	movzbl (%eax),%eax
801003a7:	0f be c0             	movsbl %al,%eax
801003aa:	83 ec 0c             	sub    $0xc,%esp
801003ad:	50                   	push   %eax
801003ae:	e8 c3 03 00 00       	call   80100776 <consputc>
801003b3:	83 c4 10             	add    $0x10,%esp
  }while((x /= base) != 0);

  if(sign)
    buf[i++] = '-';

  while(--i >= 0)
801003b6:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
801003ba:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801003be:	79 dc                	jns    8010039c <printint+0x85>
    consputc(buf[i]);
}
801003c0:	90                   	nop
801003c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801003c4:	c9                   	leave  
801003c5:	c3                   	ret    

801003c6 <cprintf>:
//PAGEBREAK: 50

// Print to the console. only understands %d, %x, %p, %s.
void
cprintf(char *fmt, ...)
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	83 ec 28             	sub    $0x28,%esp
  int i, c, locking;
  uint *argp;
  char *s;

  locking = cons.locking;
801003cc:	a1 f4 b5 10 80       	mov    0x8010b5f4,%eax
801003d1:	89 45 e8             	mov    %eax,-0x18(%ebp)
  if(locking)
801003d4:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801003d8:	74 10                	je     801003ea <cprintf+0x24>
    acquire(&cons.lock);
801003da:	83 ec 0c             	sub    $0xc,%esp
801003dd:	68 c0 b5 10 80       	push   $0x8010b5c0
801003e2:	e8 c0 4d 00 00       	call   801051a7 <acquire>
801003e7:	83 c4 10             	add    $0x10,%esp

  if (fmt == 0)
801003ea:	8b 45 08             	mov    0x8(%ebp),%eax
801003ed:	85 c0                	test   %eax,%eax
801003ef:	75 0d                	jne    801003fe <cprintf+0x38>
    panic("null fmt");
801003f1:	83 ec 0c             	sub    $0xc,%esp
801003f4:	68 9e 87 10 80       	push   $0x8010879e
801003f9:	e8 68 01 00 00       	call   80100566 <panic>

  argp = (uint*)(void*)(&fmt + 1);
801003fe:	8d 45 0c             	lea    0xc(%ebp),%eax
80100401:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100404:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010040b:	e9 1a 01 00 00       	jmp    8010052a <cprintf+0x164>
    if(c != '%'){
80100410:	83 7d e4 25          	cmpl   $0x25,-0x1c(%ebp)
80100414:	74 13                	je     80100429 <cprintf+0x63>
      consputc(c);
80100416:	83 ec 0c             	sub    $0xc,%esp
80100419:	ff 75 e4             	pushl  -0x1c(%ebp)
8010041c:	e8 55 03 00 00       	call   80100776 <consputc>
80100421:	83 c4 10             	add    $0x10,%esp
      continue;
80100424:	e9 fd 00 00 00       	jmp    80100526 <cprintf+0x160>
    }
    c = fmt[++i] & 0xff;
80100429:	8b 55 08             	mov    0x8(%ebp),%edx
8010042c:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100430:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100433:	01 d0                	add    %edx,%eax
80100435:	0f b6 00             	movzbl (%eax),%eax
80100438:	0f be c0             	movsbl %al,%eax
8010043b:	25 ff 00 00 00       	and    $0xff,%eax
80100440:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if(c == 0)
80100443:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100447:	0f 84 ff 00 00 00    	je     8010054c <cprintf+0x186>
      break;
    switch(c){
8010044d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100450:	83 f8 70             	cmp    $0x70,%eax
80100453:	74 47                	je     8010049c <cprintf+0xd6>
80100455:	83 f8 70             	cmp    $0x70,%eax
80100458:	7f 13                	jg     8010046d <cprintf+0xa7>
8010045a:	83 f8 25             	cmp    $0x25,%eax
8010045d:	0f 84 98 00 00 00    	je     801004fb <cprintf+0x135>
80100463:	83 f8 64             	cmp    $0x64,%eax
80100466:	74 14                	je     8010047c <cprintf+0xb6>
80100468:	e9 9d 00 00 00       	jmp    8010050a <cprintf+0x144>
8010046d:	83 f8 73             	cmp    $0x73,%eax
80100470:	74 47                	je     801004b9 <cprintf+0xf3>
80100472:	83 f8 78             	cmp    $0x78,%eax
80100475:	74 25                	je     8010049c <cprintf+0xd6>
80100477:	e9 8e 00 00 00       	jmp    8010050a <cprintf+0x144>
    case 'd':
      printint(*argp++, 10, 1);
8010047c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010047f:	8d 50 04             	lea    0x4(%eax),%edx
80100482:	89 55 f0             	mov    %edx,-0x10(%ebp)
80100485:	8b 00                	mov    (%eax),%eax
80100487:	83 ec 04             	sub    $0x4,%esp
8010048a:	6a 01                	push   $0x1
8010048c:	6a 0a                	push   $0xa
8010048e:	50                   	push   %eax
8010048f:	e8 83 fe ff ff       	call   80100317 <printint>
80100494:	83 c4 10             	add    $0x10,%esp
      break;
80100497:	e9 8a 00 00 00       	jmp    80100526 <cprintf+0x160>
    case 'x':
    case 'p':
      printint(*argp++, 16, 0);
8010049c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010049f:	8d 50 04             	lea    0x4(%eax),%edx
801004a2:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004a5:	8b 00                	mov    (%eax),%eax
801004a7:	83 ec 04             	sub    $0x4,%esp
801004aa:	6a 00                	push   $0x0
801004ac:	6a 10                	push   $0x10
801004ae:	50                   	push   %eax
801004af:	e8 63 fe ff ff       	call   80100317 <printint>
801004b4:	83 c4 10             	add    $0x10,%esp
      break;
801004b7:	eb 6d                	jmp    80100526 <cprintf+0x160>
    case 's':
      if((s = (char*)*argp++) == 0)
801004b9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801004bc:	8d 50 04             	lea    0x4(%eax),%edx
801004bf:	89 55 f0             	mov    %edx,-0x10(%ebp)
801004c2:	8b 00                	mov    (%eax),%eax
801004c4:	89 45 ec             	mov    %eax,-0x14(%ebp)
801004c7:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801004cb:	75 22                	jne    801004ef <cprintf+0x129>
        s = "(null)";
801004cd:	c7 45 ec a7 87 10 80 	movl   $0x801087a7,-0x14(%ebp)
      for(; *s; s++)
801004d4:	eb 19                	jmp    801004ef <cprintf+0x129>
        consputc(*s);
801004d6:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004d9:	0f b6 00             	movzbl (%eax),%eax
801004dc:	0f be c0             	movsbl %al,%eax
801004df:	83 ec 0c             	sub    $0xc,%esp
801004e2:	50                   	push   %eax
801004e3:	e8 8e 02 00 00       	call   80100776 <consputc>
801004e8:	83 c4 10             	add    $0x10,%esp
      printint(*argp++, 16, 0);
      break;
    case 's':
      if((s = (char*)*argp++) == 0)
        s = "(null)";
      for(; *s; s++)
801004eb:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
801004ef:	8b 45 ec             	mov    -0x14(%ebp),%eax
801004f2:	0f b6 00             	movzbl (%eax),%eax
801004f5:	84 c0                	test   %al,%al
801004f7:	75 dd                	jne    801004d6 <cprintf+0x110>
        consputc(*s);
      break;
801004f9:	eb 2b                	jmp    80100526 <cprintf+0x160>
    case '%':
      consputc('%');
801004fb:	83 ec 0c             	sub    $0xc,%esp
801004fe:	6a 25                	push   $0x25
80100500:	e8 71 02 00 00       	call   80100776 <consputc>
80100505:	83 c4 10             	add    $0x10,%esp
      break;
80100508:	eb 1c                	jmp    80100526 <cprintf+0x160>
    default:
      // Print unknown % sequence to draw attention.
      consputc('%');
8010050a:	83 ec 0c             	sub    $0xc,%esp
8010050d:	6a 25                	push   $0x25
8010050f:	e8 62 02 00 00       	call   80100776 <consputc>
80100514:	83 c4 10             	add    $0x10,%esp
      consputc(c);
80100517:	83 ec 0c             	sub    $0xc,%esp
8010051a:	ff 75 e4             	pushl  -0x1c(%ebp)
8010051d:	e8 54 02 00 00       	call   80100776 <consputc>
80100522:	83 c4 10             	add    $0x10,%esp
      break;
80100525:	90                   	nop

  if (fmt == 0)
    panic("null fmt");

  argp = (uint*)(void*)(&fmt + 1);
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100526:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010052a:	8b 55 08             	mov    0x8(%ebp),%edx
8010052d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100530:	01 d0                	add    %edx,%eax
80100532:	0f b6 00             	movzbl (%eax),%eax
80100535:	0f be c0             	movsbl %al,%eax
80100538:	25 ff 00 00 00       	and    $0xff,%eax
8010053d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80100540:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100544:	0f 85 c6 fe ff ff    	jne    80100410 <cprintf+0x4a>
8010054a:	eb 01                	jmp    8010054d <cprintf+0x187>
      consputc(c);
      continue;
    }
    c = fmt[++i] & 0xff;
    if(c == 0)
      break;
8010054c:	90                   	nop
      consputc(c);
      break;
    }
  }

  if(locking)
8010054d:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80100551:	74 10                	je     80100563 <cprintf+0x19d>
    release(&cons.lock);
80100553:	83 ec 0c             	sub    $0xc,%esp
80100556:	68 c0 b5 10 80       	push   $0x8010b5c0
8010055b:	e8 ae 4c 00 00       	call   8010520e <release>
80100560:	83 c4 10             	add    $0x10,%esp
}
80100563:	90                   	nop
80100564:	c9                   	leave  
80100565:	c3                   	ret    

80100566 <panic>:

void
panic(char *s)
{
80100566:	55                   	push   %ebp
80100567:	89 e5                	mov    %esp,%ebp
80100569:	83 ec 38             	sub    $0x38,%esp
  int i;
  uint pcs[10];
  
  cli();
8010056c:	e8 9f fd ff ff       	call   80100310 <cli>
  cons.locking = 0;
80100571:	c7 05 f4 b5 10 80 00 	movl   $0x0,0x8010b5f4
80100578:	00 00 00 
  cprintf("cpu%d: panic: ", cpu->id);
8010057b:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80100581:	0f b6 00             	movzbl (%eax),%eax
80100584:	0f b6 c0             	movzbl %al,%eax
80100587:	83 ec 08             	sub    $0x8,%esp
8010058a:	50                   	push   %eax
8010058b:	68 ae 87 10 80       	push   $0x801087ae
80100590:	e8 31 fe ff ff       	call   801003c6 <cprintf>
80100595:	83 c4 10             	add    $0x10,%esp
  cprintf(s);
80100598:	8b 45 08             	mov    0x8(%ebp),%eax
8010059b:	83 ec 0c             	sub    $0xc,%esp
8010059e:	50                   	push   %eax
8010059f:	e8 22 fe ff ff       	call   801003c6 <cprintf>
801005a4:	83 c4 10             	add    $0x10,%esp
  cprintf("\n");
801005a7:	83 ec 0c             	sub    $0xc,%esp
801005aa:	68 bd 87 10 80       	push   $0x801087bd
801005af:	e8 12 fe ff ff       	call   801003c6 <cprintf>
801005b4:	83 c4 10             	add    $0x10,%esp
  getcallerpcs(&s, pcs);
801005b7:	83 ec 08             	sub    $0x8,%esp
801005ba:	8d 45 cc             	lea    -0x34(%ebp),%eax
801005bd:	50                   	push   %eax
801005be:	8d 45 08             	lea    0x8(%ebp),%eax
801005c1:	50                   	push   %eax
801005c2:	e8 99 4c 00 00       	call   80105260 <getcallerpcs>
801005c7:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<10; i++)
801005ca:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801005d1:	eb 1c                	jmp    801005ef <panic+0x89>
    cprintf(" %p", pcs[i]);
801005d3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801005d6:	8b 44 85 cc          	mov    -0x34(%ebp,%eax,4),%eax
801005da:	83 ec 08             	sub    $0x8,%esp
801005dd:	50                   	push   %eax
801005de:	68 bf 87 10 80       	push   $0x801087bf
801005e3:	e8 de fd ff ff       	call   801003c6 <cprintf>
801005e8:	83 c4 10             	add    $0x10,%esp
  cons.locking = 0;
  cprintf("cpu%d: panic: ", cpu->id);
  cprintf(s);
  cprintf("\n");
  getcallerpcs(&s, pcs);
  for(i=0; i<10; i++)
801005eb:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801005ef:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
801005f3:	7e de                	jle    801005d3 <panic+0x6d>
    cprintf(" %p", pcs[i]);
  panicked = 1; // freeze other CPU
801005f5:	c7 05 a0 b5 10 80 01 	movl   $0x1,0x8010b5a0
801005fc:	00 00 00 
  for(;;)
    ;
801005ff:	eb fe                	jmp    801005ff <panic+0x99>

80100601 <cgaputc>:
#define CRTPORT 0x3d4
static ushort *crt = (ushort*)P2V(0xb8000);  // CGA memory

static void
cgaputc(int c)
{
80100601:	55                   	push   %ebp
80100602:	89 e5                	mov    %esp,%ebp
80100604:	83 ec 18             	sub    $0x18,%esp
  int pos;
  
  // Cursor position: col + 80*row.
  outb(CRTPORT, 14);
80100607:	6a 0e                	push   $0xe
80100609:	68 d4 03 00 00       	push   $0x3d4
8010060e:	e8 de fc ff ff       	call   801002f1 <outb>
80100613:	83 c4 08             	add    $0x8,%esp
  pos = inb(CRTPORT+1) << 8;
80100616:	68 d5 03 00 00       	push   $0x3d5
8010061b:	e8 b4 fc ff ff       	call   801002d4 <inb>
80100620:	83 c4 04             	add    $0x4,%esp
80100623:	0f b6 c0             	movzbl %al,%eax
80100626:	c1 e0 08             	shl    $0x8,%eax
80100629:	89 45 f4             	mov    %eax,-0xc(%ebp)
  outb(CRTPORT, 15);
8010062c:	6a 0f                	push   $0xf
8010062e:	68 d4 03 00 00       	push   $0x3d4
80100633:	e8 b9 fc ff ff       	call   801002f1 <outb>
80100638:	83 c4 08             	add    $0x8,%esp
  pos |= inb(CRTPORT+1);
8010063b:	68 d5 03 00 00       	push   $0x3d5
80100640:	e8 8f fc ff ff       	call   801002d4 <inb>
80100645:	83 c4 04             	add    $0x4,%esp
80100648:	0f b6 c0             	movzbl %al,%eax
8010064b:	09 45 f4             	or     %eax,-0xc(%ebp)

  if(c == '\n')
8010064e:	83 7d 08 0a          	cmpl   $0xa,0x8(%ebp)
80100652:	75 30                	jne    80100684 <cgaputc+0x83>
    pos += 80 - pos%80;
80100654:	8b 4d f4             	mov    -0xc(%ebp),%ecx
80100657:	ba 67 66 66 66       	mov    $0x66666667,%edx
8010065c:	89 c8                	mov    %ecx,%eax
8010065e:	f7 ea                	imul   %edx
80100660:	c1 fa 05             	sar    $0x5,%edx
80100663:	89 c8                	mov    %ecx,%eax
80100665:	c1 f8 1f             	sar    $0x1f,%eax
80100668:	29 c2                	sub    %eax,%edx
8010066a:	89 d0                	mov    %edx,%eax
8010066c:	c1 e0 02             	shl    $0x2,%eax
8010066f:	01 d0                	add    %edx,%eax
80100671:	c1 e0 04             	shl    $0x4,%eax
80100674:	29 c1                	sub    %eax,%ecx
80100676:	89 ca                	mov    %ecx,%edx
80100678:	b8 50 00 00 00       	mov    $0x50,%eax
8010067d:	29 d0                	sub    %edx,%eax
8010067f:	01 45 f4             	add    %eax,-0xc(%ebp)
80100682:	eb 34                	jmp    801006b8 <cgaputc+0xb7>
  else if(c == BACKSPACE){
80100684:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
8010068b:	75 0c                	jne    80100699 <cgaputc+0x98>
    if(pos > 0) --pos;
8010068d:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100691:	7e 25                	jle    801006b8 <cgaputc+0xb7>
80100693:	83 6d f4 01          	subl   $0x1,-0xc(%ebp)
80100697:	eb 1f                	jmp    801006b8 <cgaputc+0xb7>
  } else
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
80100699:	8b 0d 00 90 10 80    	mov    0x80109000,%ecx
8010069f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801006a2:	8d 50 01             	lea    0x1(%eax),%edx
801006a5:	89 55 f4             	mov    %edx,-0xc(%ebp)
801006a8:	01 c0                	add    %eax,%eax
801006aa:	01 c8                	add    %ecx,%eax
801006ac:	8b 55 08             	mov    0x8(%ebp),%edx
801006af:	0f b6 d2             	movzbl %dl,%edx
801006b2:	80 ce 07             	or     $0x7,%dh
801006b5:	66 89 10             	mov    %dx,(%eax)
  
  if((pos/80) >= 24){  // Scroll up.
801006b8:	81 7d f4 7f 07 00 00 	cmpl   $0x77f,-0xc(%ebp)
801006bf:	7e 4c                	jle    8010070d <cgaputc+0x10c>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801006c1:	a1 00 90 10 80       	mov    0x80109000,%eax
801006c6:	8d 90 a0 00 00 00    	lea    0xa0(%eax),%edx
801006cc:	a1 00 90 10 80       	mov    0x80109000,%eax
801006d1:	83 ec 04             	sub    $0x4,%esp
801006d4:	68 60 0e 00 00       	push   $0xe60
801006d9:	52                   	push   %edx
801006da:	50                   	push   %eax
801006db:	e8 e9 4d 00 00       	call   801054c9 <memmove>
801006e0:	83 c4 10             	add    $0x10,%esp
    pos -= 80;
801006e3:	83 6d f4 50          	subl   $0x50,-0xc(%ebp)
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801006e7:	b8 80 07 00 00       	mov    $0x780,%eax
801006ec:	2b 45 f4             	sub    -0xc(%ebp),%eax
801006ef:	8d 14 00             	lea    (%eax,%eax,1),%edx
801006f2:	a1 00 90 10 80       	mov    0x80109000,%eax
801006f7:	8b 4d f4             	mov    -0xc(%ebp),%ecx
801006fa:	01 c9                	add    %ecx,%ecx
801006fc:	01 c8                	add    %ecx,%eax
801006fe:	83 ec 04             	sub    $0x4,%esp
80100701:	52                   	push   %edx
80100702:	6a 00                	push   $0x0
80100704:	50                   	push   %eax
80100705:	e8 00 4d 00 00       	call   8010540a <memset>
8010070a:	83 c4 10             	add    $0x10,%esp
  }
  
  outb(CRTPORT, 14);
8010070d:	83 ec 08             	sub    $0x8,%esp
80100710:	6a 0e                	push   $0xe
80100712:	68 d4 03 00 00       	push   $0x3d4
80100717:	e8 d5 fb ff ff       	call   801002f1 <outb>
8010071c:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos>>8);
8010071f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100722:	c1 f8 08             	sar    $0x8,%eax
80100725:	0f b6 c0             	movzbl %al,%eax
80100728:	83 ec 08             	sub    $0x8,%esp
8010072b:	50                   	push   %eax
8010072c:	68 d5 03 00 00       	push   $0x3d5
80100731:	e8 bb fb ff ff       	call   801002f1 <outb>
80100736:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT, 15);
80100739:	83 ec 08             	sub    $0x8,%esp
8010073c:	6a 0f                	push   $0xf
8010073e:	68 d4 03 00 00       	push   $0x3d4
80100743:	e8 a9 fb ff ff       	call   801002f1 <outb>
80100748:	83 c4 10             	add    $0x10,%esp
  outb(CRTPORT+1, pos);
8010074b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010074e:	0f b6 c0             	movzbl %al,%eax
80100751:	83 ec 08             	sub    $0x8,%esp
80100754:	50                   	push   %eax
80100755:	68 d5 03 00 00       	push   $0x3d5
8010075a:	e8 92 fb ff ff       	call   801002f1 <outb>
8010075f:	83 c4 10             	add    $0x10,%esp
  crt[pos] = ' ' | 0x0700;
80100762:	a1 00 90 10 80       	mov    0x80109000,%eax
80100767:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010076a:	01 d2                	add    %edx,%edx
8010076c:	01 d0                	add    %edx,%eax
8010076e:	66 c7 00 20 07       	movw   $0x720,(%eax)
}
80100773:	90                   	nop
80100774:	c9                   	leave  
80100775:	c3                   	ret    

80100776 <consputc>:

void
consputc(int c)
{
80100776:	55                   	push   %ebp
80100777:	89 e5                	mov    %esp,%ebp
80100779:	83 ec 08             	sub    $0x8,%esp
  if(panicked){
8010077c:	a1 a0 b5 10 80       	mov    0x8010b5a0,%eax
80100781:	85 c0                	test   %eax,%eax
80100783:	74 07                	je     8010078c <consputc+0x16>
    cli();
80100785:	e8 86 fb ff ff       	call   80100310 <cli>
    for(;;)
      ;
8010078a:	eb fe                	jmp    8010078a <consputc+0x14>
  }

  if(c == BACKSPACE){
8010078c:	81 7d 08 00 01 00 00 	cmpl   $0x100,0x8(%ebp)
80100793:	75 29                	jne    801007be <consputc+0x48>
    uartputc('\b'); uartputc(' '); uartputc('\b');
80100795:	83 ec 0c             	sub    $0xc,%esp
80100798:	6a 08                	push   $0x8
8010079a:	e8 62 66 00 00       	call   80106e01 <uartputc>
8010079f:	83 c4 10             	add    $0x10,%esp
801007a2:	83 ec 0c             	sub    $0xc,%esp
801007a5:	6a 20                	push   $0x20
801007a7:	e8 55 66 00 00       	call   80106e01 <uartputc>
801007ac:	83 c4 10             	add    $0x10,%esp
801007af:	83 ec 0c             	sub    $0xc,%esp
801007b2:	6a 08                	push   $0x8
801007b4:	e8 48 66 00 00       	call   80106e01 <uartputc>
801007b9:	83 c4 10             	add    $0x10,%esp
801007bc:	eb 0e                	jmp    801007cc <consputc+0x56>
  } else
    uartputc(c);
801007be:	83 ec 0c             	sub    $0xc,%esp
801007c1:	ff 75 08             	pushl  0x8(%ebp)
801007c4:	e8 38 66 00 00       	call   80106e01 <uartputc>
801007c9:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
801007cc:	83 ec 0c             	sub    $0xc,%esp
801007cf:	ff 75 08             	pushl  0x8(%ebp)
801007d2:	e8 2a fe ff ff       	call   80100601 <cgaputc>
801007d7:	83 c4 10             	add    $0x10,%esp
}
801007da:	90                   	nop
801007db:	c9                   	leave  
801007dc:	c3                   	ret    

801007dd <consoleintr>:

#define C(x)  ((x)-'@')  // Control-x

void
consoleintr(int (*getc)(void))
{
801007dd:	55                   	push   %ebp
801007de:	89 e5                	mov    %esp,%ebp
801007e0:	83 ec 18             	sub    $0x18,%esp
  int c;

  acquire(&input.lock);
801007e3:	83 ec 0c             	sub    $0xc,%esp
801007e6:	68 80 07 11 80       	push   $0x80110780
801007eb:	e8 b7 49 00 00       	call   801051a7 <acquire>
801007f0:	83 c4 10             	add    $0x10,%esp
  while((c = getc()) >= 0){
801007f3:	e9 42 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    switch(c){
801007f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801007fb:	83 f8 10             	cmp    $0x10,%eax
801007fe:	74 1e                	je     8010081e <consoleintr+0x41>
80100800:	83 f8 10             	cmp    $0x10,%eax
80100803:	7f 0a                	jg     8010080f <consoleintr+0x32>
80100805:	83 f8 08             	cmp    $0x8,%eax
80100808:	74 69                	je     80100873 <consoleintr+0x96>
8010080a:	e9 99 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
8010080f:	83 f8 15             	cmp    $0x15,%eax
80100812:	74 31                	je     80100845 <consoleintr+0x68>
80100814:	83 f8 7f             	cmp    $0x7f,%eax
80100817:	74 5a                	je     80100873 <consoleintr+0x96>
80100819:	e9 8a 00 00 00       	jmp    801008a8 <consoleintr+0xcb>
    case C('P'):  // Process listing.
      procdump();
8010081e:	e8 2e 48 00 00       	call   80105051 <procdump>
      break;
80100823:	e9 12 01 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('U'):  // Kill line.
      while(input.e != input.w &&
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
80100828:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010082d:	83 e8 01             	sub    $0x1,%eax
80100830:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100835:	83 ec 0c             	sub    $0xc,%esp
80100838:	68 00 01 00 00       	push   $0x100
8010083d:	e8 34 ff ff ff       	call   80100776 <consputc>
80100842:	83 c4 10             	add    $0x10,%esp
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
80100845:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
8010084b:	a1 38 08 11 80       	mov    0x80110838,%eax
80100850:	39 c2                	cmp    %eax,%edx
80100852:	0f 84 e2 00 00 00    	je     8010093a <consoleintr+0x15d>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100858:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010085d:	83 e8 01             	sub    $0x1,%eax
80100860:	83 e0 7f             	and    $0x7f,%eax
80100863:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
    switch(c){
    case C('P'):  // Process listing.
      procdump();
      break;
    case C('U'):  // Kill line.
      while(input.e != input.w &&
8010086a:	3c 0a                	cmp    $0xa,%al
8010086c:	75 ba                	jne    80100828 <consoleintr+0x4b>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
        input.e--;
        consputc(BACKSPACE);
      }
      break;
8010086e:	e9 c7 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    case C('H'): case '\x7f':  // Backspace
      if(input.e != input.w){
80100873:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
80100879:	a1 38 08 11 80       	mov    0x80110838,%eax
8010087e:	39 c2                	cmp    %eax,%edx
80100880:	0f 84 b4 00 00 00    	je     8010093a <consoleintr+0x15d>
        input.e--;
80100886:	a1 3c 08 11 80       	mov    0x8011083c,%eax
8010088b:	83 e8 01             	sub    $0x1,%eax
8010088e:	a3 3c 08 11 80       	mov    %eax,0x8011083c
        consputc(BACKSPACE);
80100893:	83 ec 0c             	sub    $0xc,%esp
80100896:	68 00 01 00 00       	push   $0x100
8010089b:	e8 d6 fe ff ff       	call   80100776 <consputc>
801008a0:	83 c4 10             	add    $0x10,%esp
      }
      break;
801008a3:	e9 92 00 00 00       	jmp    8010093a <consoleintr+0x15d>
    default:
      if(c != 0 && input.e-input.r < INPUT_BUF){
801008a8:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801008ac:	0f 84 87 00 00 00    	je     80100939 <consoleintr+0x15c>
801008b2:	8b 15 3c 08 11 80    	mov    0x8011083c,%edx
801008b8:	a1 34 08 11 80       	mov    0x80110834,%eax
801008bd:	29 c2                	sub    %eax,%edx
801008bf:	89 d0                	mov    %edx,%eax
801008c1:	83 f8 7f             	cmp    $0x7f,%eax
801008c4:	77 73                	ja     80100939 <consoleintr+0x15c>
        c = (c == '\r') ? '\n' : c;
801008c6:	83 7d f4 0d          	cmpl   $0xd,-0xc(%ebp)
801008ca:	74 05                	je     801008d1 <consoleintr+0xf4>
801008cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801008cf:	eb 05                	jmp    801008d6 <consoleintr+0xf9>
801008d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801008d6:	89 45 f4             	mov    %eax,-0xc(%ebp)
        input.buf[input.e++ % INPUT_BUF] = c;
801008d9:	a1 3c 08 11 80       	mov    0x8011083c,%eax
801008de:	8d 50 01             	lea    0x1(%eax),%edx
801008e1:	89 15 3c 08 11 80    	mov    %edx,0x8011083c
801008e7:	83 e0 7f             	and    $0x7f,%eax
801008ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801008ed:	88 90 b4 07 11 80    	mov    %dl,-0x7feef84c(%eax)
        consputc(c);
801008f3:	83 ec 0c             	sub    $0xc,%esp
801008f6:	ff 75 f4             	pushl  -0xc(%ebp)
801008f9:	e8 78 fe ff ff       	call   80100776 <consputc>
801008fe:	83 c4 10             	add    $0x10,%esp
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
80100901:	83 7d f4 0a          	cmpl   $0xa,-0xc(%ebp)
80100905:	74 18                	je     8010091f <consoleintr+0x142>
80100907:	83 7d f4 04          	cmpl   $0x4,-0xc(%ebp)
8010090b:	74 12                	je     8010091f <consoleintr+0x142>
8010090d:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100912:	8b 15 34 08 11 80    	mov    0x80110834,%edx
80100918:	83 ea 80             	sub    $0xffffff80,%edx
8010091b:	39 d0                	cmp    %edx,%eax
8010091d:	75 1a                	jne    80100939 <consoleintr+0x15c>
          input.w = input.e;
8010091f:	a1 3c 08 11 80       	mov    0x8011083c,%eax
80100924:	a3 38 08 11 80       	mov    %eax,0x80110838
          wakeup(&input.r);
80100929:	83 ec 0c             	sub    $0xc,%esp
8010092c:	68 34 08 11 80       	push   $0x80110834
80100931:	e8 5d 46 00 00       	call   80104f93 <wakeup>
80100936:	83 c4 10             	add    $0x10,%esp
        }
      }
      break;
80100939:	90                   	nop
consoleintr(int (*getc)(void))
{
  int c;

  acquire(&input.lock);
  while((c = getc()) >= 0){
8010093a:	8b 45 08             	mov    0x8(%ebp),%eax
8010093d:	ff d0                	call   *%eax
8010093f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100942:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80100946:	0f 89 ac fe ff ff    	jns    801007f8 <consoleintr+0x1b>
        }
      }
      break;
    }
  }
  release(&input.lock);
8010094c:	83 ec 0c             	sub    $0xc,%esp
8010094f:	68 80 07 11 80       	push   $0x80110780
80100954:	e8 b5 48 00 00       	call   8010520e <release>
80100959:	83 c4 10             	add    $0x10,%esp
}
8010095c:	90                   	nop
8010095d:	c9                   	leave  
8010095e:	c3                   	ret    

8010095f <consoleread>:

int
consoleread(struct inode *ip, char *dst, int n)
{
8010095f:	55                   	push   %ebp
80100960:	89 e5                	mov    %esp,%ebp
80100962:	83 ec 18             	sub    $0x18,%esp
  uint target;
  int c;

  iunlock(ip);
80100965:	83 ec 0c             	sub    $0xc,%esp
80100968:	ff 75 08             	pushl  0x8(%ebp)
8010096b:	e8 3d 11 00 00       	call   80101aad <iunlock>
80100970:	83 c4 10             	add    $0x10,%esp
  target = n;
80100973:	8b 45 10             	mov    0x10(%ebp),%eax
80100976:	89 45 f4             	mov    %eax,-0xc(%ebp)
  acquire(&input.lock);
80100979:	83 ec 0c             	sub    $0xc,%esp
8010097c:	68 80 07 11 80       	push   $0x80110780
80100981:	e8 21 48 00 00       	call   801051a7 <acquire>
80100986:	83 c4 10             	add    $0x10,%esp
  while(n > 0){
80100989:	e9 ac 00 00 00       	jmp    80100a3a <consoleread+0xdb>
    while(input.r == input.w){
      if(proc->killed){
8010098e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100994:	8b 40 24             	mov    0x24(%eax),%eax
80100997:	85 c0                	test   %eax,%eax
80100999:	74 28                	je     801009c3 <consoleread+0x64>
        release(&input.lock);
8010099b:	83 ec 0c             	sub    $0xc,%esp
8010099e:	68 80 07 11 80       	push   $0x80110780
801009a3:	e8 66 48 00 00       	call   8010520e <release>
801009a8:	83 c4 10             	add    $0x10,%esp
        ilock(ip);
801009ab:	83 ec 0c             	sub    $0xc,%esp
801009ae:	ff 75 08             	pushl  0x8(%ebp)
801009b1:	e8 99 0f 00 00       	call   8010194f <ilock>
801009b6:	83 c4 10             	add    $0x10,%esp
        return -1;
801009b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801009be:	e9 ab 00 00 00       	jmp    80100a6e <consoleread+0x10f>
      }
      sleep(&input.r, &input.lock);
801009c3:	83 ec 08             	sub    $0x8,%esp
801009c6:	68 80 07 11 80       	push   $0x80110780
801009cb:	68 34 08 11 80       	push   $0x80110834
801009d0:	e8 d0 44 00 00       	call   80104ea5 <sleep>
801009d5:	83 c4 10             	add    $0x10,%esp

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
    while(input.r == input.w){
801009d8:	8b 15 34 08 11 80    	mov    0x80110834,%edx
801009de:	a1 38 08 11 80       	mov    0x80110838,%eax
801009e3:	39 c2                	cmp    %eax,%edx
801009e5:	74 a7                	je     8010098e <consoleread+0x2f>
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &input.lock);
    }
    c = input.buf[input.r++ % INPUT_BUF];
801009e7:	a1 34 08 11 80       	mov    0x80110834,%eax
801009ec:	8d 50 01             	lea    0x1(%eax),%edx
801009ef:	89 15 34 08 11 80    	mov    %edx,0x80110834
801009f5:	83 e0 7f             	and    $0x7f,%eax
801009f8:	0f b6 80 b4 07 11 80 	movzbl -0x7feef84c(%eax),%eax
801009ff:	0f be c0             	movsbl %al,%eax
80100a02:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(c == C('D')){  // EOF
80100a05:	83 7d f0 04          	cmpl   $0x4,-0x10(%ebp)
80100a09:	75 17                	jne    80100a22 <consoleread+0xc3>
      if(n < target){
80100a0b:	8b 45 10             	mov    0x10(%ebp),%eax
80100a0e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80100a11:	73 2f                	jae    80100a42 <consoleread+0xe3>
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
80100a13:	a1 34 08 11 80       	mov    0x80110834,%eax
80100a18:	83 e8 01             	sub    $0x1,%eax
80100a1b:	a3 34 08 11 80       	mov    %eax,0x80110834
      }
      break;
80100a20:	eb 20                	jmp    80100a42 <consoleread+0xe3>
    }
    *dst++ = c;
80100a22:	8b 45 0c             	mov    0xc(%ebp),%eax
80100a25:	8d 50 01             	lea    0x1(%eax),%edx
80100a28:	89 55 0c             	mov    %edx,0xc(%ebp)
80100a2b:	8b 55 f0             	mov    -0x10(%ebp),%edx
80100a2e:	88 10                	mov    %dl,(%eax)
    --n;
80100a30:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
    if(c == '\n')
80100a34:	83 7d f0 0a          	cmpl   $0xa,-0x10(%ebp)
80100a38:	74 0b                	je     80100a45 <consoleread+0xe6>
  int c;

  iunlock(ip);
  target = n;
  acquire(&input.lock);
  while(n > 0){
80100a3a:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80100a3e:	7f 98                	jg     801009d8 <consoleread+0x79>
80100a40:	eb 04                	jmp    80100a46 <consoleread+0xe7>
      if(n < target){
        // Save ^D for next time, to make sure
        // caller gets a 0-byte result.
        input.r--;
      }
      break;
80100a42:	90                   	nop
80100a43:	eb 01                	jmp    80100a46 <consoleread+0xe7>
    }
    *dst++ = c;
    --n;
    if(c == '\n')
      break;
80100a45:	90                   	nop
  }
  release(&input.lock);
80100a46:	83 ec 0c             	sub    $0xc,%esp
80100a49:	68 80 07 11 80       	push   $0x80110780
80100a4e:	e8 bb 47 00 00       	call   8010520e <release>
80100a53:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100a56:	83 ec 0c             	sub    $0xc,%esp
80100a59:	ff 75 08             	pushl  0x8(%ebp)
80100a5c:	e8 ee 0e 00 00       	call   8010194f <ilock>
80100a61:	83 c4 10             	add    $0x10,%esp

  return target - n;
80100a64:	8b 45 10             	mov    0x10(%ebp),%eax
80100a67:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100a6a:	29 c2                	sub    %eax,%edx
80100a6c:	89 d0                	mov    %edx,%eax
}
80100a6e:	c9                   	leave  
80100a6f:	c3                   	ret    

80100a70 <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
80100a70:	55                   	push   %ebp
80100a71:	89 e5                	mov    %esp,%ebp
80100a73:	83 ec 18             	sub    $0x18,%esp
  int i;

  iunlock(ip);
80100a76:	83 ec 0c             	sub    $0xc,%esp
80100a79:	ff 75 08             	pushl  0x8(%ebp)
80100a7c:	e8 2c 10 00 00       	call   80101aad <iunlock>
80100a81:	83 c4 10             	add    $0x10,%esp
  acquire(&cons.lock);
80100a84:	83 ec 0c             	sub    $0xc,%esp
80100a87:	68 c0 b5 10 80       	push   $0x8010b5c0
80100a8c:	e8 16 47 00 00       	call   801051a7 <acquire>
80100a91:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++)
80100a94:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80100a9b:	eb 21                	jmp    80100abe <consolewrite+0x4e>
    consputc(buf[i] & 0xff);
80100a9d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80100aa0:	8b 45 0c             	mov    0xc(%ebp),%eax
80100aa3:	01 d0                	add    %edx,%eax
80100aa5:	0f b6 00             	movzbl (%eax),%eax
80100aa8:	0f be c0             	movsbl %al,%eax
80100aab:	0f b6 c0             	movzbl %al,%eax
80100aae:	83 ec 0c             	sub    $0xc,%esp
80100ab1:	50                   	push   %eax
80100ab2:	e8 bf fc ff ff       	call   80100776 <consputc>
80100ab7:	83 c4 10             	add    $0x10,%esp
{
  int i;

  iunlock(ip);
  acquire(&cons.lock);
  for(i = 0; i < n; i++)
80100aba:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100abe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100ac1:	3b 45 10             	cmp    0x10(%ebp),%eax
80100ac4:	7c d7                	jl     80100a9d <consolewrite+0x2d>
    consputc(buf[i] & 0xff);
  release(&cons.lock);
80100ac6:	83 ec 0c             	sub    $0xc,%esp
80100ac9:	68 c0 b5 10 80       	push   $0x8010b5c0
80100ace:	e8 3b 47 00 00       	call   8010520e <release>
80100ad3:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80100ad6:	83 ec 0c             	sub    $0xc,%esp
80100ad9:	ff 75 08             	pushl  0x8(%ebp)
80100adc:	e8 6e 0e 00 00       	call   8010194f <ilock>
80100ae1:	83 c4 10             	add    $0x10,%esp

  return n;
80100ae4:	8b 45 10             	mov    0x10(%ebp),%eax
}
80100ae7:	c9                   	leave  
80100ae8:	c3                   	ret    

80100ae9 <consoleinit>:

void
consoleinit(void)
{
80100ae9:	55                   	push   %ebp
80100aea:	89 e5                	mov    %esp,%ebp
80100aec:	83 ec 08             	sub    $0x8,%esp
  initlock(&cons.lock, "console");
80100aef:	83 ec 08             	sub    $0x8,%esp
80100af2:	68 c3 87 10 80       	push   $0x801087c3
80100af7:	68 c0 b5 10 80       	push   $0x8010b5c0
80100afc:	e8 84 46 00 00       	call   80105185 <initlock>
80100b01:	83 c4 10             	add    $0x10,%esp
  initlock(&input.lock, "input");
80100b04:	83 ec 08             	sub    $0x8,%esp
80100b07:	68 cb 87 10 80       	push   $0x801087cb
80100b0c:	68 80 07 11 80       	push   $0x80110780
80100b11:	e8 6f 46 00 00       	call   80105185 <initlock>
80100b16:	83 c4 10             	add    $0x10,%esp

  devsw[CONSOLE].write = consolewrite;
80100b19:	c7 05 ec 11 11 80 70 	movl   $0x80100a70,0x801111ec
80100b20:	0a 10 80 
  devsw[CONSOLE].read = consoleread;
80100b23:	c7 05 e8 11 11 80 5f 	movl   $0x8010095f,0x801111e8
80100b2a:	09 10 80 
  cons.locking = 1;
80100b2d:	c7 05 f4 b5 10 80 01 	movl   $0x1,0x8010b5f4
80100b34:	00 00 00 

  picenable(IRQ_KBD);
80100b37:	83 ec 0c             	sub    $0xc,%esp
80100b3a:	6a 01                	push   $0x1
80100b3c:	e8 cf 33 00 00       	call   80103f10 <picenable>
80100b41:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_KBD, 0);
80100b44:	83 ec 08             	sub    $0x8,%esp
80100b47:	6a 00                	push   $0x0
80100b49:	6a 01                	push   $0x1
80100b4b:	e8 6f 1f 00 00       	call   80102abf <ioapicenable>
80100b50:	83 c4 10             	add    $0x10,%esp
}
80100b53:	90                   	nop
80100b54:	c9                   	leave  
80100b55:	c3                   	ret    

80100b56 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
80100b56:	55                   	push   %ebp
80100b57:	89 e5                	mov    %esp,%ebp
80100b59:	81 ec 18 01 00 00    	sub    $0x118,%esp
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;

  begin_op();
80100b5f:	e8 ce 29 00 00       	call   80103532 <begin_op>
  if((ip = namei(path)) == 0){
80100b64:	83 ec 0c             	sub    $0xc,%esp
80100b67:	ff 75 08             	pushl  0x8(%ebp)
80100b6a:	e8 9e 19 00 00       	call   8010250d <namei>
80100b6f:	83 c4 10             	add    $0x10,%esp
80100b72:	89 45 d8             	mov    %eax,-0x28(%ebp)
80100b75:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100b79:	75 0f                	jne    80100b8a <exec+0x34>
    end_op();
80100b7b:	e8 3e 2a 00 00       	call   801035be <end_op>
    return -1;
80100b80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100b85:	e9 ce 03 00 00       	jmp    80100f58 <exec+0x402>
  }
  ilock(ip);
80100b8a:	83 ec 0c             	sub    $0xc,%esp
80100b8d:	ff 75 d8             	pushl  -0x28(%ebp)
80100b90:	e8 ba 0d 00 00       	call   8010194f <ilock>
80100b95:	83 c4 10             	add    $0x10,%esp
  pgdir = 0;
80100b98:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
80100b9f:	6a 34                	push   $0x34
80100ba1:	6a 00                	push   $0x0
80100ba3:	8d 85 0c ff ff ff    	lea    -0xf4(%ebp),%eax
80100ba9:	50                   	push   %eax
80100baa:	ff 75 d8             	pushl  -0x28(%ebp)
80100bad:	e8 0b 13 00 00       	call   80101ebd <readi>
80100bb2:	83 c4 10             	add    $0x10,%esp
80100bb5:	83 f8 33             	cmp    $0x33,%eax
80100bb8:	0f 86 49 03 00 00    	jbe    80100f07 <exec+0x3b1>
    goto bad;
  if(elf.magic != ELF_MAGIC)
80100bbe:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100bc4:	3d 7f 45 4c 46       	cmp    $0x464c457f,%eax
80100bc9:	0f 85 3b 03 00 00    	jne    80100f0a <exec+0x3b4>
    goto bad;

  if((pgdir = setupkvm()) == 0)
80100bcf:	e8 82 73 00 00       	call   80107f56 <setupkvm>
80100bd4:	89 45 d4             	mov    %eax,-0x2c(%ebp)
80100bd7:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100bdb:	0f 84 2c 03 00 00    	je     80100f0d <exec+0x3b7>
    goto bad;

  // Load program into memory.
  sz = 0;
80100be1:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100be8:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
80100bef:	8b 85 28 ff ff ff    	mov    -0xd8(%ebp),%eax
80100bf5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100bf8:	e9 ab 00 00 00       	jmp    80100ca8 <exec+0x152>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
80100bfd:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100c00:	6a 20                	push   $0x20
80100c02:	50                   	push   %eax
80100c03:	8d 85 ec fe ff ff    	lea    -0x114(%ebp),%eax
80100c09:	50                   	push   %eax
80100c0a:	ff 75 d8             	pushl  -0x28(%ebp)
80100c0d:	e8 ab 12 00 00       	call   80101ebd <readi>
80100c12:	83 c4 10             	add    $0x10,%esp
80100c15:	83 f8 20             	cmp    $0x20,%eax
80100c18:	0f 85 f2 02 00 00    	jne    80100f10 <exec+0x3ba>
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
80100c1e:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100c24:	83 f8 01             	cmp    $0x1,%eax
80100c27:	75 71                	jne    80100c9a <exec+0x144>
      continue;
    if(ph.memsz < ph.filesz)
80100c29:	8b 95 00 ff ff ff    	mov    -0x100(%ebp),%edx
80100c2f:	8b 85 fc fe ff ff    	mov    -0x104(%ebp),%eax
80100c35:	39 c2                	cmp    %eax,%edx
80100c37:	0f 82 d6 02 00 00    	jb     80100f13 <exec+0x3bd>
      goto bad;
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
80100c3d:	8b 95 f4 fe ff ff    	mov    -0x10c(%ebp),%edx
80100c43:	8b 85 00 ff ff ff    	mov    -0x100(%ebp),%eax
80100c49:	01 d0                	add    %edx,%eax
80100c4b:	83 ec 04             	sub    $0x4,%esp
80100c4e:	50                   	push   %eax
80100c4f:	ff 75 e0             	pushl  -0x20(%ebp)
80100c52:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c55:	e8 a3 76 00 00       	call   801082fd <allocuvm>
80100c5a:	83 c4 10             	add    $0x10,%esp
80100c5d:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100c60:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100c64:	0f 84 ac 02 00 00    	je     80100f16 <exec+0x3c0>
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100c6a:	8b 95 fc fe ff ff    	mov    -0x104(%ebp),%edx
80100c70:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
80100c76:	8b 8d f4 fe ff ff    	mov    -0x10c(%ebp),%ecx
80100c7c:	83 ec 0c             	sub    $0xc,%esp
80100c7f:	52                   	push   %edx
80100c80:	50                   	push   %eax
80100c81:	ff 75 d8             	pushl  -0x28(%ebp)
80100c84:	51                   	push   %ecx
80100c85:	ff 75 d4             	pushl  -0x2c(%ebp)
80100c88:	e8 99 75 00 00       	call   80108226 <loaduvm>
80100c8d:	83 c4 20             	add    $0x20,%esp
80100c90:	85 c0                	test   %eax,%eax
80100c92:	0f 88 81 02 00 00    	js     80100f19 <exec+0x3c3>
80100c98:	eb 01                	jmp    80100c9b <exec+0x145>
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
    if(ph.type != ELF_PROG_LOAD)
      continue;
80100c9a:	90                   	nop
  if((pgdir = setupkvm()) == 0)
    goto bad;

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100c9b:	83 45 ec 01          	addl   $0x1,-0x14(%ebp)
80100c9f:	8b 45 e8             	mov    -0x18(%ebp),%eax
80100ca2:	83 c0 20             	add    $0x20,%eax
80100ca5:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100ca8:	0f b7 85 38 ff ff ff 	movzwl -0xc8(%ebp),%eax
80100caf:	0f b7 c0             	movzwl %ax,%eax
80100cb2:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80100cb5:	0f 8f 42 ff ff ff    	jg     80100bfd <exec+0xa7>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
  }
  iunlockput(ip);
80100cbb:	83 ec 0c             	sub    $0xc,%esp
80100cbe:	ff 75 d8             	pushl  -0x28(%ebp)
80100cc1:	e8 49 0f 00 00       	call   80101c0f <iunlockput>
80100cc6:	83 c4 10             	add    $0x10,%esp
  end_op();
80100cc9:	e8 f0 28 00 00       	call   801035be <end_op>
  ip = 0;
80100cce:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
80100cd5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100cd8:	05 ff 0f 00 00       	add    $0xfff,%eax
80100cdd:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80100ce2:	89 45 e0             	mov    %eax,-0x20(%ebp)
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100ce5:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100ce8:	05 00 20 00 00       	add    $0x2000,%eax
80100ced:	83 ec 04             	sub    $0x4,%esp
80100cf0:	50                   	push   %eax
80100cf1:	ff 75 e0             	pushl  -0x20(%ebp)
80100cf4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100cf7:	e8 01 76 00 00       	call   801082fd <allocuvm>
80100cfc:	83 c4 10             	add    $0x10,%esp
80100cff:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d02:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80100d06:	0f 84 10 02 00 00    	je     80100f1c <exec+0x3c6>
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100d0c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d0f:	2d 00 20 00 00       	sub    $0x2000,%eax
80100d14:	83 ec 08             	sub    $0x8,%esp
80100d17:	50                   	push   %eax
80100d18:	ff 75 d4             	pushl  -0x2c(%ebp)
80100d1b:	e8 03 78 00 00       	call   80108523 <clearpteu>
80100d20:	83 c4 10             	add    $0x10,%esp
  sp = sz;
80100d23:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d26:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100d29:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80100d30:	e9 96 00 00 00       	jmp    80100dcb <exec+0x275>
    if(argc >= MAXARG)
80100d35:	83 7d e4 1f          	cmpl   $0x1f,-0x1c(%ebp)
80100d39:	0f 87 e0 01 00 00    	ja     80100f1f <exec+0x3c9>
      goto bad;
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100d3f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d42:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d49:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d4c:	01 d0                	add    %edx,%eax
80100d4e:	8b 00                	mov    (%eax),%eax
80100d50:	83 ec 0c             	sub    $0xc,%esp
80100d53:	50                   	push   %eax
80100d54:	e8 fe 48 00 00       	call   80105657 <strlen>
80100d59:	83 c4 10             	add    $0x10,%esp
80100d5c:	89 c2                	mov    %eax,%edx
80100d5e:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100d61:	29 d0                	sub    %edx,%eax
80100d63:	83 e8 01             	sub    $0x1,%eax
80100d66:	83 e0 fc             	and    $0xfffffffc,%eax
80100d69:	89 45 dc             	mov    %eax,-0x24(%ebp)
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100d6c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d6f:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d76:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d79:	01 d0                	add    %edx,%eax
80100d7b:	8b 00                	mov    (%eax),%eax
80100d7d:	83 ec 0c             	sub    $0xc,%esp
80100d80:	50                   	push   %eax
80100d81:	e8 d1 48 00 00       	call   80105657 <strlen>
80100d86:	83 c4 10             	add    $0x10,%esp
80100d89:	83 c0 01             	add    $0x1,%eax
80100d8c:	89 c1                	mov    %eax,%ecx
80100d8e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100d91:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100d98:	8b 45 0c             	mov    0xc(%ebp),%eax
80100d9b:	01 d0                	add    %edx,%eax
80100d9d:	8b 00                	mov    (%eax),%eax
80100d9f:	51                   	push   %ecx
80100da0:	50                   	push   %eax
80100da1:	ff 75 dc             	pushl  -0x24(%ebp)
80100da4:	ff 75 d4             	pushl  -0x2c(%ebp)
80100da7:	e8 2e 79 00 00       	call   801086da <copyout>
80100dac:	83 c4 10             	add    $0x10,%esp
80100daf:	85 c0                	test   %eax,%eax
80100db1:	0f 88 6b 01 00 00    	js     80100f22 <exec+0x3cc>
      goto bad;
    ustack[3+argc] = sp;
80100db7:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dba:	8d 50 03             	lea    0x3(%eax),%edx
80100dbd:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100dc0:	89 84 95 40 ff ff ff 	mov    %eax,-0xc0(%ebp,%edx,4)
    goto bad;
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
80100dc7:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80100dcb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100dce:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100dd5:	8b 45 0c             	mov    0xc(%ebp),%eax
80100dd8:	01 d0                	add    %edx,%eax
80100dda:	8b 00                	mov    (%eax),%eax
80100ddc:	85 c0                	test   %eax,%eax
80100dde:	0f 85 51 ff ff ff    	jne    80100d35 <exec+0x1df>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
    ustack[3+argc] = sp;
  }
  ustack[3+argc] = 0;
80100de4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100de7:	83 c0 03             	add    $0x3,%eax
80100dea:	c7 84 85 40 ff ff ff 	movl   $0x0,-0xc0(%ebp,%eax,4)
80100df1:	00 00 00 00 

  ustack[0] = 0xffffffff;  // fake return PC
80100df5:	c7 85 40 ff ff ff ff 	movl   $0xffffffff,-0xc0(%ebp)
80100dfc:	ff ff ff 
  ustack[1] = argc;
80100dff:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e02:	89 85 44 ff ff ff    	mov    %eax,-0xbc(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100e08:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e0b:	83 c0 01             	add    $0x1,%eax
80100e0e:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80100e15:	8b 45 dc             	mov    -0x24(%ebp),%eax
80100e18:	29 d0                	sub    %edx,%eax
80100e1a:	89 85 48 ff ff ff    	mov    %eax,-0xb8(%ebp)

  sp -= (3+argc+1) * 4;
80100e20:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e23:	83 c0 04             	add    $0x4,%eax
80100e26:	c1 e0 02             	shl    $0x2,%eax
80100e29:	29 45 dc             	sub    %eax,-0x24(%ebp)
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100e2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100e2f:	83 c0 04             	add    $0x4,%eax
80100e32:	c1 e0 02             	shl    $0x2,%eax
80100e35:	50                   	push   %eax
80100e36:	8d 85 40 ff ff ff    	lea    -0xc0(%ebp),%eax
80100e3c:	50                   	push   %eax
80100e3d:	ff 75 dc             	pushl  -0x24(%ebp)
80100e40:	ff 75 d4             	pushl  -0x2c(%ebp)
80100e43:	e8 92 78 00 00       	call   801086da <copyout>
80100e48:	83 c4 10             	add    $0x10,%esp
80100e4b:	85 c0                	test   %eax,%eax
80100e4d:	0f 88 d2 00 00 00    	js     80100f25 <exec+0x3cf>
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e53:	8b 45 08             	mov    0x8(%ebp),%eax
80100e56:	89 45 f4             	mov    %eax,-0xc(%ebp)
80100e59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e5c:	89 45 f0             	mov    %eax,-0x10(%ebp)
80100e5f:	eb 17                	jmp    80100e78 <exec+0x322>
    if(*s == '/')
80100e61:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e64:	0f b6 00             	movzbl (%eax),%eax
80100e67:	3c 2f                	cmp    $0x2f,%al
80100e69:	75 09                	jne    80100e74 <exec+0x31e>
      last = s+1;
80100e6b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e6e:	83 c0 01             	add    $0x1,%eax
80100e71:	89 45 f0             	mov    %eax,-0x10(%ebp)
  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;

  // Save program name for debugging.
  for(last=s=path; *s; s++)
80100e74:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80100e78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100e7b:	0f b6 00             	movzbl (%eax),%eax
80100e7e:	84 c0                	test   %al,%al
80100e80:	75 df                	jne    80100e61 <exec+0x30b>
    if(*s == '/')
      last = s+1;
  safestrcpy(proc->name, last, sizeof(proc->name));
80100e82:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100e88:	83 c0 6c             	add    $0x6c,%eax
80100e8b:	83 ec 04             	sub    $0x4,%esp
80100e8e:	6a 10                	push   $0x10
80100e90:	ff 75 f0             	pushl  -0x10(%ebp)
80100e93:	50                   	push   %eax
80100e94:	e8 74 47 00 00       	call   8010560d <safestrcpy>
80100e99:	83 c4 10             	add    $0x10,%esp

  // Commit to the user image.
  oldpgdir = proc->pgdir;
80100e9c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ea2:	8b 40 04             	mov    0x4(%eax),%eax
80100ea5:	89 45 d0             	mov    %eax,-0x30(%ebp)
  proc->pgdir = pgdir;
80100ea8:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eae:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80100eb1:	89 50 04             	mov    %edx,0x4(%eax)
  proc->sz = sz;
80100eb4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100eba:	8b 55 e0             	mov    -0x20(%ebp),%edx
80100ebd:	89 10                	mov    %edx,(%eax)
  proc->tf->eip = elf.entry;  // main
80100ebf:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ec5:	8b 40 18             	mov    0x18(%eax),%eax
80100ec8:	8b 95 24 ff ff ff    	mov    -0xdc(%ebp),%edx
80100ece:	89 50 38             	mov    %edx,0x38(%eax)
  proc->tf->esp = sp;
80100ed1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ed7:	8b 40 18             	mov    0x18(%eax),%eax
80100eda:	8b 55 dc             	mov    -0x24(%ebp),%edx
80100edd:	89 50 44             	mov    %edx,0x44(%eax)
  switchuvm(proc);
80100ee0:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80100ee6:	83 ec 0c             	sub    $0xc,%esp
80100ee9:	50                   	push   %eax
80100eea:	e8 4e 71 00 00       	call   8010803d <switchuvm>
80100eef:	83 c4 10             	add    $0x10,%esp
  freevm(oldpgdir);
80100ef2:	83 ec 0c             	sub    $0xc,%esp
80100ef5:	ff 75 d0             	pushl  -0x30(%ebp)
80100ef8:	e8 86 75 00 00       	call   80108483 <freevm>
80100efd:	83 c4 10             	add    $0x10,%esp
  return 0;
80100f00:	b8 00 00 00 00       	mov    $0x0,%eax
80100f05:	eb 51                	jmp    80100f58 <exec+0x402>
  ilock(ip);
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) < sizeof(elf))
    goto bad;
80100f07:	90                   	nop
80100f08:	eb 1c                	jmp    80100f26 <exec+0x3d0>
  if(elf.magic != ELF_MAGIC)
    goto bad;
80100f0a:	90                   	nop
80100f0b:	eb 19                	jmp    80100f26 <exec+0x3d0>

  if((pgdir = setupkvm()) == 0)
    goto bad;
80100f0d:	90                   	nop
80100f0e:	eb 16                	jmp    80100f26 <exec+0x3d0>

  // Load program into memory.
  sz = 0;
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
      goto bad;
80100f10:	90                   	nop
80100f11:	eb 13                	jmp    80100f26 <exec+0x3d0>
    if(ph.type != ELF_PROG_LOAD)
      continue;
    if(ph.memsz < ph.filesz)
      goto bad;
80100f13:	90                   	nop
80100f14:	eb 10                	jmp    80100f26 <exec+0x3d0>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
      goto bad;
80100f16:	90                   	nop
80100f17:	eb 0d                	jmp    80100f26 <exec+0x3d0>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
      goto bad;
80100f19:	90                   	nop
80100f1a:	eb 0a                	jmp    80100f26 <exec+0x3d0>

  // Allocate two pages at the next page boundary.
  // Make the first inaccessible.  Use the second as the user stack.
  sz = PGROUNDUP(sz);
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
    goto bad;
80100f1c:	90                   	nop
80100f1d:	eb 07                	jmp    80100f26 <exec+0x3d0>
  sp = sz;

  // Push argument strings, prepare rest of stack in ustack.
  for(argc = 0; argv[argc]; argc++) {
    if(argc >= MAXARG)
      goto bad;
80100f1f:	90                   	nop
80100f20:	eb 04                	jmp    80100f26 <exec+0x3d0>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
      goto bad;
80100f22:	90                   	nop
80100f23:	eb 01                	jmp    80100f26 <exec+0x3d0>
  ustack[1] = argc;
  ustack[2] = sp - (argc+1)*4;  // argv pointer

  sp -= (3+argc+1) * 4;
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
    goto bad;
80100f25:	90                   	nop
  switchuvm(proc);
  freevm(oldpgdir);
  return 0;

 bad:
  if(pgdir)
80100f26:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
80100f2a:	74 0e                	je     80100f3a <exec+0x3e4>
    freevm(pgdir);
80100f2c:	83 ec 0c             	sub    $0xc,%esp
80100f2f:	ff 75 d4             	pushl  -0x2c(%ebp)
80100f32:	e8 4c 75 00 00       	call   80108483 <freevm>
80100f37:	83 c4 10             	add    $0x10,%esp
  if(ip){
80100f3a:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
80100f3e:	74 13                	je     80100f53 <exec+0x3fd>
    iunlockput(ip);
80100f40:	83 ec 0c             	sub    $0xc,%esp
80100f43:	ff 75 d8             	pushl  -0x28(%ebp)
80100f46:	e8 c4 0c 00 00       	call   80101c0f <iunlockput>
80100f4b:	83 c4 10             	add    $0x10,%esp
    end_op();
80100f4e:	e8 6b 26 00 00       	call   801035be <end_op>
  }
  return -1;
80100f53:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100f58:	c9                   	leave  
80100f59:	c3                   	ret    

80100f5a <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100f5a:	55                   	push   %ebp
80100f5b:	89 e5                	mov    %esp,%ebp
80100f5d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ftable.lock, "ftable");
80100f60:	83 ec 08             	sub    $0x8,%esp
80100f63:	68 d1 87 10 80       	push   $0x801087d1
80100f68:	68 40 08 11 80       	push   $0x80110840
80100f6d:	e8 13 42 00 00       	call   80105185 <initlock>
80100f72:	83 c4 10             	add    $0x10,%esp
}
80100f75:	90                   	nop
80100f76:	c9                   	leave  
80100f77:	c3                   	ret    

80100f78 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100f78:	55                   	push   %ebp
80100f79:	89 e5                	mov    %esp,%ebp
80100f7b:	83 ec 18             	sub    $0x18,%esp
  struct file *f;

  acquire(&ftable.lock);
80100f7e:	83 ec 0c             	sub    $0xc,%esp
80100f81:	68 40 08 11 80       	push   $0x80110840
80100f86:	e8 1c 42 00 00       	call   801051a7 <acquire>
80100f8b:	83 c4 10             	add    $0x10,%esp
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100f8e:	c7 45 f4 74 08 11 80 	movl   $0x80110874,-0xc(%ebp)
80100f95:	eb 2d                	jmp    80100fc4 <filealloc+0x4c>
    if(f->ref == 0){
80100f97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100f9a:	8b 40 04             	mov    0x4(%eax),%eax
80100f9d:	85 c0                	test   %eax,%eax
80100f9f:	75 1f                	jne    80100fc0 <filealloc+0x48>
      f->ref = 1;
80100fa1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fa4:	c7 40 04 01 00 00 00 	movl   $0x1,0x4(%eax)
      release(&ftable.lock);
80100fab:	83 ec 0c             	sub    $0xc,%esp
80100fae:	68 40 08 11 80       	push   $0x80110840
80100fb3:	e8 56 42 00 00       	call   8010520e <release>
80100fb8:	83 c4 10             	add    $0x10,%esp
      return f;
80100fbb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80100fbe:	eb 23                	jmp    80100fe3 <filealloc+0x6b>
filealloc(void)
{
  struct file *f;

  acquire(&ftable.lock);
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100fc0:	83 45 f4 18          	addl   $0x18,-0xc(%ebp)
80100fc4:	b8 d4 11 11 80       	mov    $0x801111d4,%eax
80100fc9:	39 45 f4             	cmp    %eax,-0xc(%ebp)
80100fcc:	72 c9                	jb     80100f97 <filealloc+0x1f>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
80100fce:	83 ec 0c             	sub    $0xc,%esp
80100fd1:	68 40 08 11 80       	push   $0x80110840
80100fd6:	e8 33 42 00 00       	call   8010520e <release>
80100fdb:	83 c4 10             	add    $0x10,%esp
  return 0;
80100fde:	b8 00 00 00 00       	mov    $0x0,%eax
}
80100fe3:	c9                   	leave  
80100fe4:	c3                   	ret    

80100fe5 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100fe5:	55                   	push   %ebp
80100fe6:	89 e5                	mov    %esp,%ebp
80100fe8:	83 ec 08             	sub    $0x8,%esp
  acquire(&ftable.lock);
80100feb:	83 ec 0c             	sub    $0xc,%esp
80100fee:	68 40 08 11 80       	push   $0x80110840
80100ff3:	e8 af 41 00 00       	call   801051a7 <acquire>
80100ff8:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
80100ffb:	8b 45 08             	mov    0x8(%ebp),%eax
80100ffe:	8b 40 04             	mov    0x4(%eax),%eax
80101001:	85 c0                	test   %eax,%eax
80101003:	7f 0d                	jg     80101012 <filedup+0x2d>
    panic("filedup");
80101005:	83 ec 0c             	sub    $0xc,%esp
80101008:	68 d8 87 10 80       	push   $0x801087d8
8010100d:	e8 54 f5 ff ff       	call   80100566 <panic>
  f->ref++;
80101012:	8b 45 08             	mov    0x8(%ebp),%eax
80101015:	8b 40 04             	mov    0x4(%eax),%eax
80101018:	8d 50 01             	lea    0x1(%eax),%edx
8010101b:	8b 45 08             	mov    0x8(%ebp),%eax
8010101e:	89 50 04             	mov    %edx,0x4(%eax)
  release(&ftable.lock);
80101021:	83 ec 0c             	sub    $0xc,%esp
80101024:	68 40 08 11 80       	push   $0x80110840
80101029:	e8 e0 41 00 00       	call   8010520e <release>
8010102e:	83 c4 10             	add    $0x10,%esp
  return f;
80101031:	8b 45 08             	mov    0x8(%ebp),%eax
}
80101034:	c9                   	leave  
80101035:	c3                   	ret    

80101036 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80101036:	55                   	push   %ebp
80101037:	89 e5                	mov    %esp,%ebp
80101039:	83 ec 28             	sub    $0x28,%esp
  struct file ff;

  acquire(&ftable.lock);
8010103c:	83 ec 0c             	sub    $0xc,%esp
8010103f:	68 40 08 11 80       	push   $0x80110840
80101044:	e8 5e 41 00 00       	call   801051a7 <acquire>
80101049:	83 c4 10             	add    $0x10,%esp
  if(f->ref < 1)
8010104c:	8b 45 08             	mov    0x8(%ebp),%eax
8010104f:	8b 40 04             	mov    0x4(%eax),%eax
80101052:	85 c0                	test   %eax,%eax
80101054:	7f 0d                	jg     80101063 <fileclose+0x2d>
    panic("fileclose");
80101056:	83 ec 0c             	sub    $0xc,%esp
80101059:	68 e0 87 10 80       	push   $0x801087e0
8010105e:	e8 03 f5 ff ff       	call   80100566 <panic>
  if(--f->ref > 0){
80101063:	8b 45 08             	mov    0x8(%ebp),%eax
80101066:	8b 40 04             	mov    0x4(%eax),%eax
80101069:	8d 50 ff             	lea    -0x1(%eax),%edx
8010106c:	8b 45 08             	mov    0x8(%ebp),%eax
8010106f:	89 50 04             	mov    %edx,0x4(%eax)
80101072:	8b 45 08             	mov    0x8(%ebp),%eax
80101075:	8b 40 04             	mov    0x4(%eax),%eax
80101078:	85 c0                	test   %eax,%eax
8010107a:	7e 15                	jle    80101091 <fileclose+0x5b>
    release(&ftable.lock);
8010107c:	83 ec 0c             	sub    $0xc,%esp
8010107f:	68 40 08 11 80       	push   $0x80110840
80101084:	e8 85 41 00 00       	call   8010520e <release>
80101089:	83 c4 10             	add    $0x10,%esp
8010108c:	e9 8b 00 00 00       	jmp    8010111c <fileclose+0xe6>
    return;
  }
  ff = *f;
80101091:	8b 45 08             	mov    0x8(%ebp),%eax
80101094:	8b 10                	mov    (%eax),%edx
80101096:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101099:	8b 50 04             	mov    0x4(%eax),%edx
8010109c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
8010109f:	8b 50 08             	mov    0x8(%eax),%edx
801010a2:	89 55 e8             	mov    %edx,-0x18(%ebp)
801010a5:	8b 50 0c             	mov    0xc(%eax),%edx
801010a8:	89 55 ec             	mov    %edx,-0x14(%ebp)
801010ab:	8b 50 10             	mov    0x10(%eax),%edx
801010ae:	89 55 f0             	mov    %edx,-0x10(%ebp)
801010b1:	8b 40 14             	mov    0x14(%eax),%eax
801010b4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  f->ref = 0;
801010b7:	8b 45 08             	mov    0x8(%ebp),%eax
801010ba:	c7 40 04 00 00 00 00 	movl   $0x0,0x4(%eax)
  f->type = FD_NONE;
801010c1:	8b 45 08             	mov    0x8(%ebp),%eax
801010c4:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  release(&ftable.lock);
801010ca:	83 ec 0c             	sub    $0xc,%esp
801010cd:	68 40 08 11 80       	push   $0x80110840
801010d2:	e8 37 41 00 00       	call   8010520e <release>
801010d7:	83 c4 10             	add    $0x10,%esp
  
  if(ff.type == FD_PIPE)
801010da:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010dd:	83 f8 01             	cmp    $0x1,%eax
801010e0:	75 19                	jne    801010fb <fileclose+0xc5>
    pipeclose(ff.pipe, ff.writable);
801010e2:	0f b6 45 e9          	movzbl -0x17(%ebp),%eax
801010e6:	0f be d0             	movsbl %al,%edx
801010e9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801010ec:	83 ec 08             	sub    $0x8,%esp
801010ef:	52                   	push   %edx
801010f0:	50                   	push   %eax
801010f1:	e8 83 30 00 00       	call   80104179 <pipeclose>
801010f6:	83 c4 10             	add    $0x10,%esp
801010f9:	eb 21                	jmp    8010111c <fileclose+0xe6>
  else if(ff.type == FD_INODE){
801010fb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010fe:	83 f8 02             	cmp    $0x2,%eax
80101101:	75 19                	jne    8010111c <fileclose+0xe6>
    begin_op();
80101103:	e8 2a 24 00 00       	call   80103532 <begin_op>
    iput(ff.ip);
80101108:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010110b:	83 ec 0c             	sub    $0xc,%esp
8010110e:	50                   	push   %eax
8010110f:	e8 0b 0a 00 00       	call   80101b1f <iput>
80101114:	83 c4 10             	add    $0x10,%esp
    end_op();
80101117:	e8 a2 24 00 00       	call   801035be <end_op>
  }
}
8010111c:	c9                   	leave  
8010111d:	c3                   	ret    

8010111e <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
8010111e:	55                   	push   %ebp
8010111f:	89 e5                	mov    %esp,%ebp
80101121:	83 ec 08             	sub    $0x8,%esp
  if(f->type == FD_INODE){
80101124:	8b 45 08             	mov    0x8(%ebp),%eax
80101127:	8b 00                	mov    (%eax),%eax
80101129:	83 f8 02             	cmp    $0x2,%eax
8010112c:	75 40                	jne    8010116e <filestat+0x50>
    ilock(f->ip);
8010112e:	8b 45 08             	mov    0x8(%ebp),%eax
80101131:	8b 40 10             	mov    0x10(%eax),%eax
80101134:	83 ec 0c             	sub    $0xc,%esp
80101137:	50                   	push   %eax
80101138:	e8 12 08 00 00       	call   8010194f <ilock>
8010113d:	83 c4 10             	add    $0x10,%esp
    stati(f->ip, st);
80101140:	8b 45 08             	mov    0x8(%ebp),%eax
80101143:	8b 40 10             	mov    0x10(%eax),%eax
80101146:	83 ec 08             	sub    $0x8,%esp
80101149:	ff 75 0c             	pushl  0xc(%ebp)
8010114c:	50                   	push   %eax
8010114d:	e8 25 0d 00 00       	call   80101e77 <stati>
80101152:	83 c4 10             	add    $0x10,%esp
    iunlock(f->ip);
80101155:	8b 45 08             	mov    0x8(%ebp),%eax
80101158:	8b 40 10             	mov    0x10(%eax),%eax
8010115b:	83 ec 0c             	sub    $0xc,%esp
8010115e:	50                   	push   %eax
8010115f:	e8 49 09 00 00       	call   80101aad <iunlock>
80101164:	83 c4 10             	add    $0x10,%esp
    return 0;
80101167:	b8 00 00 00 00       	mov    $0x0,%eax
8010116c:	eb 05                	jmp    80101173 <filestat+0x55>
  }
  return -1;
8010116e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80101173:	c9                   	leave  
80101174:	c3                   	ret    

80101175 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80101175:	55                   	push   %ebp
80101176:	89 e5                	mov    %esp,%ebp
80101178:	83 ec 18             	sub    $0x18,%esp
  int r;

  if(f->readable == 0)
8010117b:	8b 45 08             	mov    0x8(%ebp),%eax
8010117e:	0f b6 40 08          	movzbl 0x8(%eax),%eax
80101182:	84 c0                	test   %al,%al
80101184:	75 0a                	jne    80101190 <fileread+0x1b>
    return -1;
80101186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010118b:	e9 9b 00 00 00       	jmp    8010122b <fileread+0xb6>
  if(f->type == FD_PIPE)
80101190:	8b 45 08             	mov    0x8(%ebp),%eax
80101193:	8b 00                	mov    (%eax),%eax
80101195:	83 f8 01             	cmp    $0x1,%eax
80101198:	75 1a                	jne    801011b4 <fileread+0x3f>
    return piperead(f->pipe, addr, n);
8010119a:	8b 45 08             	mov    0x8(%ebp),%eax
8010119d:	8b 40 0c             	mov    0xc(%eax),%eax
801011a0:	83 ec 04             	sub    $0x4,%esp
801011a3:	ff 75 10             	pushl  0x10(%ebp)
801011a6:	ff 75 0c             	pushl  0xc(%ebp)
801011a9:	50                   	push   %eax
801011aa:	e8 72 31 00 00       	call   80104321 <piperead>
801011af:	83 c4 10             	add    $0x10,%esp
801011b2:	eb 77                	jmp    8010122b <fileread+0xb6>
  if(f->type == FD_INODE){
801011b4:	8b 45 08             	mov    0x8(%ebp),%eax
801011b7:	8b 00                	mov    (%eax),%eax
801011b9:	83 f8 02             	cmp    $0x2,%eax
801011bc:	75 60                	jne    8010121e <fileread+0xa9>
    ilock(f->ip);
801011be:	8b 45 08             	mov    0x8(%ebp),%eax
801011c1:	8b 40 10             	mov    0x10(%eax),%eax
801011c4:	83 ec 0c             	sub    $0xc,%esp
801011c7:	50                   	push   %eax
801011c8:	e8 82 07 00 00       	call   8010194f <ilock>
801011cd:	83 c4 10             	add    $0x10,%esp
    if((r = readi(f->ip, addr, f->off, n)) > 0)
801011d0:	8b 4d 10             	mov    0x10(%ebp),%ecx
801011d3:	8b 45 08             	mov    0x8(%ebp),%eax
801011d6:	8b 50 14             	mov    0x14(%eax),%edx
801011d9:	8b 45 08             	mov    0x8(%ebp),%eax
801011dc:	8b 40 10             	mov    0x10(%eax),%eax
801011df:	51                   	push   %ecx
801011e0:	52                   	push   %edx
801011e1:	ff 75 0c             	pushl  0xc(%ebp)
801011e4:	50                   	push   %eax
801011e5:	e8 d3 0c 00 00       	call   80101ebd <readi>
801011ea:	83 c4 10             	add    $0x10,%esp
801011ed:	89 45 f4             	mov    %eax,-0xc(%ebp)
801011f0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801011f4:	7e 11                	jle    80101207 <fileread+0x92>
      f->off += r;
801011f6:	8b 45 08             	mov    0x8(%ebp),%eax
801011f9:	8b 50 14             	mov    0x14(%eax),%edx
801011fc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801011ff:	01 c2                	add    %eax,%edx
80101201:	8b 45 08             	mov    0x8(%ebp),%eax
80101204:	89 50 14             	mov    %edx,0x14(%eax)
    iunlock(f->ip);
80101207:	8b 45 08             	mov    0x8(%ebp),%eax
8010120a:	8b 40 10             	mov    0x10(%eax),%eax
8010120d:	83 ec 0c             	sub    $0xc,%esp
80101210:	50                   	push   %eax
80101211:	e8 97 08 00 00       	call   80101aad <iunlock>
80101216:	83 c4 10             	add    $0x10,%esp
    return r;
80101219:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010121c:	eb 0d                	jmp    8010122b <fileread+0xb6>
  }
  panic("fileread");
8010121e:	83 ec 0c             	sub    $0xc,%esp
80101221:	68 ea 87 10 80       	push   $0x801087ea
80101226:	e8 3b f3 ff ff       	call   80100566 <panic>
}
8010122b:	c9                   	leave  
8010122c:	c3                   	ret    

8010122d <filewrite>:

//PAGEBREAK!
// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
8010122d:	55                   	push   %ebp
8010122e:	89 e5                	mov    %esp,%ebp
80101230:	53                   	push   %ebx
80101231:	83 ec 14             	sub    $0x14,%esp
  int r;

  if(f->writable == 0)
80101234:	8b 45 08             	mov    0x8(%ebp),%eax
80101237:	0f b6 40 09          	movzbl 0x9(%eax),%eax
8010123b:	84 c0                	test   %al,%al
8010123d:	75 0a                	jne    80101249 <filewrite+0x1c>
    return -1;
8010123f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101244:	e9 1b 01 00 00       	jmp    80101364 <filewrite+0x137>
  if(f->type == FD_PIPE)
80101249:	8b 45 08             	mov    0x8(%ebp),%eax
8010124c:	8b 00                	mov    (%eax),%eax
8010124e:	83 f8 01             	cmp    $0x1,%eax
80101251:	75 1d                	jne    80101270 <filewrite+0x43>
    return pipewrite(f->pipe, addr, n);
80101253:	8b 45 08             	mov    0x8(%ebp),%eax
80101256:	8b 40 0c             	mov    0xc(%eax),%eax
80101259:	83 ec 04             	sub    $0x4,%esp
8010125c:	ff 75 10             	pushl  0x10(%ebp)
8010125f:	ff 75 0c             	pushl  0xc(%ebp)
80101262:	50                   	push   %eax
80101263:	e8 bb 2f 00 00       	call   80104223 <pipewrite>
80101268:	83 c4 10             	add    $0x10,%esp
8010126b:	e9 f4 00 00 00       	jmp    80101364 <filewrite+0x137>
  if(f->type == FD_INODE){
80101270:	8b 45 08             	mov    0x8(%ebp),%eax
80101273:	8b 00                	mov    (%eax),%eax
80101275:	83 f8 02             	cmp    $0x2,%eax
80101278:	0f 85 d9 00 00 00    	jne    80101357 <filewrite+0x12a>
    // the maximum log transaction size, including
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
8010127e:	c7 45 ec 00 1a 00 00 	movl   $0x1a00,-0x14(%ebp)
    int i = 0;
80101285:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    while(i < n){
8010128c:	e9 a3 00 00 00       	jmp    80101334 <filewrite+0x107>
      int n1 = n - i;
80101291:	8b 45 10             	mov    0x10(%ebp),%eax
80101294:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101297:	89 45 f0             	mov    %eax,-0x10(%ebp)
      if(n1 > max)
8010129a:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010129d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
801012a0:	7e 06                	jle    801012a8 <filewrite+0x7b>
        n1 = max;
801012a2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801012a5:	89 45 f0             	mov    %eax,-0x10(%ebp)

      begin_op();
801012a8:	e8 85 22 00 00       	call   80103532 <begin_op>
      ilock(f->ip);
801012ad:	8b 45 08             	mov    0x8(%ebp),%eax
801012b0:	8b 40 10             	mov    0x10(%eax),%eax
801012b3:	83 ec 0c             	sub    $0xc,%esp
801012b6:	50                   	push   %eax
801012b7:	e8 93 06 00 00       	call   8010194f <ilock>
801012bc:	83 c4 10             	add    $0x10,%esp
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
801012bf:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801012c2:	8b 45 08             	mov    0x8(%ebp),%eax
801012c5:	8b 50 14             	mov    0x14(%eax),%edx
801012c8:	8b 5d f4             	mov    -0xc(%ebp),%ebx
801012cb:	8b 45 0c             	mov    0xc(%ebp),%eax
801012ce:	01 c3                	add    %eax,%ebx
801012d0:	8b 45 08             	mov    0x8(%ebp),%eax
801012d3:	8b 40 10             	mov    0x10(%eax),%eax
801012d6:	51                   	push   %ecx
801012d7:	52                   	push   %edx
801012d8:	53                   	push   %ebx
801012d9:	50                   	push   %eax
801012da:	e8 35 0d 00 00       	call   80102014 <writei>
801012df:	83 c4 10             	add    $0x10,%esp
801012e2:	89 45 e8             	mov    %eax,-0x18(%ebp)
801012e5:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
801012e9:	7e 11                	jle    801012fc <filewrite+0xcf>
        f->off += r;
801012eb:	8b 45 08             	mov    0x8(%ebp),%eax
801012ee:	8b 50 14             	mov    0x14(%eax),%edx
801012f1:	8b 45 e8             	mov    -0x18(%ebp),%eax
801012f4:	01 c2                	add    %eax,%edx
801012f6:	8b 45 08             	mov    0x8(%ebp),%eax
801012f9:	89 50 14             	mov    %edx,0x14(%eax)
      iunlock(f->ip);
801012fc:	8b 45 08             	mov    0x8(%ebp),%eax
801012ff:	8b 40 10             	mov    0x10(%eax),%eax
80101302:	83 ec 0c             	sub    $0xc,%esp
80101305:	50                   	push   %eax
80101306:	e8 a2 07 00 00       	call   80101aad <iunlock>
8010130b:	83 c4 10             	add    $0x10,%esp
      end_op();
8010130e:	e8 ab 22 00 00       	call   801035be <end_op>

      if(r < 0)
80101313:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
80101317:	78 29                	js     80101342 <filewrite+0x115>
        break;
      if(r != n1)
80101319:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010131c:	3b 45 f0             	cmp    -0x10(%ebp),%eax
8010131f:	74 0d                	je     8010132e <filewrite+0x101>
        panic("short filewrite");
80101321:	83 ec 0c             	sub    $0xc,%esp
80101324:	68 f3 87 10 80       	push   $0x801087f3
80101329:	e8 38 f2 ff ff       	call   80100566 <panic>
      i += r;
8010132e:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101331:	01 45 f4             	add    %eax,-0xc(%ebp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((LOGSIZE-1-1-2) / 2) * 512;
    int i = 0;
    while(i < n){
80101334:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101337:	3b 45 10             	cmp    0x10(%ebp),%eax
8010133a:	0f 8c 51 ff ff ff    	jl     80101291 <filewrite+0x64>
80101340:	eb 01                	jmp    80101343 <filewrite+0x116>
        f->off += r;
      iunlock(f->ip);
      end_op();

      if(r < 0)
        break;
80101342:	90                   	nop
      if(r != n1)
        panic("short filewrite");
      i += r;
    }
    return i == n ? n : -1;
80101343:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101346:	3b 45 10             	cmp    0x10(%ebp),%eax
80101349:	75 05                	jne    80101350 <filewrite+0x123>
8010134b:	8b 45 10             	mov    0x10(%ebp),%eax
8010134e:	eb 14                	jmp    80101364 <filewrite+0x137>
80101350:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101355:	eb 0d                	jmp    80101364 <filewrite+0x137>
  }
  panic("filewrite");
80101357:	83 ec 0c             	sub    $0xc,%esp
8010135a:	68 03 88 10 80       	push   $0x80108803
8010135f:	e8 02 f2 ff ff       	call   80100566 <panic>
}
80101364:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101367:	c9                   	leave  
80101368:	c3                   	ret    

80101369 <readsb>:
struct superblock sb;   // there should be one per dev, but we run with one dev

// Read the super block.
void
readsb(int dev, struct superblock *sb)
{
80101369:	55                   	push   %ebp
8010136a:	89 e5                	mov    %esp,%ebp
8010136c:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, 1);
8010136f:	8b 45 08             	mov    0x8(%ebp),%eax
80101372:	83 ec 08             	sub    $0x8,%esp
80101375:	6a 01                	push   $0x1
80101377:	50                   	push   %eax
80101378:	e8 39 ee ff ff       	call   801001b6 <bread>
8010137d:	83 c4 10             	add    $0x10,%esp
80101380:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memmove(sb, bp->data, sizeof(*sb));
80101383:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101386:	83 c0 18             	add    $0x18,%eax
80101389:	83 ec 04             	sub    $0x4,%esp
8010138c:	6a 1c                	push   $0x1c
8010138e:	50                   	push   %eax
8010138f:	ff 75 0c             	pushl  0xc(%ebp)
80101392:	e8 32 41 00 00       	call   801054c9 <memmove>
80101397:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
8010139a:	83 ec 0c             	sub    $0xc,%esp
8010139d:	ff 75 f4             	pushl  -0xc(%ebp)
801013a0:	e8 89 ee ff ff       	call   8010022e <brelse>
801013a5:	83 c4 10             	add    $0x10,%esp
}
801013a8:	90                   	nop
801013a9:	c9                   	leave  
801013aa:	c3                   	ret    

801013ab <bzero>:

// Zero a block.
static void
bzero(int dev, int bno)
{
801013ab:	55                   	push   %ebp
801013ac:	89 e5                	mov    %esp,%ebp
801013ae:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  
  bp = bread(dev, bno);
801013b1:	8b 55 0c             	mov    0xc(%ebp),%edx
801013b4:	8b 45 08             	mov    0x8(%ebp),%eax
801013b7:	83 ec 08             	sub    $0x8,%esp
801013ba:	52                   	push   %edx
801013bb:	50                   	push   %eax
801013bc:	e8 f5 ed ff ff       	call   801001b6 <bread>
801013c1:	83 c4 10             	add    $0x10,%esp
801013c4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(bp->data, 0, BSIZE);
801013c7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801013ca:	83 c0 18             	add    $0x18,%eax
801013cd:	83 ec 04             	sub    $0x4,%esp
801013d0:	68 00 02 00 00       	push   $0x200
801013d5:	6a 00                	push   $0x0
801013d7:	50                   	push   %eax
801013d8:	e8 2d 40 00 00       	call   8010540a <memset>
801013dd:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
801013e0:	83 ec 0c             	sub    $0xc,%esp
801013e3:	ff 75 f4             	pushl  -0xc(%ebp)
801013e6:	e8 7f 23 00 00       	call   8010376a <log_write>
801013eb:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
801013ee:	83 ec 0c             	sub    $0xc,%esp
801013f1:	ff 75 f4             	pushl  -0xc(%ebp)
801013f4:	e8 35 ee ff ff       	call   8010022e <brelse>
801013f9:	83 c4 10             	add    $0x10,%esp
}
801013fc:	90                   	nop
801013fd:	c9                   	leave  
801013fe:	c3                   	ret    

801013ff <balloc>:
// Blocks. 

// Allocate a zeroed disk block.
static uint
balloc(uint dev)
{
801013ff:	55                   	push   %ebp
80101400:	89 e5                	mov    %esp,%ebp
80101402:	83 ec 18             	sub    $0x18,%esp
  int b, bi, m;
  struct buf *bp;

  bp = 0;
80101405:	c7 45 ec 00 00 00 00 	movl   $0x0,-0x14(%ebp)
  for(b = 0; b < sb.size; b += BPB){
8010140c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101413:	e9 13 01 00 00       	jmp    8010152b <balloc+0x12c>
    bp = bread(dev, BBLOCK(b, sb));
80101418:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010141b:	8d 90 ff 0f 00 00    	lea    0xfff(%eax),%edx
80101421:	85 c0                	test   %eax,%eax
80101423:	0f 48 c2             	cmovs  %edx,%eax
80101426:	c1 f8 0c             	sar    $0xc,%eax
80101429:	89 c2                	mov    %eax,%edx
8010142b:	a1 58 12 11 80       	mov    0x80111258,%eax
80101430:	01 d0                	add    %edx,%eax
80101432:	83 ec 08             	sub    $0x8,%esp
80101435:	50                   	push   %eax
80101436:	ff 75 08             	pushl  0x8(%ebp)
80101439:	e8 78 ed ff ff       	call   801001b6 <bread>
8010143e:	83 c4 10             	add    $0x10,%esp
80101441:	89 45 ec             	mov    %eax,-0x14(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
80101444:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
8010144b:	e9 a6 00 00 00       	jmp    801014f6 <balloc+0xf7>
      m = 1 << (bi % 8);
80101450:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101453:	99                   	cltd   
80101454:	c1 ea 1d             	shr    $0x1d,%edx
80101457:	01 d0                	add    %edx,%eax
80101459:	83 e0 07             	and    $0x7,%eax
8010145c:	29 d0                	sub    %edx,%eax
8010145e:	ba 01 00 00 00       	mov    $0x1,%edx
80101463:	89 c1                	mov    %eax,%ecx
80101465:	d3 e2                	shl    %cl,%edx
80101467:	89 d0                	mov    %edx,%eax
80101469:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010146c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010146f:	8d 50 07             	lea    0x7(%eax),%edx
80101472:	85 c0                	test   %eax,%eax
80101474:	0f 48 c2             	cmovs  %edx,%eax
80101477:	c1 f8 03             	sar    $0x3,%eax
8010147a:	89 c2                	mov    %eax,%edx
8010147c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010147f:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
80101484:	0f b6 c0             	movzbl %al,%eax
80101487:	23 45 e8             	and    -0x18(%ebp),%eax
8010148a:	85 c0                	test   %eax,%eax
8010148c:	75 64                	jne    801014f2 <balloc+0xf3>
        bp->data[bi/8] |= m;  // Mark block in use.
8010148e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101491:	8d 50 07             	lea    0x7(%eax),%edx
80101494:	85 c0                	test   %eax,%eax
80101496:	0f 48 c2             	cmovs  %edx,%eax
80101499:	c1 f8 03             	sar    $0x3,%eax
8010149c:	8b 55 ec             	mov    -0x14(%ebp),%edx
8010149f:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801014a4:	89 d1                	mov    %edx,%ecx
801014a6:	8b 55 e8             	mov    -0x18(%ebp),%edx
801014a9:	09 ca                	or     %ecx,%edx
801014ab:	89 d1                	mov    %edx,%ecx
801014ad:	8b 55 ec             	mov    -0x14(%ebp),%edx
801014b0:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
        log_write(bp);
801014b4:	83 ec 0c             	sub    $0xc,%esp
801014b7:	ff 75 ec             	pushl  -0x14(%ebp)
801014ba:	e8 ab 22 00 00       	call   8010376a <log_write>
801014bf:	83 c4 10             	add    $0x10,%esp
        brelse(bp);
801014c2:	83 ec 0c             	sub    $0xc,%esp
801014c5:	ff 75 ec             	pushl  -0x14(%ebp)
801014c8:	e8 61 ed ff ff       	call   8010022e <brelse>
801014cd:	83 c4 10             	add    $0x10,%esp
        bzero(dev, b + bi);
801014d0:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014d3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014d6:	01 c2                	add    %eax,%edx
801014d8:	8b 45 08             	mov    0x8(%ebp),%eax
801014db:	83 ec 08             	sub    $0x8,%esp
801014de:	52                   	push   %edx
801014df:	50                   	push   %eax
801014e0:	e8 c6 fe ff ff       	call   801013ab <bzero>
801014e5:	83 c4 10             	add    $0x10,%esp
        return b + bi;
801014e8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801014eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
801014ee:	01 d0                	add    %edx,%eax
801014f0:	eb 57                	jmp    80101549 <balloc+0x14a>
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
    bp = bread(dev, BBLOCK(b, sb));
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
801014f2:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
801014f6:	81 7d f0 ff 0f 00 00 	cmpl   $0xfff,-0x10(%ebp)
801014fd:	7f 17                	jg     80101516 <balloc+0x117>
801014ff:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101502:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101505:	01 d0                	add    %edx,%eax
80101507:	89 c2                	mov    %eax,%edx
80101509:	a1 40 12 11 80       	mov    0x80111240,%eax
8010150e:	39 c2                	cmp    %eax,%edx
80101510:	0f 82 3a ff ff ff    	jb     80101450 <balloc+0x51>
        brelse(bp);
        bzero(dev, b + bi);
        return b + bi;
      }
    }
    brelse(bp);
80101516:	83 ec 0c             	sub    $0xc,%esp
80101519:	ff 75 ec             	pushl  -0x14(%ebp)
8010151c:	e8 0d ed ff ff       	call   8010022e <brelse>
80101521:	83 c4 10             	add    $0x10,%esp
{
  int b, bi, m;
  struct buf *bp;

  bp = 0;
  for(b = 0; b < sb.size; b += BPB){
80101524:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
8010152b:	8b 15 40 12 11 80    	mov    0x80111240,%edx
80101531:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101534:	39 c2                	cmp    %eax,%edx
80101536:	0f 87 dc fe ff ff    	ja     80101418 <balloc+0x19>
        return b + bi;
      }
    }
    brelse(bp);
  }
  panic("balloc: out of blocks");
8010153c:	83 ec 0c             	sub    $0xc,%esp
8010153f:	68 10 88 10 80       	push   $0x80108810
80101544:	e8 1d f0 ff ff       	call   80100566 <panic>
}
80101549:	c9                   	leave  
8010154a:	c3                   	ret    

8010154b <bfree>:

// Free a disk block.
static void
bfree(int dev, uint b)
{
8010154b:	55                   	push   %ebp
8010154c:	89 e5                	mov    %esp,%ebp
8010154e:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  int bi, m;

  readsb(dev, &sb);
80101551:	83 ec 08             	sub    $0x8,%esp
80101554:	68 40 12 11 80       	push   $0x80111240
80101559:	ff 75 08             	pushl  0x8(%ebp)
8010155c:	e8 08 fe ff ff       	call   80101369 <readsb>
80101561:	83 c4 10             	add    $0x10,%esp
  bp = bread(dev, BBLOCK(b, sb));
80101564:	8b 45 0c             	mov    0xc(%ebp),%eax
80101567:	c1 e8 0c             	shr    $0xc,%eax
8010156a:	89 c2                	mov    %eax,%edx
8010156c:	a1 58 12 11 80       	mov    0x80111258,%eax
80101571:	01 c2                	add    %eax,%edx
80101573:	8b 45 08             	mov    0x8(%ebp),%eax
80101576:	83 ec 08             	sub    $0x8,%esp
80101579:	52                   	push   %edx
8010157a:	50                   	push   %eax
8010157b:	e8 36 ec ff ff       	call   801001b6 <bread>
80101580:	83 c4 10             	add    $0x10,%esp
80101583:	89 45 f4             	mov    %eax,-0xc(%ebp)
  bi = b % BPB;
80101586:	8b 45 0c             	mov    0xc(%ebp),%eax
80101589:	25 ff 0f 00 00       	and    $0xfff,%eax
8010158e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  m = 1 << (bi % 8);
80101591:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101594:	99                   	cltd   
80101595:	c1 ea 1d             	shr    $0x1d,%edx
80101598:	01 d0                	add    %edx,%eax
8010159a:	83 e0 07             	and    $0x7,%eax
8010159d:	29 d0                	sub    %edx,%eax
8010159f:	ba 01 00 00 00       	mov    $0x1,%edx
801015a4:	89 c1                	mov    %eax,%ecx
801015a6:	d3 e2                	shl    %cl,%edx
801015a8:	89 d0                	mov    %edx,%eax
801015aa:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if((bp->data[bi/8] & m) == 0)
801015ad:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015b0:	8d 50 07             	lea    0x7(%eax),%edx
801015b3:	85 c0                	test   %eax,%eax
801015b5:	0f 48 c2             	cmovs  %edx,%eax
801015b8:	c1 f8 03             	sar    $0x3,%eax
801015bb:	89 c2                	mov    %eax,%edx
801015bd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801015c0:	0f b6 44 10 18       	movzbl 0x18(%eax,%edx,1),%eax
801015c5:	0f b6 c0             	movzbl %al,%eax
801015c8:	23 45 ec             	and    -0x14(%ebp),%eax
801015cb:	85 c0                	test   %eax,%eax
801015cd:	75 0d                	jne    801015dc <bfree+0x91>
    panic("freeing free block");
801015cf:	83 ec 0c             	sub    $0xc,%esp
801015d2:	68 26 88 10 80       	push   $0x80108826
801015d7:	e8 8a ef ff ff       	call   80100566 <panic>
  bp->data[bi/8] &= ~m;
801015dc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801015df:	8d 50 07             	lea    0x7(%eax),%edx
801015e2:	85 c0                	test   %eax,%eax
801015e4:	0f 48 c2             	cmovs  %edx,%eax
801015e7:	c1 f8 03             	sar    $0x3,%eax
801015ea:	8b 55 f4             	mov    -0xc(%ebp),%edx
801015ed:	0f b6 54 02 18       	movzbl 0x18(%edx,%eax,1),%edx
801015f2:	89 d1                	mov    %edx,%ecx
801015f4:	8b 55 ec             	mov    -0x14(%ebp),%edx
801015f7:	f7 d2                	not    %edx
801015f9:	21 ca                	and    %ecx,%edx
801015fb:	89 d1                	mov    %edx,%ecx
801015fd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101600:	88 4c 02 18          	mov    %cl,0x18(%edx,%eax,1)
  log_write(bp);
80101604:	83 ec 0c             	sub    $0xc,%esp
80101607:	ff 75 f4             	pushl  -0xc(%ebp)
8010160a:	e8 5b 21 00 00       	call   8010376a <log_write>
8010160f:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101612:	83 ec 0c             	sub    $0xc,%esp
80101615:	ff 75 f4             	pushl  -0xc(%ebp)
80101618:	e8 11 ec ff ff       	call   8010022e <brelse>
8010161d:	83 c4 10             	add    $0x10,%esp
}
80101620:	90                   	nop
80101621:	c9                   	leave  
80101622:	c3                   	ret    

80101623 <iinit>:
  struct inode inode[NINODE];
} icache;

void
iinit(int dev)
{
80101623:	55                   	push   %ebp
80101624:	89 e5                	mov    %esp,%ebp
80101626:	57                   	push   %edi
80101627:	56                   	push   %esi
80101628:	53                   	push   %ebx
80101629:	83 ec 1c             	sub    $0x1c,%esp
  initlock(&icache.lock, "icache");
8010162c:	83 ec 08             	sub    $0x8,%esp
8010162f:	68 39 88 10 80       	push   $0x80108839
80101634:	68 60 12 11 80       	push   $0x80111260
80101639:	e8 47 3b 00 00       	call   80105185 <initlock>
8010163e:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
80101641:	83 ec 08             	sub    $0x8,%esp
80101644:	68 40 12 11 80       	push   $0x80111240
80101649:	ff 75 08             	pushl  0x8(%ebp)
8010164c:	e8 18 fd ff ff       	call   80101369 <readsb>
80101651:	83 c4 10             	add    $0x10,%esp
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d inodestart %d bmap start %d\n", sb.size,
80101654:	a1 58 12 11 80       	mov    0x80111258,%eax
80101659:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010165c:	8b 3d 54 12 11 80    	mov    0x80111254,%edi
80101662:	8b 35 50 12 11 80    	mov    0x80111250,%esi
80101668:	8b 1d 4c 12 11 80    	mov    0x8011124c,%ebx
8010166e:	8b 0d 48 12 11 80    	mov    0x80111248,%ecx
80101674:	8b 15 44 12 11 80    	mov    0x80111244,%edx
8010167a:	a1 40 12 11 80       	mov    0x80111240,%eax
8010167f:	ff 75 e4             	pushl  -0x1c(%ebp)
80101682:	57                   	push   %edi
80101683:	56                   	push   %esi
80101684:	53                   	push   %ebx
80101685:	51                   	push   %ecx
80101686:	52                   	push   %edx
80101687:	50                   	push   %eax
80101688:	68 40 88 10 80       	push   $0x80108840
8010168d:	e8 34 ed ff ff       	call   801003c6 <cprintf>
80101692:	83 c4 20             	add    $0x20,%esp
          sb.nblocks, sb.ninodes, sb.nlog, sb.logstart, sb.inodestart, sb.bmapstart);
}
80101695:	90                   	nop
80101696:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101699:	5b                   	pop    %ebx
8010169a:	5e                   	pop    %esi
8010169b:	5f                   	pop    %edi
8010169c:	5d                   	pop    %ebp
8010169d:	c3                   	ret    

8010169e <ialloc>:
//PAGEBREAK!
// Allocate a new inode with the given type on device dev.
// A free inode has a type of zero.
struct inode*
ialloc(uint dev, short type)
{
8010169e:	55                   	push   %ebp
8010169f:	89 e5                	mov    %esp,%ebp
801016a1:	83 ec 28             	sub    $0x28,%esp
801016a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801016a7:	66 89 45 e4          	mov    %ax,-0x1c(%ebp)
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
801016ab:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
801016b2:	e9 9e 00 00 00       	jmp    80101755 <ialloc+0xb7>
    bp = bread(dev, IBLOCK(inum, sb));
801016b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016ba:	c1 e8 03             	shr    $0x3,%eax
801016bd:	89 c2                	mov    %eax,%edx
801016bf:	a1 54 12 11 80       	mov    0x80111254,%eax
801016c4:	01 d0                	add    %edx,%eax
801016c6:	83 ec 08             	sub    $0x8,%esp
801016c9:	50                   	push   %eax
801016ca:	ff 75 08             	pushl  0x8(%ebp)
801016cd:	e8 e4 ea ff ff       	call   801001b6 <bread>
801016d2:	83 c4 10             	add    $0x10,%esp
801016d5:	89 45 f0             	mov    %eax,-0x10(%ebp)
    dip = (struct dinode*)bp->data + inum%IPB;
801016d8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801016db:	8d 50 18             	lea    0x18(%eax),%edx
801016de:	8b 45 f4             	mov    -0xc(%ebp),%eax
801016e1:	83 e0 07             	and    $0x7,%eax
801016e4:	c1 e0 06             	shl    $0x6,%eax
801016e7:	01 d0                	add    %edx,%eax
801016e9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if(dip->type == 0){  // a free inode
801016ec:	8b 45 ec             	mov    -0x14(%ebp),%eax
801016ef:	0f b7 00             	movzwl (%eax),%eax
801016f2:	66 85 c0             	test   %ax,%ax
801016f5:	75 4c                	jne    80101743 <ialloc+0xa5>
      memset(dip, 0, sizeof(*dip));
801016f7:	83 ec 04             	sub    $0x4,%esp
801016fa:	6a 40                	push   $0x40
801016fc:	6a 00                	push   $0x0
801016fe:	ff 75 ec             	pushl  -0x14(%ebp)
80101701:	e8 04 3d 00 00       	call   8010540a <memset>
80101706:	83 c4 10             	add    $0x10,%esp
      dip->type = type;
80101709:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010170c:	0f b7 55 e4          	movzwl -0x1c(%ebp),%edx
80101710:	66 89 10             	mov    %dx,(%eax)
      log_write(bp);   // mark it allocated on the disk
80101713:	83 ec 0c             	sub    $0xc,%esp
80101716:	ff 75 f0             	pushl  -0x10(%ebp)
80101719:	e8 4c 20 00 00       	call   8010376a <log_write>
8010171e:	83 c4 10             	add    $0x10,%esp
      brelse(bp);
80101721:	83 ec 0c             	sub    $0xc,%esp
80101724:	ff 75 f0             	pushl  -0x10(%ebp)
80101727:	e8 02 eb ff ff       	call   8010022e <brelse>
8010172c:	83 c4 10             	add    $0x10,%esp
      return iget(dev, inum);
8010172f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101732:	83 ec 08             	sub    $0x8,%esp
80101735:	50                   	push   %eax
80101736:	ff 75 08             	pushl  0x8(%ebp)
80101739:	e8 f8 00 00 00       	call   80101836 <iget>
8010173e:	83 c4 10             	add    $0x10,%esp
80101741:	eb 30                	jmp    80101773 <ialloc+0xd5>
    }
    brelse(bp);
80101743:	83 ec 0c             	sub    $0xc,%esp
80101746:	ff 75 f0             	pushl  -0x10(%ebp)
80101749:	e8 e0 ea ff ff       	call   8010022e <brelse>
8010174e:	83 c4 10             	add    $0x10,%esp
{
  int inum;
  struct buf *bp;
  struct dinode *dip;

  for(inum = 1; inum < sb.ninodes; inum++){
80101751:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101755:	8b 15 48 12 11 80    	mov    0x80111248,%edx
8010175b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010175e:	39 c2                	cmp    %eax,%edx
80101760:	0f 87 51 ff ff ff    	ja     801016b7 <ialloc+0x19>
      brelse(bp);
      return iget(dev, inum);
    }
    brelse(bp);
  }
  panic("ialloc: no inodes");
80101766:	83 ec 0c             	sub    $0xc,%esp
80101769:	68 93 88 10 80       	push   $0x80108893
8010176e:	e8 f3 ed ff ff       	call   80100566 <panic>
}
80101773:	c9                   	leave  
80101774:	c3                   	ret    

80101775 <iupdate>:

// Copy a modified in-memory inode to disk.
void
iupdate(struct inode *ip)
{
80101775:	55                   	push   %ebp
80101776:	89 e5                	mov    %esp,%ebp
80101778:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
8010177b:	8b 45 08             	mov    0x8(%ebp),%eax
8010177e:	8b 40 04             	mov    0x4(%eax),%eax
80101781:	c1 e8 03             	shr    $0x3,%eax
80101784:	89 c2                	mov    %eax,%edx
80101786:	a1 54 12 11 80       	mov    0x80111254,%eax
8010178b:	01 c2                	add    %eax,%edx
8010178d:	8b 45 08             	mov    0x8(%ebp),%eax
80101790:	8b 00                	mov    (%eax),%eax
80101792:	83 ec 08             	sub    $0x8,%esp
80101795:	52                   	push   %edx
80101796:	50                   	push   %eax
80101797:	e8 1a ea ff ff       	call   801001b6 <bread>
8010179c:	83 c4 10             	add    $0x10,%esp
8010179f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  dip = (struct dinode*)bp->data + ip->inum%IPB;
801017a2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801017a5:	8d 50 18             	lea    0x18(%eax),%edx
801017a8:	8b 45 08             	mov    0x8(%ebp),%eax
801017ab:	8b 40 04             	mov    0x4(%eax),%eax
801017ae:	83 e0 07             	and    $0x7,%eax
801017b1:	c1 e0 06             	shl    $0x6,%eax
801017b4:	01 d0                	add    %edx,%eax
801017b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
  dip->type = ip->type;
801017b9:	8b 45 08             	mov    0x8(%ebp),%eax
801017bc:	0f b7 50 10          	movzwl 0x10(%eax),%edx
801017c0:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017c3:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
801017c6:	8b 45 08             	mov    0x8(%ebp),%eax
801017c9:	0f b7 50 12          	movzwl 0x12(%eax),%edx
801017cd:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017d0:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
801017d4:	8b 45 08             	mov    0x8(%ebp),%eax
801017d7:	0f b7 50 14          	movzwl 0x14(%eax),%edx
801017db:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017de:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
801017e2:	8b 45 08             	mov    0x8(%ebp),%eax
801017e5:	0f b7 50 16          	movzwl 0x16(%eax),%edx
801017e9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017ec:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
801017f0:	8b 45 08             	mov    0x8(%ebp),%eax
801017f3:	8b 50 18             	mov    0x18(%eax),%edx
801017f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801017f9:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
801017fc:	8b 45 08             	mov    0x8(%ebp),%eax
801017ff:	8d 50 1c             	lea    0x1c(%eax),%edx
80101802:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101805:	83 c0 0c             	add    $0xc,%eax
80101808:	83 ec 04             	sub    $0x4,%esp
8010180b:	6a 34                	push   $0x34
8010180d:	52                   	push   %edx
8010180e:	50                   	push   %eax
8010180f:	e8 b5 3c 00 00       	call   801054c9 <memmove>
80101814:	83 c4 10             	add    $0x10,%esp
  log_write(bp);
80101817:	83 ec 0c             	sub    $0xc,%esp
8010181a:	ff 75 f4             	pushl  -0xc(%ebp)
8010181d:	e8 48 1f 00 00       	call   8010376a <log_write>
80101822:	83 c4 10             	add    $0x10,%esp
  brelse(bp);
80101825:	83 ec 0c             	sub    $0xc,%esp
80101828:	ff 75 f4             	pushl  -0xc(%ebp)
8010182b:	e8 fe e9 ff ff       	call   8010022e <brelse>
80101830:	83 c4 10             	add    $0x10,%esp
}
80101833:	90                   	nop
80101834:	c9                   	leave  
80101835:	c3                   	ret    

80101836 <iget>:
// Find the inode with number inum on device dev
// and return the in-memory copy. Does not lock
// the inode and does not read it from disk.
static struct inode*
iget(uint dev, uint inum)
{
80101836:	55                   	push   %ebp
80101837:	89 e5                	mov    %esp,%ebp
80101839:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *empty;

  acquire(&icache.lock);
8010183c:	83 ec 0c             	sub    $0xc,%esp
8010183f:	68 60 12 11 80       	push   $0x80111260
80101844:	e8 5e 39 00 00       	call   801051a7 <acquire>
80101849:	83 c4 10             	add    $0x10,%esp

  // Is the inode already cached?
  empty = 0;
8010184c:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
80101853:	c7 45 f4 94 12 11 80 	movl   $0x80111294,-0xc(%ebp)
8010185a:	eb 5d                	jmp    801018b9 <iget+0x83>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
8010185c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010185f:	8b 40 08             	mov    0x8(%eax),%eax
80101862:	85 c0                	test   %eax,%eax
80101864:	7e 39                	jle    8010189f <iget+0x69>
80101866:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101869:	8b 00                	mov    (%eax),%eax
8010186b:	3b 45 08             	cmp    0x8(%ebp),%eax
8010186e:	75 2f                	jne    8010189f <iget+0x69>
80101870:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101873:	8b 40 04             	mov    0x4(%eax),%eax
80101876:	3b 45 0c             	cmp    0xc(%ebp),%eax
80101879:	75 24                	jne    8010189f <iget+0x69>
      ip->ref++;
8010187b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010187e:	8b 40 08             	mov    0x8(%eax),%eax
80101881:	8d 50 01             	lea    0x1(%eax),%edx
80101884:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101887:	89 50 08             	mov    %edx,0x8(%eax)
      release(&icache.lock);
8010188a:	83 ec 0c             	sub    $0xc,%esp
8010188d:	68 60 12 11 80       	push   $0x80111260
80101892:	e8 77 39 00 00       	call   8010520e <release>
80101897:	83 c4 10             	add    $0x10,%esp
      return ip;
8010189a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010189d:	eb 74                	jmp    80101913 <iget+0xdd>
    }
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
8010189f:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018a3:	75 10                	jne    801018b5 <iget+0x7f>
801018a5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018a8:	8b 40 08             	mov    0x8(%eax),%eax
801018ab:	85 c0                	test   %eax,%eax
801018ad:	75 06                	jne    801018b5 <iget+0x7f>
      empty = ip;
801018af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018b2:	89 45 f0             	mov    %eax,-0x10(%ebp)

  acquire(&icache.lock);

  // Is the inode already cached?
  empty = 0;
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801018b5:	83 45 f4 50          	addl   $0x50,-0xc(%ebp)
801018b9:	81 7d f4 34 22 11 80 	cmpl   $0x80112234,-0xc(%ebp)
801018c0:	72 9a                	jb     8010185c <iget+0x26>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
      empty = ip;
  }

  // Recycle an inode cache entry.
  if(empty == 0)
801018c2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801018c6:	75 0d                	jne    801018d5 <iget+0x9f>
    panic("iget: no inodes");
801018c8:	83 ec 0c             	sub    $0xc,%esp
801018cb:	68 a5 88 10 80       	push   $0x801088a5
801018d0:	e8 91 ec ff ff       	call   80100566 <panic>

  ip = empty;
801018d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801018d8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  ip->dev = dev;
801018db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018de:	8b 55 08             	mov    0x8(%ebp),%edx
801018e1:	89 10                	mov    %edx,(%eax)
  ip->inum = inum;
801018e3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018e6:	8b 55 0c             	mov    0xc(%ebp),%edx
801018e9:	89 50 04             	mov    %edx,0x4(%eax)
  ip->ref = 1;
801018ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018ef:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)
  ip->flags = 0;
801018f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801018f9:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  release(&icache.lock);
80101900:	83 ec 0c             	sub    $0xc,%esp
80101903:	68 60 12 11 80       	push   $0x80111260
80101908:	e8 01 39 00 00       	call   8010520e <release>
8010190d:	83 c4 10             	add    $0x10,%esp

  return ip;
80101910:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80101913:	c9                   	leave  
80101914:	c3                   	ret    

80101915 <idup>:

// Increment reference count for ip.
// Returns ip to enable ip = idup(ip1) idiom.
struct inode*
idup(struct inode *ip)
{
80101915:	55                   	push   %ebp
80101916:	89 e5                	mov    %esp,%ebp
80101918:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
8010191b:	83 ec 0c             	sub    $0xc,%esp
8010191e:	68 60 12 11 80       	push   $0x80111260
80101923:	e8 7f 38 00 00       	call   801051a7 <acquire>
80101928:	83 c4 10             	add    $0x10,%esp
  ip->ref++;
8010192b:	8b 45 08             	mov    0x8(%ebp),%eax
8010192e:	8b 40 08             	mov    0x8(%eax),%eax
80101931:	8d 50 01             	lea    0x1(%eax),%edx
80101934:	8b 45 08             	mov    0x8(%ebp),%eax
80101937:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
8010193a:	83 ec 0c             	sub    $0xc,%esp
8010193d:	68 60 12 11 80       	push   $0x80111260
80101942:	e8 c7 38 00 00       	call   8010520e <release>
80101947:	83 c4 10             	add    $0x10,%esp
  return ip;
8010194a:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010194d:	c9                   	leave  
8010194e:	c3                   	ret    

8010194f <ilock>:

// Lock the given inode.
// Reads the inode from disk if necessary.
void
ilock(struct inode *ip)
{
8010194f:	55                   	push   %ebp
80101950:	89 e5                	mov    %esp,%ebp
80101952:	83 ec 18             	sub    $0x18,%esp
  struct buf *bp;
  struct dinode *dip;

  if(ip == 0 || ip->ref < 1)
80101955:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101959:	74 0a                	je     80101965 <ilock+0x16>
8010195b:	8b 45 08             	mov    0x8(%ebp),%eax
8010195e:	8b 40 08             	mov    0x8(%eax),%eax
80101961:	85 c0                	test   %eax,%eax
80101963:	7f 0d                	jg     80101972 <ilock+0x23>
    panic("ilock");
80101965:	83 ec 0c             	sub    $0xc,%esp
80101968:	68 b5 88 10 80       	push   $0x801088b5
8010196d:	e8 f4 eb ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101972:	83 ec 0c             	sub    $0xc,%esp
80101975:	68 60 12 11 80       	push   $0x80111260
8010197a:	e8 28 38 00 00       	call   801051a7 <acquire>
8010197f:	83 c4 10             	add    $0x10,%esp
  while(ip->flags & I_BUSY)
80101982:	eb 13                	jmp    80101997 <ilock+0x48>
    sleep(ip, &icache.lock);
80101984:	83 ec 08             	sub    $0x8,%esp
80101987:	68 60 12 11 80       	push   $0x80111260
8010198c:	ff 75 08             	pushl  0x8(%ebp)
8010198f:	e8 11 35 00 00       	call   80104ea5 <sleep>
80101994:	83 c4 10             	add    $0x10,%esp

  if(ip == 0 || ip->ref < 1)
    panic("ilock");

  acquire(&icache.lock);
  while(ip->flags & I_BUSY)
80101997:	8b 45 08             	mov    0x8(%ebp),%eax
8010199a:	8b 40 0c             	mov    0xc(%eax),%eax
8010199d:	83 e0 01             	and    $0x1,%eax
801019a0:	85 c0                	test   %eax,%eax
801019a2:	75 e0                	jne    80101984 <ilock+0x35>
    sleep(ip, &icache.lock);
  ip->flags |= I_BUSY;
801019a4:	8b 45 08             	mov    0x8(%ebp),%eax
801019a7:	8b 40 0c             	mov    0xc(%eax),%eax
801019aa:	83 c8 01             	or     $0x1,%eax
801019ad:	89 c2                	mov    %eax,%edx
801019af:	8b 45 08             	mov    0x8(%ebp),%eax
801019b2:	89 50 0c             	mov    %edx,0xc(%eax)
  release(&icache.lock);
801019b5:	83 ec 0c             	sub    $0xc,%esp
801019b8:	68 60 12 11 80       	push   $0x80111260
801019bd:	e8 4c 38 00 00       	call   8010520e <release>
801019c2:	83 c4 10             	add    $0x10,%esp

  if(!(ip->flags & I_VALID)){
801019c5:	8b 45 08             	mov    0x8(%ebp),%eax
801019c8:	8b 40 0c             	mov    0xc(%eax),%eax
801019cb:	83 e0 02             	and    $0x2,%eax
801019ce:	85 c0                	test   %eax,%eax
801019d0:	0f 85 d4 00 00 00    	jne    80101aaa <ilock+0x15b>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801019d6:	8b 45 08             	mov    0x8(%ebp),%eax
801019d9:	8b 40 04             	mov    0x4(%eax),%eax
801019dc:	c1 e8 03             	shr    $0x3,%eax
801019df:	89 c2                	mov    %eax,%edx
801019e1:	a1 54 12 11 80       	mov    0x80111254,%eax
801019e6:	01 c2                	add    %eax,%edx
801019e8:	8b 45 08             	mov    0x8(%ebp),%eax
801019eb:	8b 00                	mov    (%eax),%eax
801019ed:	83 ec 08             	sub    $0x8,%esp
801019f0:	52                   	push   %edx
801019f1:	50                   	push   %eax
801019f2:	e8 bf e7 ff ff       	call   801001b6 <bread>
801019f7:	83 c4 10             	add    $0x10,%esp
801019fa:	89 45 f4             	mov    %eax,-0xc(%ebp)
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801019fd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101a00:	8d 50 18             	lea    0x18(%eax),%edx
80101a03:	8b 45 08             	mov    0x8(%ebp),%eax
80101a06:	8b 40 04             	mov    0x4(%eax),%eax
80101a09:	83 e0 07             	and    $0x7,%eax
80101a0c:	c1 e0 06             	shl    $0x6,%eax
80101a0f:	01 d0                	add    %edx,%eax
80101a11:	89 45 f0             	mov    %eax,-0x10(%ebp)
    ip->type = dip->type;
80101a14:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a17:	0f b7 10             	movzwl (%eax),%edx
80101a1a:	8b 45 08             	mov    0x8(%ebp),%eax
80101a1d:	66 89 50 10          	mov    %dx,0x10(%eax)
    ip->major = dip->major;
80101a21:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a24:	0f b7 50 02          	movzwl 0x2(%eax),%edx
80101a28:	8b 45 08             	mov    0x8(%ebp),%eax
80101a2b:	66 89 50 12          	mov    %dx,0x12(%eax)
    ip->minor = dip->minor;
80101a2f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a32:	0f b7 50 04          	movzwl 0x4(%eax),%edx
80101a36:	8b 45 08             	mov    0x8(%ebp),%eax
80101a39:	66 89 50 14          	mov    %dx,0x14(%eax)
    ip->nlink = dip->nlink;
80101a3d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a40:	0f b7 50 06          	movzwl 0x6(%eax),%edx
80101a44:	8b 45 08             	mov    0x8(%ebp),%eax
80101a47:	66 89 50 16          	mov    %dx,0x16(%eax)
    ip->size = dip->size;
80101a4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a4e:	8b 50 08             	mov    0x8(%eax),%edx
80101a51:	8b 45 08             	mov    0x8(%ebp),%eax
80101a54:	89 50 18             	mov    %edx,0x18(%eax)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101a57:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101a5a:	8d 50 0c             	lea    0xc(%eax),%edx
80101a5d:	8b 45 08             	mov    0x8(%ebp),%eax
80101a60:	83 c0 1c             	add    $0x1c,%eax
80101a63:	83 ec 04             	sub    $0x4,%esp
80101a66:	6a 34                	push   $0x34
80101a68:	52                   	push   %edx
80101a69:	50                   	push   %eax
80101a6a:	e8 5a 3a 00 00       	call   801054c9 <memmove>
80101a6f:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101a72:	83 ec 0c             	sub    $0xc,%esp
80101a75:	ff 75 f4             	pushl  -0xc(%ebp)
80101a78:	e8 b1 e7 ff ff       	call   8010022e <brelse>
80101a7d:	83 c4 10             	add    $0x10,%esp
    ip->flags |= I_VALID;
80101a80:	8b 45 08             	mov    0x8(%ebp),%eax
80101a83:	8b 40 0c             	mov    0xc(%eax),%eax
80101a86:	83 c8 02             	or     $0x2,%eax
80101a89:	89 c2                	mov    %eax,%edx
80101a8b:	8b 45 08             	mov    0x8(%ebp),%eax
80101a8e:	89 50 0c             	mov    %edx,0xc(%eax)
    if(ip->type == 0)
80101a91:	8b 45 08             	mov    0x8(%ebp),%eax
80101a94:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101a98:	66 85 c0             	test   %ax,%ax
80101a9b:	75 0d                	jne    80101aaa <ilock+0x15b>
      panic("ilock: no type");
80101a9d:	83 ec 0c             	sub    $0xc,%esp
80101aa0:	68 bb 88 10 80       	push   $0x801088bb
80101aa5:	e8 bc ea ff ff       	call   80100566 <panic>
  }
}
80101aaa:	90                   	nop
80101aab:	c9                   	leave  
80101aac:	c3                   	ret    

80101aad <iunlock>:

// Unlock the given inode.
void
iunlock(struct inode *ip)
{
80101aad:	55                   	push   %ebp
80101aae:	89 e5                	mov    %esp,%ebp
80101ab0:	83 ec 08             	sub    $0x8,%esp
  if(ip == 0 || !(ip->flags & I_BUSY) || ip->ref < 1)
80101ab3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80101ab7:	74 17                	je     80101ad0 <iunlock+0x23>
80101ab9:	8b 45 08             	mov    0x8(%ebp),%eax
80101abc:	8b 40 0c             	mov    0xc(%eax),%eax
80101abf:	83 e0 01             	and    $0x1,%eax
80101ac2:	85 c0                	test   %eax,%eax
80101ac4:	74 0a                	je     80101ad0 <iunlock+0x23>
80101ac6:	8b 45 08             	mov    0x8(%ebp),%eax
80101ac9:	8b 40 08             	mov    0x8(%eax),%eax
80101acc:	85 c0                	test   %eax,%eax
80101ace:	7f 0d                	jg     80101add <iunlock+0x30>
    panic("iunlock");
80101ad0:	83 ec 0c             	sub    $0xc,%esp
80101ad3:	68 ca 88 10 80       	push   $0x801088ca
80101ad8:	e8 89 ea ff ff       	call   80100566 <panic>

  acquire(&icache.lock);
80101add:	83 ec 0c             	sub    $0xc,%esp
80101ae0:	68 60 12 11 80       	push   $0x80111260
80101ae5:	e8 bd 36 00 00       	call   801051a7 <acquire>
80101aea:	83 c4 10             	add    $0x10,%esp
  ip->flags &= ~I_BUSY;
80101aed:	8b 45 08             	mov    0x8(%ebp),%eax
80101af0:	8b 40 0c             	mov    0xc(%eax),%eax
80101af3:	83 e0 fe             	and    $0xfffffffe,%eax
80101af6:	89 c2                	mov    %eax,%edx
80101af8:	8b 45 08             	mov    0x8(%ebp),%eax
80101afb:	89 50 0c             	mov    %edx,0xc(%eax)
  wakeup(ip);
80101afe:	83 ec 0c             	sub    $0xc,%esp
80101b01:	ff 75 08             	pushl  0x8(%ebp)
80101b04:	e8 8a 34 00 00       	call   80104f93 <wakeup>
80101b09:	83 c4 10             	add    $0x10,%esp
  release(&icache.lock);
80101b0c:	83 ec 0c             	sub    $0xc,%esp
80101b0f:	68 60 12 11 80       	push   $0x80111260
80101b14:	e8 f5 36 00 00       	call   8010520e <release>
80101b19:	83 c4 10             	add    $0x10,%esp
}
80101b1c:	90                   	nop
80101b1d:	c9                   	leave  
80101b1e:	c3                   	ret    

80101b1f <iput>:
// to it, free the inode (and its content) on disk.
// All calls to iput() must be inside a transaction in
// case it has to free the inode.
void
iput(struct inode *ip)
{
80101b1f:	55                   	push   %ebp
80101b20:	89 e5                	mov    %esp,%ebp
80101b22:	83 ec 08             	sub    $0x8,%esp
  acquire(&icache.lock);
80101b25:	83 ec 0c             	sub    $0xc,%esp
80101b28:	68 60 12 11 80       	push   $0x80111260
80101b2d:	e8 75 36 00 00       	call   801051a7 <acquire>
80101b32:	83 c4 10             	add    $0x10,%esp
  if(ip->ref == 1 && (ip->flags & I_VALID) && ip->nlink == 0){
80101b35:	8b 45 08             	mov    0x8(%ebp),%eax
80101b38:	8b 40 08             	mov    0x8(%eax),%eax
80101b3b:	83 f8 01             	cmp    $0x1,%eax
80101b3e:	0f 85 a9 00 00 00    	jne    80101bed <iput+0xce>
80101b44:	8b 45 08             	mov    0x8(%ebp),%eax
80101b47:	8b 40 0c             	mov    0xc(%eax),%eax
80101b4a:	83 e0 02             	and    $0x2,%eax
80101b4d:	85 c0                	test   %eax,%eax
80101b4f:	0f 84 98 00 00 00    	je     80101bed <iput+0xce>
80101b55:	8b 45 08             	mov    0x8(%ebp),%eax
80101b58:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80101b5c:	66 85 c0             	test   %ax,%ax
80101b5f:	0f 85 88 00 00 00    	jne    80101bed <iput+0xce>
    // inode has no links and no other references: truncate and free.
    if(ip->flags & I_BUSY)
80101b65:	8b 45 08             	mov    0x8(%ebp),%eax
80101b68:	8b 40 0c             	mov    0xc(%eax),%eax
80101b6b:	83 e0 01             	and    $0x1,%eax
80101b6e:	85 c0                	test   %eax,%eax
80101b70:	74 0d                	je     80101b7f <iput+0x60>
      panic("iput busy");
80101b72:	83 ec 0c             	sub    $0xc,%esp
80101b75:	68 d2 88 10 80       	push   $0x801088d2
80101b7a:	e8 e7 e9 ff ff       	call   80100566 <panic>
    ip->flags |= I_BUSY;
80101b7f:	8b 45 08             	mov    0x8(%ebp),%eax
80101b82:	8b 40 0c             	mov    0xc(%eax),%eax
80101b85:	83 c8 01             	or     $0x1,%eax
80101b88:	89 c2                	mov    %eax,%edx
80101b8a:	8b 45 08             	mov    0x8(%ebp),%eax
80101b8d:	89 50 0c             	mov    %edx,0xc(%eax)
    release(&icache.lock);
80101b90:	83 ec 0c             	sub    $0xc,%esp
80101b93:	68 60 12 11 80       	push   $0x80111260
80101b98:	e8 71 36 00 00       	call   8010520e <release>
80101b9d:	83 c4 10             	add    $0x10,%esp
    itrunc(ip);
80101ba0:	83 ec 0c             	sub    $0xc,%esp
80101ba3:	ff 75 08             	pushl  0x8(%ebp)
80101ba6:	e8 a8 01 00 00       	call   80101d53 <itrunc>
80101bab:	83 c4 10             	add    $0x10,%esp
    ip->type = 0;
80101bae:	8b 45 08             	mov    0x8(%ebp),%eax
80101bb1:	66 c7 40 10 00 00    	movw   $0x0,0x10(%eax)
    iupdate(ip);
80101bb7:	83 ec 0c             	sub    $0xc,%esp
80101bba:	ff 75 08             	pushl  0x8(%ebp)
80101bbd:	e8 b3 fb ff ff       	call   80101775 <iupdate>
80101bc2:	83 c4 10             	add    $0x10,%esp
    acquire(&icache.lock);
80101bc5:	83 ec 0c             	sub    $0xc,%esp
80101bc8:	68 60 12 11 80       	push   $0x80111260
80101bcd:	e8 d5 35 00 00       	call   801051a7 <acquire>
80101bd2:	83 c4 10             	add    $0x10,%esp
    ip->flags = 0;
80101bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80101bd8:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    wakeup(ip);
80101bdf:	83 ec 0c             	sub    $0xc,%esp
80101be2:	ff 75 08             	pushl  0x8(%ebp)
80101be5:	e8 a9 33 00 00       	call   80104f93 <wakeup>
80101bea:	83 c4 10             	add    $0x10,%esp
  }
  ip->ref--;
80101bed:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf0:	8b 40 08             	mov    0x8(%eax),%eax
80101bf3:	8d 50 ff             	lea    -0x1(%eax),%edx
80101bf6:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf9:	89 50 08             	mov    %edx,0x8(%eax)
  release(&icache.lock);
80101bfc:	83 ec 0c             	sub    $0xc,%esp
80101bff:	68 60 12 11 80       	push   $0x80111260
80101c04:	e8 05 36 00 00       	call   8010520e <release>
80101c09:	83 c4 10             	add    $0x10,%esp
}
80101c0c:	90                   	nop
80101c0d:	c9                   	leave  
80101c0e:	c3                   	ret    

80101c0f <iunlockput>:

// Common idiom: unlock, then put.
void
iunlockput(struct inode *ip)
{
80101c0f:	55                   	push   %ebp
80101c10:	89 e5                	mov    %esp,%ebp
80101c12:	83 ec 08             	sub    $0x8,%esp
  iunlock(ip);
80101c15:	83 ec 0c             	sub    $0xc,%esp
80101c18:	ff 75 08             	pushl  0x8(%ebp)
80101c1b:	e8 8d fe ff ff       	call   80101aad <iunlock>
80101c20:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80101c23:	83 ec 0c             	sub    $0xc,%esp
80101c26:	ff 75 08             	pushl  0x8(%ebp)
80101c29:	e8 f1 fe ff ff       	call   80101b1f <iput>
80101c2e:	83 c4 10             	add    $0x10,%esp
}
80101c31:	90                   	nop
80101c32:	c9                   	leave  
80101c33:	c3                   	ret    

80101c34 <bmap>:

// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
static uint
bmap(struct inode *ip, uint bn)
{
80101c34:	55                   	push   %ebp
80101c35:	89 e5                	mov    %esp,%ebp
80101c37:	53                   	push   %ebx
80101c38:	83 ec 14             	sub    $0x14,%esp
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
80101c3b:	83 7d 0c 0b          	cmpl   $0xb,0xc(%ebp)
80101c3f:	77 42                	ja     80101c83 <bmap+0x4f>
    if((addr = ip->addrs[bn]) == 0)
80101c41:	8b 45 08             	mov    0x8(%ebp),%eax
80101c44:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c47:	83 c2 04             	add    $0x4,%edx
80101c4a:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101c4e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c51:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c55:	75 24                	jne    80101c7b <bmap+0x47>
      ip->addrs[bn] = addr = balloc(ip->dev);
80101c57:	8b 45 08             	mov    0x8(%ebp),%eax
80101c5a:	8b 00                	mov    (%eax),%eax
80101c5c:	83 ec 0c             	sub    $0xc,%esp
80101c5f:	50                   	push   %eax
80101c60:	e8 9a f7 ff ff       	call   801013ff <balloc>
80101c65:	83 c4 10             	add    $0x10,%esp
80101c68:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c6b:	8b 45 08             	mov    0x8(%ebp),%eax
80101c6e:	8b 55 0c             	mov    0xc(%ebp),%edx
80101c71:	8d 4a 04             	lea    0x4(%edx),%ecx
80101c74:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101c77:	89 54 88 0c          	mov    %edx,0xc(%eax,%ecx,4)
    return addr;
80101c7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101c7e:	e9 cb 00 00 00       	jmp    80101d4e <bmap+0x11a>
  }
  bn -= NDIRECT;
80101c83:	83 6d 0c 0c          	subl   $0xc,0xc(%ebp)

  if(bn < NINDIRECT){
80101c87:	83 7d 0c 7f          	cmpl   $0x7f,0xc(%ebp)
80101c8b:	0f 87 b0 00 00 00    	ja     80101d41 <bmap+0x10d>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0)
80101c91:	8b 45 08             	mov    0x8(%ebp),%eax
80101c94:	8b 40 4c             	mov    0x4c(%eax),%eax
80101c97:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101c9a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101c9e:	75 1d                	jne    80101cbd <bmap+0x89>
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
80101ca0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ca3:	8b 00                	mov    (%eax),%eax
80101ca5:	83 ec 0c             	sub    $0xc,%esp
80101ca8:	50                   	push   %eax
80101ca9:	e8 51 f7 ff ff       	call   801013ff <balloc>
80101cae:	83 c4 10             	add    $0x10,%esp
80101cb1:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cb4:	8b 45 08             	mov    0x8(%ebp),%eax
80101cb7:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101cba:	89 50 4c             	mov    %edx,0x4c(%eax)
    bp = bread(ip->dev, addr);
80101cbd:	8b 45 08             	mov    0x8(%ebp),%eax
80101cc0:	8b 00                	mov    (%eax),%eax
80101cc2:	83 ec 08             	sub    $0x8,%esp
80101cc5:	ff 75 f4             	pushl  -0xc(%ebp)
80101cc8:	50                   	push   %eax
80101cc9:	e8 e8 e4 ff ff       	call   801001b6 <bread>
80101cce:	83 c4 10             	add    $0x10,%esp
80101cd1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    a = (uint*)bp->data;
80101cd4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101cd7:	83 c0 18             	add    $0x18,%eax
80101cda:	89 45 ec             	mov    %eax,-0x14(%ebp)
    if((addr = a[bn]) == 0){
80101cdd:	8b 45 0c             	mov    0xc(%ebp),%eax
80101ce0:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101ce7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101cea:	01 d0                	add    %edx,%eax
80101cec:	8b 00                	mov    (%eax),%eax
80101cee:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101cf1:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80101cf5:	75 37                	jne    80101d2e <bmap+0xfa>
      a[bn] = addr = balloc(ip->dev);
80101cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101cfa:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101d01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101d04:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
80101d07:	8b 45 08             	mov    0x8(%ebp),%eax
80101d0a:	8b 00                	mov    (%eax),%eax
80101d0c:	83 ec 0c             	sub    $0xc,%esp
80101d0f:	50                   	push   %eax
80101d10:	e8 ea f6 ff ff       	call   801013ff <balloc>
80101d15:	83 c4 10             	add    $0x10,%esp
80101d18:	89 45 f4             	mov    %eax,-0xc(%ebp)
80101d1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d1e:	89 03                	mov    %eax,(%ebx)
      log_write(bp);
80101d20:	83 ec 0c             	sub    $0xc,%esp
80101d23:	ff 75 f0             	pushl  -0x10(%ebp)
80101d26:	e8 3f 1a 00 00       	call   8010376a <log_write>
80101d2b:	83 c4 10             	add    $0x10,%esp
    }
    brelse(bp);
80101d2e:	83 ec 0c             	sub    $0xc,%esp
80101d31:	ff 75 f0             	pushl  -0x10(%ebp)
80101d34:	e8 f5 e4 ff ff       	call   8010022e <brelse>
80101d39:	83 c4 10             	add    $0x10,%esp
    return addr;
80101d3c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80101d3f:	eb 0d                	jmp    80101d4e <bmap+0x11a>
  }

  panic("bmap: out of range");
80101d41:	83 ec 0c             	sub    $0xc,%esp
80101d44:	68 dc 88 10 80       	push   $0x801088dc
80101d49:	e8 18 e8 ff ff       	call   80100566 <panic>
}
80101d4e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101d51:	c9                   	leave  
80101d52:	c3                   	ret    

80101d53 <itrunc>:
// to it (no directory entries referring to it)
// and has no in-memory reference to it (is
// not an open file or current directory).
static void
itrunc(struct inode *ip)
{
80101d53:	55                   	push   %ebp
80101d54:	89 e5                	mov    %esp,%ebp
80101d56:	83 ec 18             	sub    $0x18,%esp
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101d59:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101d60:	eb 45                	jmp    80101da7 <itrunc+0x54>
    if(ip->addrs[i]){
80101d62:	8b 45 08             	mov    0x8(%ebp),%eax
80101d65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d68:	83 c2 04             	add    $0x4,%edx
80101d6b:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d6f:	85 c0                	test   %eax,%eax
80101d71:	74 30                	je     80101da3 <itrunc+0x50>
      bfree(ip->dev, ip->addrs[i]);
80101d73:	8b 45 08             	mov    0x8(%ebp),%eax
80101d76:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d79:	83 c2 04             	add    $0x4,%edx
80101d7c:	8b 44 90 0c          	mov    0xc(%eax,%edx,4),%eax
80101d80:	8b 55 08             	mov    0x8(%ebp),%edx
80101d83:	8b 12                	mov    (%edx),%edx
80101d85:	83 ec 08             	sub    $0x8,%esp
80101d88:	50                   	push   %eax
80101d89:	52                   	push   %edx
80101d8a:	e8 bc f7 ff ff       	call   8010154b <bfree>
80101d8f:	83 c4 10             	add    $0x10,%esp
      ip->addrs[i] = 0;
80101d92:	8b 45 08             	mov    0x8(%ebp),%eax
80101d95:	8b 55 f4             	mov    -0xc(%ebp),%edx
80101d98:	83 c2 04             	add    $0x4,%edx
80101d9b:	c7 44 90 0c 00 00 00 	movl   $0x0,0xc(%eax,%edx,4)
80101da2:	00 
{
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
80101da3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80101da7:	83 7d f4 0b          	cmpl   $0xb,-0xc(%ebp)
80101dab:	7e b5                	jle    80101d62 <itrunc+0xf>
      bfree(ip->dev, ip->addrs[i]);
      ip->addrs[i] = 0;
    }
  }
  
  if(ip->addrs[NDIRECT]){
80101dad:	8b 45 08             	mov    0x8(%ebp),%eax
80101db0:	8b 40 4c             	mov    0x4c(%eax),%eax
80101db3:	85 c0                	test   %eax,%eax
80101db5:	0f 84 a1 00 00 00    	je     80101e5c <itrunc+0x109>
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
80101dbb:	8b 45 08             	mov    0x8(%ebp),%eax
80101dbe:	8b 50 4c             	mov    0x4c(%eax),%edx
80101dc1:	8b 45 08             	mov    0x8(%ebp),%eax
80101dc4:	8b 00                	mov    (%eax),%eax
80101dc6:	83 ec 08             	sub    $0x8,%esp
80101dc9:	52                   	push   %edx
80101dca:	50                   	push   %eax
80101dcb:	e8 e6 e3 ff ff       	call   801001b6 <bread>
80101dd0:	83 c4 10             	add    $0x10,%esp
80101dd3:	89 45 ec             	mov    %eax,-0x14(%ebp)
    a = (uint*)bp->data;
80101dd6:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101dd9:	83 c0 18             	add    $0x18,%eax
80101ddc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    for(j = 0; j < NINDIRECT; j++){
80101ddf:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80101de6:	eb 3c                	jmp    80101e24 <itrunc+0xd1>
      if(a[j])
80101de8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101deb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101df2:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101df5:	01 d0                	add    %edx,%eax
80101df7:	8b 00                	mov    (%eax),%eax
80101df9:	85 c0                	test   %eax,%eax
80101dfb:	74 23                	je     80101e20 <itrunc+0xcd>
        bfree(ip->dev, a[j]);
80101dfd:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e00:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80101e07:	8b 45 e8             	mov    -0x18(%ebp),%eax
80101e0a:	01 d0                	add    %edx,%eax
80101e0c:	8b 00                	mov    (%eax),%eax
80101e0e:	8b 55 08             	mov    0x8(%ebp),%edx
80101e11:	8b 12                	mov    (%edx),%edx
80101e13:	83 ec 08             	sub    $0x8,%esp
80101e16:	50                   	push   %eax
80101e17:	52                   	push   %edx
80101e18:	e8 2e f7 ff ff       	call   8010154b <bfree>
80101e1d:	83 c4 10             	add    $0x10,%esp
  }
  
  if(ip->addrs[NDIRECT]){
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    a = (uint*)bp->data;
    for(j = 0; j < NINDIRECT; j++){
80101e20:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
80101e24:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101e27:	83 f8 7f             	cmp    $0x7f,%eax
80101e2a:	76 bc                	jbe    80101de8 <itrunc+0x95>
      if(a[j])
        bfree(ip->dev, a[j]);
    }
    brelse(bp);
80101e2c:	83 ec 0c             	sub    $0xc,%esp
80101e2f:	ff 75 ec             	pushl  -0x14(%ebp)
80101e32:	e8 f7 e3 ff ff       	call   8010022e <brelse>
80101e37:	83 c4 10             	add    $0x10,%esp
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101e3a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e3d:	8b 40 4c             	mov    0x4c(%eax),%eax
80101e40:	8b 55 08             	mov    0x8(%ebp),%edx
80101e43:	8b 12                	mov    (%edx),%edx
80101e45:	83 ec 08             	sub    $0x8,%esp
80101e48:	50                   	push   %eax
80101e49:	52                   	push   %edx
80101e4a:	e8 fc f6 ff ff       	call   8010154b <bfree>
80101e4f:	83 c4 10             	add    $0x10,%esp
    ip->addrs[NDIRECT] = 0;
80101e52:	8b 45 08             	mov    0x8(%ebp),%eax
80101e55:	c7 40 4c 00 00 00 00 	movl   $0x0,0x4c(%eax)
  }

  ip->size = 0;
80101e5c:	8b 45 08             	mov    0x8(%ebp),%eax
80101e5f:	c7 40 18 00 00 00 00 	movl   $0x0,0x18(%eax)
  iupdate(ip);
80101e66:	83 ec 0c             	sub    $0xc,%esp
80101e69:	ff 75 08             	pushl  0x8(%ebp)
80101e6c:	e8 04 f9 ff ff       	call   80101775 <iupdate>
80101e71:	83 c4 10             	add    $0x10,%esp
}
80101e74:	90                   	nop
80101e75:	c9                   	leave  
80101e76:	c3                   	ret    

80101e77 <stati>:

// Copy stat information from inode.
void
stati(struct inode *ip, struct stat *st)
{
80101e77:	55                   	push   %ebp
80101e78:	89 e5                	mov    %esp,%ebp
  st->dev = ip->dev;
80101e7a:	8b 45 08             	mov    0x8(%ebp),%eax
80101e7d:	8b 00                	mov    (%eax),%eax
80101e7f:	89 c2                	mov    %eax,%edx
80101e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e84:	89 50 04             	mov    %edx,0x4(%eax)
  st->ino = ip->inum;
80101e87:	8b 45 08             	mov    0x8(%ebp),%eax
80101e8a:	8b 50 04             	mov    0x4(%eax),%edx
80101e8d:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e90:	89 50 08             	mov    %edx,0x8(%eax)
  st->type = ip->type;
80101e93:	8b 45 08             	mov    0x8(%ebp),%eax
80101e96:	0f b7 50 10          	movzwl 0x10(%eax),%edx
80101e9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80101e9d:	66 89 10             	mov    %dx,(%eax)
  st->nlink = ip->nlink;
80101ea0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ea3:	0f b7 50 16          	movzwl 0x16(%eax),%edx
80101ea7:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eaa:	66 89 50 0c          	mov    %dx,0xc(%eax)
  st->size = ip->size;
80101eae:	8b 45 08             	mov    0x8(%ebp),%eax
80101eb1:	8b 50 18             	mov    0x18(%eax),%edx
80101eb4:	8b 45 0c             	mov    0xc(%ebp),%eax
80101eb7:	89 50 10             	mov    %edx,0x10(%eax)
}
80101eba:	90                   	nop
80101ebb:	5d                   	pop    %ebp
80101ebc:	c3                   	ret    

80101ebd <readi>:

//PAGEBREAK!
// Read data from inode.
int
readi(struct inode *ip, char *dst, uint off, uint n)
{
80101ebd:	55                   	push   %ebp
80101ebe:	89 e5                	mov    %esp,%ebp
80101ec0:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
80101ec3:	8b 45 08             	mov    0x8(%ebp),%eax
80101ec6:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80101eca:	66 83 f8 03          	cmp    $0x3,%ax
80101ece:	75 5c                	jne    80101f2c <readi+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
80101ed0:	8b 45 08             	mov    0x8(%ebp),%eax
80101ed3:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ed7:	66 85 c0             	test   %ax,%ax
80101eda:	78 20                	js     80101efc <readi+0x3f>
80101edc:	8b 45 08             	mov    0x8(%ebp),%eax
80101edf:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ee3:	66 83 f8 09          	cmp    $0x9,%ax
80101ee7:	7f 13                	jg     80101efc <readi+0x3f>
80101ee9:	8b 45 08             	mov    0x8(%ebp),%eax
80101eec:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101ef0:	98                   	cwtl   
80101ef1:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101ef8:	85 c0                	test   %eax,%eax
80101efa:	75 0a                	jne    80101f06 <readi+0x49>
      return -1;
80101efc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f01:	e9 0c 01 00 00       	jmp    80102012 <readi+0x155>
    return devsw[ip->major].read(ip, dst, n);
80101f06:	8b 45 08             	mov    0x8(%ebp),%eax
80101f09:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80101f0d:	98                   	cwtl   
80101f0e:	8b 04 c5 e0 11 11 80 	mov    -0x7feeee20(,%eax,8),%eax
80101f15:	8b 55 14             	mov    0x14(%ebp),%edx
80101f18:	83 ec 04             	sub    $0x4,%esp
80101f1b:	52                   	push   %edx
80101f1c:	ff 75 0c             	pushl  0xc(%ebp)
80101f1f:	ff 75 08             	pushl  0x8(%ebp)
80101f22:	ff d0                	call   *%eax
80101f24:	83 c4 10             	add    $0x10,%esp
80101f27:	e9 e6 00 00 00       	jmp    80102012 <readi+0x155>
  }

  if(off > ip->size || off + n < off)
80101f2c:	8b 45 08             	mov    0x8(%ebp),%eax
80101f2f:	8b 40 18             	mov    0x18(%eax),%eax
80101f32:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f35:	72 0d                	jb     80101f44 <readi+0x87>
80101f37:	8b 55 10             	mov    0x10(%ebp),%edx
80101f3a:	8b 45 14             	mov    0x14(%ebp),%eax
80101f3d:	01 d0                	add    %edx,%eax
80101f3f:	3b 45 10             	cmp    0x10(%ebp),%eax
80101f42:	73 0a                	jae    80101f4e <readi+0x91>
    return -1;
80101f44:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101f49:	e9 c4 00 00 00       	jmp    80102012 <readi+0x155>
  if(off + n > ip->size)
80101f4e:	8b 55 10             	mov    0x10(%ebp),%edx
80101f51:	8b 45 14             	mov    0x14(%ebp),%eax
80101f54:	01 c2                	add    %eax,%edx
80101f56:	8b 45 08             	mov    0x8(%ebp),%eax
80101f59:	8b 40 18             	mov    0x18(%eax),%eax
80101f5c:	39 c2                	cmp    %eax,%edx
80101f5e:	76 0c                	jbe    80101f6c <readi+0xaf>
    n = ip->size - off;
80101f60:	8b 45 08             	mov    0x8(%ebp),%eax
80101f63:	8b 40 18             	mov    0x18(%eax),%eax
80101f66:	2b 45 10             	sub    0x10(%ebp),%eax
80101f69:	89 45 14             	mov    %eax,0x14(%ebp)

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101f6c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80101f73:	e9 8b 00 00 00       	jmp    80102003 <readi+0x146>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
80101f78:	8b 45 10             	mov    0x10(%ebp),%eax
80101f7b:	c1 e8 09             	shr    $0x9,%eax
80101f7e:	83 ec 08             	sub    $0x8,%esp
80101f81:	50                   	push   %eax
80101f82:	ff 75 08             	pushl  0x8(%ebp)
80101f85:	e8 aa fc ff ff       	call   80101c34 <bmap>
80101f8a:	83 c4 10             	add    $0x10,%esp
80101f8d:	89 c2                	mov    %eax,%edx
80101f8f:	8b 45 08             	mov    0x8(%ebp),%eax
80101f92:	8b 00                	mov    (%eax),%eax
80101f94:	83 ec 08             	sub    $0x8,%esp
80101f97:	52                   	push   %edx
80101f98:	50                   	push   %eax
80101f99:	e8 18 e2 ff ff       	call   801001b6 <bread>
80101f9e:	83 c4 10             	add    $0x10,%esp
80101fa1:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
80101fa4:	8b 45 10             	mov    0x10(%ebp),%eax
80101fa7:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fac:	ba 00 02 00 00       	mov    $0x200,%edx
80101fb1:	29 c2                	sub    %eax,%edx
80101fb3:	8b 45 14             	mov    0x14(%ebp),%eax
80101fb6:	2b 45 f4             	sub    -0xc(%ebp),%eax
80101fb9:	39 c2                	cmp    %eax,%edx
80101fbb:	0f 46 c2             	cmovbe %edx,%eax
80101fbe:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dst, bp->data + off%BSIZE, m);
80101fc1:	8b 45 f0             	mov    -0x10(%ebp),%eax
80101fc4:	8d 50 18             	lea    0x18(%eax),%edx
80101fc7:	8b 45 10             	mov    0x10(%ebp),%eax
80101fca:	25 ff 01 00 00       	and    $0x1ff,%eax
80101fcf:	01 d0                	add    %edx,%eax
80101fd1:	83 ec 04             	sub    $0x4,%esp
80101fd4:	ff 75 ec             	pushl  -0x14(%ebp)
80101fd7:	50                   	push   %eax
80101fd8:	ff 75 0c             	pushl  0xc(%ebp)
80101fdb:	e8 e9 34 00 00       	call   801054c9 <memmove>
80101fe0:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80101fe3:	83 ec 0c             	sub    $0xc,%esp
80101fe6:	ff 75 f0             	pushl  -0x10(%ebp)
80101fe9:	e8 40 e2 ff ff       	call   8010022e <brelse>
80101fee:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > ip->size)
    n = ip->size - off;

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
80101ff1:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ff4:	01 45 f4             	add    %eax,-0xc(%ebp)
80101ff7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80101ffa:	01 45 10             	add    %eax,0x10(%ebp)
80101ffd:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102000:	01 45 0c             	add    %eax,0xc(%ebp)
80102003:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102006:	3b 45 14             	cmp    0x14(%ebp),%eax
80102009:	0f 82 69 ff ff ff    	jb     80101f78 <readi+0xbb>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
    m = min(n - tot, BSIZE - off%BSIZE);
    memmove(dst, bp->data + off%BSIZE, m);
    brelse(bp);
  }
  return n;
8010200f:	8b 45 14             	mov    0x14(%ebp),%eax
}
80102012:	c9                   	leave  
80102013:	c3                   	ret    

80102014 <writei>:

// PAGEBREAK!
// Write data to inode.
int
writei(struct inode *ip, char *src, uint off, uint n)
{
80102014:	55                   	push   %ebp
80102015:	89 e5                	mov    %esp,%ebp
80102017:	83 ec 18             	sub    $0x18,%esp
  uint tot, m;
  struct buf *bp;

  if(ip->type == T_DEV){
8010201a:	8b 45 08             	mov    0x8(%ebp),%eax
8010201d:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102021:	66 83 f8 03          	cmp    $0x3,%ax
80102025:	75 5c                	jne    80102083 <writei+0x6f>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
80102027:	8b 45 08             	mov    0x8(%ebp),%eax
8010202a:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010202e:	66 85 c0             	test   %ax,%ax
80102031:	78 20                	js     80102053 <writei+0x3f>
80102033:	8b 45 08             	mov    0x8(%ebp),%eax
80102036:	0f b7 40 12          	movzwl 0x12(%eax),%eax
8010203a:	66 83 f8 09          	cmp    $0x9,%ax
8010203e:	7f 13                	jg     80102053 <writei+0x3f>
80102040:	8b 45 08             	mov    0x8(%ebp),%eax
80102043:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102047:	98                   	cwtl   
80102048:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
8010204f:	85 c0                	test   %eax,%eax
80102051:	75 0a                	jne    8010205d <writei+0x49>
      return -1;
80102053:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102058:	e9 3d 01 00 00       	jmp    8010219a <writei+0x186>
    return devsw[ip->major].write(ip, src, n);
8010205d:	8b 45 08             	mov    0x8(%ebp),%eax
80102060:	0f b7 40 12          	movzwl 0x12(%eax),%eax
80102064:	98                   	cwtl   
80102065:	8b 04 c5 e4 11 11 80 	mov    -0x7feeee1c(,%eax,8),%eax
8010206c:	8b 55 14             	mov    0x14(%ebp),%edx
8010206f:	83 ec 04             	sub    $0x4,%esp
80102072:	52                   	push   %edx
80102073:	ff 75 0c             	pushl  0xc(%ebp)
80102076:	ff 75 08             	pushl  0x8(%ebp)
80102079:	ff d0                	call   *%eax
8010207b:	83 c4 10             	add    $0x10,%esp
8010207e:	e9 17 01 00 00       	jmp    8010219a <writei+0x186>
  }

  if(off > ip->size || off + n < off)
80102083:	8b 45 08             	mov    0x8(%ebp),%eax
80102086:	8b 40 18             	mov    0x18(%eax),%eax
80102089:	3b 45 10             	cmp    0x10(%ebp),%eax
8010208c:	72 0d                	jb     8010209b <writei+0x87>
8010208e:	8b 55 10             	mov    0x10(%ebp),%edx
80102091:	8b 45 14             	mov    0x14(%ebp),%eax
80102094:	01 d0                	add    %edx,%eax
80102096:	3b 45 10             	cmp    0x10(%ebp),%eax
80102099:	73 0a                	jae    801020a5 <writei+0x91>
    return -1;
8010209b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020a0:	e9 f5 00 00 00       	jmp    8010219a <writei+0x186>
  if(off + n > MAXFILE*BSIZE)
801020a5:	8b 55 10             	mov    0x10(%ebp),%edx
801020a8:	8b 45 14             	mov    0x14(%ebp),%eax
801020ab:	01 d0                	add    %edx,%eax
801020ad:	3d 00 18 01 00       	cmp    $0x11800,%eax
801020b2:	76 0a                	jbe    801020be <writei+0xaa>
    return -1;
801020b4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801020b9:	e9 dc 00 00 00       	jmp    8010219a <writei+0x186>

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801020be:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801020c5:	e9 99 00 00 00       	jmp    80102163 <writei+0x14f>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801020ca:	8b 45 10             	mov    0x10(%ebp),%eax
801020cd:	c1 e8 09             	shr    $0x9,%eax
801020d0:	83 ec 08             	sub    $0x8,%esp
801020d3:	50                   	push   %eax
801020d4:	ff 75 08             	pushl  0x8(%ebp)
801020d7:	e8 58 fb ff ff       	call   80101c34 <bmap>
801020dc:	83 c4 10             	add    $0x10,%esp
801020df:	89 c2                	mov    %eax,%edx
801020e1:	8b 45 08             	mov    0x8(%ebp),%eax
801020e4:	8b 00                	mov    (%eax),%eax
801020e6:	83 ec 08             	sub    $0x8,%esp
801020e9:	52                   	push   %edx
801020ea:	50                   	push   %eax
801020eb:	e8 c6 e0 ff ff       	call   801001b6 <bread>
801020f0:	83 c4 10             	add    $0x10,%esp
801020f3:	89 45 f0             	mov    %eax,-0x10(%ebp)
    m = min(n - tot, BSIZE - off%BSIZE);
801020f6:	8b 45 10             	mov    0x10(%ebp),%eax
801020f9:	25 ff 01 00 00       	and    $0x1ff,%eax
801020fe:	ba 00 02 00 00       	mov    $0x200,%edx
80102103:	29 c2                	sub    %eax,%edx
80102105:	8b 45 14             	mov    0x14(%ebp),%eax
80102108:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010210b:	39 c2                	cmp    %eax,%edx
8010210d:	0f 46 c2             	cmovbe %edx,%eax
80102110:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(bp->data + off%BSIZE, src, m);
80102113:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102116:	8d 50 18             	lea    0x18(%eax),%edx
80102119:	8b 45 10             	mov    0x10(%ebp),%eax
8010211c:	25 ff 01 00 00       	and    $0x1ff,%eax
80102121:	01 d0                	add    %edx,%eax
80102123:	83 ec 04             	sub    $0x4,%esp
80102126:	ff 75 ec             	pushl  -0x14(%ebp)
80102129:	ff 75 0c             	pushl  0xc(%ebp)
8010212c:	50                   	push   %eax
8010212d:	e8 97 33 00 00       	call   801054c9 <memmove>
80102132:	83 c4 10             	add    $0x10,%esp
    log_write(bp);
80102135:	83 ec 0c             	sub    $0xc,%esp
80102138:	ff 75 f0             	pushl  -0x10(%ebp)
8010213b:	e8 2a 16 00 00       	call   8010376a <log_write>
80102140:	83 c4 10             	add    $0x10,%esp
    brelse(bp);
80102143:	83 ec 0c             	sub    $0xc,%esp
80102146:	ff 75 f0             	pushl  -0x10(%ebp)
80102149:	e8 e0 e0 ff ff       	call   8010022e <brelse>
8010214e:	83 c4 10             	add    $0x10,%esp
  if(off > ip->size || off + n < off)
    return -1;
  if(off + n > MAXFILE*BSIZE)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
80102151:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102154:	01 45 f4             	add    %eax,-0xc(%ebp)
80102157:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010215a:	01 45 10             	add    %eax,0x10(%ebp)
8010215d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102160:	01 45 0c             	add    %eax,0xc(%ebp)
80102163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102166:	3b 45 14             	cmp    0x14(%ebp),%eax
80102169:	0f 82 5b ff ff ff    	jb     801020ca <writei+0xb6>
    memmove(bp->data + off%BSIZE, src, m);
    log_write(bp);
    brelse(bp);
  }

  if(n > 0 && off > ip->size){
8010216f:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
80102173:	74 22                	je     80102197 <writei+0x183>
80102175:	8b 45 08             	mov    0x8(%ebp),%eax
80102178:	8b 40 18             	mov    0x18(%eax),%eax
8010217b:	3b 45 10             	cmp    0x10(%ebp),%eax
8010217e:	73 17                	jae    80102197 <writei+0x183>
    ip->size = off;
80102180:	8b 45 08             	mov    0x8(%ebp),%eax
80102183:	8b 55 10             	mov    0x10(%ebp),%edx
80102186:	89 50 18             	mov    %edx,0x18(%eax)
    iupdate(ip);
80102189:	83 ec 0c             	sub    $0xc,%esp
8010218c:	ff 75 08             	pushl  0x8(%ebp)
8010218f:	e8 e1 f5 ff ff       	call   80101775 <iupdate>
80102194:	83 c4 10             	add    $0x10,%esp
  }
  return n;
80102197:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010219a:	c9                   	leave  
8010219b:	c3                   	ret    

8010219c <namecmp>:
//PAGEBREAK!
// Directories

int
namecmp(const char *s, const char *t)
{
8010219c:	55                   	push   %ebp
8010219d:	89 e5                	mov    %esp,%ebp
8010219f:	83 ec 08             	sub    $0x8,%esp
  return strncmp(s, t, DIRSIZ);
801021a2:	83 ec 04             	sub    $0x4,%esp
801021a5:	6a 0e                	push   $0xe
801021a7:	ff 75 0c             	pushl  0xc(%ebp)
801021aa:	ff 75 08             	pushl  0x8(%ebp)
801021ad:	e8 ad 33 00 00       	call   8010555f <strncmp>
801021b2:	83 c4 10             	add    $0x10,%esp
}
801021b5:	c9                   	leave  
801021b6:	c3                   	ret    

801021b7 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
801021b7:	55                   	push   %ebp
801021b8:	89 e5                	mov    %esp,%ebp
801021ba:	83 ec 28             	sub    $0x28,%esp
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
801021bd:	8b 45 08             	mov    0x8(%ebp),%eax
801021c0:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801021c4:	66 83 f8 01          	cmp    $0x1,%ax
801021c8:	74 0d                	je     801021d7 <dirlookup+0x20>
    panic("dirlookup not DIR");
801021ca:	83 ec 0c             	sub    $0xc,%esp
801021cd:	68 ef 88 10 80       	push   $0x801088ef
801021d2:	e8 8f e3 ff ff       	call   80100566 <panic>

  for(off = 0; off < dp->size; off += sizeof(de)){
801021d7:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801021de:	eb 7b                	jmp    8010225b <dirlookup+0xa4>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801021e0:	6a 10                	push   $0x10
801021e2:	ff 75 f4             	pushl  -0xc(%ebp)
801021e5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801021e8:	50                   	push   %eax
801021e9:	ff 75 08             	pushl  0x8(%ebp)
801021ec:	e8 cc fc ff ff       	call   80101ebd <readi>
801021f1:	83 c4 10             	add    $0x10,%esp
801021f4:	83 f8 10             	cmp    $0x10,%eax
801021f7:	74 0d                	je     80102206 <dirlookup+0x4f>
      panic("dirlink read");
801021f9:	83 ec 0c             	sub    $0xc,%esp
801021fc:	68 01 89 10 80       	push   $0x80108901
80102201:	e8 60 e3 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
80102206:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010220a:	66 85 c0             	test   %ax,%ax
8010220d:	74 47                	je     80102256 <dirlookup+0x9f>
      continue;
    if(namecmp(name, de.name) == 0){
8010220f:	83 ec 08             	sub    $0x8,%esp
80102212:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102215:	83 c0 02             	add    $0x2,%eax
80102218:	50                   	push   %eax
80102219:	ff 75 0c             	pushl  0xc(%ebp)
8010221c:	e8 7b ff ff ff       	call   8010219c <namecmp>
80102221:	83 c4 10             	add    $0x10,%esp
80102224:	85 c0                	test   %eax,%eax
80102226:	75 2f                	jne    80102257 <dirlookup+0xa0>
      // entry matches path element
      if(poff)
80102228:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010222c:	74 08                	je     80102236 <dirlookup+0x7f>
        *poff = off;
8010222e:	8b 45 10             	mov    0x10(%ebp),%eax
80102231:	8b 55 f4             	mov    -0xc(%ebp),%edx
80102234:	89 10                	mov    %edx,(%eax)
      inum = de.inum;
80102236:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
8010223a:	0f b7 c0             	movzwl %ax,%eax
8010223d:	89 45 f0             	mov    %eax,-0x10(%ebp)
      return iget(dp->dev, inum);
80102240:	8b 45 08             	mov    0x8(%ebp),%eax
80102243:	8b 00                	mov    (%eax),%eax
80102245:	83 ec 08             	sub    $0x8,%esp
80102248:	ff 75 f0             	pushl  -0x10(%ebp)
8010224b:	50                   	push   %eax
8010224c:	e8 e5 f5 ff ff       	call   80101836 <iget>
80102251:	83 c4 10             	add    $0x10,%esp
80102254:	eb 19                	jmp    8010226f <dirlookup+0xb8>

  for(off = 0; off < dp->size; off += sizeof(de)){
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      continue;
80102256:	90                   	nop
  struct dirent de;

  if(dp->type != T_DIR)
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
80102257:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
8010225b:	8b 45 08             	mov    0x8(%ebp),%eax
8010225e:	8b 40 18             	mov    0x18(%eax),%eax
80102261:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80102264:	0f 87 76 ff ff ff    	ja     801021e0 <dirlookup+0x29>
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
8010226a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010226f:	c9                   	leave  
80102270:	c3                   	ret    

80102271 <dirlink>:

// Write a new directory entry (name, inum) into the directory dp.
int
dirlink(struct inode *dp, char *name, uint inum)
{
80102271:	55                   	push   %ebp
80102272:	89 e5                	mov    %esp,%ebp
80102274:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;
  struct inode *ip;

  // Check that name is not present.
  if((ip = dirlookup(dp, name, 0)) != 0){
80102277:	83 ec 04             	sub    $0x4,%esp
8010227a:	6a 00                	push   $0x0
8010227c:	ff 75 0c             	pushl  0xc(%ebp)
8010227f:	ff 75 08             	pushl  0x8(%ebp)
80102282:	e8 30 ff ff ff       	call   801021b7 <dirlookup>
80102287:	83 c4 10             	add    $0x10,%esp
8010228a:	89 45 f0             	mov    %eax,-0x10(%ebp)
8010228d:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80102291:	74 18                	je     801022ab <dirlink+0x3a>
    iput(ip);
80102293:	83 ec 0c             	sub    $0xc,%esp
80102296:	ff 75 f0             	pushl  -0x10(%ebp)
80102299:	e8 81 f8 ff ff       	call   80101b1f <iput>
8010229e:	83 c4 10             	add    $0x10,%esp
    return -1;
801022a1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022a6:	e9 9c 00 00 00       	jmp    80102347 <dirlink+0xd6>
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022ab:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801022b2:	eb 39                	jmp    801022ed <dirlink+0x7c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801022b4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022b7:	6a 10                	push   $0x10
801022b9:	50                   	push   %eax
801022ba:	8d 45 e0             	lea    -0x20(%ebp),%eax
801022bd:	50                   	push   %eax
801022be:	ff 75 08             	pushl  0x8(%ebp)
801022c1:	e8 f7 fb ff ff       	call   80101ebd <readi>
801022c6:	83 c4 10             	add    $0x10,%esp
801022c9:	83 f8 10             	cmp    $0x10,%eax
801022cc:	74 0d                	je     801022db <dirlink+0x6a>
      panic("dirlink read");
801022ce:	83 ec 0c             	sub    $0xc,%esp
801022d1:	68 01 89 10 80       	push   $0x80108901
801022d6:	e8 8b e2 ff ff       	call   80100566 <panic>
    if(de.inum == 0)
801022db:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801022df:	66 85 c0             	test   %ax,%ax
801022e2:	74 18                	je     801022fc <dirlink+0x8b>
    iput(ip);
    return -1;
  }

  // Look for an empty dirent.
  for(off = 0; off < dp->size; off += sizeof(de)){
801022e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022e7:	83 c0 10             	add    $0x10,%eax
801022ea:	89 45 f4             	mov    %eax,-0xc(%ebp)
801022ed:	8b 45 08             	mov    0x8(%ebp),%eax
801022f0:	8b 50 18             	mov    0x18(%eax),%edx
801022f3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801022f6:	39 c2                	cmp    %eax,%edx
801022f8:	77 ba                	ja     801022b4 <dirlink+0x43>
801022fa:	eb 01                	jmp    801022fd <dirlink+0x8c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("dirlink read");
    if(de.inum == 0)
      break;
801022fc:	90                   	nop
  }

  strncpy(de.name, name, DIRSIZ);
801022fd:	83 ec 04             	sub    $0x4,%esp
80102300:	6a 0e                	push   $0xe
80102302:	ff 75 0c             	pushl  0xc(%ebp)
80102305:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102308:	83 c0 02             	add    $0x2,%eax
8010230b:	50                   	push   %eax
8010230c:	e8 a4 32 00 00       	call   801055b5 <strncpy>
80102311:	83 c4 10             	add    $0x10,%esp
  de.inum = inum;
80102314:	8b 45 10             	mov    0x10(%ebp),%eax
80102317:	66 89 45 e0          	mov    %ax,-0x20(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010231b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010231e:	6a 10                	push   $0x10
80102320:	50                   	push   %eax
80102321:	8d 45 e0             	lea    -0x20(%ebp),%eax
80102324:	50                   	push   %eax
80102325:	ff 75 08             	pushl  0x8(%ebp)
80102328:	e8 e7 fc ff ff       	call   80102014 <writei>
8010232d:	83 c4 10             	add    $0x10,%esp
80102330:	83 f8 10             	cmp    $0x10,%eax
80102333:	74 0d                	je     80102342 <dirlink+0xd1>
    panic("dirlink");
80102335:	83 ec 0c             	sub    $0xc,%esp
80102338:	68 0e 89 10 80       	push   $0x8010890e
8010233d:	e8 24 e2 ff ff       	call   80100566 <panic>
  
  return 0;
80102342:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102347:	c9                   	leave  
80102348:	c3                   	ret    

80102349 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80102349:	55                   	push   %ebp
8010234a:	89 e5                	mov    %esp,%ebp
8010234c:	83 ec 18             	sub    $0x18,%esp
  char *s;
  int len;

  while(*path == '/')
8010234f:	eb 04                	jmp    80102355 <skipelem+0xc>
    path++;
80102351:	83 45 08 01          	addl   $0x1,0x8(%ebp)
skipelem(char *path, char *name)
{
  char *s;
  int len;

  while(*path == '/')
80102355:	8b 45 08             	mov    0x8(%ebp),%eax
80102358:	0f b6 00             	movzbl (%eax),%eax
8010235b:	3c 2f                	cmp    $0x2f,%al
8010235d:	74 f2                	je     80102351 <skipelem+0x8>
    path++;
  if(*path == 0)
8010235f:	8b 45 08             	mov    0x8(%ebp),%eax
80102362:	0f b6 00             	movzbl (%eax),%eax
80102365:	84 c0                	test   %al,%al
80102367:	75 07                	jne    80102370 <skipelem+0x27>
    return 0;
80102369:	b8 00 00 00 00       	mov    $0x0,%eax
8010236e:	eb 7b                	jmp    801023eb <skipelem+0xa2>
  s = path;
80102370:	8b 45 08             	mov    0x8(%ebp),%eax
80102373:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(*path != '/' && *path != 0)
80102376:	eb 04                	jmp    8010237c <skipelem+0x33>
    path++;
80102378:	83 45 08 01          	addl   $0x1,0x8(%ebp)
  while(*path == '/')
    path++;
  if(*path == 0)
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
8010237c:	8b 45 08             	mov    0x8(%ebp),%eax
8010237f:	0f b6 00             	movzbl (%eax),%eax
80102382:	3c 2f                	cmp    $0x2f,%al
80102384:	74 0a                	je     80102390 <skipelem+0x47>
80102386:	8b 45 08             	mov    0x8(%ebp),%eax
80102389:	0f b6 00             	movzbl (%eax),%eax
8010238c:	84 c0                	test   %al,%al
8010238e:	75 e8                	jne    80102378 <skipelem+0x2f>
    path++;
  len = path - s;
80102390:	8b 55 08             	mov    0x8(%ebp),%edx
80102393:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102396:	29 c2                	sub    %eax,%edx
80102398:	89 d0                	mov    %edx,%eax
8010239a:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(len >= DIRSIZ)
8010239d:	83 7d f0 0d          	cmpl   $0xd,-0x10(%ebp)
801023a1:	7e 15                	jle    801023b8 <skipelem+0x6f>
    memmove(name, s, DIRSIZ);
801023a3:	83 ec 04             	sub    $0x4,%esp
801023a6:	6a 0e                	push   $0xe
801023a8:	ff 75 f4             	pushl  -0xc(%ebp)
801023ab:	ff 75 0c             	pushl  0xc(%ebp)
801023ae:	e8 16 31 00 00       	call   801054c9 <memmove>
801023b3:	83 c4 10             	add    $0x10,%esp
801023b6:	eb 26                	jmp    801023de <skipelem+0x95>
  else {
    memmove(name, s, len);
801023b8:	8b 45 f0             	mov    -0x10(%ebp),%eax
801023bb:	83 ec 04             	sub    $0x4,%esp
801023be:	50                   	push   %eax
801023bf:	ff 75 f4             	pushl  -0xc(%ebp)
801023c2:	ff 75 0c             	pushl  0xc(%ebp)
801023c5:	e8 ff 30 00 00       	call   801054c9 <memmove>
801023ca:	83 c4 10             	add    $0x10,%esp
    name[len] = 0;
801023cd:	8b 55 f0             	mov    -0x10(%ebp),%edx
801023d0:	8b 45 0c             	mov    0xc(%ebp),%eax
801023d3:	01 d0                	add    %edx,%eax
801023d5:	c6 00 00             	movb   $0x0,(%eax)
  }
  while(*path == '/')
801023d8:	eb 04                	jmp    801023de <skipelem+0x95>
    path++;
801023da:	83 45 08 01          	addl   $0x1,0x8(%ebp)
    memmove(name, s, DIRSIZ);
  else {
    memmove(name, s, len);
    name[len] = 0;
  }
  while(*path == '/')
801023de:	8b 45 08             	mov    0x8(%ebp),%eax
801023e1:	0f b6 00             	movzbl (%eax),%eax
801023e4:	3c 2f                	cmp    $0x2f,%al
801023e6:	74 f2                	je     801023da <skipelem+0x91>
    path++;
  return path;
801023e8:	8b 45 08             	mov    0x8(%ebp),%eax
}
801023eb:	c9                   	leave  
801023ec:	c3                   	ret    

801023ed <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
801023ed:	55                   	push   %ebp
801023ee:	89 e5                	mov    %esp,%ebp
801023f0:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip, *next;

  if(*path == '/')
801023f3:	8b 45 08             	mov    0x8(%ebp),%eax
801023f6:	0f b6 00             	movzbl (%eax),%eax
801023f9:	3c 2f                	cmp    $0x2f,%al
801023fb:	75 17                	jne    80102414 <namex+0x27>
    ip = iget(ROOTDEV, ROOTINO);
801023fd:	83 ec 08             	sub    $0x8,%esp
80102400:	6a 01                	push   $0x1
80102402:	6a 01                	push   $0x1
80102404:	e8 2d f4 ff ff       	call   80101836 <iget>
80102409:	83 c4 10             	add    $0x10,%esp
8010240c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010240f:	e9 bb 00 00 00       	jmp    801024cf <namex+0xe2>
  else
    ip = idup(proc->cwd);
80102414:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010241a:	8b 40 68             	mov    0x68(%eax),%eax
8010241d:	83 ec 0c             	sub    $0xc,%esp
80102420:	50                   	push   %eax
80102421:	e8 ef f4 ff ff       	call   80101915 <idup>
80102426:	83 c4 10             	add    $0x10,%esp
80102429:	89 45 f4             	mov    %eax,-0xc(%ebp)

  while((path = skipelem(path, name)) != 0){
8010242c:	e9 9e 00 00 00       	jmp    801024cf <namex+0xe2>
    ilock(ip);
80102431:	83 ec 0c             	sub    $0xc,%esp
80102434:	ff 75 f4             	pushl  -0xc(%ebp)
80102437:	e8 13 f5 ff ff       	call   8010194f <ilock>
8010243c:	83 c4 10             	add    $0x10,%esp
    if(ip->type != T_DIR){
8010243f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102442:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80102446:	66 83 f8 01          	cmp    $0x1,%ax
8010244a:	74 18                	je     80102464 <namex+0x77>
      iunlockput(ip);
8010244c:	83 ec 0c             	sub    $0xc,%esp
8010244f:	ff 75 f4             	pushl  -0xc(%ebp)
80102452:	e8 b8 f7 ff ff       	call   80101c0f <iunlockput>
80102457:	83 c4 10             	add    $0x10,%esp
      return 0;
8010245a:	b8 00 00 00 00       	mov    $0x0,%eax
8010245f:	e9 a7 00 00 00       	jmp    8010250b <namex+0x11e>
    }
    if(nameiparent && *path == '\0'){
80102464:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102468:	74 20                	je     8010248a <namex+0x9d>
8010246a:	8b 45 08             	mov    0x8(%ebp),%eax
8010246d:	0f b6 00             	movzbl (%eax),%eax
80102470:	84 c0                	test   %al,%al
80102472:	75 16                	jne    8010248a <namex+0x9d>
      // Stop one level early.
      iunlock(ip);
80102474:	83 ec 0c             	sub    $0xc,%esp
80102477:	ff 75 f4             	pushl  -0xc(%ebp)
8010247a:	e8 2e f6 ff ff       	call   80101aad <iunlock>
8010247f:	83 c4 10             	add    $0x10,%esp
      return ip;
80102482:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102485:	e9 81 00 00 00       	jmp    8010250b <namex+0x11e>
    }
    if((next = dirlookup(ip, name, 0)) == 0){
8010248a:	83 ec 04             	sub    $0x4,%esp
8010248d:	6a 00                	push   $0x0
8010248f:	ff 75 10             	pushl  0x10(%ebp)
80102492:	ff 75 f4             	pushl  -0xc(%ebp)
80102495:	e8 1d fd ff ff       	call   801021b7 <dirlookup>
8010249a:	83 c4 10             	add    $0x10,%esp
8010249d:	89 45 f0             	mov    %eax,-0x10(%ebp)
801024a0:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801024a4:	75 15                	jne    801024bb <namex+0xce>
      iunlockput(ip);
801024a6:	83 ec 0c             	sub    $0xc,%esp
801024a9:	ff 75 f4             	pushl  -0xc(%ebp)
801024ac:	e8 5e f7 ff ff       	call   80101c0f <iunlockput>
801024b1:	83 c4 10             	add    $0x10,%esp
      return 0;
801024b4:	b8 00 00 00 00       	mov    $0x0,%eax
801024b9:	eb 50                	jmp    8010250b <namex+0x11e>
    }
    iunlockput(ip);
801024bb:	83 ec 0c             	sub    $0xc,%esp
801024be:	ff 75 f4             	pushl  -0xc(%ebp)
801024c1:	e8 49 f7 ff ff       	call   80101c0f <iunlockput>
801024c6:	83 c4 10             	add    $0x10,%esp
    ip = next;
801024c9:	8b 45 f0             	mov    -0x10(%ebp),%eax
801024cc:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(*path == '/')
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(proc->cwd);

  while((path = skipelem(path, name)) != 0){
801024cf:	83 ec 08             	sub    $0x8,%esp
801024d2:	ff 75 10             	pushl  0x10(%ebp)
801024d5:	ff 75 08             	pushl  0x8(%ebp)
801024d8:	e8 6c fe ff ff       	call   80102349 <skipelem>
801024dd:	83 c4 10             	add    $0x10,%esp
801024e0:	89 45 08             	mov    %eax,0x8(%ebp)
801024e3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801024e7:	0f 85 44 ff ff ff    	jne    80102431 <namex+0x44>
      return 0;
    }
    iunlockput(ip);
    ip = next;
  }
  if(nameiparent){
801024ed:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801024f1:	74 15                	je     80102508 <namex+0x11b>
    iput(ip);
801024f3:	83 ec 0c             	sub    $0xc,%esp
801024f6:	ff 75 f4             	pushl  -0xc(%ebp)
801024f9:	e8 21 f6 ff ff       	call   80101b1f <iput>
801024fe:	83 c4 10             	add    $0x10,%esp
    return 0;
80102501:	b8 00 00 00 00       	mov    $0x0,%eax
80102506:	eb 03                	jmp    8010250b <namex+0x11e>
  }
  return ip;
80102508:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010250b:	c9                   	leave  
8010250c:	c3                   	ret    

8010250d <namei>:

struct inode*
namei(char *path)
{
8010250d:	55                   	push   %ebp
8010250e:	89 e5                	mov    %esp,%ebp
80102510:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80102513:	83 ec 04             	sub    $0x4,%esp
80102516:	8d 45 ea             	lea    -0x16(%ebp),%eax
80102519:	50                   	push   %eax
8010251a:	6a 00                	push   $0x0
8010251c:	ff 75 08             	pushl  0x8(%ebp)
8010251f:	e8 c9 fe ff ff       	call   801023ed <namex>
80102524:	83 c4 10             	add    $0x10,%esp
}
80102527:	c9                   	leave  
80102528:	c3                   	ret    

80102529 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80102529:	55                   	push   %ebp
8010252a:	89 e5                	mov    %esp,%ebp
8010252c:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
8010252f:	83 ec 04             	sub    $0x4,%esp
80102532:	ff 75 0c             	pushl  0xc(%ebp)
80102535:	6a 01                	push   $0x1
80102537:	ff 75 08             	pushl  0x8(%ebp)
8010253a:	e8 ae fe ff ff       	call   801023ed <namex>
8010253f:	83 c4 10             	add    $0x10,%esp
}
80102542:	c9                   	leave  
80102543:	c3                   	ret    

80102544 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102544:	55                   	push   %ebp
80102545:	89 e5                	mov    %esp,%ebp
80102547:	83 ec 14             	sub    $0x14,%esp
8010254a:	8b 45 08             	mov    0x8(%ebp),%eax
8010254d:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102551:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102555:	89 c2                	mov    %eax,%edx
80102557:	ec                   	in     (%dx),%al
80102558:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
8010255b:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
8010255f:	c9                   	leave  
80102560:	c3                   	ret    

80102561 <insl>:

static inline void
insl(int port, void *addr, int cnt)
{
80102561:	55                   	push   %ebp
80102562:	89 e5                	mov    %esp,%ebp
80102564:	57                   	push   %edi
80102565:	53                   	push   %ebx
  asm volatile("cld; rep insl" :
80102566:	8b 55 08             	mov    0x8(%ebp),%edx
80102569:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010256c:	8b 45 10             	mov    0x10(%ebp),%eax
8010256f:	89 cb                	mov    %ecx,%ebx
80102571:	89 df                	mov    %ebx,%edi
80102573:	89 c1                	mov    %eax,%ecx
80102575:	fc                   	cld    
80102576:	f3 6d                	rep insl (%dx),%es:(%edi)
80102578:	89 c8                	mov    %ecx,%eax
8010257a:	89 fb                	mov    %edi,%ebx
8010257c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
8010257f:	89 45 10             	mov    %eax,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "memory", "cc");
}
80102582:	90                   	nop
80102583:	5b                   	pop    %ebx
80102584:	5f                   	pop    %edi
80102585:	5d                   	pop    %ebp
80102586:	c3                   	ret    

80102587 <outb>:

static inline void
outb(ushort port, uchar data)
{
80102587:	55                   	push   %ebp
80102588:	89 e5                	mov    %esp,%ebp
8010258a:	83 ec 08             	sub    $0x8,%esp
8010258d:	8b 55 08             	mov    0x8(%ebp),%edx
80102590:	8b 45 0c             	mov    0xc(%ebp),%eax
80102593:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102597:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010259a:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
8010259e:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801025a2:	ee                   	out    %al,(%dx)
}
801025a3:	90                   	nop
801025a4:	c9                   	leave  
801025a5:	c3                   	ret    

801025a6 <outsl>:
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
}

static inline void
outsl(int port, const void *addr, int cnt)
{
801025a6:	55                   	push   %ebp
801025a7:	89 e5                	mov    %esp,%ebp
801025a9:	56                   	push   %esi
801025aa:	53                   	push   %ebx
  asm volatile("cld; rep outsl" :
801025ab:	8b 55 08             	mov    0x8(%ebp),%edx
801025ae:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801025b1:	8b 45 10             	mov    0x10(%ebp),%eax
801025b4:	89 cb                	mov    %ecx,%ebx
801025b6:	89 de                	mov    %ebx,%esi
801025b8:	89 c1                	mov    %eax,%ecx
801025ba:	fc                   	cld    
801025bb:	f3 6f                	rep outsl %ds:(%esi),(%dx)
801025bd:	89 c8                	mov    %ecx,%eax
801025bf:	89 f3                	mov    %esi,%ebx
801025c1:	89 5d 0c             	mov    %ebx,0xc(%ebp)
801025c4:	89 45 10             	mov    %eax,0x10(%ebp)
               "=S" (addr), "=c" (cnt) :
               "d" (port), "0" (addr), "1" (cnt) :
               "cc");
}
801025c7:	90                   	nop
801025c8:	5b                   	pop    %ebx
801025c9:	5e                   	pop    %esi
801025ca:	5d                   	pop    %ebp
801025cb:	c3                   	ret    

801025cc <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
801025cc:	55                   	push   %ebp
801025cd:	89 e5                	mov    %esp,%ebp
801025cf:	83 ec 10             	sub    $0x10,%esp
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY) 
801025d2:	90                   	nop
801025d3:	68 f7 01 00 00       	push   $0x1f7
801025d8:	e8 67 ff ff ff       	call   80102544 <inb>
801025dd:	83 c4 04             	add    $0x4,%esp
801025e0:	0f b6 c0             	movzbl %al,%eax
801025e3:	89 45 fc             	mov    %eax,-0x4(%ebp)
801025e6:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025e9:	25 c0 00 00 00       	and    $0xc0,%eax
801025ee:	83 f8 40             	cmp    $0x40,%eax
801025f1:	75 e0                	jne    801025d3 <idewait+0x7>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
801025f3:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801025f7:	74 11                	je     8010260a <idewait+0x3e>
801025f9:	8b 45 fc             	mov    -0x4(%ebp),%eax
801025fc:	83 e0 21             	and    $0x21,%eax
801025ff:	85 c0                	test   %eax,%eax
80102601:	74 07                	je     8010260a <idewait+0x3e>
    return -1;
80102603:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102608:	eb 05                	jmp    8010260f <idewait+0x43>
  return 0;
8010260a:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010260f:	c9                   	leave  
80102610:	c3                   	ret    

80102611 <ideinit>:

void
ideinit(void)
{
80102611:	55                   	push   %ebp
80102612:	89 e5                	mov    %esp,%ebp
80102614:	83 ec 18             	sub    $0x18,%esp
  int i;
  
  initlock(&idelock, "ide");
80102617:	83 ec 08             	sub    $0x8,%esp
8010261a:	68 16 89 10 80       	push   $0x80108916
8010261f:	68 00 b6 10 80       	push   $0x8010b600
80102624:	e8 5c 2b 00 00       	call   80105185 <initlock>
80102629:	83 c4 10             	add    $0x10,%esp
  picenable(IRQ_IDE);
8010262c:	83 ec 0c             	sub    $0xc,%esp
8010262f:	6a 0e                	push   $0xe
80102631:	e8 da 18 00 00       	call   80103f10 <picenable>
80102636:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_IDE, ncpu - 1);
80102639:	a1 60 29 11 80       	mov    0x80112960,%eax
8010263e:	83 e8 01             	sub    $0x1,%eax
80102641:	83 ec 08             	sub    $0x8,%esp
80102644:	50                   	push   %eax
80102645:	6a 0e                	push   $0xe
80102647:	e8 73 04 00 00       	call   80102abf <ioapicenable>
8010264c:	83 c4 10             	add    $0x10,%esp
  idewait(0);
8010264f:	83 ec 0c             	sub    $0xc,%esp
80102652:	6a 00                	push   $0x0
80102654:	e8 73 ff ff ff       	call   801025cc <idewait>
80102659:	83 c4 10             	add    $0x10,%esp
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
8010265c:	83 ec 08             	sub    $0x8,%esp
8010265f:	68 f0 00 00 00       	push   $0xf0
80102664:	68 f6 01 00 00       	push   $0x1f6
80102669:	e8 19 ff ff ff       	call   80102587 <outb>
8010266e:	83 c4 10             	add    $0x10,%esp
  for(i=0; i<1000; i++){
80102671:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102678:	eb 24                	jmp    8010269e <ideinit+0x8d>
    if(inb(0x1f7) != 0){
8010267a:	83 ec 0c             	sub    $0xc,%esp
8010267d:	68 f7 01 00 00       	push   $0x1f7
80102682:	e8 bd fe ff ff       	call   80102544 <inb>
80102687:	83 c4 10             	add    $0x10,%esp
8010268a:	84 c0                	test   %al,%al
8010268c:	74 0c                	je     8010269a <ideinit+0x89>
      havedisk1 = 1;
8010268e:	c7 05 38 b6 10 80 01 	movl   $0x1,0x8010b638
80102695:	00 00 00 
      break;
80102698:	eb 0d                	jmp    801026a7 <ideinit+0x96>
  ioapicenable(IRQ_IDE, ncpu - 1);
  idewait(0);
  
  // Check if disk 1 is present
  outb(0x1f6, 0xe0 | (1<<4));
  for(i=0; i<1000; i++){
8010269a:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
8010269e:	81 7d f4 e7 03 00 00 	cmpl   $0x3e7,-0xc(%ebp)
801026a5:	7e d3                	jle    8010267a <ideinit+0x69>
      break;
    }
  }
  
  // Switch back to disk 0.
  outb(0x1f6, 0xe0 | (0<<4));
801026a7:	83 ec 08             	sub    $0x8,%esp
801026aa:	68 e0 00 00 00       	push   $0xe0
801026af:	68 f6 01 00 00       	push   $0x1f6
801026b4:	e8 ce fe ff ff       	call   80102587 <outb>
801026b9:	83 c4 10             	add    $0x10,%esp
}
801026bc:	90                   	nop
801026bd:	c9                   	leave  
801026be:	c3                   	ret    

801026bf <idestart>:

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
801026bf:	55                   	push   %ebp
801026c0:	89 e5                	mov    %esp,%ebp
801026c2:	83 ec 18             	sub    $0x18,%esp
  if(b == 0)
801026c5:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801026c9:	75 0d                	jne    801026d8 <idestart+0x19>
    panic("idestart");
801026cb:	83 ec 0c             	sub    $0xc,%esp
801026ce:	68 1a 89 10 80       	push   $0x8010891a
801026d3:	e8 8e de ff ff       	call   80100566 <panic>
  if(b->blockno >= FSSIZE)
801026d8:	8b 45 08             	mov    0x8(%ebp),%eax
801026db:	8b 40 08             	mov    0x8(%eax),%eax
801026de:	3d e7 03 00 00       	cmp    $0x3e7,%eax
801026e3:	76 0d                	jbe    801026f2 <idestart+0x33>
    panic("incorrect blockno");
801026e5:	83 ec 0c             	sub    $0xc,%esp
801026e8:	68 23 89 10 80       	push   $0x80108923
801026ed:	e8 74 de ff ff       	call   80100566 <panic>
  int sector_per_block =  BSIZE/SECTOR_SIZE;
801026f2:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
  int sector = b->blockno * sector_per_block;
801026f9:	8b 45 08             	mov    0x8(%ebp),%eax
801026fc:	8b 50 08             	mov    0x8(%eax),%edx
801026ff:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102702:	0f af c2             	imul   %edx,%eax
80102705:	89 45 f0             	mov    %eax,-0x10(%ebp)

  if (sector_per_block > 7) panic("idestart");
80102708:	83 7d f4 07          	cmpl   $0x7,-0xc(%ebp)
8010270c:	7e 0d                	jle    8010271b <idestart+0x5c>
8010270e:	83 ec 0c             	sub    $0xc,%esp
80102711:	68 1a 89 10 80       	push   $0x8010891a
80102716:	e8 4b de ff ff       	call   80100566 <panic>
  
  idewait(0);
8010271b:	83 ec 0c             	sub    $0xc,%esp
8010271e:	6a 00                	push   $0x0
80102720:	e8 a7 fe ff ff       	call   801025cc <idewait>
80102725:	83 c4 10             	add    $0x10,%esp
  outb(0x3f6, 0);  // generate interrupt
80102728:	83 ec 08             	sub    $0x8,%esp
8010272b:	6a 00                	push   $0x0
8010272d:	68 f6 03 00 00       	push   $0x3f6
80102732:	e8 50 fe ff ff       	call   80102587 <outb>
80102737:	83 c4 10             	add    $0x10,%esp
  outb(0x1f2, sector_per_block);  // number of sectors
8010273a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010273d:	0f b6 c0             	movzbl %al,%eax
80102740:	83 ec 08             	sub    $0x8,%esp
80102743:	50                   	push   %eax
80102744:	68 f2 01 00 00       	push   $0x1f2
80102749:	e8 39 fe ff ff       	call   80102587 <outb>
8010274e:	83 c4 10             	add    $0x10,%esp
  outb(0x1f3, sector & 0xff);
80102751:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102754:	0f b6 c0             	movzbl %al,%eax
80102757:	83 ec 08             	sub    $0x8,%esp
8010275a:	50                   	push   %eax
8010275b:	68 f3 01 00 00       	push   $0x1f3
80102760:	e8 22 fe ff ff       	call   80102587 <outb>
80102765:	83 c4 10             	add    $0x10,%esp
  outb(0x1f4, (sector >> 8) & 0xff);
80102768:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010276b:	c1 f8 08             	sar    $0x8,%eax
8010276e:	0f b6 c0             	movzbl %al,%eax
80102771:	83 ec 08             	sub    $0x8,%esp
80102774:	50                   	push   %eax
80102775:	68 f4 01 00 00       	push   $0x1f4
8010277a:	e8 08 fe ff ff       	call   80102587 <outb>
8010277f:	83 c4 10             	add    $0x10,%esp
  outb(0x1f5, (sector >> 16) & 0xff);
80102782:	8b 45 f0             	mov    -0x10(%ebp),%eax
80102785:	c1 f8 10             	sar    $0x10,%eax
80102788:	0f b6 c0             	movzbl %al,%eax
8010278b:	83 ec 08             	sub    $0x8,%esp
8010278e:	50                   	push   %eax
8010278f:	68 f5 01 00 00       	push   $0x1f5
80102794:	e8 ee fd ff ff       	call   80102587 <outb>
80102799:	83 c4 10             	add    $0x10,%esp
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
8010279c:	8b 45 08             	mov    0x8(%ebp),%eax
8010279f:	8b 40 04             	mov    0x4(%eax),%eax
801027a2:	83 e0 01             	and    $0x1,%eax
801027a5:	c1 e0 04             	shl    $0x4,%eax
801027a8:	89 c2                	mov    %eax,%edx
801027aa:	8b 45 f0             	mov    -0x10(%ebp),%eax
801027ad:	c1 f8 18             	sar    $0x18,%eax
801027b0:	83 e0 0f             	and    $0xf,%eax
801027b3:	09 d0                	or     %edx,%eax
801027b5:	83 c8 e0             	or     $0xffffffe0,%eax
801027b8:	0f b6 c0             	movzbl %al,%eax
801027bb:	83 ec 08             	sub    $0x8,%esp
801027be:	50                   	push   %eax
801027bf:	68 f6 01 00 00       	push   $0x1f6
801027c4:	e8 be fd ff ff       	call   80102587 <outb>
801027c9:	83 c4 10             	add    $0x10,%esp
  if(b->flags & B_DIRTY){
801027cc:	8b 45 08             	mov    0x8(%ebp),%eax
801027cf:	8b 00                	mov    (%eax),%eax
801027d1:	83 e0 04             	and    $0x4,%eax
801027d4:	85 c0                	test   %eax,%eax
801027d6:	74 30                	je     80102808 <idestart+0x149>
    outb(0x1f7, IDE_CMD_WRITE);
801027d8:	83 ec 08             	sub    $0x8,%esp
801027db:	6a 30                	push   $0x30
801027dd:	68 f7 01 00 00       	push   $0x1f7
801027e2:	e8 a0 fd ff ff       	call   80102587 <outb>
801027e7:	83 c4 10             	add    $0x10,%esp
    outsl(0x1f0, b->data, BSIZE/4);
801027ea:	8b 45 08             	mov    0x8(%ebp),%eax
801027ed:	83 c0 18             	add    $0x18,%eax
801027f0:	83 ec 04             	sub    $0x4,%esp
801027f3:	68 80 00 00 00       	push   $0x80
801027f8:	50                   	push   %eax
801027f9:	68 f0 01 00 00       	push   $0x1f0
801027fe:	e8 a3 fd ff ff       	call   801025a6 <outsl>
80102803:	83 c4 10             	add    $0x10,%esp
  } else {
    outb(0x1f7, IDE_CMD_READ);
  }
}
80102806:	eb 12                	jmp    8010281a <idestart+0x15b>
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
  if(b->flags & B_DIRTY){
    outb(0x1f7, IDE_CMD_WRITE);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, IDE_CMD_READ);
80102808:	83 ec 08             	sub    $0x8,%esp
8010280b:	6a 20                	push   $0x20
8010280d:	68 f7 01 00 00       	push   $0x1f7
80102812:	e8 70 fd ff ff       	call   80102587 <outb>
80102817:	83 c4 10             	add    $0x10,%esp
  }
}
8010281a:	90                   	nop
8010281b:	c9                   	leave  
8010281c:	c3                   	ret    

8010281d <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
8010281d:	55                   	push   %ebp
8010281e:	89 e5                	mov    %esp,%ebp
80102820:	83 ec 18             	sub    $0x18,%esp
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80102823:	83 ec 0c             	sub    $0xc,%esp
80102826:	68 00 b6 10 80       	push   $0x8010b600
8010282b:	e8 77 29 00 00       	call   801051a7 <acquire>
80102830:	83 c4 10             	add    $0x10,%esp
  if((b = idequeue) == 0){
80102833:	a1 34 b6 10 80       	mov    0x8010b634,%eax
80102838:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010283b:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010283f:	75 15                	jne    80102856 <ideintr+0x39>
    release(&idelock);
80102841:	83 ec 0c             	sub    $0xc,%esp
80102844:	68 00 b6 10 80       	push   $0x8010b600
80102849:	e8 c0 29 00 00       	call   8010520e <release>
8010284e:	83 c4 10             	add    $0x10,%esp
    // cprintf("spurious IDE interrupt\n");
    return;
80102851:	e9 9a 00 00 00       	jmp    801028f0 <ideintr+0xd3>
  }
  idequeue = b->qnext;
80102856:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102859:	8b 40 14             	mov    0x14(%eax),%eax
8010285c:	a3 34 b6 10 80       	mov    %eax,0x8010b634

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80102861:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102864:	8b 00                	mov    (%eax),%eax
80102866:	83 e0 04             	and    $0x4,%eax
80102869:	85 c0                	test   %eax,%eax
8010286b:	75 2d                	jne    8010289a <ideintr+0x7d>
8010286d:	83 ec 0c             	sub    $0xc,%esp
80102870:	6a 01                	push   $0x1
80102872:	e8 55 fd ff ff       	call   801025cc <idewait>
80102877:	83 c4 10             	add    $0x10,%esp
8010287a:	85 c0                	test   %eax,%eax
8010287c:	78 1c                	js     8010289a <ideintr+0x7d>
    insl(0x1f0, b->data, BSIZE/4);
8010287e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102881:	83 c0 18             	add    $0x18,%eax
80102884:	83 ec 04             	sub    $0x4,%esp
80102887:	68 80 00 00 00       	push   $0x80
8010288c:	50                   	push   %eax
8010288d:	68 f0 01 00 00       	push   $0x1f0
80102892:	e8 ca fc ff ff       	call   80102561 <insl>
80102897:	83 c4 10             	add    $0x10,%esp
  
  // Wake process waiting for this buf.
  b->flags |= B_VALID;
8010289a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010289d:	8b 00                	mov    (%eax),%eax
8010289f:	83 c8 02             	or     $0x2,%eax
801028a2:	89 c2                	mov    %eax,%edx
801028a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028a7:	89 10                	mov    %edx,(%eax)
  b->flags &= ~B_DIRTY;
801028a9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028ac:	8b 00                	mov    (%eax),%eax
801028ae:	83 e0 fb             	and    $0xfffffffb,%eax
801028b1:	89 c2                	mov    %eax,%edx
801028b3:	8b 45 f4             	mov    -0xc(%ebp),%eax
801028b6:	89 10                	mov    %edx,(%eax)
  wakeup(b);
801028b8:	83 ec 0c             	sub    $0xc,%esp
801028bb:	ff 75 f4             	pushl  -0xc(%ebp)
801028be:	e8 d0 26 00 00       	call   80104f93 <wakeup>
801028c3:	83 c4 10             	add    $0x10,%esp
  
  // Start disk on next buf in queue.
  if(idequeue != 0)
801028c6:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028cb:	85 c0                	test   %eax,%eax
801028cd:	74 11                	je     801028e0 <ideintr+0xc3>
    idestart(idequeue);
801028cf:	a1 34 b6 10 80       	mov    0x8010b634,%eax
801028d4:	83 ec 0c             	sub    $0xc,%esp
801028d7:	50                   	push   %eax
801028d8:	e8 e2 fd ff ff       	call   801026bf <idestart>
801028dd:	83 c4 10             	add    $0x10,%esp

  release(&idelock);
801028e0:	83 ec 0c             	sub    $0xc,%esp
801028e3:	68 00 b6 10 80       	push   $0x8010b600
801028e8:	e8 21 29 00 00       	call   8010520e <release>
801028ed:	83 c4 10             	add    $0x10,%esp
}
801028f0:	c9                   	leave  
801028f1:	c3                   	ret    

801028f2 <iderw>:
// Sync buf with disk. 
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
801028f2:	55                   	push   %ebp
801028f3:	89 e5                	mov    %esp,%ebp
801028f5:	83 ec 18             	sub    $0x18,%esp
  struct buf **pp;

  if(!(b->flags & B_BUSY))
801028f8:	8b 45 08             	mov    0x8(%ebp),%eax
801028fb:	8b 00                	mov    (%eax),%eax
801028fd:	83 e0 01             	and    $0x1,%eax
80102900:	85 c0                	test   %eax,%eax
80102902:	75 0d                	jne    80102911 <iderw+0x1f>
    panic("iderw: buf not busy");
80102904:	83 ec 0c             	sub    $0xc,%esp
80102907:	68 35 89 10 80       	push   $0x80108935
8010290c:	e8 55 dc ff ff       	call   80100566 <panic>
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80102911:	8b 45 08             	mov    0x8(%ebp),%eax
80102914:	8b 00                	mov    (%eax),%eax
80102916:	83 e0 06             	and    $0x6,%eax
80102919:	83 f8 02             	cmp    $0x2,%eax
8010291c:	75 0d                	jne    8010292b <iderw+0x39>
    panic("iderw: nothing to do");
8010291e:	83 ec 0c             	sub    $0xc,%esp
80102921:	68 49 89 10 80       	push   $0x80108949
80102926:	e8 3b dc ff ff       	call   80100566 <panic>
  if(b->dev != 0 && !havedisk1)
8010292b:	8b 45 08             	mov    0x8(%ebp),%eax
8010292e:	8b 40 04             	mov    0x4(%eax),%eax
80102931:	85 c0                	test   %eax,%eax
80102933:	74 16                	je     8010294b <iderw+0x59>
80102935:	a1 38 b6 10 80       	mov    0x8010b638,%eax
8010293a:	85 c0                	test   %eax,%eax
8010293c:	75 0d                	jne    8010294b <iderw+0x59>
    panic("iderw: ide disk 1 not present");
8010293e:	83 ec 0c             	sub    $0xc,%esp
80102941:	68 5e 89 10 80       	push   $0x8010895e
80102946:	e8 1b dc ff ff       	call   80100566 <panic>

  acquire(&idelock);  //DOC:acquire-lock
8010294b:	83 ec 0c             	sub    $0xc,%esp
8010294e:	68 00 b6 10 80       	push   $0x8010b600
80102953:	e8 4f 28 00 00       	call   801051a7 <acquire>
80102958:	83 c4 10             	add    $0x10,%esp

  // Append b to idequeue.
  b->qnext = 0;
8010295b:	8b 45 08             	mov    0x8(%ebp),%eax
8010295e:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80102965:	c7 45 f4 34 b6 10 80 	movl   $0x8010b634,-0xc(%ebp)
8010296c:	eb 0b                	jmp    80102979 <iderw+0x87>
8010296e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102971:	8b 00                	mov    (%eax),%eax
80102973:	83 c0 14             	add    $0x14,%eax
80102976:	89 45 f4             	mov    %eax,-0xc(%ebp)
80102979:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010297c:	8b 00                	mov    (%eax),%eax
8010297e:	85 c0                	test   %eax,%eax
80102980:	75 ec                	jne    8010296e <iderw+0x7c>
    ;
  *pp = b;
80102982:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102985:	8b 55 08             	mov    0x8(%ebp),%edx
80102988:	89 10                	mov    %edx,(%eax)
  
  // Start disk if necessary.
  if(idequeue == b)
8010298a:	a1 34 b6 10 80       	mov    0x8010b634,%eax
8010298f:	3b 45 08             	cmp    0x8(%ebp),%eax
80102992:	75 23                	jne    801029b7 <iderw+0xc5>
    idestart(b);
80102994:	83 ec 0c             	sub    $0xc,%esp
80102997:	ff 75 08             	pushl  0x8(%ebp)
8010299a:	e8 20 fd ff ff       	call   801026bf <idestart>
8010299f:	83 c4 10             	add    $0x10,%esp
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029a2:	eb 13                	jmp    801029b7 <iderw+0xc5>
    sleep(b, &idelock);
801029a4:	83 ec 08             	sub    $0x8,%esp
801029a7:	68 00 b6 10 80       	push   $0x8010b600
801029ac:	ff 75 08             	pushl  0x8(%ebp)
801029af:	e8 f1 24 00 00       	call   80104ea5 <sleep>
801029b4:	83 c4 10             	add    $0x10,%esp
  // Start disk if necessary.
  if(idequeue == b)
    idestart(b);
  
  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
801029b7:	8b 45 08             	mov    0x8(%ebp),%eax
801029ba:	8b 00                	mov    (%eax),%eax
801029bc:	83 e0 06             	and    $0x6,%eax
801029bf:	83 f8 02             	cmp    $0x2,%eax
801029c2:	75 e0                	jne    801029a4 <iderw+0xb2>
    sleep(b, &idelock);
  }

  release(&idelock);
801029c4:	83 ec 0c             	sub    $0xc,%esp
801029c7:	68 00 b6 10 80       	push   $0x8010b600
801029cc:	e8 3d 28 00 00       	call   8010520e <release>
801029d1:	83 c4 10             	add    $0x10,%esp
}
801029d4:	90                   	nop
801029d5:	c9                   	leave  
801029d6:	c3                   	ret    

801029d7 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
801029d7:	55                   	push   %ebp
801029d8:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029da:	a1 34 22 11 80       	mov    0x80112234,%eax
801029df:	8b 55 08             	mov    0x8(%ebp),%edx
801029e2:	89 10                	mov    %edx,(%eax)
  return ioapic->data;
801029e4:	a1 34 22 11 80       	mov    0x80112234,%eax
801029e9:	8b 40 10             	mov    0x10(%eax),%eax
}
801029ec:	5d                   	pop    %ebp
801029ed:	c3                   	ret    

801029ee <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
801029ee:	55                   	push   %ebp
801029ef:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
801029f1:	a1 34 22 11 80       	mov    0x80112234,%eax
801029f6:	8b 55 08             	mov    0x8(%ebp),%edx
801029f9:	89 10                	mov    %edx,(%eax)
  ioapic->data = data;
801029fb:	a1 34 22 11 80       	mov    0x80112234,%eax
80102a00:	8b 55 0c             	mov    0xc(%ebp),%edx
80102a03:	89 50 10             	mov    %edx,0x10(%eax)
}
80102a06:	90                   	nop
80102a07:	5d                   	pop    %ebp
80102a08:	c3                   	ret    

80102a09 <ioapicinit>:

void
ioapicinit(void)
{
80102a09:	55                   	push   %ebp
80102a0a:	89 e5                	mov    %esp,%ebp
80102a0c:	83 ec 18             	sub    $0x18,%esp
  int i, id, maxintr;

  if(!ismp)
80102a0f:	a1 64 23 11 80       	mov    0x80112364,%eax
80102a14:	85 c0                	test   %eax,%eax
80102a16:	0f 84 a0 00 00 00    	je     80102abc <ioapicinit+0xb3>
    return;

  ioapic = (volatile struct ioapic*)IOAPIC;
80102a1c:	c7 05 34 22 11 80 00 	movl   $0xfec00000,0x80112234
80102a23:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80102a26:	6a 01                	push   $0x1
80102a28:	e8 aa ff ff ff       	call   801029d7 <ioapicread>
80102a2d:	83 c4 04             	add    $0x4,%esp
80102a30:	c1 e8 10             	shr    $0x10,%eax
80102a33:	25 ff 00 00 00       	and    $0xff,%eax
80102a38:	89 45 f0             	mov    %eax,-0x10(%ebp)
  id = ioapicread(REG_ID) >> 24;
80102a3b:	6a 00                	push   $0x0
80102a3d:	e8 95 ff ff ff       	call   801029d7 <ioapicread>
80102a42:	83 c4 04             	add    $0x4,%esp
80102a45:	c1 e8 18             	shr    $0x18,%eax
80102a48:	89 45 ec             	mov    %eax,-0x14(%ebp)
  if(id != ioapicid)
80102a4b:	0f b6 05 60 23 11 80 	movzbl 0x80112360,%eax
80102a52:	0f b6 c0             	movzbl %al,%eax
80102a55:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80102a58:	74 10                	je     80102a6a <ioapicinit+0x61>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80102a5a:	83 ec 0c             	sub    $0xc,%esp
80102a5d:	68 7c 89 10 80       	push   $0x8010897c
80102a62:	e8 5f d9 ff ff       	call   801003c6 <cprintf>
80102a67:	83 c4 10             	add    $0x10,%esp

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102a6a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80102a71:	eb 3f                	jmp    80102ab2 <ioapicinit+0xa9>
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80102a73:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a76:	83 c0 20             	add    $0x20,%eax
80102a79:	0d 00 00 01 00       	or     $0x10000,%eax
80102a7e:	89 c2                	mov    %eax,%edx
80102a80:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a83:	83 c0 08             	add    $0x8,%eax
80102a86:	01 c0                	add    %eax,%eax
80102a88:	83 ec 08             	sub    $0x8,%esp
80102a8b:	52                   	push   %edx
80102a8c:	50                   	push   %eax
80102a8d:	e8 5c ff ff ff       	call   801029ee <ioapicwrite>
80102a92:	83 c4 10             	add    $0x10,%esp
    ioapicwrite(REG_TABLE+2*i+1, 0);
80102a95:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102a98:	83 c0 08             	add    $0x8,%eax
80102a9b:	01 c0                	add    %eax,%eax
80102a9d:	83 c0 01             	add    $0x1,%eax
80102aa0:	83 ec 08             	sub    $0x8,%esp
80102aa3:	6a 00                	push   $0x0
80102aa5:	50                   	push   %eax
80102aa6:	e8 43 ff ff ff       	call   801029ee <ioapicwrite>
80102aab:	83 c4 10             	add    $0x10,%esp
  if(id != ioapicid)
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
80102aae:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80102ab2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ab5:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80102ab8:	7e b9                	jle    80102a73 <ioapicinit+0x6a>
80102aba:	eb 01                	jmp    80102abd <ioapicinit+0xb4>
ioapicinit(void)
{
  int i, id, maxintr;

  if(!ismp)
    return;
80102abc:	90                   	nop
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
    ioapicwrite(REG_TABLE+2*i+1, 0);
  }
}
80102abd:	c9                   	leave  
80102abe:	c3                   	ret    

80102abf <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80102abf:	55                   	push   %ebp
80102ac0:	89 e5                	mov    %esp,%ebp
  if(!ismp)
80102ac2:	a1 64 23 11 80       	mov    0x80112364,%eax
80102ac7:	85 c0                	test   %eax,%eax
80102ac9:	74 39                	je     80102b04 <ioapicenable+0x45>
    return;

  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80102acb:	8b 45 08             	mov    0x8(%ebp),%eax
80102ace:	83 c0 20             	add    $0x20,%eax
80102ad1:	89 c2                	mov    %eax,%edx
80102ad3:	8b 45 08             	mov    0x8(%ebp),%eax
80102ad6:	83 c0 08             	add    $0x8,%eax
80102ad9:	01 c0                	add    %eax,%eax
80102adb:	52                   	push   %edx
80102adc:	50                   	push   %eax
80102add:	e8 0c ff ff ff       	call   801029ee <ioapicwrite>
80102ae2:	83 c4 08             	add    $0x8,%esp
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80102ae5:	8b 45 0c             	mov    0xc(%ebp),%eax
80102ae8:	c1 e0 18             	shl    $0x18,%eax
80102aeb:	89 c2                	mov    %eax,%edx
80102aed:	8b 45 08             	mov    0x8(%ebp),%eax
80102af0:	83 c0 08             	add    $0x8,%eax
80102af3:	01 c0                	add    %eax,%eax
80102af5:	83 c0 01             	add    $0x1,%eax
80102af8:	52                   	push   %edx
80102af9:	50                   	push   %eax
80102afa:	e8 ef fe ff ff       	call   801029ee <ioapicwrite>
80102aff:	83 c4 08             	add    $0x8,%esp
80102b02:	eb 01                	jmp    80102b05 <ioapicenable+0x46>

void
ioapicenable(int irq, int cpunum)
{
  if(!ismp)
    return;
80102b04:	90                   	nop
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
}
80102b05:	c9                   	leave  
80102b06:	c3                   	ret    

80102b07 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80102b07:	55                   	push   %ebp
80102b08:	89 e5                	mov    %esp,%ebp
80102b0a:	8b 45 08             	mov    0x8(%ebp),%eax
80102b0d:	05 00 00 00 80       	add    $0x80000000,%eax
80102b12:	5d                   	pop    %ebp
80102b13:	c3                   	ret    

80102b14 <kinit1>:
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
80102b14:	55                   	push   %ebp
80102b15:	89 e5                	mov    %esp,%ebp
80102b17:	83 ec 08             	sub    $0x8,%esp
  initlock(&kmem.lock, "kmem");
80102b1a:	83 ec 08             	sub    $0x8,%esp
80102b1d:	68 ae 89 10 80       	push   $0x801089ae
80102b22:	68 40 22 11 80       	push   $0x80112240
80102b27:	e8 59 26 00 00       	call   80105185 <initlock>
80102b2c:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 0;
80102b2f:	c7 05 74 22 11 80 00 	movl   $0x0,0x80112274
80102b36:	00 00 00 
  freerange(vstart, vend);
80102b39:	83 ec 08             	sub    $0x8,%esp
80102b3c:	ff 75 0c             	pushl  0xc(%ebp)
80102b3f:	ff 75 08             	pushl  0x8(%ebp)
80102b42:	e8 2a 00 00 00       	call   80102b71 <freerange>
80102b47:	83 c4 10             	add    $0x10,%esp
}
80102b4a:	90                   	nop
80102b4b:	c9                   	leave  
80102b4c:	c3                   	ret    

80102b4d <kinit2>:

void
kinit2(void *vstart, void *vend)
{
80102b4d:	55                   	push   %ebp
80102b4e:	89 e5                	mov    %esp,%ebp
80102b50:	83 ec 08             	sub    $0x8,%esp
  freerange(vstart, vend);
80102b53:	83 ec 08             	sub    $0x8,%esp
80102b56:	ff 75 0c             	pushl  0xc(%ebp)
80102b59:	ff 75 08             	pushl  0x8(%ebp)
80102b5c:	e8 10 00 00 00       	call   80102b71 <freerange>
80102b61:	83 c4 10             	add    $0x10,%esp
  kmem.use_lock = 1;
80102b64:	c7 05 74 22 11 80 01 	movl   $0x1,0x80112274
80102b6b:	00 00 00 
}
80102b6e:	90                   	nop
80102b6f:	c9                   	leave  
80102b70:	c3                   	ret    

80102b71 <freerange>:

void
freerange(void *vstart, void *vend)
{
80102b71:	55                   	push   %ebp
80102b72:	89 e5                	mov    %esp,%ebp
80102b74:	83 ec 18             	sub    $0x18,%esp
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
80102b77:	8b 45 08             	mov    0x8(%ebp),%eax
80102b7a:	05 ff 0f 00 00       	add    $0xfff,%eax
80102b7f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80102b84:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b87:	eb 15                	jmp    80102b9e <freerange+0x2d>
    kfree(p);
80102b89:	83 ec 0c             	sub    $0xc,%esp
80102b8c:	ff 75 f4             	pushl  -0xc(%ebp)
80102b8f:	e8 1a 00 00 00       	call   80102bae <kfree>
80102b94:	83 c4 10             	add    $0x10,%esp
void
freerange(void *vstart, void *vend)
{
  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102b97:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80102b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102ba1:	05 00 10 00 00       	add    $0x1000,%eax
80102ba6:	3b 45 0c             	cmp    0xc(%ebp),%eax
80102ba9:	76 de                	jbe    80102b89 <freerange+0x18>
    kfree(p);
}
80102bab:	90                   	nop
80102bac:	c9                   	leave  
80102bad:	c3                   	ret    

80102bae <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102bae:	55                   	push   %ebp
80102baf:	89 e5                	mov    %esp,%ebp
80102bb1:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if((uint)v % PGSIZE || v < end || v2p(v) >= PHYSTOP)
80102bb4:	8b 45 08             	mov    0x8(%ebp),%eax
80102bb7:	25 ff 0f 00 00       	and    $0xfff,%eax
80102bbc:	85 c0                	test   %eax,%eax
80102bbe:	75 1b                	jne    80102bdb <kfree+0x2d>
80102bc0:	81 7d 08 5c 55 11 80 	cmpl   $0x8011555c,0x8(%ebp)
80102bc7:	72 12                	jb     80102bdb <kfree+0x2d>
80102bc9:	ff 75 08             	pushl  0x8(%ebp)
80102bcc:	e8 36 ff ff ff       	call   80102b07 <v2p>
80102bd1:	83 c4 04             	add    $0x4,%esp
80102bd4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80102bd9:	76 0d                	jbe    80102be8 <kfree+0x3a>
    panic("kfree");
80102bdb:	83 ec 0c             	sub    $0xc,%esp
80102bde:	68 b3 89 10 80       	push   $0x801089b3
80102be3:	e8 7e d9 ff ff       	call   80100566 <panic>

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102be8:	83 ec 04             	sub    $0x4,%esp
80102beb:	68 00 10 00 00       	push   $0x1000
80102bf0:	6a 01                	push   $0x1
80102bf2:	ff 75 08             	pushl  0x8(%ebp)
80102bf5:	e8 10 28 00 00       	call   8010540a <memset>
80102bfa:	83 c4 10             	add    $0x10,%esp

  if(kmem.use_lock)
80102bfd:	a1 74 22 11 80       	mov    0x80112274,%eax
80102c02:	85 c0                	test   %eax,%eax
80102c04:	74 10                	je     80102c16 <kfree+0x68>
    acquire(&kmem.lock);
80102c06:	83 ec 0c             	sub    $0xc,%esp
80102c09:	68 40 22 11 80       	push   $0x80112240
80102c0e:	e8 94 25 00 00       	call   801051a7 <acquire>
80102c13:	83 c4 10             	add    $0x10,%esp
  r = (struct run*)v;
80102c16:	8b 45 08             	mov    0x8(%ebp),%eax
80102c19:	89 45 f4             	mov    %eax,-0xc(%ebp)
  r->next = kmem.freelist;
80102c1c:	8b 15 78 22 11 80    	mov    0x80112278,%edx
80102c22:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c25:	89 10                	mov    %edx,(%eax)
  kmem.freelist = r;
80102c27:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c2a:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102c2f:	a1 74 22 11 80       	mov    0x80112274,%eax
80102c34:	85 c0                	test   %eax,%eax
80102c36:	74 10                	je     80102c48 <kfree+0x9a>
    release(&kmem.lock);
80102c38:	83 ec 0c             	sub    $0xc,%esp
80102c3b:	68 40 22 11 80       	push   $0x80112240
80102c40:	e8 c9 25 00 00       	call   8010520e <release>
80102c45:	83 c4 10             	add    $0x10,%esp
}
80102c48:	90                   	nop
80102c49:	c9                   	leave  
80102c4a:	c3                   	ret    

80102c4b <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102c4b:	55                   	push   %ebp
80102c4c:	89 e5                	mov    %esp,%ebp
80102c4e:	83 ec 18             	sub    $0x18,%esp
  struct run *r;

  if(kmem.use_lock)
80102c51:	a1 74 22 11 80       	mov    0x80112274,%eax
80102c56:	85 c0                	test   %eax,%eax
80102c58:	74 10                	je     80102c6a <kalloc+0x1f>
    acquire(&kmem.lock);
80102c5a:	83 ec 0c             	sub    $0xc,%esp
80102c5d:	68 40 22 11 80       	push   $0x80112240
80102c62:	e8 40 25 00 00       	call   801051a7 <acquire>
80102c67:	83 c4 10             	add    $0x10,%esp
  r = kmem.freelist;
80102c6a:	a1 78 22 11 80       	mov    0x80112278,%eax
80102c6f:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(r)
80102c72:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80102c76:	74 0a                	je     80102c82 <kalloc+0x37>
    kmem.freelist = r->next;
80102c78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102c7b:	8b 00                	mov    (%eax),%eax
80102c7d:	a3 78 22 11 80       	mov    %eax,0x80112278
  if(kmem.use_lock)
80102c82:	a1 74 22 11 80       	mov    0x80112274,%eax
80102c87:	85 c0                	test   %eax,%eax
80102c89:	74 10                	je     80102c9b <kalloc+0x50>
    release(&kmem.lock);
80102c8b:	83 ec 0c             	sub    $0xc,%esp
80102c8e:	68 40 22 11 80       	push   $0x80112240
80102c93:	e8 76 25 00 00       	call   8010520e <release>
80102c98:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80102c9e:	c9                   	leave  
80102c9f:	c3                   	ret    

80102ca0 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102ca0:	55                   	push   %ebp
80102ca1:	89 e5                	mov    %esp,%ebp
80102ca3:	83 ec 14             	sub    $0x14,%esp
80102ca6:	8b 45 08             	mov    0x8(%ebp),%eax
80102ca9:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102cad:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102cb1:	89 c2                	mov    %eax,%edx
80102cb3:	ec                   	in     (%dx),%al
80102cb4:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102cb7:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102cbb:	c9                   	leave  
80102cbc:	c3                   	ret    

80102cbd <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102cbd:	55                   	push   %ebp
80102cbe:	89 e5                	mov    %esp,%ebp
80102cc0:	83 ec 10             	sub    $0x10,%esp
  static uchar *charcode[4] = {
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
80102cc3:	6a 64                	push   $0x64
80102cc5:	e8 d6 ff ff ff       	call   80102ca0 <inb>
80102cca:	83 c4 04             	add    $0x4,%esp
80102ccd:	0f b6 c0             	movzbl %al,%eax
80102cd0:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((st & KBS_DIB) == 0)
80102cd3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80102cd6:	83 e0 01             	and    $0x1,%eax
80102cd9:	85 c0                	test   %eax,%eax
80102cdb:	75 0a                	jne    80102ce7 <kbdgetc+0x2a>
    return -1;
80102cdd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ce2:	e9 23 01 00 00       	jmp    80102e0a <kbdgetc+0x14d>
  data = inb(KBDATAP);
80102ce7:	6a 60                	push   $0x60
80102ce9:	e8 b2 ff ff ff       	call   80102ca0 <inb>
80102cee:	83 c4 04             	add    $0x4,%esp
80102cf1:	0f b6 c0             	movzbl %al,%eax
80102cf4:	89 45 fc             	mov    %eax,-0x4(%ebp)

  if(data == 0xE0){
80102cf7:	81 7d fc e0 00 00 00 	cmpl   $0xe0,-0x4(%ebp)
80102cfe:	75 17                	jne    80102d17 <kbdgetc+0x5a>
    shift |= E0ESC;
80102d00:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d05:	83 c8 40             	or     $0x40,%eax
80102d08:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d0d:	b8 00 00 00 00       	mov    $0x0,%eax
80102d12:	e9 f3 00 00 00       	jmp    80102e0a <kbdgetc+0x14d>
  } else if(data & 0x80){
80102d17:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d1a:	25 80 00 00 00       	and    $0x80,%eax
80102d1f:	85 c0                	test   %eax,%eax
80102d21:	74 45                	je     80102d68 <kbdgetc+0xab>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
80102d23:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d28:	83 e0 40             	and    $0x40,%eax
80102d2b:	85 c0                	test   %eax,%eax
80102d2d:	75 08                	jne    80102d37 <kbdgetc+0x7a>
80102d2f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d32:	83 e0 7f             	and    $0x7f,%eax
80102d35:	eb 03                	jmp    80102d3a <kbdgetc+0x7d>
80102d37:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d3a:	89 45 fc             	mov    %eax,-0x4(%ebp)
    shift &= ~(shiftcode[data] | E0ESC);
80102d3d:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d40:	05 20 90 10 80       	add    $0x80109020,%eax
80102d45:	0f b6 00             	movzbl (%eax),%eax
80102d48:	83 c8 40             	or     $0x40,%eax
80102d4b:	0f b6 c0             	movzbl %al,%eax
80102d4e:	f7 d0                	not    %eax
80102d50:	89 c2                	mov    %eax,%edx
80102d52:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d57:	21 d0                	and    %edx,%eax
80102d59:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
    return 0;
80102d5e:	b8 00 00 00 00       	mov    $0x0,%eax
80102d63:	e9 a2 00 00 00       	jmp    80102e0a <kbdgetc+0x14d>
  } else if(shift & E0ESC){
80102d68:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d6d:	83 e0 40             	and    $0x40,%eax
80102d70:	85 c0                	test   %eax,%eax
80102d72:	74 14                	je     80102d88 <kbdgetc+0xcb>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102d74:	81 4d fc 80 00 00 00 	orl    $0x80,-0x4(%ebp)
    shift &= ~E0ESC;
80102d7b:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d80:	83 e0 bf             	and    $0xffffffbf,%eax
80102d83:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  }

  shift |= shiftcode[data];
80102d88:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102d8b:	05 20 90 10 80       	add    $0x80109020,%eax
80102d90:	0f b6 00             	movzbl (%eax),%eax
80102d93:	0f b6 d0             	movzbl %al,%edx
80102d96:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102d9b:	09 d0                	or     %edx,%eax
80102d9d:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  shift ^= togglecode[data];
80102da2:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102da5:	05 20 91 10 80       	add    $0x80109120,%eax
80102daa:	0f b6 00             	movzbl (%eax),%eax
80102dad:	0f b6 d0             	movzbl %al,%edx
80102db0:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102db5:	31 d0                	xor    %edx,%eax
80102db7:	a3 3c b6 10 80       	mov    %eax,0x8010b63c
  c = charcode[shift & (CTL | SHIFT)][data];
80102dbc:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dc1:	83 e0 03             	and    $0x3,%eax
80102dc4:	8b 14 85 20 95 10 80 	mov    -0x7fef6ae0(,%eax,4),%edx
80102dcb:	8b 45 fc             	mov    -0x4(%ebp),%eax
80102dce:	01 d0                	add    %edx,%eax
80102dd0:	0f b6 00             	movzbl (%eax),%eax
80102dd3:	0f b6 c0             	movzbl %al,%eax
80102dd6:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(shift & CAPSLOCK){
80102dd9:	a1 3c b6 10 80       	mov    0x8010b63c,%eax
80102dde:	83 e0 08             	and    $0x8,%eax
80102de1:	85 c0                	test   %eax,%eax
80102de3:	74 22                	je     80102e07 <kbdgetc+0x14a>
    if('a' <= c && c <= 'z')
80102de5:	83 7d f8 60          	cmpl   $0x60,-0x8(%ebp)
80102de9:	76 0c                	jbe    80102df7 <kbdgetc+0x13a>
80102deb:	83 7d f8 7a          	cmpl   $0x7a,-0x8(%ebp)
80102def:	77 06                	ja     80102df7 <kbdgetc+0x13a>
      c += 'A' - 'a';
80102df1:	83 6d f8 20          	subl   $0x20,-0x8(%ebp)
80102df5:	eb 10                	jmp    80102e07 <kbdgetc+0x14a>
    else if('A' <= c && c <= 'Z')
80102df7:	83 7d f8 40          	cmpl   $0x40,-0x8(%ebp)
80102dfb:	76 0a                	jbe    80102e07 <kbdgetc+0x14a>
80102dfd:	83 7d f8 5a          	cmpl   $0x5a,-0x8(%ebp)
80102e01:	77 04                	ja     80102e07 <kbdgetc+0x14a>
      c += 'a' - 'A';
80102e03:	83 45 f8 20          	addl   $0x20,-0x8(%ebp)
  }
  return c;
80102e07:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80102e0a:	c9                   	leave  
80102e0b:	c3                   	ret    

80102e0c <kbdintr>:

void
kbdintr(void)
{
80102e0c:	55                   	push   %ebp
80102e0d:	89 e5                	mov    %esp,%ebp
80102e0f:	83 ec 08             	sub    $0x8,%esp
  consoleintr(kbdgetc);
80102e12:	83 ec 0c             	sub    $0xc,%esp
80102e15:	68 bd 2c 10 80       	push   $0x80102cbd
80102e1a:	e8 be d9 ff ff       	call   801007dd <consoleintr>
80102e1f:	83 c4 10             	add    $0x10,%esp
}
80102e22:	90                   	nop
80102e23:	c9                   	leave  
80102e24:	c3                   	ret    

80102e25 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80102e25:	55                   	push   %ebp
80102e26:	89 e5                	mov    %esp,%ebp
80102e28:	83 ec 14             	sub    $0x14,%esp
80102e2b:	8b 45 08             	mov    0x8(%ebp),%eax
80102e2e:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e32:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80102e36:	89 c2                	mov    %eax,%edx
80102e38:	ec                   	in     (%dx),%al
80102e39:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80102e3c:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80102e40:	c9                   	leave  
80102e41:	c3                   	ret    

80102e42 <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80102e42:	55                   	push   %ebp
80102e43:	89 e5                	mov    %esp,%ebp
80102e45:	83 ec 08             	sub    $0x8,%esp
80102e48:	8b 55 08             	mov    0x8(%ebp),%edx
80102e4b:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e4e:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80102e52:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e55:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80102e59:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80102e5d:	ee                   	out    %al,(%dx)
}
80102e5e:	90                   	nop
80102e5f:	c9                   	leave  
80102e60:	c3                   	ret    

80102e61 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80102e61:	55                   	push   %ebp
80102e62:	89 e5                	mov    %esp,%ebp
80102e64:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80102e67:	9c                   	pushf  
80102e68:	58                   	pop    %eax
80102e69:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80102e6c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80102e6f:	c9                   	leave  
80102e70:	c3                   	ret    

80102e71 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102e71:	55                   	push   %ebp
80102e72:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102e74:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e79:	8b 55 08             	mov    0x8(%ebp),%edx
80102e7c:	c1 e2 02             	shl    $0x2,%edx
80102e7f:	01 c2                	add    %eax,%edx
80102e81:	8b 45 0c             	mov    0xc(%ebp),%eax
80102e84:	89 02                	mov    %eax,(%edx)
  lapic[ID];  // wait for write to finish, by reading
80102e86:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e8b:	83 c0 20             	add    $0x20,%eax
80102e8e:	8b 00                	mov    (%eax),%eax
}
80102e90:	90                   	nop
80102e91:	5d                   	pop    %ebp
80102e92:	c3                   	ret    

80102e93 <lapicinit>:
//PAGEBREAK!

void
lapicinit(void)
{
80102e93:	55                   	push   %ebp
80102e94:	89 e5                	mov    %esp,%ebp
  if(!lapic) 
80102e96:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102e9b:	85 c0                	test   %eax,%eax
80102e9d:	0f 84 0b 01 00 00    	je     80102fae <lapicinit+0x11b>
    return;

  // Enable local APIC; set spurious interrupt vector.
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102ea3:	68 3f 01 00 00       	push   $0x13f
80102ea8:	6a 3c                	push   $0x3c
80102eaa:	e8 c2 ff ff ff       	call   80102e71 <lapicw>
80102eaf:	83 c4 08             	add    $0x8,%esp

  // The timer repeatedly counts down at bus frequency
  // from lapic[TICR] and then issues an interrupt.  
  // If xv6 cared more about precise timekeeping,
  // TICR would be calibrated using an external time source.
  lapicw(TDCR, X1);
80102eb2:	6a 0b                	push   $0xb
80102eb4:	68 f8 00 00 00       	push   $0xf8
80102eb9:	e8 b3 ff ff ff       	call   80102e71 <lapicw>
80102ebe:	83 c4 08             	add    $0x8,%esp
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102ec1:	68 20 00 02 00       	push   $0x20020
80102ec6:	68 c8 00 00 00       	push   $0xc8
80102ecb:	e8 a1 ff ff ff       	call   80102e71 <lapicw>
80102ed0:	83 c4 08             	add    $0x8,%esp
  lapicw(TICR, 10000000); 
80102ed3:	68 80 96 98 00       	push   $0x989680
80102ed8:	68 e0 00 00 00       	push   $0xe0
80102edd:	e8 8f ff ff ff       	call   80102e71 <lapicw>
80102ee2:	83 c4 08             	add    $0x8,%esp

  // Disable logical interrupt lines.
  lapicw(LINT0, MASKED);
80102ee5:	68 00 00 01 00       	push   $0x10000
80102eea:	68 d4 00 00 00       	push   $0xd4
80102eef:	e8 7d ff ff ff       	call   80102e71 <lapicw>
80102ef4:	83 c4 08             	add    $0x8,%esp
  lapicw(LINT1, MASKED);
80102ef7:	68 00 00 01 00       	push   $0x10000
80102efc:	68 d8 00 00 00       	push   $0xd8
80102f01:	e8 6b ff ff ff       	call   80102e71 <lapicw>
80102f06:	83 c4 08             	add    $0x8,%esp

  // Disable performance counter overflow interrupts
  // on machines that provide that interrupt entry.
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102f09:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f0e:	83 c0 30             	add    $0x30,%eax
80102f11:	8b 00                	mov    (%eax),%eax
80102f13:	c1 e8 10             	shr    $0x10,%eax
80102f16:	0f b6 c0             	movzbl %al,%eax
80102f19:	83 f8 03             	cmp    $0x3,%eax
80102f1c:	76 12                	jbe    80102f30 <lapicinit+0x9d>
    lapicw(PCINT, MASKED);
80102f1e:	68 00 00 01 00       	push   $0x10000
80102f23:	68 d0 00 00 00       	push   $0xd0
80102f28:	e8 44 ff ff ff       	call   80102e71 <lapicw>
80102f2d:	83 c4 08             	add    $0x8,%esp

  // Map error interrupt to IRQ_ERROR.
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102f30:	6a 33                	push   $0x33
80102f32:	68 dc 00 00 00       	push   $0xdc
80102f37:	e8 35 ff ff ff       	call   80102e71 <lapicw>
80102f3c:	83 c4 08             	add    $0x8,%esp

  // Clear error status register (requires back-to-back writes).
  lapicw(ESR, 0);
80102f3f:	6a 00                	push   $0x0
80102f41:	68 a0 00 00 00       	push   $0xa0
80102f46:	e8 26 ff ff ff       	call   80102e71 <lapicw>
80102f4b:	83 c4 08             	add    $0x8,%esp
  lapicw(ESR, 0);
80102f4e:	6a 00                	push   $0x0
80102f50:	68 a0 00 00 00       	push   $0xa0
80102f55:	e8 17 ff ff ff       	call   80102e71 <lapicw>
80102f5a:	83 c4 08             	add    $0x8,%esp

  // Ack any outstanding interrupts.
  lapicw(EOI, 0);
80102f5d:	6a 00                	push   $0x0
80102f5f:	6a 2c                	push   $0x2c
80102f61:	e8 0b ff ff ff       	call   80102e71 <lapicw>
80102f66:	83 c4 08             	add    $0x8,%esp

  // Send an Init Level De-Assert to synchronise arbitration ID's.
  lapicw(ICRHI, 0);
80102f69:	6a 00                	push   $0x0
80102f6b:	68 c4 00 00 00       	push   $0xc4
80102f70:	e8 fc fe ff ff       	call   80102e71 <lapicw>
80102f75:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102f78:	68 00 85 08 00       	push   $0x88500
80102f7d:	68 c0 00 00 00       	push   $0xc0
80102f82:	e8 ea fe ff ff       	call   80102e71 <lapicw>
80102f87:	83 c4 08             	add    $0x8,%esp
  while(lapic[ICRLO] & DELIVS)
80102f8a:	90                   	nop
80102f8b:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102f90:	05 00 03 00 00       	add    $0x300,%eax
80102f95:	8b 00                	mov    (%eax),%eax
80102f97:	25 00 10 00 00       	and    $0x1000,%eax
80102f9c:	85 c0                	test   %eax,%eax
80102f9e:	75 eb                	jne    80102f8b <lapicinit+0xf8>
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
80102fa0:	6a 00                	push   $0x0
80102fa2:	6a 20                	push   $0x20
80102fa4:	e8 c8 fe ff ff       	call   80102e71 <lapicw>
80102fa9:	83 c4 08             	add    $0x8,%esp
80102fac:	eb 01                	jmp    80102faf <lapicinit+0x11c>

void
lapicinit(void)
{
  if(!lapic) 
    return;
80102fae:	90                   	nop
  while(lapic[ICRLO] & DELIVS)
    ;

  // Enable interrupts on the APIC (but not on the processor).
  lapicw(TPR, 0);
}
80102faf:	c9                   	leave  
80102fb0:	c3                   	ret    

80102fb1 <cpunum>:

int
cpunum(void)
{
80102fb1:	55                   	push   %ebp
80102fb2:	89 e5                	mov    %esp,%ebp
80102fb4:	83 ec 08             	sub    $0x8,%esp
  // Cannot call cpu when interrupts are enabled:
  // result not guaranteed to last long enough to be used!
  // Would prefer to panic but even printing is chancy here:
  // almost everything, including cprintf and panic, calls cpu,
  // often indirectly through acquire and release.
  if(readeflags()&FL_IF){
80102fb7:	e8 a5 fe ff ff       	call   80102e61 <readeflags>
80102fbc:	25 00 02 00 00       	and    $0x200,%eax
80102fc1:	85 c0                	test   %eax,%eax
80102fc3:	74 26                	je     80102feb <cpunum+0x3a>
    static int n;
    if(n++ == 0)
80102fc5:	a1 40 b6 10 80       	mov    0x8010b640,%eax
80102fca:	8d 50 01             	lea    0x1(%eax),%edx
80102fcd:	89 15 40 b6 10 80    	mov    %edx,0x8010b640
80102fd3:	85 c0                	test   %eax,%eax
80102fd5:	75 14                	jne    80102feb <cpunum+0x3a>
      cprintf("cpu called from %x with interrupts enabled\n",
80102fd7:	8b 45 04             	mov    0x4(%ebp),%eax
80102fda:	83 ec 08             	sub    $0x8,%esp
80102fdd:	50                   	push   %eax
80102fde:	68 bc 89 10 80       	push   $0x801089bc
80102fe3:	e8 de d3 ff ff       	call   801003c6 <cprintf>
80102fe8:	83 c4 10             	add    $0x10,%esp
        __builtin_return_address(0));
  }

  if(lapic)
80102feb:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102ff0:	85 c0                	test   %eax,%eax
80102ff2:	74 0f                	je     80103003 <cpunum+0x52>
    return lapic[ID]>>24;
80102ff4:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80102ff9:	83 c0 20             	add    $0x20,%eax
80102ffc:	8b 00                	mov    (%eax),%eax
80102ffe:	c1 e8 18             	shr    $0x18,%eax
80103001:	eb 05                	jmp    80103008 <cpunum+0x57>
  return 0;
80103003:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103008:	c9                   	leave  
80103009:	c3                   	ret    

8010300a <lapiceoi>:

// Acknowledge interrupt.
void
lapiceoi(void)
{
8010300a:	55                   	push   %ebp
8010300b:	89 e5                	mov    %esp,%ebp
  if(lapic)
8010300d:	a1 7c 22 11 80       	mov    0x8011227c,%eax
80103012:	85 c0                	test   %eax,%eax
80103014:	74 0c                	je     80103022 <lapiceoi+0x18>
    lapicw(EOI, 0);
80103016:	6a 00                	push   $0x0
80103018:	6a 2c                	push   $0x2c
8010301a:	e8 52 fe ff ff       	call   80102e71 <lapicw>
8010301f:	83 c4 08             	add    $0x8,%esp
}
80103022:	90                   	nop
80103023:	c9                   	leave  
80103024:	c3                   	ret    

80103025 <microdelay>:

// Spin for a given number of microseconds.
// On real hardware would want to tune this dynamically.
void
microdelay(int us)
{
80103025:	55                   	push   %ebp
80103026:	89 e5                	mov    %esp,%ebp
}
80103028:	90                   	nop
80103029:	5d                   	pop    %ebp
8010302a:	c3                   	ret    

8010302b <lapicstartap>:

// Start additional processor running entry code at addr.
// See Appendix B of MultiProcessor Specification.
void
lapicstartap(uchar apicid, uint addr)
{
8010302b:	55                   	push   %ebp
8010302c:	89 e5                	mov    %esp,%ebp
8010302e:	83 ec 14             	sub    $0x14,%esp
80103031:	8b 45 08             	mov    0x8(%ebp),%eax
80103034:	88 45 ec             	mov    %al,-0x14(%ebp)
  ushort *wrv;
  
  // "The BSP must initialize CMOS shutdown code to 0AH
  // and the warm reset vector (DWORD based at 40:67) to point at
  // the AP startup code prior to the [universal startup algorithm]."
  outb(CMOS_PORT, 0xF);  // offset 0xF is shutdown code
80103037:	6a 0f                	push   $0xf
80103039:	6a 70                	push   $0x70
8010303b:	e8 02 fe ff ff       	call   80102e42 <outb>
80103040:	83 c4 08             	add    $0x8,%esp
  outb(CMOS_PORT+1, 0x0A);
80103043:	6a 0a                	push   $0xa
80103045:	6a 71                	push   $0x71
80103047:	e8 f6 fd ff ff       	call   80102e42 <outb>
8010304c:	83 c4 08             	add    $0x8,%esp
  wrv = (ushort*)P2V((0x40<<4 | 0x67));  // Warm reset vector
8010304f:	c7 45 f8 67 04 00 80 	movl   $0x80000467,-0x8(%ebp)
  wrv[0] = 0;
80103056:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103059:	66 c7 00 00 00       	movw   $0x0,(%eax)
  wrv[1] = addr >> 4;
8010305e:	8b 45 f8             	mov    -0x8(%ebp),%eax
80103061:	83 c0 02             	add    $0x2,%eax
80103064:	8b 55 0c             	mov    0xc(%ebp),%edx
80103067:	c1 ea 04             	shr    $0x4,%edx
8010306a:	66 89 10             	mov    %dx,(%eax)

  // "Universal startup algorithm."
  // Send INIT (level-triggered) interrupt to reset other CPU.
  lapicw(ICRHI, apicid<<24);
8010306d:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
80103071:	c1 e0 18             	shl    $0x18,%eax
80103074:	50                   	push   %eax
80103075:	68 c4 00 00 00       	push   $0xc4
8010307a:	e8 f2 fd ff ff       	call   80102e71 <lapicw>
8010307f:	83 c4 08             	add    $0x8,%esp
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80103082:	68 00 c5 00 00       	push   $0xc500
80103087:	68 c0 00 00 00       	push   $0xc0
8010308c:	e8 e0 fd ff ff       	call   80102e71 <lapicw>
80103091:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103094:	68 c8 00 00 00       	push   $0xc8
80103099:	e8 87 ff ff ff       	call   80103025 <microdelay>
8010309e:	83 c4 04             	add    $0x4,%esp
  lapicw(ICRLO, INIT | LEVEL);
801030a1:	68 00 85 00 00       	push   $0x8500
801030a6:	68 c0 00 00 00       	push   $0xc0
801030ab:	e8 c1 fd ff ff       	call   80102e71 <lapicw>
801030b0:	83 c4 08             	add    $0x8,%esp
  microdelay(100);    // should be 10ms, but too slow in Bochs!
801030b3:	6a 64                	push   $0x64
801030b5:	e8 6b ff ff ff       	call   80103025 <microdelay>
801030ba:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030bd:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801030c4:	eb 3d                	jmp    80103103 <lapicstartap+0xd8>
    lapicw(ICRHI, apicid<<24);
801030c6:	0f b6 45 ec          	movzbl -0x14(%ebp),%eax
801030ca:	c1 e0 18             	shl    $0x18,%eax
801030cd:	50                   	push   %eax
801030ce:	68 c4 00 00 00       	push   $0xc4
801030d3:	e8 99 fd ff ff       	call   80102e71 <lapicw>
801030d8:	83 c4 08             	add    $0x8,%esp
    lapicw(ICRLO, STARTUP | (addr>>12));
801030db:	8b 45 0c             	mov    0xc(%ebp),%eax
801030de:	c1 e8 0c             	shr    $0xc,%eax
801030e1:	80 cc 06             	or     $0x6,%ah
801030e4:	50                   	push   %eax
801030e5:	68 c0 00 00 00       	push   $0xc0
801030ea:	e8 82 fd ff ff       	call   80102e71 <lapicw>
801030ef:	83 c4 08             	add    $0x8,%esp
    microdelay(200);
801030f2:	68 c8 00 00 00       	push   $0xc8
801030f7:	e8 29 ff ff ff       	call   80103025 <microdelay>
801030fc:	83 c4 04             	add    $0x4,%esp
  // Send startup IPI (twice!) to enter code.
  // Regular hardware is supposed to only accept a STARTUP
  // when it is in the halted state due to an INIT.  So the second
  // should be ignored, but it is part of the official Intel algorithm.
  // Bochs complains about the second one.  Too bad for Bochs.
  for(i = 0; i < 2; i++){
801030ff:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103103:	83 7d fc 01          	cmpl   $0x1,-0x4(%ebp)
80103107:	7e bd                	jle    801030c6 <lapicstartap+0x9b>
    lapicw(ICRHI, apicid<<24);
    lapicw(ICRLO, STARTUP | (addr>>12));
    microdelay(200);
  }
}
80103109:	90                   	nop
8010310a:	c9                   	leave  
8010310b:	c3                   	ret    

8010310c <cmos_read>:
#define DAY     0x07
#define MONTH   0x08
#define YEAR    0x09

static uint cmos_read(uint reg)
{
8010310c:	55                   	push   %ebp
8010310d:	89 e5                	mov    %esp,%ebp
  outb(CMOS_PORT,  reg);
8010310f:	8b 45 08             	mov    0x8(%ebp),%eax
80103112:	0f b6 c0             	movzbl %al,%eax
80103115:	50                   	push   %eax
80103116:	6a 70                	push   $0x70
80103118:	e8 25 fd ff ff       	call   80102e42 <outb>
8010311d:	83 c4 08             	add    $0x8,%esp
  microdelay(200);
80103120:	68 c8 00 00 00       	push   $0xc8
80103125:	e8 fb fe ff ff       	call   80103025 <microdelay>
8010312a:	83 c4 04             	add    $0x4,%esp

  return inb(CMOS_RETURN);
8010312d:	6a 71                	push   $0x71
8010312f:	e8 f1 fc ff ff       	call   80102e25 <inb>
80103134:	83 c4 04             	add    $0x4,%esp
80103137:	0f b6 c0             	movzbl %al,%eax
}
8010313a:	c9                   	leave  
8010313b:	c3                   	ret    

8010313c <fill_rtcdate>:

static void fill_rtcdate(struct rtcdate *r)
{
8010313c:	55                   	push   %ebp
8010313d:	89 e5                	mov    %esp,%ebp
  r->second = cmos_read(SECS);
8010313f:	6a 00                	push   $0x0
80103141:	e8 c6 ff ff ff       	call   8010310c <cmos_read>
80103146:	83 c4 04             	add    $0x4,%esp
80103149:	89 c2                	mov    %eax,%edx
8010314b:	8b 45 08             	mov    0x8(%ebp),%eax
8010314e:	89 10                	mov    %edx,(%eax)
  r->minute = cmos_read(MINS);
80103150:	6a 02                	push   $0x2
80103152:	e8 b5 ff ff ff       	call   8010310c <cmos_read>
80103157:	83 c4 04             	add    $0x4,%esp
8010315a:	89 c2                	mov    %eax,%edx
8010315c:	8b 45 08             	mov    0x8(%ebp),%eax
8010315f:	89 50 04             	mov    %edx,0x4(%eax)
  r->hour   = cmos_read(HOURS);
80103162:	6a 04                	push   $0x4
80103164:	e8 a3 ff ff ff       	call   8010310c <cmos_read>
80103169:	83 c4 04             	add    $0x4,%esp
8010316c:	89 c2                	mov    %eax,%edx
8010316e:	8b 45 08             	mov    0x8(%ebp),%eax
80103171:	89 50 08             	mov    %edx,0x8(%eax)
  r->day    = cmos_read(DAY);
80103174:	6a 07                	push   $0x7
80103176:	e8 91 ff ff ff       	call   8010310c <cmos_read>
8010317b:	83 c4 04             	add    $0x4,%esp
8010317e:	89 c2                	mov    %eax,%edx
80103180:	8b 45 08             	mov    0x8(%ebp),%eax
80103183:	89 50 0c             	mov    %edx,0xc(%eax)
  r->month  = cmos_read(MONTH);
80103186:	6a 08                	push   $0x8
80103188:	e8 7f ff ff ff       	call   8010310c <cmos_read>
8010318d:	83 c4 04             	add    $0x4,%esp
80103190:	89 c2                	mov    %eax,%edx
80103192:	8b 45 08             	mov    0x8(%ebp),%eax
80103195:	89 50 10             	mov    %edx,0x10(%eax)
  r->year   = cmos_read(YEAR);
80103198:	6a 09                	push   $0x9
8010319a:	e8 6d ff ff ff       	call   8010310c <cmos_read>
8010319f:	83 c4 04             	add    $0x4,%esp
801031a2:	89 c2                	mov    %eax,%edx
801031a4:	8b 45 08             	mov    0x8(%ebp),%eax
801031a7:	89 50 14             	mov    %edx,0x14(%eax)
}
801031aa:	90                   	nop
801031ab:	c9                   	leave  
801031ac:	c3                   	ret    

801031ad <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void cmostime(struct rtcdate *r)
{
801031ad:	55                   	push   %ebp
801031ae:	89 e5                	mov    %esp,%ebp
801031b0:	83 ec 48             	sub    $0x48,%esp
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801031b3:	6a 0b                	push   $0xb
801031b5:	e8 52 ff ff ff       	call   8010310c <cmos_read>
801031ba:	83 c4 04             	add    $0x4,%esp
801031bd:	89 45 f4             	mov    %eax,-0xc(%ebp)

  bcd = (sb & (1 << 2)) == 0;
801031c0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801031c3:	83 e0 04             	and    $0x4,%eax
801031c6:	85 c0                	test   %eax,%eax
801031c8:	0f 94 c0             	sete   %al
801031cb:	0f b6 c0             	movzbl %al,%eax
801031ce:	89 45 f0             	mov    %eax,-0x10(%ebp)

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
801031d1:	8d 45 d8             	lea    -0x28(%ebp),%eax
801031d4:	50                   	push   %eax
801031d5:	e8 62 ff ff ff       	call   8010313c <fill_rtcdate>
801031da:	83 c4 04             	add    $0x4,%esp
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
801031dd:	6a 0a                	push   $0xa
801031df:	e8 28 ff ff ff       	call   8010310c <cmos_read>
801031e4:	83 c4 04             	add    $0x4,%esp
801031e7:	25 80 00 00 00       	and    $0x80,%eax
801031ec:	85 c0                	test   %eax,%eax
801031ee:	75 27                	jne    80103217 <cmostime+0x6a>
        continue;
    fill_rtcdate(&t2);
801031f0:	8d 45 c0             	lea    -0x40(%ebp),%eax
801031f3:	50                   	push   %eax
801031f4:	e8 43 ff ff ff       	call   8010313c <fill_rtcdate>
801031f9:	83 c4 04             	add    $0x4,%esp
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
801031fc:	83 ec 04             	sub    $0x4,%esp
801031ff:	6a 18                	push   $0x18
80103201:	8d 45 c0             	lea    -0x40(%ebp),%eax
80103204:	50                   	push   %eax
80103205:	8d 45 d8             	lea    -0x28(%ebp),%eax
80103208:	50                   	push   %eax
80103209:	e8 63 22 00 00       	call   80105471 <memcmp>
8010320e:	83 c4 10             	add    $0x10,%esp
80103211:	85 c0                	test   %eax,%eax
80103213:	74 05                	je     8010321a <cmostime+0x6d>
80103215:	eb ba                	jmp    801031d1 <cmostime+0x24>

  // make sure CMOS doesn't modify time while we read it
  for (;;) {
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
80103217:	90                   	nop
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
  }
80103218:	eb b7                	jmp    801031d1 <cmostime+0x24>
    fill_rtcdate(&t1);
    if (cmos_read(CMOS_STATA) & CMOS_UIP)
        continue;
    fill_rtcdate(&t2);
    if (memcmp(&t1, &t2, sizeof(t1)) == 0)
      break;
8010321a:	90                   	nop
  }

  // convert
  if (bcd) {
8010321b:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010321f:	0f 84 b4 00 00 00    	je     801032d9 <cmostime+0x12c>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80103225:	8b 45 d8             	mov    -0x28(%ebp),%eax
80103228:	c1 e8 04             	shr    $0x4,%eax
8010322b:	89 c2                	mov    %eax,%edx
8010322d:	89 d0                	mov    %edx,%eax
8010322f:	c1 e0 02             	shl    $0x2,%eax
80103232:	01 d0                	add    %edx,%eax
80103234:	01 c0                	add    %eax,%eax
80103236:	89 c2                	mov    %eax,%edx
80103238:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010323b:	83 e0 0f             	and    $0xf,%eax
8010323e:	01 d0                	add    %edx,%eax
80103240:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(minute);
80103243:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103246:	c1 e8 04             	shr    $0x4,%eax
80103249:	89 c2                	mov    %eax,%edx
8010324b:	89 d0                	mov    %edx,%eax
8010324d:	c1 e0 02             	shl    $0x2,%eax
80103250:	01 d0                	add    %edx,%eax
80103252:	01 c0                	add    %eax,%eax
80103254:	89 c2                	mov    %eax,%edx
80103256:	8b 45 dc             	mov    -0x24(%ebp),%eax
80103259:	83 e0 0f             	and    $0xf,%eax
8010325c:	01 d0                	add    %edx,%eax
8010325e:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(hour  );
80103261:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103264:	c1 e8 04             	shr    $0x4,%eax
80103267:	89 c2                	mov    %eax,%edx
80103269:	89 d0                	mov    %edx,%eax
8010326b:	c1 e0 02             	shl    $0x2,%eax
8010326e:	01 d0                	add    %edx,%eax
80103270:	01 c0                	add    %eax,%eax
80103272:	89 c2                	mov    %eax,%edx
80103274:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103277:	83 e0 0f             	and    $0xf,%eax
8010327a:	01 d0                	add    %edx,%eax
8010327c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(day   );
8010327f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103282:	c1 e8 04             	shr    $0x4,%eax
80103285:	89 c2                	mov    %eax,%edx
80103287:	89 d0                	mov    %edx,%eax
80103289:	c1 e0 02             	shl    $0x2,%eax
8010328c:	01 d0                	add    %edx,%eax
8010328e:	01 c0                	add    %eax,%eax
80103290:	89 c2                	mov    %eax,%edx
80103292:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103295:	83 e0 0f             	and    $0xf,%eax
80103298:	01 d0                	add    %edx,%eax
8010329a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    CONV(month );
8010329d:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032a0:	c1 e8 04             	shr    $0x4,%eax
801032a3:	89 c2                	mov    %eax,%edx
801032a5:	89 d0                	mov    %edx,%eax
801032a7:	c1 e0 02             	shl    $0x2,%eax
801032aa:	01 d0                	add    %edx,%eax
801032ac:	01 c0                	add    %eax,%eax
801032ae:	89 c2                	mov    %eax,%edx
801032b0:	8b 45 e8             	mov    -0x18(%ebp),%eax
801032b3:	83 e0 0f             	and    $0xf,%eax
801032b6:	01 d0                	add    %edx,%eax
801032b8:	89 45 e8             	mov    %eax,-0x18(%ebp)
    CONV(year  );
801032bb:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032be:	c1 e8 04             	shr    $0x4,%eax
801032c1:	89 c2                	mov    %eax,%edx
801032c3:	89 d0                	mov    %edx,%eax
801032c5:	c1 e0 02             	shl    $0x2,%eax
801032c8:	01 d0                	add    %edx,%eax
801032ca:	01 c0                	add    %eax,%eax
801032cc:	89 c2                	mov    %eax,%edx
801032ce:	8b 45 ec             	mov    -0x14(%ebp),%eax
801032d1:	83 e0 0f             	and    $0xf,%eax
801032d4:	01 d0                	add    %edx,%eax
801032d6:	89 45 ec             	mov    %eax,-0x14(%ebp)
#undef     CONV
  }

  *r = t1;
801032d9:	8b 45 08             	mov    0x8(%ebp),%eax
801032dc:	8b 55 d8             	mov    -0x28(%ebp),%edx
801032df:	89 10                	mov    %edx,(%eax)
801032e1:	8b 55 dc             	mov    -0x24(%ebp),%edx
801032e4:	89 50 04             	mov    %edx,0x4(%eax)
801032e7:	8b 55 e0             	mov    -0x20(%ebp),%edx
801032ea:	89 50 08             	mov    %edx,0x8(%eax)
801032ed:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801032f0:	89 50 0c             	mov    %edx,0xc(%eax)
801032f3:	8b 55 e8             	mov    -0x18(%ebp),%edx
801032f6:	89 50 10             	mov    %edx,0x10(%eax)
801032f9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801032fc:	89 50 14             	mov    %edx,0x14(%eax)
  r->year += 2000;
801032ff:	8b 45 08             	mov    0x8(%ebp),%eax
80103302:	8b 40 14             	mov    0x14(%eax),%eax
80103305:	8d 90 d0 07 00 00    	lea    0x7d0(%eax),%edx
8010330b:	8b 45 08             	mov    0x8(%ebp),%eax
8010330e:	89 50 14             	mov    %edx,0x14(%eax)
}
80103311:	90                   	nop
80103312:	c9                   	leave  
80103313:	c3                   	ret    

80103314 <initlog>:
static void recover_from_log(void);
static void commit();

void
initlog(int dev)
{
80103314:	55                   	push   %ebp
80103315:	89 e5                	mov    %esp,%ebp
80103317:	83 ec 28             	sub    $0x28,%esp
  if (sizeof(struct logheader) >= BSIZE)
    panic("initlog: too big logheader");

  struct superblock sb;
  initlock(&log.lock, "log");
8010331a:	83 ec 08             	sub    $0x8,%esp
8010331d:	68 e8 89 10 80       	push   $0x801089e8
80103322:	68 80 22 11 80       	push   $0x80112280
80103327:	e8 59 1e 00 00       	call   80105185 <initlock>
8010332c:	83 c4 10             	add    $0x10,%esp
  readsb(dev, &sb);
8010332f:	83 ec 08             	sub    $0x8,%esp
80103332:	8d 45 dc             	lea    -0x24(%ebp),%eax
80103335:	50                   	push   %eax
80103336:	ff 75 08             	pushl  0x8(%ebp)
80103339:	e8 2b e0 ff ff       	call   80101369 <readsb>
8010333e:	83 c4 10             	add    $0x10,%esp
  log.start = sb.logstart;
80103341:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103344:	a3 b4 22 11 80       	mov    %eax,0x801122b4
  log.size = sb.nlog;
80103349:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010334c:	a3 b8 22 11 80       	mov    %eax,0x801122b8
  log.dev = dev;
80103351:	8b 45 08             	mov    0x8(%ebp),%eax
80103354:	a3 c4 22 11 80       	mov    %eax,0x801122c4
  recover_from_log();
80103359:	e8 b2 01 00 00       	call   80103510 <recover_from_log>
}
8010335e:	90                   	nop
8010335f:	c9                   	leave  
80103360:	c3                   	ret    

80103361 <install_trans>:

// Copy committed blocks from log to their home location
static void 
install_trans(void)
{
80103361:	55                   	push   %ebp
80103362:	89 e5                	mov    %esp,%ebp
80103364:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103367:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010336e:	e9 95 00 00 00       	jmp    80103408 <install_trans+0xa7>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80103373:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
80103379:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010337c:	01 d0                	add    %edx,%eax
8010337e:	83 c0 01             	add    $0x1,%eax
80103381:	89 c2                	mov    %eax,%edx
80103383:	a1 c4 22 11 80       	mov    0x801122c4,%eax
80103388:	83 ec 08             	sub    $0x8,%esp
8010338b:	52                   	push   %edx
8010338c:	50                   	push   %eax
8010338d:	e8 24 ce ff ff       	call   801001b6 <bread>
80103392:	83 c4 10             	add    $0x10,%esp
80103395:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80103398:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010339b:	83 c0 10             	add    $0x10,%eax
8010339e:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
801033a5:	89 c2                	mov    %eax,%edx
801033a7:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801033ac:	83 ec 08             	sub    $0x8,%esp
801033af:	52                   	push   %edx
801033b0:	50                   	push   %eax
801033b1:	e8 00 ce ff ff       	call   801001b6 <bread>
801033b6:	83 c4 10             	add    $0x10,%esp
801033b9:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801033bc:	8b 45 f0             	mov    -0x10(%ebp),%eax
801033bf:	8d 50 18             	lea    0x18(%eax),%edx
801033c2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801033c5:	83 c0 18             	add    $0x18,%eax
801033c8:	83 ec 04             	sub    $0x4,%esp
801033cb:	68 00 02 00 00       	push   $0x200
801033d0:	52                   	push   %edx
801033d1:	50                   	push   %eax
801033d2:	e8 f2 20 00 00       	call   801054c9 <memmove>
801033d7:	83 c4 10             	add    $0x10,%esp
    bwrite(dbuf);  // write dst to disk
801033da:	83 ec 0c             	sub    $0xc,%esp
801033dd:	ff 75 ec             	pushl  -0x14(%ebp)
801033e0:	e8 0a ce ff ff       	call   801001ef <bwrite>
801033e5:	83 c4 10             	add    $0x10,%esp
    brelse(lbuf); 
801033e8:	83 ec 0c             	sub    $0xc,%esp
801033eb:	ff 75 f0             	pushl  -0x10(%ebp)
801033ee:	e8 3b ce ff ff       	call   8010022e <brelse>
801033f3:	83 c4 10             	add    $0x10,%esp
    brelse(dbuf);
801033f6:	83 ec 0c             	sub    $0xc,%esp
801033f9:	ff 75 ec             	pushl  -0x14(%ebp)
801033fc:	e8 2d ce ff ff       	call   8010022e <brelse>
80103401:	83 c4 10             	add    $0x10,%esp
static void 
install_trans(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103404:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103408:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010340d:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103410:	0f 8f 5d ff ff ff    	jg     80103373 <install_trans+0x12>
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    bwrite(dbuf);  // write dst to disk
    brelse(lbuf); 
    brelse(dbuf);
  }
}
80103416:	90                   	nop
80103417:	c9                   	leave  
80103418:	c3                   	ret    

80103419 <read_head>:

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
80103419:	55                   	push   %ebp
8010341a:	89 e5                	mov    %esp,%ebp
8010341c:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
8010341f:	a1 b4 22 11 80       	mov    0x801122b4,%eax
80103424:	89 c2                	mov    %eax,%edx
80103426:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010342b:	83 ec 08             	sub    $0x8,%esp
8010342e:	52                   	push   %edx
8010342f:	50                   	push   %eax
80103430:	e8 81 cd ff ff       	call   801001b6 <bread>
80103435:	83 c4 10             	add    $0x10,%esp
80103438:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *lh = (struct logheader *) (buf->data);
8010343b:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010343e:	83 c0 18             	add    $0x18,%eax
80103441:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  log.lh.n = lh->n;
80103444:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103447:	8b 00                	mov    (%eax),%eax
80103449:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  for (i = 0; i < log.lh.n; i++) {
8010344e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80103455:	eb 1b                	jmp    80103472 <read_head+0x59>
    log.lh.block[i] = lh->block[i];
80103457:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010345a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010345d:	8b 44 90 04          	mov    0x4(%eax,%edx,4),%eax
80103461:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103464:	83 c2 10             	add    $0x10,%edx
80103467:	89 04 95 8c 22 11 80 	mov    %eax,-0x7feedd74(,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
  for (i = 0; i < log.lh.n; i++) {
8010346e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103472:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103477:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010347a:	7f db                	jg     80103457 <read_head+0x3e>
    log.lh.block[i] = lh->block[i];
  }
  brelse(buf);
8010347c:	83 ec 0c             	sub    $0xc,%esp
8010347f:	ff 75 f0             	pushl  -0x10(%ebp)
80103482:	e8 a7 cd ff ff       	call   8010022e <brelse>
80103487:	83 c4 10             	add    $0x10,%esp
}
8010348a:	90                   	nop
8010348b:	c9                   	leave  
8010348c:	c3                   	ret    

8010348d <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
8010348d:	55                   	push   %ebp
8010348e:	89 e5                	mov    %esp,%ebp
80103490:	83 ec 18             	sub    $0x18,%esp
  struct buf *buf = bread(log.dev, log.start);
80103493:	a1 b4 22 11 80       	mov    0x801122b4,%eax
80103498:	89 c2                	mov    %eax,%edx
8010349a:	a1 c4 22 11 80       	mov    0x801122c4,%eax
8010349f:	83 ec 08             	sub    $0x8,%esp
801034a2:	52                   	push   %edx
801034a3:	50                   	push   %eax
801034a4:	e8 0d cd ff ff       	call   801001b6 <bread>
801034a9:	83 c4 10             	add    $0x10,%esp
801034ac:	89 45 f0             	mov    %eax,-0x10(%ebp)
  struct logheader *hb = (struct logheader *) (buf->data);
801034af:	8b 45 f0             	mov    -0x10(%ebp),%eax
801034b2:	83 c0 18             	add    $0x18,%eax
801034b5:	89 45 ec             	mov    %eax,-0x14(%ebp)
  int i;
  hb->n = log.lh.n;
801034b8:	8b 15 c8 22 11 80    	mov    0x801122c8,%edx
801034be:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034c1:	89 10                	mov    %edx,(%eax)
  for (i = 0; i < log.lh.n; i++) {
801034c3:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801034ca:	eb 1b                	jmp    801034e7 <write_head+0x5a>
    hb->block[i] = log.lh.block[i];
801034cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801034cf:	83 c0 10             	add    $0x10,%eax
801034d2:	8b 0c 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%ecx
801034d9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801034dc:	8b 55 f4             	mov    -0xc(%ebp),%edx
801034df:	89 4c 90 04          	mov    %ecx,0x4(%eax,%edx,4)
{
  struct buf *buf = bread(log.dev, log.start);
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
  for (i = 0; i < log.lh.n; i++) {
801034e3:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801034e7:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801034ec:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801034ef:	7f db                	jg     801034cc <write_head+0x3f>
    hb->block[i] = log.lh.block[i];
  }
  bwrite(buf);
801034f1:	83 ec 0c             	sub    $0xc,%esp
801034f4:	ff 75 f0             	pushl  -0x10(%ebp)
801034f7:	e8 f3 cc ff ff       	call   801001ef <bwrite>
801034fc:	83 c4 10             	add    $0x10,%esp
  brelse(buf);
801034ff:	83 ec 0c             	sub    $0xc,%esp
80103502:	ff 75 f0             	pushl  -0x10(%ebp)
80103505:	e8 24 cd ff ff       	call   8010022e <brelse>
8010350a:	83 c4 10             	add    $0x10,%esp
}
8010350d:	90                   	nop
8010350e:	c9                   	leave  
8010350f:	c3                   	ret    

80103510 <recover_from_log>:

static void
recover_from_log(void)
{
80103510:	55                   	push   %ebp
80103511:	89 e5                	mov    %esp,%ebp
80103513:	83 ec 08             	sub    $0x8,%esp
  read_head();      
80103516:	e8 fe fe ff ff       	call   80103419 <read_head>
  install_trans(); // if committed, copy from log to disk
8010351b:	e8 41 fe ff ff       	call   80103361 <install_trans>
  log.lh.n = 0;
80103520:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
80103527:	00 00 00 
  write_head(); // clear the log
8010352a:	e8 5e ff ff ff       	call   8010348d <write_head>
}
8010352f:	90                   	nop
80103530:	c9                   	leave  
80103531:	c3                   	ret    

80103532 <begin_op>:

// called at the start of each FS system call.
void
begin_op(void)
{
80103532:	55                   	push   %ebp
80103533:	89 e5                	mov    %esp,%ebp
80103535:	83 ec 08             	sub    $0x8,%esp
  acquire(&log.lock);
80103538:	83 ec 0c             	sub    $0xc,%esp
8010353b:	68 80 22 11 80       	push   $0x80112280
80103540:	e8 62 1c 00 00       	call   801051a7 <acquire>
80103545:	83 c4 10             	add    $0x10,%esp
  while(1){
    if(log.committing){
80103548:	a1 c0 22 11 80       	mov    0x801122c0,%eax
8010354d:	85 c0                	test   %eax,%eax
8010354f:	74 17                	je     80103568 <begin_op+0x36>
      sleep(&log, &log.lock);
80103551:	83 ec 08             	sub    $0x8,%esp
80103554:	68 80 22 11 80       	push   $0x80112280
80103559:	68 80 22 11 80       	push   $0x80112280
8010355e:	e8 42 19 00 00       	call   80104ea5 <sleep>
80103563:	83 c4 10             	add    $0x10,%esp
80103566:	eb e0                	jmp    80103548 <begin_op+0x16>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80103568:	8b 0d c8 22 11 80    	mov    0x801122c8,%ecx
8010356e:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103573:	8d 50 01             	lea    0x1(%eax),%edx
80103576:	89 d0                	mov    %edx,%eax
80103578:	c1 e0 02             	shl    $0x2,%eax
8010357b:	01 d0                	add    %edx,%eax
8010357d:	01 c0                	add    %eax,%eax
8010357f:	01 c8                	add    %ecx,%eax
80103581:	83 f8 1e             	cmp    $0x1e,%eax
80103584:	7e 17                	jle    8010359d <begin_op+0x6b>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
80103586:	83 ec 08             	sub    $0x8,%esp
80103589:	68 80 22 11 80       	push   $0x80112280
8010358e:	68 80 22 11 80       	push   $0x80112280
80103593:	e8 0d 19 00 00       	call   80104ea5 <sleep>
80103598:	83 c4 10             	add    $0x10,%esp
8010359b:	eb ab                	jmp    80103548 <begin_op+0x16>
    } else {
      log.outstanding += 1;
8010359d:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801035a2:	83 c0 01             	add    $0x1,%eax
801035a5:	a3 bc 22 11 80       	mov    %eax,0x801122bc
      release(&log.lock);
801035aa:	83 ec 0c             	sub    $0xc,%esp
801035ad:	68 80 22 11 80       	push   $0x80112280
801035b2:	e8 57 1c 00 00       	call   8010520e <release>
801035b7:	83 c4 10             	add    $0x10,%esp
      break;
801035ba:	90                   	nop
    }
  }
}
801035bb:	90                   	nop
801035bc:	c9                   	leave  
801035bd:	c3                   	ret    

801035be <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
801035be:	55                   	push   %ebp
801035bf:	89 e5                	mov    %esp,%ebp
801035c1:	83 ec 18             	sub    $0x18,%esp
  int do_commit = 0;
801035c4:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

  acquire(&log.lock);
801035cb:	83 ec 0c             	sub    $0xc,%esp
801035ce:	68 80 22 11 80       	push   $0x80112280
801035d3:	e8 cf 1b 00 00       	call   801051a7 <acquire>
801035d8:	83 c4 10             	add    $0x10,%esp
  log.outstanding -= 1;
801035db:	a1 bc 22 11 80       	mov    0x801122bc,%eax
801035e0:	83 e8 01             	sub    $0x1,%eax
801035e3:	a3 bc 22 11 80       	mov    %eax,0x801122bc
  if(log.committing)
801035e8:	a1 c0 22 11 80       	mov    0x801122c0,%eax
801035ed:	85 c0                	test   %eax,%eax
801035ef:	74 0d                	je     801035fe <end_op+0x40>
    panic("log.committing");
801035f1:	83 ec 0c             	sub    $0xc,%esp
801035f4:	68 ec 89 10 80       	push   $0x801089ec
801035f9:	e8 68 cf ff ff       	call   80100566 <panic>
  if(log.outstanding == 0){
801035fe:	a1 bc 22 11 80       	mov    0x801122bc,%eax
80103603:	85 c0                	test   %eax,%eax
80103605:	75 13                	jne    8010361a <end_op+0x5c>
    do_commit = 1;
80103607:	c7 45 f4 01 00 00 00 	movl   $0x1,-0xc(%ebp)
    log.committing = 1;
8010360e:	c7 05 c0 22 11 80 01 	movl   $0x1,0x801122c0
80103615:	00 00 00 
80103618:	eb 10                	jmp    8010362a <end_op+0x6c>
  } else {
    // begin_op() may be waiting for log space.
    wakeup(&log);
8010361a:	83 ec 0c             	sub    $0xc,%esp
8010361d:	68 80 22 11 80       	push   $0x80112280
80103622:	e8 6c 19 00 00       	call   80104f93 <wakeup>
80103627:	83 c4 10             	add    $0x10,%esp
  }
  release(&log.lock);
8010362a:	83 ec 0c             	sub    $0xc,%esp
8010362d:	68 80 22 11 80       	push   $0x80112280
80103632:	e8 d7 1b 00 00       	call   8010520e <release>
80103637:	83 c4 10             	add    $0x10,%esp

  if(do_commit){
8010363a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010363e:	74 3f                	je     8010367f <end_op+0xc1>
    // call commit w/o holding locks, since not allowed
    // to sleep with locks.
    commit();
80103640:	e8 f5 00 00 00       	call   8010373a <commit>
    acquire(&log.lock);
80103645:	83 ec 0c             	sub    $0xc,%esp
80103648:	68 80 22 11 80       	push   $0x80112280
8010364d:	e8 55 1b 00 00       	call   801051a7 <acquire>
80103652:	83 c4 10             	add    $0x10,%esp
    log.committing = 0;
80103655:	c7 05 c0 22 11 80 00 	movl   $0x0,0x801122c0
8010365c:	00 00 00 
    wakeup(&log);
8010365f:	83 ec 0c             	sub    $0xc,%esp
80103662:	68 80 22 11 80       	push   $0x80112280
80103667:	e8 27 19 00 00       	call   80104f93 <wakeup>
8010366c:	83 c4 10             	add    $0x10,%esp
    release(&log.lock);
8010366f:	83 ec 0c             	sub    $0xc,%esp
80103672:	68 80 22 11 80       	push   $0x80112280
80103677:	e8 92 1b 00 00       	call   8010520e <release>
8010367c:	83 c4 10             	add    $0x10,%esp
  }
}
8010367f:	90                   	nop
80103680:	c9                   	leave  
80103681:	c3                   	ret    

80103682 <write_log>:

// Copy modified blocks from cache to log.
static void 
write_log(void)
{
80103682:	55                   	push   %ebp
80103683:	89 e5                	mov    %esp,%ebp
80103685:	83 ec 18             	sub    $0x18,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103688:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010368f:	e9 95 00 00 00       	jmp    80103729 <write_log+0xa7>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80103694:	8b 15 b4 22 11 80    	mov    0x801122b4,%edx
8010369a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010369d:	01 d0                	add    %edx,%eax
8010369f:	83 c0 01             	add    $0x1,%eax
801036a2:	89 c2                	mov    %eax,%edx
801036a4:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801036a9:	83 ec 08             	sub    $0x8,%esp
801036ac:	52                   	push   %edx
801036ad:	50                   	push   %eax
801036ae:	e8 03 cb ff ff       	call   801001b6 <bread>
801036b3:	83 c4 10             	add    $0x10,%esp
801036b6:	89 45 f0             	mov    %eax,-0x10(%ebp)
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801036b9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801036bc:	83 c0 10             	add    $0x10,%eax
801036bf:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
801036c6:	89 c2                	mov    %eax,%edx
801036c8:	a1 c4 22 11 80       	mov    0x801122c4,%eax
801036cd:	83 ec 08             	sub    $0x8,%esp
801036d0:	52                   	push   %edx
801036d1:	50                   	push   %eax
801036d2:	e8 df ca ff ff       	call   801001b6 <bread>
801036d7:	83 c4 10             	add    $0x10,%esp
801036da:	89 45 ec             	mov    %eax,-0x14(%ebp)
    memmove(to->data, from->data, BSIZE);
801036dd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801036e0:	8d 50 18             	lea    0x18(%eax),%edx
801036e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801036e6:	83 c0 18             	add    $0x18,%eax
801036e9:	83 ec 04             	sub    $0x4,%esp
801036ec:	68 00 02 00 00       	push   $0x200
801036f1:	52                   	push   %edx
801036f2:	50                   	push   %eax
801036f3:	e8 d1 1d 00 00       	call   801054c9 <memmove>
801036f8:	83 c4 10             	add    $0x10,%esp
    bwrite(to);  // write the log
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	ff 75 f0             	pushl  -0x10(%ebp)
80103701:	e8 e9 ca ff ff       	call   801001ef <bwrite>
80103706:	83 c4 10             	add    $0x10,%esp
    brelse(from); 
80103709:	83 ec 0c             	sub    $0xc,%esp
8010370c:	ff 75 ec             	pushl  -0x14(%ebp)
8010370f:	e8 1a cb ff ff       	call   8010022e <brelse>
80103714:	83 c4 10             	add    $0x10,%esp
    brelse(to);
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	ff 75 f0             	pushl  -0x10(%ebp)
8010371d:	e8 0c cb ff ff       	call   8010022e <brelse>
80103722:	83 c4 10             	add    $0x10,%esp
static void 
write_log(void)
{
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80103725:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80103729:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010372e:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103731:	0f 8f 5d ff ff ff    	jg     80103694 <write_log+0x12>
    memmove(to->data, from->data, BSIZE);
    bwrite(to);  // write the log
    brelse(from); 
    brelse(to);
  }
}
80103737:	90                   	nop
80103738:	c9                   	leave  
80103739:	c3                   	ret    

8010373a <commit>:

static void
commit()
{
8010373a:	55                   	push   %ebp
8010373b:	89 e5                	mov    %esp,%ebp
8010373d:	83 ec 08             	sub    $0x8,%esp
  if (log.lh.n > 0) {
80103740:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103745:	85 c0                	test   %eax,%eax
80103747:	7e 1e                	jle    80103767 <commit+0x2d>
    write_log();     // Write modified blocks from cache to log
80103749:	e8 34 ff ff ff       	call   80103682 <write_log>
    write_head();    // Write header to disk -- the real commit
8010374e:	e8 3a fd ff ff       	call   8010348d <write_head>
    install_trans(); // Now install writes to home locations
80103753:	e8 09 fc ff ff       	call   80103361 <install_trans>
    log.lh.n = 0; 
80103758:	c7 05 c8 22 11 80 00 	movl   $0x0,0x801122c8
8010375f:	00 00 00 
    write_head();    // Erase the transaction from the log
80103762:	e8 26 fd ff ff       	call   8010348d <write_head>
  }
}
80103767:	90                   	nop
80103768:	c9                   	leave  
80103769:	c3                   	ret    

8010376a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
8010376a:	55                   	push   %ebp
8010376b:	89 e5                	mov    %esp,%ebp
8010376d:	83 ec 18             	sub    $0x18,%esp
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80103770:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103775:	83 f8 1d             	cmp    $0x1d,%eax
80103778:	7f 12                	jg     8010378c <log_write+0x22>
8010377a:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010377f:	8b 15 b8 22 11 80    	mov    0x801122b8,%edx
80103785:	83 ea 01             	sub    $0x1,%edx
80103788:	39 d0                	cmp    %edx,%eax
8010378a:	7c 0d                	jl     80103799 <log_write+0x2f>
    panic("too big a transaction");
8010378c:	83 ec 0c             	sub    $0xc,%esp
8010378f:	68 fb 89 10 80       	push   $0x801089fb
80103794:	e8 cd cd ff ff       	call   80100566 <panic>
  if (log.outstanding < 1)
80103799:	a1 bc 22 11 80       	mov    0x801122bc,%eax
8010379e:	85 c0                	test   %eax,%eax
801037a0:	7f 0d                	jg     801037af <log_write+0x45>
    panic("log_write outside of trans");
801037a2:	83 ec 0c             	sub    $0xc,%esp
801037a5:	68 11 8a 10 80       	push   $0x80108a11
801037aa:	e8 b7 cd ff ff       	call   80100566 <panic>

  acquire(&log.lock);
801037af:	83 ec 0c             	sub    $0xc,%esp
801037b2:	68 80 22 11 80       	push   $0x80112280
801037b7:	e8 eb 19 00 00       	call   801051a7 <acquire>
801037bc:	83 c4 10             	add    $0x10,%esp
  for (i = 0; i < log.lh.n; i++) {
801037bf:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801037c6:	eb 1d                	jmp    801037e5 <log_write+0x7b>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
801037c8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037cb:	83 c0 10             	add    $0x10,%eax
801037ce:	8b 04 85 8c 22 11 80 	mov    -0x7feedd74(,%eax,4),%eax
801037d5:	89 c2                	mov    %eax,%edx
801037d7:	8b 45 08             	mov    0x8(%ebp),%eax
801037da:	8b 40 08             	mov    0x8(%eax),%eax
801037dd:	39 c2                	cmp    %eax,%edx
801037df:	74 10                	je     801037f1 <log_write+0x87>
    panic("too big a transaction");
  if (log.outstanding < 1)
    panic("log_write outside of trans");

  acquire(&log.lock);
  for (i = 0; i < log.lh.n; i++) {
801037e1:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801037e5:	a1 c8 22 11 80       	mov    0x801122c8,%eax
801037ea:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801037ed:	7f d9                	jg     801037c8 <log_write+0x5e>
801037ef:	eb 01                	jmp    801037f2 <log_write+0x88>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
      break;
801037f1:	90                   	nop
  }
  log.lh.block[i] = b->blockno;
801037f2:	8b 45 08             	mov    0x8(%ebp),%eax
801037f5:	8b 40 08             	mov    0x8(%eax),%eax
801037f8:	89 c2                	mov    %eax,%edx
801037fa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801037fd:	83 c0 10             	add    $0x10,%eax
80103800:	89 14 85 8c 22 11 80 	mov    %edx,-0x7feedd74(,%eax,4)
  if (i == log.lh.n)
80103807:	a1 c8 22 11 80       	mov    0x801122c8,%eax
8010380c:	3b 45 f4             	cmp    -0xc(%ebp),%eax
8010380f:	75 0d                	jne    8010381e <log_write+0xb4>
    log.lh.n++;
80103811:	a1 c8 22 11 80       	mov    0x801122c8,%eax
80103816:	83 c0 01             	add    $0x1,%eax
80103819:	a3 c8 22 11 80       	mov    %eax,0x801122c8
  b->flags |= B_DIRTY; // prevent eviction
8010381e:	8b 45 08             	mov    0x8(%ebp),%eax
80103821:	8b 00                	mov    (%eax),%eax
80103823:	83 c8 04             	or     $0x4,%eax
80103826:	89 c2                	mov    %eax,%edx
80103828:	8b 45 08             	mov    0x8(%ebp),%eax
8010382b:	89 10                	mov    %edx,(%eax)
  release(&log.lock);
8010382d:	83 ec 0c             	sub    $0xc,%esp
80103830:	68 80 22 11 80       	push   $0x80112280
80103835:	e8 d4 19 00 00       	call   8010520e <release>
8010383a:	83 c4 10             	add    $0x10,%esp
}
8010383d:	90                   	nop
8010383e:	c9                   	leave  
8010383f:	c3                   	ret    

80103840 <v2p>:
80103840:	55                   	push   %ebp
80103841:	89 e5                	mov    %esp,%ebp
80103843:	8b 45 08             	mov    0x8(%ebp),%eax
80103846:	05 00 00 00 80       	add    $0x80000000,%eax
8010384b:	5d                   	pop    %ebp
8010384c:	c3                   	ret    

8010384d <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
8010384d:	55                   	push   %ebp
8010384e:	89 e5                	mov    %esp,%ebp
80103850:	8b 45 08             	mov    0x8(%ebp),%eax
80103853:	05 00 00 00 80       	add    $0x80000000,%eax
80103858:	5d                   	pop    %ebp
80103859:	c3                   	ret    

8010385a <xchg>:
  asm volatile("sti");
}

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010385a:	55                   	push   %ebp
8010385b:	89 e5                	mov    %esp,%ebp
8010385d:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80103860:	8b 55 08             	mov    0x8(%ebp),%edx
80103863:	8b 45 0c             	mov    0xc(%ebp),%eax
80103866:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103869:	f0 87 02             	lock xchg %eax,(%edx)
8010386c:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
8010386f:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80103872:	c9                   	leave  
80103873:	c3                   	ret    

80103874 <main>:
// Bootstrap processor starts running C code here.
// Allocate a real stack and switch to it, first
// doing some setup required for memory allocator to work.
int
main(void)
{
80103874:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80103878:	83 e4 f0             	and    $0xfffffff0,%esp
8010387b:	ff 71 fc             	pushl  -0x4(%ecx)
8010387e:	55                   	push   %ebp
8010387f:	89 e5                	mov    %esp,%ebp
80103881:	51                   	push   %ecx
80103882:	83 ec 04             	sub    $0x4,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80103885:	83 ec 08             	sub    $0x8,%esp
80103888:	68 00 00 40 80       	push   $0x80400000
8010388d:	68 5c 55 11 80       	push   $0x8011555c
80103892:	e8 7d f2 ff ff       	call   80102b14 <kinit1>
80103897:	83 c4 10             	add    $0x10,%esp
  kvmalloc();      // kernel page table
8010389a:	e8 69 47 00 00       	call   80108008 <kvmalloc>
  mpinit();        // collect info about this machine
8010389f:	e8 43 04 00 00       	call   80103ce7 <mpinit>
  lapicinit();
801038a4:	e8 ea f5 ff ff       	call   80102e93 <lapicinit>
  seginit();       // set up segments
801038a9:	e8 03 41 00 00       	call   801079b1 <seginit>
  cprintf("\ncpu%d: starting xv6\n\n", cpu->id);
801038ae:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801038b4:	0f b6 00             	movzbl (%eax),%eax
801038b7:	0f b6 c0             	movzbl %al,%eax
801038ba:	83 ec 08             	sub    $0x8,%esp
801038bd:	50                   	push   %eax
801038be:	68 2c 8a 10 80       	push   $0x80108a2c
801038c3:	e8 fe ca ff ff       	call   801003c6 <cprintf>
801038c8:	83 c4 10             	add    $0x10,%esp
  picinit();       // interrupt controller
801038cb:	e8 6d 06 00 00       	call   80103f3d <picinit>
  ioapicinit();    // another interrupt controller
801038d0:	e8 34 f1 ff ff       	call   80102a09 <ioapicinit>
  consoleinit();   // I/O devices & their interrupts
801038d5:	e8 0f d2 ff ff       	call   80100ae9 <consoleinit>
  uartinit();      // serial port
801038da:	e8 2e 34 00 00       	call   80106d0d <uartinit>
  pinit();         // process table
801038df:	e8 56 0b 00 00       	call   8010443a <pinit>
  tvinit();        // trap vectors
801038e4:	e8 98 2f 00 00       	call   80106881 <tvinit>
  binit();         // buffer cache
801038e9:	e8 46 c7 ff ff       	call   80100034 <binit>
  fileinit();      // file table
801038ee:	e8 67 d6 ff ff       	call   80100f5a <fileinit>
  ideinit();       // disk
801038f3:	e8 19 ed ff ff       	call   80102611 <ideinit>
  if(!ismp)
801038f8:	a1 64 23 11 80       	mov    0x80112364,%eax
801038fd:	85 c0                	test   %eax,%eax
801038ff:	75 05                	jne    80103906 <main+0x92>
    timerinit();   // uniprocessor timer
80103901:	e8 d8 2e 00 00       	call   801067de <timerinit>
  startothers();   // start other processors
80103906:	e8 7f 00 00 00       	call   8010398a <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
8010390b:	83 ec 08             	sub    $0x8,%esp
8010390e:	68 00 00 00 8e       	push   $0x8e000000
80103913:	68 00 00 40 80       	push   $0x80400000
80103918:	e8 30 f2 ff ff       	call   80102b4d <kinit2>
8010391d:	83 c4 10             	add    $0x10,%esp
  userinit();      // first user process
80103920:	e8 73 0c 00 00       	call   80104598 <userinit>
  // Finish setting up this processor in mpmain.
  mpmain();
80103925:	e8 1a 00 00 00       	call   80103944 <mpmain>

8010392a <mpenter>:
}

// Other CPUs jump here from entryother.S.
static void
mpenter(void)
{
8010392a:	55                   	push   %ebp
8010392b:	89 e5                	mov    %esp,%ebp
8010392d:	83 ec 08             	sub    $0x8,%esp
  switchkvm(); 
80103930:	e8 eb 46 00 00       	call   80108020 <switchkvm>
  seginit();
80103935:	e8 77 40 00 00       	call   801079b1 <seginit>
  lapicinit();
8010393a:	e8 54 f5 ff ff       	call   80102e93 <lapicinit>
  mpmain();
8010393f:	e8 00 00 00 00       	call   80103944 <mpmain>

80103944 <mpmain>:
}

// Common CPU setup code.
static void
mpmain(void)
{
80103944:	55                   	push   %ebp
80103945:	89 e5                	mov    %esp,%ebp
80103947:	83 ec 08             	sub    $0x8,%esp
  cprintf("cpu%d: starting\n", cpu->id);
8010394a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103950:	0f b6 00             	movzbl (%eax),%eax
80103953:	0f b6 c0             	movzbl %al,%eax
80103956:	83 ec 08             	sub    $0x8,%esp
80103959:	50                   	push   %eax
8010395a:	68 43 8a 10 80       	push   $0x80108a43
8010395f:	e8 62 ca ff ff       	call   801003c6 <cprintf>
80103964:	83 c4 10             	add    $0x10,%esp
  idtinit();       // load idt register
80103967:	e8 8b 30 00 00       	call   801069f7 <idtinit>
  xchg(&cpu->started, 1); // tell startothers() we're up
8010396c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80103972:	05 a8 00 00 00       	add    $0xa8,%eax
80103977:	83 ec 08             	sub    $0x8,%esp
8010397a:	6a 01                	push   $0x1
8010397c:	50                   	push   %eax
8010397d:	e8 d8 fe ff ff       	call   8010385a <xchg>
80103982:	83 c4 10             	add    $0x10,%esp
  scheduler();     // start running processes
80103985:	e8 36 13 00 00       	call   80104cc0 <scheduler>

8010398a <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
8010398a:	55                   	push   %ebp
8010398b:	89 e5                	mov    %esp,%ebp
8010398d:	53                   	push   %ebx
8010398e:	83 ec 14             	sub    $0x14,%esp
  char *stack;

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
80103991:	68 00 70 00 00       	push   $0x7000
80103996:	e8 b2 fe ff ff       	call   8010384d <p2v>
8010399b:	83 c4 04             	add    $0x4,%esp
8010399e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801039a1:	b8 8a 00 00 00       	mov    $0x8a,%eax
801039a6:	83 ec 04             	sub    $0x4,%esp
801039a9:	50                   	push   %eax
801039aa:	68 0c b5 10 80       	push   $0x8010b50c
801039af:	ff 75 f0             	pushl  -0x10(%ebp)
801039b2:	e8 12 1b 00 00       	call   801054c9 <memmove>
801039b7:	83 c4 10             	add    $0x10,%esp

  for(c = cpus; c < cpus+ncpu; c++){
801039ba:	c7 45 f4 80 23 11 80 	movl   $0x80112380,-0xc(%ebp)
801039c1:	e9 90 00 00 00       	jmp    80103a56 <startothers+0xcc>
    if(c == cpus+cpunum())  // We've started already.
801039c6:	e8 e6 f5 ff ff       	call   80102fb1 <cpunum>
801039cb:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801039d1:	05 80 23 11 80       	add    $0x80112380,%eax
801039d6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
801039d9:	74 73                	je     80103a4e <startothers+0xc4>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what 
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
801039db:	e8 6b f2 ff ff       	call   80102c4b <kalloc>
801039e0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    *(void**)(code-4) = stack + KSTACKSIZE;
801039e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039e6:	83 e8 04             	sub    $0x4,%eax
801039e9:	8b 55 ec             	mov    -0x14(%ebp),%edx
801039ec:	81 c2 00 10 00 00    	add    $0x1000,%edx
801039f2:	89 10                	mov    %edx,(%eax)
    *(void**)(code-8) = mpenter;
801039f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801039f7:	83 e8 08             	sub    $0x8,%eax
801039fa:	c7 00 2a 39 10 80    	movl   $0x8010392a,(%eax)
    *(int**)(code-12) = (void *) v2p(entrypgdir);
80103a00:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103a03:	8d 58 f4             	lea    -0xc(%eax),%ebx
80103a06:	83 ec 0c             	sub    $0xc,%esp
80103a09:	68 00 a0 10 80       	push   $0x8010a000
80103a0e:	e8 2d fe ff ff       	call   80103840 <v2p>
80103a13:	83 c4 10             	add    $0x10,%esp
80103a16:	89 03                	mov    %eax,(%ebx)

    lapicstartap(c->id, v2p(code));
80103a18:	83 ec 0c             	sub    $0xc,%esp
80103a1b:	ff 75 f0             	pushl  -0x10(%ebp)
80103a1e:	e8 1d fe ff ff       	call   80103840 <v2p>
80103a23:	83 c4 10             	add    $0x10,%esp
80103a26:	89 c2                	mov    %eax,%edx
80103a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a2b:	0f b6 00             	movzbl (%eax),%eax
80103a2e:	0f b6 c0             	movzbl %al,%eax
80103a31:	83 ec 08             	sub    $0x8,%esp
80103a34:	52                   	push   %edx
80103a35:	50                   	push   %eax
80103a36:	e8 f0 f5 ff ff       	call   8010302b <lapicstartap>
80103a3b:	83 c4 10             	add    $0x10,%esp

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80103a3e:	90                   	nop
80103a3f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103a42:	8b 80 a8 00 00 00    	mov    0xa8(%eax),%eax
80103a48:	85 c0                	test   %eax,%eax
80103a4a:	74 f3                	je     80103a3f <startothers+0xb5>
80103a4c:	eb 01                	jmp    80103a4f <startothers+0xc5>
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
    if(c == cpus+cpunum())  // We've started already.
      continue;
80103a4e:	90                   	nop
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = p2v(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);

  for(c = cpus; c < cpus+ncpu; c++){
80103a4f:	81 45 f4 bc 00 00 00 	addl   $0xbc,-0xc(%ebp)
80103a56:	a1 60 29 11 80       	mov    0x80112960,%eax
80103a5b:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103a61:	05 80 23 11 80       	add    $0x80112380,%eax
80103a66:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80103a69:	0f 87 57 ff ff ff    	ja     801039c6 <startothers+0x3c>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
      ;
  }
}
80103a6f:	90                   	nop
80103a70:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a73:	c9                   	leave  
80103a74:	c3                   	ret    

80103a75 <p2v>:
80103a75:	55                   	push   %ebp
80103a76:	89 e5                	mov    %esp,%ebp
80103a78:	8b 45 08             	mov    0x8(%ebp),%eax
80103a7b:	05 00 00 00 80       	add    $0x80000000,%eax
80103a80:	5d                   	pop    %ebp
80103a81:	c3                   	ret    

80103a82 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80103a82:	55                   	push   %ebp
80103a83:	89 e5                	mov    %esp,%ebp
80103a85:	83 ec 14             	sub    $0x14,%esp
80103a88:	8b 45 08             	mov    0x8(%ebp),%eax
80103a8b:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80103a8f:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80103a93:	89 c2                	mov    %eax,%edx
80103a95:	ec                   	in     (%dx),%al
80103a96:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80103a99:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80103a9d:	c9                   	leave  
80103a9e:	c3                   	ret    

80103a9f <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103a9f:	55                   	push   %ebp
80103aa0:	89 e5                	mov    %esp,%ebp
80103aa2:	83 ec 08             	sub    $0x8,%esp
80103aa5:	8b 55 08             	mov    0x8(%ebp),%edx
80103aa8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103aab:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103aaf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ab2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ab6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103aba:	ee                   	out    %al,(%dx)
}
80103abb:	90                   	nop
80103abc:	c9                   	leave  
80103abd:	c3                   	ret    

80103abe <mpbcpu>:
int ncpu;
uchar ioapicid;

int
mpbcpu(void)
{
80103abe:	55                   	push   %ebp
80103abf:	89 e5                	mov    %esp,%ebp
  return bcpu-cpus;
80103ac1:	a1 44 b6 10 80       	mov    0x8010b644,%eax
80103ac6:	89 c2                	mov    %eax,%edx
80103ac8:	b8 80 23 11 80       	mov    $0x80112380,%eax
80103acd:	29 c2                	sub    %eax,%edx
80103acf:	89 d0                	mov    %edx,%eax
80103ad1:	c1 f8 02             	sar    $0x2,%eax
80103ad4:	69 c0 cf 46 7d 67    	imul   $0x677d46cf,%eax,%eax
}
80103ada:	5d                   	pop    %ebp
80103adb:	c3                   	ret    

80103adc <sum>:

static uchar
sum(uchar *addr, int len)
{
80103adc:	55                   	push   %ebp
80103add:	89 e5                	mov    %esp,%ebp
80103adf:	83 ec 10             	sub    $0x10,%esp
  int i, sum;
  
  sum = 0;
80103ae2:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
  for(i=0; i<len; i++)
80103ae9:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80103af0:	eb 15                	jmp    80103b07 <sum+0x2b>
    sum += addr[i];
80103af2:	8b 55 fc             	mov    -0x4(%ebp),%edx
80103af5:	8b 45 08             	mov    0x8(%ebp),%eax
80103af8:	01 d0                	add    %edx,%eax
80103afa:	0f b6 00             	movzbl (%eax),%eax
80103afd:	0f b6 c0             	movzbl %al,%eax
80103b00:	01 45 f8             	add    %eax,-0x8(%ebp)
sum(uchar *addr, int len)
{
  int i, sum;
  
  sum = 0;
  for(i=0; i<len; i++)
80103b03:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80103b07:	8b 45 fc             	mov    -0x4(%ebp),%eax
80103b0a:	3b 45 0c             	cmp    0xc(%ebp),%eax
80103b0d:	7c e3                	jl     80103af2 <sum+0x16>
    sum += addr[i];
  return sum;
80103b0f:	8b 45 f8             	mov    -0x8(%ebp),%eax
}
80103b12:	c9                   	leave  
80103b13:	c3                   	ret    

80103b14 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80103b14:	55                   	push   %ebp
80103b15:	89 e5                	mov    %esp,%ebp
80103b17:	83 ec 18             	sub    $0x18,%esp
  uchar *e, *p, *addr;

  addr = p2v(a);
80103b1a:	ff 75 08             	pushl  0x8(%ebp)
80103b1d:	e8 53 ff ff ff       	call   80103a75 <p2v>
80103b22:	83 c4 04             	add    $0x4,%esp
80103b25:	89 45 f0             	mov    %eax,-0x10(%ebp)
  e = addr+len;
80103b28:	8b 55 0c             	mov    0xc(%ebp),%edx
80103b2b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b2e:	01 d0                	add    %edx,%eax
80103b30:	89 45 ec             	mov    %eax,-0x14(%ebp)
  for(p = addr; p < e; p += sizeof(struct mp))
80103b33:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103b36:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103b39:	eb 36                	jmp    80103b71 <mpsearch1+0x5d>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80103b3b:	83 ec 04             	sub    $0x4,%esp
80103b3e:	6a 04                	push   $0x4
80103b40:	68 54 8a 10 80       	push   $0x80108a54
80103b45:	ff 75 f4             	pushl  -0xc(%ebp)
80103b48:	e8 24 19 00 00       	call   80105471 <memcmp>
80103b4d:	83 c4 10             	add    $0x10,%esp
80103b50:	85 c0                	test   %eax,%eax
80103b52:	75 19                	jne    80103b6d <mpsearch1+0x59>
80103b54:	83 ec 08             	sub    $0x8,%esp
80103b57:	6a 10                	push   $0x10
80103b59:	ff 75 f4             	pushl  -0xc(%ebp)
80103b5c:	e8 7b ff ff ff       	call   80103adc <sum>
80103b61:	83 c4 10             	add    $0x10,%esp
80103b64:	84 c0                	test   %al,%al
80103b66:	75 05                	jne    80103b6d <mpsearch1+0x59>
      return (struct mp*)p;
80103b68:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b6b:	eb 11                	jmp    80103b7e <mpsearch1+0x6a>
{
  uchar *e, *p, *addr;

  addr = p2v(a);
  e = addr+len;
  for(p = addr; p < e; p += sizeof(struct mp))
80103b6d:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80103b71:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b74:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103b77:	72 c2                	jb     80103b3b <mpsearch1+0x27>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
      return (struct mp*)p;
  return 0;
80103b79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103b7e:	c9                   	leave  
80103b7f:	c3                   	ret    

80103b80 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80103b80:	55                   	push   %ebp
80103b81:	89 e5                	mov    %esp,%ebp
80103b83:	83 ec 18             	sub    $0x18,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
80103b86:	c7 45 f4 00 04 00 80 	movl   $0x80000400,-0xc(%ebp)
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80103b8d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103b90:	83 c0 0f             	add    $0xf,%eax
80103b93:	0f b6 00             	movzbl (%eax),%eax
80103b96:	0f b6 c0             	movzbl %al,%eax
80103b99:	c1 e0 08             	shl    $0x8,%eax
80103b9c:	89 c2                	mov    %eax,%edx
80103b9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103ba1:	83 c0 0e             	add    $0xe,%eax
80103ba4:	0f b6 00             	movzbl (%eax),%eax
80103ba7:	0f b6 c0             	movzbl %al,%eax
80103baa:	09 d0                	or     %edx,%eax
80103bac:	c1 e0 04             	shl    $0x4,%eax
80103baf:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103bb2:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103bb6:	74 21                	je     80103bd9 <mpsearch+0x59>
    if((mp = mpsearch1(p, 1024)))
80103bb8:	83 ec 08             	sub    $0x8,%esp
80103bbb:	68 00 04 00 00       	push   $0x400
80103bc0:	ff 75 f0             	pushl  -0x10(%ebp)
80103bc3:	e8 4c ff ff ff       	call   80103b14 <mpsearch1>
80103bc8:	83 c4 10             	add    $0x10,%esp
80103bcb:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103bce:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103bd2:	74 51                	je     80103c25 <mpsearch+0xa5>
      return mp;
80103bd4:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103bd7:	eb 61                	jmp    80103c3a <mpsearch+0xba>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80103bd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bdc:	83 c0 14             	add    $0x14,%eax
80103bdf:	0f b6 00             	movzbl (%eax),%eax
80103be2:	0f b6 c0             	movzbl %al,%eax
80103be5:	c1 e0 08             	shl    $0x8,%eax
80103be8:	89 c2                	mov    %eax,%edx
80103bea:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103bed:	83 c0 13             	add    $0x13,%eax
80103bf0:	0f b6 00             	movzbl (%eax),%eax
80103bf3:	0f b6 c0             	movzbl %al,%eax
80103bf6:	09 d0                	or     %edx,%eax
80103bf8:	c1 e0 0a             	shl    $0xa,%eax
80103bfb:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if((mp = mpsearch1(p-1024, 1024)))
80103bfe:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c01:	2d 00 04 00 00       	sub    $0x400,%eax
80103c06:	83 ec 08             	sub    $0x8,%esp
80103c09:	68 00 04 00 00       	push   $0x400
80103c0e:	50                   	push   %eax
80103c0f:	e8 00 ff ff ff       	call   80103b14 <mpsearch1>
80103c14:	83 c4 10             	add    $0x10,%esp
80103c17:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103c1a:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80103c1e:	74 05                	je     80103c25 <mpsearch+0xa5>
      return mp;
80103c20:	8b 45 ec             	mov    -0x14(%ebp),%eax
80103c23:	eb 15                	jmp    80103c3a <mpsearch+0xba>
  }
  return mpsearch1(0xF0000, 0x10000);
80103c25:	83 ec 08             	sub    $0x8,%esp
80103c28:	68 00 00 01 00       	push   $0x10000
80103c2d:	68 00 00 0f 00       	push   $0xf0000
80103c32:	e8 dd fe ff ff       	call   80103b14 <mpsearch1>
80103c37:	83 c4 10             	add    $0x10,%esp
}
80103c3a:	c9                   	leave  
80103c3b:	c3                   	ret    

80103c3c <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80103c3c:	55                   	push   %ebp
80103c3d:	89 e5                	mov    %esp,%ebp
80103c3f:	83 ec 18             	sub    $0x18,%esp
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80103c42:	e8 39 ff ff ff       	call   80103b80 <mpsearch>
80103c47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103c4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80103c4e:	74 0a                	je     80103c5a <mpconfig+0x1e>
80103c50:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c53:	8b 40 04             	mov    0x4(%eax),%eax
80103c56:	85 c0                	test   %eax,%eax
80103c58:	75 0a                	jne    80103c64 <mpconfig+0x28>
    return 0;
80103c5a:	b8 00 00 00 00       	mov    $0x0,%eax
80103c5f:	e9 81 00 00 00       	jmp    80103ce5 <mpconfig+0xa9>
  conf = (struct mpconf*) p2v((uint) mp->physaddr);
80103c64:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103c67:	8b 40 04             	mov    0x4(%eax),%eax
80103c6a:	83 ec 0c             	sub    $0xc,%esp
80103c6d:	50                   	push   %eax
80103c6e:	e8 02 fe ff ff       	call   80103a75 <p2v>
80103c73:	83 c4 10             	add    $0x10,%esp
80103c76:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(memcmp(conf, "PCMP", 4) != 0)
80103c79:	83 ec 04             	sub    $0x4,%esp
80103c7c:	6a 04                	push   $0x4
80103c7e:	68 59 8a 10 80       	push   $0x80108a59
80103c83:	ff 75 f0             	pushl  -0x10(%ebp)
80103c86:	e8 e6 17 00 00       	call   80105471 <memcmp>
80103c8b:	83 c4 10             	add    $0x10,%esp
80103c8e:	85 c0                	test   %eax,%eax
80103c90:	74 07                	je     80103c99 <mpconfig+0x5d>
    return 0;
80103c92:	b8 00 00 00 00       	mov    $0x0,%eax
80103c97:	eb 4c                	jmp    80103ce5 <mpconfig+0xa9>
  if(conf->version != 1 && conf->version != 4)
80103c99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103c9c:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103ca0:	3c 01                	cmp    $0x1,%al
80103ca2:	74 12                	je     80103cb6 <mpconfig+0x7a>
80103ca4:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103ca7:	0f b6 40 06          	movzbl 0x6(%eax),%eax
80103cab:	3c 04                	cmp    $0x4,%al
80103cad:	74 07                	je     80103cb6 <mpconfig+0x7a>
    return 0;
80103caf:	b8 00 00 00 00       	mov    $0x0,%eax
80103cb4:	eb 2f                	jmp    80103ce5 <mpconfig+0xa9>
  if(sum((uchar*)conf, conf->length) != 0)
80103cb6:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103cb9:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103cbd:	0f b7 c0             	movzwl %ax,%eax
80103cc0:	83 ec 08             	sub    $0x8,%esp
80103cc3:	50                   	push   %eax
80103cc4:	ff 75 f0             	pushl  -0x10(%ebp)
80103cc7:	e8 10 fe ff ff       	call   80103adc <sum>
80103ccc:	83 c4 10             	add    $0x10,%esp
80103ccf:	84 c0                	test   %al,%al
80103cd1:	74 07                	je     80103cda <mpconfig+0x9e>
    return 0;
80103cd3:	b8 00 00 00 00       	mov    $0x0,%eax
80103cd8:	eb 0b                	jmp    80103ce5 <mpconfig+0xa9>
  *pmp = mp;
80103cda:	8b 45 08             	mov    0x8(%ebp),%eax
80103cdd:	8b 55 f4             	mov    -0xc(%ebp),%edx
80103ce0:	89 10                	mov    %edx,(%eax)
  return conf;
80103ce2:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80103ce5:	c9                   	leave  
80103ce6:	c3                   	ret    

80103ce7 <mpinit>:

void
mpinit(void)
{
80103ce7:	55                   	push   %ebp
80103ce8:	89 e5                	mov    %esp,%ebp
80103cea:	83 ec 28             	sub    $0x28,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
80103ced:	c7 05 44 b6 10 80 80 	movl   $0x80112380,0x8010b644
80103cf4:	23 11 80 
  if((conf = mpconfig(&mp)) == 0)
80103cf7:	83 ec 0c             	sub    $0xc,%esp
80103cfa:	8d 45 e0             	lea    -0x20(%ebp),%eax
80103cfd:	50                   	push   %eax
80103cfe:	e8 39 ff ff ff       	call   80103c3c <mpconfig>
80103d03:	83 c4 10             	add    $0x10,%esp
80103d06:	89 45 f0             	mov    %eax,-0x10(%ebp)
80103d09:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80103d0d:	0f 84 96 01 00 00    	je     80103ea9 <mpinit+0x1c2>
    return;
  ismp = 1;
80103d13:	c7 05 64 23 11 80 01 	movl   $0x1,0x80112364
80103d1a:	00 00 00 
  lapic = (uint*)conf->lapicaddr;
80103d1d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d20:	8b 40 24             	mov    0x24(%eax),%eax
80103d23:	a3 7c 22 11 80       	mov    %eax,0x8011227c
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103d28:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d2b:	83 c0 2c             	add    $0x2c,%eax
80103d2e:	89 45 f4             	mov    %eax,-0xc(%ebp)
80103d31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d34:	0f b7 40 04          	movzwl 0x4(%eax),%eax
80103d38:	0f b7 d0             	movzwl %ax,%edx
80103d3b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80103d3e:	01 d0                	add    %edx,%eax
80103d40:	89 45 ec             	mov    %eax,-0x14(%ebp)
80103d43:	e9 f2 00 00 00       	jmp    80103e3a <mpinit+0x153>
    switch(*p){
80103d48:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d4b:	0f b6 00             	movzbl (%eax),%eax
80103d4e:	0f b6 c0             	movzbl %al,%eax
80103d51:	83 f8 04             	cmp    $0x4,%eax
80103d54:	0f 87 bc 00 00 00    	ja     80103e16 <mpinit+0x12f>
80103d5a:	8b 04 85 9c 8a 10 80 	mov    -0x7fef7564(,%eax,4),%eax
80103d61:	ff e0                	jmp    *%eax
    case MPPROC:
      proc = (struct mpproc*)p;
80103d63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103d66:	89 45 e8             	mov    %eax,-0x18(%ebp)
      if(ncpu != proc->apicid){
80103d69:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d6c:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d70:	0f b6 d0             	movzbl %al,%edx
80103d73:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d78:	39 c2                	cmp    %eax,%edx
80103d7a:	74 2b                	je     80103da7 <mpinit+0xc0>
        cprintf("mpinit: ncpu=%d apicid=%d\n", ncpu, proc->apicid);
80103d7c:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103d7f:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103d83:	0f b6 d0             	movzbl %al,%edx
80103d86:	a1 60 29 11 80       	mov    0x80112960,%eax
80103d8b:	83 ec 04             	sub    $0x4,%esp
80103d8e:	52                   	push   %edx
80103d8f:	50                   	push   %eax
80103d90:	68 5e 8a 10 80       	push   $0x80108a5e
80103d95:	e8 2c c6 ff ff       	call   801003c6 <cprintf>
80103d9a:	83 c4 10             	add    $0x10,%esp
        ismp = 0;
80103d9d:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103da4:	00 00 00 
      }
      if(proc->flags & MPBOOT)
80103da7:	8b 45 e8             	mov    -0x18(%ebp),%eax
80103daa:	0f b6 40 03          	movzbl 0x3(%eax),%eax
80103dae:	0f b6 c0             	movzbl %al,%eax
80103db1:	83 e0 02             	and    $0x2,%eax
80103db4:	85 c0                	test   %eax,%eax
80103db6:	74 15                	je     80103dcd <mpinit+0xe6>
        bcpu = &cpus[ncpu];
80103db8:	a1 60 29 11 80       	mov    0x80112960,%eax
80103dbd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dc3:	05 80 23 11 80       	add    $0x80112380,%eax
80103dc8:	a3 44 b6 10 80       	mov    %eax,0x8010b644
      cpus[ncpu].id = ncpu;
80103dcd:	a1 60 29 11 80       	mov    0x80112960,%eax
80103dd2:	8b 15 60 29 11 80    	mov    0x80112960,%edx
80103dd8:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
80103dde:	05 80 23 11 80       	add    $0x80112380,%eax
80103de3:	88 10                	mov    %dl,(%eax)
      ncpu++;
80103de5:	a1 60 29 11 80       	mov    0x80112960,%eax
80103dea:	83 c0 01             	add    $0x1,%eax
80103ded:	a3 60 29 11 80       	mov    %eax,0x80112960
      p += sizeof(struct mpproc);
80103df2:	83 45 f4 14          	addl   $0x14,-0xc(%ebp)
      continue;
80103df6:	eb 42                	jmp    80103e3a <mpinit+0x153>
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
80103df8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103dfb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      ioapicid = ioapic->apicno;
80103dfe:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80103e01:	0f b6 40 01          	movzbl 0x1(%eax),%eax
80103e05:	a2 60 23 11 80       	mov    %al,0x80112360
      p += sizeof(struct mpioapic);
80103e0a:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e0e:	eb 2a                	jmp    80103e3a <mpinit+0x153>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80103e10:	83 45 f4 08          	addl   $0x8,-0xc(%ebp)
      continue;
80103e14:	eb 24                	jmp    80103e3a <mpinit+0x153>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
80103e16:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e19:	0f b6 00             	movzbl (%eax),%eax
80103e1c:	0f b6 c0             	movzbl %al,%eax
80103e1f:	83 ec 08             	sub    $0x8,%esp
80103e22:	50                   	push   %eax
80103e23:	68 7c 8a 10 80       	push   $0x80108a7c
80103e28:	e8 99 c5 ff ff       	call   801003c6 <cprintf>
80103e2d:	83 c4 10             	add    $0x10,%esp
      ismp = 0;
80103e30:	c7 05 64 23 11 80 00 	movl   $0x0,0x80112364
80103e37:	00 00 00 
  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80103e3a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103e3d:	3b 45 ec             	cmp    -0x14(%ebp),%eax
80103e40:	0f 82 02 ff ff ff    	jb     80103d48 <mpinit+0x61>
    default:
      cprintf("mpinit: unknown config type %x\n", *p);
      ismp = 0;
    }
  }
  if(!ismp){
80103e46:	a1 64 23 11 80       	mov    0x80112364,%eax
80103e4b:	85 c0                	test   %eax,%eax
80103e4d:	75 1d                	jne    80103e6c <mpinit+0x185>
    // Didn't like what we found; fall back to no MP.
    ncpu = 1;
80103e4f:	c7 05 60 29 11 80 01 	movl   $0x1,0x80112960
80103e56:	00 00 00 
    lapic = 0;
80103e59:	c7 05 7c 22 11 80 00 	movl   $0x0,0x8011227c
80103e60:	00 00 00 
    ioapicid = 0;
80103e63:	c6 05 60 23 11 80 00 	movb   $0x0,0x80112360
    return;
80103e6a:	eb 3e                	jmp    80103eaa <mpinit+0x1c3>
  }

  if(mp->imcrp){
80103e6c:	8b 45 e0             	mov    -0x20(%ebp),%eax
80103e6f:	0f b6 40 0c          	movzbl 0xc(%eax),%eax
80103e73:	84 c0                	test   %al,%al
80103e75:	74 33                	je     80103eaa <mpinit+0x1c3>
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
80103e77:	83 ec 08             	sub    $0x8,%esp
80103e7a:	6a 70                	push   $0x70
80103e7c:	6a 22                	push   $0x22
80103e7e:	e8 1c fc ff ff       	call   80103a9f <outb>
80103e83:	83 c4 10             	add    $0x10,%esp
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80103e86:	83 ec 0c             	sub    $0xc,%esp
80103e89:	6a 23                	push   $0x23
80103e8b:	e8 f2 fb ff ff       	call   80103a82 <inb>
80103e90:	83 c4 10             	add    $0x10,%esp
80103e93:	83 c8 01             	or     $0x1,%eax
80103e96:	0f b6 c0             	movzbl %al,%eax
80103e99:	83 ec 08             	sub    $0x8,%esp
80103e9c:	50                   	push   %eax
80103e9d:	6a 23                	push   $0x23
80103e9f:	e8 fb fb ff ff       	call   80103a9f <outb>
80103ea4:	83 c4 10             	add    $0x10,%esp
80103ea7:	eb 01                	jmp    80103eaa <mpinit+0x1c3>
  struct mpproc *proc;
  struct mpioapic *ioapic;

  bcpu = &cpus[0];
  if((conf = mpconfig(&mp)) == 0)
    return;
80103ea9:	90                   	nop
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
  }
}
80103eaa:	c9                   	leave  
80103eab:	c3                   	ret    

80103eac <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80103eac:	55                   	push   %ebp
80103ead:	89 e5                	mov    %esp,%ebp
80103eaf:	83 ec 08             	sub    $0x8,%esp
80103eb2:	8b 55 08             	mov    0x8(%ebp),%edx
80103eb5:	8b 45 0c             	mov    0xc(%ebp),%eax
80103eb8:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80103ebc:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80103ebf:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80103ec3:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80103ec7:	ee                   	out    %al,(%dx)
}
80103ec8:	90                   	nop
80103ec9:	c9                   	leave  
80103eca:	c3                   	ret    

80103ecb <picsetmask>:
// Initial IRQ mask has interrupt 2 enabled (for slave 8259A).
static ushort irqmask = 0xFFFF & ~(1<<IRQ_SLAVE);

static void
picsetmask(ushort mask)
{
80103ecb:	55                   	push   %ebp
80103ecc:	89 e5                	mov    %esp,%ebp
80103ece:	83 ec 04             	sub    $0x4,%esp
80103ed1:	8b 45 08             	mov    0x8(%ebp),%eax
80103ed4:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  irqmask = mask;
80103ed8:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103edc:	66 a3 00 b0 10 80    	mov    %ax,0x8010b000
  outb(IO_PIC1+1, mask);
80103ee2:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ee6:	0f b6 c0             	movzbl %al,%eax
80103ee9:	50                   	push   %eax
80103eea:	6a 21                	push   $0x21
80103eec:	e8 bb ff ff ff       	call   80103eac <outb>
80103ef1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, mask >> 8);
80103ef4:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80103ef8:	66 c1 e8 08          	shr    $0x8,%ax
80103efc:	0f b6 c0             	movzbl %al,%eax
80103eff:	50                   	push   %eax
80103f00:	68 a1 00 00 00       	push   $0xa1
80103f05:	e8 a2 ff ff ff       	call   80103eac <outb>
80103f0a:	83 c4 08             	add    $0x8,%esp
}
80103f0d:	90                   	nop
80103f0e:	c9                   	leave  
80103f0f:	c3                   	ret    

80103f10 <picenable>:

void
picenable(int irq)
{
80103f10:	55                   	push   %ebp
80103f11:	89 e5                	mov    %esp,%ebp
  picsetmask(irqmask & ~(1<<irq));
80103f13:	8b 45 08             	mov    0x8(%ebp),%eax
80103f16:	ba 01 00 00 00       	mov    $0x1,%edx
80103f1b:	89 c1                	mov    %eax,%ecx
80103f1d:	d3 e2                	shl    %cl,%edx
80103f1f:	89 d0                	mov    %edx,%eax
80103f21:	f7 d0                	not    %eax
80103f23:	89 c2                	mov    %eax,%edx
80103f25:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80103f2c:	21 d0                	and    %edx,%eax
80103f2e:	0f b7 c0             	movzwl %ax,%eax
80103f31:	50                   	push   %eax
80103f32:	e8 94 ff ff ff       	call   80103ecb <picsetmask>
80103f37:	83 c4 04             	add    $0x4,%esp
}
80103f3a:	90                   	nop
80103f3b:	c9                   	leave  
80103f3c:	c3                   	ret    

80103f3d <picinit>:

// Initialize the 8259A interrupt controllers.
void
picinit(void)
{
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
80103f40:	68 ff 00 00 00       	push   $0xff
80103f45:	6a 21                	push   $0x21
80103f47:	e8 60 ff ff ff       	call   80103eac <outb>
80103f4c:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, 0xFF);
80103f4f:	68 ff 00 00 00       	push   $0xff
80103f54:	68 a1 00 00 00       	push   $0xa1
80103f59:	e8 4e ff ff ff       	call   80103eac <outb>
80103f5e:	83 c4 08             	add    $0x8,%esp

  // ICW1:  0001g0hi
  //    g:  0 = edge triggering, 1 = level triggering
  //    h:  0 = cascaded PICs, 1 = master only
  //    i:  0 = no ICW4, 1 = ICW4 required
  outb(IO_PIC1, 0x11);
80103f61:	6a 11                	push   $0x11
80103f63:	6a 20                	push   $0x20
80103f65:	e8 42 ff ff ff       	call   80103eac <outb>
80103f6a:	83 c4 08             	add    $0x8,%esp

  // ICW2:  Vector offset
  outb(IO_PIC1+1, T_IRQ0);
80103f6d:	6a 20                	push   $0x20
80103f6f:	6a 21                	push   $0x21
80103f71:	e8 36 ff ff ff       	call   80103eac <outb>
80103f76:	83 c4 08             	add    $0x8,%esp

  // ICW3:  (master PIC) bit mask of IR lines connected to slaves
  //        (slave PIC) 3-bit # of slave's connection to master
  outb(IO_PIC1+1, 1<<IRQ_SLAVE);
80103f79:	6a 04                	push   $0x4
80103f7b:	6a 21                	push   $0x21
80103f7d:	e8 2a ff ff ff       	call   80103eac <outb>
80103f82:	83 c4 08             	add    $0x8,%esp
  //    m:  0 = slave PIC, 1 = master PIC
  //      (ignored when b is 0, as the master/slave role
  //      can be hardwired).
  //    a:  1 = Automatic EOI mode
  //    p:  0 = MCS-80/85 mode, 1 = intel x86 mode
  outb(IO_PIC1+1, 0x3);
80103f85:	6a 03                	push   $0x3
80103f87:	6a 21                	push   $0x21
80103f89:	e8 1e ff ff ff       	call   80103eac <outb>
80103f8e:	83 c4 08             	add    $0x8,%esp

  // Set up slave (8259A-2)
  outb(IO_PIC2, 0x11);                  // ICW1
80103f91:	6a 11                	push   $0x11
80103f93:	68 a0 00 00 00       	push   $0xa0
80103f98:	e8 0f ff ff ff       	call   80103eac <outb>
80103f9d:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, T_IRQ0 + 8);      // ICW2
80103fa0:	6a 28                	push   $0x28
80103fa2:	68 a1 00 00 00       	push   $0xa1
80103fa7:	e8 00 ff ff ff       	call   80103eac <outb>
80103fac:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2+1, IRQ_SLAVE);           // ICW3
80103faf:	6a 02                	push   $0x2
80103fb1:	68 a1 00 00 00       	push   $0xa1
80103fb6:	e8 f1 fe ff ff       	call   80103eac <outb>
80103fbb:	83 c4 08             	add    $0x8,%esp
  // NB Automatic EOI mode doesn't tend to work on the slave.
  // Linux source code says it's "to be investigated".
  outb(IO_PIC2+1, 0x3);                 // ICW4
80103fbe:	6a 03                	push   $0x3
80103fc0:	68 a1 00 00 00       	push   $0xa1
80103fc5:	e8 e2 fe ff ff       	call   80103eac <outb>
80103fca:	83 c4 08             	add    $0x8,%esp

  // OCW3:  0ef01prs
  //   ef:  0x = NOP, 10 = clear specific mask, 11 = set specific mask
  //    p:  0 = no polling, 1 = polling mode
  //   rs:  0x = NOP, 10 = read IRR, 11 = read ISR
  outb(IO_PIC1, 0x68);             // clear specific mask
80103fcd:	6a 68                	push   $0x68
80103fcf:	6a 20                	push   $0x20
80103fd1:	e8 d6 fe ff ff       	call   80103eac <outb>
80103fd6:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC1, 0x0a);             // read IRR by default
80103fd9:	6a 0a                	push   $0xa
80103fdb:	6a 20                	push   $0x20
80103fdd:	e8 ca fe ff ff       	call   80103eac <outb>
80103fe2:	83 c4 08             	add    $0x8,%esp

  outb(IO_PIC2, 0x68);             // OCW3
80103fe5:	6a 68                	push   $0x68
80103fe7:	68 a0 00 00 00       	push   $0xa0
80103fec:	e8 bb fe ff ff       	call   80103eac <outb>
80103ff1:	83 c4 08             	add    $0x8,%esp
  outb(IO_PIC2, 0x0a);             // OCW3
80103ff4:	6a 0a                	push   $0xa
80103ff6:	68 a0 00 00 00       	push   $0xa0
80103ffb:	e8 ac fe ff ff       	call   80103eac <outb>
80104000:	83 c4 08             	add    $0x8,%esp

  if(irqmask != 0xFFFF)
80104003:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
8010400a:	66 83 f8 ff          	cmp    $0xffff,%ax
8010400e:	74 13                	je     80104023 <picinit+0xe6>
    picsetmask(irqmask);
80104010:	0f b7 05 00 b0 10 80 	movzwl 0x8010b000,%eax
80104017:	0f b7 c0             	movzwl %ax,%eax
8010401a:	50                   	push   %eax
8010401b:	e8 ab fe ff ff       	call   80103ecb <picsetmask>
80104020:	83 c4 04             	add    $0x4,%esp
}
80104023:	90                   	nop
80104024:	c9                   	leave  
80104025:	c3                   	ret    

80104026 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80104026:	55                   	push   %ebp
80104027:	89 e5                	mov    %esp,%ebp
80104029:	83 ec 18             	sub    $0x18,%esp
  struct pipe *p;

  p = 0;
8010402c:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
  *f0 = *f1 = 0;
80104033:	8b 45 0c             	mov    0xc(%ebp),%eax
80104036:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
8010403c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010403f:	8b 10                	mov    (%eax),%edx
80104041:	8b 45 08             	mov    0x8(%ebp),%eax
80104044:	89 10                	mov    %edx,(%eax)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80104046:	e8 2d cf ff ff       	call   80100f78 <filealloc>
8010404b:	89 c2                	mov    %eax,%edx
8010404d:	8b 45 08             	mov    0x8(%ebp),%eax
80104050:	89 10                	mov    %edx,(%eax)
80104052:	8b 45 08             	mov    0x8(%ebp),%eax
80104055:	8b 00                	mov    (%eax),%eax
80104057:	85 c0                	test   %eax,%eax
80104059:	0f 84 cb 00 00 00    	je     8010412a <pipealloc+0x104>
8010405f:	e8 14 cf ff ff       	call   80100f78 <filealloc>
80104064:	89 c2                	mov    %eax,%edx
80104066:	8b 45 0c             	mov    0xc(%ebp),%eax
80104069:	89 10                	mov    %edx,(%eax)
8010406b:	8b 45 0c             	mov    0xc(%ebp),%eax
8010406e:	8b 00                	mov    (%eax),%eax
80104070:	85 c0                	test   %eax,%eax
80104072:	0f 84 b2 00 00 00    	je     8010412a <pipealloc+0x104>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80104078:	e8 ce eb ff ff       	call   80102c4b <kalloc>
8010407d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104080:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104084:	0f 84 9f 00 00 00    	je     80104129 <pipealloc+0x103>
    goto bad;
  p->readopen = 1;
8010408a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010408d:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80104094:	00 00 00 
  p->writeopen = 1;
80104097:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010409a:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
801040a1:	00 00 00 
  p->nwrite = 0;
801040a4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040a7:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
801040ae:	00 00 00 
  p->nread = 0;
801040b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040b4:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
801040bb:	00 00 00 
  initlock(&p->lock, "pipe");
801040be:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040c1:	83 ec 08             	sub    $0x8,%esp
801040c4:	68 b0 8a 10 80       	push   $0x80108ab0
801040c9:	50                   	push   %eax
801040ca:	e8 b6 10 00 00       	call   80105185 <initlock>
801040cf:	83 c4 10             	add    $0x10,%esp
  (*f0)->type = FD_PIPE;
801040d2:	8b 45 08             	mov    0x8(%ebp),%eax
801040d5:	8b 00                	mov    (%eax),%eax
801040d7:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
801040dd:	8b 45 08             	mov    0x8(%ebp),%eax
801040e0:	8b 00                	mov    (%eax),%eax
801040e2:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
801040e6:	8b 45 08             	mov    0x8(%ebp),%eax
801040e9:	8b 00                	mov    (%eax),%eax
801040eb:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
801040ef:	8b 45 08             	mov    0x8(%ebp),%eax
801040f2:	8b 00                	mov    (%eax),%eax
801040f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801040f7:	89 50 0c             	mov    %edx,0xc(%eax)
  (*f1)->type = FD_PIPE;
801040fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801040fd:	8b 00                	mov    (%eax),%eax
801040ff:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80104105:	8b 45 0c             	mov    0xc(%ebp),%eax
80104108:	8b 00                	mov    (%eax),%eax
8010410a:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
8010410e:	8b 45 0c             	mov    0xc(%ebp),%eax
80104111:	8b 00                	mov    (%eax),%eax
80104113:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80104117:	8b 45 0c             	mov    0xc(%ebp),%eax
8010411a:	8b 00                	mov    (%eax),%eax
8010411c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010411f:	89 50 0c             	mov    %edx,0xc(%eax)
  return 0;
80104122:	b8 00 00 00 00       	mov    $0x0,%eax
80104127:	eb 4e                	jmp    80104177 <pipealloc+0x151>
  p = 0;
  *f0 = *f1 = 0;
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
    goto bad;
80104129:	90                   	nop
  (*f1)->pipe = p;
  return 0;

//PAGEBREAK: 20
 bad:
  if(p)
8010412a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010412e:	74 0e                	je     8010413e <pipealloc+0x118>
    kfree((char*)p);
80104130:	83 ec 0c             	sub    $0xc,%esp
80104133:	ff 75 f4             	pushl  -0xc(%ebp)
80104136:	e8 73 ea ff ff       	call   80102bae <kfree>
8010413b:	83 c4 10             	add    $0x10,%esp
  if(*f0)
8010413e:	8b 45 08             	mov    0x8(%ebp),%eax
80104141:	8b 00                	mov    (%eax),%eax
80104143:	85 c0                	test   %eax,%eax
80104145:	74 11                	je     80104158 <pipealloc+0x132>
    fileclose(*f0);
80104147:	8b 45 08             	mov    0x8(%ebp),%eax
8010414a:	8b 00                	mov    (%eax),%eax
8010414c:	83 ec 0c             	sub    $0xc,%esp
8010414f:	50                   	push   %eax
80104150:	e8 e1 ce ff ff       	call   80101036 <fileclose>
80104155:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80104158:	8b 45 0c             	mov    0xc(%ebp),%eax
8010415b:	8b 00                	mov    (%eax),%eax
8010415d:	85 c0                	test   %eax,%eax
8010415f:	74 11                	je     80104172 <pipealloc+0x14c>
    fileclose(*f1);
80104161:	8b 45 0c             	mov    0xc(%ebp),%eax
80104164:	8b 00                	mov    (%eax),%eax
80104166:	83 ec 0c             	sub    $0xc,%esp
80104169:	50                   	push   %eax
8010416a:	e8 c7 ce ff ff       	call   80101036 <fileclose>
8010416f:	83 c4 10             	add    $0x10,%esp
  return -1;
80104172:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104177:	c9                   	leave  
80104178:	c3                   	ret    

80104179 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80104179:	55                   	push   %ebp
8010417a:	89 e5                	mov    %esp,%ebp
8010417c:	83 ec 08             	sub    $0x8,%esp
  acquire(&p->lock);
8010417f:	8b 45 08             	mov    0x8(%ebp),%eax
80104182:	83 ec 0c             	sub    $0xc,%esp
80104185:	50                   	push   %eax
80104186:	e8 1c 10 00 00       	call   801051a7 <acquire>
8010418b:	83 c4 10             	add    $0x10,%esp
  if(writable){
8010418e:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104192:	74 23                	je     801041b7 <pipeclose+0x3e>
    p->writeopen = 0;
80104194:	8b 45 08             	mov    0x8(%ebp),%eax
80104197:	c7 80 40 02 00 00 00 	movl   $0x0,0x240(%eax)
8010419e:	00 00 00 
    wakeup(&p->nread);
801041a1:	8b 45 08             	mov    0x8(%ebp),%eax
801041a4:	05 34 02 00 00       	add    $0x234,%eax
801041a9:	83 ec 0c             	sub    $0xc,%esp
801041ac:	50                   	push   %eax
801041ad:	e8 e1 0d 00 00       	call   80104f93 <wakeup>
801041b2:	83 c4 10             	add    $0x10,%esp
801041b5:	eb 21                	jmp    801041d8 <pipeclose+0x5f>
  } else {
    p->readopen = 0;
801041b7:	8b 45 08             	mov    0x8(%ebp),%eax
801041ba:	c7 80 3c 02 00 00 00 	movl   $0x0,0x23c(%eax)
801041c1:	00 00 00 
    wakeup(&p->nwrite);
801041c4:	8b 45 08             	mov    0x8(%ebp),%eax
801041c7:	05 38 02 00 00       	add    $0x238,%eax
801041cc:	83 ec 0c             	sub    $0xc,%esp
801041cf:	50                   	push   %eax
801041d0:	e8 be 0d 00 00       	call   80104f93 <wakeup>
801041d5:	83 c4 10             	add    $0x10,%esp
  }
  if(p->readopen == 0 && p->writeopen == 0){
801041d8:	8b 45 08             	mov    0x8(%ebp),%eax
801041db:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
801041e1:	85 c0                	test   %eax,%eax
801041e3:	75 2c                	jne    80104211 <pipeclose+0x98>
801041e5:	8b 45 08             	mov    0x8(%ebp),%eax
801041e8:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
801041ee:	85 c0                	test   %eax,%eax
801041f0:	75 1f                	jne    80104211 <pipeclose+0x98>
    release(&p->lock);
801041f2:	8b 45 08             	mov    0x8(%ebp),%eax
801041f5:	83 ec 0c             	sub    $0xc,%esp
801041f8:	50                   	push   %eax
801041f9:	e8 10 10 00 00       	call   8010520e <release>
801041fe:	83 c4 10             	add    $0x10,%esp
    kfree((char*)p);
80104201:	83 ec 0c             	sub    $0xc,%esp
80104204:	ff 75 08             	pushl  0x8(%ebp)
80104207:	e8 a2 e9 ff ff       	call   80102bae <kfree>
8010420c:	83 c4 10             	add    $0x10,%esp
8010420f:	eb 0f                	jmp    80104220 <pipeclose+0xa7>
  } else
    release(&p->lock);
80104211:	8b 45 08             	mov    0x8(%ebp),%eax
80104214:	83 ec 0c             	sub    $0xc,%esp
80104217:	50                   	push   %eax
80104218:	e8 f1 0f 00 00       	call   8010520e <release>
8010421d:	83 c4 10             	add    $0x10,%esp
}
80104220:	90                   	nop
80104221:	c9                   	leave  
80104222:	c3                   	ret    

80104223 <pipewrite>:

//PAGEBREAK: 40
int
pipewrite(struct pipe *p, char *addr, int n)
{
80104223:	55                   	push   %ebp
80104224:	89 e5                	mov    %esp,%ebp
80104226:	83 ec 18             	sub    $0x18,%esp
  int i;

  acquire(&p->lock);
80104229:	8b 45 08             	mov    0x8(%ebp),%eax
8010422c:	83 ec 0c             	sub    $0xc,%esp
8010422f:	50                   	push   %eax
80104230:	e8 72 0f 00 00       	call   801051a7 <acquire>
80104235:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < n; i++){
80104238:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010423f:	e9 ad 00 00 00       	jmp    801042f1 <pipewrite+0xce>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
      if(p->readopen == 0 || proc->killed){
80104244:	8b 45 08             	mov    0x8(%ebp),%eax
80104247:	8b 80 3c 02 00 00    	mov    0x23c(%eax),%eax
8010424d:	85 c0                	test   %eax,%eax
8010424f:	74 0d                	je     8010425e <pipewrite+0x3b>
80104251:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104257:	8b 40 24             	mov    0x24(%eax),%eax
8010425a:	85 c0                	test   %eax,%eax
8010425c:	74 19                	je     80104277 <pipewrite+0x54>
        release(&p->lock);
8010425e:	8b 45 08             	mov    0x8(%ebp),%eax
80104261:	83 ec 0c             	sub    $0xc,%esp
80104264:	50                   	push   %eax
80104265:	e8 a4 0f 00 00       	call   8010520e <release>
8010426a:	83 c4 10             	add    $0x10,%esp
        return -1;
8010426d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104272:	e9 a8 00 00 00       	jmp    8010431f <pipewrite+0xfc>
      }
      wakeup(&p->nread);
80104277:	8b 45 08             	mov    0x8(%ebp),%eax
8010427a:	05 34 02 00 00       	add    $0x234,%eax
8010427f:	83 ec 0c             	sub    $0xc,%esp
80104282:	50                   	push   %eax
80104283:	e8 0b 0d 00 00       	call   80104f93 <wakeup>
80104288:	83 c4 10             	add    $0x10,%esp
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010428b:	8b 45 08             	mov    0x8(%ebp),%eax
8010428e:	8b 55 08             	mov    0x8(%ebp),%edx
80104291:	81 c2 38 02 00 00    	add    $0x238,%edx
80104297:	83 ec 08             	sub    $0x8,%esp
8010429a:	50                   	push   %eax
8010429b:	52                   	push   %edx
8010429c:	e8 04 0c 00 00       	call   80104ea5 <sleep>
801042a1:	83 c4 10             	add    $0x10,%esp
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
801042a4:	8b 45 08             	mov    0x8(%ebp),%eax
801042a7:	8b 90 38 02 00 00    	mov    0x238(%eax),%edx
801042ad:	8b 45 08             	mov    0x8(%ebp),%eax
801042b0:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801042b6:	05 00 02 00 00       	add    $0x200,%eax
801042bb:	39 c2                	cmp    %eax,%edx
801042bd:	74 85                	je     80104244 <pipewrite+0x21>
        return -1;
      }
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801042bf:	8b 45 08             	mov    0x8(%ebp),%eax
801042c2:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801042c8:	8d 48 01             	lea    0x1(%eax),%ecx
801042cb:	8b 55 08             	mov    0x8(%ebp),%edx
801042ce:	89 8a 38 02 00 00    	mov    %ecx,0x238(%edx)
801042d4:	25 ff 01 00 00       	and    $0x1ff,%eax
801042d9:	89 c1                	mov    %eax,%ecx
801042db:	8b 55 f4             	mov    -0xc(%ebp),%edx
801042de:	8b 45 0c             	mov    0xc(%ebp),%eax
801042e1:	01 d0                	add    %edx,%eax
801042e3:	0f b6 10             	movzbl (%eax),%edx
801042e6:	8b 45 08             	mov    0x8(%ebp),%eax
801042e9:	88 54 08 34          	mov    %dl,0x34(%eax,%ecx,1)
pipewrite(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  for(i = 0; i < n; i++){
801042ed:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801042f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801042f4:	3b 45 10             	cmp    0x10(%ebp),%eax
801042f7:	7c ab                	jl     801042a4 <pipewrite+0x81>
      wakeup(&p->nread);
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
    }
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801042f9:	8b 45 08             	mov    0x8(%ebp),%eax
801042fc:	05 34 02 00 00       	add    $0x234,%eax
80104301:	83 ec 0c             	sub    $0xc,%esp
80104304:	50                   	push   %eax
80104305:	e8 89 0c 00 00       	call   80104f93 <wakeup>
8010430a:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010430d:	8b 45 08             	mov    0x8(%ebp),%eax
80104310:	83 ec 0c             	sub    $0xc,%esp
80104313:	50                   	push   %eax
80104314:	e8 f5 0e 00 00       	call   8010520e <release>
80104319:	83 c4 10             	add    $0x10,%esp
  return n;
8010431c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010431f:	c9                   	leave  
80104320:	c3                   	ret    

80104321 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80104321:	55                   	push   %ebp
80104322:	89 e5                	mov    %esp,%ebp
80104324:	53                   	push   %ebx
80104325:	83 ec 14             	sub    $0x14,%esp
  int i;

  acquire(&p->lock);
80104328:	8b 45 08             	mov    0x8(%ebp),%eax
8010432b:	83 ec 0c             	sub    $0xc,%esp
8010432e:	50                   	push   %eax
8010432f:	e8 73 0e 00 00       	call   801051a7 <acquire>
80104334:	83 c4 10             	add    $0x10,%esp
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104337:	eb 3f                	jmp    80104378 <piperead+0x57>
    if(proc->killed){
80104339:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010433f:	8b 40 24             	mov    0x24(%eax),%eax
80104342:	85 c0                	test   %eax,%eax
80104344:	74 19                	je     8010435f <piperead+0x3e>
      release(&p->lock);
80104346:	8b 45 08             	mov    0x8(%ebp),%eax
80104349:	83 ec 0c             	sub    $0xc,%esp
8010434c:	50                   	push   %eax
8010434d:	e8 bc 0e 00 00       	call   8010520e <release>
80104352:	83 c4 10             	add    $0x10,%esp
      return -1;
80104355:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010435a:	e9 bf 00 00 00       	jmp    8010441e <piperead+0xfd>
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010435f:	8b 45 08             	mov    0x8(%ebp),%eax
80104362:	8b 55 08             	mov    0x8(%ebp),%edx
80104365:	81 c2 34 02 00 00    	add    $0x234,%edx
8010436b:	83 ec 08             	sub    $0x8,%esp
8010436e:	50                   	push   %eax
8010436f:	52                   	push   %edx
80104370:	e8 30 0b 00 00       	call   80104ea5 <sleep>
80104375:	83 c4 10             	add    $0x10,%esp
piperead(struct pipe *p, char *addr, int n)
{
  int i;

  acquire(&p->lock);
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80104378:	8b 45 08             	mov    0x8(%ebp),%eax
8010437b:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
80104381:	8b 45 08             	mov    0x8(%ebp),%eax
80104384:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
8010438a:	39 c2                	cmp    %eax,%edx
8010438c:	75 0d                	jne    8010439b <piperead+0x7a>
8010438e:	8b 45 08             	mov    0x8(%ebp),%eax
80104391:	8b 80 40 02 00 00    	mov    0x240(%eax),%eax
80104397:	85 c0                	test   %eax,%eax
80104399:	75 9e                	jne    80104339 <piperead+0x18>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010439b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801043a2:	eb 49                	jmp    801043ed <piperead+0xcc>
    if(p->nread == p->nwrite)
801043a4:	8b 45 08             	mov    0x8(%ebp),%eax
801043a7:	8b 90 34 02 00 00    	mov    0x234(%eax),%edx
801043ad:	8b 45 08             	mov    0x8(%ebp),%eax
801043b0:	8b 80 38 02 00 00    	mov    0x238(%eax),%eax
801043b6:	39 c2                	cmp    %eax,%edx
801043b8:	74 3d                	je     801043f7 <piperead+0xd6>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801043ba:	8b 55 f4             	mov    -0xc(%ebp),%edx
801043bd:	8b 45 0c             	mov    0xc(%ebp),%eax
801043c0:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801043c3:	8b 45 08             	mov    0x8(%ebp),%eax
801043c6:	8b 80 34 02 00 00    	mov    0x234(%eax),%eax
801043cc:	8d 48 01             	lea    0x1(%eax),%ecx
801043cf:	8b 55 08             	mov    0x8(%ebp),%edx
801043d2:	89 8a 34 02 00 00    	mov    %ecx,0x234(%edx)
801043d8:	25 ff 01 00 00       	and    $0x1ff,%eax
801043dd:	89 c2                	mov    %eax,%edx
801043df:	8b 45 08             	mov    0x8(%ebp),%eax
801043e2:	0f b6 44 10 34       	movzbl 0x34(%eax,%edx,1),%eax
801043e7:	88 03                	mov    %al,(%ebx)
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801043e9:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
801043ed:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043f0:	3b 45 10             	cmp    0x10(%ebp),%eax
801043f3:	7c af                	jl     801043a4 <piperead+0x83>
801043f5:	eb 01                	jmp    801043f8 <piperead+0xd7>
    if(p->nread == p->nwrite)
      break;
801043f7:	90                   	nop
    addr[i] = p->data[p->nread++ % PIPESIZE];
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801043f8:	8b 45 08             	mov    0x8(%ebp),%eax
801043fb:	05 38 02 00 00       	add    $0x238,%eax
80104400:	83 ec 0c             	sub    $0xc,%esp
80104403:	50                   	push   %eax
80104404:	e8 8a 0b 00 00       	call   80104f93 <wakeup>
80104409:	83 c4 10             	add    $0x10,%esp
  release(&p->lock);
8010440c:	8b 45 08             	mov    0x8(%ebp),%eax
8010440f:	83 ec 0c             	sub    $0xc,%esp
80104412:	50                   	push   %eax
80104413:	e8 f6 0d 00 00       	call   8010520e <release>
80104418:	83 c4 10             	add    $0x10,%esp
  return i;
8010441b:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
8010441e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104421:	c9                   	leave  
80104422:	c3                   	ret    

80104423 <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
80104423:	55                   	push   %ebp
80104424:	89 e5                	mov    %esp,%ebp
80104426:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80104429:	9c                   	pushf  
8010442a:	58                   	pop    %eax
8010442b:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
8010442e:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80104431:	c9                   	leave  
80104432:	c3                   	ret    

80104433 <sti>:
  asm volatile("cli");
}

static inline void
sti(void)
{
80104433:	55                   	push   %ebp
80104434:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80104436:	fb                   	sti    
}
80104437:	90                   	nop
80104438:	5d                   	pop    %ebp
80104439:	c3                   	ret    

8010443a <pinit>:

static void wakeup1(void *chan);

void
pinit(void)
{
8010443a:	55                   	push   %ebp
8010443b:	89 e5                	mov    %esp,%ebp
8010443d:	83 ec 08             	sub    $0x8,%esp
  initlock(&ptable.lock, "ptable");
80104440:	83 ec 08             	sub    $0x8,%esp
80104443:	68 b5 8a 10 80       	push   $0x80108ab5
80104448:	68 80 29 11 80       	push   $0x80112980
8010444d:	e8 33 0d 00 00       	call   80105185 <initlock>
80104452:	83 c4 10             	add    $0x10,%esp
}
80104455:	90                   	nop
80104456:	c9                   	leave  
80104457:	c3                   	ret    

80104458 <allocproc>:
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
80104458:	55                   	push   %ebp
80104459:	89 e5                	mov    %esp,%ebp
8010445b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
8010445e:	83 ec 0c             	sub    $0xc,%esp
80104461:	68 80 29 11 80       	push   $0x80112980
80104466:	e8 3c 0d 00 00       	call   801051a7 <acquire>
8010446b:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010446e:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104475:	eb 11                	jmp    80104488 <allocproc+0x30>
    if(p->state == UNUSED)
80104477:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010447a:	8b 40 0c             	mov    0xc(%eax),%eax
8010447d:	85 c0                	test   %eax,%eax
8010447f:	74 2a                	je     801044ab <allocproc+0x53>
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104481:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104488:	81 7d f4 b4 4c 11 80 	cmpl   $0x80114cb4,-0xc(%ebp)
8010448f:	72 e6                	jb     80104477 <allocproc+0x1f>
    if(p->state == UNUSED)
      goto found;
  release(&ptable.lock);
80104491:	83 ec 0c             	sub    $0xc,%esp
80104494:	68 80 29 11 80       	push   $0x80112980
80104499:	e8 70 0d 00 00       	call   8010520e <release>
8010449e:	83 c4 10             	add    $0x10,%esp
  return 0;
801044a1:	b8 00 00 00 00       	mov    $0x0,%eax
801044a6:	e9 eb 00 00 00       	jmp    80104596 <allocproc+0x13e>
  char *sp;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;
801044ab:	90                   	nop
  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
801044ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044af:	c7 40 0c 01 00 00 00 	movl   $0x1,0xc(%eax)
  p->pid = nextpid++;
801044b6:	a1 04 b0 10 80       	mov    0x8010b004,%eax
801044bb:	8d 50 01             	lea    0x1(%eax),%edx
801044be:	89 15 04 b0 10 80    	mov    %edx,0x8010b004
801044c4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044c7:	89 42 10             	mov    %eax,0x10(%edx)
  release(&ptable.lock);
801044ca:	83 ec 0c             	sub    $0xc,%esp
801044cd:	68 80 29 11 80       	push   $0x80112980
801044d2:	e8 37 0d 00 00       	call   8010520e <release>
801044d7:	83 c4 10             	add    $0x10,%esp

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
801044da:	e8 6c e7 ff ff       	call   80102c4b <kalloc>
801044df:	89 c2                	mov    %eax,%edx
801044e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044e4:	89 50 08             	mov    %edx,0x8(%eax)
801044e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044ea:	8b 40 08             	mov    0x8(%eax),%eax
801044ed:	85 c0                	test   %eax,%eax
801044ef:	75 14                	jne    80104505 <allocproc+0xad>
    p->state = UNUSED;
801044f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044f4:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return 0;
801044fb:	b8 00 00 00 00       	mov    $0x0,%eax
80104500:	e9 91 00 00 00       	jmp    80104596 <allocproc+0x13e>
  }
  sp = p->kstack + KSTACKSIZE;
80104505:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104508:	8b 40 08             	mov    0x8(%eax),%eax
8010450b:	05 00 10 00 00       	add    $0x1000,%eax
80104510:	89 45 f0             	mov    %eax,-0x10(%ebp)
  
  // Leave room for trap frame.
  sp -= sizeof *p->tf;
80104513:	83 6d f0 4c          	subl   $0x4c,-0x10(%ebp)
  p->tf = (struct trapframe*)sp;
80104517:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010451a:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010451d:	89 50 18             	mov    %edx,0x18(%eax)
  
  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
80104520:	83 6d f0 04          	subl   $0x4,-0x10(%ebp)
  *(uint*)sp = (uint)trapret;
80104524:	ba 3b 68 10 80       	mov    $0x8010683b,%edx
80104529:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010452c:	89 10                	mov    %edx,(%eax)

  sp -= sizeof *p->context;
8010452e:	83 6d f0 14          	subl   $0x14,-0x10(%ebp)
  p->context = (struct context*)sp;
80104532:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104535:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104538:	89 50 1c             	mov    %edx,0x1c(%eax)
  memset(p->context, 0, sizeof *p->context);
8010453b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010453e:	8b 40 1c             	mov    0x1c(%eax),%eax
80104541:	83 ec 04             	sub    $0x4,%esp
80104544:	6a 14                	push   $0x14
80104546:	6a 00                	push   $0x0
80104548:	50                   	push   %eax
80104549:	e8 bc 0e 00 00       	call   8010540a <memset>
8010454e:	83 c4 10             	add    $0x10,%esp
  p->context->eip = (uint)forkret;
80104551:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104554:	8b 40 1c             	mov    0x1c(%eax),%eax
80104557:	ba 5f 4e 10 80       	mov    $0x80104e5f,%edx
8010455c:	89 50 10             	mov    %edx,0x10(%eax)

  // #$#$#%@%$@#%@%^@^@^$#% adding fields
  p->ctime1 = ticks; // TODO Might need to protect the read of ticks with a lock
8010455f:	a1 00 55 11 80       	mov    0x80115500,%eax
80104564:	89 c2                	mov    %eax,%edx
80104566:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104569:	89 50 7c             	mov    %edx,0x7c(%eax)
  p->etime = 0;
8010456c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010456f:	c7 80 80 00 00 00 00 	movl   $0x0,0x80(%eax)
80104576:	00 00 00 
  p->rtime = 0;
80104579:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010457c:	c7 80 84 00 00 00 00 	movl   $0x0,0x84(%eax)
80104583:	00 00 00 
  p->iotime=0;
80104586:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104589:	c7 80 88 00 00 00 00 	movl   $0x0,0x88(%eax)
80104590:	00 00 00 


  return p;
80104593:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80104596:	c9                   	leave  
80104597:	c3                   	ret    

80104598 <userinit>:

//PAGEBREAK: 32
// Set up first user process.
void
userinit(void)
{
80104598:	55                   	push   %ebp
80104599:	89 e5                	mov    %esp,%ebp
8010459b:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];
  
  p = allocproc();
8010459e:	e8 b5 fe ff ff       	call   80104458 <allocproc>
801045a3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  initproc = p;
801045a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045a9:	a3 48 b6 10 80       	mov    %eax,0x8010b648
  if((p->pgdir = setupkvm()) == 0)
801045ae:	e8 a3 39 00 00       	call   80107f56 <setupkvm>
801045b3:	89 c2                	mov    %eax,%edx
801045b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045b8:	89 50 04             	mov    %edx,0x4(%eax)
801045bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045be:	8b 40 04             	mov    0x4(%eax),%eax
801045c1:	85 c0                	test   %eax,%eax
801045c3:	75 0d                	jne    801045d2 <userinit+0x3a>
    panic("userinit: out of memory?");
801045c5:	83 ec 0c             	sub    $0xc,%esp
801045c8:	68 bc 8a 10 80       	push   $0x80108abc
801045cd:	e8 94 bf ff ff       	call   80100566 <panic>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801045d2:	ba 2c 00 00 00       	mov    $0x2c,%edx
801045d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045da:	8b 40 04             	mov    0x4(%eax),%eax
801045dd:	83 ec 04             	sub    $0x4,%esp
801045e0:	52                   	push   %edx
801045e1:	68 e0 b4 10 80       	push   $0x8010b4e0
801045e6:	50                   	push   %eax
801045e7:	e8 c4 3b 00 00       	call   801081b0 <inituvm>
801045ec:	83 c4 10             	add    $0x10,%esp
  p->sz = PGSIZE;
801045ef:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045f2:	c7 00 00 10 00 00    	movl   $0x1000,(%eax)
  memset(p->tf, 0, sizeof(*p->tf));
801045f8:	8b 45 f4             	mov    -0xc(%ebp),%eax
801045fb:	8b 40 18             	mov    0x18(%eax),%eax
801045fe:	83 ec 04             	sub    $0x4,%esp
80104601:	6a 4c                	push   $0x4c
80104603:	6a 00                	push   $0x0
80104605:	50                   	push   %eax
80104606:	e8 ff 0d 00 00       	call   8010540a <memset>
8010460b:	83 c4 10             	add    $0x10,%esp
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010460e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104611:	8b 40 18             	mov    0x18(%eax),%eax
80104614:	66 c7 40 3c 23 00    	movw   $0x23,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
8010461a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010461d:	8b 40 18             	mov    0x18(%eax),%eax
80104620:	66 c7 40 2c 2b 00    	movw   $0x2b,0x2c(%eax)
  p->tf->es = p->tf->ds;
80104626:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104629:	8b 40 18             	mov    0x18(%eax),%eax
8010462c:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010462f:	8b 52 18             	mov    0x18(%edx),%edx
80104632:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
80104636:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010463a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010463d:	8b 40 18             	mov    0x18(%eax),%eax
80104640:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104643:	8b 52 18             	mov    0x18(%edx),%edx
80104646:	0f b7 52 2c          	movzwl 0x2c(%edx),%edx
8010464a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010464e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104651:	8b 40 18             	mov    0x18(%eax),%eax
80104654:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
8010465b:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010465e:	8b 40 18             	mov    0x18(%eax),%eax
80104661:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80104668:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010466b:	8b 40 18             	mov    0x18(%eax),%eax
8010466e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)

  safestrcpy(p->name, "initcode", sizeof(p->name));
80104675:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104678:	83 c0 6c             	add    $0x6c,%eax
8010467b:	83 ec 04             	sub    $0x4,%esp
8010467e:	6a 10                	push   $0x10
80104680:	68 d5 8a 10 80       	push   $0x80108ad5
80104685:	50                   	push   %eax
80104686:	e8 82 0f 00 00       	call   8010560d <safestrcpy>
8010468b:	83 c4 10             	add    $0x10,%esp
  p->cwd = namei("/");
8010468e:	83 ec 0c             	sub    $0xc,%esp
80104691:	68 de 8a 10 80       	push   $0x80108ade
80104696:	e8 72 de ff ff       	call   8010250d <namei>
8010469b:	83 c4 10             	add    $0x10,%esp
8010469e:	89 c2                	mov    %eax,%edx
801046a0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a3:	89 50 68             	mov    %edx,0x68(%eax)

  p->state = RUNNABLE;
801046a6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046a9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
}
801046b0:	90                   	nop
801046b1:	c9                   	leave  
801046b2:	c3                   	ret    

801046b3 <growproc>:

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
801046b3:	55                   	push   %ebp
801046b4:	89 e5                	mov    %esp,%ebp
801046b6:	83 ec 18             	sub    $0x18,%esp
  uint sz;
  
  sz = proc->sz;
801046b9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046bf:	8b 00                	mov    (%eax),%eax
801046c1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(n > 0){
801046c4:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046c8:	7e 31                	jle    801046fb <growproc+0x48>
    if((sz = allocuvm(proc->pgdir, sz, sz + n)) == 0)
801046ca:	8b 55 08             	mov    0x8(%ebp),%edx
801046cd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801046d0:	01 c2                	add    %eax,%edx
801046d2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801046d8:	8b 40 04             	mov    0x4(%eax),%eax
801046db:	83 ec 04             	sub    $0x4,%esp
801046de:	52                   	push   %edx
801046df:	ff 75 f4             	pushl  -0xc(%ebp)
801046e2:	50                   	push   %eax
801046e3:	e8 15 3c 00 00       	call   801082fd <allocuvm>
801046e8:	83 c4 10             	add    $0x10,%esp
801046eb:	89 45 f4             	mov    %eax,-0xc(%ebp)
801046ee:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801046f2:	75 3e                	jne    80104732 <growproc+0x7f>
      return -1;
801046f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f9:	eb 59                	jmp    80104754 <growproc+0xa1>
  } else if(n < 0){
801046fb:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
801046ff:	79 31                	jns    80104732 <growproc+0x7f>
    if((sz = deallocuvm(proc->pgdir, sz, sz + n)) == 0)
80104701:	8b 55 08             	mov    0x8(%ebp),%edx
80104704:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104707:	01 c2                	add    %eax,%edx
80104709:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010470f:	8b 40 04             	mov    0x4(%eax),%eax
80104712:	83 ec 04             	sub    $0x4,%esp
80104715:	52                   	push   %edx
80104716:	ff 75 f4             	pushl  -0xc(%ebp)
80104719:	50                   	push   %eax
8010471a:	e8 a7 3c 00 00       	call   801083c6 <deallocuvm>
8010471f:	83 c4 10             	add    $0x10,%esp
80104722:	89 45 f4             	mov    %eax,-0xc(%ebp)
80104725:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80104729:	75 07                	jne    80104732 <growproc+0x7f>
      return -1;
8010472b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104730:	eb 22                	jmp    80104754 <growproc+0xa1>
  }
  proc->sz = sz;
80104732:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104738:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010473b:	89 10                	mov    %edx,(%eax)
  switchuvm(proc);
8010473d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104743:	83 ec 0c             	sub    $0xc,%esp
80104746:	50                   	push   %eax
80104747:	e8 f1 38 00 00       	call   8010803d <switchuvm>
8010474c:	83 c4 10             	add    $0x10,%esp
  return 0;
8010474f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104754:	c9                   	leave  
80104755:	c3                   	ret    

80104756 <fork>:
// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
80104756:	55                   	push   %ebp
80104757:	89 e5                	mov    %esp,%ebp
80104759:	57                   	push   %edi
8010475a:	56                   	push   %esi
8010475b:	53                   	push   %ebx
8010475c:	83 ec 1c             	sub    $0x1c,%esp
  int i, pid;
  struct proc *np;

  // Allocate process.
  if((np = allocproc()) == 0)
8010475f:	e8 f4 fc ff ff       	call   80104458 <allocproc>
80104764:	89 45 e0             	mov    %eax,-0x20(%ebp)
80104767:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
8010476b:	75 0a                	jne    80104777 <fork+0x21>
    return -1;
8010476d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104772:	e9 68 01 00 00       	jmp    801048df <fork+0x189>

  // Copy process state from p.
  if((np->pgdir = copyuvm(proc->pgdir, proc->sz)) == 0){
80104777:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010477d:	8b 10                	mov    (%eax),%edx
8010477f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104785:	8b 40 04             	mov    0x4(%eax),%eax
80104788:	83 ec 08             	sub    $0x8,%esp
8010478b:	52                   	push   %edx
8010478c:	50                   	push   %eax
8010478d:	e8 d2 3d 00 00       	call   80108564 <copyuvm>
80104792:	83 c4 10             	add    $0x10,%esp
80104795:	89 c2                	mov    %eax,%edx
80104797:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010479a:	89 50 04             	mov    %edx,0x4(%eax)
8010479d:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047a0:	8b 40 04             	mov    0x4(%eax),%eax
801047a3:	85 c0                	test   %eax,%eax
801047a5:	75 30                	jne    801047d7 <fork+0x81>
    kfree(np->kstack);
801047a7:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047aa:	8b 40 08             	mov    0x8(%eax),%eax
801047ad:	83 ec 0c             	sub    $0xc,%esp
801047b0:	50                   	push   %eax
801047b1:	e8 f8 e3 ff ff       	call   80102bae <kfree>
801047b6:	83 c4 10             	add    $0x10,%esp
    np->kstack = 0;
801047b9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047bc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
    np->state = UNUSED;
801047c3:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c6:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
    return -1;
801047cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047d2:	e9 08 01 00 00       	jmp    801048df <fork+0x189>
  }
  np->sz = proc->sz;
801047d7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047dd:	8b 10                	mov    (%eax),%edx
801047df:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047e2:	89 10                	mov    %edx,(%eax)
  np->parent = proc;
801047e4:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801047eb:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047ee:	89 50 14             	mov    %edx,0x14(%eax)
  *np->tf = *proc->tf;
801047f1:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047f4:	8b 50 18             	mov    0x18(%eax),%edx
801047f7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801047fd:	8b 40 18             	mov    0x18(%eax),%eax
80104800:	89 c3                	mov    %eax,%ebx
80104802:	b8 13 00 00 00       	mov    $0x13,%eax
80104807:	89 d7                	mov    %edx,%edi
80104809:	89 de                	mov    %ebx,%esi
8010480b:	89 c1                	mov    %eax,%ecx
8010480d:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
8010480f:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104812:	8b 40 18             	mov    0x18(%eax),%eax
80104815:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)

  for(i = 0; i < NOFILE; i++)
8010481c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80104823:	eb 43                	jmp    80104868 <fork+0x112>
    if(proc->ofile[i])
80104825:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010482b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010482e:	83 c2 08             	add    $0x8,%edx
80104831:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104835:	85 c0                	test   %eax,%eax
80104837:	74 2b                	je     80104864 <fork+0x10e>
      np->ofile[i] = filedup(proc->ofile[i]);
80104839:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010483f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80104842:	83 c2 08             	add    $0x8,%edx
80104845:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104849:	83 ec 0c             	sub    $0xc,%esp
8010484c:	50                   	push   %eax
8010484d:	e8 93 c7 ff ff       	call   80100fe5 <filedup>
80104852:	83 c4 10             	add    $0x10,%esp
80104855:	89 c1                	mov    %eax,%ecx
80104857:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010485a:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010485d:	83 c2 08             	add    $0x8,%edx
80104860:	89 4c 90 08          	mov    %ecx,0x8(%eax,%edx,4)
  *np->tf = *proc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
80104864:	83 45 e4 01          	addl   $0x1,-0x1c(%ebp)
80104868:	83 7d e4 0f          	cmpl   $0xf,-0x1c(%ebp)
8010486c:	7e b7                	jle    80104825 <fork+0xcf>
    if(proc->ofile[i])
      np->ofile[i] = filedup(proc->ofile[i]);
  np->cwd = idup(proc->cwd);
8010486e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104874:	8b 40 68             	mov    0x68(%eax),%eax
80104877:	83 ec 0c             	sub    $0xc,%esp
8010487a:	50                   	push   %eax
8010487b:	e8 95 d0 ff ff       	call   80101915 <idup>
80104880:	83 c4 10             	add    $0x10,%esp
80104883:	89 c2                	mov    %eax,%edx
80104885:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104888:	89 50 68             	mov    %edx,0x68(%eax)

  safestrcpy(np->name, proc->name, sizeof(proc->name));
8010488b:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104891:	8d 50 6c             	lea    0x6c(%eax),%edx
80104894:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104897:	83 c0 6c             	add    $0x6c,%eax
8010489a:	83 ec 04             	sub    $0x4,%esp
8010489d:	6a 10                	push   $0x10
8010489f:	52                   	push   %edx
801048a0:	50                   	push   %eax
801048a1:	e8 67 0d 00 00       	call   8010560d <safestrcpy>
801048a6:	83 c4 10             	add    $0x10,%esp
 
  pid = np->pid;
801048a9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048ac:	8b 40 10             	mov    0x10(%eax),%eax
801048af:	89 45 dc             	mov    %eax,-0x24(%ebp)

  // lock to force the compiler to emit the np->state write last.
  acquire(&ptable.lock);
801048b2:	83 ec 0c             	sub    $0xc,%esp
801048b5:	68 80 29 11 80       	push   $0x80112980
801048ba:	e8 e8 08 00 00       	call   801051a7 <acquire>
801048bf:	83 c4 10             	add    $0x10,%esp
  np->state = RUNNABLE;
801048c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048c5:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  release(&ptable.lock);
801048cc:	83 ec 0c             	sub    $0xc,%esp
801048cf:	68 80 29 11 80       	push   $0x80112980
801048d4:	e8 35 09 00 00       	call   8010520e <release>
801048d9:	83 c4 10             	add    $0x10,%esp
  
  return pid;
801048dc:	8b 45 dc             	mov    -0x24(%ebp),%eax
}
801048df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048e2:	5b                   	pop    %ebx
801048e3:	5e                   	pop    %esi
801048e4:	5f                   	pop    %edi
801048e5:	5d                   	pop    %ebp
801048e6:	c3                   	ret    

801048e7 <exit>:
// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
801048e7:	55                   	push   %ebp
801048e8:	89 e5                	mov    %esp,%ebp
801048ea:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int fd;

  if(proc == initproc)
801048ed:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
801048f4:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801048f9:	39 c2                	cmp    %eax,%edx
801048fb:	75 0d                	jne    8010490a <exit+0x23>
    panic("init exiting");
801048fd:	83 ec 0c             	sub    $0xc,%esp
80104900:	68 e0 8a 10 80       	push   $0x80108ae0
80104905:	e8 5c bc ff ff       	call   80100566 <panic>

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
8010490a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
80104911:	eb 48                	jmp    8010495b <exit+0x74>
    if(proc->ofile[fd]){
80104913:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104919:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010491c:	83 c2 08             	add    $0x8,%edx
8010491f:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104923:	85 c0                	test   %eax,%eax
80104925:	74 30                	je     80104957 <exit+0x70>
      fileclose(proc->ofile[fd]);
80104927:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010492d:	8b 55 f0             	mov    -0x10(%ebp),%edx
80104930:	83 c2 08             	add    $0x8,%edx
80104933:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
80104937:	83 ec 0c             	sub    $0xc,%esp
8010493a:	50                   	push   %eax
8010493b:	e8 f6 c6 ff ff       	call   80101036 <fileclose>
80104940:	83 c4 10             	add    $0x10,%esp
      proc->ofile[fd] = 0;
80104943:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104949:	8b 55 f0             	mov    -0x10(%ebp),%edx
8010494c:	83 c2 08             	add    $0x8,%edx
8010494f:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80104956:	00 

  if(proc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
80104957:	83 45 f0 01          	addl   $0x1,-0x10(%ebp)
8010495b:	83 7d f0 0f          	cmpl   $0xf,-0x10(%ebp)
8010495f:	7e b2                	jle    80104913 <exit+0x2c>
      fileclose(proc->ofile[fd]);
      proc->ofile[fd] = 0;
    }
  }

  begin_op();
80104961:	e8 cc eb ff ff       	call   80103532 <begin_op>
  iput(proc->cwd);
80104966:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010496c:	8b 40 68             	mov    0x68(%eax),%eax
8010496f:	83 ec 0c             	sub    $0xc,%esp
80104972:	50                   	push   %eax
80104973:	e8 a7 d1 ff ff       	call   80101b1f <iput>
80104978:	83 c4 10             	add    $0x10,%esp
  end_op();
8010497b:	e8 3e ec ff ff       	call   801035be <end_op>
  proc->cwd = 0;
80104980:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104986:	c7 40 68 00 00 00 00 	movl   $0x0,0x68(%eax)

  acquire(&ptable.lock);
8010498d:	83 ec 0c             	sub    $0xc,%esp
80104990:	68 80 29 11 80       	push   $0x80112980
80104995:	e8 0d 08 00 00       	call   801051a7 <acquire>
8010499a:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);
8010499d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049a3:	8b 40 14             	mov    0x14(%eax),%eax
801049a6:	83 ec 0c             	sub    $0xc,%esp
801049a9:	50                   	push   %eax
801049aa:	e8 a2 05 00 00       	call   80104f51 <wakeup1>
801049af:	83 c4 10             	add    $0x10,%esp

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049b2:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
801049b9:	eb 3f                	jmp    801049fa <exit+0x113>
    if(p->parent == proc){
801049bb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049be:	8b 50 14             	mov    0x14(%eax),%edx
801049c1:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801049c7:	39 c2                	cmp    %eax,%edx
801049c9:	75 28                	jne    801049f3 <exit+0x10c>
      p->parent = initproc;
801049cb:	8b 15 48 b6 10 80    	mov    0x8010b648,%edx
801049d1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049d4:	89 50 14             	mov    %edx,0x14(%eax)
      if(p->state == ZOMBIE)
801049d7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049da:	8b 40 0c             	mov    0xc(%eax),%eax
801049dd:	83 f8 05             	cmp    $0x5,%eax
801049e0:	75 11                	jne    801049f3 <exit+0x10c>
        wakeup1(initproc);
801049e2:	a1 48 b6 10 80       	mov    0x8010b648,%eax
801049e7:	83 ec 0c             	sub    $0xc,%esp
801049ea:	50                   	push   %eax
801049eb:	e8 61 05 00 00       	call   80104f51 <wakeup1>
801049f0:	83 c4 10             	add    $0x10,%esp

  // Parent might be sleeping in wait().
  wakeup1(proc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801049f3:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
801049fa:	81 7d f4 b4 4c 11 80 	cmpl   $0x80114cb4,-0xc(%ebp)
80104a01:	72 b8                	jb     801049bb <exit+0xd4>
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  proc->state = ZOMBIE;
80104a03:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a09:	c7 40 0c 05 00 00 00 	movl   $0x5,0xc(%eax)
  // #$#$^$#^%$&$&$&$%
   proc->etime = ticks; // TODO Might need to protect the read of ticks with a lock
80104a10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a16:	8b 15 00 55 11 80    	mov    0x80115500,%edx
80104a1c:	89 90 80 00 00 00    	mov    %edx,0x80(%eax)
  sched();
80104a22:	e8 41 03 00 00       	call   80104d68 <sched>
  panic("zombie exit");
80104a27:	83 ec 0c             	sub    $0xc,%esp
80104a2a:	68 ed 8a 10 80       	push   $0x80108aed
80104a2f:	e8 32 bb ff ff       	call   80100566 <panic>

80104a34 <wait>:

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
80104a34:	55                   	push   %ebp
80104a35:	89 e5                	mov    %esp,%ebp
80104a37:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104a3a:	83 ec 0c             	sub    $0xc,%esp
80104a3d:	68 80 29 11 80       	push   $0x80112980
80104a42:	e8 60 07 00 00       	call   801051a7 <acquire>
80104a47:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104a4a:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104a51:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104a58:	e9 a9 00 00 00       	jmp    80104b06 <wait+0xd2>
      if(p->parent != proc)
80104a5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a60:	8b 50 14             	mov    0x14(%eax),%edx
80104a63:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104a69:	39 c2                	cmp    %eax,%edx
80104a6b:	0f 85 8d 00 00 00    	jne    80104afe <wait+0xca>
        continue;
      havekids = 1;
80104a71:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104a78:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a7b:	8b 40 0c             	mov    0xc(%eax),%eax
80104a7e:	83 f8 05             	cmp    $0x5,%eax
80104a81:	75 7c                	jne    80104aff <wait+0xcb>
        // Found one.
        pid = p->pid;
80104a83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a86:	8b 40 10             	mov    0x10(%eax),%eax
80104a89:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104a8c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a8f:	8b 40 08             	mov    0x8(%eax),%eax
80104a92:	83 ec 0c             	sub    $0xc,%esp
80104a95:	50                   	push   %eax
80104a96:	e8 13 e1 ff ff       	call   80102bae <kfree>
80104a9b:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104a9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aa1:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104aa8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aab:	8b 40 04             	mov    0x4(%eax),%eax
80104aae:	83 ec 0c             	sub    $0xc,%esp
80104ab1:	50                   	push   %eax
80104ab2:	e8 cc 39 00 00       	call   80108483 <freevm>
80104ab7:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104aba:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104abd:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104ac4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ac7:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104ace:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ad1:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104ad8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104adb:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104adf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ae2:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104ae9:	83 ec 0c             	sub    $0xc,%esp
80104aec:	68 80 29 11 80       	push   $0x80112980
80104af1:	e8 18 07 00 00       	call   8010520e <release>
80104af6:	83 c4 10             	add    $0x10,%esp
        return pid;
80104af9:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104afc:	eb 5b                	jmp    80104b59 <wait+0x125>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104afe:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104aff:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104b06:	81 7d f4 b4 4c 11 80 	cmpl   $0x80114cb4,-0xc(%ebp)
80104b0d:	0f 82 4a ff ff ff    	jb     80104a5d <wait+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104b13:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104b17:	74 0d                	je     80104b26 <wait+0xf2>
80104b19:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b1f:	8b 40 24             	mov    0x24(%eax),%eax
80104b22:	85 c0                	test   %eax,%eax
80104b24:	74 17                	je     80104b3d <wait+0x109>
      release(&ptable.lock);
80104b26:	83 ec 0c             	sub    $0xc,%esp
80104b29:	68 80 29 11 80       	push   $0x80112980
80104b2e:	e8 db 06 00 00       	call   8010520e <release>
80104b33:	83 c4 10             	add    $0x10,%esp
      return -1;
80104b36:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b3b:	eb 1c                	jmp    80104b59 <wait+0x125>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104b3d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b43:	83 ec 08             	sub    $0x8,%esp
80104b46:	68 80 29 11 80       	push   $0x80112980
80104b4b:	50                   	push   %eax
80104b4c:	e8 54 03 00 00       	call   80104ea5 <sleep>
80104b51:	83 c4 10             	add    $0x10,%esp
  }
80104b54:	e9 f1 fe ff ff       	jmp    80104a4a <wait+0x16>
}
80104b59:	c9                   	leave  
80104b5a:	c3                   	ret    

80104b5b <waitx>:
int
waitx(int *wtime,int *rtime)
{
80104b5b:	55                   	push   %ebp
80104b5c:	89 e5                	mov    %esp,%ebp
80104b5e:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;
  int havekids, pid;

  acquire(&ptable.lock);
80104b61:	83 ec 0c             	sub    $0xc,%esp
80104b64:	68 80 29 11 80       	push   $0x80112980
80104b69:	e8 39 06 00 00       	call   801051a7 <acquire>
80104b6e:	83 c4 10             	add    $0x10,%esp
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
80104b71:	c7 45 f0 00 00 00 00 	movl   $0x0,-0x10(%ebp)
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104b78:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104b7f:	e9 e7 00 00 00       	jmp    80104c6b <waitx+0x110>
      if(p->parent != proc)
80104b84:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b87:	8b 50 14             	mov    0x14(%eax),%edx
80104b8a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104b90:	39 c2                	cmp    %eax,%edx
80104b92:	0f 85 cb 00 00 00    	jne    80104c63 <waitx+0x108>
        continue;
      havekids = 1;
80104b98:	c7 45 f0 01 00 00 00 	movl   $0x1,-0x10(%ebp)
      if(p->state == ZOMBIE){
80104b9f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ba2:	8b 40 0c             	mov    0xc(%eax),%eax
80104ba5:	83 f8 05             	cmp    $0x5,%eax
80104ba8:	0f 85 b6 00 00 00    	jne    80104c64 <waitx+0x109>
        // Found one.
        *wtime= p->etime - p->ctime1 - p->rtime - p->iotime;
80104bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bb1:	8b 90 80 00 00 00    	mov    0x80(%eax),%edx
80104bb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bba:	8b 40 7c             	mov    0x7c(%eax),%eax
80104bbd:	29 c2                	sub    %eax,%edx
80104bbf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bc2:	8b 80 84 00 00 00    	mov    0x84(%eax),%eax
80104bc8:	29 c2                	sub    %eax,%edx
80104bca:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bcd:	8b 80 88 00 00 00    	mov    0x88(%eax),%eax
80104bd3:	29 c2                	sub    %eax,%edx
80104bd5:	8b 45 08             	mov    0x8(%ebp),%eax
80104bd8:	89 10                	mov    %edx,(%eax)
        *rtime=p->rtime;
80104bda:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bdd:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80104be3:	8b 45 0c             	mov    0xc(%ebp),%eax
80104be6:	89 10                	mov    %edx,(%eax)
        pid = p->pid;
80104be8:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104beb:	8b 40 10             	mov    0x10(%eax),%eax
80104bee:	89 45 ec             	mov    %eax,-0x14(%ebp)
        kfree(p->kstack);
80104bf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104bf4:	8b 40 08             	mov    0x8(%eax),%eax
80104bf7:	83 ec 0c             	sub    $0xc,%esp
80104bfa:	50                   	push   %eax
80104bfb:	e8 ae df ff ff       	call   80102bae <kfree>
80104c00:	83 c4 10             	add    $0x10,%esp
        p->kstack = 0;
80104c03:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c06:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
        freevm(p->pgdir);
80104c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c10:	8b 40 04             	mov    0x4(%eax),%eax
80104c13:	83 ec 0c             	sub    $0xc,%esp
80104c16:	50                   	push   %eax
80104c17:	e8 67 38 00 00       	call   80108483 <freevm>
80104c1c:	83 c4 10             	add    $0x10,%esp
        p->state = UNUSED;
80104c1f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c22:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
        p->pid = 0;
80104c29:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c2c:	c7 40 10 00 00 00 00 	movl   $0x0,0x10(%eax)
        p->parent = 0;
80104c33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c36:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
        p->name[0] = 0;
80104c3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c40:	c6 40 6c 00          	movb   $0x0,0x6c(%eax)
        p->killed = 0;
80104c44:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104c47:	c7 40 24 00 00 00 00 	movl   $0x0,0x24(%eax)
        release(&ptable.lock);
80104c4e:	83 ec 0c             	sub    $0xc,%esp
80104c51:	68 80 29 11 80       	push   $0x80112980
80104c56:	e8 b3 05 00 00       	call   8010520e <release>
80104c5b:	83 c4 10             	add    $0x10,%esp
        return pid;
80104c5e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c61:	eb 5b                	jmp    80104cbe <waitx+0x163>
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != proc)
        continue;
80104c63:	90                   	nop

  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for zombie children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104c64:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104c6b:	81 7d f4 b4 4c 11 80 	cmpl   $0x80114cb4,-0xc(%ebp)
80104c72:	0f 82 0c ff ff ff    	jb     80104b84 <waitx+0x29>
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || proc->killed){
80104c78:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80104c7c:	74 0d                	je     80104c8b <waitx+0x130>
80104c7e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104c84:	8b 40 24             	mov    0x24(%eax),%eax
80104c87:	85 c0                	test   %eax,%eax
80104c89:	74 17                	je     80104ca2 <waitx+0x147>
      release(&ptable.lock);
80104c8b:	83 ec 0c             	sub    $0xc,%esp
80104c8e:	68 80 29 11 80       	push   $0x80112980
80104c93:	e8 76 05 00 00       	call   8010520e <release>
80104c98:	83 c4 10             	add    $0x10,%esp
      return -1;
80104c9b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ca0:	eb 1c                	jmp    80104cbe <waitx+0x163>
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(proc, &ptable.lock);  //DOC: wait-sleep
80104ca2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104ca8:	83 ec 08             	sub    $0x8,%esp
80104cab:	68 80 29 11 80       	push   $0x80112980
80104cb0:	50                   	push   %eax
80104cb1:	e8 ef 01 00 00       	call   80104ea5 <sleep>
80104cb6:	83 c4 10             	add    $0x10,%esp
  }
80104cb9:	e9 b3 fe ff ff       	jmp    80104b71 <waitx+0x16>
}
80104cbe:	c9                   	leave  
80104cbf:	c3                   	ret    

80104cc0 <scheduler>:
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
80104cc0:	55                   	push   %ebp
80104cc1:	89 e5                	mov    %esp,%ebp
80104cc3:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  for(;;){
    // Enable interrupts on this processor.
    sti();
80104cc6:	e8 68 f7 ff ff       	call   80104433 <sti>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
80104ccb:	83 ec 0c             	sub    $0xc,%esp
80104cce:	68 80 29 11 80       	push   $0x80112980
80104cd3:	e8 cf 04 00 00       	call   801051a7 <acquire>
80104cd8:	83 c4 10             	add    $0x10,%esp
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104cdb:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104ce2:	eb 66                	jmp    80104d4a <scheduler+0x8a>
      if(p->state != RUNNABLE)
80104ce4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ce7:	8b 40 0c             	mov    0xc(%eax),%eax
80104cea:	83 f8 03             	cmp    $0x3,%eax
80104ced:	75 53                	jne    80104d42 <scheduler+0x82>
        continue;

      // Switch to chosen process.  It is the process's job
      // to release ptable.lock and then reacquire it
      // before jumping back to us.
      proc = p;
80104cef:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104cf2:	65 a3 04 00 00 00    	mov    %eax,%gs:0x4
      switchuvm(p);
80104cf8:	83 ec 0c             	sub    $0xc,%esp
80104cfb:	ff 75 f4             	pushl  -0xc(%ebp)
80104cfe:	e8 3a 33 00 00       	call   8010803d <switchuvm>
80104d03:	83 c4 10             	add    $0x10,%esp
      p->state = RUNNING;
80104d06:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104d09:	c7 40 0c 04 00 00 00 	movl   $0x4,0xc(%eax)
      swtch(&cpu->scheduler, proc->context);
80104d10:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104d16:	8b 40 1c             	mov    0x1c(%eax),%eax
80104d19:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80104d20:	83 c2 04             	add    $0x4,%edx
80104d23:	83 ec 08             	sub    $0x8,%esp
80104d26:	50                   	push   %eax
80104d27:	52                   	push   %edx
80104d28:	e8 51 09 00 00       	call   8010567e <swtch>
80104d2d:	83 c4 10             	add    $0x10,%esp
      switchkvm();
80104d30:	e8 eb 32 00 00       	call   80108020 <switchkvm>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
80104d35:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80104d3c:	00 00 00 00 
80104d40:	eb 01                	jmp    80104d43 <scheduler+0x83>

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->state != RUNNABLE)
        continue;
80104d42:	90                   	nop
    // Enable interrupts on this processor.
    sti();

    // Loop over process table looking for process to run.
    acquire(&ptable.lock);
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104d43:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80104d4a:	81 7d f4 b4 4c 11 80 	cmpl   $0x80114cb4,-0xc(%ebp)
80104d51:	72 91                	jb     80104ce4 <scheduler+0x24>

      // Process is done running for now.
      // It should have changed its p->state before coming back.
      proc = 0;
    }
    release(&ptable.lock);
80104d53:	83 ec 0c             	sub    $0xc,%esp
80104d56:	68 80 29 11 80       	push   $0x80112980
80104d5b:	e8 ae 04 00 00       	call   8010520e <release>
80104d60:	83 c4 10             	add    $0x10,%esp

  }
80104d63:	e9 5e ff ff ff       	jmp    80104cc6 <scheduler+0x6>

80104d68 <sched>:

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state.
void
sched(void)
{
80104d68:	55                   	push   %ebp
80104d69:	89 e5                	mov    %esp,%ebp
80104d6b:	83 ec 18             	sub    $0x18,%esp
  int intena;

  if(!holding(&ptable.lock))
80104d6e:	83 ec 0c             	sub    $0xc,%esp
80104d71:	68 80 29 11 80       	push   $0x80112980
80104d76:	e8 5f 05 00 00       	call   801052da <holding>
80104d7b:	83 c4 10             	add    $0x10,%esp
80104d7e:	85 c0                	test   %eax,%eax
80104d80:	75 0d                	jne    80104d8f <sched+0x27>
    panic("sched ptable.lock");
80104d82:	83 ec 0c             	sub    $0xc,%esp
80104d85:	68 f9 8a 10 80       	push   $0x80108af9
80104d8a:	e8 d7 b7 ff ff       	call   80100566 <panic>
  if(cpu->ncli != 1)
80104d8f:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104d95:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80104d9b:	83 f8 01             	cmp    $0x1,%eax
80104d9e:	74 0d                	je     80104dad <sched+0x45>
    panic("sched locks");
80104da0:	83 ec 0c             	sub    $0xc,%esp
80104da3:	68 0b 8b 10 80       	push   $0x80108b0b
80104da8:	e8 b9 b7 ff ff       	call   80100566 <panic>
  if(proc->state == RUNNING)
80104dad:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104db3:	8b 40 0c             	mov    0xc(%eax),%eax
80104db6:	83 f8 04             	cmp    $0x4,%eax
80104db9:	75 0d                	jne    80104dc8 <sched+0x60>
    panic("sched running");
80104dbb:	83 ec 0c             	sub    $0xc,%esp
80104dbe:	68 17 8b 10 80       	push   $0x80108b17
80104dc3:	e8 9e b7 ff ff       	call   80100566 <panic>
  if(readeflags()&FL_IF)
80104dc8:	e8 56 f6 ff ff       	call   80104423 <readeflags>
80104dcd:	25 00 02 00 00       	and    $0x200,%eax
80104dd2:	85 c0                	test   %eax,%eax
80104dd4:	74 0d                	je     80104de3 <sched+0x7b>
    panic("sched interruptible");
80104dd6:	83 ec 0c             	sub    $0xc,%esp
80104dd9:	68 25 8b 10 80       	push   $0x80108b25
80104dde:	e8 83 b7 ff ff       	call   80100566 <panic>
  intena = cpu->intena;
80104de3:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104de9:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
80104def:	89 45 f4             	mov    %eax,-0xc(%ebp)
  swtch(&proc->context, cpu->scheduler);
80104df2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104df8:	8b 40 04             	mov    0x4(%eax),%eax
80104dfb:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80104e02:	83 c2 1c             	add    $0x1c,%edx
80104e05:	83 ec 08             	sub    $0x8,%esp
80104e08:	50                   	push   %eax
80104e09:	52                   	push   %edx
80104e0a:	e8 6f 08 00 00       	call   8010567e <swtch>
80104e0f:	83 c4 10             	add    $0x10,%esp
  cpu->intena = intena;
80104e12:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80104e18:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104e1b:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80104e21:	90                   	nop
80104e22:	c9                   	leave  
80104e23:	c3                   	ret    

80104e24 <yield>:

// Give up the CPU for one scheduling round.
void
yield(void)
{
80104e24:	55                   	push   %ebp
80104e25:	89 e5                	mov    %esp,%ebp
80104e27:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80104e2a:	83 ec 0c             	sub    $0xc,%esp
80104e2d:	68 80 29 11 80       	push   $0x80112980
80104e32:	e8 70 03 00 00       	call   801051a7 <acquire>
80104e37:	83 c4 10             	add    $0x10,%esp
  proc->state = RUNNABLE;
80104e3a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104e40:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80104e47:	e8 1c ff ff ff       	call   80104d68 <sched>
  release(&ptable.lock);
80104e4c:	83 ec 0c             	sub    $0xc,%esp
80104e4f:	68 80 29 11 80       	push   $0x80112980
80104e54:	e8 b5 03 00 00       	call   8010520e <release>
80104e59:	83 c4 10             	add    $0x10,%esp
}
80104e5c:	90                   	nop
80104e5d:	c9                   	leave  
80104e5e:	c3                   	ret    

80104e5f <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
80104e5f:	55                   	push   %ebp
80104e60:	89 e5                	mov    %esp,%ebp
80104e62:	83 ec 08             	sub    $0x8,%esp
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);
80104e65:	83 ec 0c             	sub    $0xc,%esp
80104e68:	68 80 29 11 80       	push   $0x80112980
80104e6d:	e8 9c 03 00 00       	call   8010520e <release>
80104e72:	83 c4 10             	add    $0x10,%esp

  if (first) {
80104e75:	a1 08 b0 10 80       	mov    0x8010b008,%eax
80104e7a:	85 c0                	test   %eax,%eax
80104e7c:	74 24                	je     80104ea2 <forkret+0x43>
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot 
    // be run from main().
    first = 0;
80104e7e:	c7 05 08 b0 10 80 00 	movl   $0x0,0x8010b008
80104e85:	00 00 00 
    iinit(ROOTDEV);
80104e88:	83 ec 0c             	sub    $0xc,%esp
80104e8b:	6a 01                	push   $0x1
80104e8d:	e8 91 c7 ff ff       	call   80101623 <iinit>
80104e92:	83 c4 10             	add    $0x10,%esp
    initlog(ROOTDEV);
80104e95:	83 ec 0c             	sub    $0xc,%esp
80104e98:	6a 01                	push   $0x1
80104e9a:	e8 75 e4 ff ff       	call   80103314 <initlog>
80104e9f:	83 c4 10             	add    $0x10,%esp
  }
  
  // Return to "caller", actually trapret (see allocproc).
}
80104ea2:	90                   	nop
80104ea3:	c9                   	leave  
80104ea4:	c3                   	ret    

80104ea5 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
80104ea5:	55                   	push   %ebp
80104ea6:	89 e5                	mov    %esp,%ebp
80104ea8:	83 ec 08             	sub    $0x8,%esp
  if(proc == 0)
80104eab:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104eb1:	85 c0                	test   %eax,%eax
80104eb3:	75 0d                	jne    80104ec2 <sleep+0x1d>
    panic("sleep");
80104eb5:	83 ec 0c             	sub    $0xc,%esp
80104eb8:	68 39 8b 10 80       	push   $0x80108b39
80104ebd:	e8 a4 b6 ff ff       	call   80100566 <panic>

  if(lk == 0)
80104ec2:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80104ec6:	75 0d                	jne    80104ed5 <sleep+0x30>
    panic("sleep without lk");
80104ec8:	83 ec 0c             	sub    $0xc,%esp
80104ecb:	68 3f 8b 10 80       	push   $0x80108b3f
80104ed0:	e8 91 b6 ff ff       	call   80100566 <panic>
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
80104ed5:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104edc:	74 1e                	je     80104efc <sleep+0x57>
    acquire(&ptable.lock);  //DOC: sleeplock1
80104ede:	83 ec 0c             	sub    $0xc,%esp
80104ee1:	68 80 29 11 80       	push   $0x80112980
80104ee6:	e8 bc 02 00 00       	call   801051a7 <acquire>
80104eeb:	83 c4 10             	add    $0x10,%esp
    release(lk);
80104eee:	83 ec 0c             	sub    $0xc,%esp
80104ef1:	ff 75 0c             	pushl  0xc(%ebp)
80104ef4:	e8 15 03 00 00       	call   8010520e <release>
80104ef9:	83 c4 10             	add    $0x10,%esp
  }

  // Go to sleep.
  proc->chan = chan;
80104efc:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f02:	8b 55 08             	mov    0x8(%ebp),%edx
80104f05:	89 50 20             	mov    %edx,0x20(%eax)
  proc->state = SLEEPING;
80104f08:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f0e:	c7 40 0c 02 00 00 00 	movl   $0x2,0xc(%eax)
  sched();
80104f15:	e8 4e fe ff ff       	call   80104d68 <sched>

  // Tidy up.
  proc->chan = 0;
80104f1a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80104f20:	c7 40 20 00 00 00 00 	movl   $0x0,0x20(%eax)

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
80104f27:	81 7d 0c 80 29 11 80 	cmpl   $0x80112980,0xc(%ebp)
80104f2e:	74 1e                	je     80104f4e <sleep+0xa9>
    release(&ptable.lock);
80104f30:	83 ec 0c             	sub    $0xc,%esp
80104f33:	68 80 29 11 80       	push   $0x80112980
80104f38:	e8 d1 02 00 00       	call   8010520e <release>
80104f3d:	83 c4 10             	add    $0x10,%esp
    acquire(lk);
80104f40:	83 ec 0c             	sub    $0xc,%esp
80104f43:	ff 75 0c             	pushl  0xc(%ebp)
80104f46:	e8 5c 02 00 00       	call   801051a7 <acquire>
80104f4b:	83 c4 10             	add    $0x10,%esp
  }
}
80104f4e:	90                   	nop
80104f4f:	c9                   	leave  
80104f50:	c3                   	ret    

80104f51 <wakeup1>:
//PAGEBREAK!
// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80104f51:	55                   	push   %ebp
80104f52:	89 e5                	mov    %esp,%ebp
80104f54:	83 ec 10             	sub    $0x10,%esp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f57:	c7 45 fc b4 29 11 80 	movl   $0x801129b4,-0x4(%ebp)
80104f5e:	eb 27                	jmp    80104f87 <wakeup1+0x36>
    if(p->state == SLEEPING && p->chan == chan)
80104f60:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f63:	8b 40 0c             	mov    0xc(%eax),%eax
80104f66:	83 f8 02             	cmp    $0x2,%eax
80104f69:	75 15                	jne    80104f80 <wakeup1+0x2f>
80104f6b:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f6e:	8b 40 20             	mov    0x20(%eax),%eax
80104f71:	3b 45 08             	cmp    0x8(%ebp),%eax
80104f74:	75 0a                	jne    80104f80 <wakeup1+0x2f>
      p->state = RUNNABLE;
80104f76:	8b 45 fc             	mov    -0x4(%ebp),%eax
80104f79:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80104f80:	81 45 fc 8c 00 00 00 	addl   $0x8c,-0x4(%ebp)
80104f87:	81 7d fc b4 4c 11 80 	cmpl   $0x80114cb4,-0x4(%ebp)
80104f8e:	72 d0                	jb     80104f60 <wakeup1+0xf>
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}
80104f90:	90                   	nop
80104f91:	c9                   	leave  
80104f92:	c3                   	ret    

80104f93 <wakeup>:


// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80104f93:	55                   	push   %ebp
80104f94:	89 e5                	mov    %esp,%ebp
80104f96:	83 ec 08             	sub    $0x8,%esp
  acquire(&ptable.lock);
80104f99:	83 ec 0c             	sub    $0xc,%esp
80104f9c:	68 80 29 11 80       	push   $0x80112980
80104fa1:	e8 01 02 00 00       	call   801051a7 <acquire>
80104fa6:	83 c4 10             	add    $0x10,%esp
  wakeup1(chan);
80104fa9:	83 ec 0c             	sub    $0xc,%esp
80104fac:	ff 75 08             	pushl  0x8(%ebp)
80104faf:	e8 9d ff ff ff       	call   80104f51 <wakeup1>
80104fb4:	83 c4 10             	add    $0x10,%esp
  release(&ptable.lock);
80104fb7:	83 ec 0c             	sub    $0xc,%esp
80104fba:	68 80 29 11 80       	push   $0x80112980
80104fbf:	e8 4a 02 00 00       	call   8010520e <release>
80104fc4:	83 c4 10             	add    $0x10,%esp
}
80104fc7:	90                   	nop
80104fc8:	c9                   	leave  
80104fc9:	c3                   	ret    

80104fca <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80104fca:	55                   	push   %ebp
80104fcb:	89 e5                	mov    %esp,%ebp
80104fcd:	83 ec 18             	sub    $0x18,%esp
  struct proc *p;

  acquire(&ptable.lock);
80104fd0:	83 ec 0c             	sub    $0xc,%esp
80104fd3:	68 80 29 11 80       	push   $0x80112980
80104fd8:	e8 ca 01 00 00       	call   801051a7 <acquire>
80104fdd:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80104fe0:	c7 45 f4 b4 29 11 80 	movl   $0x801129b4,-0xc(%ebp)
80104fe7:	eb 48                	jmp    80105031 <kill+0x67>
    if(p->pid == pid){
80104fe9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104fec:	8b 40 10             	mov    0x10(%eax),%eax
80104fef:	3b 45 08             	cmp    0x8(%ebp),%eax
80104ff2:	75 36                	jne    8010502a <kill+0x60>
      p->killed = 1;
80104ff4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104ff7:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80104ffe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105001:	8b 40 0c             	mov    0xc(%eax),%eax
80105004:	83 f8 02             	cmp    $0x2,%eax
80105007:	75 0a                	jne    80105013 <kill+0x49>
        p->state = RUNNABLE;
80105009:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010500c:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
      release(&ptable.lock);
80105013:	83 ec 0c             	sub    $0xc,%esp
80105016:	68 80 29 11 80       	push   $0x80112980
8010501b:	e8 ee 01 00 00       	call   8010520e <release>
80105020:	83 c4 10             	add    $0x10,%esp
      return 0;
80105023:	b8 00 00 00 00       	mov    $0x0,%eax
80105028:	eb 25                	jmp    8010504f <kill+0x85>
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010502a:	81 45 f4 8c 00 00 00 	addl   $0x8c,-0xc(%ebp)
80105031:	81 7d f4 b4 4c 11 80 	cmpl   $0x80114cb4,-0xc(%ebp)
80105038:	72 af                	jb     80104fe9 <kill+0x1f>
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
8010503a:	83 ec 0c             	sub    $0xc,%esp
8010503d:	68 80 29 11 80       	push   $0x80112980
80105042:	e8 c7 01 00 00       	call   8010520e <release>
80105047:	83 c4 10             	add    $0x10,%esp
  return -1;
8010504a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010504f:	c9                   	leave  
80105050:	c3                   	ret    

80105051 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80105051:	55                   	push   %ebp
80105052:	89 e5                	mov    %esp,%ebp
80105054:	83 ec 48             	sub    $0x48,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105057:	c7 45 f0 b4 29 11 80 	movl   $0x801129b4,-0x10(%ebp)
8010505e:	e9 da 00 00 00       	jmp    8010513d <procdump+0xec>
    if(p->state == UNUSED)
80105063:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105066:	8b 40 0c             	mov    0xc(%eax),%eax
80105069:	85 c0                	test   %eax,%eax
8010506b:	0f 84 c4 00 00 00    	je     80105135 <procdump+0xe4>
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80105071:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105074:	8b 40 0c             	mov    0xc(%eax),%eax
80105077:	83 f8 05             	cmp    $0x5,%eax
8010507a:	77 23                	ja     8010509f <procdump+0x4e>
8010507c:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010507f:	8b 40 0c             	mov    0xc(%eax),%eax
80105082:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
80105089:	85 c0                	test   %eax,%eax
8010508b:	74 12                	je     8010509f <procdump+0x4e>
      state = states[p->state];
8010508d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105090:	8b 40 0c             	mov    0xc(%eax),%eax
80105093:	8b 04 85 0c b0 10 80 	mov    -0x7fef4ff4(,%eax,4),%eax
8010509a:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010509d:	eb 07                	jmp    801050a6 <procdump+0x55>
    else
      state = "???";
8010509f:	c7 45 ec 50 8b 10 80 	movl   $0x80108b50,-0x14(%ebp)
    cprintf("%d %s %s", p->pid, state, p->name);
801050a6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050a9:	8d 50 6c             	lea    0x6c(%eax),%edx
801050ac:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050af:	8b 40 10             	mov    0x10(%eax),%eax
801050b2:	52                   	push   %edx
801050b3:	ff 75 ec             	pushl  -0x14(%ebp)
801050b6:	50                   	push   %eax
801050b7:	68 54 8b 10 80       	push   $0x80108b54
801050bc:	e8 05 b3 ff ff       	call   801003c6 <cprintf>
801050c1:	83 c4 10             	add    $0x10,%esp
    if(p->state == SLEEPING){
801050c4:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050c7:	8b 40 0c             	mov    0xc(%eax),%eax
801050ca:	83 f8 02             	cmp    $0x2,%eax
801050cd:	75 54                	jne    80105123 <procdump+0xd2>
      getcallerpcs((uint*)p->context->ebp+2, pc);
801050cf:	8b 45 f0             	mov    -0x10(%ebp),%eax
801050d2:	8b 40 1c             	mov    0x1c(%eax),%eax
801050d5:	8b 40 0c             	mov    0xc(%eax),%eax
801050d8:	83 c0 08             	add    $0x8,%eax
801050db:	89 c2                	mov    %eax,%edx
801050dd:	83 ec 08             	sub    $0x8,%esp
801050e0:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801050e3:	50                   	push   %eax
801050e4:	52                   	push   %edx
801050e5:	e8 76 01 00 00       	call   80105260 <getcallerpcs>
801050ea:	83 c4 10             	add    $0x10,%esp
      for(i=0; i<10 && pc[i] != 0; i++)
801050ed:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801050f4:	eb 1c                	jmp    80105112 <procdump+0xc1>
        cprintf(" %p", pc[i]);
801050f6:	8b 45 f4             	mov    -0xc(%ebp),%eax
801050f9:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
801050fd:	83 ec 08             	sub    $0x8,%esp
80105100:	50                   	push   %eax
80105101:	68 5d 8b 10 80       	push   $0x80108b5d
80105106:	e8 bb b2 ff ff       	call   801003c6 <cprintf>
8010510b:	83 c4 10             	add    $0x10,%esp
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
8010510e:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80105112:	83 7d f4 09          	cmpl   $0x9,-0xc(%ebp)
80105116:	7f 0b                	jg     80105123 <procdump+0xd2>
80105118:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010511b:	8b 44 85 c4          	mov    -0x3c(%ebp,%eax,4),%eax
8010511f:	85 c0                	test   %eax,%eax
80105121:	75 d3                	jne    801050f6 <procdump+0xa5>
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80105123:	83 ec 0c             	sub    $0xc,%esp
80105126:	68 61 8b 10 80       	push   $0x80108b61
8010512b:	e8 96 b2 ff ff       	call   801003c6 <cprintf>
80105130:	83 c4 10             	add    $0x10,%esp
80105133:	eb 01                	jmp    80105136 <procdump+0xe5>
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
80105135:	90                   	nop
  int i;
  struct proc *p;
  char *state;
  uint pc[10];
  
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80105136:	81 45 f0 8c 00 00 00 	addl   $0x8c,-0x10(%ebp)
8010513d:	81 7d f0 b4 4c 11 80 	cmpl   $0x80114cb4,-0x10(%ebp)
80105144:	0f 82 19 ff ff ff    	jb     80105063 <procdump+0x12>
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }
}
8010514a:	90                   	nop
8010514b:	c9                   	leave  
8010514c:	c3                   	ret    

8010514d <readeflags>:
  asm volatile("ltr %0" : : "r" (sel));
}

static inline uint
readeflags(void)
{
8010514d:	55                   	push   %ebp
8010514e:	89 e5                	mov    %esp,%ebp
80105150:	83 ec 10             	sub    $0x10,%esp
  uint eflags;
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80105153:	9c                   	pushf  
80105154:	58                   	pop    %eax
80105155:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return eflags;
80105158:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010515b:	c9                   	leave  
8010515c:	c3                   	ret    

8010515d <cli>:
  asm volatile("movw %0, %%gs" : : "r" (v));
}

static inline void
cli(void)
{
8010515d:	55                   	push   %ebp
8010515e:	89 e5                	mov    %esp,%ebp
  asm volatile("cli");
80105160:	fa                   	cli    
}
80105161:	90                   	nop
80105162:	5d                   	pop    %ebp
80105163:	c3                   	ret    

80105164 <sti>:

static inline void
sti(void)
{
80105164:	55                   	push   %ebp
80105165:	89 e5                	mov    %esp,%ebp
  asm volatile("sti");
80105167:	fb                   	sti    
}
80105168:	90                   	nop
80105169:	5d                   	pop    %ebp
8010516a:	c3                   	ret    

8010516b <xchg>:

static inline uint
xchg(volatile uint *addr, uint newval)
{
8010516b:	55                   	push   %ebp
8010516c:	89 e5                	mov    %esp,%ebp
8010516e:	83 ec 10             	sub    $0x10,%esp
  uint result;
  
  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80105171:	8b 55 08             	mov    0x8(%ebp),%edx
80105174:	8b 45 0c             	mov    0xc(%ebp),%eax
80105177:	8b 4d 08             	mov    0x8(%ebp),%ecx
8010517a:	f0 87 02             	lock xchg %eax,(%edx)
8010517d:	89 45 fc             	mov    %eax,-0x4(%ebp)
               "+m" (*addr), "=a" (result) :
               "1" (newval) :
               "cc");
  return result;
80105180:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105183:	c9                   	leave  
80105184:	c3                   	ret    

80105185 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80105185:	55                   	push   %ebp
80105186:	89 e5                	mov    %esp,%ebp
  lk->name = name;
80105188:	8b 45 08             	mov    0x8(%ebp),%eax
8010518b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010518e:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80105191:	8b 45 08             	mov    0x8(%ebp),%eax
80105194:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
8010519a:	8b 45 08             	mov    0x8(%ebp),%eax
8010519d:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
801051a4:	90                   	nop
801051a5:	5d                   	pop    %ebp
801051a6:	c3                   	ret    

801051a7 <acquire>:
// Loops (spins) until the lock is acquired.
// Holding a lock for a long time may cause
// other CPUs to waste time spinning to acquire it.
void
acquire(struct spinlock *lk)
{
801051a7:	55                   	push   %ebp
801051a8:	89 e5                	mov    %esp,%ebp
801051aa:	83 ec 08             	sub    $0x8,%esp
  pushcli(); // disable interrupts to avoid deadlock.
801051ad:	e8 52 01 00 00       	call   80105304 <pushcli>
  if(holding(lk))
801051b2:	8b 45 08             	mov    0x8(%ebp),%eax
801051b5:	83 ec 0c             	sub    $0xc,%esp
801051b8:	50                   	push   %eax
801051b9:	e8 1c 01 00 00       	call   801052da <holding>
801051be:	83 c4 10             	add    $0x10,%esp
801051c1:	85 c0                	test   %eax,%eax
801051c3:	74 0d                	je     801051d2 <acquire+0x2b>
    panic("acquire");
801051c5:	83 ec 0c             	sub    $0xc,%esp
801051c8:	68 8d 8b 10 80       	push   $0x80108b8d
801051cd:	e8 94 b3 ff ff       	call   80100566 <panic>

  // The xchg is atomic.
  // It also serializes, so that reads after acquire are not
  // reordered before it. 
  while(xchg(&lk->locked, 1) != 0)
801051d2:	90                   	nop
801051d3:	8b 45 08             	mov    0x8(%ebp),%eax
801051d6:	83 ec 08             	sub    $0x8,%esp
801051d9:	6a 01                	push   $0x1
801051db:	50                   	push   %eax
801051dc:	e8 8a ff ff ff       	call   8010516b <xchg>
801051e1:	83 c4 10             	add    $0x10,%esp
801051e4:	85 c0                	test   %eax,%eax
801051e6:	75 eb                	jne    801051d3 <acquire+0x2c>
    ;

  // Record info about lock acquisition for debugging.
  lk->cpu = cpu;
801051e8:	8b 45 08             	mov    0x8(%ebp),%eax
801051eb:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
801051f2:	89 50 08             	mov    %edx,0x8(%eax)
  getcallerpcs(&lk, lk->pcs);
801051f5:	8b 45 08             	mov    0x8(%ebp),%eax
801051f8:	83 c0 0c             	add    $0xc,%eax
801051fb:	83 ec 08             	sub    $0x8,%esp
801051fe:	50                   	push   %eax
801051ff:	8d 45 08             	lea    0x8(%ebp),%eax
80105202:	50                   	push   %eax
80105203:	e8 58 00 00 00       	call   80105260 <getcallerpcs>
80105208:	83 c4 10             	add    $0x10,%esp
}
8010520b:	90                   	nop
8010520c:	c9                   	leave  
8010520d:	c3                   	ret    

8010520e <release>:

// Release the lock.
void
release(struct spinlock *lk)
{
8010520e:	55                   	push   %ebp
8010520f:	89 e5                	mov    %esp,%ebp
80105211:	83 ec 08             	sub    $0x8,%esp
  if(!holding(lk))
80105214:	83 ec 0c             	sub    $0xc,%esp
80105217:	ff 75 08             	pushl  0x8(%ebp)
8010521a:	e8 bb 00 00 00       	call   801052da <holding>
8010521f:	83 c4 10             	add    $0x10,%esp
80105222:	85 c0                	test   %eax,%eax
80105224:	75 0d                	jne    80105233 <release+0x25>
    panic("release");
80105226:	83 ec 0c             	sub    $0xc,%esp
80105229:	68 95 8b 10 80       	push   $0x80108b95
8010522e:	e8 33 b3 ff ff       	call   80100566 <panic>

  lk->pcs[0] = 0;
80105233:	8b 45 08             	mov    0x8(%ebp),%eax
80105236:	c7 40 0c 00 00 00 00 	movl   $0x0,0xc(%eax)
  lk->cpu = 0;
8010523d:	8b 45 08             	mov    0x8(%ebp),%eax
80105240:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
  // But the 2007 Intel 64 Architecture Memory Ordering White
  // Paper says that Intel 64 and IA-32 will not move a load
  // after a store. So lock->locked = 0 would work here.
  // The xchg being asm volatile ensures gcc emits it after
  // the above assignments (and after the critical section).
  xchg(&lk->locked, 0);
80105247:	8b 45 08             	mov    0x8(%ebp),%eax
8010524a:	83 ec 08             	sub    $0x8,%esp
8010524d:	6a 00                	push   $0x0
8010524f:	50                   	push   %eax
80105250:	e8 16 ff ff ff       	call   8010516b <xchg>
80105255:	83 c4 10             	add    $0x10,%esp

  popcli();
80105258:	e8 ec 00 00 00       	call   80105349 <popcli>
}
8010525d:	90                   	nop
8010525e:	c9                   	leave  
8010525f:	c3                   	ret    

80105260 <getcallerpcs>:

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80105260:	55                   	push   %ebp
80105261:	89 e5                	mov    %esp,%ebp
80105263:	83 ec 10             	sub    $0x10,%esp
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
80105266:	8b 45 08             	mov    0x8(%ebp),%eax
80105269:	83 e8 08             	sub    $0x8,%eax
8010526c:	89 45 fc             	mov    %eax,-0x4(%ebp)
  for(i = 0; i < 10; i++){
8010526f:	c7 45 f8 00 00 00 00 	movl   $0x0,-0x8(%ebp)
80105276:	eb 38                	jmp    801052b0 <getcallerpcs+0x50>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80105278:	83 7d fc 00          	cmpl   $0x0,-0x4(%ebp)
8010527c:	74 53                	je     801052d1 <getcallerpcs+0x71>
8010527e:	81 7d fc ff ff ff 7f 	cmpl   $0x7fffffff,-0x4(%ebp)
80105285:	76 4a                	jbe    801052d1 <getcallerpcs+0x71>
80105287:	83 7d fc ff          	cmpl   $0xffffffff,-0x4(%ebp)
8010528b:	74 44                	je     801052d1 <getcallerpcs+0x71>
      break;
    pcs[i] = ebp[1];     // saved %eip
8010528d:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105290:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80105297:	8b 45 0c             	mov    0xc(%ebp),%eax
8010529a:	01 c2                	add    %eax,%edx
8010529c:	8b 45 fc             	mov    -0x4(%ebp),%eax
8010529f:	8b 40 04             	mov    0x4(%eax),%eax
801052a2:	89 02                	mov    %eax,(%edx)
    ebp = (uint*)ebp[0]; // saved %ebp
801052a4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801052a7:	8b 00                	mov    (%eax),%eax
801052a9:	89 45 fc             	mov    %eax,-0x4(%ebp)
{
  uint *ebp;
  int i;
  
  ebp = (uint*)v - 2;
  for(i = 0; i < 10; i++){
801052ac:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052b0:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052b4:	7e c2                	jle    80105278 <getcallerpcs+0x18>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052b6:	eb 19                	jmp    801052d1 <getcallerpcs+0x71>
    pcs[i] = 0;
801052b8:	8b 45 f8             	mov    -0x8(%ebp),%eax
801052bb:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801052c2:	8b 45 0c             	mov    0xc(%ebp),%eax
801052c5:	01 d0                	add    %edx,%eax
801052c7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
      break;
    pcs[i] = ebp[1];     // saved %eip
    ebp = (uint*)ebp[0]; // saved %ebp
  }
  for(; i < 10; i++)
801052cd:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
801052d1:	83 7d f8 09          	cmpl   $0x9,-0x8(%ebp)
801052d5:	7e e1                	jle    801052b8 <getcallerpcs+0x58>
    pcs[i] = 0;
}
801052d7:	90                   	nop
801052d8:	c9                   	leave  
801052d9:	c3                   	ret    

801052da <holding>:

// Check whether this cpu is holding the lock.
int
holding(struct spinlock *lock)
{
801052da:	55                   	push   %ebp
801052db:	89 e5                	mov    %esp,%ebp
  return lock->locked && lock->cpu == cpu;
801052dd:	8b 45 08             	mov    0x8(%ebp),%eax
801052e0:	8b 00                	mov    (%eax),%eax
801052e2:	85 c0                	test   %eax,%eax
801052e4:	74 17                	je     801052fd <holding+0x23>
801052e6:	8b 45 08             	mov    0x8(%ebp),%eax
801052e9:	8b 50 08             	mov    0x8(%eax),%edx
801052ec:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801052f2:	39 c2                	cmp    %eax,%edx
801052f4:	75 07                	jne    801052fd <holding+0x23>
801052f6:	b8 01 00 00 00       	mov    $0x1,%eax
801052fb:	eb 05                	jmp    80105302 <holding+0x28>
801052fd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105302:	5d                   	pop    %ebp
80105303:	c3                   	ret    

80105304 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80105304:	55                   	push   %ebp
80105305:	89 e5                	mov    %esp,%ebp
80105307:	83 ec 10             	sub    $0x10,%esp
  int eflags;
  
  eflags = readeflags();
8010530a:	e8 3e fe ff ff       	call   8010514d <readeflags>
8010530f:	89 45 fc             	mov    %eax,-0x4(%ebp)
  cli();
80105312:	e8 46 fe ff ff       	call   8010515d <cli>
  if(cpu->ncli++ == 0)
80105317:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010531e:	8b 82 ac 00 00 00    	mov    0xac(%edx),%eax
80105324:	8d 48 01             	lea    0x1(%eax),%ecx
80105327:	89 8a ac 00 00 00    	mov    %ecx,0xac(%edx)
8010532d:	85 c0                	test   %eax,%eax
8010532f:	75 15                	jne    80105346 <pushcli+0x42>
    cpu->intena = eflags & FL_IF;
80105331:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105337:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010533a:	81 e2 00 02 00 00    	and    $0x200,%edx
80105340:	89 90 b0 00 00 00    	mov    %edx,0xb0(%eax)
}
80105346:	90                   	nop
80105347:	c9                   	leave  
80105348:	c3                   	ret    

80105349 <popcli>:

void
popcli(void)
{
80105349:	55                   	push   %ebp
8010534a:	89 e5                	mov    %esp,%ebp
8010534c:	83 ec 08             	sub    $0x8,%esp
  if(readeflags()&FL_IF)
8010534f:	e8 f9 fd ff ff       	call   8010514d <readeflags>
80105354:	25 00 02 00 00       	and    $0x200,%eax
80105359:	85 c0                	test   %eax,%eax
8010535b:	74 0d                	je     8010536a <popcli+0x21>
    panic("popcli - interruptible");
8010535d:	83 ec 0c             	sub    $0xc,%esp
80105360:	68 9d 8b 10 80       	push   $0x80108b9d
80105365:	e8 fc b1 ff ff       	call   80100566 <panic>
  if(--cpu->ncli < 0)
8010536a:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80105370:	8b 90 ac 00 00 00    	mov    0xac(%eax),%edx
80105376:	83 ea 01             	sub    $0x1,%edx
80105379:	89 90 ac 00 00 00    	mov    %edx,0xac(%eax)
8010537f:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
80105385:	85 c0                	test   %eax,%eax
80105387:	79 0d                	jns    80105396 <popcli+0x4d>
    panic("popcli");
80105389:	83 ec 0c             	sub    $0xc,%esp
8010538c:	68 b4 8b 10 80       	push   $0x80108bb4
80105391:	e8 d0 b1 ff ff       	call   80100566 <panic>
  if(cpu->ncli == 0 && cpu->intena)
80105396:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010539c:	8b 80 ac 00 00 00    	mov    0xac(%eax),%eax
801053a2:	85 c0                	test   %eax,%eax
801053a4:	75 15                	jne    801053bb <popcli+0x72>
801053a6:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
801053ac:	8b 80 b0 00 00 00    	mov    0xb0(%eax),%eax
801053b2:	85 c0                	test   %eax,%eax
801053b4:	74 05                	je     801053bb <popcli+0x72>
    sti();
801053b6:	e8 a9 fd ff ff       	call   80105164 <sti>
}
801053bb:	90                   	nop
801053bc:	c9                   	leave  
801053bd:	c3                   	ret    

801053be <stosb>:
               "cc");
}

static inline void
stosb(void *addr, int data, int cnt)
{
801053be:	55                   	push   %ebp
801053bf:	89 e5                	mov    %esp,%ebp
801053c1:	57                   	push   %edi
801053c2:	53                   	push   %ebx
  asm volatile("cld; rep stosb" :
801053c3:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053c6:	8b 55 10             	mov    0x10(%ebp),%edx
801053c9:	8b 45 0c             	mov    0xc(%ebp),%eax
801053cc:	89 cb                	mov    %ecx,%ebx
801053ce:	89 df                	mov    %ebx,%edi
801053d0:	89 d1                	mov    %edx,%ecx
801053d2:	fc                   	cld    
801053d3:	f3 aa                	rep stos %al,%es:(%edi)
801053d5:	89 ca                	mov    %ecx,%edx
801053d7:	89 fb                	mov    %edi,%ebx
801053d9:	89 5d 08             	mov    %ebx,0x8(%ebp)
801053dc:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
801053df:	90                   	nop
801053e0:	5b                   	pop    %ebx
801053e1:	5f                   	pop    %edi
801053e2:	5d                   	pop    %ebp
801053e3:	c3                   	ret    

801053e4 <stosl>:

static inline void
stosl(void *addr, int data, int cnt)
{
801053e4:	55                   	push   %ebp
801053e5:	89 e5                	mov    %esp,%ebp
801053e7:	57                   	push   %edi
801053e8:	53                   	push   %ebx
  asm volatile("cld; rep stosl" :
801053e9:	8b 4d 08             	mov    0x8(%ebp),%ecx
801053ec:	8b 55 10             	mov    0x10(%ebp),%edx
801053ef:	8b 45 0c             	mov    0xc(%ebp),%eax
801053f2:	89 cb                	mov    %ecx,%ebx
801053f4:	89 df                	mov    %ebx,%edi
801053f6:	89 d1                	mov    %edx,%ecx
801053f8:	fc                   	cld    
801053f9:	f3 ab                	rep stos %eax,%es:(%edi)
801053fb:	89 ca                	mov    %ecx,%edx
801053fd:	89 fb                	mov    %edi,%ebx
801053ff:	89 5d 08             	mov    %ebx,0x8(%ebp)
80105402:	89 55 10             	mov    %edx,0x10(%ebp)
               "=D" (addr), "=c" (cnt) :
               "0" (addr), "1" (cnt), "a" (data) :
               "memory", "cc");
}
80105405:	90                   	nop
80105406:	5b                   	pop    %ebx
80105407:	5f                   	pop    %edi
80105408:	5d                   	pop    %ebp
80105409:	c3                   	ret    

8010540a <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
8010540a:	55                   	push   %ebp
8010540b:	89 e5                	mov    %esp,%ebp
  if ((int)dst%4 == 0 && n%4 == 0){
8010540d:	8b 45 08             	mov    0x8(%ebp),%eax
80105410:	83 e0 03             	and    $0x3,%eax
80105413:	85 c0                	test   %eax,%eax
80105415:	75 43                	jne    8010545a <memset+0x50>
80105417:	8b 45 10             	mov    0x10(%ebp),%eax
8010541a:	83 e0 03             	and    $0x3,%eax
8010541d:	85 c0                	test   %eax,%eax
8010541f:	75 39                	jne    8010545a <memset+0x50>
    c &= 0xFF;
80105421:	81 65 0c ff 00 00 00 	andl   $0xff,0xc(%ebp)
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80105428:	8b 45 10             	mov    0x10(%ebp),%eax
8010542b:	c1 e8 02             	shr    $0x2,%eax
8010542e:	89 c1                	mov    %eax,%ecx
80105430:	8b 45 0c             	mov    0xc(%ebp),%eax
80105433:	c1 e0 18             	shl    $0x18,%eax
80105436:	89 c2                	mov    %eax,%edx
80105438:	8b 45 0c             	mov    0xc(%ebp),%eax
8010543b:	c1 e0 10             	shl    $0x10,%eax
8010543e:	09 c2                	or     %eax,%edx
80105440:	8b 45 0c             	mov    0xc(%ebp),%eax
80105443:	c1 e0 08             	shl    $0x8,%eax
80105446:	09 d0                	or     %edx,%eax
80105448:	0b 45 0c             	or     0xc(%ebp),%eax
8010544b:	51                   	push   %ecx
8010544c:	50                   	push   %eax
8010544d:	ff 75 08             	pushl  0x8(%ebp)
80105450:	e8 8f ff ff ff       	call   801053e4 <stosl>
80105455:	83 c4 0c             	add    $0xc,%esp
80105458:	eb 12                	jmp    8010546c <memset+0x62>
  } else
    stosb(dst, c, n);
8010545a:	8b 45 10             	mov    0x10(%ebp),%eax
8010545d:	50                   	push   %eax
8010545e:	ff 75 0c             	pushl  0xc(%ebp)
80105461:	ff 75 08             	pushl  0x8(%ebp)
80105464:	e8 55 ff ff ff       	call   801053be <stosb>
80105469:	83 c4 0c             	add    $0xc,%esp
  return dst;
8010546c:	8b 45 08             	mov    0x8(%ebp),%eax
}
8010546f:	c9                   	leave  
80105470:	c3                   	ret    

80105471 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80105471:	55                   	push   %ebp
80105472:	89 e5                	mov    %esp,%ebp
80105474:	83 ec 10             	sub    $0x10,%esp
  const uchar *s1, *s2;
  
  s1 = v1;
80105477:	8b 45 08             	mov    0x8(%ebp),%eax
8010547a:	89 45 fc             	mov    %eax,-0x4(%ebp)
  s2 = v2;
8010547d:	8b 45 0c             	mov    0xc(%ebp),%eax
80105480:	89 45 f8             	mov    %eax,-0x8(%ebp)
  while(n-- > 0){
80105483:	eb 30                	jmp    801054b5 <memcmp+0x44>
    if(*s1 != *s2)
80105485:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105488:	0f b6 10             	movzbl (%eax),%edx
8010548b:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010548e:	0f b6 00             	movzbl (%eax),%eax
80105491:	38 c2                	cmp    %al,%dl
80105493:	74 18                	je     801054ad <memcmp+0x3c>
      return *s1 - *s2;
80105495:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105498:	0f b6 00             	movzbl (%eax),%eax
8010549b:	0f b6 d0             	movzbl %al,%edx
8010549e:	8b 45 f8             	mov    -0x8(%ebp),%eax
801054a1:	0f b6 00             	movzbl (%eax),%eax
801054a4:	0f b6 c0             	movzbl %al,%eax
801054a7:	29 c2                	sub    %eax,%edx
801054a9:	89 d0                	mov    %edx,%eax
801054ab:	eb 1a                	jmp    801054c7 <memcmp+0x56>
    s1++, s2++;
801054ad:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
801054b1:	83 45 f8 01          	addl   $0x1,-0x8(%ebp)
{
  const uchar *s1, *s2;
  
  s1 = v1;
  s2 = v2;
  while(n-- > 0){
801054b5:	8b 45 10             	mov    0x10(%ebp),%eax
801054b8:	8d 50 ff             	lea    -0x1(%eax),%edx
801054bb:	89 55 10             	mov    %edx,0x10(%ebp)
801054be:	85 c0                	test   %eax,%eax
801054c0:	75 c3                	jne    80105485 <memcmp+0x14>
    if(*s1 != *s2)
      return *s1 - *s2;
    s1++, s2++;
  }

  return 0;
801054c2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801054c7:	c9                   	leave  
801054c8:	c3                   	ret    

801054c9 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
801054c9:	55                   	push   %ebp
801054ca:	89 e5                	mov    %esp,%ebp
801054cc:	83 ec 10             	sub    $0x10,%esp
  const char *s;
  char *d;

  s = src;
801054cf:	8b 45 0c             	mov    0xc(%ebp),%eax
801054d2:	89 45 fc             	mov    %eax,-0x4(%ebp)
  d = dst;
801054d5:	8b 45 08             	mov    0x8(%ebp),%eax
801054d8:	89 45 f8             	mov    %eax,-0x8(%ebp)
  if(s < d && s + n > d){
801054db:	8b 45 fc             	mov    -0x4(%ebp),%eax
801054de:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054e1:	73 54                	jae    80105537 <memmove+0x6e>
801054e3:	8b 55 fc             	mov    -0x4(%ebp),%edx
801054e6:	8b 45 10             	mov    0x10(%ebp),%eax
801054e9:	01 d0                	add    %edx,%eax
801054eb:	3b 45 f8             	cmp    -0x8(%ebp),%eax
801054ee:	76 47                	jbe    80105537 <memmove+0x6e>
    s += n;
801054f0:	8b 45 10             	mov    0x10(%ebp),%eax
801054f3:	01 45 fc             	add    %eax,-0x4(%ebp)
    d += n;
801054f6:	8b 45 10             	mov    0x10(%ebp),%eax
801054f9:	01 45 f8             	add    %eax,-0x8(%ebp)
    while(n-- > 0)
801054fc:	eb 13                	jmp    80105511 <memmove+0x48>
      *--d = *--s;
801054fe:	83 6d f8 01          	subl   $0x1,-0x8(%ebp)
80105502:	83 6d fc 01          	subl   $0x1,-0x4(%ebp)
80105506:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105509:	0f b6 10             	movzbl (%eax),%edx
8010550c:	8b 45 f8             	mov    -0x8(%ebp),%eax
8010550f:	88 10                	mov    %dl,(%eax)
  s = src;
  d = dst;
  if(s < d && s + n > d){
    s += n;
    d += n;
    while(n-- > 0)
80105511:	8b 45 10             	mov    0x10(%ebp),%eax
80105514:	8d 50 ff             	lea    -0x1(%eax),%edx
80105517:	89 55 10             	mov    %edx,0x10(%ebp)
8010551a:	85 c0                	test   %eax,%eax
8010551c:	75 e0                	jne    801054fe <memmove+0x35>
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
8010551e:	eb 24                	jmp    80105544 <memmove+0x7b>
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
      *d++ = *s++;
80105520:	8b 45 f8             	mov    -0x8(%ebp),%eax
80105523:	8d 50 01             	lea    0x1(%eax),%edx
80105526:	89 55 f8             	mov    %edx,-0x8(%ebp)
80105529:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010552c:	8d 4a 01             	lea    0x1(%edx),%ecx
8010552f:	89 4d fc             	mov    %ecx,-0x4(%ebp)
80105532:	0f b6 12             	movzbl (%edx),%edx
80105535:	88 10                	mov    %dl,(%eax)
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
80105537:	8b 45 10             	mov    0x10(%ebp),%eax
8010553a:	8d 50 ff             	lea    -0x1(%eax),%edx
8010553d:	89 55 10             	mov    %edx,0x10(%ebp)
80105540:	85 c0                	test   %eax,%eax
80105542:	75 dc                	jne    80105520 <memmove+0x57>
      *d++ = *s++;

  return dst;
80105544:	8b 45 08             	mov    0x8(%ebp),%eax
}
80105547:	c9                   	leave  
80105548:	c3                   	ret    

80105549 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80105549:	55                   	push   %ebp
8010554a:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
8010554c:	ff 75 10             	pushl  0x10(%ebp)
8010554f:	ff 75 0c             	pushl  0xc(%ebp)
80105552:	ff 75 08             	pushl  0x8(%ebp)
80105555:	e8 6f ff ff ff       	call   801054c9 <memmove>
8010555a:	83 c4 0c             	add    $0xc,%esp
}
8010555d:	c9                   	leave  
8010555e:	c3                   	ret    

8010555f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
8010555f:	55                   	push   %ebp
80105560:	89 e5                	mov    %esp,%ebp
  while(n > 0 && *p && *p == *q)
80105562:	eb 0c                	jmp    80105570 <strncmp+0x11>
    n--, p++, q++;
80105564:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105568:	83 45 08 01          	addl   $0x1,0x8(%ebp)
8010556c:	83 45 0c 01          	addl   $0x1,0xc(%ebp)
}

int
strncmp(const char *p, const char *q, uint n)
{
  while(n > 0 && *p && *p == *q)
80105570:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105574:	74 1a                	je     80105590 <strncmp+0x31>
80105576:	8b 45 08             	mov    0x8(%ebp),%eax
80105579:	0f b6 00             	movzbl (%eax),%eax
8010557c:	84 c0                	test   %al,%al
8010557e:	74 10                	je     80105590 <strncmp+0x31>
80105580:	8b 45 08             	mov    0x8(%ebp),%eax
80105583:	0f b6 10             	movzbl (%eax),%edx
80105586:	8b 45 0c             	mov    0xc(%ebp),%eax
80105589:	0f b6 00             	movzbl (%eax),%eax
8010558c:	38 c2                	cmp    %al,%dl
8010558e:	74 d4                	je     80105564 <strncmp+0x5>
    n--, p++, q++;
  if(n == 0)
80105590:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80105594:	75 07                	jne    8010559d <strncmp+0x3e>
    return 0;
80105596:	b8 00 00 00 00       	mov    $0x0,%eax
8010559b:	eb 16                	jmp    801055b3 <strncmp+0x54>
  return (uchar)*p - (uchar)*q;
8010559d:	8b 45 08             	mov    0x8(%ebp),%eax
801055a0:	0f b6 00             	movzbl (%eax),%eax
801055a3:	0f b6 d0             	movzbl %al,%edx
801055a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801055a9:	0f b6 00             	movzbl (%eax),%eax
801055ac:	0f b6 c0             	movzbl %al,%eax
801055af:	29 c2                	sub    %eax,%edx
801055b1:	89 d0                	mov    %edx,%eax
}
801055b3:	5d                   	pop    %ebp
801055b4:	c3                   	ret    

801055b5 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
801055b5:	55                   	push   %ebp
801055b6:	89 e5                	mov    %esp,%ebp
801055b8:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
801055bb:	8b 45 08             	mov    0x8(%ebp),%eax
801055be:	89 45 fc             	mov    %eax,-0x4(%ebp)
  while(n-- > 0 && (*s++ = *t++) != 0)
801055c1:	90                   	nop
801055c2:	8b 45 10             	mov    0x10(%ebp),%eax
801055c5:	8d 50 ff             	lea    -0x1(%eax),%edx
801055c8:	89 55 10             	mov    %edx,0x10(%ebp)
801055cb:	85 c0                	test   %eax,%eax
801055cd:	7e 2c                	jle    801055fb <strncpy+0x46>
801055cf:	8b 45 08             	mov    0x8(%ebp),%eax
801055d2:	8d 50 01             	lea    0x1(%eax),%edx
801055d5:	89 55 08             	mov    %edx,0x8(%ebp)
801055d8:	8b 55 0c             	mov    0xc(%ebp),%edx
801055db:	8d 4a 01             	lea    0x1(%edx),%ecx
801055de:	89 4d 0c             	mov    %ecx,0xc(%ebp)
801055e1:	0f b6 12             	movzbl (%edx),%edx
801055e4:	88 10                	mov    %dl,(%eax)
801055e6:	0f b6 00             	movzbl (%eax),%eax
801055e9:	84 c0                	test   %al,%al
801055eb:	75 d5                	jne    801055c2 <strncpy+0xd>
    ;
  while(n-- > 0)
801055ed:	eb 0c                	jmp    801055fb <strncpy+0x46>
    *s++ = 0;
801055ef:	8b 45 08             	mov    0x8(%ebp),%eax
801055f2:	8d 50 01             	lea    0x1(%eax),%edx
801055f5:	89 55 08             	mov    %edx,0x8(%ebp)
801055f8:	c6 00 00             	movb   $0x0,(%eax)
  char *os;
  
  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    ;
  while(n-- > 0)
801055fb:	8b 45 10             	mov    0x10(%ebp),%eax
801055fe:	8d 50 ff             	lea    -0x1(%eax),%edx
80105601:	89 55 10             	mov    %edx,0x10(%ebp)
80105604:	85 c0                	test   %eax,%eax
80105606:	7f e7                	jg     801055ef <strncpy+0x3a>
    *s++ = 0;
  return os;
80105608:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010560b:	c9                   	leave  
8010560c:	c3                   	ret    

8010560d <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
8010560d:	55                   	push   %ebp
8010560e:	89 e5                	mov    %esp,%ebp
80105610:	83 ec 10             	sub    $0x10,%esp
  char *os;
  
  os = s;
80105613:	8b 45 08             	mov    0x8(%ebp),%eax
80105616:	89 45 fc             	mov    %eax,-0x4(%ebp)
  if(n <= 0)
80105619:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010561d:	7f 05                	jg     80105624 <safestrcpy+0x17>
    return os;
8010561f:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105622:	eb 31                	jmp    80105655 <safestrcpy+0x48>
  while(--n > 0 && (*s++ = *t++) != 0)
80105624:	83 6d 10 01          	subl   $0x1,0x10(%ebp)
80105628:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
8010562c:	7e 1e                	jle    8010564c <safestrcpy+0x3f>
8010562e:	8b 45 08             	mov    0x8(%ebp),%eax
80105631:	8d 50 01             	lea    0x1(%eax),%edx
80105634:	89 55 08             	mov    %edx,0x8(%ebp)
80105637:	8b 55 0c             	mov    0xc(%ebp),%edx
8010563a:	8d 4a 01             	lea    0x1(%edx),%ecx
8010563d:	89 4d 0c             	mov    %ecx,0xc(%ebp)
80105640:	0f b6 12             	movzbl (%edx),%edx
80105643:	88 10                	mov    %dl,(%eax)
80105645:	0f b6 00             	movzbl (%eax),%eax
80105648:	84 c0                	test   %al,%al
8010564a:	75 d8                	jne    80105624 <safestrcpy+0x17>
    ;
  *s = 0;
8010564c:	8b 45 08             	mov    0x8(%ebp),%eax
8010564f:	c6 00 00             	movb   $0x0,(%eax)
  return os;
80105652:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
80105655:	c9                   	leave  
80105656:	c3                   	ret    

80105657 <strlen>:

int
strlen(const char *s)
{
80105657:	55                   	push   %ebp
80105658:	89 e5                	mov    %esp,%ebp
8010565a:	83 ec 10             	sub    $0x10,%esp
  int n;

  for(n = 0; s[n]; n++)
8010565d:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
80105664:	eb 04                	jmp    8010566a <strlen+0x13>
80105666:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010566a:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010566d:	8b 45 08             	mov    0x8(%ebp),%eax
80105670:	01 d0                	add    %edx,%eax
80105672:	0f b6 00             	movzbl (%eax),%eax
80105675:	84 c0                	test   %al,%al
80105677:	75 ed                	jne    80105666 <strlen+0xf>
    ;
  return n;
80105679:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010567c:	c9                   	leave  
8010567d:	c3                   	ret    

8010567e <swtch>:
# Save current register context in old
# and then load register context from new.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010567e:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80105682:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-save registers
  pushl %ebp
80105686:	55                   	push   %ebp
  pushl %ebx
80105687:	53                   	push   %ebx
  pushl %esi
80105688:	56                   	push   %esi
  pushl %edi
80105689:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
8010568a:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010568c:	89 d4                	mov    %edx,%esp

  # Load new callee-save registers
  popl %edi
8010568e:	5f                   	pop    %edi
  popl %esi
8010568f:	5e                   	pop    %esi
  popl %ebx
80105690:	5b                   	pop    %ebx
  popl %ebp
80105691:	5d                   	pop    %ebp
  ret
80105692:	c3                   	ret    

80105693 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80105693:	55                   	push   %ebp
80105694:	89 e5                	mov    %esp,%ebp
  if(addr >= proc->sz || addr+4 > proc->sz)
80105696:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010569c:	8b 00                	mov    (%eax),%eax
8010569e:	3b 45 08             	cmp    0x8(%ebp),%eax
801056a1:	76 12                	jbe    801056b5 <fetchint+0x22>
801056a3:	8b 45 08             	mov    0x8(%ebp),%eax
801056a6:	8d 50 04             	lea    0x4(%eax),%edx
801056a9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056af:	8b 00                	mov    (%eax),%eax
801056b1:	39 c2                	cmp    %eax,%edx
801056b3:	76 07                	jbe    801056bc <fetchint+0x29>
    return -1;
801056b5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056ba:	eb 0f                	jmp    801056cb <fetchint+0x38>
  *ip = *(int*)(addr);
801056bc:	8b 45 08             	mov    0x8(%ebp),%eax
801056bf:	8b 10                	mov    (%eax),%edx
801056c1:	8b 45 0c             	mov    0xc(%ebp),%eax
801056c4:	89 10                	mov    %edx,(%eax)
  return 0;
801056c6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801056cb:	5d                   	pop    %ebp
801056cc:	c3                   	ret    

801056cd <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801056cd:	55                   	push   %ebp
801056ce:	89 e5                	mov    %esp,%ebp
801056d0:	83 ec 10             	sub    $0x10,%esp
  char *s, *ep;

  if(addr >= proc->sz)
801056d3:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056d9:	8b 00                	mov    (%eax),%eax
801056db:	3b 45 08             	cmp    0x8(%ebp),%eax
801056de:	77 07                	ja     801056e7 <fetchstr+0x1a>
    return -1;
801056e0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801056e5:	eb 46                	jmp    8010572d <fetchstr+0x60>
  *pp = (char*)addr;
801056e7:	8b 55 08             	mov    0x8(%ebp),%edx
801056ea:	8b 45 0c             	mov    0xc(%ebp),%eax
801056ed:	89 10                	mov    %edx,(%eax)
  ep = (char*)proc->sz;
801056ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801056f5:	8b 00                	mov    (%eax),%eax
801056f7:	89 45 f8             	mov    %eax,-0x8(%ebp)
  for(s = *pp; s < ep; s++)
801056fa:	8b 45 0c             	mov    0xc(%ebp),%eax
801056fd:	8b 00                	mov    (%eax),%eax
801056ff:	89 45 fc             	mov    %eax,-0x4(%ebp)
80105702:	eb 1c                	jmp    80105720 <fetchstr+0x53>
    if(*s == 0)
80105704:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105707:	0f b6 00             	movzbl (%eax),%eax
8010570a:	84 c0                	test   %al,%al
8010570c:	75 0e                	jne    8010571c <fetchstr+0x4f>
      return s - *pp;
8010570e:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105711:	8b 45 0c             	mov    0xc(%ebp),%eax
80105714:	8b 00                	mov    (%eax),%eax
80105716:	29 c2                	sub    %eax,%edx
80105718:	89 d0                	mov    %edx,%eax
8010571a:	eb 11                	jmp    8010572d <fetchstr+0x60>

  if(addr >= proc->sz)
    return -1;
  *pp = (char*)addr;
  ep = (char*)proc->sz;
  for(s = *pp; s < ep; s++)
8010571c:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
80105720:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105723:	3b 45 f8             	cmp    -0x8(%ebp),%eax
80105726:	72 dc                	jb     80105704 <fetchstr+0x37>
    if(*s == 0)
      return s - *pp;
  return -1;
80105728:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010572d:	c9                   	leave  
8010572e:	c3                   	ret    

8010572f <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010572f:	55                   	push   %ebp
80105730:	89 e5                	mov    %esp,%ebp
  return fetchint(proc->tf->esp + 4 + 4*n, ip);
80105732:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105738:	8b 40 18             	mov    0x18(%eax),%eax
8010573b:	8b 40 44             	mov    0x44(%eax),%eax
8010573e:	8b 55 08             	mov    0x8(%ebp),%edx
80105741:	c1 e2 02             	shl    $0x2,%edx
80105744:	01 d0                	add    %edx,%eax
80105746:	83 c0 04             	add    $0x4,%eax
80105749:	ff 75 0c             	pushl  0xc(%ebp)
8010574c:	50                   	push   %eax
8010574d:	e8 41 ff ff ff       	call   80105693 <fetchint>
80105752:	83 c4 08             	add    $0x8,%esp
}
80105755:	c9                   	leave  
80105756:	c3                   	ret    

80105757 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size n bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80105757:	55                   	push   %ebp
80105758:	89 e5                	mov    %esp,%ebp
8010575a:	83 ec 10             	sub    $0x10,%esp
  int i;
  
  if(argint(n, &i) < 0)
8010575d:	8d 45 fc             	lea    -0x4(%ebp),%eax
80105760:	50                   	push   %eax
80105761:	ff 75 08             	pushl  0x8(%ebp)
80105764:	e8 c6 ff ff ff       	call   8010572f <argint>
80105769:	83 c4 08             	add    $0x8,%esp
8010576c:	85 c0                	test   %eax,%eax
8010576e:	79 07                	jns    80105777 <argptr+0x20>
    return -1;
80105770:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105775:	eb 3b                	jmp    801057b2 <argptr+0x5b>
  if((uint)i >= proc->sz || (uint)i+size > proc->sz)
80105777:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010577d:	8b 00                	mov    (%eax),%eax
8010577f:	8b 55 fc             	mov    -0x4(%ebp),%edx
80105782:	39 d0                	cmp    %edx,%eax
80105784:	76 16                	jbe    8010579c <argptr+0x45>
80105786:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105789:	89 c2                	mov    %eax,%edx
8010578b:	8b 45 10             	mov    0x10(%ebp),%eax
8010578e:	01 c2                	add    %eax,%edx
80105790:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105796:	8b 00                	mov    (%eax),%eax
80105798:	39 c2                	cmp    %eax,%edx
8010579a:	76 07                	jbe    801057a3 <argptr+0x4c>
    return -1;
8010579c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057a1:	eb 0f                	jmp    801057b2 <argptr+0x5b>
  *pp = (char*)i;
801057a3:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057a6:	89 c2                	mov    %eax,%edx
801057a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801057ab:	89 10                	mov    %edx,(%eax)
  return 0;
801057ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801057b2:	c9                   	leave  
801057b3:	c3                   	ret    

801057b4 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801057b4:	55                   	push   %ebp
801057b5:	89 e5                	mov    %esp,%ebp
801057b7:	83 ec 10             	sub    $0x10,%esp
  int addr;
  if(argint(n, &addr) < 0)
801057ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
801057bd:	50                   	push   %eax
801057be:	ff 75 08             	pushl  0x8(%ebp)
801057c1:	e8 69 ff ff ff       	call   8010572f <argint>
801057c6:	83 c4 08             	add    $0x8,%esp
801057c9:	85 c0                	test   %eax,%eax
801057cb:	79 07                	jns    801057d4 <argstr+0x20>
    return -1;
801057cd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801057d2:	eb 0f                	jmp    801057e3 <argstr+0x2f>
  return fetchstr(addr, pp);
801057d4:	8b 45 fc             	mov    -0x4(%ebp),%eax
801057d7:	ff 75 0c             	pushl  0xc(%ebp)
801057da:	50                   	push   %eax
801057db:	e8 ed fe ff ff       	call   801056cd <fetchstr>
801057e0:	83 c4 08             	add    $0x8,%esp
}
801057e3:	c9                   	leave  
801057e4:	c3                   	ret    

801057e5 <syscall>:
[SYS_waitx]   sys_waitx,
};

void
syscall(void)
{
801057e5:	55                   	push   %ebp
801057e6:	89 e5                	mov    %esp,%ebp
801057e8:	53                   	push   %ebx
801057e9:	83 ec 14             	sub    $0x14,%esp
  int num;

  num = proc->tf->eax;
801057ec:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801057f2:	8b 40 18             	mov    0x18(%eax),%eax
801057f5:	8b 40 1c             	mov    0x1c(%eax),%eax
801057f8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801057fb:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801057ff:	7e 30                	jle    80105831 <syscall+0x4c>
80105801:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105804:	83 f8 16             	cmp    $0x16,%eax
80105807:	77 28                	ja     80105831 <syscall+0x4c>
80105809:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010580c:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
80105813:	85 c0                	test   %eax,%eax
80105815:	74 1a                	je     80105831 <syscall+0x4c>
    proc->tf->eax = syscalls[num]();
80105817:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010581d:	8b 58 18             	mov    0x18(%eax),%ebx
80105820:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105823:	8b 04 85 40 b0 10 80 	mov    -0x7fef4fc0(,%eax,4),%eax
8010582a:	ff d0                	call   *%eax
8010582c:	89 43 1c             	mov    %eax,0x1c(%ebx)
8010582f:	eb 34                	jmp    80105865 <syscall+0x80>
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            proc->pid, proc->name, num);
80105831:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105837:	8d 50 6c             	lea    0x6c(%eax),%edx
8010583a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax

  num = proc->tf->eax;
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    proc->tf->eax = syscalls[num]();
  } else {
    cprintf("%d %s: unknown sys call %d\n",
80105840:	8b 40 10             	mov    0x10(%eax),%eax
80105843:	ff 75 f4             	pushl  -0xc(%ebp)
80105846:	52                   	push   %edx
80105847:	50                   	push   %eax
80105848:	68 bb 8b 10 80       	push   $0x80108bbb
8010584d:	e8 74 ab ff ff       	call   801003c6 <cprintf>
80105852:	83 c4 10             	add    $0x10,%esp
            proc->pid, proc->name, num);
    proc->tf->eax = -1;
80105855:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
8010585b:	8b 40 18             	mov    0x18(%eax),%eax
8010585e:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
  }
}
80105865:	90                   	nop
80105866:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105869:	c9                   	leave  
8010586a:	c3                   	ret    

8010586b <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010586b:	55                   	push   %ebp
8010586c:	89 e5                	mov    %esp,%ebp
8010586e:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80105871:	83 ec 08             	sub    $0x8,%esp
80105874:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105877:	50                   	push   %eax
80105878:	ff 75 08             	pushl  0x8(%ebp)
8010587b:	e8 af fe ff ff       	call   8010572f <argint>
80105880:	83 c4 10             	add    $0x10,%esp
80105883:	85 c0                	test   %eax,%eax
80105885:	79 07                	jns    8010588e <argfd+0x23>
    return -1;
80105887:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010588c:	eb 50                	jmp    801058de <argfd+0x73>
  if(fd < 0 || fd >= NOFILE || (f=proc->ofile[fd]) == 0)
8010588e:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105891:	85 c0                	test   %eax,%eax
80105893:	78 21                	js     801058b6 <argfd+0x4b>
80105895:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105898:	83 f8 0f             	cmp    $0xf,%eax
8010589b:	7f 19                	jg     801058b6 <argfd+0x4b>
8010589d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058a3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058a6:	83 c2 08             	add    $0x8,%edx
801058a9:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058ad:	89 45 f4             	mov    %eax,-0xc(%ebp)
801058b0:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801058b4:	75 07                	jne    801058bd <argfd+0x52>
    return -1;
801058b6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801058bb:	eb 21                	jmp    801058de <argfd+0x73>
  if(pfd)
801058bd:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801058c1:	74 08                	je     801058cb <argfd+0x60>
    *pfd = fd;
801058c3:	8b 55 f0             	mov    -0x10(%ebp),%edx
801058c6:	8b 45 0c             	mov    0xc(%ebp),%eax
801058c9:	89 10                	mov    %edx,(%eax)
  if(pf)
801058cb:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
801058cf:	74 08                	je     801058d9 <argfd+0x6e>
    *pf = f;
801058d1:	8b 45 10             	mov    0x10(%ebp),%eax
801058d4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801058d7:	89 10                	mov    %edx,(%eax)
  return 0;
801058d9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801058de:	c9                   	leave  
801058df:	c3                   	ret    

801058e0 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801058e0:	55                   	push   %ebp
801058e1:	89 e5                	mov    %esp,%ebp
801058e3:	83 ec 10             	sub    $0x10,%esp
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
801058e6:	c7 45 fc 00 00 00 00 	movl   $0x0,-0x4(%ebp)
801058ed:	eb 30                	jmp    8010591f <fdalloc+0x3f>
    if(proc->ofile[fd] == 0){
801058ef:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801058f5:	8b 55 fc             	mov    -0x4(%ebp),%edx
801058f8:	83 c2 08             	add    $0x8,%edx
801058fb:	8b 44 90 08          	mov    0x8(%eax,%edx,4),%eax
801058ff:	85 c0                	test   %eax,%eax
80105901:	75 18                	jne    8010591b <fdalloc+0x3b>
      proc->ofile[fd] = f;
80105903:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105909:	8b 55 fc             	mov    -0x4(%ebp),%edx
8010590c:	8d 4a 08             	lea    0x8(%edx),%ecx
8010590f:	8b 55 08             	mov    0x8(%ebp),%edx
80105912:	89 54 88 08          	mov    %edx,0x8(%eax,%ecx,4)
      return fd;
80105916:	8b 45 fc             	mov    -0x4(%ebp),%eax
80105919:	eb 0f                	jmp    8010592a <fdalloc+0x4a>
static int
fdalloc(struct file *f)
{
  int fd;

  for(fd = 0; fd < NOFILE; fd++){
8010591b:	83 45 fc 01          	addl   $0x1,-0x4(%ebp)
8010591f:	83 7d fc 0f          	cmpl   $0xf,-0x4(%ebp)
80105923:	7e ca                	jle    801058ef <fdalloc+0xf>
    if(proc->ofile[fd] == 0){
      proc->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
80105925:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010592a:	c9                   	leave  
8010592b:	c3                   	ret    

8010592c <sys_dup>:

int
sys_dup(void)
{
8010592c:	55                   	push   %ebp
8010592d:	89 e5                	mov    %esp,%ebp
8010592f:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int fd;
  
  if(argfd(0, 0, &f) < 0)
80105932:	83 ec 04             	sub    $0x4,%esp
80105935:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105938:	50                   	push   %eax
80105939:	6a 00                	push   $0x0
8010593b:	6a 00                	push   $0x0
8010593d:	e8 29 ff ff ff       	call   8010586b <argfd>
80105942:	83 c4 10             	add    $0x10,%esp
80105945:	85 c0                	test   %eax,%eax
80105947:	79 07                	jns    80105950 <sys_dup+0x24>
    return -1;
80105949:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010594e:	eb 31                	jmp    80105981 <sys_dup+0x55>
  if((fd=fdalloc(f)) < 0)
80105950:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105953:	83 ec 0c             	sub    $0xc,%esp
80105956:	50                   	push   %eax
80105957:	e8 84 ff ff ff       	call   801058e0 <fdalloc>
8010595c:	83 c4 10             	add    $0x10,%esp
8010595f:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105962:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105966:	79 07                	jns    8010596f <sys_dup+0x43>
    return -1;
80105968:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010596d:	eb 12                	jmp    80105981 <sys_dup+0x55>
  filedup(f);
8010596f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105972:	83 ec 0c             	sub    $0xc,%esp
80105975:	50                   	push   %eax
80105976:	e8 6a b6 ff ff       	call   80100fe5 <filedup>
8010597b:	83 c4 10             	add    $0x10,%esp
  return fd;
8010597e:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
80105981:	c9                   	leave  
80105982:	c3                   	ret    

80105983 <sys_read>:

int
sys_read(void)
{
80105983:	55                   	push   %ebp
80105984:	89 e5                	mov    %esp,%ebp
80105986:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80105989:	83 ec 04             	sub    $0x4,%esp
8010598c:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010598f:	50                   	push   %eax
80105990:	6a 00                	push   $0x0
80105992:	6a 00                	push   $0x0
80105994:	e8 d2 fe ff ff       	call   8010586b <argfd>
80105999:	83 c4 10             	add    $0x10,%esp
8010599c:	85 c0                	test   %eax,%eax
8010599e:	78 2e                	js     801059ce <sys_read+0x4b>
801059a0:	83 ec 08             	sub    $0x8,%esp
801059a3:	8d 45 f0             	lea    -0x10(%ebp),%eax
801059a6:	50                   	push   %eax
801059a7:	6a 02                	push   $0x2
801059a9:	e8 81 fd ff ff       	call   8010572f <argint>
801059ae:	83 c4 10             	add    $0x10,%esp
801059b1:	85 c0                	test   %eax,%eax
801059b3:	78 19                	js     801059ce <sys_read+0x4b>
801059b5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801059b8:	83 ec 04             	sub    $0x4,%esp
801059bb:	50                   	push   %eax
801059bc:	8d 45 ec             	lea    -0x14(%ebp),%eax
801059bf:	50                   	push   %eax
801059c0:	6a 01                	push   $0x1
801059c2:	e8 90 fd ff ff       	call   80105757 <argptr>
801059c7:	83 c4 10             	add    $0x10,%esp
801059ca:	85 c0                	test   %eax,%eax
801059cc:	79 07                	jns    801059d5 <sys_read+0x52>
    return -1;
801059ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801059d3:	eb 17                	jmp    801059ec <sys_read+0x69>
  return fileread(f, p, n);
801059d5:	8b 4d f0             	mov    -0x10(%ebp),%ecx
801059d8:	8b 55 ec             	mov    -0x14(%ebp),%edx
801059db:	8b 45 f4             	mov    -0xc(%ebp),%eax
801059de:	83 ec 04             	sub    $0x4,%esp
801059e1:	51                   	push   %ecx
801059e2:	52                   	push   %edx
801059e3:	50                   	push   %eax
801059e4:	e8 8c b7 ff ff       	call   80101175 <fileread>
801059e9:	83 c4 10             	add    $0x10,%esp
}
801059ec:	c9                   	leave  
801059ed:	c3                   	ret    

801059ee <sys_write>:

int
sys_write(void)
{
801059ee:	55                   	push   %ebp
801059ef:	89 e5                	mov    %esp,%ebp
801059f1:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  int n;
  char *p;

  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801059f4:	83 ec 04             	sub    $0x4,%esp
801059f7:	8d 45 f4             	lea    -0xc(%ebp),%eax
801059fa:	50                   	push   %eax
801059fb:	6a 00                	push   $0x0
801059fd:	6a 00                	push   $0x0
801059ff:	e8 67 fe ff ff       	call   8010586b <argfd>
80105a04:	83 c4 10             	add    $0x10,%esp
80105a07:	85 c0                	test   %eax,%eax
80105a09:	78 2e                	js     80105a39 <sys_write+0x4b>
80105a0b:	83 ec 08             	sub    $0x8,%esp
80105a0e:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a11:	50                   	push   %eax
80105a12:	6a 02                	push   $0x2
80105a14:	e8 16 fd ff ff       	call   8010572f <argint>
80105a19:	83 c4 10             	add    $0x10,%esp
80105a1c:	85 c0                	test   %eax,%eax
80105a1e:	78 19                	js     80105a39 <sys_write+0x4b>
80105a20:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a23:	83 ec 04             	sub    $0x4,%esp
80105a26:	50                   	push   %eax
80105a27:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105a2a:	50                   	push   %eax
80105a2b:	6a 01                	push   $0x1
80105a2d:	e8 25 fd ff ff       	call   80105757 <argptr>
80105a32:	83 c4 10             	add    $0x10,%esp
80105a35:	85 c0                	test   %eax,%eax
80105a37:	79 07                	jns    80105a40 <sys_write+0x52>
    return -1;
80105a39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a3e:	eb 17                	jmp    80105a57 <sys_write+0x69>
  return filewrite(f, p, n);
80105a40:	8b 4d f0             	mov    -0x10(%ebp),%ecx
80105a43:	8b 55 ec             	mov    -0x14(%ebp),%edx
80105a46:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105a49:	83 ec 04             	sub    $0x4,%esp
80105a4c:	51                   	push   %ecx
80105a4d:	52                   	push   %edx
80105a4e:	50                   	push   %eax
80105a4f:	e8 d9 b7 ff ff       	call   8010122d <filewrite>
80105a54:	83 c4 10             	add    $0x10,%esp
}
80105a57:	c9                   	leave  
80105a58:	c3                   	ret    

80105a59 <sys_close>:

int
sys_close(void)
{
80105a59:	55                   	push   %ebp
80105a5a:	89 e5                	mov    %esp,%ebp
80105a5c:	83 ec 18             	sub    $0x18,%esp
  int fd;
  struct file *f;
  
  if(argfd(0, &fd, &f) < 0)
80105a5f:	83 ec 04             	sub    $0x4,%esp
80105a62:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105a65:	50                   	push   %eax
80105a66:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105a69:	50                   	push   %eax
80105a6a:	6a 00                	push   $0x0
80105a6c:	e8 fa fd ff ff       	call   8010586b <argfd>
80105a71:	83 c4 10             	add    $0x10,%esp
80105a74:	85 c0                	test   %eax,%eax
80105a76:	79 07                	jns    80105a7f <sys_close+0x26>
    return -1;
80105a78:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105a7d:	eb 28                	jmp    80105aa7 <sys_close+0x4e>
  proc->ofile[fd] = 0;
80105a7f:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80105a85:	8b 55 f4             	mov    -0xc(%ebp),%edx
80105a88:	83 c2 08             	add    $0x8,%edx
80105a8b:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
80105a92:	00 
  fileclose(f);
80105a93:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105a96:	83 ec 0c             	sub    $0xc,%esp
80105a99:	50                   	push   %eax
80105a9a:	e8 97 b5 ff ff       	call   80101036 <fileclose>
80105a9f:	83 c4 10             	add    $0x10,%esp
  return 0;
80105aa2:	b8 00 00 00 00       	mov    $0x0,%eax
}
80105aa7:	c9                   	leave  
80105aa8:	c3                   	ret    

80105aa9 <sys_fstat>:

int
sys_fstat(void)
{
80105aa9:	55                   	push   %ebp
80105aaa:	89 e5                	mov    %esp,%ebp
80105aac:	83 ec 18             	sub    $0x18,%esp
  struct file *f;
  struct stat *st;
  
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80105aaf:	83 ec 04             	sub    $0x4,%esp
80105ab2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80105ab5:	50                   	push   %eax
80105ab6:	6a 00                	push   $0x0
80105ab8:	6a 00                	push   $0x0
80105aba:	e8 ac fd ff ff       	call   8010586b <argfd>
80105abf:	83 c4 10             	add    $0x10,%esp
80105ac2:	85 c0                	test   %eax,%eax
80105ac4:	78 17                	js     80105add <sys_fstat+0x34>
80105ac6:	83 ec 04             	sub    $0x4,%esp
80105ac9:	6a 14                	push   $0x14
80105acb:	8d 45 f0             	lea    -0x10(%ebp),%eax
80105ace:	50                   	push   %eax
80105acf:	6a 01                	push   $0x1
80105ad1:	e8 81 fc ff ff       	call   80105757 <argptr>
80105ad6:	83 c4 10             	add    $0x10,%esp
80105ad9:	85 c0                	test   %eax,%eax
80105adb:	79 07                	jns    80105ae4 <sys_fstat+0x3b>
    return -1;
80105add:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105ae2:	eb 13                	jmp    80105af7 <sys_fstat+0x4e>
  return filestat(f, st);
80105ae4:	8b 55 f0             	mov    -0x10(%ebp),%edx
80105ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105aea:	83 ec 08             	sub    $0x8,%esp
80105aed:	52                   	push   %edx
80105aee:	50                   	push   %eax
80105aef:	e8 2a b6 ff ff       	call   8010111e <filestat>
80105af4:	83 c4 10             	add    $0x10,%esp
}
80105af7:	c9                   	leave  
80105af8:	c3                   	ret    

80105af9 <sys_link>:

// Create the path new as a link to the same inode as old.
int
sys_link(void)
{
80105af9:	55                   	push   %ebp
80105afa:	89 e5                	mov    %esp,%ebp
80105afc:	83 ec 28             	sub    $0x28,%esp
  char name[DIRSIZ], *new, *old;
  struct inode *dp, *ip;

  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80105aff:	83 ec 08             	sub    $0x8,%esp
80105b02:	8d 45 d8             	lea    -0x28(%ebp),%eax
80105b05:	50                   	push   %eax
80105b06:	6a 00                	push   $0x0
80105b08:	e8 a7 fc ff ff       	call   801057b4 <argstr>
80105b0d:	83 c4 10             	add    $0x10,%esp
80105b10:	85 c0                	test   %eax,%eax
80105b12:	78 15                	js     80105b29 <sys_link+0x30>
80105b14:	83 ec 08             	sub    $0x8,%esp
80105b17:	8d 45 dc             	lea    -0x24(%ebp),%eax
80105b1a:	50                   	push   %eax
80105b1b:	6a 01                	push   $0x1
80105b1d:	e8 92 fc ff ff       	call   801057b4 <argstr>
80105b22:	83 c4 10             	add    $0x10,%esp
80105b25:	85 c0                	test   %eax,%eax
80105b27:	79 0a                	jns    80105b33 <sys_link+0x3a>
    return -1;
80105b29:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b2e:	e9 68 01 00 00       	jmp    80105c9b <sys_link+0x1a2>

  begin_op();
80105b33:	e8 fa d9 ff ff       	call   80103532 <begin_op>
  if((ip = namei(old)) == 0){
80105b38:	8b 45 d8             	mov    -0x28(%ebp),%eax
80105b3b:	83 ec 0c             	sub    $0xc,%esp
80105b3e:	50                   	push   %eax
80105b3f:	e8 c9 c9 ff ff       	call   8010250d <namei>
80105b44:	83 c4 10             	add    $0x10,%esp
80105b47:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105b4a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105b4e:	75 0f                	jne    80105b5f <sys_link+0x66>
    end_op();
80105b50:	e8 69 da ff ff       	call   801035be <end_op>
    return -1;
80105b55:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b5a:	e9 3c 01 00 00       	jmp    80105c9b <sys_link+0x1a2>
  }

  ilock(ip);
80105b5f:	83 ec 0c             	sub    $0xc,%esp
80105b62:	ff 75 f4             	pushl  -0xc(%ebp)
80105b65:	e8 e5 bd ff ff       	call   8010194f <ilock>
80105b6a:	83 c4 10             	add    $0x10,%esp
  if(ip->type == T_DIR){
80105b6d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b70:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105b74:	66 83 f8 01          	cmp    $0x1,%ax
80105b78:	75 1d                	jne    80105b97 <sys_link+0x9e>
    iunlockput(ip);
80105b7a:	83 ec 0c             	sub    $0xc,%esp
80105b7d:	ff 75 f4             	pushl  -0xc(%ebp)
80105b80:	e8 8a c0 ff ff       	call   80101c0f <iunlockput>
80105b85:	83 c4 10             	add    $0x10,%esp
    end_op();
80105b88:	e8 31 da ff ff       	call   801035be <end_op>
    return -1;
80105b8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105b92:	e9 04 01 00 00       	jmp    80105c9b <sys_link+0x1a2>
  }

  ip->nlink++;
80105b97:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105b9a:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105b9e:	83 c0 01             	add    $0x1,%eax
80105ba1:	89 c2                	mov    %eax,%edx
80105ba3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ba6:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105baa:	83 ec 0c             	sub    $0xc,%esp
80105bad:	ff 75 f4             	pushl  -0xc(%ebp)
80105bb0:	e8 c0 bb ff ff       	call   80101775 <iupdate>
80105bb5:	83 c4 10             	add    $0x10,%esp
  iunlock(ip);
80105bb8:	83 ec 0c             	sub    $0xc,%esp
80105bbb:	ff 75 f4             	pushl  -0xc(%ebp)
80105bbe:	e8 ea be ff ff       	call   80101aad <iunlock>
80105bc3:	83 c4 10             	add    $0x10,%esp

  if((dp = nameiparent(new, name)) == 0)
80105bc6:	8b 45 dc             	mov    -0x24(%ebp),%eax
80105bc9:	83 ec 08             	sub    $0x8,%esp
80105bcc:	8d 55 e2             	lea    -0x1e(%ebp),%edx
80105bcf:	52                   	push   %edx
80105bd0:	50                   	push   %eax
80105bd1:	e8 53 c9 ff ff       	call   80102529 <nameiparent>
80105bd6:	83 c4 10             	add    $0x10,%esp
80105bd9:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105bdc:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105be0:	74 71                	je     80105c53 <sys_link+0x15a>
    goto bad;
  ilock(dp);
80105be2:	83 ec 0c             	sub    $0xc,%esp
80105be5:	ff 75 f0             	pushl  -0x10(%ebp)
80105be8:	e8 62 bd ff ff       	call   8010194f <ilock>
80105bed:	83 c4 10             	add    $0x10,%esp
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80105bf0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105bf3:	8b 10                	mov    (%eax),%edx
80105bf5:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105bf8:	8b 00                	mov    (%eax),%eax
80105bfa:	39 c2                	cmp    %eax,%edx
80105bfc:	75 1d                	jne    80105c1b <sys_link+0x122>
80105bfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c01:	8b 40 04             	mov    0x4(%eax),%eax
80105c04:	83 ec 04             	sub    $0x4,%esp
80105c07:	50                   	push   %eax
80105c08:	8d 45 e2             	lea    -0x1e(%ebp),%eax
80105c0b:	50                   	push   %eax
80105c0c:	ff 75 f0             	pushl  -0x10(%ebp)
80105c0f:	e8 5d c6 ff ff       	call   80102271 <dirlink>
80105c14:	83 c4 10             	add    $0x10,%esp
80105c17:	85 c0                	test   %eax,%eax
80105c19:	79 10                	jns    80105c2b <sys_link+0x132>
    iunlockput(dp);
80105c1b:	83 ec 0c             	sub    $0xc,%esp
80105c1e:	ff 75 f0             	pushl  -0x10(%ebp)
80105c21:	e8 e9 bf ff ff       	call   80101c0f <iunlockput>
80105c26:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105c29:	eb 29                	jmp    80105c54 <sys_link+0x15b>
  }
  iunlockput(dp);
80105c2b:	83 ec 0c             	sub    $0xc,%esp
80105c2e:	ff 75 f0             	pushl  -0x10(%ebp)
80105c31:	e8 d9 bf ff ff       	call   80101c0f <iunlockput>
80105c36:	83 c4 10             	add    $0x10,%esp
  iput(ip);
80105c39:	83 ec 0c             	sub    $0xc,%esp
80105c3c:	ff 75 f4             	pushl  -0xc(%ebp)
80105c3f:	e8 db be ff ff       	call   80101b1f <iput>
80105c44:	83 c4 10             	add    $0x10,%esp

  end_op();
80105c47:	e8 72 d9 ff ff       	call   801035be <end_op>

  return 0;
80105c4c:	b8 00 00 00 00       	mov    $0x0,%eax
80105c51:	eb 48                	jmp    80105c9b <sys_link+0x1a2>
  ip->nlink++;
  iupdate(ip);
  iunlock(ip);

  if((dp = nameiparent(new, name)) == 0)
    goto bad;
80105c53:	90                   	nop
  end_op();

  return 0;

bad:
  ilock(ip);
80105c54:	83 ec 0c             	sub    $0xc,%esp
80105c57:	ff 75 f4             	pushl  -0xc(%ebp)
80105c5a:	e8 f0 bc ff ff       	call   8010194f <ilock>
80105c5f:	83 c4 10             	add    $0x10,%esp
  ip->nlink--;
80105c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c65:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105c69:	83 e8 01             	sub    $0x1,%eax
80105c6c:	89 c2                	mov    %eax,%edx
80105c6e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105c71:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105c75:	83 ec 0c             	sub    $0xc,%esp
80105c78:	ff 75 f4             	pushl  -0xc(%ebp)
80105c7b:	e8 f5 ba ff ff       	call   80101775 <iupdate>
80105c80:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105c83:	83 ec 0c             	sub    $0xc,%esp
80105c86:	ff 75 f4             	pushl  -0xc(%ebp)
80105c89:	e8 81 bf ff ff       	call   80101c0f <iunlockput>
80105c8e:	83 c4 10             	add    $0x10,%esp
  end_op();
80105c91:	e8 28 d9 ff ff       	call   801035be <end_op>
  return -1;
80105c96:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105c9b:	c9                   	leave  
80105c9c:	c3                   	ret    

80105c9d <isdirempty>:

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80105c9d:	55                   	push   %ebp
80105c9e:	89 e5                	mov    %esp,%ebp
80105ca0:	83 ec 28             	sub    $0x28,%esp
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ca3:	c7 45 f4 20 00 00 00 	movl   $0x20,-0xc(%ebp)
80105caa:	eb 40                	jmp    80105cec <isdirempty+0x4f>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105cac:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105caf:	6a 10                	push   $0x10
80105cb1:	50                   	push   %eax
80105cb2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80105cb5:	50                   	push   %eax
80105cb6:	ff 75 08             	pushl  0x8(%ebp)
80105cb9:	e8 ff c1 ff ff       	call   80101ebd <readi>
80105cbe:	83 c4 10             	add    $0x10,%esp
80105cc1:	83 f8 10             	cmp    $0x10,%eax
80105cc4:	74 0d                	je     80105cd3 <isdirempty+0x36>
      panic("isdirempty: readi");
80105cc6:	83 ec 0c             	sub    $0xc,%esp
80105cc9:	68 d7 8b 10 80       	push   $0x80108bd7
80105cce:	e8 93 a8 ff ff       	call   80100566 <panic>
    if(de.inum != 0)
80105cd3:	0f b7 45 e4          	movzwl -0x1c(%ebp),%eax
80105cd7:	66 85 c0             	test   %ax,%ax
80105cda:	74 07                	je     80105ce3 <isdirempty+0x46>
      return 0;
80105cdc:	b8 00 00 00 00       	mov    $0x0,%eax
80105ce1:	eb 1b                	jmp    80105cfe <isdirempty+0x61>
isdirempty(struct inode *dp)
{
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80105ce3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105ce6:	83 c0 10             	add    $0x10,%eax
80105ce9:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105cec:	8b 45 08             	mov    0x8(%ebp),%eax
80105cef:	8b 50 18             	mov    0x18(%eax),%edx
80105cf2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105cf5:	39 c2                	cmp    %eax,%edx
80105cf7:	77 b3                	ja     80105cac <isdirempty+0xf>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
      panic("isdirempty: readi");
    if(de.inum != 0)
      return 0;
  }
  return 1;
80105cf9:	b8 01 00 00 00       	mov    $0x1,%eax
}
80105cfe:	c9                   	leave  
80105cff:	c3                   	ret    

80105d00 <sys_unlink>:

//PAGEBREAK!
int
sys_unlink(void)
{
80105d00:	55                   	push   %ebp
80105d01:	89 e5                	mov    %esp,%ebp
80105d03:	83 ec 38             	sub    $0x38,%esp
  struct inode *ip, *dp;
  struct dirent de;
  char name[DIRSIZ], *path;
  uint off;

  if(argstr(0, &path) < 0)
80105d06:	83 ec 08             	sub    $0x8,%esp
80105d09:	8d 45 cc             	lea    -0x34(%ebp),%eax
80105d0c:	50                   	push   %eax
80105d0d:	6a 00                	push   $0x0
80105d0f:	e8 a0 fa ff ff       	call   801057b4 <argstr>
80105d14:	83 c4 10             	add    $0x10,%esp
80105d17:	85 c0                	test   %eax,%eax
80105d19:	79 0a                	jns    80105d25 <sys_unlink+0x25>
    return -1;
80105d1b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d20:	e9 bc 01 00 00       	jmp    80105ee1 <sys_unlink+0x1e1>

  begin_op();
80105d25:	e8 08 d8 ff ff       	call   80103532 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80105d2a:	8b 45 cc             	mov    -0x34(%ebp),%eax
80105d2d:	83 ec 08             	sub    $0x8,%esp
80105d30:	8d 55 d2             	lea    -0x2e(%ebp),%edx
80105d33:	52                   	push   %edx
80105d34:	50                   	push   %eax
80105d35:	e8 ef c7 ff ff       	call   80102529 <nameiparent>
80105d3a:	83 c4 10             	add    $0x10,%esp
80105d3d:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105d40:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105d44:	75 0f                	jne    80105d55 <sys_unlink+0x55>
    end_op();
80105d46:	e8 73 d8 ff ff       	call   801035be <end_op>
    return -1;
80105d4b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105d50:	e9 8c 01 00 00       	jmp    80105ee1 <sys_unlink+0x1e1>
  }

  ilock(dp);
80105d55:	83 ec 0c             	sub    $0xc,%esp
80105d58:	ff 75 f4             	pushl  -0xc(%ebp)
80105d5b:	e8 ef bb ff ff       	call   8010194f <ilock>
80105d60:	83 c4 10             	add    $0x10,%esp

  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80105d63:	83 ec 08             	sub    $0x8,%esp
80105d66:	68 e9 8b 10 80       	push   $0x80108be9
80105d6b:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d6e:	50                   	push   %eax
80105d6f:	e8 28 c4 ff ff       	call   8010219c <namecmp>
80105d74:	83 c4 10             	add    $0x10,%esp
80105d77:	85 c0                	test   %eax,%eax
80105d79:	0f 84 4a 01 00 00    	je     80105ec9 <sys_unlink+0x1c9>
80105d7f:	83 ec 08             	sub    $0x8,%esp
80105d82:	68 eb 8b 10 80       	push   $0x80108beb
80105d87:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105d8a:	50                   	push   %eax
80105d8b:	e8 0c c4 ff ff       	call   8010219c <namecmp>
80105d90:	83 c4 10             	add    $0x10,%esp
80105d93:	85 c0                	test   %eax,%eax
80105d95:	0f 84 2e 01 00 00    	je     80105ec9 <sys_unlink+0x1c9>
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
80105d9b:	83 ec 04             	sub    $0x4,%esp
80105d9e:	8d 45 c8             	lea    -0x38(%ebp),%eax
80105da1:	50                   	push   %eax
80105da2:	8d 45 d2             	lea    -0x2e(%ebp),%eax
80105da5:	50                   	push   %eax
80105da6:	ff 75 f4             	pushl  -0xc(%ebp)
80105da9:	e8 09 c4 ff ff       	call   801021b7 <dirlookup>
80105dae:	83 c4 10             	add    $0x10,%esp
80105db1:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105db4:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105db8:	0f 84 0a 01 00 00    	je     80105ec8 <sys_unlink+0x1c8>
    goto bad;
  ilock(ip);
80105dbe:	83 ec 0c             	sub    $0xc,%esp
80105dc1:	ff 75 f0             	pushl  -0x10(%ebp)
80105dc4:	e8 86 bb ff ff       	call   8010194f <ilock>
80105dc9:	83 c4 10             	add    $0x10,%esp

  if(ip->nlink < 1)
80105dcc:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105dcf:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105dd3:	66 85 c0             	test   %ax,%ax
80105dd6:	7f 0d                	jg     80105de5 <sys_unlink+0xe5>
    panic("unlink: nlink < 1");
80105dd8:	83 ec 0c             	sub    $0xc,%esp
80105ddb:	68 ee 8b 10 80       	push   $0x80108bee
80105de0:	e8 81 a7 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80105de5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105de8:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105dec:	66 83 f8 01          	cmp    $0x1,%ax
80105df0:	75 25                	jne    80105e17 <sys_unlink+0x117>
80105df2:	83 ec 0c             	sub    $0xc,%esp
80105df5:	ff 75 f0             	pushl  -0x10(%ebp)
80105df8:	e8 a0 fe ff ff       	call   80105c9d <isdirempty>
80105dfd:	83 c4 10             	add    $0x10,%esp
80105e00:	85 c0                	test   %eax,%eax
80105e02:	75 13                	jne    80105e17 <sys_unlink+0x117>
    iunlockput(ip);
80105e04:	83 ec 0c             	sub    $0xc,%esp
80105e07:	ff 75 f0             	pushl  -0x10(%ebp)
80105e0a:	e8 00 be ff ff       	call   80101c0f <iunlockput>
80105e0f:	83 c4 10             	add    $0x10,%esp
    goto bad;
80105e12:	e9 b2 00 00 00       	jmp    80105ec9 <sys_unlink+0x1c9>
  }

  memset(&de, 0, sizeof(de));
80105e17:	83 ec 04             	sub    $0x4,%esp
80105e1a:	6a 10                	push   $0x10
80105e1c:	6a 00                	push   $0x0
80105e1e:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e21:	50                   	push   %eax
80105e22:	e8 e3 f5 ff ff       	call   8010540a <memset>
80105e27:	83 c4 10             	add    $0x10,%esp
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80105e2a:	8b 45 c8             	mov    -0x38(%ebp),%eax
80105e2d:	6a 10                	push   $0x10
80105e2f:	50                   	push   %eax
80105e30:	8d 45 e0             	lea    -0x20(%ebp),%eax
80105e33:	50                   	push   %eax
80105e34:	ff 75 f4             	pushl  -0xc(%ebp)
80105e37:	e8 d8 c1 ff ff       	call   80102014 <writei>
80105e3c:	83 c4 10             	add    $0x10,%esp
80105e3f:	83 f8 10             	cmp    $0x10,%eax
80105e42:	74 0d                	je     80105e51 <sys_unlink+0x151>
    panic("unlink: writei");
80105e44:	83 ec 0c             	sub    $0xc,%esp
80105e47:	68 00 8c 10 80       	push   $0x80108c00
80105e4c:	e8 15 a7 ff ff       	call   80100566 <panic>
  if(ip->type == T_DIR){
80105e51:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e54:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105e58:	66 83 f8 01          	cmp    $0x1,%ax
80105e5c:	75 21                	jne    80105e7f <sys_unlink+0x17f>
    dp->nlink--;
80105e5e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e61:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e65:	83 e8 01             	sub    $0x1,%eax
80105e68:	89 c2                	mov    %eax,%edx
80105e6a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105e6d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80105e71:	83 ec 0c             	sub    $0xc,%esp
80105e74:	ff 75 f4             	pushl  -0xc(%ebp)
80105e77:	e8 f9 b8 ff ff       	call   80101775 <iupdate>
80105e7c:	83 c4 10             	add    $0x10,%esp
  }
  iunlockput(dp);
80105e7f:	83 ec 0c             	sub    $0xc,%esp
80105e82:	ff 75 f4             	pushl  -0xc(%ebp)
80105e85:	e8 85 bd ff ff       	call   80101c0f <iunlockput>
80105e8a:	83 c4 10             	add    $0x10,%esp

  ip->nlink--;
80105e8d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e90:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80105e94:	83 e8 01             	sub    $0x1,%eax
80105e97:	89 c2                	mov    %eax,%edx
80105e99:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105e9c:	66 89 50 16          	mov    %dx,0x16(%eax)
  iupdate(ip);
80105ea0:	83 ec 0c             	sub    $0xc,%esp
80105ea3:	ff 75 f0             	pushl  -0x10(%ebp)
80105ea6:	e8 ca b8 ff ff       	call   80101775 <iupdate>
80105eab:	83 c4 10             	add    $0x10,%esp
  iunlockput(ip);
80105eae:	83 ec 0c             	sub    $0xc,%esp
80105eb1:	ff 75 f0             	pushl  -0x10(%ebp)
80105eb4:	e8 56 bd ff ff       	call   80101c0f <iunlockput>
80105eb9:	83 c4 10             	add    $0x10,%esp

  end_op();
80105ebc:	e8 fd d6 ff ff       	call   801035be <end_op>

  return 0;
80105ec1:	b8 00 00 00 00       	mov    $0x0,%eax
80105ec6:	eb 19                	jmp    80105ee1 <sys_unlink+0x1e1>
  // Cannot unlink "." or "..".
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    goto bad;

  if((ip = dirlookup(dp, name, &off)) == 0)
    goto bad;
80105ec8:	90                   	nop
  end_op();

  return 0;

bad:
  iunlockput(dp);
80105ec9:	83 ec 0c             	sub    $0xc,%esp
80105ecc:	ff 75 f4             	pushl  -0xc(%ebp)
80105ecf:	e8 3b bd ff ff       	call   80101c0f <iunlockput>
80105ed4:	83 c4 10             	add    $0x10,%esp
  end_op();
80105ed7:	e8 e2 d6 ff ff       	call   801035be <end_op>
  return -1;
80105edc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80105ee1:	c9                   	leave  
80105ee2:	c3                   	ret    

80105ee3 <create>:

static struct inode*
create(char *path, short type, short major, short minor)
{
80105ee3:	55                   	push   %ebp
80105ee4:	89 e5                	mov    %esp,%ebp
80105ee6:	83 ec 38             	sub    $0x38,%esp
80105ee9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80105eec:	8b 55 10             	mov    0x10(%ebp),%edx
80105eef:	8b 45 14             	mov    0x14(%ebp),%eax
80105ef2:	66 89 4d d4          	mov    %cx,-0x2c(%ebp)
80105ef6:	66 89 55 d0          	mov    %dx,-0x30(%ebp)
80105efa:	66 89 45 cc          	mov    %ax,-0x34(%ebp)
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80105efe:	83 ec 08             	sub    $0x8,%esp
80105f01:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f04:	50                   	push   %eax
80105f05:	ff 75 08             	pushl  0x8(%ebp)
80105f08:	e8 1c c6 ff ff       	call   80102529 <nameiparent>
80105f0d:	83 c4 10             	add    $0x10,%esp
80105f10:	89 45 f4             	mov    %eax,-0xc(%ebp)
80105f13:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80105f17:	75 0a                	jne    80105f23 <create+0x40>
    return 0;
80105f19:	b8 00 00 00 00       	mov    $0x0,%eax
80105f1e:	e9 90 01 00 00       	jmp    801060b3 <create+0x1d0>
  ilock(dp);
80105f23:	83 ec 0c             	sub    $0xc,%esp
80105f26:	ff 75 f4             	pushl  -0xc(%ebp)
80105f29:	e8 21 ba ff ff       	call   8010194f <ilock>
80105f2e:	83 c4 10             	add    $0x10,%esp

  if((ip = dirlookup(dp, name, &off)) != 0){
80105f31:	83 ec 04             	sub    $0x4,%esp
80105f34:	8d 45 ec             	lea    -0x14(%ebp),%eax
80105f37:	50                   	push   %eax
80105f38:	8d 45 de             	lea    -0x22(%ebp),%eax
80105f3b:	50                   	push   %eax
80105f3c:	ff 75 f4             	pushl  -0xc(%ebp)
80105f3f:	e8 73 c2 ff ff       	call   801021b7 <dirlookup>
80105f44:	83 c4 10             	add    $0x10,%esp
80105f47:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105f4a:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105f4e:	74 50                	je     80105fa0 <create+0xbd>
    iunlockput(dp);
80105f50:	83 ec 0c             	sub    $0xc,%esp
80105f53:	ff 75 f4             	pushl  -0xc(%ebp)
80105f56:	e8 b4 bc ff ff       	call   80101c0f <iunlockput>
80105f5b:	83 c4 10             	add    $0x10,%esp
    ilock(ip);
80105f5e:	83 ec 0c             	sub    $0xc,%esp
80105f61:	ff 75 f0             	pushl  -0x10(%ebp)
80105f64:	e8 e6 b9 ff ff       	call   8010194f <ilock>
80105f69:	83 c4 10             	add    $0x10,%esp
    if(type == T_FILE && ip->type == T_FILE)
80105f6c:	66 83 7d d4 02       	cmpw   $0x2,-0x2c(%ebp)
80105f71:	75 15                	jne    80105f88 <create+0xa5>
80105f73:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f76:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80105f7a:	66 83 f8 02          	cmp    $0x2,%ax
80105f7e:	75 08                	jne    80105f88 <create+0xa5>
      return ip;
80105f80:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105f83:	e9 2b 01 00 00       	jmp    801060b3 <create+0x1d0>
    iunlockput(ip);
80105f88:	83 ec 0c             	sub    $0xc,%esp
80105f8b:	ff 75 f0             	pushl  -0x10(%ebp)
80105f8e:	e8 7c bc ff ff       	call   80101c0f <iunlockput>
80105f93:	83 c4 10             	add    $0x10,%esp
    return 0;
80105f96:	b8 00 00 00 00       	mov    $0x0,%eax
80105f9b:	e9 13 01 00 00       	jmp    801060b3 <create+0x1d0>
  }

  if((ip = ialloc(dp->dev, type)) == 0)
80105fa0:	0f bf 55 d4          	movswl -0x2c(%ebp),%edx
80105fa4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80105fa7:	8b 00                	mov    (%eax),%eax
80105fa9:	83 ec 08             	sub    $0x8,%esp
80105fac:	52                   	push   %edx
80105fad:	50                   	push   %eax
80105fae:	e8 eb b6 ff ff       	call   8010169e <ialloc>
80105fb3:	83 c4 10             	add    $0x10,%esp
80105fb6:	89 45 f0             	mov    %eax,-0x10(%ebp)
80105fb9:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80105fbd:	75 0d                	jne    80105fcc <create+0xe9>
    panic("create: ialloc");
80105fbf:	83 ec 0c             	sub    $0xc,%esp
80105fc2:	68 0f 8c 10 80       	push   $0x80108c0f
80105fc7:	e8 9a a5 ff ff       	call   80100566 <panic>

  ilock(ip);
80105fcc:	83 ec 0c             	sub    $0xc,%esp
80105fcf:	ff 75 f0             	pushl  -0x10(%ebp)
80105fd2:	e8 78 b9 ff ff       	call   8010194f <ilock>
80105fd7:	83 c4 10             	add    $0x10,%esp
  ip->major = major;
80105fda:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fdd:	0f b7 55 d0          	movzwl -0x30(%ebp),%edx
80105fe1:	66 89 50 12          	mov    %dx,0x12(%eax)
  ip->minor = minor;
80105fe5:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105fe8:	0f b7 55 cc          	movzwl -0x34(%ebp),%edx
80105fec:	66 89 50 14          	mov    %dx,0x14(%eax)
  ip->nlink = 1;
80105ff0:	8b 45 f0             	mov    -0x10(%ebp),%eax
80105ff3:	66 c7 40 16 01 00    	movw   $0x1,0x16(%eax)
  iupdate(ip);
80105ff9:	83 ec 0c             	sub    $0xc,%esp
80105ffc:	ff 75 f0             	pushl  -0x10(%ebp)
80105fff:	e8 71 b7 ff ff       	call   80101775 <iupdate>
80106004:	83 c4 10             	add    $0x10,%esp

  if(type == T_DIR){  // Create . and .. entries.
80106007:	66 83 7d d4 01       	cmpw   $0x1,-0x2c(%ebp)
8010600c:	75 6a                	jne    80106078 <create+0x195>
    dp->nlink++;  // for ".."
8010600e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106011:	0f b7 40 16          	movzwl 0x16(%eax),%eax
80106015:	83 c0 01             	add    $0x1,%eax
80106018:	89 c2                	mov    %eax,%edx
8010601a:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010601d:	66 89 50 16          	mov    %dx,0x16(%eax)
    iupdate(dp);
80106021:	83 ec 0c             	sub    $0xc,%esp
80106024:	ff 75 f4             	pushl  -0xc(%ebp)
80106027:	e8 49 b7 ff ff       	call   80101775 <iupdate>
8010602c:	83 c4 10             	add    $0x10,%esp
    // No ip->nlink++ for ".": avoid cyclic ref count.
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010602f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106032:	8b 40 04             	mov    0x4(%eax),%eax
80106035:	83 ec 04             	sub    $0x4,%esp
80106038:	50                   	push   %eax
80106039:	68 e9 8b 10 80       	push   $0x80108be9
8010603e:	ff 75 f0             	pushl  -0x10(%ebp)
80106041:	e8 2b c2 ff ff       	call   80102271 <dirlink>
80106046:	83 c4 10             	add    $0x10,%esp
80106049:	85 c0                	test   %eax,%eax
8010604b:	78 1e                	js     8010606b <create+0x188>
8010604d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106050:	8b 40 04             	mov    0x4(%eax),%eax
80106053:	83 ec 04             	sub    $0x4,%esp
80106056:	50                   	push   %eax
80106057:	68 eb 8b 10 80       	push   $0x80108beb
8010605c:	ff 75 f0             	pushl  -0x10(%ebp)
8010605f:	e8 0d c2 ff ff       	call   80102271 <dirlink>
80106064:	83 c4 10             	add    $0x10,%esp
80106067:	85 c0                	test   %eax,%eax
80106069:	79 0d                	jns    80106078 <create+0x195>
      panic("create dots");
8010606b:	83 ec 0c             	sub    $0xc,%esp
8010606e:	68 1e 8c 10 80       	push   $0x80108c1e
80106073:	e8 ee a4 ff ff       	call   80100566 <panic>
  }

  if(dirlink(dp, name, ip->inum) < 0)
80106078:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010607b:	8b 40 04             	mov    0x4(%eax),%eax
8010607e:	83 ec 04             	sub    $0x4,%esp
80106081:	50                   	push   %eax
80106082:	8d 45 de             	lea    -0x22(%ebp),%eax
80106085:	50                   	push   %eax
80106086:	ff 75 f4             	pushl  -0xc(%ebp)
80106089:	e8 e3 c1 ff ff       	call   80102271 <dirlink>
8010608e:	83 c4 10             	add    $0x10,%esp
80106091:	85 c0                	test   %eax,%eax
80106093:	79 0d                	jns    801060a2 <create+0x1bf>
    panic("create: dirlink");
80106095:	83 ec 0c             	sub    $0xc,%esp
80106098:	68 2a 8c 10 80       	push   $0x80108c2a
8010609d:	e8 c4 a4 ff ff       	call   80100566 <panic>

  iunlockput(dp);
801060a2:	83 ec 0c             	sub    $0xc,%esp
801060a5:	ff 75 f4             	pushl  -0xc(%ebp)
801060a8:	e8 62 bb ff ff       	call   80101c0f <iunlockput>
801060ad:	83 c4 10             	add    $0x10,%esp

  return ip;
801060b0:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
801060b3:	c9                   	leave  
801060b4:	c3                   	ret    

801060b5 <sys_open>:

int
sys_open(void)
{
801060b5:	55                   	push   %ebp
801060b6:	89 e5                	mov    %esp,%ebp
801060b8:	83 ec 28             	sub    $0x28,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801060bb:	83 ec 08             	sub    $0x8,%esp
801060be:	8d 45 e8             	lea    -0x18(%ebp),%eax
801060c1:	50                   	push   %eax
801060c2:	6a 00                	push   $0x0
801060c4:	e8 eb f6 ff ff       	call   801057b4 <argstr>
801060c9:	83 c4 10             	add    $0x10,%esp
801060cc:	85 c0                	test   %eax,%eax
801060ce:	78 15                	js     801060e5 <sys_open+0x30>
801060d0:	83 ec 08             	sub    $0x8,%esp
801060d3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801060d6:	50                   	push   %eax
801060d7:	6a 01                	push   $0x1
801060d9:	e8 51 f6 ff ff       	call   8010572f <argint>
801060de:	83 c4 10             	add    $0x10,%esp
801060e1:	85 c0                	test   %eax,%eax
801060e3:	79 0a                	jns    801060ef <sys_open+0x3a>
    return -1;
801060e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060ea:	e9 61 01 00 00       	jmp    80106250 <sys_open+0x19b>

  begin_op();
801060ef:	e8 3e d4 ff ff       	call   80103532 <begin_op>

  if(omode & O_CREATE){
801060f4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801060f7:	25 00 02 00 00       	and    $0x200,%eax
801060fc:	85 c0                	test   %eax,%eax
801060fe:	74 2a                	je     8010612a <sys_open+0x75>
    ip = create(path, T_FILE, 0, 0);
80106100:	8b 45 e8             	mov    -0x18(%ebp),%eax
80106103:	6a 00                	push   $0x0
80106105:	6a 00                	push   $0x0
80106107:	6a 02                	push   $0x2
80106109:	50                   	push   %eax
8010610a:	e8 d4 fd ff ff       	call   80105ee3 <create>
8010610f:	83 c4 10             	add    $0x10,%esp
80106112:	89 45 f4             	mov    %eax,-0xc(%ebp)
    if(ip == 0){
80106115:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106119:	75 75                	jne    80106190 <sys_open+0xdb>
      end_op();
8010611b:	e8 9e d4 ff ff       	call   801035be <end_op>
      return -1;
80106120:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106125:	e9 26 01 00 00       	jmp    80106250 <sys_open+0x19b>
    }
  } else {
    if((ip = namei(path)) == 0){
8010612a:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010612d:	83 ec 0c             	sub    $0xc,%esp
80106130:	50                   	push   %eax
80106131:	e8 d7 c3 ff ff       	call   8010250d <namei>
80106136:	83 c4 10             	add    $0x10,%esp
80106139:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010613c:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106140:	75 0f                	jne    80106151 <sys_open+0x9c>
      end_op();
80106142:	e8 77 d4 ff ff       	call   801035be <end_op>
      return -1;
80106147:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010614c:	e9 ff 00 00 00       	jmp    80106250 <sys_open+0x19b>
    }
    ilock(ip);
80106151:	83 ec 0c             	sub    $0xc,%esp
80106154:	ff 75 f4             	pushl  -0xc(%ebp)
80106157:	e8 f3 b7 ff ff       	call   8010194f <ilock>
8010615c:	83 c4 10             	add    $0x10,%esp
    if(ip->type == T_DIR && omode != O_RDONLY){
8010615f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106162:	0f b7 40 10          	movzwl 0x10(%eax),%eax
80106166:	66 83 f8 01          	cmp    $0x1,%ax
8010616a:	75 24                	jne    80106190 <sys_open+0xdb>
8010616c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010616f:	85 c0                	test   %eax,%eax
80106171:	74 1d                	je     80106190 <sys_open+0xdb>
      iunlockput(ip);
80106173:	83 ec 0c             	sub    $0xc,%esp
80106176:	ff 75 f4             	pushl  -0xc(%ebp)
80106179:	e8 91 ba ff ff       	call   80101c0f <iunlockput>
8010617e:	83 c4 10             	add    $0x10,%esp
      end_op();
80106181:	e8 38 d4 ff ff       	call   801035be <end_op>
      return -1;
80106186:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010618b:	e9 c0 00 00 00       	jmp    80106250 <sys_open+0x19b>
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80106190:	e8 e3 ad ff ff       	call   80100f78 <filealloc>
80106195:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106198:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010619c:	74 17                	je     801061b5 <sys_open+0x100>
8010619e:	83 ec 0c             	sub    $0xc,%esp
801061a1:	ff 75 f0             	pushl  -0x10(%ebp)
801061a4:	e8 37 f7 ff ff       	call   801058e0 <fdalloc>
801061a9:	83 c4 10             	add    $0x10,%esp
801061ac:	89 45 ec             	mov    %eax,-0x14(%ebp)
801061af:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801061b3:	79 2e                	jns    801061e3 <sys_open+0x12e>
    if(f)
801061b5:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
801061b9:	74 0e                	je     801061c9 <sys_open+0x114>
      fileclose(f);
801061bb:	83 ec 0c             	sub    $0xc,%esp
801061be:	ff 75 f0             	pushl  -0x10(%ebp)
801061c1:	e8 70 ae ff ff       	call   80101036 <fileclose>
801061c6:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801061c9:	83 ec 0c             	sub    $0xc,%esp
801061cc:	ff 75 f4             	pushl  -0xc(%ebp)
801061cf:	e8 3b ba ff ff       	call   80101c0f <iunlockput>
801061d4:	83 c4 10             	add    $0x10,%esp
    end_op();
801061d7:	e8 e2 d3 ff ff       	call   801035be <end_op>
    return -1;
801061dc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061e1:	eb 6d                	jmp    80106250 <sys_open+0x19b>
  }
  iunlock(ip);
801061e3:	83 ec 0c             	sub    $0xc,%esp
801061e6:	ff 75 f4             	pushl  -0xc(%ebp)
801061e9:	e8 bf b8 ff ff       	call   80101aad <iunlock>
801061ee:	83 c4 10             	add    $0x10,%esp
  end_op();
801061f1:	e8 c8 d3 ff ff       	call   801035be <end_op>

  f->type = FD_INODE;
801061f6:	8b 45 f0             	mov    -0x10(%ebp),%eax
801061f9:	c7 00 02 00 00 00    	movl   $0x2,(%eax)
  f->ip = ip;
801061ff:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106202:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106205:	89 50 10             	mov    %edx,0x10(%eax)
  f->off = 0;
80106208:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010620b:	c7 40 14 00 00 00 00 	movl   $0x0,0x14(%eax)
  f->readable = !(omode & O_WRONLY);
80106212:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106215:	83 e0 01             	and    $0x1,%eax
80106218:	85 c0                	test   %eax,%eax
8010621a:	0f 94 c0             	sete   %al
8010621d:	89 c2                	mov    %eax,%edx
8010621f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106222:	88 50 08             	mov    %dl,0x8(%eax)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80106225:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106228:	83 e0 01             	and    $0x1,%eax
8010622b:	85 c0                	test   %eax,%eax
8010622d:	75 0a                	jne    80106239 <sys_open+0x184>
8010622f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106232:	83 e0 02             	and    $0x2,%eax
80106235:	85 c0                	test   %eax,%eax
80106237:	74 07                	je     80106240 <sys_open+0x18b>
80106239:	b8 01 00 00 00       	mov    $0x1,%eax
8010623e:	eb 05                	jmp    80106245 <sys_open+0x190>
80106240:	b8 00 00 00 00       	mov    $0x0,%eax
80106245:	89 c2                	mov    %eax,%edx
80106247:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010624a:	88 50 09             	mov    %dl,0x9(%eax)
  return fd;
8010624d:	8b 45 ec             	mov    -0x14(%ebp),%eax
}
80106250:	c9                   	leave  
80106251:	c3                   	ret    

80106252 <sys_mkdir>:

int
sys_mkdir(void)
{
80106252:	55                   	push   %ebp
80106253:	89 e5                	mov    %esp,%ebp
80106255:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106258:	e8 d5 d2 ff ff       	call   80103532 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010625d:	83 ec 08             	sub    $0x8,%esp
80106260:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106263:	50                   	push   %eax
80106264:	6a 00                	push   $0x0
80106266:	e8 49 f5 ff ff       	call   801057b4 <argstr>
8010626b:	83 c4 10             	add    $0x10,%esp
8010626e:	85 c0                	test   %eax,%eax
80106270:	78 1b                	js     8010628d <sys_mkdir+0x3b>
80106272:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106275:	6a 00                	push   $0x0
80106277:	6a 00                	push   $0x0
80106279:	6a 01                	push   $0x1
8010627b:	50                   	push   %eax
8010627c:	e8 62 fc ff ff       	call   80105ee3 <create>
80106281:	83 c4 10             	add    $0x10,%esp
80106284:	89 45 f4             	mov    %eax,-0xc(%ebp)
80106287:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010628b:	75 0c                	jne    80106299 <sys_mkdir+0x47>
    end_op();
8010628d:	e8 2c d3 ff ff       	call   801035be <end_op>
    return -1;
80106292:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106297:	eb 18                	jmp    801062b1 <sys_mkdir+0x5f>
  }
  iunlockput(ip);
80106299:	83 ec 0c             	sub    $0xc,%esp
8010629c:	ff 75 f4             	pushl  -0xc(%ebp)
8010629f:	e8 6b b9 ff ff       	call   80101c0f <iunlockput>
801062a4:	83 c4 10             	add    $0x10,%esp
  end_op();
801062a7:	e8 12 d3 ff ff       	call   801035be <end_op>
  return 0;
801062ac:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062b1:	c9                   	leave  
801062b2:	c3                   	ret    

801062b3 <sys_mknod>:

int
sys_mknod(void)
{
801062b3:	55                   	push   %ebp
801062b4:	89 e5                	mov    %esp,%ebp
801062b6:	83 ec 28             	sub    $0x28,%esp
  struct inode *ip;
  char *path;
  int len;
  int major, minor;
  
  begin_op();
801062b9:	e8 74 d2 ff ff       	call   80103532 <begin_op>
  if((len=argstr(0, &path)) < 0 ||
801062be:	83 ec 08             	sub    $0x8,%esp
801062c1:	8d 45 ec             	lea    -0x14(%ebp),%eax
801062c4:	50                   	push   %eax
801062c5:	6a 00                	push   $0x0
801062c7:	e8 e8 f4 ff ff       	call   801057b4 <argstr>
801062cc:	83 c4 10             	add    $0x10,%esp
801062cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
801062d2:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
801062d6:	78 4f                	js     80106327 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
801062d8:	83 ec 08             	sub    $0x8,%esp
801062db:	8d 45 e8             	lea    -0x18(%ebp),%eax
801062de:	50                   	push   %eax
801062df:	6a 01                	push   $0x1
801062e1:	e8 49 f4 ff ff       	call   8010572f <argint>
801062e6:	83 c4 10             	add    $0x10,%esp
  char *path;
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
801062e9:	85 c0                	test   %eax,%eax
801062eb:	78 3a                	js     80106327 <sys_mknod+0x74>
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
801062ed:	83 ec 08             	sub    $0x8,%esp
801062f0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801062f3:	50                   	push   %eax
801062f4:	6a 02                	push   $0x2
801062f6:	e8 34 f4 ff ff       	call   8010572f <argint>
801062fb:	83 c4 10             	add    $0x10,%esp
  int len;
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
801062fe:	85 c0                	test   %eax,%eax
80106300:	78 25                	js     80106327 <sys_mknod+0x74>
     argint(2, &minor) < 0 ||
     (ip = create(path, T_DEV, major, minor)) == 0){
80106302:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106305:	0f bf c8             	movswl %ax,%ecx
80106308:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010630b:	0f bf d0             	movswl %ax,%edx
8010630e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  int major, minor;
  
  begin_op();
  if((len=argstr(0, &path)) < 0 ||
     argint(1, &major) < 0 ||
     argint(2, &minor) < 0 ||
80106311:	51                   	push   %ecx
80106312:	52                   	push   %edx
80106313:	6a 03                	push   $0x3
80106315:	50                   	push   %eax
80106316:	e8 c8 fb ff ff       	call   80105ee3 <create>
8010631b:	83 c4 10             	add    $0x10,%esp
8010631e:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106321:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106325:	75 0c                	jne    80106333 <sys_mknod+0x80>
     (ip = create(path, T_DEV, major, minor)) == 0){
    end_op();
80106327:	e8 92 d2 ff ff       	call   801035be <end_op>
    return -1;
8010632c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106331:	eb 18                	jmp    8010634b <sys_mknod+0x98>
  }
  iunlockput(ip);
80106333:	83 ec 0c             	sub    $0xc,%esp
80106336:	ff 75 f0             	pushl  -0x10(%ebp)
80106339:	e8 d1 b8 ff ff       	call   80101c0f <iunlockput>
8010633e:	83 c4 10             	add    $0x10,%esp
  end_op();
80106341:	e8 78 d2 ff ff       	call   801035be <end_op>
  return 0;
80106346:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010634b:	c9                   	leave  
8010634c:	c3                   	ret    

8010634d <sys_chdir>:

int
sys_chdir(void)
{
8010634d:	55                   	push   %ebp
8010634e:	89 e5                	mov    %esp,%ebp
80106350:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80106353:	e8 da d1 ff ff       	call   80103532 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80106358:	83 ec 08             	sub    $0x8,%esp
8010635b:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010635e:	50                   	push   %eax
8010635f:	6a 00                	push   $0x0
80106361:	e8 4e f4 ff ff       	call   801057b4 <argstr>
80106366:	83 c4 10             	add    $0x10,%esp
80106369:	85 c0                	test   %eax,%eax
8010636b:	78 18                	js     80106385 <sys_chdir+0x38>
8010636d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80106370:	83 ec 0c             	sub    $0xc,%esp
80106373:	50                   	push   %eax
80106374:	e8 94 c1 ff ff       	call   8010250d <namei>
80106379:	83 c4 10             	add    $0x10,%esp
8010637c:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010637f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80106383:	75 0c                	jne    80106391 <sys_chdir+0x44>
    end_op();
80106385:	e8 34 d2 ff ff       	call   801035be <end_op>
    return -1;
8010638a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010638f:	eb 6e                	jmp    801063ff <sys_chdir+0xb2>
  }
  ilock(ip);
80106391:	83 ec 0c             	sub    $0xc,%esp
80106394:	ff 75 f4             	pushl  -0xc(%ebp)
80106397:	e8 b3 b5 ff ff       	call   8010194f <ilock>
8010639c:	83 c4 10             	add    $0x10,%esp
  if(ip->type != T_DIR){
8010639f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801063a2:	0f b7 40 10          	movzwl 0x10(%eax),%eax
801063a6:	66 83 f8 01          	cmp    $0x1,%ax
801063aa:	74 1a                	je     801063c6 <sys_chdir+0x79>
    iunlockput(ip);
801063ac:	83 ec 0c             	sub    $0xc,%esp
801063af:	ff 75 f4             	pushl  -0xc(%ebp)
801063b2:	e8 58 b8 ff ff       	call   80101c0f <iunlockput>
801063b7:	83 c4 10             	add    $0x10,%esp
    end_op();
801063ba:	e8 ff d1 ff ff       	call   801035be <end_op>
    return -1;
801063bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801063c4:	eb 39                	jmp    801063ff <sys_chdir+0xb2>
  }
  iunlock(ip);
801063c6:	83 ec 0c             	sub    $0xc,%esp
801063c9:	ff 75 f4             	pushl  -0xc(%ebp)
801063cc:	e8 dc b6 ff ff       	call   80101aad <iunlock>
801063d1:	83 c4 10             	add    $0x10,%esp
  iput(proc->cwd);
801063d4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063da:	8b 40 68             	mov    0x68(%eax),%eax
801063dd:	83 ec 0c             	sub    $0xc,%esp
801063e0:	50                   	push   %eax
801063e1:	e8 39 b7 ff ff       	call   80101b1f <iput>
801063e6:	83 c4 10             	add    $0x10,%esp
  end_op();
801063e9:	e8 d0 d1 ff ff       	call   801035be <end_op>
  proc->cwd = ip;
801063ee:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801063f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801063f7:	89 50 68             	mov    %edx,0x68(%eax)
  return 0;
801063fa:	b8 00 00 00 00       	mov    $0x0,%eax
}
801063ff:	c9                   	leave  
80106400:	c3                   	ret    

80106401 <sys_exec>:

int
sys_exec(void)
{
80106401:	55                   	push   %ebp
80106402:	89 e5                	mov    %esp,%ebp
80106404:	81 ec 98 00 00 00    	sub    $0x98,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
8010640a:	83 ec 08             	sub    $0x8,%esp
8010640d:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106410:	50                   	push   %eax
80106411:	6a 00                	push   $0x0
80106413:	e8 9c f3 ff ff       	call   801057b4 <argstr>
80106418:	83 c4 10             	add    $0x10,%esp
8010641b:	85 c0                	test   %eax,%eax
8010641d:	78 18                	js     80106437 <sys_exec+0x36>
8010641f:	83 ec 08             	sub    $0x8,%esp
80106422:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80106428:	50                   	push   %eax
80106429:	6a 01                	push   $0x1
8010642b:	e8 ff f2 ff ff       	call   8010572f <argint>
80106430:	83 c4 10             	add    $0x10,%esp
80106433:	85 c0                	test   %eax,%eax
80106435:	79 0a                	jns    80106441 <sys_exec+0x40>
    return -1;
80106437:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010643c:	e9 c6 00 00 00       	jmp    80106507 <sys_exec+0x106>
  }
  memset(argv, 0, sizeof(argv));
80106441:	83 ec 04             	sub    $0x4,%esp
80106444:	68 80 00 00 00       	push   $0x80
80106449:	6a 00                	push   $0x0
8010644b:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80106451:	50                   	push   %eax
80106452:	e8 b3 ef ff ff       	call   8010540a <memset>
80106457:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
8010645a:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
    if(i >= NELEM(argv))
80106461:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106464:	83 f8 1f             	cmp    $0x1f,%eax
80106467:	76 0a                	jbe    80106473 <sys_exec+0x72>
      return -1;
80106469:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010646e:	e9 94 00 00 00       	jmp    80106507 <sys_exec+0x106>
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80106473:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106476:	c1 e0 02             	shl    $0x2,%eax
80106479:	89 c2                	mov    %eax,%edx
8010647b:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80106481:	01 c2                	add    %eax,%edx
80106483:	83 ec 08             	sub    $0x8,%esp
80106486:	8d 85 68 ff ff ff    	lea    -0x98(%ebp),%eax
8010648c:	50                   	push   %eax
8010648d:	52                   	push   %edx
8010648e:	e8 00 f2 ff ff       	call   80105693 <fetchint>
80106493:	83 c4 10             	add    $0x10,%esp
80106496:	85 c0                	test   %eax,%eax
80106498:	79 07                	jns    801064a1 <sys_exec+0xa0>
      return -1;
8010649a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010649f:	eb 66                	jmp    80106507 <sys_exec+0x106>
    if(uarg == 0){
801064a1:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064a7:	85 c0                	test   %eax,%eax
801064a9:	75 27                	jne    801064d2 <sys_exec+0xd1>
      argv[i] = 0;
801064ab:	8b 45 f4             	mov    -0xc(%ebp),%eax
801064ae:	c7 84 85 70 ff ff ff 	movl   $0x0,-0x90(%ebp,%eax,4)
801064b5:	00 00 00 00 
      break;
801064b9:	90                   	nop
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
  return exec(path, argv);
801064ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
801064bd:	83 ec 08             	sub    $0x8,%esp
801064c0:	8d 95 70 ff ff ff    	lea    -0x90(%ebp),%edx
801064c6:	52                   	push   %edx
801064c7:	50                   	push   %eax
801064c8:	e8 89 a6 ff ff       	call   80100b56 <exec>
801064cd:	83 c4 10             	add    $0x10,%esp
801064d0:	eb 35                	jmp    80106507 <sys_exec+0x106>
      return -1;
    if(uarg == 0){
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
801064d2:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
801064d8:	8b 55 f4             	mov    -0xc(%ebp),%edx
801064db:	c1 e2 02             	shl    $0x2,%edx
801064de:	01 c2                	add    %eax,%edx
801064e0:	8b 85 68 ff ff ff    	mov    -0x98(%ebp),%eax
801064e6:	83 ec 08             	sub    $0x8,%esp
801064e9:	52                   	push   %edx
801064ea:	50                   	push   %eax
801064eb:	e8 dd f1 ff ff       	call   801056cd <fetchstr>
801064f0:	83 c4 10             	add    $0x10,%esp
801064f3:	85 c0                	test   %eax,%eax
801064f5:	79 07                	jns    801064fe <sys_exec+0xfd>
      return -1;
801064f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064fc:	eb 09                	jmp    80106507 <sys_exec+0x106>

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
    return -1;
  }
  memset(argv, 0, sizeof(argv));
  for(i=0;; i++){
801064fe:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
      return -1;
  }
80106502:	e9 5a ff ff ff       	jmp    80106461 <sys_exec+0x60>
  return exec(path, argv);
}
80106507:	c9                   	leave  
80106508:	c3                   	ret    

80106509 <sys_pipe>:

int
sys_pipe(void)
{
80106509:	55                   	push   %ebp
8010650a:	89 e5                	mov    %esp,%ebp
8010650c:	83 ec 28             	sub    $0x28,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
8010650f:	83 ec 04             	sub    $0x4,%esp
80106512:	6a 08                	push   $0x8
80106514:	8d 45 ec             	lea    -0x14(%ebp),%eax
80106517:	50                   	push   %eax
80106518:	6a 00                	push   $0x0
8010651a:	e8 38 f2 ff ff       	call   80105757 <argptr>
8010651f:	83 c4 10             	add    $0x10,%esp
80106522:	85 c0                	test   %eax,%eax
80106524:	79 0a                	jns    80106530 <sys_pipe+0x27>
    return -1;
80106526:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010652b:	e9 af 00 00 00       	jmp    801065df <sys_pipe+0xd6>
  if(pipealloc(&rf, &wf) < 0)
80106530:	83 ec 08             	sub    $0x8,%esp
80106533:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80106536:	50                   	push   %eax
80106537:	8d 45 e8             	lea    -0x18(%ebp),%eax
8010653a:	50                   	push   %eax
8010653b:	e8 e6 da ff ff       	call   80104026 <pipealloc>
80106540:	83 c4 10             	add    $0x10,%esp
80106543:	85 c0                	test   %eax,%eax
80106545:	79 0a                	jns    80106551 <sys_pipe+0x48>
    return -1;
80106547:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010654c:	e9 8e 00 00 00       	jmp    801065df <sys_pipe+0xd6>
  fd0 = -1;
80106551:	c7 45 f4 ff ff ff ff 	movl   $0xffffffff,-0xc(%ebp)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80106558:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010655b:	83 ec 0c             	sub    $0xc,%esp
8010655e:	50                   	push   %eax
8010655f:	e8 7c f3 ff ff       	call   801058e0 <fdalloc>
80106564:	83 c4 10             	add    $0x10,%esp
80106567:	89 45 f4             	mov    %eax,-0xc(%ebp)
8010656a:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010656e:	78 18                	js     80106588 <sys_pipe+0x7f>
80106570:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106573:	83 ec 0c             	sub    $0xc,%esp
80106576:	50                   	push   %eax
80106577:	e8 64 f3 ff ff       	call   801058e0 <fdalloc>
8010657c:	83 c4 10             	add    $0x10,%esp
8010657f:	89 45 f0             	mov    %eax,-0x10(%ebp)
80106582:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80106586:	79 3f                	jns    801065c7 <sys_pipe+0xbe>
    if(fd0 >= 0)
80106588:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
8010658c:	78 14                	js     801065a2 <sys_pipe+0x99>
      proc->ofile[fd0] = 0;
8010658e:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106594:	8b 55 f4             	mov    -0xc(%ebp),%edx
80106597:	83 c2 08             	add    $0x8,%edx
8010659a:	c7 44 90 08 00 00 00 	movl   $0x0,0x8(%eax,%edx,4)
801065a1:	00 
    fileclose(rf);
801065a2:	8b 45 e8             	mov    -0x18(%ebp),%eax
801065a5:	83 ec 0c             	sub    $0xc,%esp
801065a8:	50                   	push   %eax
801065a9:	e8 88 aa ff ff       	call   80101036 <fileclose>
801065ae:	83 c4 10             	add    $0x10,%esp
    fileclose(wf);
801065b1:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801065b4:	83 ec 0c             	sub    $0xc,%esp
801065b7:	50                   	push   %eax
801065b8:	e8 79 aa ff ff       	call   80101036 <fileclose>
801065bd:	83 c4 10             	add    $0x10,%esp
    return -1;
801065c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065c5:	eb 18                	jmp    801065df <sys_pipe+0xd6>
  }
  fd[0] = fd0;
801065c7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065ca:	8b 55 f4             	mov    -0xc(%ebp),%edx
801065cd:	89 10                	mov    %edx,(%eax)
  fd[1] = fd1;
801065cf:	8b 45 ec             	mov    -0x14(%ebp),%eax
801065d2:	8d 50 04             	lea    0x4(%eax),%edx
801065d5:	8b 45 f0             	mov    -0x10(%ebp),%eax
801065d8:	89 02                	mov    %eax,(%edx)
  return 0;
801065da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065df:	c9                   	leave  
801065e0:	c3                   	ret    

801065e1 <sys_fork>:
#include "memlayout.h"
#include "mmu.h"
#include "proc.h"
int
sys_fork(void)
{
801065e1:	55                   	push   %ebp
801065e2:	89 e5                	mov    %esp,%ebp
801065e4:	83 ec 08             	sub    $0x8,%esp
  return fork();
801065e7:	e8 6a e1 ff ff       	call   80104756 <fork>
}
801065ec:	c9                   	leave  
801065ed:	c3                   	ret    

801065ee <sys_exit>:

int
sys_exit(void)
{
801065ee:	55                   	push   %ebp
801065ef:	89 e5                	mov    %esp,%ebp
801065f1:	83 ec 08             	sub    $0x8,%esp
  exit();
801065f4:	e8 ee e2 ff ff       	call   801048e7 <exit>
  return 0;  // not reached
801065f9:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065fe:	c9                   	leave  
801065ff:	c3                   	ret    

80106600 <sys_wait>:

int
sys_wait(void)
{
80106600:	55                   	push   %ebp
80106601:	89 e5                	mov    %esp,%ebp
80106603:	83 ec 08             	sub    $0x8,%esp
  return wait();
80106606:	e8 29 e4 ff ff       	call   80104a34 <wait>
}
8010660b:	c9                   	leave  
8010660c:	c3                   	ret    

8010660d <sys_waitx>:
//@%^&*&^*&^*&^*&^(^(***************^&*(^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^)))
int 
sys_waitx(void)
{
8010660d:	55                   	push   %ebp
8010660e:	89 e5                	mov    %esp,%ebp
80106610:	83 ec 18             	sub    $0x18,%esp
  int *wtime;
  int *rtime;
  
  if(argptr(0, (char**)&wtime, sizeof(int)) < 0)
80106613:	83 ec 04             	sub    $0x4,%esp
80106616:	6a 04                	push   $0x4
80106618:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010661b:	50                   	push   %eax
8010661c:	6a 00                	push   $0x0
8010661e:	e8 34 f1 ff ff       	call   80105757 <argptr>
80106623:	83 c4 10             	add    $0x10,%esp
80106626:	85 c0                	test   %eax,%eax
80106628:	79 07                	jns    80106631 <sys_waitx+0x24>
    return 12;
8010662a:	b8 0c 00 00 00       	mov    $0xc,%eax
8010662f:	eb 31                	jmp    80106662 <sys_waitx+0x55>

  if(argptr(1, (char**)&rtime, sizeof(int)) < 0)
80106631:	83 ec 04             	sub    $0x4,%esp
80106634:	6a 04                	push   $0x4
80106636:	8d 45 f0             	lea    -0x10(%ebp),%eax
80106639:	50                   	push   %eax
8010663a:	6a 01                	push   $0x1
8010663c:	e8 16 f1 ff ff       	call   80105757 <argptr>
80106641:	83 c4 10             	add    $0x10,%esp
80106644:	85 c0                	test   %eax,%eax
80106646:	79 07                	jns    8010664f <sys_waitx+0x42>
    return 13;
80106648:	b8 0d 00 00 00       	mov    $0xd,%eax
8010664d:	eb 13                	jmp    80106662 <sys_waitx+0x55>

  return waitx(wtime,rtime);
8010664f:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106652:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106655:	83 ec 08             	sub    $0x8,%esp
80106658:	52                   	push   %edx
80106659:	50                   	push   %eax
8010665a:	e8 fc e4 ff ff       	call   80104b5b <waitx>
8010665f:	83 c4 10             	add    $0x10,%esp
}
80106662:	c9                   	leave  
80106663:	c3                   	ret    

80106664 <sys_kill>:

int
sys_kill(void)
{
80106664:	55                   	push   %ebp
80106665:	89 e5                	mov    %esp,%ebp
80106667:	83 ec 18             	sub    $0x18,%esp
  int pid;

  if(argint(0, &pid) < 0)
8010666a:	83 ec 08             	sub    $0x8,%esp
8010666d:	8d 45 f4             	lea    -0xc(%ebp),%eax
80106670:	50                   	push   %eax
80106671:	6a 00                	push   $0x0
80106673:	e8 b7 f0 ff ff       	call   8010572f <argint>
80106678:	83 c4 10             	add    $0x10,%esp
8010667b:	85 c0                	test   %eax,%eax
8010667d:	79 07                	jns    80106686 <sys_kill+0x22>
    return -1;
8010667f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106684:	eb 0f                	jmp    80106695 <sys_kill+0x31>
  return kill(pid);
80106686:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106689:	83 ec 0c             	sub    $0xc,%esp
8010668c:	50                   	push   %eax
8010668d:	e8 38 e9 ff ff       	call   80104fca <kill>
80106692:	83 c4 10             	add    $0x10,%esp
}
80106695:	c9                   	leave  
80106696:	c3                   	ret    

80106697 <sys_getpid>:

int
sys_getpid(void)
{
80106697:	55                   	push   %ebp
80106698:	89 e5                	mov    %esp,%ebp
  return proc->pid;
8010669a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066a0:	8b 40 10             	mov    0x10(%eax),%eax
}
801066a3:	5d                   	pop    %ebp
801066a4:	c3                   	ret    

801066a5 <sys_sbrk>:

int
sys_sbrk(void)
{
801066a5:	55                   	push   %ebp
801066a6:	89 e5                	mov    %esp,%ebp
801066a8:	83 ec 18             	sub    $0x18,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
801066ab:	83 ec 08             	sub    $0x8,%esp
801066ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066b1:	50                   	push   %eax
801066b2:	6a 00                	push   $0x0
801066b4:	e8 76 f0 ff ff       	call   8010572f <argint>
801066b9:	83 c4 10             	add    $0x10,%esp
801066bc:	85 c0                	test   %eax,%eax
801066be:	79 07                	jns    801066c7 <sys_sbrk+0x22>
    return -1;
801066c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066c5:	eb 28                	jmp    801066ef <sys_sbrk+0x4a>
  addr = proc->sz;
801066c7:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
801066cd:	8b 00                	mov    (%eax),%eax
801066cf:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(growproc(n) < 0)
801066d2:	8b 45 f0             	mov    -0x10(%ebp),%eax
801066d5:	83 ec 0c             	sub    $0xc,%esp
801066d8:	50                   	push   %eax
801066d9:	e8 d5 df ff ff       	call   801046b3 <growproc>
801066de:	83 c4 10             	add    $0x10,%esp
801066e1:	85 c0                	test   %eax,%eax
801066e3:	79 07                	jns    801066ec <sys_sbrk+0x47>
    return -1;
801066e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801066ea:	eb 03                	jmp    801066ef <sys_sbrk+0x4a>
  return addr;
801066ec:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801066ef:	c9                   	leave  
801066f0:	c3                   	ret    

801066f1 <sys_sleep>:

int
sys_sleep(void)
{
801066f1:	55                   	push   %ebp
801066f2:	89 e5                	mov    %esp,%ebp
801066f4:	83 ec 18             	sub    $0x18,%esp
  int n;
  uint ticks0;
  
  if(argint(0, &n) < 0)
801066f7:	83 ec 08             	sub    $0x8,%esp
801066fa:	8d 45 f0             	lea    -0x10(%ebp),%eax
801066fd:	50                   	push   %eax
801066fe:	6a 00                	push   $0x0
80106700:	e8 2a f0 ff ff       	call   8010572f <argint>
80106705:	83 c4 10             	add    $0x10,%esp
80106708:	85 c0                	test   %eax,%eax
8010670a:	79 07                	jns    80106713 <sys_sleep+0x22>
    return -1;
8010670c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106711:	eb 77                	jmp    8010678a <sys_sleep+0x99>
  acquire(&tickslock);
80106713:	83 ec 0c             	sub    $0xc,%esp
80106716:	68 c0 4c 11 80       	push   $0x80114cc0
8010671b:	e8 87 ea ff ff       	call   801051a7 <acquire>
80106720:	83 c4 10             	add    $0x10,%esp
  ticks0 = ticks;
80106723:	a1 00 55 11 80       	mov    0x80115500,%eax
80106728:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(ticks - ticks0 < n){
8010672b:	eb 39                	jmp    80106766 <sys_sleep+0x75>
    if(proc->killed){
8010672d:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106733:	8b 40 24             	mov    0x24(%eax),%eax
80106736:	85 c0                	test   %eax,%eax
80106738:	74 17                	je     80106751 <sys_sleep+0x60>
      release(&tickslock);
8010673a:	83 ec 0c             	sub    $0xc,%esp
8010673d:	68 c0 4c 11 80       	push   $0x80114cc0
80106742:	e8 c7 ea ff ff       	call   8010520e <release>
80106747:	83 c4 10             	add    $0x10,%esp
      return -1;
8010674a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010674f:	eb 39                	jmp    8010678a <sys_sleep+0x99>
    }
    sleep(&ticks, &tickslock);
80106751:	83 ec 08             	sub    $0x8,%esp
80106754:	68 c0 4c 11 80       	push   $0x80114cc0
80106759:	68 00 55 11 80       	push   $0x80115500
8010675e:	e8 42 e7 ff ff       	call   80104ea5 <sleep>
80106763:	83 c4 10             	add    $0x10,%esp
  
  if(argint(0, &n) < 0)
    return -1;
  acquire(&tickslock);
  ticks0 = ticks;
  while(ticks - ticks0 < n){
80106766:	a1 00 55 11 80       	mov    0x80115500,%eax
8010676b:	2b 45 f4             	sub    -0xc(%ebp),%eax
8010676e:	8b 55 f0             	mov    -0x10(%ebp),%edx
80106771:	39 d0                	cmp    %edx,%eax
80106773:	72 b8                	jb     8010672d <sys_sleep+0x3c>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
  }
  release(&tickslock);
80106775:	83 ec 0c             	sub    $0xc,%esp
80106778:	68 c0 4c 11 80       	push   $0x80114cc0
8010677d:	e8 8c ea ff ff       	call   8010520e <release>
80106782:	83 c4 10             	add    $0x10,%esp
  return 0;
80106785:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010678a:	c9                   	leave  
8010678b:	c3                   	ret    

8010678c <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
8010678c:	55                   	push   %ebp
8010678d:	89 e5                	mov    %esp,%ebp
8010678f:	83 ec 18             	sub    $0x18,%esp
  uint xticks;
  
  acquire(&tickslock);
80106792:	83 ec 0c             	sub    $0xc,%esp
80106795:	68 c0 4c 11 80       	push   $0x80114cc0
8010679a:	e8 08 ea ff ff       	call   801051a7 <acquire>
8010679f:	83 c4 10             	add    $0x10,%esp
  xticks = ticks;
801067a2:	a1 00 55 11 80       	mov    0x80115500,%eax
801067a7:	89 45 f4             	mov    %eax,-0xc(%ebp)
  release(&tickslock);
801067aa:	83 ec 0c             	sub    $0xc,%esp
801067ad:	68 c0 4c 11 80       	push   $0x80114cc0
801067b2:	e8 57 ea ff ff       	call   8010520e <release>
801067b7:	83 c4 10             	add    $0x10,%esp
  return xticks;
801067ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
}
801067bd:	c9                   	leave  
801067be:	c3                   	ret    

801067bf <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
801067bf:	55                   	push   %ebp
801067c0:	89 e5                	mov    %esp,%ebp
801067c2:	83 ec 08             	sub    $0x8,%esp
801067c5:	8b 55 08             	mov    0x8(%ebp),%edx
801067c8:	8b 45 0c             	mov    0xc(%ebp),%eax
801067cb:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
801067cf:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801067d2:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
801067d6:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
801067da:	ee                   	out    %al,(%dx)
}
801067db:	90                   	nop
801067dc:	c9                   	leave  
801067dd:	c3                   	ret    

801067de <timerinit>:
#define TIMER_RATEGEN   0x04    // mode 2, rate generator
#define TIMER_16BIT     0x30    // r/w counter 16 bits, LSB first

void
timerinit(void)
{
801067de:	55                   	push   %ebp
801067df:	89 e5                	mov    %esp,%ebp
801067e1:	83 ec 08             	sub    $0x8,%esp
  // Interrupt 100 times/sec.
  outb(TIMER_MODE, TIMER_SEL0 | TIMER_RATEGEN | TIMER_16BIT);
801067e4:	6a 34                	push   $0x34
801067e6:	6a 43                	push   $0x43
801067e8:	e8 d2 ff ff ff       	call   801067bf <outb>
801067ed:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) % 256);
801067f0:	68 9c 00 00 00       	push   $0x9c
801067f5:	6a 40                	push   $0x40
801067f7:	e8 c3 ff ff ff       	call   801067bf <outb>
801067fc:	83 c4 08             	add    $0x8,%esp
  outb(IO_TIMER1, TIMER_DIV(100) / 256);
801067ff:	6a 2e                	push   $0x2e
80106801:	6a 40                	push   $0x40
80106803:	e8 b7 ff ff ff       	call   801067bf <outb>
80106808:	83 c4 08             	add    $0x8,%esp
  picenable(IRQ_TIMER);
8010680b:	83 ec 0c             	sub    $0xc,%esp
8010680e:	6a 00                	push   $0x0
80106810:	e8 fb d6 ff ff       	call   80103f10 <picenable>
80106815:	83 c4 10             	add    $0x10,%esp
}
80106818:	90                   	nop
80106819:	c9                   	leave  
8010681a:	c3                   	ret    

8010681b <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
8010681b:	1e                   	push   %ds
  pushl %es
8010681c:	06                   	push   %es
  pushl %fs
8010681d:	0f a0                	push   %fs
  pushl %gs
8010681f:	0f a8                	push   %gs
  pushal
80106821:	60                   	pusha  
  
  # Set up data and per-cpu segments.
  movw $(SEG_KDATA<<3), %ax
80106822:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80106826:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80106828:	8e c0                	mov    %eax,%es
  movw $(SEG_KCPU<<3), %ax
8010682a:	66 b8 18 00          	mov    $0x18,%ax
  movw %ax, %fs
8010682e:	8e e0                	mov    %eax,%fs
  movw %ax, %gs
80106830:	8e e8                	mov    %eax,%gs

  # Call trap(tf), where tf=%esp
  pushl %esp
80106832:	54                   	push   %esp
  call trap
80106833:	e8 d7 01 00 00       	call   80106a0f <trap>
  addl $4, %esp
80106838:	83 c4 04             	add    $0x4,%esp

8010683b <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
8010683b:	61                   	popa   
  popl %gs
8010683c:	0f a9                	pop    %gs
  popl %fs
8010683e:	0f a1                	pop    %fs
  popl %es
80106840:	07                   	pop    %es
  popl %ds
80106841:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80106842:	83 c4 08             	add    $0x8,%esp
  iret
80106845:	cf                   	iret   

80106846 <lidt>:

struct gatedesc;

static inline void
lidt(struct gatedesc *p, int size)
{
80106846:	55                   	push   %ebp
80106847:	89 e5                	mov    %esp,%ebp
80106849:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010684c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010684f:	83 e8 01             	sub    $0x1,%eax
80106852:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80106856:	8b 45 08             	mov    0x8(%ebp),%eax
80106859:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010685d:	8b 45 08             	mov    0x8(%ebp),%eax
80106860:	c1 e8 10             	shr    $0x10,%eax
80106863:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lidt (%0)" : : "r" (pd));
80106867:	8d 45 fa             	lea    -0x6(%ebp),%eax
8010686a:	0f 01 18             	lidtl  (%eax)
}
8010686d:	90                   	nop
8010686e:	c9                   	leave  
8010686f:	c3                   	ret    

80106870 <rcr2>:
  return result;
}

static inline uint
rcr2(void)
{
80106870:	55                   	push   %ebp
80106871:	89 e5                	mov    %esp,%ebp
80106873:	83 ec 10             	sub    $0x10,%esp
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80106876:	0f 20 d0             	mov    %cr2,%eax
80106879:	89 45 fc             	mov    %eax,-0x4(%ebp)
  return val;
8010687c:	8b 45 fc             	mov    -0x4(%ebp),%eax
}
8010687f:	c9                   	leave  
80106880:	c3                   	ret    

80106881 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80106881:	55                   	push   %ebp
80106882:	89 e5                	mov    %esp,%ebp
80106884:	83 ec 18             	sub    $0x18,%esp
  int i;

  for(i = 0; i < 256; i++)
80106887:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010688e:	e9 c3 00 00 00       	jmp    80106956 <tvinit+0xd5>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80106893:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106896:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
8010689d:	89 c2                	mov    %eax,%edx
8010689f:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068a2:	66 89 14 c5 00 4d 11 	mov    %dx,-0x7feeb300(,%eax,8)
801068a9:	80 
801068aa:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ad:	66 c7 04 c5 02 4d 11 	movw   $0x8,-0x7feeb2fe(,%eax,8)
801068b4:	80 08 00 
801068b7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068ba:	0f b6 14 c5 04 4d 11 	movzbl -0x7feeb2fc(,%eax,8),%edx
801068c1:	80 
801068c2:	83 e2 e0             	and    $0xffffffe0,%edx
801068c5:	88 14 c5 04 4d 11 80 	mov    %dl,-0x7feeb2fc(,%eax,8)
801068cc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068cf:	0f b6 14 c5 04 4d 11 	movzbl -0x7feeb2fc(,%eax,8),%edx
801068d6:	80 
801068d7:	83 e2 1f             	and    $0x1f,%edx
801068da:	88 14 c5 04 4d 11 80 	mov    %dl,-0x7feeb2fc(,%eax,8)
801068e1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068e4:	0f b6 14 c5 05 4d 11 	movzbl -0x7feeb2fb(,%eax,8),%edx
801068eb:	80 
801068ec:	83 e2 f0             	and    $0xfffffff0,%edx
801068ef:	83 ca 0e             	or     $0xe,%edx
801068f2:	88 14 c5 05 4d 11 80 	mov    %dl,-0x7feeb2fb(,%eax,8)
801068f9:	8b 45 f4             	mov    -0xc(%ebp),%eax
801068fc:	0f b6 14 c5 05 4d 11 	movzbl -0x7feeb2fb(,%eax,8),%edx
80106903:	80 
80106904:	83 e2 ef             	and    $0xffffffef,%edx
80106907:	88 14 c5 05 4d 11 80 	mov    %dl,-0x7feeb2fb(,%eax,8)
8010690e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106911:	0f b6 14 c5 05 4d 11 	movzbl -0x7feeb2fb(,%eax,8),%edx
80106918:	80 
80106919:	83 e2 9f             	and    $0xffffff9f,%edx
8010691c:	88 14 c5 05 4d 11 80 	mov    %dl,-0x7feeb2fb(,%eax,8)
80106923:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106926:	0f b6 14 c5 05 4d 11 	movzbl -0x7feeb2fb(,%eax,8),%edx
8010692d:	80 
8010692e:	83 ca 80             	or     $0xffffff80,%edx
80106931:	88 14 c5 05 4d 11 80 	mov    %dl,-0x7feeb2fb(,%eax,8)
80106938:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010693b:	8b 04 85 9c b0 10 80 	mov    -0x7fef4f64(,%eax,4),%eax
80106942:	c1 e8 10             	shr    $0x10,%eax
80106945:	89 c2                	mov    %eax,%edx
80106947:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010694a:	66 89 14 c5 06 4d 11 	mov    %dx,-0x7feeb2fa(,%eax,8)
80106951:	80 
void
tvinit(void)
{
  int i;

  for(i = 0; i < 256; i++)
80106952:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106956:	81 7d f4 ff 00 00 00 	cmpl   $0xff,-0xc(%ebp)
8010695d:	0f 8e 30 ff ff ff    	jle    80106893 <tvinit+0x12>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80106963:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
80106968:	66 a3 00 4f 11 80    	mov    %ax,0x80114f00
8010696e:	66 c7 05 02 4f 11 80 	movw   $0x8,0x80114f02
80106975:	08 00 
80106977:	0f b6 05 04 4f 11 80 	movzbl 0x80114f04,%eax
8010697e:	83 e0 e0             	and    $0xffffffe0,%eax
80106981:	a2 04 4f 11 80       	mov    %al,0x80114f04
80106986:	0f b6 05 04 4f 11 80 	movzbl 0x80114f04,%eax
8010698d:	83 e0 1f             	and    $0x1f,%eax
80106990:	a2 04 4f 11 80       	mov    %al,0x80114f04
80106995:	0f b6 05 05 4f 11 80 	movzbl 0x80114f05,%eax
8010699c:	83 c8 0f             	or     $0xf,%eax
8010699f:	a2 05 4f 11 80       	mov    %al,0x80114f05
801069a4:	0f b6 05 05 4f 11 80 	movzbl 0x80114f05,%eax
801069ab:	83 e0 ef             	and    $0xffffffef,%eax
801069ae:	a2 05 4f 11 80       	mov    %al,0x80114f05
801069b3:	0f b6 05 05 4f 11 80 	movzbl 0x80114f05,%eax
801069ba:	83 c8 60             	or     $0x60,%eax
801069bd:	a2 05 4f 11 80       	mov    %al,0x80114f05
801069c2:	0f b6 05 05 4f 11 80 	movzbl 0x80114f05,%eax
801069c9:	83 c8 80             	or     $0xffffff80,%eax
801069cc:	a2 05 4f 11 80       	mov    %al,0x80114f05
801069d1:	a1 9c b1 10 80       	mov    0x8010b19c,%eax
801069d6:	c1 e8 10             	shr    $0x10,%eax
801069d9:	66 a3 06 4f 11 80    	mov    %ax,0x80114f06
  
  initlock(&tickslock, "time");
801069df:	83 ec 08             	sub    $0x8,%esp
801069e2:	68 3c 8c 10 80       	push   $0x80108c3c
801069e7:	68 c0 4c 11 80       	push   $0x80114cc0
801069ec:	e8 94 e7 ff ff       	call   80105185 <initlock>
801069f1:	83 c4 10             	add    $0x10,%esp
}
801069f4:	90                   	nop
801069f5:	c9                   	leave  
801069f6:	c3                   	ret    

801069f7 <idtinit>:

void
idtinit(void)
{
801069f7:	55                   	push   %ebp
801069f8:	89 e5                	mov    %esp,%ebp
  lidt(idt, sizeof(idt));
801069fa:	68 00 08 00 00       	push   $0x800
801069ff:	68 00 4d 11 80       	push   $0x80114d00
80106a04:	e8 3d fe ff ff       	call   80106846 <lidt>
80106a09:	83 c4 08             	add    $0x8,%esp
}
80106a0c:	90                   	nop
80106a0d:	c9                   	leave  
80106a0e:	c3                   	ret    

80106a0f <trap>:

//PAGEBREAK: 41
void
trap(struct trapframe *tf)
{
80106a0f:	55                   	push   %ebp
80106a10:	89 e5                	mov    %esp,%ebp
80106a12:	57                   	push   %edi
80106a13:	56                   	push   %esi
80106a14:	53                   	push   %ebx
80106a15:	83 ec 1c             	sub    $0x1c,%esp
  if(tf->trapno == T_SYSCALL){
80106a18:	8b 45 08             	mov    0x8(%ebp),%eax
80106a1b:	8b 40 30             	mov    0x30(%eax),%eax
80106a1e:	83 f8 40             	cmp    $0x40,%eax
80106a21:	75 3e                	jne    80106a61 <trap+0x52>
    if(proc->killed)
80106a23:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a29:	8b 40 24             	mov    0x24(%eax),%eax
80106a2c:	85 c0                	test   %eax,%eax
80106a2e:	74 05                	je     80106a35 <trap+0x26>
      exit();
80106a30:	e8 b2 de ff ff       	call   801048e7 <exit>
    proc->tf = tf;
80106a35:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a3b:	8b 55 08             	mov    0x8(%ebp),%edx
80106a3e:	89 50 18             	mov    %edx,0x18(%eax)
    syscall();
80106a41:	e8 9f ed ff ff       	call   801057e5 <syscall>
    if(proc->killed)
80106a46:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106a4c:	8b 40 24             	mov    0x24(%eax),%eax
80106a4f:	85 c0                	test   %eax,%eax
80106a51:	0f 84 71 02 00 00    	je     80106cc8 <trap+0x2b9>
      exit();
80106a57:	e8 8b de ff ff       	call   801048e7 <exit>
    return;
80106a5c:	e9 67 02 00 00       	jmp    80106cc8 <trap+0x2b9>
  }

  switch(tf->trapno){
80106a61:	8b 45 08             	mov    0x8(%ebp),%eax
80106a64:	8b 40 30             	mov    0x30(%eax),%eax
80106a67:	83 e8 20             	sub    $0x20,%eax
80106a6a:	83 f8 1f             	cmp    $0x1f,%eax
80106a6d:	0f 87 16 01 00 00    	ja     80106b89 <trap+0x17a>
80106a73:	8b 04 85 e4 8c 10 80 	mov    -0x7fef731c(,%eax,4),%eax
80106a7a:	ff e0                	jmp    *%eax
  case T_IRQ0 + IRQ_TIMER:
    if(cpu->id == 0){
80106a7c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106a82:	0f b6 00             	movzbl (%eax),%eax
80106a85:	84 c0                	test   %al,%al
80106a87:	0f 85 8f 00 00 00    	jne    80106b1c <trap+0x10d>
      acquire(&tickslock);
80106a8d:	83 ec 0c             	sub    $0xc,%esp
80106a90:	68 c0 4c 11 80       	push   $0x80114cc0
80106a95:	e8 0d e7 ff ff       	call   801051a7 <acquire>
80106a9a:	83 c4 10             	add    $0x10,%esp
      ticks++;
80106a9d:	a1 00 55 11 80       	mov    0x80115500,%eax
80106aa2:	83 c0 01             	add    $0x1,%eax
80106aa5:	a3 00 55 11 80       	mov    %eax,0x80115500
      wakeup(&ticks);
80106aaa:	83 ec 0c             	sub    $0xc,%esp
80106aad:	68 00 55 11 80       	push   $0x80115500
80106ab2:	e8 dc e4 ff ff       	call   80104f93 <wakeup>
80106ab7:	83 c4 10             	add    $0x10,%esp
      release(&tickslock);
80106aba:	83 ec 0c             	sub    $0xc,%esp
80106abd:	68 c0 4c 11 80       	push   $0x80114cc0
80106ac2:	e8 47 e7 ff ff       	call   8010520e <release>
80106ac7:	83 c4 10             	add    $0x10,%esp

      // #@%$#@%%@%%@%%%@#$%@%@$%@%@
       if(proc) {
80106aca:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ad0:	85 c0                	test   %eax,%eax
80106ad2:	74 48                	je     80106b1c <trap+0x10d>
        if(proc->state == RUNNING)
80106ad4:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ada:	8b 40 0c             	mov    0xc(%eax),%eax
80106add:	83 f8 04             	cmp    $0x4,%eax
80106ae0:	75 17                	jne    80106af9 <trap+0xea>
          proc->rtime++;
80106ae2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ae8:	8b 90 84 00 00 00    	mov    0x84(%eax),%edx
80106aee:	83 c2 01             	add    $0x1,%edx
80106af1:	89 90 84 00 00 00    	mov    %edx,0x84(%eax)
80106af7:	eb 23                	jmp    80106b1c <trap+0x10d>
        else if(proc->state == SLEEPING)
80106af9:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106aff:	8b 40 0c             	mov    0xc(%eax),%eax
80106b02:	83 f8 02             	cmp    $0x2,%eax
80106b05:	75 15                	jne    80106b1c <trap+0x10d>
          proc->iotime++;
80106b07:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b0d:	8b 90 88 00 00 00    	mov    0x88(%eax),%edx
80106b13:	83 c2 01             	add    $0x1,%edx
80106b16:	89 90 88 00 00 00    	mov    %edx,0x88(%eax)
      }
    }
    lapiceoi();
80106b1c:	e8 e9 c4 ff ff       	call   8010300a <lapiceoi>
    break;
80106b21:	e9 1c 01 00 00       	jmp    80106c42 <trap+0x233>
  case T_IRQ0 + IRQ_IDE:
    ideintr();
80106b26:	e8 f2 bc ff ff       	call   8010281d <ideintr>
    lapiceoi();
80106b2b:	e8 da c4 ff ff       	call   8010300a <lapiceoi>
    break;
80106b30:	e9 0d 01 00 00       	jmp    80106c42 <trap+0x233>
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
  case T_IRQ0 + IRQ_KBD:
    kbdintr();
80106b35:	e8 d2 c2 ff ff       	call   80102e0c <kbdintr>
    lapiceoi();
80106b3a:	e8 cb c4 ff ff       	call   8010300a <lapiceoi>
    break;
80106b3f:	e9 fe 00 00 00       	jmp    80106c42 <trap+0x233>
  case T_IRQ0 + IRQ_COM1:
    uartintr();
80106b44:	e8 60 03 00 00       	call   80106ea9 <uartintr>
    lapiceoi();
80106b49:	e8 bc c4 ff ff       	call   8010300a <lapiceoi>
    break;
80106b4e:	e9 ef 00 00 00       	jmp    80106c42 <trap+0x233>
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b53:	8b 45 08             	mov    0x8(%ebp),%eax
80106b56:	8b 48 38             	mov    0x38(%eax),%ecx
            cpu->id, tf->cs, tf->eip);
80106b59:	8b 45 08             	mov    0x8(%ebp),%eax
80106b5c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b60:	0f b7 d0             	movzwl %ax,%edx
            cpu->id, tf->cs, tf->eip);
80106b63:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106b69:	0f b6 00             	movzbl (%eax),%eax
    uartintr();
    lapiceoi();
    break;
  case T_IRQ0 + 7:
  case T_IRQ0 + IRQ_SPURIOUS:
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80106b6c:	0f b6 c0             	movzbl %al,%eax
80106b6f:	51                   	push   %ecx
80106b70:	52                   	push   %edx
80106b71:	50                   	push   %eax
80106b72:	68 44 8c 10 80       	push   $0x80108c44
80106b77:	e8 4a 98 ff ff       	call   801003c6 <cprintf>
80106b7c:	83 c4 10             	add    $0x10,%esp
            cpu->id, tf->cs, tf->eip);
    lapiceoi();
80106b7f:	e8 86 c4 ff ff       	call   8010300a <lapiceoi>
    break;
80106b84:	e9 b9 00 00 00       	jmp    80106c42 <trap+0x233>
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
80106b89:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106b8f:	85 c0                	test   %eax,%eax
80106b91:	74 11                	je     80106ba4 <trap+0x195>
80106b93:	8b 45 08             	mov    0x8(%ebp),%eax
80106b96:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106b9a:	0f b7 c0             	movzwl %ax,%eax
80106b9d:	83 e0 03             	and    $0x3,%eax
80106ba0:	85 c0                	test   %eax,%eax
80106ba2:	75 40                	jne    80106be4 <trap+0x1d5>
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106ba4:	e8 c7 fc ff ff       	call   80106870 <rcr2>
80106ba9:	89 c3                	mov    %eax,%ebx
80106bab:	8b 45 08             	mov    0x8(%ebp),%eax
80106bae:	8b 48 38             	mov    0x38(%eax),%ecx
              tf->trapno, cpu->id, tf->eip, rcr2());
80106bb1:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bb7:	0f b6 00             	movzbl (%eax),%eax
   
  //PAGEBREAK: 13
  default:
    if(proc == 0 || (tf->cs&3) == 0){
      // In kernel, it must be our mistake.
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80106bba:	0f b6 d0             	movzbl %al,%edx
80106bbd:	8b 45 08             	mov    0x8(%ebp),%eax
80106bc0:	8b 40 30             	mov    0x30(%eax),%eax
80106bc3:	83 ec 0c             	sub    $0xc,%esp
80106bc6:	53                   	push   %ebx
80106bc7:	51                   	push   %ecx
80106bc8:	52                   	push   %edx
80106bc9:	50                   	push   %eax
80106bca:	68 68 8c 10 80       	push   $0x80108c68
80106bcf:	e8 f2 97 ff ff       	call   801003c6 <cprintf>
80106bd4:	83 c4 20             	add    $0x20,%esp
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
80106bd7:	83 ec 0c             	sub    $0xc,%esp
80106bda:	68 9a 8c 10 80       	push   $0x80108c9a
80106bdf:	e8 82 99 ff ff       	call   80100566 <panic>
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106be4:	e8 87 fc ff ff       	call   80106870 <rcr2>
80106be9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106bec:	8b 45 08             	mov    0x8(%ebp),%eax
80106bef:	8b 70 38             	mov    0x38(%eax),%esi
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106bf2:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80106bf8:	0f b6 00             	movzbl (%eax),%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106bfb:	0f b6 d8             	movzbl %al,%ebx
80106bfe:	8b 45 08             	mov    0x8(%ebp),%eax
80106c01:	8b 48 34             	mov    0x34(%eax),%ecx
80106c04:	8b 45 08             	mov    0x8(%ebp),%eax
80106c07:	8b 50 30             	mov    0x30(%eax),%edx
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
80106c0a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c10:	8d 78 6c             	lea    0x6c(%eax),%edi
80106c13:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
              tf->trapno, cpu->id, tf->eip, rcr2());
      panic("trap");
    }
    // In user space, assume process misbehaved.
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80106c19:	8b 40 10             	mov    0x10(%eax),%eax
80106c1c:	ff 75 e4             	pushl  -0x1c(%ebp)
80106c1f:	56                   	push   %esi
80106c20:	53                   	push   %ebx
80106c21:	51                   	push   %ecx
80106c22:	52                   	push   %edx
80106c23:	57                   	push   %edi
80106c24:	50                   	push   %eax
80106c25:	68 a0 8c 10 80       	push   $0x80108ca0
80106c2a:	e8 97 97 ff ff       	call   801003c6 <cprintf>
80106c2f:	83 c4 20             	add    $0x20,%esp
            "eip 0x%x addr 0x%x--kill proc\n",
            proc->pid, proc->name, tf->trapno, tf->err, cpu->id, tf->eip, 
            rcr2());
    proc->killed = 1;
80106c32:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c38:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80106c3f:	eb 01                	jmp    80106c42 <trap+0x233>
    ideintr();
    lapiceoi();
    break;
  case T_IRQ0 + IRQ_IDE+1:
    // Bochs generates spurious IDE1 interrupts.
    break;
80106c41:	90                   	nop
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running 
  // until it gets to the regular system call return.)
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c42:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c48:	85 c0                	test   %eax,%eax
80106c4a:	74 24                	je     80106c70 <trap+0x261>
80106c4c:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c52:	8b 40 24             	mov    0x24(%eax),%eax
80106c55:	85 c0                	test   %eax,%eax
80106c57:	74 17                	je     80106c70 <trap+0x261>
80106c59:	8b 45 08             	mov    0x8(%ebp),%eax
80106c5c:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106c60:	0f b7 c0             	movzwl %ax,%eax
80106c63:	83 e0 03             	and    $0x3,%eax
80106c66:	83 f8 03             	cmp    $0x3,%eax
80106c69:	75 05                	jne    80106c70 <trap+0x261>
    exit();
80106c6b:	e8 77 dc ff ff       	call   801048e7 <exit>

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(proc && proc->state == RUNNING && tf->trapno == T_IRQ0+IRQ_TIMER)
80106c70:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c76:	85 c0                	test   %eax,%eax
80106c78:	74 1e                	je     80106c98 <trap+0x289>
80106c7a:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c80:	8b 40 0c             	mov    0xc(%eax),%eax
80106c83:	83 f8 04             	cmp    $0x4,%eax
80106c86:	75 10                	jne    80106c98 <trap+0x289>
80106c88:	8b 45 08             	mov    0x8(%ebp),%eax
80106c8b:	8b 40 30             	mov    0x30(%eax),%eax
80106c8e:	83 f8 20             	cmp    $0x20,%eax
80106c91:	75 05                	jne    80106c98 <trap+0x289>
    yield();
80106c93:	e8 8c e1 ff ff       	call   80104e24 <yield>

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
80106c98:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106c9e:	85 c0                	test   %eax,%eax
80106ca0:	74 27                	je     80106cc9 <trap+0x2ba>
80106ca2:	65 a1 04 00 00 00    	mov    %gs:0x4,%eax
80106ca8:	8b 40 24             	mov    0x24(%eax),%eax
80106cab:	85 c0                	test   %eax,%eax
80106cad:	74 1a                	je     80106cc9 <trap+0x2ba>
80106caf:	8b 45 08             	mov    0x8(%ebp),%eax
80106cb2:	0f b7 40 3c          	movzwl 0x3c(%eax),%eax
80106cb6:	0f b7 c0             	movzwl %ax,%eax
80106cb9:	83 e0 03             	and    $0x3,%eax
80106cbc:	83 f8 03             	cmp    $0x3,%eax
80106cbf:	75 08                	jne    80106cc9 <trap+0x2ba>
    exit();
80106cc1:	e8 21 dc ff ff       	call   801048e7 <exit>
80106cc6:	eb 01                	jmp    80106cc9 <trap+0x2ba>
      exit();
    proc->tf = tf;
    syscall();
    if(proc->killed)
      exit();
    return;
80106cc8:	90                   	nop
    yield();

  // Check if the process has been killed since we yielded
  if(proc && proc->killed && (tf->cs&3) == DPL_USER)
    exit();
}
80106cc9:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106ccc:	5b                   	pop    %ebx
80106ccd:	5e                   	pop    %esi
80106cce:	5f                   	pop    %edi
80106ccf:	5d                   	pop    %ebp
80106cd0:	c3                   	ret    

80106cd1 <inb>:
// Routines to let C code use special x86 instructions.

static inline uchar
inb(ushort port)
{
80106cd1:	55                   	push   %ebp
80106cd2:	89 e5                	mov    %esp,%ebp
80106cd4:	83 ec 14             	sub    $0x14,%esp
80106cd7:	8b 45 08             	mov    0x8(%ebp),%eax
80106cda:	66 89 45 ec          	mov    %ax,-0x14(%ebp)
  uchar data;

  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80106cde:	0f b7 45 ec          	movzwl -0x14(%ebp),%eax
80106ce2:	89 c2                	mov    %eax,%edx
80106ce4:	ec                   	in     (%dx),%al
80106ce5:	88 45 ff             	mov    %al,-0x1(%ebp)
  return data;
80106ce8:	0f b6 45 ff          	movzbl -0x1(%ebp),%eax
}
80106cec:	c9                   	leave  
80106ced:	c3                   	ret    

80106cee <outb>:
               "memory", "cc");
}

static inline void
outb(ushort port, uchar data)
{
80106cee:	55                   	push   %ebp
80106cef:	89 e5                	mov    %esp,%ebp
80106cf1:	83 ec 08             	sub    $0x8,%esp
80106cf4:	8b 55 08             	mov    0x8(%ebp),%edx
80106cf7:	8b 45 0c             	mov    0xc(%ebp),%eax
80106cfa:	66 89 55 fc          	mov    %dx,-0x4(%ebp)
80106cfe:	88 45 f8             	mov    %al,-0x8(%ebp)
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80106d01:	0f b6 45 f8          	movzbl -0x8(%ebp),%eax
80106d05:	0f b7 55 fc          	movzwl -0x4(%ebp),%edx
80106d09:	ee                   	out    %al,(%dx)
}
80106d0a:	90                   	nop
80106d0b:	c9                   	leave  
80106d0c:	c3                   	ret    

80106d0d <uartinit>:

static int uart;    // is there a uart?

void
uartinit(void)
{
80106d0d:	55                   	push   %ebp
80106d0e:	89 e5                	mov    %esp,%ebp
80106d10:	83 ec 18             	sub    $0x18,%esp
  char *p;

  // Turn off the FIFO
  outb(COM1+2, 0);
80106d13:	6a 00                	push   $0x0
80106d15:	68 fa 03 00 00       	push   $0x3fa
80106d1a:	e8 cf ff ff ff       	call   80106cee <outb>
80106d1f:	83 c4 08             	add    $0x8,%esp
  
  // 9600 baud, 8 data bits, 1 stop bit, parity off.
  outb(COM1+3, 0x80);    // Unlock divisor
80106d22:	68 80 00 00 00       	push   $0x80
80106d27:	68 fb 03 00 00       	push   $0x3fb
80106d2c:	e8 bd ff ff ff       	call   80106cee <outb>
80106d31:	83 c4 08             	add    $0x8,%esp
  outb(COM1+0, 115200/9600);
80106d34:	6a 0c                	push   $0xc
80106d36:	68 f8 03 00 00       	push   $0x3f8
80106d3b:	e8 ae ff ff ff       	call   80106cee <outb>
80106d40:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0);
80106d43:	6a 00                	push   $0x0
80106d45:	68 f9 03 00 00       	push   $0x3f9
80106d4a:	e8 9f ff ff ff       	call   80106cee <outb>
80106d4f:	83 c4 08             	add    $0x8,%esp
  outb(COM1+3, 0x03);    // Lock divisor, 8 data bits.
80106d52:	6a 03                	push   $0x3
80106d54:	68 fb 03 00 00       	push   $0x3fb
80106d59:	e8 90 ff ff ff       	call   80106cee <outb>
80106d5e:	83 c4 08             	add    $0x8,%esp
  outb(COM1+4, 0);
80106d61:	6a 00                	push   $0x0
80106d63:	68 fc 03 00 00       	push   $0x3fc
80106d68:	e8 81 ff ff ff       	call   80106cee <outb>
80106d6d:	83 c4 08             	add    $0x8,%esp
  outb(COM1+1, 0x01);    // Enable receive interrupts.
80106d70:	6a 01                	push   $0x1
80106d72:	68 f9 03 00 00       	push   $0x3f9
80106d77:	e8 72 ff ff ff       	call   80106cee <outb>
80106d7c:	83 c4 08             	add    $0x8,%esp

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
80106d7f:	68 fd 03 00 00       	push   $0x3fd
80106d84:	e8 48 ff ff ff       	call   80106cd1 <inb>
80106d89:	83 c4 04             	add    $0x4,%esp
80106d8c:	3c ff                	cmp    $0xff,%al
80106d8e:	74 6e                	je     80106dfe <uartinit+0xf1>
    return;
  uart = 1;
80106d90:	c7 05 4c b6 10 80 01 	movl   $0x1,0x8010b64c
80106d97:	00 00 00 

  // Acknowledge pre-existing interrupt conditions;
  // enable interrupts.
  inb(COM1+2);
80106d9a:	68 fa 03 00 00       	push   $0x3fa
80106d9f:	e8 2d ff ff ff       	call   80106cd1 <inb>
80106da4:	83 c4 04             	add    $0x4,%esp
  inb(COM1+0);
80106da7:	68 f8 03 00 00       	push   $0x3f8
80106dac:	e8 20 ff ff ff       	call   80106cd1 <inb>
80106db1:	83 c4 04             	add    $0x4,%esp
  picenable(IRQ_COM1);
80106db4:	83 ec 0c             	sub    $0xc,%esp
80106db7:	6a 04                	push   $0x4
80106db9:	e8 52 d1 ff ff       	call   80103f10 <picenable>
80106dbe:	83 c4 10             	add    $0x10,%esp
  ioapicenable(IRQ_COM1, 0);
80106dc1:	83 ec 08             	sub    $0x8,%esp
80106dc4:	6a 00                	push   $0x0
80106dc6:	6a 04                	push   $0x4
80106dc8:	e8 f2 bc ff ff       	call   80102abf <ioapicenable>
80106dcd:	83 c4 10             	add    $0x10,%esp
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106dd0:	c7 45 f4 64 8d 10 80 	movl   $0x80108d64,-0xc(%ebp)
80106dd7:	eb 19                	jmp    80106df2 <uartinit+0xe5>
    uartputc(*p);
80106dd9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106ddc:	0f b6 00             	movzbl (%eax),%eax
80106ddf:	0f be c0             	movsbl %al,%eax
80106de2:	83 ec 0c             	sub    $0xc,%esp
80106de5:	50                   	push   %eax
80106de6:	e8 16 00 00 00       	call   80106e01 <uartputc>
80106deb:	83 c4 10             	add    $0x10,%esp
  inb(COM1+0);
  picenable(IRQ_COM1);
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
80106dee:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106df2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80106df5:	0f b6 00             	movzbl (%eax),%eax
80106df8:	84 c0                	test   %al,%al
80106dfa:	75 dd                	jne    80106dd9 <uartinit+0xcc>
80106dfc:	eb 01                	jmp    80106dff <uartinit+0xf2>
  outb(COM1+4, 0);
  outb(COM1+1, 0x01);    // Enable receive interrupts.

  // If status is 0xFF, no serial port.
  if(inb(COM1+5) == 0xFF)
    return;
80106dfe:	90                   	nop
  ioapicenable(IRQ_COM1, 0);
  
  // Announce that we're here.
  for(p="xv6...\n"; *p; p++)
    uartputc(*p);
}
80106dff:	c9                   	leave  
80106e00:	c3                   	ret    

80106e01 <uartputc>:

void
uartputc(int c)
{
80106e01:	55                   	push   %ebp
80106e02:	89 e5                	mov    %esp,%ebp
80106e04:	83 ec 18             	sub    $0x18,%esp
  int i;

  if(!uart)
80106e07:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106e0c:	85 c0                	test   %eax,%eax
80106e0e:	74 53                	je     80106e63 <uartputc+0x62>
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e10:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
80106e17:	eb 11                	jmp    80106e2a <uartputc+0x29>
    microdelay(10);
80106e19:	83 ec 0c             	sub    $0xc,%esp
80106e1c:	6a 0a                	push   $0xa
80106e1e:	e8 02 c2 ff ff       	call   80103025 <microdelay>
80106e23:	83 c4 10             	add    $0x10,%esp
{
  int i;

  if(!uart)
    return;
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80106e26:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80106e2a:	83 7d f4 7f          	cmpl   $0x7f,-0xc(%ebp)
80106e2e:	7f 1a                	jg     80106e4a <uartputc+0x49>
80106e30:	83 ec 0c             	sub    $0xc,%esp
80106e33:	68 fd 03 00 00       	push   $0x3fd
80106e38:	e8 94 fe ff ff       	call   80106cd1 <inb>
80106e3d:	83 c4 10             	add    $0x10,%esp
80106e40:	0f b6 c0             	movzbl %al,%eax
80106e43:	83 e0 20             	and    $0x20,%eax
80106e46:	85 c0                	test   %eax,%eax
80106e48:	74 cf                	je     80106e19 <uartputc+0x18>
    microdelay(10);
  outb(COM1+0, c);
80106e4a:	8b 45 08             	mov    0x8(%ebp),%eax
80106e4d:	0f b6 c0             	movzbl %al,%eax
80106e50:	83 ec 08             	sub    $0x8,%esp
80106e53:	50                   	push   %eax
80106e54:	68 f8 03 00 00       	push   $0x3f8
80106e59:	e8 90 fe ff ff       	call   80106cee <outb>
80106e5e:	83 c4 10             	add    $0x10,%esp
80106e61:	eb 01                	jmp    80106e64 <uartputc+0x63>
uartputc(int c)
{
  int i;

  if(!uart)
    return;
80106e63:	90                   	nop
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
    microdelay(10);
  outb(COM1+0, c);
}
80106e64:	c9                   	leave  
80106e65:	c3                   	ret    

80106e66 <uartgetc>:

static int
uartgetc(void)
{
80106e66:	55                   	push   %ebp
80106e67:	89 e5                	mov    %esp,%ebp
  if(!uart)
80106e69:	a1 4c b6 10 80       	mov    0x8010b64c,%eax
80106e6e:	85 c0                	test   %eax,%eax
80106e70:	75 07                	jne    80106e79 <uartgetc+0x13>
    return -1;
80106e72:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e77:	eb 2e                	jmp    80106ea7 <uartgetc+0x41>
  if(!(inb(COM1+5) & 0x01))
80106e79:	68 fd 03 00 00       	push   $0x3fd
80106e7e:	e8 4e fe ff ff       	call   80106cd1 <inb>
80106e83:	83 c4 04             	add    $0x4,%esp
80106e86:	0f b6 c0             	movzbl %al,%eax
80106e89:	83 e0 01             	and    $0x1,%eax
80106e8c:	85 c0                	test   %eax,%eax
80106e8e:	75 07                	jne    80106e97 <uartgetc+0x31>
    return -1;
80106e90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106e95:	eb 10                	jmp    80106ea7 <uartgetc+0x41>
  return inb(COM1+0);
80106e97:	68 f8 03 00 00       	push   $0x3f8
80106e9c:	e8 30 fe ff ff       	call   80106cd1 <inb>
80106ea1:	83 c4 04             	add    $0x4,%esp
80106ea4:	0f b6 c0             	movzbl %al,%eax
}
80106ea7:	c9                   	leave  
80106ea8:	c3                   	ret    

80106ea9 <uartintr>:

void
uartintr(void)
{
80106ea9:	55                   	push   %ebp
80106eaa:	89 e5                	mov    %esp,%ebp
80106eac:	83 ec 08             	sub    $0x8,%esp
  consoleintr(uartgetc);
80106eaf:	83 ec 0c             	sub    $0xc,%esp
80106eb2:	68 66 6e 10 80       	push   $0x80106e66
80106eb7:	e8 21 99 ff ff       	call   801007dd <consoleintr>
80106ebc:	83 c4 10             	add    $0x10,%esp
}
80106ebf:	90                   	nop
80106ec0:	c9                   	leave  
80106ec1:	c3                   	ret    

80106ec2 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80106ec2:	6a 00                	push   $0x0
  pushl $0
80106ec4:	6a 00                	push   $0x0
  jmp alltraps
80106ec6:	e9 50 f9 ff ff       	jmp    8010681b <alltraps>

80106ecb <vector1>:
.globl vector1
vector1:
  pushl $0
80106ecb:	6a 00                	push   $0x0
  pushl $1
80106ecd:	6a 01                	push   $0x1
  jmp alltraps
80106ecf:	e9 47 f9 ff ff       	jmp    8010681b <alltraps>

80106ed4 <vector2>:
.globl vector2
vector2:
  pushl $0
80106ed4:	6a 00                	push   $0x0
  pushl $2
80106ed6:	6a 02                	push   $0x2
  jmp alltraps
80106ed8:	e9 3e f9 ff ff       	jmp    8010681b <alltraps>

80106edd <vector3>:
.globl vector3
vector3:
  pushl $0
80106edd:	6a 00                	push   $0x0
  pushl $3
80106edf:	6a 03                	push   $0x3
  jmp alltraps
80106ee1:	e9 35 f9 ff ff       	jmp    8010681b <alltraps>

80106ee6 <vector4>:
.globl vector4
vector4:
  pushl $0
80106ee6:	6a 00                	push   $0x0
  pushl $4
80106ee8:	6a 04                	push   $0x4
  jmp alltraps
80106eea:	e9 2c f9 ff ff       	jmp    8010681b <alltraps>

80106eef <vector5>:
.globl vector5
vector5:
  pushl $0
80106eef:	6a 00                	push   $0x0
  pushl $5
80106ef1:	6a 05                	push   $0x5
  jmp alltraps
80106ef3:	e9 23 f9 ff ff       	jmp    8010681b <alltraps>

80106ef8 <vector6>:
.globl vector6
vector6:
  pushl $0
80106ef8:	6a 00                	push   $0x0
  pushl $6
80106efa:	6a 06                	push   $0x6
  jmp alltraps
80106efc:	e9 1a f9 ff ff       	jmp    8010681b <alltraps>

80106f01 <vector7>:
.globl vector7
vector7:
  pushl $0
80106f01:	6a 00                	push   $0x0
  pushl $7
80106f03:	6a 07                	push   $0x7
  jmp alltraps
80106f05:	e9 11 f9 ff ff       	jmp    8010681b <alltraps>

80106f0a <vector8>:
.globl vector8
vector8:
  pushl $8
80106f0a:	6a 08                	push   $0x8
  jmp alltraps
80106f0c:	e9 0a f9 ff ff       	jmp    8010681b <alltraps>

80106f11 <vector9>:
.globl vector9
vector9:
  pushl $0
80106f11:	6a 00                	push   $0x0
  pushl $9
80106f13:	6a 09                	push   $0x9
  jmp alltraps
80106f15:	e9 01 f9 ff ff       	jmp    8010681b <alltraps>

80106f1a <vector10>:
.globl vector10
vector10:
  pushl $10
80106f1a:	6a 0a                	push   $0xa
  jmp alltraps
80106f1c:	e9 fa f8 ff ff       	jmp    8010681b <alltraps>

80106f21 <vector11>:
.globl vector11
vector11:
  pushl $11
80106f21:	6a 0b                	push   $0xb
  jmp alltraps
80106f23:	e9 f3 f8 ff ff       	jmp    8010681b <alltraps>

80106f28 <vector12>:
.globl vector12
vector12:
  pushl $12
80106f28:	6a 0c                	push   $0xc
  jmp alltraps
80106f2a:	e9 ec f8 ff ff       	jmp    8010681b <alltraps>

80106f2f <vector13>:
.globl vector13
vector13:
  pushl $13
80106f2f:	6a 0d                	push   $0xd
  jmp alltraps
80106f31:	e9 e5 f8 ff ff       	jmp    8010681b <alltraps>

80106f36 <vector14>:
.globl vector14
vector14:
  pushl $14
80106f36:	6a 0e                	push   $0xe
  jmp alltraps
80106f38:	e9 de f8 ff ff       	jmp    8010681b <alltraps>

80106f3d <vector15>:
.globl vector15
vector15:
  pushl $0
80106f3d:	6a 00                	push   $0x0
  pushl $15
80106f3f:	6a 0f                	push   $0xf
  jmp alltraps
80106f41:	e9 d5 f8 ff ff       	jmp    8010681b <alltraps>

80106f46 <vector16>:
.globl vector16
vector16:
  pushl $0
80106f46:	6a 00                	push   $0x0
  pushl $16
80106f48:	6a 10                	push   $0x10
  jmp alltraps
80106f4a:	e9 cc f8 ff ff       	jmp    8010681b <alltraps>

80106f4f <vector17>:
.globl vector17
vector17:
  pushl $17
80106f4f:	6a 11                	push   $0x11
  jmp alltraps
80106f51:	e9 c5 f8 ff ff       	jmp    8010681b <alltraps>

80106f56 <vector18>:
.globl vector18
vector18:
  pushl $0
80106f56:	6a 00                	push   $0x0
  pushl $18
80106f58:	6a 12                	push   $0x12
  jmp alltraps
80106f5a:	e9 bc f8 ff ff       	jmp    8010681b <alltraps>

80106f5f <vector19>:
.globl vector19
vector19:
  pushl $0
80106f5f:	6a 00                	push   $0x0
  pushl $19
80106f61:	6a 13                	push   $0x13
  jmp alltraps
80106f63:	e9 b3 f8 ff ff       	jmp    8010681b <alltraps>

80106f68 <vector20>:
.globl vector20
vector20:
  pushl $0
80106f68:	6a 00                	push   $0x0
  pushl $20
80106f6a:	6a 14                	push   $0x14
  jmp alltraps
80106f6c:	e9 aa f8 ff ff       	jmp    8010681b <alltraps>

80106f71 <vector21>:
.globl vector21
vector21:
  pushl $0
80106f71:	6a 00                	push   $0x0
  pushl $21
80106f73:	6a 15                	push   $0x15
  jmp alltraps
80106f75:	e9 a1 f8 ff ff       	jmp    8010681b <alltraps>

80106f7a <vector22>:
.globl vector22
vector22:
  pushl $0
80106f7a:	6a 00                	push   $0x0
  pushl $22
80106f7c:	6a 16                	push   $0x16
  jmp alltraps
80106f7e:	e9 98 f8 ff ff       	jmp    8010681b <alltraps>

80106f83 <vector23>:
.globl vector23
vector23:
  pushl $0
80106f83:	6a 00                	push   $0x0
  pushl $23
80106f85:	6a 17                	push   $0x17
  jmp alltraps
80106f87:	e9 8f f8 ff ff       	jmp    8010681b <alltraps>

80106f8c <vector24>:
.globl vector24
vector24:
  pushl $0
80106f8c:	6a 00                	push   $0x0
  pushl $24
80106f8e:	6a 18                	push   $0x18
  jmp alltraps
80106f90:	e9 86 f8 ff ff       	jmp    8010681b <alltraps>

80106f95 <vector25>:
.globl vector25
vector25:
  pushl $0
80106f95:	6a 00                	push   $0x0
  pushl $25
80106f97:	6a 19                	push   $0x19
  jmp alltraps
80106f99:	e9 7d f8 ff ff       	jmp    8010681b <alltraps>

80106f9e <vector26>:
.globl vector26
vector26:
  pushl $0
80106f9e:	6a 00                	push   $0x0
  pushl $26
80106fa0:	6a 1a                	push   $0x1a
  jmp alltraps
80106fa2:	e9 74 f8 ff ff       	jmp    8010681b <alltraps>

80106fa7 <vector27>:
.globl vector27
vector27:
  pushl $0
80106fa7:	6a 00                	push   $0x0
  pushl $27
80106fa9:	6a 1b                	push   $0x1b
  jmp alltraps
80106fab:	e9 6b f8 ff ff       	jmp    8010681b <alltraps>

80106fb0 <vector28>:
.globl vector28
vector28:
  pushl $0
80106fb0:	6a 00                	push   $0x0
  pushl $28
80106fb2:	6a 1c                	push   $0x1c
  jmp alltraps
80106fb4:	e9 62 f8 ff ff       	jmp    8010681b <alltraps>

80106fb9 <vector29>:
.globl vector29
vector29:
  pushl $0
80106fb9:	6a 00                	push   $0x0
  pushl $29
80106fbb:	6a 1d                	push   $0x1d
  jmp alltraps
80106fbd:	e9 59 f8 ff ff       	jmp    8010681b <alltraps>

80106fc2 <vector30>:
.globl vector30
vector30:
  pushl $0
80106fc2:	6a 00                	push   $0x0
  pushl $30
80106fc4:	6a 1e                	push   $0x1e
  jmp alltraps
80106fc6:	e9 50 f8 ff ff       	jmp    8010681b <alltraps>

80106fcb <vector31>:
.globl vector31
vector31:
  pushl $0
80106fcb:	6a 00                	push   $0x0
  pushl $31
80106fcd:	6a 1f                	push   $0x1f
  jmp alltraps
80106fcf:	e9 47 f8 ff ff       	jmp    8010681b <alltraps>

80106fd4 <vector32>:
.globl vector32
vector32:
  pushl $0
80106fd4:	6a 00                	push   $0x0
  pushl $32
80106fd6:	6a 20                	push   $0x20
  jmp alltraps
80106fd8:	e9 3e f8 ff ff       	jmp    8010681b <alltraps>

80106fdd <vector33>:
.globl vector33
vector33:
  pushl $0
80106fdd:	6a 00                	push   $0x0
  pushl $33
80106fdf:	6a 21                	push   $0x21
  jmp alltraps
80106fe1:	e9 35 f8 ff ff       	jmp    8010681b <alltraps>

80106fe6 <vector34>:
.globl vector34
vector34:
  pushl $0
80106fe6:	6a 00                	push   $0x0
  pushl $34
80106fe8:	6a 22                	push   $0x22
  jmp alltraps
80106fea:	e9 2c f8 ff ff       	jmp    8010681b <alltraps>

80106fef <vector35>:
.globl vector35
vector35:
  pushl $0
80106fef:	6a 00                	push   $0x0
  pushl $35
80106ff1:	6a 23                	push   $0x23
  jmp alltraps
80106ff3:	e9 23 f8 ff ff       	jmp    8010681b <alltraps>

80106ff8 <vector36>:
.globl vector36
vector36:
  pushl $0
80106ff8:	6a 00                	push   $0x0
  pushl $36
80106ffa:	6a 24                	push   $0x24
  jmp alltraps
80106ffc:	e9 1a f8 ff ff       	jmp    8010681b <alltraps>

80107001 <vector37>:
.globl vector37
vector37:
  pushl $0
80107001:	6a 00                	push   $0x0
  pushl $37
80107003:	6a 25                	push   $0x25
  jmp alltraps
80107005:	e9 11 f8 ff ff       	jmp    8010681b <alltraps>

8010700a <vector38>:
.globl vector38
vector38:
  pushl $0
8010700a:	6a 00                	push   $0x0
  pushl $38
8010700c:	6a 26                	push   $0x26
  jmp alltraps
8010700e:	e9 08 f8 ff ff       	jmp    8010681b <alltraps>

80107013 <vector39>:
.globl vector39
vector39:
  pushl $0
80107013:	6a 00                	push   $0x0
  pushl $39
80107015:	6a 27                	push   $0x27
  jmp alltraps
80107017:	e9 ff f7 ff ff       	jmp    8010681b <alltraps>

8010701c <vector40>:
.globl vector40
vector40:
  pushl $0
8010701c:	6a 00                	push   $0x0
  pushl $40
8010701e:	6a 28                	push   $0x28
  jmp alltraps
80107020:	e9 f6 f7 ff ff       	jmp    8010681b <alltraps>

80107025 <vector41>:
.globl vector41
vector41:
  pushl $0
80107025:	6a 00                	push   $0x0
  pushl $41
80107027:	6a 29                	push   $0x29
  jmp alltraps
80107029:	e9 ed f7 ff ff       	jmp    8010681b <alltraps>

8010702e <vector42>:
.globl vector42
vector42:
  pushl $0
8010702e:	6a 00                	push   $0x0
  pushl $42
80107030:	6a 2a                	push   $0x2a
  jmp alltraps
80107032:	e9 e4 f7 ff ff       	jmp    8010681b <alltraps>

80107037 <vector43>:
.globl vector43
vector43:
  pushl $0
80107037:	6a 00                	push   $0x0
  pushl $43
80107039:	6a 2b                	push   $0x2b
  jmp alltraps
8010703b:	e9 db f7 ff ff       	jmp    8010681b <alltraps>

80107040 <vector44>:
.globl vector44
vector44:
  pushl $0
80107040:	6a 00                	push   $0x0
  pushl $44
80107042:	6a 2c                	push   $0x2c
  jmp alltraps
80107044:	e9 d2 f7 ff ff       	jmp    8010681b <alltraps>

80107049 <vector45>:
.globl vector45
vector45:
  pushl $0
80107049:	6a 00                	push   $0x0
  pushl $45
8010704b:	6a 2d                	push   $0x2d
  jmp alltraps
8010704d:	e9 c9 f7 ff ff       	jmp    8010681b <alltraps>

80107052 <vector46>:
.globl vector46
vector46:
  pushl $0
80107052:	6a 00                	push   $0x0
  pushl $46
80107054:	6a 2e                	push   $0x2e
  jmp alltraps
80107056:	e9 c0 f7 ff ff       	jmp    8010681b <alltraps>

8010705b <vector47>:
.globl vector47
vector47:
  pushl $0
8010705b:	6a 00                	push   $0x0
  pushl $47
8010705d:	6a 2f                	push   $0x2f
  jmp alltraps
8010705f:	e9 b7 f7 ff ff       	jmp    8010681b <alltraps>

80107064 <vector48>:
.globl vector48
vector48:
  pushl $0
80107064:	6a 00                	push   $0x0
  pushl $48
80107066:	6a 30                	push   $0x30
  jmp alltraps
80107068:	e9 ae f7 ff ff       	jmp    8010681b <alltraps>

8010706d <vector49>:
.globl vector49
vector49:
  pushl $0
8010706d:	6a 00                	push   $0x0
  pushl $49
8010706f:	6a 31                	push   $0x31
  jmp alltraps
80107071:	e9 a5 f7 ff ff       	jmp    8010681b <alltraps>

80107076 <vector50>:
.globl vector50
vector50:
  pushl $0
80107076:	6a 00                	push   $0x0
  pushl $50
80107078:	6a 32                	push   $0x32
  jmp alltraps
8010707a:	e9 9c f7 ff ff       	jmp    8010681b <alltraps>

8010707f <vector51>:
.globl vector51
vector51:
  pushl $0
8010707f:	6a 00                	push   $0x0
  pushl $51
80107081:	6a 33                	push   $0x33
  jmp alltraps
80107083:	e9 93 f7 ff ff       	jmp    8010681b <alltraps>

80107088 <vector52>:
.globl vector52
vector52:
  pushl $0
80107088:	6a 00                	push   $0x0
  pushl $52
8010708a:	6a 34                	push   $0x34
  jmp alltraps
8010708c:	e9 8a f7 ff ff       	jmp    8010681b <alltraps>

80107091 <vector53>:
.globl vector53
vector53:
  pushl $0
80107091:	6a 00                	push   $0x0
  pushl $53
80107093:	6a 35                	push   $0x35
  jmp alltraps
80107095:	e9 81 f7 ff ff       	jmp    8010681b <alltraps>

8010709a <vector54>:
.globl vector54
vector54:
  pushl $0
8010709a:	6a 00                	push   $0x0
  pushl $54
8010709c:	6a 36                	push   $0x36
  jmp alltraps
8010709e:	e9 78 f7 ff ff       	jmp    8010681b <alltraps>

801070a3 <vector55>:
.globl vector55
vector55:
  pushl $0
801070a3:	6a 00                	push   $0x0
  pushl $55
801070a5:	6a 37                	push   $0x37
  jmp alltraps
801070a7:	e9 6f f7 ff ff       	jmp    8010681b <alltraps>

801070ac <vector56>:
.globl vector56
vector56:
  pushl $0
801070ac:	6a 00                	push   $0x0
  pushl $56
801070ae:	6a 38                	push   $0x38
  jmp alltraps
801070b0:	e9 66 f7 ff ff       	jmp    8010681b <alltraps>

801070b5 <vector57>:
.globl vector57
vector57:
  pushl $0
801070b5:	6a 00                	push   $0x0
  pushl $57
801070b7:	6a 39                	push   $0x39
  jmp alltraps
801070b9:	e9 5d f7 ff ff       	jmp    8010681b <alltraps>

801070be <vector58>:
.globl vector58
vector58:
  pushl $0
801070be:	6a 00                	push   $0x0
  pushl $58
801070c0:	6a 3a                	push   $0x3a
  jmp alltraps
801070c2:	e9 54 f7 ff ff       	jmp    8010681b <alltraps>

801070c7 <vector59>:
.globl vector59
vector59:
  pushl $0
801070c7:	6a 00                	push   $0x0
  pushl $59
801070c9:	6a 3b                	push   $0x3b
  jmp alltraps
801070cb:	e9 4b f7 ff ff       	jmp    8010681b <alltraps>

801070d0 <vector60>:
.globl vector60
vector60:
  pushl $0
801070d0:	6a 00                	push   $0x0
  pushl $60
801070d2:	6a 3c                	push   $0x3c
  jmp alltraps
801070d4:	e9 42 f7 ff ff       	jmp    8010681b <alltraps>

801070d9 <vector61>:
.globl vector61
vector61:
  pushl $0
801070d9:	6a 00                	push   $0x0
  pushl $61
801070db:	6a 3d                	push   $0x3d
  jmp alltraps
801070dd:	e9 39 f7 ff ff       	jmp    8010681b <alltraps>

801070e2 <vector62>:
.globl vector62
vector62:
  pushl $0
801070e2:	6a 00                	push   $0x0
  pushl $62
801070e4:	6a 3e                	push   $0x3e
  jmp alltraps
801070e6:	e9 30 f7 ff ff       	jmp    8010681b <alltraps>

801070eb <vector63>:
.globl vector63
vector63:
  pushl $0
801070eb:	6a 00                	push   $0x0
  pushl $63
801070ed:	6a 3f                	push   $0x3f
  jmp alltraps
801070ef:	e9 27 f7 ff ff       	jmp    8010681b <alltraps>

801070f4 <vector64>:
.globl vector64
vector64:
  pushl $0
801070f4:	6a 00                	push   $0x0
  pushl $64
801070f6:	6a 40                	push   $0x40
  jmp alltraps
801070f8:	e9 1e f7 ff ff       	jmp    8010681b <alltraps>

801070fd <vector65>:
.globl vector65
vector65:
  pushl $0
801070fd:	6a 00                	push   $0x0
  pushl $65
801070ff:	6a 41                	push   $0x41
  jmp alltraps
80107101:	e9 15 f7 ff ff       	jmp    8010681b <alltraps>

80107106 <vector66>:
.globl vector66
vector66:
  pushl $0
80107106:	6a 00                	push   $0x0
  pushl $66
80107108:	6a 42                	push   $0x42
  jmp alltraps
8010710a:	e9 0c f7 ff ff       	jmp    8010681b <alltraps>

8010710f <vector67>:
.globl vector67
vector67:
  pushl $0
8010710f:	6a 00                	push   $0x0
  pushl $67
80107111:	6a 43                	push   $0x43
  jmp alltraps
80107113:	e9 03 f7 ff ff       	jmp    8010681b <alltraps>

80107118 <vector68>:
.globl vector68
vector68:
  pushl $0
80107118:	6a 00                	push   $0x0
  pushl $68
8010711a:	6a 44                	push   $0x44
  jmp alltraps
8010711c:	e9 fa f6 ff ff       	jmp    8010681b <alltraps>

80107121 <vector69>:
.globl vector69
vector69:
  pushl $0
80107121:	6a 00                	push   $0x0
  pushl $69
80107123:	6a 45                	push   $0x45
  jmp alltraps
80107125:	e9 f1 f6 ff ff       	jmp    8010681b <alltraps>

8010712a <vector70>:
.globl vector70
vector70:
  pushl $0
8010712a:	6a 00                	push   $0x0
  pushl $70
8010712c:	6a 46                	push   $0x46
  jmp alltraps
8010712e:	e9 e8 f6 ff ff       	jmp    8010681b <alltraps>

80107133 <vector71>:
.globl vector71
vector71:
  pushl $0
80107133:	6a 00                	push   $0x0
  pushl $71
80107135:	6a 47                	push   $0x47
  jmp alltraps
80107137:	e9 df f6 ff ff       	jmp    8010681b <alltraps>

8010713c <vector72>:
.globl vector72
vector72:
  pushl $0
8010713c:	6a 00                	push   $0x0
  pushl $72
8010713e:	6a 48                	push   $0x48
  jmp alltraps
80107140:	e9 d6 f6 ff ff       	jmp    8010681b <alltraps>

80107145 <vector73>:
.globl vector73
vector73:
  pushl $0
80107145:	6a 00                	push   $0x0
  pushl $73
80107147:	6a 49                	push   $0x49
  jmp alltraps
80107149:	e9 cd f6 ff ff       	jmp    8010681b <alltraps>

8010714e <vector74>:
.globl vector74
vector74:
  pushl $0
8010714e:	6a 00                	push   $0x0
  pushl $74
80107150:	6a 4a                	push   $0x4a
  jmp alltraps
80107152:	e9 c4 f6 ff ff       	jmp    8010681b <alltraps>

80107157 <vector75>:
.globl vector75
vector75:
  pushl $0
80107157:	6a 00                	push   $0x0
  pushl $75
80107159:	6a 4b                	push   $0x4b
  jmp alltraps
8010715b:	e9 bb f6 ff ff       	jmp    8010681b <alltraps>

80107160 <vector76>:
.globl vector76
vector76:
  pushl $0
80107160:	6a 00                	push   $0x0
  pushl $76
80107162:	6a 4c                	push   $0x4c
  jmp alltraps
80107164:	e9 b2 f6 ff ff       	jmp    8010681b <alltraps>

80107169 <vector77>:
.globl vector77
vector77:
  pushl $0
80107169:	6a 00                	push   $0x0
  pushl $77
8010716b:	6a 4d                	push   $0x4d
  jmp alltraps
8010716d:	e9 a9 f6 ff ff       	jmp    8010681b <alltraps>

80107172 <vector78>:
.globl vector78
vector78:
  pushl $0
80107172:	6a 00                	push   $0x0
  pushl $78
80107174:	6a 4e                	push   $0x4e
  jmp alltraps
80107176:	e9 a0 f6 ff ff       	jmp    8010681b <alltraps>

8010717b <vector79>:
.globl vector79
vector79:
  pushl $0
8010717b:	6a 00                	push   $0x0
  pushl $79
8010717d:	6a 4f                	push   $0x4f
  jmp alltraps
8010717f:	e9 97 f6 ff ff       	jmp    8010681b <alltraps>

80107184 <vector80>:
.globl vector80
vector80:
  pushl $0
80107184:	6a 00                	push   $0x0
  pushl $80
80107186:	6a 50                	push   $0x50
  jmp alltraps
80107188:	e9 8e f6 ff ff       	jmp    8010681b <alltraps>

8010718d <vector81>:
.globl vector81
vector81:
  pushl $0
8010718d:	6a 00                	push   $0x0
  pushl $81
8010718f:	6a 51                	push   $0x51
  jmp alltraps
80107191:	e9 85 f6 ff ff       	jmp    8010681b <alltraps>

80107196 <vector82>:
.globl vector82
vector82:
  pushl $0
80107196:	6a 00                	push   $0x0
  pushl $82
80107198:	6a 52                	push   $0x52
  jmp alltraps
8010719a:	e9 7c f6 ff ff       	jmp    8010681b <alltraps>

8010719f <vector83>:
.globl vector83
vector83:
  pushl $0
8010719f:	6a 00                	push   $0x0
  pushl $83
801071a1:	6a 53                	push   $0x53
  jmp alltraps
801071a3:	e9 73 f6 ff ff       	jmp    8010681b <alltraps>

801071a8 <vector84>:
.globl vector84
vector84:
  pushl $0
801071a8:	6a 00                	push   $0x0
  pushl $84
801071aa:	6a 54                	push   $0x54
  jmp alltraps
801071ac:	e9 6a f6 ff ff       	jmp    8010681b <alltraps>

801071b1 <vector85>:
.globl vector85
vector85:
  pushl $0
801071b1:	6a 00                	push   $0x0
  pushl $85
801071b3:	6a 55                	push   $0x55
  jmp alltraps
801071b5:	e9 61 f6 ff ff       	jmp    8010681b <alltraps>

801071ba <vector86>:
.globl vector86
vector86:
  pushl $0
801071ba:	6a 00                	push   $0x0
  pushl $86
801071bc:	6a 56                	push   $0x56
  jmp alltraps
801071be:	e9 58 f6 ff ff       	jmp    8010681b <alltraps>

801071c3 <vector87>:
.globl vector87
vector87:
  pushl $0
801071c3:	6a 00                	push   $0x0
  pushl $87
801071c5:	6a 57                	push   $0x57
  jmp alltraps
801071c7:	e9 4f f6 ff ff       	jmp    8010681b <alltraps>

801071cc <vector88>:
.globl vector88
vector88:
  pushl $0
801071cc:	6a 00                	push   $0x0
  pushl $88
801071ce:	6a 58                	push   $0x58
  jmp alltraps
801071d0:	e9 46 f6 ff ff       	jmp    8010681b <alltraps>

801071d5 <vector89>:
.globl vector89
vector89:
  pushl $0
801071d5:	6a 00                	push   $0x0
  pushl $89
801071d7:	6a 59                	push   $0x59
  jmp alltraps
801071d9:	e9 3d f6 ff ff       	jmp    8010681b <alltraps>

801071de <vector90>:
.globl vector90
vector90:
  pushl $0
801071de:	6a 00                	push   $0x0
  pushl $90
801071e0:	6a 5a                	push   $0x5a
  jmp alltraps
801071e2:	e9 34 f6 ff ff       	jmp    8010681b <alltraps>

801071e7 <vector91>:
.globl vector91
vector91:
  pushl $0
801071e7:	6a 00                	push   $0x0
  pushl $91
801071e9:	6a 5b                	push   $0x5b
  jmp alltraps
801071eb:	e9 2b f6 ff ff       	jmp    8010681b <alltraps>

801071f0 <vector92>:
.globl vector92
vector92:
  pushl $0
801071f0:	6a 00                	push   $0x0
  pushl $92
801071f2:	6a 5c                	push   $0x5c
  jmp alltraps
801071f4:	e9 22 f6 ff ff       	jmp    8010681b <alltraps>

801071f9 <vector93>:
.globl vector93
vector93:
  pushl $0
801071f9:	6a 00                	push   $0x0
  pushl $93
801071fb:	6a 5d                	push   $0x5d
  jmp alltraps
801071fd:	e9 19 f6 ff ff       	jmp    8010681b <alltraps>

80107202 <vector94>:
.globl vector94
vector94:
  pushl $0
80107202:	6a 00                	push   $0x0
  pushl $94
80107204:	6a 5e                	push   $0x5e
  jmp alltraps
80107206:	e9 10 f6 ff ff       	jmp    8010681b <alltraps>

8010720b <vector95>:
.globl vector95
vector95:
  pushl $0
8010720b:	6a 00                	push   $0x0
  pushl $95
8010720d:	6a 5f                	push   $0x5f
  jmp alltraps
8010720f:	e9 07 f6 ff ff       	jmp    8010681b <alltraps>

80107214 <vector96>:
.globl vector96
vector96:
  pushl $0
80107214:	6a 00                	push   $0x0
  pushl $96
80107216:	6a 60                	push   $0x60
  jmp alltraps
80107218:	e9 fe f5 ff ff       	jmp    8010681b <alltraps>

8010721d <vector97>:
.globl vector97
vector97:
  pushl $0
8010721d:	6a 00                	push   $0x0
  pushl $97
8010721f:	6a 61                	push   $0x61
  jmp alltraps
80107221:	e9 f5 f5 ff ff       	jmp    8010681b <alltraps>

80107226 <vector98>:
.globl vector98
vector98:
  pushl $0
80107226:	6a 00                	push   $0x0
  pushl $98
80107228:	6a 62                	push   $0x62
  jmp alltraps
8010722a:	e9 ec f5 ff ff       	jmp    8010681b <alltraps>

8010722f <vector99>:
.globl vector99
vector99:
  pushl $0
8010722f:	6a 00                	push   $0x0
  pushl $99
80107231:	6a 63                	push   $0x63
  jmp alltraps
80107233:	e9 e3 f5 ff ff       	jmp    8010681b <alltraps>

80107238 <vector100>:
.globl vector100
vector100:
  pushl $0
80107238:	6a 00                	push   $0x0
  pushl $100
8010723a:	6a 64                	push   $0x64
  jmp alltraps
8010723c:	e9 da f5 ff ff       	jmp    8010681b <alltraps>

80107241 <vector101>:
.globl vector101
vector101:
  pushl $0
80107241:	6a 00                	push   $0x0
  pushl $101
80107243:	6a 65                	push   $0x65
  jmp alltraps
80107245:	e9 d1 f5 ff ff       	jmp    8010681b <alltraps>

8010724a <vector102>:
.globl vector102
vector102:
  pushl $0
8010724a:	6a 00                	push   $0x0
  pushl $102
8010724c:	6a 66                	push   $0x66
  jmp alltraps
8010724e:	e9 c8 f5 ff ff       	jmp    8010681b <alltraps>

80107253 <vector103>:
.globl vector103
vector103:
  pushl $0
80107253:	6a 00                	push   $0x0
  pushl $103
80107255:	6a 67                	push   $0x67
  jmp alltraps
80107257:	e9 bf f5 ff ff       	jmp    8010681b <alltraps>

8010725c <vector104>:
.globl vector104
vector104:
  pushl $0
8010725c:	6a 00                	push   $0x0
  pushl $104
8010725e:	6a 68                	push   $0x68
  jmp alltraps
80107260:	e9 b6 f5 ff ff       	jmp    8010681b <alltraps>

80107265 <vector105>:
.globl vector105
vector105:
  pushl $0
80107265:	6a 00                	push   $0x0
  pushl $105
80107267:	6a 69                	push   $0x69
  jmp alltraps
80107269:	e9 ad f5 ff ff       	jmp    8010681b <alltraps>

8010726e <vector106>:
.globl vector106
vector106:
  pushl $0
8010726e:	6a 00                	push   $0x0
  pushl $106
80107270:	6a 6a                	push   $0x6a
  jmp alltraps
80107272:	e9 a4 f5 ff ff       	jmp    8010681b <alltraps>

80107277 <vector107>:
.globl vector107
vector107:
  pushl $0
80107277:	6a 00                	push   $0x0
  pushl $107
80107279:	6a 6b                	push   $0x6b
  jmp alltraps
8010727b:	e9 9b f5 ff ff       	jmp    8010681b <alltraps>

80107280 <vector108>:
.globl vector108
vector108:
  pushl $0
80107280:	6a 00                	push   $0x0
  pushl $108
80107282:	6a 6c                	push   $0x6c
  jmp alltraps
80107284:	e9 92 f5 ff ff       	jmp    8010681b <alltraps>

80107289 <vector109>:
.globl vector109
vector109:
  pushl $0
80107289:	6a 00                	push   $0x0
  pushl $109
8010728b:	6a 6d                	push   $0x6d
  jmp alltraps
8010728d:	e9 89 f5 ff ff       	jmp    8010681b <alltraps>

80107292 <vector110>:
.globl vector110
vector110:
  pushl $0
80107292:	6a 00                	push   $0x0
  pushl $110
80107294:	6a 6e                	push   $0x6e
  jmp alltraps
80107296:	e9 80 f5 ff ff       	jmp    8010681b <alltraps>

8010729b <vector111>:
.globl vector111
vector111:
  pushl $0
8010729b:	6a 00                	push   $0x0
  pushl $111
8010729d:	6a 6f                	push   $0x6f
  jmp alltraps
8010729f:	e9 77 f5 ff ff       	jmp    8010681b <alltraps>

801072a4 <vector112>:
.globl vector112
vector112:
  pushl $0
801072a4:	6a 00                	push   $0x0
  pushl $112
801072a6:	6a 70                	push   $0x70
  jmp alltraps
801072a8:	e9 6e f5 ff ff       	jmp    8010681b <alltraps>

801072ad <vector113>:
.globl vector113
vector113:
  pushl $0
801072ad:	6a 00                	push   $0x0
  pushl $113
801072af:	6a 71                	push   $0x71
  jmp alltraps
801072b1:	e9 65 f5 ff ff       	jmp    8010681b <alltraps>

801072b6 <vector114>:
.globl vector114
vector114:
  pushl $0
801072b6:	6a 00                	push   $0x0
  pushl $114
801072b8:	6a 72                	push   $0x72
  jmp alltraps
801072ba:	e9 5c f5 ff ff       	jmp    8010681b <alltraps>

801072bf <vector115>:
.globl vector115
vector115:
  pushl $0
801072bf:	6a 00                	push   $0x0
  pushl $115
801072c1:	6a 73                	push   $0x73
  jmp alltraps
801072c3:	e9 53 f5 ff ff       	jmp    8010681b <alltraps>

801072c8 <vector116>:
.globl vector116
vector116:
  pushl $0
801072c8:	6a 00                	push   $0x0
  pushl $116
801072ca:	6a 74                	push   $0x74
  jmp alltraps
801072cc:	e9 4a f5 ff ff       	jmp    8010681b <alltraps>

801072d1 <vector117>:
.globl vector117
vector117:
  pushl $0
801072d1:	6a 00                	push   $0x0
  pushl $117
801072d3:	6a 75                	push   $0x75
  jmp alltraps
801072d5:	e9 41 f5 ff ff       	jmp    8010681b <alltraps>

801072da <vector118>:
.globl vector118
vector118:
  pushl $0
801072da:	6a 00                	push   $0x0
  pushl $118
801072dc:	6a 76                	push   $0x76
  jmp alltraps
801072de:	e9 38 f5 ff ff       	jmp    8010681b <alltraps>

801072e3 <vector119>:
.globl vector119
vector119:
  pushl $0
801072e3:	6a 00                	push   $0x0
  pushl $119
801072e5:	6a 77                	push   $0x77
  jmp alltraps
801072e7:	e9 2f f5 ff ff       	jmp    8010681b <alltraps>

801072ec <vector120>:
.globl vector120
vector120:
  pushl $0
801072ec:	6a 00                	push   $0x0
  pushl $120
801072ee:	6a 78                	push   $0x78
  jmp alltraps
801072f0:	e9 26 f5 ff ff       	jmp    8010681b <alltraps>

801072f5 <vector121>:
.globl vector121
vector121:
  pushl $0
801072f5:	6a 00                	push   $0x0
  pushl $121
801072f7:	6a 79                	push   $0x79
  jmp alltraps
801072f9:	e9 1d f5 ff ff       	jmp    8010681b <alltraps>

801072fe <vector122>:
.globl vector122
vector122:
  pushl $0
801072fe:	6a 00                	push   $0x0
  pushl $122
80107300:	6a 7a                	push   $0x7a
  jmp alltraps
80107302:	e9 14 f5 ff ff       	jmp    8010681b <alltraps>

80107307 <vector123>:
.globl vector123
vector123:
  pushl $0
80107307:	6a 00                	push   $0x0
  pushl $123
80107309:	6a 7b                	push   $0x7b
  jmp alltraps
8010730b:	e9 0b f5 ff ff       	jmp    8010681b <alltraps>

80107310 <vector124>:
.globl vector124
vector124:
  pushl $0
80107310:	6a 00                	push   $0x0
  pushl $124
80107312:	6a 7c                	push   $0x7c
  jmp alltraps
80107314:	e9 02 f5 ff ff       	jmp    8010681b <alltraps>

80107319 <vector125>:
.globl vector125
vector125:
  pushl $0
80107319:	6a 00                	push   $0x0
  pushl $125
8010731b:	6a 7d                	push   $0x7d
  jmp alltraps
8010731d:	e9 f9 f4 ff ff       	jmp    8010681b <alltraps>

80107322 <vector126>:
.globl vector126
vector126:
  pushl $0
80107322:	6a 00                	push   $0x0
  pushl $126
80107324:	6a 7e                	push   $0x7e
  jmp alltraps
80107326:	e9 f0 f4 ff ff       	jmp    8010681b <alltraps>

8010732b <vector127>:
.globl vector127
vector127:
  pushl $0
8010732b:	6a 00                	push   $0x0
  pushl $127
8010732d:	6a 7f                	push   $0x7f
  jmp alltraps
8010732f:	e9 e7 f4 ff ff       	jmp    8010681b <alltraps>

80107334 <vector128>:
.globl vector128
vector128:
  pushl $0
80107334:	6a 00                	push   $0x0
  pushl $128
80107336:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010733b:	e9 db f4 ff ff       	jmp    8010681b <alltraps>

80107340 <vector129>:
.globl vector129
vector129:
  pushl $0
80107340:	6a 00                	push   $0x0
  pushl $129
80107342:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80107347:	e9 cf f4 ff ff       	jmp    8010681b <alltraps>

8010734c <vector130>:
.globl vector130
vector130:
  pushl $0
8010734c:	6a 00                	push   $0x0
  pushl $130
8010734e:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80107353:	e9 c3 f4 ff ff       	jmp    8010681b <alltraps>

80107358 <vector131>:
.globl vector131
vector131:
  pushl $0
80107358:	6a 00                	push   $0x0
  pushl $131
8010735a:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010735f:	e9 b7 f4 ff ff       	jmp    8010681b <alltraps>

80107364 <vector132>:
.globl vector132
vector132:
  pushl $0
80107364:	6a 00                	push   $0x0
  pushl $132
80107366:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010736b:	e9 ab f4 ff ff       	jmp    8010681b <alltraps>

80107370 <vector133>:
.globl vector133
vector133:
  pushl $0
80107370:	6a 00                	push   $0x0
  pushl $133
80107372:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80107377:	e9 9f f4 ff ff       	jmp    8010681b <alltraps>

8010737c <vector134>:
.globl vector134
vector134:
  pushl $0
8010737c:	6a 00                	push   $0x0
  pushl $134
8010737e:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80107383:	e9 93 f4 ff ff       	jmp    8010681b <alltraps>

80107388 <vector135>:
.globl vector135
vector135:
  pushl $0
80107388:	6a 00                	push   $0x0
  pushl $135
8010738a:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010738f:	e9 87 f4 ff ff       	jmp    8010681b <alltraps>

80107394 <vector136>:
.globl vector136
vector136:
  pushl $0
80107394:	6a 00                	push   $0x0
  pushl $136
80107396:	68 88 00 00 00       	push   $0x88
  jmp alltraps
8010739b:	e9 7b f4 ff ff       	jmp    8010681b <alltraps>

801073a0 <vector137>:
.globl vector137
vector137:
  pushl $0
801073a0:	6a 00                	push   $0x0
  pushl $137
801073a2:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801073a7:	e9 6f f4 ff ff       	jmp    8010681b <alltraps>

801073ac <vector138>:
.globl vector138
vector138:
  pushl $0
801073ac:	6a 00                	push   $0x0
  pushl $138
801073ae:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801073b3:	e9 63 f4 ff ff       	jmp    8010681b <alltraps>

801073b8 <vector139>:
.globl vector139
vector139:
  pushl $0
801073b8:	6a 00                	push   $0x0
  pushl $139
801073ba:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801073bf:	e9 57 f4 ff ff       	jmp    8010681b <alltraps>

801073c4 <vector140>:
.globl vector140
vector140:
  pushl $0
801073c4:	6a 00                	push   $0x0
  pushl $140
801073c6:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801073cb:	e9 4b f4 ff ff       	jmp    8010681b <alltraps>

801073d0 <vector141>:
.globl vector141
vector141:
  pushl $0
801073d0:	6a 00                	push   $0x0
  pushl $141
801073d2:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801073d7:	e9 3f f4 ff ff       	jmp    8010681b <alltraps>

801073dc <vector142>:
.globl vector142
vector142:
  pushl $0
801073dc:	6a 00                	push   $0x0
  pushl $142
801073de:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801073e3:	e9 33 f4 ff ff       	jmp    8010681b <alltraps>

801073e8 <vector143>:
.globl vector143
vector143:
  pushl $0
801073e8:	6a 00                	push   $0x0
  pushl $143
801073ea:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
801073ef:	e9 27 f4 ff ff       	jmp    8010681b <alltraps>

801073f4 <vector144>:
.globl vector144
vector144:
  pushl $0
801073f4:	6a 00                	push   $0x0
  pushl $144
801073f6:	68 90 00 00 00       	push   $0x90
  jmp alltraps
801073fb:	e9 1b f4 ff ff       	jmp    8010681b <alltraps>

80107400 <vector145>:
.globl vector145
vector145:
  pushl $0
80107400:	6a 00                	push   $0x0
  pushl $145
80107402:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80107407:	e9 0f f4 ff ff       	jmp    8010681b <alltraps>

8010740c <vector146>:
.globl vector146
vector146:
  pushl $0
8010740c:	6a 00                	push   $0x0
  pushl $146
8010740e:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80107413:	e9 03 f4 ff ff       	jmp    8010681b <alltraps>

80107418 <vector147>:
.globl vector147
vector147:
  pushl $0
80107418:	6a 00                	push   $0x0
  pushl $147
8010741a:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010741f:	e9 f7 f3 ff ff       	jmp    8010681b <alltraps>

80107424 <vector148>:
.globl vector148
vector148:
  pushl $0
80107424:	6a 00                	push   $0x0
  pushl $148
80107426:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010742b:	e9 eb f3 ff ff       	jmp    8010681b <alltraps>

80107430 <vector149>:
.globl vector149
vector149:
  pushl $0
80107430:	6a 00                	push   $0x0
  pushl $149
80107432:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80107437:	e9 df f3 ff ff       	jmp    8010681b <alltraps>

8010743c <vector150>:
.globl vector150
vector150:
  pushl $0
8010743c:	6a 00                	push   $0x0
  pushl $150
8010743e:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80107443:	e9 d3 f3 ff ff       	jmp    8010681b <alltraps>

80107448 <vector151>:
.globl vector151
vector151:
  pushl $0
80107448:	6a 00                	push   $0x0
  pushl $151
8010744a:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010744f:	e9 c7 f3 ff ff       	jmp    8010681b <alltraps>

80107454 <vector152>:
.globl vector152
vector152:
  pushl $0
80107454:	6a 00                	push   $0x0
  pushl $152
80107456:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010745b:	e9 bb f3 ff ff       	jmp    8010681b <alltraps>

80107460 <vector153>:
.globl vector153
vector153:
  pushl $0
80107460:	6a 00                	push   $0x0
  pushl $153
80107462:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80107467:	e9 af f3 ff ff       	jmp    8010681b <alltraps>

8010746c <vector154>:
.globl vector154
vector154:
  pushl $0
8010746c:	6a 00                	push   $0x0
  pushl $154
8010746e:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80107473:	e9 a3 f3 ff ff       	jmp    8010681b <alltraps>

80107478 <vector155>:
.globl vector155
vector155:
  pushl $0
80107478:	6a 00                	push   $0x0
  pushl $155
8010747a:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010747f:	e9 97 f3 ff ff       	jmp    8010681b <alltraps>

80107484 <vector156>:
.globl vector156
vector156:
  pushl $0
80107484:	6a 00                	push   $0x0
  pushl $156
80107486:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010748b:	e9 8b f3 ff ff       	jmp    8010681b <alltraps>

80107490 <vector157>:
.globl vector157
vector157:
  pushl $0
80107490:	6a 00                	push   $0x0
  pushl $157
80107492:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80107497:	e9 7f f3 ff ff       	jmp    8010681b <alltraps>

8010749c <vector158>:
.globl vector158
vector158:
  pushl $0
8010749c:	6a 00                	push   $0x0
  pushl $158
8010749e:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801074a3:	e9 73 f3 ff ff       	jmp    8010681b <alltraps>

801074a8 <vector159>:
.globl vector159
vector159:
  pushl $0
801074a8:	6a 00                	push   $0x0
  pushl $159
801074aa:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801074af:	e9 67 f3 ff ff       	jmp    8010681b <alltraps>

801074b4 <vector160>:
.globl vector160
vector160:
  pushl $0
801074b4:	6a 00                	push   $0x0
  pushl $160
801074b6:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801074bb:	e9 5b f3 ff ff       	jmp    8010681b <alltraps>

801074c0 <vector161>:
.globl vector161
vector161:
  pushl $0
801074c0:	6a 00                	push   $0x0
  pushl $161
801074c2:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801074c7:	e9 4f f3 ff ff       	jmp    8010681b <alltraps>

801074cc <vector162>:
.globl vector162
vector162:
  pushl $0
801074cc:	6a 00                	push   $0x0
  pushl $162
801074ce:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801074d3:	e9 43 f3 ff ff       	jmp    8010681b <alltraps>

801074d8 <vector163>:
.globl vector163
vector163:
  pushl $0
801074d8:	6a 00                	push   $0x0
  pushl $163
801074da:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801074df:	e9 37 f3 ff ff       	jmp    8010681b <alltraps>

801074e4 <vector164>:
.globl vector164
vector164:
  pushl $0
801074e4:	6a 00                	push   $0x0
  pushl $164
801074e6:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801074eb:	e9 2b f3 ff ff       	jmp    8010681b <alltraps>

801074f0 <vector165>:
.globl vector165
vector165:
  pushl $0
801074f0:	6a 00                	push   $0x0
  pushl $165
801074f2:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
801074f7:	e9 1f f3 ff ff       	jmp    8010681b <alltraps>

801074fc <vector166>:
.globl vector166
vector166:
  pushl $0
801074fc:	6a 00                	push   $0x0
  pushl $166
801074fe:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80107503:	e9 13 f3 ff ff       	jmp    8010681b <alltraps>

80107508 <vector167>:
.globl vector167
vector167:
  pushl $0
80107508:	6a 00                	push   $0x0
  pushl $167
8010750a:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010750f:	e9 07 f3 ff ff       	jmp    8010681b <alltraps>

80107514 <vector168>:
.globl vector168
vector168:
  pushl $0
80107514:	6a 00                	push   $0x0
  pushl $168
80107516:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010751b:	e9 fb f2 ff ff       	jmp    8010681b <alltraps>

80107520 <vector169>:
.globl vector169
vector169:
  pushl $0
80107520:	6a 00                	push   $0x0
  pushl $169
80107522:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80107527:	e9 ef f2 ff ff       	jmp    8010681b <alltraps>

8010752c <vector170>:
.globl vector170
vector170:
  pushl $0
8010752c:	6a 00                	push   $0x0
  pushl $170
8010752e:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80107533:	e9 e3 f2 ff ff       	jmp    8010681b <alltraps>

80107538 <vector171>:
.globl vector171
vector171:
  pushl $0
80107538:	6a 00                	push   $0x0
  pushl $171
8010753a:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010753f:	e9 d7 f2 ff ff       	jmp    8010681b <alltraps>

80107544 <vector172>:
.globl vector172
vector172:
  pushl $0
80107544:	6a 00                	push   $0x0
  pushl $172
80107546:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010754b:	e9 cb f2 ff ff       	jmp    8010681b <alltraps>

80107550 <vector173>:
.globl vector173
vector173:
  pushl $0
80107550:	6a 00                	push   $0x0
  pushl $173
80107552:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80107557:	e9 bf f2 ff ff       	jmp    8010681b <alltraps>

8010755c <vector174>:
.globl vector174
vector174:
  pushl $0
8010755c:	6a 00                	push   $0x0
  pushl $174
8010755e:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80107563:	e9 b3 f2 ff ff       	jmp    8010681b <alltraps>

80107568 <vector175>:
.globl vector175
vector175:
  pushl $0
80107568:	6a 00                	push   $0x0
  pushl $175
8010756a:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010756f:	e9 a7 f2 ff ff       	jmp    8010681b <alltraps>

80107574 <vector176>:
.globl vector176
vector176:
  pushl $0
80107574:	6a 00                	push   $0x0
  pushl $176
80107576:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010757b:	e9 9b f2 ff ff       	jmp    8010681b <alltraps>

80107580 <vector177>:
.globl vector177
vector177:
  pushl $0
80107580:	6a 00                	push   $0x0
  pushl $177
80107582:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80107587:	e9 8f f2 ff ff       	jmp    8010681b <alltraps>

8010758c <vector178>:
.globl vector178
vector178:
  pushl $0
8010758c:	6a 00                	push   $0x0
  pushl $178
8010758e:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80107593:	e9 83 f2 ff ff       	jmp    8010681b <alltraps>

80107598 <vector179>:
.globl vector179
vector179:
  pushl $0
80107598:	6a 00                	push   $0x0
  pushl $179
8010759a:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
8010759f:	e9 77 f2 ff ff       	jmp    8010681b <alltraps>

801075a4 <vector180>:
.globl vector180
vector180:
  pushl $0
801075a4:	6a 00                	push   $0x0
  pushl $180
801075a6:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801075ab:	e9 6b f2 ff ff       	jmp    8010681b <alltraps>

801075b0 <vector181>:
.globl vector181
vector181:
  pushl $0
801075b0:	6a 00                	push   $0x0
  pushl $181
801075b2:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801075b7:	e9 5f f2 ff ff       	jmp    8010681b <alltraps>

801075bc <vector182>:
.globl vector182
vector182:
  pushl $0
801075bc:	6a 00                	push   $0x0
  pushl $182
801075be:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801075c3:	e9 53 f2 ff ff       	jmp    8010681b <alltraps>

801075c8 <vector183>:
.globl vector183
vector183:
  pushl $0
801075c8:	6a 00                	push   $0x0
  pushl $183
801075ca:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801075cf:	e9 47 f2 ff ff       	jmp    8010681b <alltraps>

801075d4 <vector184>:
.globl vector184
vector184:
  pushl $0
801075d4:	6a 00                	push   $0x0
  pushl $184
801075d6:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801075db:	e9 3b f2 ff ff       	jmp    8010681b <alltraps>

801075e0 <vector185>:
.globl vector185
vector185:
  pushl $0
801075e0:	6a 00                	push   $0x0
  pushl $185
801075e2:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801075e7:	e9 2f f2 ff ff       	jmp    8010681b <alltraps>

801075ec <vector186>:
.globl vector186
vector186:
  pushl $0
801075ec:	6a 00                	push   $0x0
  pushl $186
801075ee:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
801075f3:	e9 23 f2 ff ff       	jmp    8010681b <alltraps>

801075f8 <vector187>:
.globl vector187
vector187:
  pushl $0
801075f8:	6a 00                	push   $0x0
  pushl $187
801075fa:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
801075ff:	e9 17 f2 ff ff       	jmp    8010681b <alltraps>

80107604 <vector188>:
.globl vector188
vector188:
  pushl $0
80107604:	6a 00                	push   $0x0
  pushl $188
80107606:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
8010760b:	e9 0b f2 ff ff       	jmp    8010681b <alltraps>

80107610 <vector189>:
.globl vector189
vector189:
  pushl $0
80107610:	6a 00                	push   $0x0
  pushl $189
80107612:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80107617:	e9 ff f1 ff ff       	jmp    8010681b <alltraps>

8010761c <vector190>:
.globl vector190
vector190:
  pushl $0
8010761c:	6a 00                	push   $0x0
  pushl $190
8010761e:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80107623:	e9 f3 f1 ff ff       	jmp    8010681b <alltraps>

80107628 <vector191>:
.globl vector191
vector191:
  pushl $0
80107628:	6a 00                	push   $0x0
  pushl $191
8010762a:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010762f:	e9 e7 f1 ff ff       	jmp    8010681b <alltraps>

80107634 <vector192>:
.globl vector192
vector192:
  pushl $0
80107634:	6a 00                	push   $0x0
  pushl $192
80107636:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
8010763b:	e9 db f1 ff ff       	jmp    8010681b <alltraps>

80107640 <vector193>:
.globl vector193
vector193:
  pushl $0
80107640:	6a 00                	push   $0x0
  pushl $193
80107642:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80107647:	e9 cf f1 ff ff       	jmp    8010681b <alltraps>

8010764c <vector194>:
.globl vector194
vector194:
  pushl $0
8010764c:	6a 00                	push   $0x0
  pushl $194
8010764e:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80107653:	e9 c3 f1 ff ff       	jmp    8010681b <alltraps>

80107658 <vector195>:
.globl vector195
vector195:
  pushl $0
80107658:	6a 00                	push   $0x0
  pushl $195
8010765a:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010765f:	e9 b7 f1 ff ff       	jmp    8010681b <alltraps>

80107664 <vector196>:
.globl vector196
vector196:
  pushl $0
80107664:	6a 00                	push   $0x0
  pushl $196
80107666:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
8010766b:	e9 ab f1 ff ff       	jmp    8010681b <alltraps>

80107670 <vector197>:
.globl vector197
vector197:
  pushl $0
80107670:	6a 00                	push   $0x0
  pushl $197
80107672:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80107677:	e9 9f f1 ff ff       	jmp    8010681b <alltraps>

8010767c <vector198>:
.globl vector198
vector198:
  pushl $0
8010767c:	6a 00                	push   $0x0
  pushl $198
8010767e:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80107683:	e9 93 f1 ff ff       	jmp    8010681b <alltraps>

80107688 <vector199>:
.globl vector199
vector199:
  pushl $0
80107688:	6a 00                	push   $0x0
  pushl $199
8010768a:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
8010768f:	e9 87 f1 ff ff       	jmp    8010681b <alltraps>

80107694 <vector200>:
.globl vector200
vector200:
  pushl $0
80107694:	6a 00                	push   $0x0
  pushl $200
80107696:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
8010769b:	e9 7b f1 ff ff       	jmp    8010681b <alltraps>

801076a0 <vector201>:
.globl vector201
vector201:
  pushl $0
801076a0:	6a 00                	push   $0x0
  pushl $201
801076a2:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801076a7:	e9 6f f1 ff ff       	jmp    8010681b <alltraps>

801076ac <vector202>:
.globl vector202
vector202:
  pushl $0
801076ac:	6a 00                	push   $0x0
  pushl $202
801076ae:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801076b3:	e9 63 f1 ff ff       	jmp    8010681b <alltraps>

801076b8 <vector203>:
.globl vector203
vector203:
  pushl $0
801076b8:	6a 00                	push   $0x0
  pushl $203
801076ba:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801076bf:	e9 57 f1 ff ff       	jmp    8010681b <alltraps>

801076c4 <vector204>:
.globl vector204
vector204:
  pushl $0
801076c4:	6a 00                	push   $0x0
  pushl $204
801076c6:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801076cb:	e9 4b f1 ff ff       	jmp    8010681b <alltraps>

801076d0 <vector205>:
.globl vector205
vector205:
  pushl $0
801076d0:	6a 00                	push   $0x0
  pushl $205
801076d2:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801076d7:	e9 3f f1 ff ff       	jmp    8010681b <alltraps>

801076dc <vector206>:
.globl vector206
vector206:
  pushl $0
801076dc:	6a 00                	push   $0x0
  pushl $206
801076de:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801076e3:	e9 33 f1 ff ff       	jmp    8010681b <alltraps>

801076e8 <vector207>:
.globl vector207
vector207:
  pushl $0
801076e8:	6a 00                	push   $0x0
  pushl $207
801076ea:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
801076ef:	e9 27 f1 ff ff       	jmp    8010681b <alltraps>

801076f4 <vector208>:
.globl vector208
vector208:
  pushl $0
801076f4:	6a 00                	push   $0x0
  pushl $208
801076f6:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
801076fb:	e9 1b f1 ff ff       	jmp    8010681b <alltraps>

80107700 <vector209>:
.globl vector209
vector209:
  pushl $0
80107700:	6a 00                	push   $0x0
  pushl $209
80107702:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80107707:	e9 0f f1 ff ff       	jmp    8010681b <alltraps>

8010770c <vector210>:
.globl vector210
vector210:
  pushl $0
8010770c:	6a 00                	push   $0x0
  pushl $210
8010770e:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80107713:	e9 03 f1 ff ff       	jmp    8010681b <alltraps>

80107718 <vector211>:
.globl vector211
vector211:
  pushl $0
80107718:	6a 00                	push   $0x0
  pushl $211
8010771a:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
8010771f:	e9 f7 f0 ff ff       	jmp    8010681b <alltraps>

80107724 <vector212>:
.globl vector212
vector212:
  pushl $0
80107724:	6a 00                	push   $0x0
  pushl $212
80107726:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
8010772b:	e9 eb f0 ff ff       	jmp    8010681b <alltraps>

80107730 <vector213>:
.globl vector213
vector213:
  pushl $0
80107730:	6a 00                	push   $0x0
  pushl $213
80107732:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80107737:	e9 df f0 ff ff       	jmp    8010681b <alltraps>

8010773c <vector214>:
.globl vector214
vector214:
  pushl $0
8010773c:	6a 00                	push   $0x0
  pushl $214
8010773e:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80107743:	e9 d3 f0 ff ff       	jmp    8010681b <alltraps>

80107748 <vector215>:
.globl vector215
vector215:
  pushl $0
80107748:	6a 00                	push   $0x0
  pushl $215
8010774a:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
8010774f:	e9 c7 f0 ff ff       	jmp    8010681b <alltraps>

80107754 <vector216>:
.globl vector216
vector216:
  pushl $0
80107754:	6a 00                	push   $0x0
  pushl $216
80107756:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
8010775b:	e9 bb f0 ff ff       	jmp    8010681b <alltraps>

80107760 <vector217>:
.globl vector217
vector217:
  pushl $0
80107760:	6a 00                	push   $0x0
  pushl $217
80107762:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80107767:	e9 af f0 ff ff       	jmp    8010681b <alltraps>

8010776c <vector218>:
.globl vector218
vector218:
  pushl $0
8010776c:	6a 00                	push   $0x0
  pushl $218
8010776e:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80107773:	e9 a3 f0 ff ff       	jmp    8010681b <alltraps>

80107778 <vector219>:
.globl vector219
vector219:
  pushl $0
80107778:	6a 00                	push   $0x0
  pushl $219
8010777a:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
8010777f:	e9 97 f0 ff ff       	jmp    8010681b <alltraps>

80107784 <vector220>:
.globl vector220
vector220:
  pushl $0
80107784:	6a 00                	push   $0x0
  pushl $220
80107786:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
8010778b:	e9 8b f0 ff ff       	jmp    8010681b <alltraps>

80107790 <vector221>:
.globl vector221
vector221:
  pushl $0
80107790:	6a 00                	push   $0x0
  pushl $221
80107792:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80107797:	e9 7f f0 ff ff       	jmp    8010681b <alltraps>

8010779c <vector222>:
.globl vector222
vector222:
  pushl $0
8010779c:	6a 00                	push   $0x0
  pushl $222
8010779e:	68 de 00 00 00       	push   $0xde
  jmp alltraps
801077a3:	e9 73 f0 ff ff       	jmp    8010681b <alltraps>

801077a8 <vector223>:
.globl vector223
vector223:
  pushl $0
801077a8:	6a 00                	push   $0x0
  pushl $223
801077aa:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
801077af:	e9 67 f0 ff ff       	jmp    8010681b <alltraps>

801077b4 <vector224>:
.globl vector224
vector224:
  pushl $0
801077b4:	6a 00                	push   $0x0
  pushl $224
801077b6:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
801077bb:	e9 5b f0 ff ff       	jmp    8010681b <alltraps>

801077c0 <vector225>:
.globl vector225
vector225:
  pushl $0
801077c0:	6a 00                	push   $0x0
  pushl $225
801077c2:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
801077c7:	e9 4f f0 ff ff       	jmp    8010681b <alltraps>

801077cc <vector226>:
.globl vector226
vector226:
  pushl $0
801077cc:	6a 00                	push   $0x0
  pushl $226
801077ce:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
801077d3:	e9 43 f0 ff ff       	jmp    8010681b <alltraps>

801077d8 <vector227>:
.globl vector227
vector227:
  pushl $0
801077d8:	6a 00                	push   $0x0
  pushl $227
801077da:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
801077df:	e9 37 f0 ff ff       	jmp    8010681b <alltraps>

801077e4 <vector228>:
.globl vector228
vector228:
  pushl $0
801077e4:	6a 00                	push   $0x0
  pushl $228
801077e6:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
801077eb:	e9 2b f0 ff ff       	jmp    8010681b <alltraps>

801077f0 <vector229>:
.globl vector229
vector229:
  pushl $0
801077f0:	6a 00                	push   $0x0
  pushl $229
801077f2:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
801077f7:	e9 1f f0 ff ff       	jmp    8010681b <alltraps>

801077fc <vector230>:
.globl vector230
vector230:
  pushl $0
801077fc:	6a 00                	push   $0x0
  pushl $230
801077fe:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80107803:	e9 13 f0 ff ff       	jmp    8010681b <alltraps>

80107808 <vector231>:
.globl vector231
vector231:
  pushl $0
80107808:	6a 00                	push   $0x0
  pushl $231
8010780a:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
8010780f:	e9 07 f0 ff ff       	jmp    8010681b <alltraps>

80107814 <vector232>:
.globl vector232
vector232:
  pushl $0
80107814:	6a 00                	push   $0x0
  pushl $232
80107816:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
8010781b:	e9 fb ef ff ff       	jmp    8010681b <alltraps>

80107820 <vector233>:
.globl vector233
vector233:
  pushl $0
80107820:	6a 00                	push   $0x0
  pushl $233
80107822:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80107827:	e9 ef ef ff ff       	jmp    8010681b <alltraps>

8010782c <vector234>:
.globl vector234
vector234:
  pushl $0
8010782c:	6a 00                	push   $0x0
  pushl $234
8010782e:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80107833:	e9 e3 ef ff ff       	jmp    8010681b <alltraps>

80107838 <vector235>:
.globl vector235
vector235:
  pushl $0
80107838:	6a 00                	push   $0x0
  pushl $235
8010783a:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
8010783f:	e9 d7 ef ff ff       	jmp    8010681b <alltraps>

80107844 <vector236>:
.globl vector236
vector236:
  pushl $0
80107844:	6a 00                	push   $0x0
  pushl $236
80107846:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
8010784b:	e9 cb ef ff ff       	jmp    8010681b <alltraps>

80107850 <vector237>:
.globl vector237
vector237:
  pushl $0
80107850:	6a 00                	push   $0x0
  pushl $237
80107852:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80107857:	e9 bf ef ff ff       	jmp    8010681b <alltraps>

8010785c <vector238>:
.globl vector238
vector238:
  pushl $0
8010785c:	6a 00                	push   $0x0
  pushl $238
8010785e:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80107863:	e9 b3 ef ff ff       	jmp    8010681b <alltraps>

80107868 <vector239>:
.globl vector239
vector239:
  pushl $0
80107868:	6a 00                	push   $0x0
  pushl $239
8010786a:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
8010786f:	e9 a7 ef ff ff       	jmp    8010681b <alltraps>

80107874 <vector240>:
.globl vector240
vector240:
  pushl $0
80107874:	6a 00                	push   $0x0
  pushl $240
80107876:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
8010787b:	e9 9b ef ff ff       	jmp    8010681b <alltraps>

80107880 <vector241>:
.globl vector241
vector241:
  pushl $0
80107880:	6a 00                	push   $0x0
  pushl $241
80107882:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80107887:	e9 8f ef ff ff       	jmp    8010681b <alltraps>

8010788c <vector242>:
.globl vector242
vector242:
  pushl $0
8010788c:	6a 00                	push   $0x0
  pushl $242
8010788e:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80107893:	e9 83 ef ff ff       	jmp    8010681b <alltraps>

80107898 <vector243>:
.globl vector243
vector243:
  pushl $0
80107898:	6a 00                	push   $0x0
  pushl $243
8010789a:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
8010789f:	e9 77 ef ff ff       	jmp    8010681b <alltraps>

801078a4 <vector244>:
.globl vector244
vector244:
  pushl $0
801078a4:	6a 00                	push   $0x0
  pushl $244
801078a6:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
801078ab:	e9 6b ef ff ff       	jmp    8010681b <alltraps>

801078b0 <vector245>:
.globl vector245
vector245:
  pushl $0
801078b0:	6a 00                	push   $0x0
  pushl $245
801078b2:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
801078b7:	e9 5f ef ff ff       	jmp    8010681b <alltraps>

801078bc <vector246>:
.globl vector246
vector246:
  pushl $0
801078bc:	6a 00                	push   $0x0
  pushl $246
801078be:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
801078c3:	e9 53 ef ff ff       	jmp    8010681b <alltraps>

801078c8 <vector247>:
.globl vector247
vector247:
  pushl $0
801078c8:	6a 00                	push   $0x0
  pushl $247
801078ca:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
801078cf:	e9 47 ef ff ff       	jmp    8010681b <alltraps>

801078d4 <vector248>:
.globl vector248
vector248:
  pushl $0
801078d4:	6a 00                	push   $0x0
  pushl $248
801078d6:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
801078db:	e9 3b ef ff ff       	jmp    8010681b <alltraps>

801078e0 <vector249>:
.globl vector249
vector249:
  pushl $0
801078e0:	6a 00                	push   $0x0
  pushl $249
801078e2:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
801078e7:	e9 2f ef ff ff       	jmp    8010681b <alltraps>

801078ec <vector250>:
.globl vector250
vector250:
  pushl $0
801078ec:	6a 00                	push   $0x0
  pushl $250
801078ee:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
801078f3:	e9 23 ef ff ff       	jmp    8010681b <alltraps>

801078f8 <vector251>:
.globl vector251
vector251:
  pushl $0
801078f8:	6a 00                	push   $0x0
  pushl $251
801078fa:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
801078ff:	e9 17 ef ff ff       	jmp    8010681b <alltraps>

80107904 <vector252>:
.globl vector252
vector252:
  pushl $0
80107904:	6a 00                	push   $0x0
  pushl $252
80107906:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
8010790b:	e9 0b ef ff ff       	jmp    8010681b <alltraps>

80107910 <vector253>:
.globl vector253
vector253:
  pushl $0
80107910:	6a 00                	push   $0x0
  pushl $253
80107912:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80107917:	e9 ff ee ff ff       	jmp    8010681b <alltraps>

8010791c <vector254>:
.globl vector254
vector254:
  pushl $0
8010791c:	6a 00                	push   $0x0
  pushl $254
8010791e:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80107923:	e9 f3 ee ff ff       	jmp    8010681b <alltraps>

80107928 <vector255>:
.globl vector255
vector255:
  pushl $0
80107928:	6a 00                	push   $0x0
  pushl $255
8010792a:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
8010792f:	e9 e7 ee ff ff       	jmp    8010681b <alltraps>

80107934 <lgdt>:

struct segdesc;

static inline void
lgdt(struct segdesc *p, int size)
{
80107934:	55                   	push   %ebp
80107935:	89 e5                	mov    %esp,%ebp
80107937:	83 ec 10             	sub    $0x10,%esp
  volatile ushort pd[3];

  pd[0] = size-1;
8010793a:	8b 45 0c             	mov    0xc(%ebp),%eax
8010793d:	83 e8 01             	sub    $0x1,%eax
80107940:	66 89 45 fa          	mov    %ax,-0x6(%ebp)
  pd[1] = (uint)p;
80107944:	8b 45 08             	mov    0x8(%ebp),%eax
80107947:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
8010794b:	8b 45 08             	mov    0x8(%ebp),%eax
8010794e:	c1 e8 10             	shr    $0x10,%eax
80107951:	66 89 45 fe          	mov    %ax,-0x2(%ebp)

  asm volatile("lgdt (%0)" : : "r" (pd));
80107955:	8d 45 fa             	lea    -0x6(%ebp),%eax
80107958:	0f 01 10             	lgdtl  (%eax)
}
8010795b:	90                   	nop
8010795c:	c9                   	leave  
8010795d:	c3                   	ret    

8010795e <ltr>:
  asm volatile("lidt (%0)" : : "r" (pd));
}

static inline void
ltr(ushort sel)
{
8010795e:	55                   	push   %ebp
8010795f:	89 e5                	mov    %esp,%ebp
80107961:	83 ec 04             	sub    $0x4,%esp
80107964:	8b 45 08             	mov    0x8(%ebp),%eax
80107967:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("ltr %0" : : "r" (sel));
8010796b:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
8010796f:	0f 00 d8             	ltr    %ax
}
80107972:	90                   	nop
80107973:	c9                   	leave  
80107974:	c3                   	ret    

80107975 <loadgs>:
  return eflags;
}

static inline void
loadgs(ushort v)
{
80107975:	55                   	push   %ebp
80107976:	89 e5                	mov    %esp,%ebp
80107978:	83 ec 04             	sub    $0x4,%esp
8010797b:	8b 45 08             	mov    0x8(%ebp),%eax
8010797e:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  asm volatile("movw %0, %%gs" : : "r" (v));
80107982:	0f b7 45 fc          	movzwl -0x4(%ebp),%eax
80107986:	8e e8                	mov    %eax,%gs
}
80107988:	90                   	nop
80107989:	c9                   	leave  
8010798a:	c3                   	ret    

8010798b <lcr3>:
  return val;
}

static inline void
lcr3(uint val) 
{
8010798b:	55                   	push   %ebp
8010798c:	89 e5                	mov    %esp,%ebp
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010798e:	8b 45 08             	mov    0x8(%ebp),%eax
80107991:	0f 22 d8             	mov    %eax,%cr3
}
80107994:	90                   	nop
80107995:	5d                   	pop    %ebp
80107996:	c3                   	ret    

80107997 <v2p>:
#define KERNBASE 0x80000000         // First kernel virtual address
#define KERNLINK (KERNBASE+EXTMEM)  // Address where kernel is linked

#ifndef __ASSEMBLER__

static inline uint v2p(void *a) { return ((uint) (a))  - KERNBASE; }
80107997:	55                   	push   %ebp
80107998:	89 e5                	mov    %esp,%ebp
8010799a:	8b 45 08             	mov    0x8(%ebp),%eax
8010799d:	05 00 00 00 80       	add    $0x80000000,%eax
801079a2:	5d                   	pop    %ebp
801079a3:	c3                   	ret    

801079a4 <p2v>:
static inline void *p2v(uint a) { return (void *) ((a) + KERNBASE); }
801079a4:	55                   	push   %ebp
801079a5:	89 e5                	mov    %esp,%ebp
801079a7:	8b 45 08             	mov    0x8(%ebp),%eax
801079aa:	05 00 00 00 80       	add    $0x80000000,%eax
801079af:	5d                   	pop    %ebp
801079b0:	c3                   	ret    

801079b1 <seginit>:

// Set up CPU's kernel segment descriptors.
// Run once on entry on each CPU.
void
seginit(void)
{
801079b1:	55                   	push   %ebp
801079b2:	89 e5                	mov    %esp,%ebp
801079b4:	53                   	push   %ebx
801079b5:	83 ec 14             	sub    $0x14,%esp

  // Map "logical" addresses to virtual addresses using identity map.
  // Cannot share a CODE descriptor for both kernel and user
  // because it would have to have DPL_USR, but the CPU forbids
  // an interrupt from CPL=0 to DPL=3.
  c = &cpus[cpunum()];
801079b8:	e8 f4 b5 ff ff       	call   80102fb1 <cpunum>
801079bd:	69 c0 bc 00 00 00    	imul   $0xbc,%eax,%eax
801079c3:	05 80 23 11 80       	add    $0x80112380,%eax
801079c8:	89 45 f4             	mov    %eax,-0xc(%ebp)
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
801079cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079ce:	66 c7 40 78 ff ff    	movw   $0xffff,0x78(%eax)
801079d4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079d7:	66 c7 40 7a 00 00    	movw   $0x0,0x7a(%eax)
801079dd:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e0:	c6 40 7c 00          	movb   $0x0,0x7c(%eax)
801079e4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079e7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079eb:	83 e2 f0             	and    $0xfffffff0,%edx
801079ee:	83 ca 0a             	or     $0xa,%edx
801079f1:	88 50 7d             	mov    %dl,0x7d(%eax)
801079f4:	8b 45 f4             	mov    -0xc(%ebp),%eax
801079f7:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
801079fb:	83 ca 10             	or     $0x10,%edx
801079fe:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a01:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a04:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a08:	83 e2 9f             	and    $0xffffff9f,%edx
80107a0b:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a0e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a11:	0f b6 50 7d          	movzbl 0x7d(%eax),%edx
80107a15:	83 ca 80             	or     $0xffffff80,%edx
80107a18:	88 50 7d             	mov    %dl,0x7d(%eax)
80107a1b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a1e:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a22:	83 ca 0f             	or     $0xf,%edx
80107a25:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a28:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a2b:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a2f:	83 e2 ef             	and    $0xffffffef,%edx
80107a32:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a35:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a38:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a3c:	83 e2 df             	and    $0xffffffdf,%edx
80107a3f:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a42:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a45:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a49:	83 ca 40             	or     $0x40,%edx
80107a4c:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a52:	0f b6 50 7e          	movzbl 0x7e(%eax),%edx
80107a56:	83 ca 80             	or     $0xffffff80,%edx
80107a59:	88 50 7e             	mov    %dl,0x7e(%eax)
80107a5c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a5f:	c6 40 7f 00          	movb   $0x0,0x7f(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80107a63:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a66:	66 c7 80 80 00 00 00 	movw   $0xffff,0x80(%eax)
80107a6d:	ff ff 
80107a6f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a72:	66 c7 80 82 00 00 00 	movw   $0x0,0x82(%eax)
80107a79:	00 00 
80107a7b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a7e:	c6 80 84 00 00 00 00 	movb   $0x0,0x84(%eax)
80107a85:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a88:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107a8f:	83 e2 f0             	and    $0xfffffff0,%edx
80107a92:	83 ca 02             	or     $0x2,%edx
80107a95:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107a9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107a9e:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107aa5:	83 ca 10             	or     $0x10,%edx
80107aa8:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107aae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ab1:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107ab8:	83 e2 9f             	and    $0xffffff9f,%edx
80107abb:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ac1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ac4:	0f b6 90 85 00 00 00 	movzbl 0x85(%eax),%edx
80107acb:	83 ca 80             	or     $0xffffff80,%edx
80107ace:	88 90 85 00 00 00    	mov    %dl,0x85(%eax)
80107ad4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ad7:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107ade:	83 ca 0f             	or     $0xf,%edx
80107ae1:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107ae7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107aea:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107af1:	83 e2 ef             	and    $0xffffffef,%edx
80107af4:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107afa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107afd:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b04:	83 e2 df             	and    $0xffffffdf,%edx
80107b07:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b10:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b17:	83 ca 40             	or     $0x40,%edx
80107b1a:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b20:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b23:	0f b6 90 86 00 00 00 	movzbl 0x86(%eax),%edx
80107b2a:	83 ca 80             	or     $0xffffff80,%edx
80107b2d:	88 90 86 00 00 00    	mov    %dl,0x86(%eax)
80107b33:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b36:	c6 80 87 00 00 00 00 	movb   $0x0,0x87(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80107b3d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b40:	66 c7 80 90 00 00 00 	movw   $0xffff,0x90(%eax)
80107b47:	ff ff 
80107b49:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b4c:	66 c7 80 92 00 00 00 	movw   $0x0,0x92(%eax)
80107b53:	00 00 
80107b55:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b58:	c6 80 94 00 00 00 00 	movb   $0x0,0x94(%eax)
80107b5f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b62:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b69:	83 e2 f0             	and    $0xfffffff0,%edx
80107b6c:	83 ca 0a             	or     $0xa,%edx
80107b6f:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b78:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b7f:	83 ca 10             	or     $0x10,%edx
80107b82:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b8b:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107b92:	83 ca 60             	or     $0x60,%edx
80107b95:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107b9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107b9e:	0f b6 90 95 00 00 00 	movzbl 0x95(%eax),%edx
80107ba5:	83 ca 80             	or     $0xffffff80,%edx
80107ba8:	88 90 95 00 00 00    	mov    %dl,0x95(%eax)
80107bae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bb1:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bb8:	83 ca 0f             	or     $0xf,%edx
80107bbb:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bc4:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bcb:	83 e2 ef             	and    $0xffffffef,%edx
80107bce:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bd7:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bde:	83 e2 df             	and    $0xffffffdf,%edx
80107be1:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107be7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bea:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107bf1:	83 ca 40             	or     $0x40,%edx
80107bf4:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107bfa:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107bfd:	0f b6 90 96 00 00 00 	movzbl 0x96(%eax),%edx
80107c04:	83 ca 80             	or     $0xffffff80,%edx
80107c07:	88 90 96 00 00 00    	mov    %dl,0x96(%eax)
80107c0d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c10:	c6 80 97 00 00 00 00 	movb   $0x0,0x97(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80107c17:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c1a:	66 c7 80 98 00 00 00 	movw   $0xffff,0x98(%eax)
80107c21:	ff ff 
80107c23:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c26:	66 c7 80 9a 00 00 00 	movw   $0x0,0x9a(%eax)
80107c2d:	00 00 
80107c2f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c32:	c6 80 9c 00 00 00 00 	movb   $0x0,0x9c(%eax)
80107c39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c3c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c43:	83 e2 f0             	and    $0xfffffff0,%edx
80107c46:	83 ca 02             	or     $0x2,%edx
80107c49:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c4f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c52:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c59:	83 ca 10             	or     $0x10,%edx
80107c5c:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c62:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c65:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c6c:	83 ca 60             	or     $0x60,%edx
80107c6f:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c75:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c78:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80107c7f:	83 ca 80             	or     $0xffffff80,%edx
80107c82:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
80107c88:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c8b:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107c92:	83 ca 0f             	or     $0xf,%edx
80107c95:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107c9b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107c9e:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ca5:	83 e2 ef             	and    $0xffffffef,%edx
80107ca8:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cae:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cb1:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cb8:	83 e2 df             	and    $0xffffffdf,%edx
80107cbb:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cc4:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107ccb:	83 ca 40             	or     $0x40,%edx
80107cce:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107cd4:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cd7:	0f b6 90 9e 00 00 00 	movzbl 0x9e(%eax),%edx
80107cde:	83 ca 80             	or     $0xffffff80,%edx
80107ce1:	88 90 9e 00 00 00    	mov    %dl,0x9e(%eax)
80107ce7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cea:	c6 80 9f 00 00 00 00 	movb   $0x0,0x9f(%eax)

  // Map cpu, and curproc
  c->gdt[SEG_KCPU] = SEG(STA_W, &c->cpu, 8, 0);
80107cf1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cf4:	05 b4 00 00 00       	add    $0xb4,%eax
80107cf9:	89 c3                	mov    %eax,%ebx
80107cfb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107cfe:	05 b4 00 00 00       	add    $0xb4,%eax
80107d03:	c1 e8 10             	shr    $0x10,%eax
80107d06:	89 c2                	mov    %eax,%edx
80107d08:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d0b:	05 b4 00 00 00       	add    $0xb4,%eax
80107d10:	c1 e8 18             	shr    $0x18,%eax
80107d13:	89 c1                	mov    %eax,%ecx
80107d15:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d18:	66 c7 80 88 00 00 00 	movw   $0x0,0x88(%eax)
80107d1f:	00 00 
80107d21:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d24:	66 89 98 8a 00 00 00 	mov    %bx,0x8a(%eax)
80107d2b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d2e:	88 90 8c 00 00 00    	mov    %dl,0x8c(%eax)
80107d34:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d37:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d3e:	83 e2 f0             	and    $0xfffffff0,%edx
80107d41:	83 ca 02             	or     $0x2,%edx
80107d44:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d4a:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d4d:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d54:	83 ca 10             	or     $0x10,%edx
80107d57:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d5d:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d60:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d67:	83 e2 9f             	and    $0xffffff9f,%edx
80107d6a:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d70:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d73:	0f b6 90 8d 00 00 00 	movzbl 0x8d(%eax),%edx
80107d7a:	83 ca 80             	or     $0xffffff80,%edx
80107d7d:	88 90 8d 00 00 00    	mov    %dl,0x8d(%eax)
80107d83:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d86:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107d8d:	83 e2 f0             	and    $0xfffffff0,%edx
80107d90:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107d96:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107d99:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107da0:	83 e2 ef             	and    $0xffffffef,%edx
80107da3:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107da9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dac:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107db3:	83 e2 df             	and    $0xffffffdf,%edx
80107db6:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107dbc:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dbf:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107dc6:	83 ca 40             	or     $0x40,%edx
80107dc9:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107dcf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dd2:	0f b6 90 8e 00 00 00 	movzbl 0x8e(%eax),%edx
80107dd9:	83 ca 80             	or     $0xffffff80,%edx
80107ddc:	88 90 8e 00 00 00    	mov    %dl,0x8e(%eax)
80107de2:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107de5:	88 88 8f 00 00 00    	mov    %cl,0x8f(%eax)

  lgdt(c->gdt, sizeof(c->gdt));
80107deb:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107dee:	83 c0 70             	add    $0x70,%eax
80107df1:	83 ec 08             	sub    $0x8,%esp
80107df4:	6a 38                	push   $0x38
80107df6:	50                   	push   %eax
80107df7:	e8 38 fb ff ff       	call   80107934 <lgdt>
80107dfc:	83 c4 10             	add    $0x10,%esp
  loadgs(SEG_KCPU << 3);
80107dff:	83 ec 0c             	sub    $0xc,%esp
80107e02:	6a 18                	push   $0x18
80107e04:	e8 6c fb ff ff       	call   80107975 <loadgs>
80107e09:	83 c4 10             	add    $0x10,%esp
  
  // Initialize cpu-local storage.
  cpu = c;
80107e0c:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107e0f:	65 a3 00 00 00 00    	mov    %eax,%gs:0x0
  proc = 0;
80107e15:	65 c7 05 04 00 00 00 	movl   $0x0,%gs:0x4
80107e1c:	00 00 00 00 
}
80107e20:	90                   	nop
80107e21:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80107e24:	c9                   	leave  
80107e25:	c3                   	ret    

80107e26 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80107e26:	55                   	push   %ebp
80107e27:	89 e5                	mov    %esp,%ebp
80107e29:	83 ec 18             	sub    $0x18,%esp
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80107e2c:	8b 45 0c             	mov    0xc(%ebp),%eax
80107e2f:	c1 e8 16             	shr    $0x16,%eax
80107e32:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107e39:	8b 45 08             	mov    0x8(%ebp),%eax
80107e3c:	01 d0                	add    %edx,%eax
80107e3e:	89 45 f0             	mov    %eax,-0x10(%ebp)
  if(*pde & PTE_P){
80107e41:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e44:	8b 00                	mov    (%eax),%eax
80107e46:	83 e0 01             	and    $0x1,%eax
80107e49:	85 c0                	test   %eax,%eax
80107e4b:	74 18                	je     80107e65 <walkpgdir+0x3f>
    pgtab = (pte_t*)p2v(PTE_ADDR(*pde));
80107e4d:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107e50:	8b 00                	mov    (%eax),%eax
80107e52:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107e57:	50                   	push   %eax
80107e58:	e8 47 fb ff ff       	call   801079a4 <p2v>
80107e5d:	83 c4 04             	add    $0x4,%esp
80107e60:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e63:	eb 48                	jmp    80107ead <walkpgdir+0x87>
  } else {
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80107e65:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80107e69:	74 0e                	je     80107e79 <walkpgdir+0x53>
80107e6b:	e8 db ad ff ff       	call   80102c4b <kalloc>
80107e70:	89 45 f4             	mov    %eax,-0xc(%ebp)
80107e73:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80107e77:	75 07                	jne    80107e80 <walkpgdir+0x5a>
      return 0;
80107e79:	b8 00 00 00 00       	mov    $0x0,%eax
80107e7e:	eb 44                	jmp    80107ec4 <walkpgdir+0x9e>
    // Make sure all those PTE_P bits are zero.
    memset(pgtab, 0, PGSIZE);
80107e80:	83 ec 04             	sub    $0x4,%esp
80107e83:	68 00 10 00 00       	push   $0x1000
80107e88:	6a 00                	push   $0x0
80107e8a:	ff 75 f4             	pushl  -0xc(%ebp)
80107e8d:	e8 78 d5 ff ff       	call   8010540a <memset>
80107e92:	83 c4 10             	add    $0x10,%esp
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table 
    // entries, if necessary.
    *pde = v2p(pgtab) | PTE_P | PTE_W | PTE_U;
80107e95:	83 ec 0c             	sub    $0xc,%esp
80107e98:	ff 75 f4             	pushl  -0xc(%ebp)
80107e9b:	e8 f7 fa ff ff       	call   80107997 <v2p>
80107ea0:	83 c4 10             	add    $0x10,%esp
80107ea3:	83 c8 07             	or     $0x7,%eax
80107ea6:	89 c2                	mov    %eax,%edx
80107ea8:	8b 45 f0             	mov    -0x10(%ebp),%eax
80107eab:	89 10                	mov    %edx,(%eax)
  }
  return &pgtab[PTX(va)];
80107ead:	8b 45 0c             	mov    0xc(%ebp),%eax
80107eb0:	c1 e8 0c             	shr    $0xc,%eax
80107eb3:	25 ff 03 00 00       	and    $0x3ff,%eax
80107eb8:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80107ebf:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107ec2:	01 d0                	add    %edx,%eax
}
80107ec4:	c9                   	leave  
80107ec5:	c3                   	ret    

80107ec6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80107ec6:	55                   	push   %ebp
80107ec7:	89 e5                	mov    %esp,%ebp
80107ec9:	83 ec 18             	sub    $0x18,%esp
  char *a, *last;
  pte_t *pte;
  
  a = (char*)PGROUNDDOWN((uint)va);
80107ecc:	8b 45 0c             	mov    0xc(%ebp),%eax
80107ecf:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ed4:	89 45 f4             	mov    %eax,-0xc(%ebp)
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80107ed7:	8b 55 0c             	mov    0xc(%ebp),%edx
80107eda:	8b 45 10             	mov    0x10(%ebp),%eax
80107edd:	01 d0                	add    %edx,%eax
80107edf:	83 e8 01             	sub    $0x1,%eax
80107ee2:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80107ee7:	89 45 f0             	mov    %eax,-0x10(%ebp)
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80107eea:	83 ec 04             	sub    $0x4,%esp
80107eed:	6a 01                	push   $0x1
80107eef:	ff 75 f4             	pushl  -0xc(%ebp)
80107ef2:	ff 75 08             	pushl  0x8(%ebp)
80107ef5:	e8 2c ff ff ff       	call   80107e26 <walkpgdir>
80107efa:	83 c4 10             	add    $0x10,%esp
80107efd:	89 45 ec             	mov    %eax,-0x14(%ebp)
80107f00:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80107f04:	75 07                	jne    80107f0d <mappages+0x47>
      return -1;
80107f06:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80107f0b:	eb 47                	jmp    80107f54 <mappages+0x8e>
    if(*pte & PTE_P)
80107f0d:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f10:	8b 00                	mov    (%eax),%eax
80107f12:	83 e0 01             	and    $0x1,%eax
80107f15:	85 c0                	test   %eax,%eax
80107f17:	74 0d                	je     80107f26 <mappages+0x60>
      panic("remap");
80107f19:	83 ec 0c             	sub    $0xc,%esp
80107f1c:	68 6c 8d 10 80       	push   $0x80108d6c
80107f21:	e8 40 86 ff ff       	call   80100566 <panic>
    *pte = pa | perm | PTE_P;
80107f26:	8b 45 18             	mov    0x18(%ebp),%eax
80107f29:	0b 45 14             	or     0x14(%ebp),%eax
80107f2c:	83 c8 01             	or     $0x1,%eax
80107f2f:	89 c2                	mov    %eax,%edx
80107f31:	8b 45 ec             	mov    -0x14(%ebp),%eax
80107f34:	89 10                	mov    %edx,(%eax)
    if(a == last)
80107f36:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107f39:	3b 45 f0             	cmp    -0x10(%ebp),%eax
80107f3c:	74 10                	je     80107f4e <mappages+0x88>
      break;
    a += PGSIZE;
80107f3e:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
    pa += PGSIZE;
80107f45:	81 45 14 00 10 00 00 	addl   $0x1000,0x14(%ebp)
  }
80107f4c:	eb 9c                	jmp    80107eea <mappages+0x24>
      return -1;
    if(*pte & PTE_P)
      panic("remap");
    *pte = pa | perm | PTE_P;
    if(a == last)
      break;
80107f4e:	90                   	nop
    a += PGSIZE;
    pa += PGSIZE;
  }
  return 0;
80107f4f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80107f54:	c9                   	leave  
80107f55:	c3                   	ret    

80107f56 <setupkvm>:
};

// Set up kernel part of a page table.
pde_t*
setupkvm(void)
{
80107f56:	55                   	push   %ebp
80107f57:	89 e5                	mov    %esp,%ebp
80107f59:	53                   	push   %ebx
80107f5a:	83 ec 14             	sub    $0x14,%esp
  pde_t *pgdir;
  struct kmap *k;

  if((pgdir = (pde_t*)kalloc()) == 0)
80107f5d:	e8 e9 ac ff ff       	call   80102c4b <kalloc>
80107f62:	89 45 f0             	mov    %eax,-0x10(%ebp)
80107f65:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80107f69:	75 0a                	jne    80107f75 <setupkvm+0x1f>
    return 0;
80107f6b:	b8 00 00 00 00       	mov    $0x0,%eax
80107f70:	e9 8e 00 00 00       	jmp    80108003 <setupkvm+0xad>
  memset(pgdir, 0, PGSIZE);
80107f75:	83 ec 04             	sub    $0x4,%esp
80107f78:	68 00 10 00 00       	push   $0x1000
80107f7d:	6a 00                	push   $0x0
80107f7f:	ff 75 f0             	pushl  -0x10(%ebp)
80107f82:	e8 83 d4 ff ff       	call   8010540a <memset>
80107f87:	83 c4 10             	add    $0x10,%esp
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
80107f8a:	83 ec 0c             	sub    $0xc,%esp
80107f8d:	68 00 00 00 0e       	push   $0xe000000
80107f92:	e8 0d fa ff ff       	call   801079a4 <p2v>
80107f97:	83 c4 10             	add    $0x10,%esp
80107f9a:	3d 00 00 00 fe       	cmp    $0xfe000000,%eax
80107f9f:	76 0d                	jbe    80107fae <setupkvm+0x58>
    panic("PHYSTOP too high");
80107fa1:	83 ec 0c             	sub    $0xc,%esp
80107fa4:	68 72 8d 10 80       	push   $0x80108d72
80107fa9:	e8 b8 85 ff ff       	call   80100566 <panic>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107fae:	c7 45 f4 a0 b4 10 80 	movl   $0x8010b4a0,-0xc(%ebp)
80107fb5:	eb 40                	jmp    80107ff7 <setupkvm+0xa1>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107fb7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fba:	8b 48 0c             	mov    0xc(%eax),%ecx
                (uint)k->phys_start, k->perm) < 0)
80107fbd:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc0:	8b 50 04             	mov    0x4(%eax),%edx
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
80107fc3:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fc6:	8b 58 08             	mov    0x8(%eax),%ebx
80107fc9:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fcc:	8b 40 04             	mov    0x4(%eax),%eax
80107fcf:	29 c3                	sub    %eax,%ebx
80107fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
80107fd4:	8b 00                	mov    (%eax),%eax
80107fd6:	83 ec 0c             	sub    $0xc,%esp
80107fd9:	51                   	push   %ecx
80107fda:	52                   	push   %edx
80107fdb:	53                   	push   %ebx
80107fdc:	50                   	push   %eax
80107fdd:	ff 75 f0             	pushl  -0x10(%ebp)
80107fe0:	e8 e1 fe ff ff       	call   80107ec6 <mappages>
80107fe5:	83 c4 20             	add    $0x20,%esp
80107fe8:	85 c0                	test   %eax,%eax
80107fea:	79 07                	jns    80107ff3 <setupkvm+0x9d>
                (uint)k->phys_start, k->perm) < 0)
      return 0;
80107fec:	b8 00 00 00 00       	mov    $0x0,%eax
80107ff1:	eb 10                	jmp    80108003 <setupkvm+0xad>
  if((pgdir = (pde_t*)kalloc()) == 0)
    return 0;
  memset(pgdir, 0, PGSIZE);
  if (p2v(PHYSTOP) > (void*)DEVSPACE)
    panic("PHYSTOP too high");
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80107ff3:	83 45 f4 10          	addl   $0x10,-0xc(%ebp)
80107ff7:	81 7d f4 e0 b4 10 80 	cmpl   $0x8010b4e0,-0xc(%ebp)
80107ffe:	72 b7                	jb     80107fb7 <setupkvm+0x61>
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start, 
                (uint)k->phys_start, k->perm) < 0)
      return 0;
  return pgdir;
80108000:	8b 45 f0             	mov    -0x10(%ebp),%eax
}
80108003:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80108006:	c9                   	leave  
80108007:	c3                   	ret    

80108008 <kvmalloc>:

// Allocate one page table for the machine for the kernel address
// space for scheduler processes.
void
kvmalloc(void)
{
80108008:	55                   	push   %ebp
80108009:	89 e5                	mov    %esp,%ebp
8010800b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010800e:	e8 43 ff ff ff       	call   80107f56 <setupkvm>
80108013:	a3 58 55 11 80       	mov    %eax,0x80115558
  switchkvm();
80108018:	e8 03 00 00 00       	call   80108020 <switchkvm>
}
8010801d:	90                   	nop
8010801e:	c9                   	leave  
8010801f:	c3                   	ret    

80108020 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80108020:	55                   	push   %ebp
80108021:	89 e5                	mov    %esp,%ebp
  lcr3(v2p(kpgdir));   // switch to the kernel page table
80108023:	a1 58 55 11 80       	mov    0x80115558,%eax
80108028:	50                   	push   %eax
80108029:	e8 69 f9 ff ff       	call   80107997 <v2p>
8010802e:	83 c4 04             	add    $0x4,%esp
80108031:	50                   	push   %eax
80108032:	e8 54 f9 ff ff       	call   8010798b <lcr3>
80108037:	83 c4 04             	add    $0x4,%esp
}
8010803a:	90                   	nop
8010803b:	c9                   	leave  
8010803c:	c3                   	ret    

8010803d <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
8010803d:	55                   	push   %ebp
8010803e:	89 e5                	mov    %esp,%ebp
80108040:	56                   	push   %esi
80108041:	53                   	push   %ebx
  pushcli();
80108042:	e8 bd d2 ff ff       	call   80105304 <pushcli>
  cpu->gdt[SEG_TSS] = SEG16(STS_T32A, &cpu->ts, sizeof(cpu->ts)-1, 0);
80108047:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010804d:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108054:	83 c2 08             	add    $0x8,%edx
80108057:	89 d6                	mov    %edx,%esi
80108059:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
80108060:	83 c2 08             	add    $0x8,%edx
80108063:	c1 ea 10             	shr    $0x10,%edx
80108066:	89 d3                	mov    %edx,%ebx
80108068:	65 8b 15 00 00 00 00 	mov    %gs:0x0,%edx
8010806f:	83 c2 08             	add    $0x8,%edx
80108072:	c1 ea 18             	shr    $0x18,%edx
80108075:	89 d1                	mov    %edx,%ecx
80108077:	66 c7 80 a0 00 00 00 	movw   $0x67,0xa0(%eax)
8010807e:	67 00 
80108080:	66 89 b0 a2 00 00 00 	mov    %si,0xa2(%eax)
80108087:	88 98 a4 00 00 00    	mov    %bl,0xa4(%eax)
8010808d:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108094:	83 e2 f0             	and    $0xfffffff0,%edx
80108097:	83 ca 09             	or     $0x9,%edx
8010809a:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801080a0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080a7:	83 ca 10             	or     $0x10,%edx
801080aa:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801080b0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080b7:	83 e2 9f             	and    $0xffffff9f,%edx
801080ba:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801080c0:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
801080c7:	83 ca 80             	or     $0xffffff80,%edx
801080ca:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
801080d0:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801080d7:	83 e2 f0             	and    $0xfffffff0,%edx
801080da:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801080e0:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801080e7:	83 e2 ef             	and    $0xffffffef,%edx
801080ea:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
801080f0:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
801080f7:	83 e2 df             	and    $0xffffffdf,%edx
801080fa:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108100:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108107:	83 ca 40             	or     $0x40,%edx
8010810a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108110:	0f b6 90 a6 00 00 00 	movzbl 0xa6(%eax),%edx
80108117:	83 e2 7f             	and    $0x7f,%edx
8010811a:	88 90 a6 00 00 00    	mov    %dl,0xa6(%eax)
80108120:	88 88 a7 00 00 00    	mov    %cl,0xa7(%eax)
  cpu->gdt[SEG_TSS].s = 0;
80108126:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010812c:	0f b6 90 a5 00 00 00 	movzbl 0xa5(%eax),%edx
80108133:	83 e2 ef             	and    $0xffffffef,%edx
80108136:	88 90 a5 00 00 00    	mov    %dl,0xa5(%eax)
  cpu->ts.ss0 = SEG_KDATA << 3;
8010813c:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
80108142:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  cpu->ts.esp0 = (uint)proc->kstack + KSTACKSIZE;
80108148:	65 a1 00 00 00 00    	mov    %gs:0x0,%eax
8010814e:	65 8b 15 04 00 00 00 	mov    %gs:0x4,%edx
80108155:	8b 52 08             	mov    0x8(%edx),%edx
80108158:	81 c2 00 10 00 00    	add    $0x1000,%edx
8010815e:	89 50 0c             	mov    %edx,0xc(%eax)
  ltr(SEG_TSS << 3);
80108161:	83 ec 0c             	sub    $0xc,%esp
80108164:	6a 30                	push   $0x30
80108166:	e8 f3 f7 ff ff       	call   8010795e <ltr>
8010816b:	83 c4 10             	add    $0x10,%esp
  if(p->pgdir == 0)
8010816e:	8b 45 08             	mov    0x8(%ebp),%eax
80108171:	8b 40 04             	mov    0x4(%eax),%eax
80108174:	85 c0                	test   %eax,%eax
80108176:	75 0d                	jne    80108185 <switchuvm+0x148>
    panic("switchuvm: no pgdir");
80108178:	83 ec 0c             	sub    $0xc,%esp
8010817b:	68 83 8d 10 80       	push   $0x80108d83
80108180:	e8 e1 83 ff ff       	call   80100566 <panic>
  lcr3(v2p(p->pgdir));  // switch to new address space
80108185:	8b 45 08             	mov    0x8(%ebp),%eax
80108188:	8b 40 04             	mov    0x4(%eax),%eax
8010818b:	83 ec 0c             	sub    $0xc,%esp
8010818e:	50                   	push   %eax
8010818f:	e8 03 f8 ff ff       	call   80107997 <v2p>
80108194:	83 c4 10             	add    $0x10,%esp
80108197:	83 ec 0c             	sub    $0xc,%esp
8010819a:	50                   	push   %eax
8010819b:	e8 eb f7 ff ff       	call   8010798b <lcr3>
801081a0:	83 c4 10             	add    $0x10,%esp
  popcli();
801081a3:	e8 a1 d1 ff ff       	call   80105349 <popcli>
}
801081a8:	90                   	nop
801081a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801081ac:	5b                   	pop    %ebx
801081ad:	5e                   	pop    %esi
801081ae:	5d                   	pop    %ebp
801081af:	c3                   	ret    

801081b0 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801081b0:	55                   	push   %ebp
801081b1:	89 e5                	mov    %esp,%ebp
801081b3:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  
  if(sz >= PGSIZE)
801081b6:	81 7d 10 ff 0f 00 00 	cmpl   $0xfff,0x10(%ebp)
801081bd:	76 0d                	jbe    801081cc <inituvm+0x1c>
    panic("inituvm: more than a page");
801081bf:	83 ec 0c             	sub    $0xc,%esp
801081c2:	68 97 8d 10 80       	push   $0x80108d97
801081c7:	e8 9a 83 ff ff       	call   80100566 <panic>
  mem = kalloc();
801081cc:	e8 7a aa ff ff       	call   80102c4b <kalloc>
801081d1:	89 45 f4             	mov    %eax,-0xc(%ebp)
  memset(mem, 0, PGSIZE);
801081d4:	83 ec 04             	sub    $0x4,%esp
801081d7:	68 00 10 00 00       	push   $0x1000
801081dc:	6a 00                	push   $0x0
801081de:	ff 75 f4             	pushl  -0xc(%ebp)
801081e1:	e8 24 d2 ff ff       	call   8010540a <memset>
801081e6:	83 c4 10             	add    $0x10,%esp
  mappages(pgdir, 0, PGSIZE, v2p(mem), PTE_W|PTE_U);
801081e9:	83 ec 0c             	sub    $0xc,%esp
801081ec:	ff 75 f4             	pushl  -0xc(%ebp)
801081ef:	e8 a3 f7 ff ff       	call   80107997 <v2p>
801081f4:	83 c4 10             	add    $0x10,%esp
801081f7:	83 ec 0c             	sub    $0xc,%esp
801081fa:	6a 06                	push   $0x6
801081fc:	50                   	push   %eax
801081fd:	68 00 10 00 00       	push   $0x1000
80108202:	6a 00                	push   $0x0
80108204:	ff 75 08             	pushl  0x8(%ebp)
80108207:	e8 ba fc ff ff       	call   80107ec6 <mappages>
8010820c:	83 c4 20             	add    $0x20,%esp
  memmove(mem, init, sz);
8010820f:	83 ec 04             	sub    $0x4,%esp
80108212:	ff 75 10             	pushl  0x10(%ebp)
80108215:	ff 75 0c             	pushl  0xc(%ebp)
80108218:	ff 75 f4             	pushl  -0xc(%ebp)
8010821b:	e8 a9 d2 ff ff       	call   801054c9 <memmove>
80108220:	83 c4 10             	add    $0x10,%esp
}
80108223:	90                   	nop
80108224:	c9                   	leave  
80108225:	c3                   	ret    

80108226 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80108226:	55                   	push   %ebp
80108227:	89 e5                	mov    %esp,%ebp
80108229:	53                   	push   %ebx
8010822a:	83 ec 14             	sub    $0x14,%esp
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
8010822d:	8b 45 0c             	mov    0xc(%ebp),%eax
80108230:	25 ff 0f 00 00       	and    $0xfff,%eax
80108235:	85 c0                	test   %eax,%eax
80108237:	74 0d                	je     80108246 <loaduvm+0x20>
    panic("loaduvm: addr must be page aligned");
80108239:	83 ec 0c             	sub    $0xc,%esp
8010823c:	68 b4 8d 10 80       	push   $0x80108db4
80108241:	e8 20 83 ff ff       	call   80100566 <panic>
  for(i = 0; i < sz; i += PGSIZE){
80108246:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010824d:	e9 95 00 00 00       	jmp    801082e7 <loaduvm+0xc1>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80108252:	8b 55 0c             	mov    0xc(%ebp),%edx
80108255:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108258:	01 d0                	add    %edx,%eax
8010825a:	83 ec 04             	sub    $0x4,%esp
8010825d:	6a 00                	push   $0x0
8010825f:	50                   	push   %eax
80108260:	ff 75 08             	pushl  0x8(%ebp)
80108263:	e8 be fb ff ff       	call   80107e26 <walkpgdir>
80108268:	83 c4 10             	add    $0x10,%esp
8010826b:	89 45 ec             	mov    %eax,-0x14(%ebp)
8010826e:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108272:	75 0d                	jne    80108281 <loaduvm+0x5b>
      panic("loaduvm: address should exist");
80108274:	83 ec 0c             	sub    $0xc,%esp
80108277:	68 d7 8d 10 80       	push   $0x80108dd7
8010827c:	e8 e5 82 ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
80108281:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108284:	8b 00                	mov    (%eax),%eax
80108286:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010828b:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(sz - i < PGSIZE)
8010828e:	8b 45 18             	mov    0x18(%ebp),%eax
80108291:	2b 45 f4             	sub    -0xc(%ebp),%eax
80108294:	3d ff 0f 00 00       	cmp    $0xfff,%eax
80108299:	77 0b                	ja     801082a6 <loaduvm+0x80>
      n = sz - i;
8010829b:	8b 45 18             	mov    0x18(%ebp),%eax
8010829e:	2b 45 f4             	sub    -0xc(%ebp),%eax
801082a1:	89 45 f0             	mov    %eax,-0x10(%ebp)
801082a4:	eb 07                	jmp    801082ad <loaduvm+0x87>
    else
      n = PGSIZE;
801082a6:	c7 45 f0 00 10 00 00 	movl   $0x1000,-0x10(%ebp)
    if(readi(ip, p2v(pa), offset+i, n) != n)
801082ad:	8b 55 14             	mov    0x14(%ebp),%edx
801082b0:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082b3:	8d 1c 02             	lea    (%edx,%eax,1),%ebx
801082b6:	83 ec 0c             	sub    $0xc,%esp
801082b9:	ff 75 e8             	pushl  -0x18(%ebp)
801082bc:	e8 e3 f6 ff ff       	call   801079a4 <p2v>
801082c1:	83 c4 10             	add    $0x10,%esp
801082c4:	ff 75 f0             	pushl  -0x10(%ebp)
801082c7:	53                   	push   %ebx
801082c8:	50                   	push   %eax
801082c9:	ff 75 10             	pushl  0x10(%ebp)
801082cc:	e8 ec 9b ff ff       	call   80101ebd <readi>
801082d1:	83 c4 10             	add    $0x10,%esp
801082d4:	3b 45 f0             	cmp    -0x10(%ebp),%eax
801082d7:	74 07                	je     801082e0 <loaduvm+0xba>
      return -1;
801082d9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801082de:	eb 18                	jmp    801082f8 <loaduvm+0xd2>
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
801082e0:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801082e7:	8b 45 f4             	mov    -0xc(%ebp),%eax
801082ea:	3b 45 18             	cmp    0x18(%ebp),%eax
801082ed:	0f 82 5f ff ff ff    	jb     80108252 <loaduvm+0x2c>
    else
      n = PGSIZE;
    if(readi(ip, p2v(pa), offset+i, n) != n)
      return -1;
  }
  return 0;
801082f3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801082f8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801082fb:	c9                   	leave  
801082fc:	c3                   	ret    

801082fd <allocuvm>:

// Allocate page tables and physical memory to grow process from oldsz to
// newsz, which need not be page aligned.  Returns new size or 0 on error.
int
allocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801082fd:	55                   	push   %ebp
801082fe:	89 e5                	mov    %esp,%ebp
80108300:	83 ec 18             	sub    $0x18,%esp
  char *mem;
  uint a;

  if(newsz >= KERNBASE)
80108303:	8b 45 10             	mov    0x10(%ebp),%eax
80108306:	85 c0                	test   %eax,%eax
80108308:	79 0a                	jns    80108314 <allocuvm+0x17>
    return 0;
8010830a:	b8 00 00 00 00       	mov    $0x0,%eax
8010830f:	e9 b0 00 00 00       	jmp    801083c4 <allocuvm+0xc7>
  if(newsz < oldsz)
80108314:	8b 45 10             	mov    0x10(%ebp),%eax
80108317:	3b 45 0c             	cmp    0xc(%ebp),%eax
8010831a:	73 08                	jae    80108324 <allocuvm+0x27>
    return oldsz;
8010831c:	8b 45 0c             	mov    0xc(%ebp),%eax
8010831f:	e9 a0 00 00 00       	jmp    801083c4 <allocuvm+0xc7>

  a = PGROUNDUP(oldsz);
80108324:	8b 45 0c             	mov    0xc(%ebp),%eax
80108327:	05 ff 0f 00 00       	add    $0xfff,%eax
8010832c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80108331:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a < newsz; a += PGSIZE){
80108334:	eb 7f                	jmp    801083b5 <allocuvm+0xb8>
    mem = kalloc();
80108336:	e8 10 a9 ff ff       	call   80102c4b <kalloc>
8010833b:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(mem == 0){
8010833e:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108342:	75 2b                	jne    8010836f <allocuvm+0x72>
      cprintf("allocuvm out of memory\n");
80108344:	83 ec 0c             	sub    $0xc,%esp
80108347:	68 f5 8d 10 80       	push   $0x80108df5
8010834c:	e8 75 80 ff ff       	call   801003c6 <cprintf>
80108351:	83 c4 10             	add    $0x10,%esp
      deallocuvm(pgdir, newsz, oldsz);
80108354:	83 ec 04             	sub    $0x4,%esp
80108357:	ff 75 0c             	pushl  0xc(%ebp)
8010835a:	ff 75 10             	pushl  0x10(%ebp)
8010835d:	ff 75 08             	pushl  0x8(%ebp)
80108360:	e8 61 00 00 00       	call   801083c6 <deallocuvm>
80108365:	83 c4 10             	add    $0x10,%esp
      return 0;
80108368:	b8 00 00 00 00       	mov    $0x0,%eax
8010836d:	eb 55                	jmp    801083c4 <allocuvm+0xc7>
    }
    memset(mem, 0, PGSIZE);
8010836f:	83 ec 04             	sub    $0x4,%esp
80108372:	68 00 10 00 00       	push   $0x1000
80108377:	6a 00                	push   $0x0
80108379:	ff 75 f0             	pushl  -0x10(%ebp)
8010837c:	e8 89 d0 ff ff       	call   8010540a <memset>
80108381:	83 c4 10             	add    $0x10,%esp
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
80108384:	83 ec 0c             	sub    $0xc,%esp
80108387:	ff 75 f0             	pushl  -0x10(%ebp)
8010838a:	e8 08 f6 ff ff       	call   80107997 <v2p>
8010838f:	83 c4 10             	add    $0x10,%esp
80108392:	89 c2                	mov    %eax,%edx
80108394:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108397:	83 ec 0c             	sub    $0xc,%esp
8010839a:	6a 06                	push   $0x6
8010839c:	52                   	push   %edx
8010839d:	68 00 10 00 00       	push   $0x1000
801083a2:	50                   	push   %eax
801083a3:	ff 75 08             	pushl  0x8(%ebp)
801083a6:	e8 1b fb ff ff       	call   80107ec6 <mappages>
801083ab:	83 c4 20             	add    $0x20,%esp
    return 0;
  if(newsz < oldsz)
    return oldsz;

  a = PGROUNDUP(oldsz);
  for(; a < newsz; a += PGSIZE){
801083ae:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
801083b5:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083b8:	3b 45 10             	cmp    0x10(%ebp),%eax
801083bb:	0f 82 75 ff ff ff    	jb     80108336 <allocuvm+0x39>
      return 0;
    }
    memset(mem, 0, PGSIZE);
    mappages(pgdir, (char*)a, PGSIZE, v2p(mem), PTE_W|PTE_U);
  }
  return newsz;
801083c1:	8b 45 10             	mov    0x10(%ebp),%eax
}
801083c4:	c9                   	leave  
801083c5:	c3                   	ret    

801083c6 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801083c6:	55                   	push   %ebp
801083c7:	89 e5                	mov    %esp,%ebp
801083c9:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801083cc:	8b 45 10             	mov    0x10(%ebp),%eax
801083cf:	3b 45 0c             	cmp    0xc(%ebp),%eax
801083d2:	72 08                	jb     801083dc <deallocuvm+0x16>
    return oldsz;
801083d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801083d7:	e9 a5 00 00 00       	jmp    80108481 <deallocuvm+0xbb>

  a = PGROUNDUP(newsz);
801083dc:	8b 45 10             	mov    0x10(%ebp),%eax
801083df:	05 ff 0f 00 00       	add    $0xfff,%eax
801083e4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801083e9:	89 45 f4             	mov    %eax,-0xc(%ebp)
  for(; a  < oldsz; a += PGSIZE){
801083ec:	e9 81 00 00 00       	jmp    80108472 <deallocuvm+0xac>
    pte = walkpgdir(pgdir, (char*)a, 0);
801083f1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801083f4:	83 ec 04             	sub    $0x4,%esp
801083f7:	6a 00                	push   $0x0
801083f9:	50                   	push   %eax
801083fa:	ff 75 08             	pushl  0x8(%ebp)
801083fd:	e8 24 fa ff ff       	call   80107e26 <walkpgdir>
80108402:	83 c4 10             	add    $0x10,%esp
80108405:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(!pte)
80108408:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
8010840c:	75 09                	jne    80108417 <deallocuvm+0x51>
      a += (NPTENTRIES - 1) * PGSIZE;
8010840e:	81 45 f4 00 f0 3f 00 	addl   $0x3ff000,-0xc(%ebp)
80108415:	eb 54                	jmp    8010846b <deallocuvm+0xa5>
    else if((*pte & PTE_P) != 0){
80108417:	8b 45 f0             	mov    -0x10(%ebp),%eax
8010841a:	8b 00                	mov    (%eax),%eax
8010841c:	83 e0 01             	and    $0x1,%eax
8010841f:	85 c0                	test   %eax,%eax
80108421:	74 48                	je     8010846b <deallocuvm+0xa5>
      pa = PTE_ADDR(*pte);
80108423:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108426:	8b 00                	mov    (%eax),%eax
80108428:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010842d:	89 45 ec             	mov    %eax,-0x14(%ebp)
      if(pa == 0)
80108430:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
80108434:	75 0d                	jne    80108443 <deallocuvm+0x7d>
        panic("kfree");
80108436:	83 ec 0c             	sub    $0xc,%esp
80108439:	68 0d 8e 10 80       	push   $0x80108e0d
8010843e:	e8 23 81 ff ff       	call   80100566 <panic>
      char *v = p2v(pa);
80108443:	83 ec 0c             	sub    $0xc,%esp
80108446:	ff 75 ec             	pushl  -0x14(%ebp)
80108449:	e8 56 f5 ff ff       	call   801079a4 <p2v>
8010844e:	83 c4 10             	add    $0x10,%esp
80108451:	89 45 e8             	mov    %eax,-0x18(%ebp)
      kfree(v);
80108454:	83 ec 0c             	sub    $0xc,%esp
80108457:	ff 75 e8             	pushl  -0x18(%ebp)
8010845a:	e8 4f a7 ff ff       	call   80102bae <kfree>
8010845f:	83 c4 10             	add    $0x10,%esp
      *pte = 0;
80108462:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108465:	c7 00 00 00 00 00    	movl   $0x0,(%eax)

  if(newsz >= oldsz)
    return oldsz;

  a = PGROUNDUP(newsz);
  for(; a  < oldsz; a += PGSIZE){
8010846b:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108472:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108475:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108478:	0f 82 73 ff ff ff    	jb     801083f1 <deallocuvm+0x2b>
      char *v = p2v(pa);
      kfree(v);
      *pte = 0;
    }
  }
  return newsz;
8010847e:	8b 45 10             	mov    0x10(%ebp),%eax
}
80108481:	c9                   	leave  
80108482:	c3                   	ret    

80108483 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80108483:	55                   	push   %ebp
80108484:	89 e5                	mov    %esp,%ebp
80108486:	83 ec 18             	sub    $0x18,%esp
  uint i;

  if(pgdir == 0)
80108489:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
8010848d:	75 0d                	jne    8010849c <freevm+0x19>
    panic("freevm: no pgdir");
8010848f:	83 ec 0c             	sub    $0xc,%esp
80108492:	68 13 8e 10 80       	push   $0x80108e13
80108497:	e8 ca 80 ff ff       	call   80100566 <panic>
  deallocuvm(pgdir, KERNBASE, 0);
8010849c:	83 ec 04             	sub    $0x4,%esp
8010849f:	6a 00                	push   $0x0
801084a1:	68 00 00 00 80       	push   $0x80000000
801084a6:	ff 75 08             	pushl  0x8(%ebp)
801084a9:	e8 18 ff ff ff       	call   801083c6 <deallocuvm>
801084ae:	83 c4 10             	add    $0x10,%esp
  for(i = 0; i < NPDENTRIES; i++){
801084b1:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
801084b8:	eb 4f                	jmp    80108509 <freevm+0x86>
    if(pgdir[i] & PTE_P){
801084ba:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084bd:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084c4:	8b 45 08             	mov    0x8(%ebp),%eax
801084c7:	01 d0                	add    %edx,%eax
801084c9:	8b 00                	mov    (%eax),%eax
801084cb:	83 e0 01             	and    $0x1,%eax
801084ce:	85 c0                	test   %eax,%eax
801084d0:	74 33                	je     80108505 <freevm+0x82>
      char * v = p2v(PTE_ADDR(pgdir[i]));
801084d2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801084d5:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
801084dc:	8b 45 08             	mov    0x8(%ebp),%eax
801084df:	01 d0                	add    %edx,%eax
801084e1:	8b 00                	mov    (%eax),%eax
801084e3:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801084e8:	83 ec 0c             	sub    $0xc,%esp
801084eb:	50                   	push   %eax
801084ec:	e8 b3 f4 ff ff       	call   801079a4 <p2v>
801084f1:	83 c4 10             	add    $0x10,%esp
801084f4:	89 45 f0             	mov    %eax,-0x10(%ebp)
      kfree(v);
801084f7:	83 ec 0c             	sub    $0xc,%esp
801084fa:	ff 75 f0             	pushl  -0x10(%ebp)
801084fd:	e8 ac a6 ff ff       	call   80102bae <kfree>
80108502:	83 c4 10             	add    $0x10,%esp
  uint i;

  if(pgdir == 0)
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
  for(i = 0; i < NPDENTRIES; i++){
80108505:	83 45 f4 01          	addl   $0x1,-0xc(%ebp)
80108509:	81 7d f4 ff 03 00 00 	cmpl   $0x3ff,-0xc(%ebp)
80108510:	76 a8                	jbe    801084ba <freevm+0x37>
    if(pgdir[i] & PTE_P){
      char * v = p2v(PTE_ADDR(pgdir[i]));
      kfree(v);
    }
  }
  kfree((char*)pgdir);
80108512:	83 ec 0c             	sub    $0xc,%esp
80108515:	ff 75 08             	pushl  0x8(%ebp)
80108518:	e8 91 a6 ff ff       	call   80102bae <kfree>
8010851d:	83 c4 10             	add    $0x10,%esp
}
80108520:	90                   	nop
80108521:	c9                   	leave  
80108522:	c3                   	ret    

80108523 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80108523:	55                   	push   %ebp
80108524:	89 e5                	mov    %esp,%ebp
80108526:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108529:	83 ec 04             	sub    $0x4,%esp
8010852c:	6a 00                	push   $0x0
8010852e:	ff 75 0c             	pushl  0xc(%ebp)
80108531:	ff 75 08             	pushl  0x8(%ebp)
80108534:	e8 ed f8 ff ff       	call   80107e26 <walkpgdir>
80108539:	83 c4 10             	add    $0x10,%esp
8010853c:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if(pte == 0)
8010853f:	83 7d f4 00          	cmpl   $0x0,-0xc(%ebp)
80108543:	75 0d                	jne    80108552 <clearpteu+0x2f>
    panic("clearpteu");
80108545:	83 ec 0c             	sub    $0xc,%esp
80108548:	68 24 8e 10 80       	push   $0x80108e24
8010854d:	e8 14 80 ff ff       	call   80100566 <panic>
  *pte &= ~PTE_U;
80108552:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108555:	8b 00                	mov    (%eax),%eax
80108557:	83 e0 fb             	and    $0xfffffffb,%eax
8010855a:	89 c2                	mov    %eax,%edx
8010855c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010855f:	89 10                	mov    %edx,(%eax)
}
80108561:	90                   	nop
80108562:	c9                   	leave  
80108563:	c3                   	ret    

80108564 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80108564:	55                   	push   %ebp
80108565:	89 e5                	mov    %esp,%ebp
80108567:	53                   	push   %ebx
80108568:	83 ec 24             	sub    $0x24,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010856b:	e8 e6 f9 ff ff       	call   80107f56 <setupkvm>
80108570:	89 45 f0             	mov    %eax,-0x10(%ebp)
80108573:	83 7d f0 00          	cmpl   $0x0,-0x10(%ebp)
80108577:	75 0a                	jne    80108583 <copyuvm+0x1f>
    return 0;
80108579:	b8 00 00 00 00       	mov    $0x0,%eax
8010857e:	e9 f8 00 00 00       	jmp    8010867b <copyuvm+0x117>
  for(i = 0; i < sz; i += PGSIZE){
80108583:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)
8010858a:	e9 c4 00 00 00       	jmp    80108653 <copyuvm+0xef>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010858f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108592:	83 ec 04             	sub    $0x4,%esp
80108595:	6a 00                	push   $0x0
80108597:	50                   	push   %eax
80108598:	ff 75 08             	pushl  0x8(%ebp)
8010859b:	e8 86 f8 ff ff       	call   80107e26 <walkpgdir>
801085a0:	83 c4 10             	add    $0x10,%esp
801085a3:	89 45 ec             	mov    %eax,-0x14(%ebp)
801085a6:	83 7d ec 00          	cmpl   $0x0,-0x14(%ebp)
801085aa:	75 0d                	jne    801085b9 <copyuvm+0x55>
      panic("copyuvm: pte should exist");
801085ac:	83 ec 0c             	sub    $0xc,%esp
801085af:	68 2e 8e 10 80       	push   $0x80108e2e
801085b4:	e8 ad 7f ff ff       	call   80100566 <panic>
    if(!(*pte & PTE_P))
801085b9:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085bc:	8b 00                	mov    (%eax),%eax
801085be:	83 e0 01             	and    $0x1,%eax
801085c1:	85 c0                	test   %eax,%eax
801085c3:	75 0d                	jne    801085d2 <copyuvm+0x6e>
      panic("copyuvm: page not present");
801085c5:	83 ec 0c             	sub    $0xc,%esp
801085c8:	68 48 8e 10 80       	push   $0x80108e48
801085cd:	e8 94 7f ff ff       	call   80100566 <panic>
    pa = PTE_ADDR(*pte);
801085d2:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085d5:	8b 00                	mov    (%eax),%eax
801085d7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801085dc:	89 45 e8             	mov    %eax,-0x18(%ebp)
    flags = PTE_FLAGS(*pte);
801085df:	8b 45 ec             	mov    -0x14(%ebp),%eax
801085e2:	8b 00                	mov    (%eax),%eax
801085e4:	25 ff 0f 00 00       	and    $0xfff,%eax
801085e9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    if((mem = kalloc()) == 0)
801085ec:	e8 5a a6 ff ff       	call   80102c4b <kalloc>
801085f1:	89 45 e0             	mov    %eax,-0x20(%ebp)
801085f4:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801085f8:	74 6a                	je     80108664 <copyuvm+0x100>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
801085fa:	83 ec 0c             	sub    $0xc,%esp
801085fd:	ff 75 e8             	pushl  -0x18(%ebp)
80108600:	e8 9f f3 ff ff       	call   801079a4 <p2v>
80108605:	83 c4 10             	add    $0x10,%esp
80108608:	83 ec 04             	sub    $0x4,%esp
8010860b:	68 00 10 00 00       	push   $0x1000
80108610:	50                   	push   %eax
80108611:	ff 75 e0             	pushl  -0x20(%ebp)
80108614:	e8 b0 ce ff ff       	call   801054c9 <memmove>
80108619:	83 c4 10             	add    $0x10,%esp
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
8010861c:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
8010861f:	83 ec 0c             	sub    $0xc,%esp
80108622:	ff 75 e0             	pushl  -0x20(%ebp)
80108625:	e8 6d f3 ff ff       	call   80107997 <v2p>
8010862a:	83 c4 10             	add    $0x10,%esp
8010862d:	89 c2                	mov    %eax,%edx
8010862f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108632:	83 ec 0c             	sub    $0xc,%esp
80108635:	53                   	push   %ebx
80108636:	52                   	push   %edx
80108637:	68 00 10 00 00       	push   $0x1000
8010863c:	50                   	push   %eax
8010863d:	ff 75 f0             	pushl  -0x10(%ebp)
80108640:	e8 81 f8 ff ff       	call   80107ec6 <mappages>
80108645:	83 c4 20             	add    $0x20,%esp
80108648:	85 c0                	test   %eax,%eax
8010864a:	78 1b                	js     80108667 <copyuvm+0x103>
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010864c:	81 45 f4 00 10 00 00 	addl   $0x1000,-0xc(%ebp)
80108653:	8b 45 f4             	mov    -0xc(%ebp),%eax
80108656:	3b 45 0c             	cmp    0xc(%ebp),%eax
80108659:	0f 82 30 ff ff ff    	jb     8010858f <copyuvm+0x2b>
      goto bad;
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
  }
  return d;
8010865f:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108662:	eb 17                	jmp    8010867b <copyuvm+0x117>
    if(!(*pte & PTE_P))
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
    flags = PTE_FLAGS(*pte);
    if((mem = kalloc()) == 0)
      goto bad;
80108664:	90                   	nop
80108665:	eb 01                	jmp    80108668 <copyuvm+0x104>
    memmove(mem, (char*)p2v(pa), PGSIZE);
    if(mappages(d, (void*)i, PGSIZE, v2p(mem), flags) < 0)
      goto bad;
80108667:	90                   	nop
  }
  return d;

bad:
  freevm(d);
80108668:	83 ec 0c             	sub    $0xc,%esp
8010866b:	ff 75 f0             	pushl  -0x10(%ebp)
8010866e:	e8 10 fe ff ff       	call   80108483 <freevm>
80108673:	83 c4 10             	add    $0x10,%esp
  return 0;
80108676:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010867b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010867e:	c9                   	leave  
8010867f:	c3                   	ret    

80108680 <uva2ka>:

//PAGEBREAK!
// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80108680:	55                   	push   %ebp
80108681:	89 e5                	mov    %esp,%ebp
80108683:	83 ec 18             	sub    $0x18,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80108686:	83 ec 04             	sub    $0x4,%esp
80108689:	6a 00                	push   $0x0
8010868b:	ff 75 0c             	pushl  0xc(%ebp)
8010868e:	ff 75 08             	pushl  0x8(%ebp)
80108691:	e8 90 f7 ff ff       	call   80107e26 <walkpgdir>
80108696:	83 c4 10             	add    $0x10,%esp
80108699:	89 45 f4             	mov    %eax,-0xc(%ebp)
  if((*pte & PTE_P) == 0)
8010869c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010869f:	8b 00                	mov    (%eax),%eax
801086a1:	83 e0 01             	and    $0x1,%eax
801086a4:	85 c0                	test   %eax,%eax
801086a6:	75 07                	jne    801086af <uva2ka+0x2f>
    return 0;
801086a8:	b8 00 00 00 00       	mov    $0x0,%eax
801086ad:	eb 29                	jmp    801086d8 <uva2ka+0x58>
  if((*pte & PTE_U) == 0)
801086af:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086b2:	8b 00                	mov    (%eax),%eax
801086b4:	83 e0 04             	and    $0x4,%eax
801086b7:	85 c0                	test   %eax,%eax
801086b9:	75 07                	jne    801086c2 <uva2ka+0x42>
    return 0;
801086bb:	b8 00 00 00 00       	mov    $0x0,%eax
801086c0:	eb 16                	jmp    801086d8 <uva2ka+0x58>
  return (char*)p2v(PTE_ADDR(*pte));
801086c2:	8b 45 f4             	mov    -0xc(%ebp),%eax
801086c5:	8b 00                	mov    (%eax),%eax
801086c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086cc:	83 ec 0c             	sub    $0xc,%esp
801086cf:	50                   	push   %eax
801086d0:	e8 cf f2 ff ff       	call   801079a4 <p2v>
801086d5:	83 c4 10             	add    $0x10,%esp
}
801086d8:	c9                   	leave  
801086d9:	c3                   	ret    

801086da <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801086da:	55                   	push   %ebp
801086db:	89 e5                	mov    %esp,%ebp
801086dd:	83 ec 18             	sub    $0x18,%esp
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
801086e0:	8b 45 10             	mov    0x10(%ebp),%eax
801086e3:	89 45 f4             	mov    %eax,-0xc(%ebp)
  while(len > 0){
801086e6:	eb 7f                	jmp    80108767 <copyout+0x8d>
    va0 = (uint)PGROUNDDOWN(va);
801086e8:	8b 45 0c             	mov    0xc(%ebp),%eax
801086eb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801086f0:	89 45 ec             	mov    %eax,-0x14(%ebp)
    pa0 = uva2ka(pgdir, (char*)va0);
801086f3:	8b 45 ec             	mov    -0x14(%ebp),%eax
801086f6:	83 ec 08             	sub    $0x8,%esp
801086f9:	50                   	push   %eax
801086fa:	ff 75 08             	pushl  0x8(%ebp)
801086fd:	e8 7e ff ff ff       	call   80108680 <uva2ka>
80108702:	83 c4 10             	add    $0x10,%esp
80108705:	89 45 e8             	mov    %eax,-0x18(%ebp)
    if(pa0 == 0)
80108708:	83 7d e8 00          	cmpl   $0x0,-0x18(%ebp)
8010870c:	75 07                	jne    80108715 <copyout+0x3b>
      return -1;
8010870e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80108713:	eb 61                	jmp    80108776 <copyout+0x9c>
    n = PGSIZE - (va - va0);
80108715:	8b 45 ec             	mov    -0x14(%ebp),%eax
80108718:	2b 45 0c             	sub    0xc(%ebp),%eax
8010871b:	05 00 10 00 00       	add    $0x1000,%eax
80108720:	89 45 f0             	mov    %eax,-0x10(%ebp)
    if(n > len)
80108723:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108726:	3b 45 14             	cmp    0x14(%ebp),%eax
80108729:	76 06                	jbe    80108731 <copyout+0x57>
      n = len;
8010872b:	8b 45 14             	mov    0x14(%ebp),%eax
8010872e:	89 45 f0             	mov    %eax,-0x10(%ebp)
    memmove(pa0 + (va - va0), buf, n);
80108731:	8b 45 0c             	mov    0xc(%ebp),%eax
80108734:	2b 45 ec             	sub    -0x14(%ebp),%eax
80108737:	89 c2                	mov    %eax,%edx
80108739:	8b 45 e8             	mov    -0x18(%ebp),%eax
8010873c:	01 d0                	add    %edx,%eax
8010873e:	83 ec 04             	sub    $0x4,%esp
80108741:	ff 75 f0             	pushl  -0x10(%ebp)
80108744:	ff 75 f4             	pushl  -0xc(%ebp)
80108747:	50                   	push   %eax
80108748:	e8 7c cd ff ff       	call   801054c9 <memmove>
8010874d:	83 c4 10             	add    $0x10,%esp
    len -= n;
80108750:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108753:	29 45 14             	sub    %eax,0x14(%ebp)
    buf += n;
80108756:	8b 45 f0             	mov    -0x10(%ebp),%eax
80108759:	01 45 f4             	add    %eax,-0xc(%ebp)
    va = va0 + PGSIZE;
8010875c:	8b 45 ec             	mov    -0x14(%ebp),%eax
8010875f:	05 00 10 00 00       	add    $0x1000,%eax
80108764:	89 45 0c             	mov    %eax,0xc(%ebp)
{
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80108767:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010876b:	0f 85 77 ff ff ff    	jne    801086e8 <copyout+0xe>
    memmove(pa0 + (va - va0), buf, n);
    len -= n;
    buf += n;
    va = va0 + PGSIZE;
  }
  return 0;
80108771:	b8 00 00 00 00       	mov    $0x0,%eax
}
80108776:	c9                   	leave  
80108777:	c3                   	ret    
