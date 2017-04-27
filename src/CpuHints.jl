"""
# Module CpuHints

The module `CpuHints` enables to emit low-level CPU instructions that aim at
optimising or manipulating how data caches are operated and where instruction
re-ordering related to memory access is undesirable.

Primary targeted is to improve benchmarking, but potentially also for
low-level optimisations of tight memory or bandwidth bound algorithms.
"""
module CpuHints


export lfence, sfence, mfence, prefetch, prefetcht0, prefetcht1, prefetcht2,
       prefetchnta, prefetchw, clflush, clflushopt, clwb, reorder_barrier,
       elimination_barrier

using Base:  llvmcall, @_inline_meta
using CpuId: cpufeature, CLWB, CLFSH, CLFLUSH, PREFETCHW, SSE, SSE2


"""
    lfence()

Load memory fence: The LFENCE instruction prevents the CPU from re-ordering
speculative loads from memory to pass the fence.  That is, loads will not be
performed prior to the fence if the load instruction is located after the
fence, and vice versa.

The LFENCE instruction requires SSE2 extensions.
"""
function lfence end

__lfence() = (@_inline_meta; llvmcall(
      raw"""
        tail call void asm sideeffect "lfence", "~{memory},~{dirflag},~{fpsr},~{flags}"()
        ret void
      """
    , Void, Tuple{}
   ))


"""
    sfence()

Store memory fence: The SFENCE instruction prevents the CPU from re-ordering
deferred stores to memory to pass the fence.  That is, stores will not be
performed after the fence if the store instruction is located before the
fence, and vice versa.

The SFENCE instruction requires SSE extensions.
"""
function sfence end

__sfence() = (@_inline_meta; llvmcall(
      raw"""
        tail call void asm sideeffect "sfence", "~{memory},~{dirflag},~{fpsr},~{flags}"()
        ret void
      """
    , Void, Tuple{}
   ))


"""
    mfence()

Load and store memory fence: The MFENCE instruction prevents the CPU from
re-ordering deferred stores and speculative loads to and from the memory to
pass the fence.  That is, stores will not be performed after the fence if the
store instruction is located before the fence, and loads will not be performed
prior to the fence if the load instruction is located after the fence, and vice
versa.  The MFENCE instruction is a such the combination of an LFENCE and
SFENCE.

The MFENCE instruction requires SSE2 extensions.
"""
function mfence end

__mfence() = (@_inline_meta; llvmcall(
      raw"""
        tail call void asm sideeffect "mfence", "~{memory},~{dirflag},~{fpsr},~{flags}"()
        ret void
      """
    , Void, Tuple{}
   ))


