using Base.Test
using CpuHints
using CpuId

@testset "Result Types" begin

    a = [1,2,3,4]
    p = pointer(a)

    @test isa( lfence(), Void )
    @test isa( mfence(), Void )
    @test isa( sfence(), Void )

    @test isa( prefetch(p),    Void )
    @test isa( prefetcht0(p),  Void )
    @test isa( prefetcht1(p),  Void )
    @test isa( prefetcht2(p),  Void )
    @test isa( prefetchnta(p), Void )
    @test isa( prefetchw(p),   Void )

    @test isa( clflush(p),     Void )
    @test isa( clflushopt(p),  Void )
    @test isa( clwb(p),        Void )

    @test isa( reorder_barrier(),      Void )
    @test isa( elimination_barrier(p), Void )

end

