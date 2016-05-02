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
