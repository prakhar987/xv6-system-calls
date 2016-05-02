Here we try to create a basic system-call. The first step is to extend the
current proc structure and add new fields ctime, etime and rtime for
creation time, end-time and total time respectively of a process. 
When a new process gets created the kernel code should update the process
creation time. The run-time should get updated after every clock tick for
the process. To extract this information from the kernel add a new system
call which extends wait. The new call will be

 int waitx(int *wtime, int *rtime)
 
The two arguments are pointers to integers to which waitx will assign the
total number of clock ticks during which process was waiting and total
number of clock ticks when the process was running. The return values for
waitx should be same as that of wait system-call.
Created a test program which utilises the waitx system-call by creating a
‘time’ like command for the same. 


1) ADDING SYSTEM CALL :

- waitx() system call was added modifying user.h , usys.S , syscall.h
,syscall.c , sysproc.c , defs.h .
- proc.c contains the actual waitx() system call. Copied the code of wait() and modified it as
follows -
-Searched for a zombie child of parent in the proc table.
-When the child was found , following pointers were updated :
*wtime= p->etime - p->ctime1 - p->rtime - p->iotime;
*rtime=p->rtime;
-sysproc.c is just used to call waitx() which is present in proc.c . The sys_waitx() function in
sysproc.c although does one job - it passes the
parameters (rtime,wtime) to the waitx() of proc.c , just like all other system calls do.
2) MODIFICATIONS DONE TO proc structure

- ctime1 (records CREATION TIME) , etime (records END TIME) , rtime (calculates RUN TIME)
& iotime (calculates IO TIME ) fields added to
proc structure of proc.h file
3) HOW ctime,etime & rtime ARE CALCULATED :

- ctime is recoreded in allocproc() function of proc.c.(When process is born)
- etime is recorded in exit() function (i.e when child exists, ticks are recorded) of proc.c.
- rtime is updated in trap() function of trap.c .(IF STATE IS RUNNING , THEN UPDATE rtime)
- iotime is updated in trap() function of trap.c.(IF STATE IS SLEEPING , THEN UPDATE wtime)
4) THE time COMMAND

-time inputs a command and exec it normally.
- the only thing different is that it uses 'waitx()' instead of normal wait().
-at end it displays rtime and wtime.
-status returned is also displayed.
-to get status(IN QUESTION IT WAS ASKED TO RETURN SAME STATUS AS wait() ) wait()
is called from within waitx().

(Install QEMU Emulator , then run the Xv6 code)
