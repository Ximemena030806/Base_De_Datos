# Operadores del álgebra relacional

| Operador | Símbolo | Aridad | Definición formal | SQL |
|---|---|---|---|---|
| Selección | σ | Unario | σ_p(R) = { t ∈ R \| p(t) } | WHERE |
| Proyección | π | Unario | π_A(R) = { t[A] \| t ∈ R } | SELECT DISTINCT |
| Renombramiento | ρ | Unario | ρ_S(B1…Bn)(R) | AS |
| Producto cartesiano | × | Binario | R × S = { t·u \| t ∈ R, u ∈ S } | CROSS JOIN |
| Unión | ∪ | Binario | R ∪ S = { t \| t ∈ R ∨ t ∈ S } | UNION |
| Intersección | ∩ | Binario | R ∩ S = R − (R − S) | INTERSECT |
| Diferencia | − | Binario | R − S = { t ∈ R \| t ∉ S } | EXCEPT |
| División | ÷ | Binario | R(X∪Y) ÷ S(Y) = { x \| ∀y ∈ S: (x,y) ∈ R } | NOT EXISTS doble |
| Reunión | ⋈ | Binario | R ⋈_θ S = σ_θ(R × S) | JOIN … ON |
| Proyección generalizada | π_F | Unario | π con expresiones aritméticas | SELECT expr AS alias |
| Agregación | G | Unario | _A G_f(B)(R) | GROUP BY |
| Reunión externa | ⋈_L ⋈_R ⋈_F | Binario | (R ⋈ S) ∪ tuplas sin pareja con NULL | LEFT / RIGHT / FULL JOIN |
