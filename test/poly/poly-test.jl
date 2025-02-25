@testset "poly.constructors" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])
   R1, (x, ) = polynomial_ring(ZZ, [:x, ])
   @test R == R1

   @test elem_type(R) == spoly{n_Z}
   @test elem_type(PolyRing{n_Z}) == spoly{n_Z}
   @test parent_type(spoly{n_Z}) == PolyRing{n_Z}
   @test base_ring(R) == ZZ

   @test R isa Nemo.Ring

   a = R()

   @test base_ring(a) == ZZ
   @test parent(a) == R

   @test isa(a, spoly)

   b = R(123)

   @test isa(b, spoly)

   c = R(BigInt(123))

   @test isa(c, spoly)

   d = R(c)

   @test isa(d, spoly)

   f = R(Nemo.ZZ(123))

   @test isa(f, spoly)

   g = R(ZZ(123))

   @test isa(g, spoly)

   S, (y, ) = polynomial_ring(QQ, ["y", ])

   h = S(ZZ(123))

   @test isa(h, spoly)

   T, (z, ) = polynomial_ring(Nemo.ZZ, ["z", ])

   k = T(123)

   @test isa(k, spoly)

   S = @polynomial_ring(ZZ, "x", 50)

   @test isa(x17, spoly)

   T = @polynomial_ring(ZZ, "y", 50, :lex)

   @test isa(y7, spoly)

   R, (x, y) = polynomial_ring(QQ, ["x", "y"])

   @test is_gen(x)
   @test is_gen(y)
   @test !is_gen(R(1))
   @test !is_gen(R(0))
   @test !is_gen(2x)
   @test !is_gen(x + y)
   @test !is_gen(x^2)

   @test has_global_ordering(R)
   @test !has_local_ordering(R)
   @test !has_mixed_ordering(R)

   @test length(symbols(R)) == 2
   @test symbols(R) == [:x, :y]

   R, (x, y) = polynomial_ring(ZZ, ["x", "y"]; ordering=:lex)

   M = MPolyBuildCtx(R)
   push_term!(M, ZZ(2), [1, 2])
   push_term!(M, ZZ(1), [1, 1])
   push_term!(M, ZZ(2), [3, 2])
   f = finish(M)

   @test f == 2*x^3*y^2+2*x*y^2+x*y
end