"""
    prefetch(ptr::Ptr)

Load the memory block of size of one cache line that associated with the given
address into a higher cache level.  The target cache level is CPU-wise
implementation dependent.
"""
prefetch(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "prefetch $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))

"""
    prefetcht0(ptr::Ptr)

Load the memory block of size of one cache line that is associated with the
given address into the lowest cache hierarchy (L1 cache).  The CPU is free to
ignore this request.
"""
prefetcht0(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "prefetcht0 $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


"""
    prefetcht1(ptr::Ptr)

Load the memory block of size of one cache line that is associated with the
given address into the second lowest cache hierarchy (L2 cache).  The CPU is free to
ignore this request.
"""
prefetcht1(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "prefetcht1 $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


"""
    prefetcht2(ptr::Ptr)

Load the memory block of size of one cache line that is associated with the
given address into the third lowest cache hierarchy (L3 cache).  The CPU is free to
ignore this request.
"""
prefetcht2(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "prefetcht2 $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


"""
    prefetchnta(ptr::Ptr)

Prepare to load the memory block of size of one cache line that is associated
with the given address into the CPU, bypassing the cache hierarchy
(non-temporal load). The CPU is free to ignore this request.
"""
prefetchnta(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "prefetchnta $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


"""
    prefetchw(ptr::Ptr)

Load the memory block of size of one cache line that is associated
with the given address into the CPU, in anticipation of a subsequent write to
same address.  This also invalidates the cache line for other cores the cache
line might be shared with.  The CPU is free to ignore this request.

Requires a CPU having the cpuid feature flag PREFETCHW set.
"""
function prefetchw end

__prefetchw(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "prefetchw $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


"""
    clflush(ptr::Ptr)

Write and invalidate a cache line from all levels of the CPU's cache
hierarchy, if the associated cache line is present.

Requires a CPU having the cpuid feature flag CLFSH set, leaf 0x01, EDX[19].
"""
function clflush end

__clflush(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "clflush $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


"""
    clflushopt(ptr::Ptr)

Write and invalidate a cache line from all levels of the CPU's cache
hierarchy, if the associated cache line is present, with optimised memory
throughput.

Requires a CPU having the cpuid feature flag CLFLUSH set, leaf 0x07, EBX[23].
"""
function clflushopt end

__clflushopt(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "clflush $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


"""
    clwb(ptr)

Write a cache line back to main memory, if modified, but may retain the data
in the cache hierarchy for future use.

Requires a CPU having the cpuid feature flag CLWB set, leaf 0x07, EBX[24].
"""
function clwb end

__clwb(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        call void asm sideeffect "clwb $0", "*m,~{dirflag},~{fpsr},~{flags}"(i8* nonnull %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


#
#  Compiler-related functions
#

"""
    reorder_barrier()

Prevent LLVM from reordering any instructions from before to after or vice
versa relative to this barrier.  This is attained by emitting a fake
instruction that pretends to manipulate all of the memory, and LLVM couldn't
possibly infer what has happened, and, hence, must keep everything in
sequence.
"""
reorder_barrier() = (@_inline_meta; llvmcall(
      raw"""
        tail call void asm sideeffect "", "~{memory},~{dirflag},~{fpsr},~{flags}"()
        ret void
      """
    , Void, Tuple{}
   ))


"""
    elimination_barrier(ptr::Ptr)

Prevent LLVM from eliminating function calls related to data associated
with memory address `ptr` by emitting a fake instruction that pretends to
manipulate that piece of memory.  This is, so to say, a 'touch ptr' function.
"""
elimination_barrier(ptr::Ptr) = (@_inline_meta; llvmcall(
      raw"""
        tail call void asm sideeffect "", "imr,~{memory},~{dirflag},~{fpsr},~{flags}"(i8* %0)
        ret void
      """
    , Void, Tuple{Ptr{Void}}
    , Ptr{Void}(ptr)
   ))


"""
    __noop()
    __noop(ptr)

A do-nothing function for unsupported CPU instructions.  Chosen at module
initialisation time to prevent undesired process termination signals from the
operating system due to illegal instruction errors.
"""
function __noop end

__noop() = info("This instruction is not supported by this CPU.")
__noop(ptr::Ptr) = info("This instruction is not supported by this CPU.")


#
# Module initialisation:
# Enable/Disable all functions for which we have no CPU support
#

function __init__()
    eval( :(sfence()      = cpufeature(:SSE)       ? __sfence()      : __noop() ) )
    eval( :(lfence()      = cpufeature(:SSE2)      ? __lfence()      : __noop() ) )
    eval( :(mfence()      = cpufeature(:SSE2)      ? __mfence()      : __noop() ) )
    eval( :(prefetchw(p)  = cpufeature(:PREFETCHW) ? __prefetchw(p)  : __noop(p) ) )
    eval( :(clflush(p)    = cpufeature(:CLFSH)     ? __clflush(p)    : __noop(p) ) )
    eval( :(clflushopt(p) = cpufeature(:CLFLUSH)   ? __clflushopt(p) : __noop(p) ) )
    eval( :(clwb(p)       = cpufeature(:CLWB)      ? __clwb(p)       : __noop(p) ) )
end

end # module CpuHints

