# CPU, do as I say!

*CpuHints* is a package for the Julia programming language that enables you to
give your CPU hints about when data is best read into cache, or written back to
main memory.  Furthermore, you may place fences to manipulate instruction
re-ordering with respect to memory loads and stores.  Primary goal is to improve
accuracy of benchmarks.

[![Build Status](https://travis-ci.org/m-j-w/CpuHints.jl.svg?branch=master)](https://travis-ci.org/m-j-w/CpuHints.jl)
[![Build Status](https://ci.appveyor.com/api/projects/status/86c7vqay8ra57rym?svg=true)](https://ci.appveyor.com/project/m-j-w/cpuhints-jl)
[![codecov](https://codecov.io/gh/m-j-w/CpuHints.jl/branch/master/graph/badge.svg)](https://codecov.io/gh/m-j-w/CpuHints.jl)

_Status: considered a pre-beta version, ready for you to try out._

[![CpuId](http://pkg.julialang.org/badges/CpuHints_0.5.svg)](http://pkg.julialang.org/?pkg=CpuHints)
[![CpuId](http://pkg.julialang.org/badges/CpuHints_0.6.svg)](http://pkg.julialang.org/?pkg=CpuHints)

Works on Julia 0.5 and 0.6, on Linux, Mac and Windows with Intel compatible CPUs.


## Motivation

Modern CPUs do a hell of a job in trying to predict what's gonna happen next,
which data is to be read or written from and to memory, and how the low level
instructions could be best re-ordered to squeeze the last bit or performance out
of the hardware.

However, in some rare cases, the programmer knows more, or is in need of
provoking a specific behaviour.  One of these reasons is benchmarking, where
a specific state of caches is sought, whether 'cold' or 'hot'.

Giving the CPU such hints is attained by emitting special CPU instructions that
have little or even no run-time overhead after compilation.

The full documentation of CPU instructions is found in Intel's 4670 page combined [Architectures
Software Devleoper Manual](
http://www.intel.com/content/www/us/en/architecture-and-technology/64-ia-32-architectures-software-developer-manual-325462.html).

Secondly, this packages serves as an example on how the related package `CpuId`
could be used in real-life code.


## Installation and Usage

*CpuHints* is a registered Julia package; use the package manager to install:

    Julia> Pkg.add("CpuHints")

Or, if you're keen to get some intermediate updates, clone from GitHub
[master branch](https://github.com/m-j-w/CpuId.jl/tree/master):

    Julia> Pkg.clone("https://github.com/m-j-w/CpuHints.jl")


## Features

After `using CpuHints`, you have the following functions at your disposal:

 - `prefetch`, `prefetcht0`, `prefetcht1`, `prefetcht2` to ask the CPU kindly to
     load a piece of memory into the cache hierarchy.
 - `prefetchw` to ask the CPU to prepare writing to a given piece of memory.
 - `clflush` and `clflushopt` to write modified data to main memory and
     invalidate the cache.
 - `clwb` to write modified data to main memory, but keep it in the cache.
 - `lfence`, `sfence` to build fences where instruction re-ordering with respect
     to memory loads (l) and stores (s) must not happen, or `mfence` for both
     loads and stores.

Furthermore, there are two barrier functions that prevent LLVM from eliminating
function calls when their result seems to be omitted – as it is typically the
case in benchmarking:
 - `reorder_barrier()` fakes a manipulation of all memory, wheres
 - `elimination_barrier(ptr)` fakes a change of the underlying data,
both with side effects impossible to infer by the compiler.


## Limitations

Tampering with the low-level mechanisms of how caches are to be operated and how
instruction reordering is to be performed is in most cases an extremely stupid
idea.  In most cases, the CPU is better in determining what needs to be done,
and as a consequence the overall performance will go down.

Furthermore, not all instructions are available on all CPUs, hence the
requirement of the package `CpuId` to ensure safe operation.

Finally, the current release is only providing the low-level equivalents of said
instructions;  higher level functions e.g. to evict or prefetch a whole array
are future features.


## Terms of usage

This Julia package *CpuHints* is published as open source and licensed under the
[MIT "Expat" License](./LICENSE.md).


**Contributions welcome!**

Show that you like this package by giving it a GitHub star. Thanks!  You're also
highly welcome to report successful usage or any issues via GitHub, and to open
pull requests to extend the current functionality.