@testset "poly.printing" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   @test length(string(3x^2 + 2x + 1)) > 3
   @test length(sprint(show, "text/plain", 3x^2 + 2x + 1)) > 3

   R, (x, ) = polynomial_ring(QQ, ["x", ])

   @test length(string(3x^2 + 2x + 1)) > 3
   @test length(sprint(show, "text/plain", 3x^2 + 2x + 1)) > 3

   R, (x, ) = polynomial_ring(Fp(5), ["x", ])

   @test length(string(3x^2 + 2x + 1)) > 3
   @test length(sprint(show, "text/plain", 3x^2 + 2x + 1)) > 3

   R, (x, ) = polynomial_ring(residue_ring(ZZ, 5), ["x", ])

   @test length(string(3x^2 + 2x + 1)) > 3
   @test length(sprint(show, "text/plain", 3x^2 + 2x + 1)) > 3

   R, (x, ) = polynomial_ring(FiniteField(5, 3, "a")[1], ["x", ])
   @test string(x) == "x"

   # the answers should be printed in reduced form.
   R, (x,) = polynomial_ring(QQ, ["x"])
   @test string((QQ(1//2) + QQ(3//2)*x)(1)) == "2"

   Qa, (a,) = FunctionField(QQ, ["a"])
   R, (x,) = polynomial_ring(Qa, ["x"])
   @test string((1//a + (1)//(a-1)*x + (a-1)//a*x^2)(1)) == "a//(a - 1)"
   @test string((1//a + (1)//(a-1)*x + (a^2-3*a+1)//(a^2-a)*x^2)(1)) == "1"
end

@testset "poly.rename" begin
   s = ["x[1]", "x[2]", "x[3]"]
   R, x = polynomial_ring(QQ, s)
   @test String.(symbols(R)) == s
   @test String.(Singular.singular_symbols(R)) == ["x_1", "x_2", "x_3"]

   s = ["x[1][2]", "\$", "x[2][3]", "x[3][4]"]
   R, x = polynomial_ring(QQ, s)
   @test String.(symbols(R)) == s
   @test String.(Singular.singular_symbols(R)) == ["x_1_2", "x", "x_2_3", "x_3_4"]

   s = ["t[1]", "\$", "t[2]", "t[3]", "t[1]"]
   F, t = FunctionField(QQ, s)
   @test String.(symbols(F)) == s
   @test String.(Singular.singular_symbols(F)) == ["t_1", "t", "t_2", "t_3", "t_1@1"]

   s = ["t[1]", "\$", "t[2]", "t[3]", "t[1]"]
   R, x = polynomial_ring(F, s)
   @test String.(symbols(R)) == s
   @test String.(Singular.singular_symbols(R)) == ["t_1@2", "x", "t_2@1", "t_3@1", "t_1@3"]

   F, a = FiniteField(3, 1, "\$")
   @test String.(Singular.singular_symbols(F)) == []

   F, a = FiniteField(3, 2, "\$")
   s = ["a", "\$", "t[1]", "t[2]", "t[1]"]
   R, x = polynomial_ring(F, s)
   @test String.(Singular.singular_symbols(F)) == ["a"]
   @test String.(symbols(R)) == s
   @test String.(Singular.singular_symbols(R)) == ["a@1", "x", "t_1", "t_2", "t_1@1"]
end

@testset "poly.manipulation" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   @test isone(one(R))
   @test iszero(zero(R))
   @test is_unit(R(1)) && is_unit(R(-1))
   @test !is_unit(R(2)) && !is_unit(R(0)) && !is_unit(x)
   @test is_gen(x)
   @test !is_gen(R(1)) && !is_gen(x + 1)
   @test is_constant(R(0)) && is_constant(R(1))
   @test !is_constant(x) && !is_constant(x + 1)
   @test is_monomial(x) && is_monomial(R(1))
   @test !is_monomial(2x) && !is_monomial(x + 1)
   @test is_term(2x) && !is_term(x + 1)
   @test length(x^2 + 2x + 1) == 3
   @test total_degree(x^2 + 2x + 1) == 2
   @test order(x^2 + 2x + 1) == 0

   @test leading_exponent_vector(x^3 + 2x + 1) == [3]
   @test_throws ArgumentError leading_exponent_vector(zero(R))

   @test deepcopy(x + 2) == x + 2

   @test characteristic(R) == 0

   @test nvars(R) == 1
   pol = x^5 + 3x + 2

   @test length(collect(coefficients(pol))) == length(pol)
   @test length(collect(exponent_vectors(pol))) == length(pol)

   polzip = zip(coefficients(pol), monomials(pol), terms(pol))
   r = R()
   for (c, m, t) in polzip
      r += c*m
      @test t == c*m
   end

   @test pol == r

   R, (x, ) = polynomial_ring(residue_ring(ZZ, 6), ["x", ])

   @test characteristic(R) == 6

   R, (x, y) = polynomial_ring(QQ, ["x", "y"])
   p = x + y
   q = x
   @test Singular.substitute_variable(p, 2, q) == 2*x
   @test Singular.permute_variables(q, [2, 1], R) == y

   @test x * QQ(2) == QQ(2) * x
   @test x * 2 == 2 * x

   for i = 1:nvars(R)
      @test gen(R, i) == gens(R)[i]
   end
   @test gen(R, 1) == x

   @test is_ordering_symbolic(R)
   @test ordering_as_symbol(R) == :degrevlex
   @test degree(x^2*y^3 + 1, 1) == 2
   @test degree(x^2*y^3 + 1, y) == 3
   @test degree(R(), 1) == -1
   @test degrees(x^2*y^3) == [2, 3]
   @test vars(x^2 + 3x + 1) == [x]
   @test var_index(x) == 1 && var_index(y) == 2
   @test tail(3x^2*y + 2x*y + y + 7) == 2x*y + y + 7
   @test tail(R(1)) == 0
   @test tail(R()) == 0
   @test leading_coefficient(zero(R)) == 0
   @test leading_coefficient(3x^2 + 2x + 1) == 3
   @test constant_coefficient(x^2*y + 2x + 3) == 3
   @test constant_coefficient(x^2 + y) == 0
   @test_throws ArgumentError leading_monomial(zero(R))
   @test_throws ArgumentError leading_term(zero(R))
   @test leading_monomial(3x^2 + 2x + 1) == x^2
   @test leading_term(3x^2 + 2x + 1) == 3x^2
   @test trailing_coefficient(3x^2*y + 2x + 7y + 9) == 9
   @test trailing_coefficient(5x) == 5
   @test trailing_coefficient(R(3)) == 3
   @test trailing_coefficient(R()) == 0
end

@testset "poly.QuotientRing" begin
    R, (x,y) = polynomial_ring(QQ, ["x", "y"])
    Q, (a,b) = QuotientRing(R, Ideal(R, x-y))
    @test iszero(a-b)
    @test (a-b) == Q(0)
    @test a == b
end

@testset "poly.change_base_ring" begin
   R1, (x, ) = polynomial_ring(ZZ, ["x", ])

   a1 = x^2 + 3x + 1

   b1 = change_base_ring(QQ, a1)

   @test isa(b1, spoly{n_Q})

   R2, (x, y) = polynomial_ring(ZZ, ["x", "y"])
   a2 = x^5 + y^3 + 1

   R3, (x, y) = polynomial_ring(QQ, ["x", "y"])
   a3 = x^5+y^3+1

   R4, (x, y) = polynomial_ring(Nemo.QQ, ["x", "y"])
   a4 = x^5+y^3+1

   a5 = change_base_ring(QQ, a2)
   a6 = change_base_ring(CoefficientRing(Nemo.QQ), a2)

   @test a3 == a5
   @test a4 == a6
end

@testset "poly.multivariate_coeff" begin
   R, (x, y) = polynomial_ring(ZZ, ["x", "y"])

   f = 2x^2*y^2 + 3x*y^2 - x^2*y + 4x*y - 5y + 1

   @test coeff(f, [2], [1]) == -x^2 + 4x - 5
   @test coeff(f, [y], [1]) == -x^2 + 4x - 5
end

@testset "poly.unary_ops" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   a = x^2 + 3x + 1

   @test -a == -x^2 - 3x - 1
end

@testset "poly.binary_ops" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   a = x^2 + 3x + 1
   b = 2x + 4

   @test a + b == x^2+5*x+5
   @test a - b == x^2+x-3
   @test a*b == 2*x^3+10*x^2+14*x+4
end

@testset "poly.comparison" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   a = x^2 + 3x + 1

   @test a == deepcopy(a)
   @test a != x
end

@testset "poly.powering" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   a = x^2 + 3x + 1

   @test a^0 == 1
   @test a^1 == x^2 + 3x + 1
   @test a^3 == x^6+9*x^5+30*x^4+45*x^3+30*x^2+9*x+1

   @test_throws DomainError a^(-rand(1:99))
   if sizeof(Cint) < sizeof(Int)
      @test_throws DomainError a^typemax(Int)
   end
end

@testset "poly.exact_division" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   a = x^2 + 3x + 1
   b = 2x + 4

   @test divexact(a*b, a) == b
end

@testset "poly.adhoc_exact_division" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   a = x^2 + 3x + 1

   @test divexact(2a, 2) == a
   @test divexact(2a, BigInt(2)) == a
   @test divexact(2a, ZZ(2)) == a

   R, (x, ) = polynomial_ring(QQ, ["x", ])

   a = x^2 + 3x + 1

   @test divexact(2a, 2) == a
   @test divexact(2a, BigInt(2)) == a
   @test divexact(2a, ZZ(2)) == a
   @test divexact(2a, 2//3) == 3a
   @test divexact(2a, QQ(2//3)) == 3a
   @test divexact(2a, BigInt(2)//3) == 3a
end

@testset "poly.adhoc_binary_operation" begin
   R, (x, ) = polynomial_ring(QQ, ["x", ])

   a = x^2 + 3x + 1

   @test Nemo.QQ(2)*a == 2*a
   @test a*Nemo.QQ(2) == 2*a
   @test Nemo.QQ(2) + a == 2 + a
   @test a + Nemo.QQ(2) == 2 + a
   @test divexact(2a, Nemo.QQ(2)) == a
end

@testset "poly.euclidean_division" begin
   for k in [QQ, Nemo.QQ]
      R, (x, y) = polynomial_ring(k, ["x", "y"])

      a = x^2*y^2 + 3x + 1
      b = x*y + 1

      q, r = divrem(a, b)
      @test a == b*q + r
      @test q == div(a, b)
      @test r == reduce(a, b)
   end
end

@testset "poly.divides" begin
   for k in [QQ, Nemo.QQ]
      R, (x, y) = polynomial_ring(k, ["x", "y"])

      a = x^2 + 3x + 1
      b = x*y + 1

      flag, q = divides(a*b, b)
      @test flag && q == a
      @test iszero(reduce(a*b, b))

      flag, q = divides(a, y)
      @test !flag
      @test !iszero(reduce(a, y))

      val, q = remove(a*b^3, b)
      @test val == 3 && q == a
      @test valuation(a*b^3, b) == 3
   end
end

@testset "poly.gcd_lcm" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])
   a = x^2 + 3x + 1
   b = 2x + 4
   c = 2x^2 + 1

   @test gcd(a*c, b*c) == c

   @test lcm(a, b) == a*b

   @test primpart(2*a) == a

   @test content(2*a) == 2
end

@testset "poly.extended_gcd" begin
   for k in [QQ, Nemo.QQ]
      R, (x, ) = polynomial_ring(k, ["x", ])

      a = x^2 + 3x + 1
      b = 2x + 4

      if k == Nemo.QQ
         @test_throws Exception gcdx(a, b)
      else
         g, s, t = gcdx(a, b)
         @test !iszero(g)
         @test s*a + t*b == g
      end
   end
end

@testset "poly.evaluate" begin
   R, (x, y) = polynomial_ring(QQ, ["x", "y"])

   f = x^2*y + 2x + 1

   @test evaluate(f, [2, 3]) == 17
   @test evaluate(f, [ZZ(2), ZZ(3)]) == 17
   @test evaluate(f, [QQ(2), QQ(3)]) == 17
   @test evaluate(f, [x + 1, y - 1]) == x^2*y - x^2 + 2*x*y + y + 2
   @test evaluate(f, [x], [1]) == y + 3
   @test f(2, 3) == 17
end

@testset "poly.inflation_deflation" begin
   R, (x, y) = polynomial_ring(ZZ, ["x", "y"])

   f = x^7*y^7 + 3x^4*y^4 + 2x*y

   @test inflate(deflate(f, deflation(f)...), deflation(f)...) == f
end

@testset "poly.Polynomials" begin
   R, (x, ) = polynomial_ring(ZZ, ["x", ])

   S, y = Nemo.polynomial_ring(R, "y")

   f = (1 + 2x + 3x^2)*y + (2x + 3)

   g = f^2

   @test g == (9*x^4+12*x^3+10*x^2+4*x+1)*y^2+(12*x^3+26*x^2+16*x+6)*y+(4*x^2+12*x+9)
end

@testset "poly.convert_Nemo.MPoly_to_Singular.spoly" begin
   R, (x, y, z) = Nemo.polynomial_ring(Nemo.QQ, ["x", "y", "z"])
   S, (a, b, c) = polynomial_ring(QQ, ["a", "b", "c"])

   f = x^2+y^3+z^5

   @test S(f) == a^2+b^3+c^5
end

@testset "poly.test_spoly_differential" begin
   R, (x, y) = polynomial_ring(QQ, ["x", "y"])

   f = x^3 + y^6

   J1 = @inferred jacobian_ideal(f)
   J2 = @inferred jacobian_matrix(f)
   f1 = @inferred derivative(f, 1)
   f2 = @inferred derivative(f, y)
   jf = @inferred jet(f, 3)
   J3 = @inferred jacobian_matrix([f, jf])

   @test f == x^3 + y^6

   I = Ideal(R, x^2, y^5)
   Z1 = zero_matrix(R, 2, 1)
   Z1[1, 1] = 3*x^2
   Z1[2, 1] = 6 * y^5

   Z2 = zero_matrix(R, 2, 2)
   Z2[1, 1] = f1
   Z2[1, 2] = f2
   Z2[2, 1] = 3*x^2
   Z2[2, 2] = R(0)

   # Check derivative
   @test f1 == 3*x^2
   @test f2 == 6*y^5

   #Check jacobians
   @test equal(I, J1)
   @test J2 == Z1
   @test J3 == Z2

   #Check jet
   @test jf == x^3
end

@testset "poly.homogeneous" begin
   R, (x, y, z) = polynomial_ring(QQ, ["x", "y", "z"])
   @test divides(homogenize(x + y^2, z), x*z + y^2)[1]

   R, (x, y, z) = polynomial_ring(QQ, ["x", "y", "z"], ordering = ordering_wp([2,3,1]))
   @test divides(homogenize(x + y^2, z), x*z^4 + y^2)[1]
   @test is_homogeneous(Ideal(R, [homogenize(x + y^2, z)]))

   R, (x, y, z) = polynomial_ring(QQ, ["x", "y", "z"], ordering = ordering_wp([1,2,3]))
   @test_throws ErrorException homogenize(x + y^2, z)
end

@testset "poly.test_spoly_factor" begin
   # everything works for QQ, Fp, and extensions of these by a minpoly
   # factor_squarefree strangely does not work for ZZ

   R, (x, y, z, w) = polynomial_ring(QQ, ["x", "y", "z", "w"]; ordering=:negdegrevlex)
   f1 = 113*(2*y^7 + w^2)^3*(1 + x)^2*(x + y*z)^2

   R, (x, y, z, w) = polynomial_ring(ZZ, ["x", "y", "z", "w"]; ordering=:negdegrevlex)
   f2 = 123*(57*y^3 + w^5)^3*(x^2 + x+1)^2*(x + y*z)^2

   R, (x, y, z, w) = polynomial_ring(Fp(3), ["x", "y", "z", "w"]; ordering=:negdegrevlex)
   f3 = 7*(y^3 + w^3)*(1 + x)^2*(x + y*z)^2

   Qa, (a,) = FunctionField(QQ, ["a"])
   K, a = AlgebraicExtensionField(Qa, a^2 + 1)
   R, (x, y, z) = polynomial_ring(K, ["x", "y", "z"])
   f4 = (x^4 + y^4*z^4)*(1 + x + a*y + a^2*z)^2

   F7a, (a,) = FunctionField(Fp(7), ["a"])
   K, a = AlgebraicExtensionField(F7a, a^2 + 1)
   R, (x, y, z) = polynomial_ring(K, ["x", "y", "z"])
   f5 = (x^4 + y^4*z^4)*(1 + x + a*y + a^2*z)^2

   for f in [f1, f2, f3, f4, f5]
      F = factor(f)
      @test f == F.unit*prod(p^e for (p, e) in F)

      if typeof(f.parent) == PolyRing{n_Z}
         @test_throws Exception factor_squarefree(f)
      else
         F = factor_squarefree(f)
         @test f == F.unit*prod(p^e for (p, e) in F)
      end
   end

   # nothing works for Fq when constructed with the Zech log representation
   # as the kernel lacks the conversion functions

   Fq, a = FiniteField(19, 3, "a")
   R, (x, y, z) = polynomial_ring(Fq, ["x", "y", "z"])
   f = x^3*y^3*z^3 - a^3

   @test_throws Exception factor(f)
   @test_throws Exception factor_squarefree(f)
end

@testset "poly.hash" begin
   R, (x, y) = polynomial_ring(QQ, ["x", "y"])

   @test hash(x) == hash(x+y-y)
   @test hash(x,zero(UInt)) == hash(x+y-y,zero(UInt))
   @test hash(x,one(UInt)) == hash(x+y-y,one(UInt))
end

@testset "poly.errors" begin
   R, (x,) = polynomial_ring(QQ, ["x"])
   @test_throws Exception div(R(), R())
   @test !iszero(std(Ideal(R, R(1))))
end

@testset "poly.to_univariate" begin

   touni = Singular.AbstractAlgebra.to_univariate

   S, t = Singular.AbstractAlgebra.polynomial_ring(Singular.QQ, "t")

   R,(x,y) = polynomial_ring(QQ, ["x", "y"], ordering=:deglex)
   @test touni(S, 0*x) == zero(S)
   @test touni(S, 1+0*x) == one(S)
   @test touni(S, y+2*y^2+3*y^3) == t+2*t^2+3*t^3
   @test touni(S, x+2*x^2+3*x^3) == t+2*t^2+3*t^3
   @test_throws Exception touni(S, (1+x)*(1+y))

   R,(x,y) = polynomial_ring(QQ, ["x", "y"], ordering=:neglex)
   @test touni(S, 0*x) == zero(S)
   @test touni(S, 1+0*x) == one(S)
   @test touni(S, (1+2*y)^6) == (1+2*t)^6
   @test touni(S, (1+2*x)^6) == (1+2*t)^6
   @test_throws Exception touni(S, (1+x)*(1+y))
end
