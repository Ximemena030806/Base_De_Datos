# -*- coding: utf-8 -*-
"""Simulador de álgebra relacional — Clínica Veterinaria (esquema normalizado de la Unidad 4)
Ejecuta cada expresión sobre los datos, muestra las tablas intermedias y valida el resultado
contra la consulta SQL equivalente ejecutada en SQLite. Uso:  python simulador_algebra.py"""
import json, os, sqlite3, sys, itertools

# ------------------------------------------------------------------ núcleo
class Rel:
    def __init__(self, attrs, rows):
        self.attrs=list(attrs); seen=[]; 
        for r in rows:
            r=tuple(r)
            if r not in seen: seen.append(r)
        self.rows=seen
    def dicts(self): return [dict(zip(self.attrs,r)) for r in self.rows]
    def __len__(self): return len(self.rows)
    def key(self): return sorted(((tuple(None if v is None else (round(v,2) if isinstance(v,float) else v) for v in r)) for r in self.rows), key=lambda t:[(x is None,str(x)) for x in t])
def sel(R,p): return Rel(R.attrs,[r for r in R.rows if p(dict(zip(R.attrs,r)))])
def proj(R,attrs): ix=[R.attrs.index(a) for a in attrs]; return Rel(attrs,[tuple(r[i] for i in ix) for r in R.rows])
def gproj(R,exprs): return Rel([n for n,_ in exprs],[tuple(f(dict(zip(R.attrs,r))) for _,f in exprs) for r in R.rows])
def ren(R,mp): return Rel([mp.get(a,a) for a in R.attrs],R.rows)
def cross(R,S):
    assert not set(R.attrs)&set(S.attrs),"atributos no disjuntos"
    return Rel(R.attrs+S.attrs,[a+b for a in R.rows for b in S.rows])
def _align(R,S): assert set(R.attrs)==set(S.attrs),"no compatibles para unión"; return [tuple(dict(zip(S.attrs,r))[a] for a in R.attrs) for r in S.rows]
def union(R,S): return Rel(R.attrs,R.rows+_align(R,S))
def inter(R,S): s=set(_align(R,S)); return Rel(R.attrs,[r for r in R.rows if r in s])
def diff(R,S): s=set(_align(R,S)); return Rel(R.attrs,[r for r in R.rows if r not in s])
def theta(R,S,p): 
    assert not set(R.attrs)&set(S.attrs)
    return Rel(R.attrs+S.attrs,[a+b for a in R.rows for b in S.rows if p({**dict(zip(R.attrs,a)),**dict(zip(S.attrs,b))})])
def _common(R,S): return [a for a in R.attrs if a in S.attrs]
def _match(R,S,a,b,c): return all(a[R.attrs.index(k)] is not None and a[R.attrs.index(k)]==b[S.attrs.index(k)] for k in c)
def join(R,S):
    c=_common(R,S); extra=[x for x in S.attrs if x not in c]
    return Rel(R.attrs+extra,[a+tuple(b[S.attrs.index(x)] for x in extra) for a in R.rows for b in S.rows if _match(R,S,a,b,c)])
def _outer(R,S,left,right):
    c=_common(R,S); extra=[x for x in S.attrs if x not in c]; out=[]
    for a in R.rows:
        m=[b for b in S.rows if _match(R,S,a,b,c)]
        for b in m: out.append(a+tuple(b[S.attrs.index(x)] for x in extra))
        if not m and left: out.append(a+(None,)*len(extra))
    if right:
        for b in S.rows:
            if not any(_match(R,S,a,b,c) for a in R.rows):
                d=dict(zip(S.attrs,b)); out.append(tuple(d.get(x) for x in R.attrs)+tuple(d[x] for x in extra))
    return Rel(R.attrs+extra,out)
def ljoin(R,S): return _outer(R,S,True,False)
def rjoin(R,S): return _outer(R,S,False,True)
def fjoin(R,S): return _outer(R,S,True,True)
def div(R,S):
    X=[a for a in R.attrs if a not in S.attrs]; need=set(S.rows) ; out=[]
    px=proj(R,X)
    for x in px.rows:
        got={tuple(dict(zip(R.attrs,r))[y] for y in S.attrs) for r in R.rows if tuple(dict(zip(R.attrs,r))[a] for a in X)==x}
        if need<=got: out.append(x)
    return Rel(X,out)
AGG={"count":lambda v:len([x for x in v if x is not None]),"sum":lambda v:sum(x for x in v if x is not None),
     "avg":lambda v:sum(x for x in v if x is not None)/len([x for x in v if x is not None]),"min":lambda v:min(x for x in v if x is not None),"max":lambda v:max(x for x in v if x is not None)}
def group(R,by,aggs):
    """aggs: lista de (función, atributo, nombre_resultado)"""
    groups={}
    for r in R.rows:
        d=dict(zip(R.attrs,r)); groups.setdefault(tuple(d[b] for b in by),[]).append(d)
    if not by and not groups: groups[()]=[]
    return Rel(list(by)+[n for _,_,n in aggs],[k+tuple(AGG[f]([d[a] for d in ds]) for f,a,_ in aggs) for k,ds in groups.items()])
# ------------------------------------------------------------------ datos
HERE=os.path.dirname(os.path.abspath(__file__))
def load(path=None):
    data=json.load(open(path or os.path.join(HERE,"datos_veterinaria.json"),encoding="utf-8"))
    return {k:Rel(v["attrs"],v["rows"]) for k,v in data.items()},data
DB={};RAW={}
def init(path=None):
    global DB,RAW; DB,RAW=load(path)
# ------------------------------------------------------------------ catálogo
Q=[]
def q(id,nivel,titulo,natural,formula,sql): 
    def deco(fn): Q.append(dict(id=id,nivel=nivel,titulo=titulo,natural=natural,formula=formula,sql=sql.strip(),fn=fn)); return fn
    return deco
class Steps:
    def __init__(s): s.l=[]
    def add(s,name,expr,R): s.l.append((name,expr,R)); return R
@q("Q1","Básica","Citas programadas","Listar las citas cuyo estado es PROGRAMADA.",
   "σ_{estado='PROGRAMADA'}(cita)",
   "SELECT id_cita,id_mascota,id_veterinario,fecha_hora,motivo,estado FROM cita WHERE estado='PROGRAMADA'")
def q1(S):
    return S.add("R1","σ_{estado='PROGRAMADA'}(cita)",sel(DB["cita"],lambda t:t["estado"]=="PROGRAMADA"))
@q("Q2","Básica","Medicamentos caros","Mostrar el nombre y el precio de los medicamentos que cuestan más de 100.",
   "π_{nombre, precio}(σ_{precio>100}(medicamento))",
   "SELECT DISTINCT nombre,precio FROM medicamento WHERE precio>100")
def q2(S):
    r1=S.add("R1","σ_{precio>100}(medicamento)",sel(DB["medicamento"],lambda t:t["precio"]>100))
    return S.add("R2","π_{nombre, precio}(R1)",proj(r1,["nombre","precio"]))
@q("Q3","Intermedia","Mascotas con su propietario (reunión natural)","Mostrar el nombre de cada mascota junto con el nombre y apellido paterno de su propietario.",
   "π_{nombre, nombre_pila, ap_paterno}( π_{nombre, id_propietario}(mascota) ⋈ π_{id_propietario, nombre_pila, ap_paterno}(propietario) )",
   "SELECT DISTINCT m.nombre,p.nombre_pila,p.ap_paterno FROM mascota m JOIN propietario p ON p.id_propietario=m.id_propietario")
def q3(S):
    a=S.add("R1","π_{nombre, id_propietario}(mascota)",proj(DB["mascota"],["nombre","id_propietario"]))
    b=S.add("R2","π_{id_propietario, nombre_pila, ap_paterno}(propietario)",proj(DB["propietario"],["id_propietario","nombre_pila","ap_paterno"]))
    c=S.add("R3","R1 ⋈ R2",join(a,b))
    return S.add("R4","π_{nombre, nombre_pila, ap_paterno}(R3)",proj(c,["nombre","nombre_pila","ap_paterno"]))
@q("Q4","Intermedia","Consultas con mascota y veterinario (reunión de tres relaciones y renombramiento)","Listar el folio y la fecha de cada consulta con el nombre de la mascota atendida y el nombre del veterinario que la realizó.",
   "π_{folio, fecha, nombre_mascota, veterinario}( π_{folio, fecha, id_mascota, id_veterinario}(consulta) ⋈ ρ_{nombre_mascota←nombre}(π_{id_mascota, nombre}(mascota)) ⋈ ρ_{id_veterinario←id_empleado, veterinario←nombre_pila}(π_{id_empleado, nombre_pila}(empleado)) )",
   "SELECT DISTINCT c.folio,c.fecha,m.nombre AS nombre_mascota,e.nombre_pila AS veterinario FROM consulta c JOIN mascota m ON m.id_mascota=c.id_mascota JOIN empleado e ON e.id_empleado=c.id_veterinario")
def q4(S):
    a=S.add("R1","π_{folio, fecha, id_mascota, id_veterinario}(consulta)",proj(DB["consulta"],["folio","fecha","id_mascota","id_veterinario"]))
    b=S.add("R2","ρ_{nombre_mascota←nombre}(π_{id_mascota, nombre}(mascota))",ren(proj(DB["mascota"],["id_mascota","nombre"]),{"nombre":"nombre_mascota"}))
    c=S.add("R3","ρ_{id_veterinario←id_empleado, veterinario←nombre_pila}(π_{id_empleado, nombre_pila}(empleado))",ren(proj(DB["empleado"],["id_empleado","nombre_pila"]),{"id_empleado":"id_veterinario","nombre_pila":"veterinario"}))
    d=S.add("R4","R1 ⋈ R2",join(a,b)); e=S.add("R5","R4 ⋈ R3",join(d,c))
    return S.add("R6","π_{folio, fecha, nombre_mascota, veterinario}(R5)",proj(e,["folio","fecha","nombre_mascota","veterinario"]))
@q("Q5","Intermedia","Pares de medicamentos por precio (θ-join)","Obtener los pares (A, B) de medicamentos en los que A es más caro que B.",
   "π_{nombre_a, nombre_b}( ρ_{nombre_a←nombre, precio_a←precio}(π_{nombre, precio}(medicamento)) ⋈_{precio_a > precio_b} ρ_{nombre_b←nombre, precio_b←precio}(π_{nombre, precio}(medicamento)) )",
   "SELECT DISTINCT a.nombre AS nombre_a,b.nombre AS nombre_b FROM medicamento a JOIN medicamento b ON a.precio>b.precio")
def q5(S):
    m=proj(DB["medicamento"],["nombre","precio"])
    a=S.add("R1","ρ_{nombre_a←nombre, precio_a←precio}(π_{nombre, precio}(medicamento))",ren(m,{"nombre":"nombre_a","precio":"precio_a"}))
    b=S.add("R2","ρ_{nombre_b←nombre, precio_b←precio}(π_{nombre, precio}(medicamento))",ren(m,{"nombre":"nombre_b","precio":"precio_b"}))
    c=S.add("R3","R1 ⋈_{precio_a > precio_b} R2",theta(a,b,lambda t:t["precio_a"]>t["precio_b"]))
    return S.add("R4","π_{nombre_a, nombre_b}(R3)",proj(c,["nombre_a","nombre_b"]))
@q("Q6","Intermedia","Empleados con rol de gerente o recepcionista (unión)","Listar los empleados que son gerentes o recepcionistas.",
   "π_{id_empleado, nombre_pila, ap_paterno}( empleado ⋈ ( π_{id_empleado}(gerente) ∪ π_{id_empleado}(recepcionista) ) )",
   "SELECT e.id_empleado,e.nombre_pila,e.ap_paterno FROM empleado e WHERE e.id_empleado IN (SELECT id_empleado FROM gerente UNION SELECT id_empleado FROM recepcionista)")
def q6(S):
    a=S.add("R1","π_{id_empleado}(gerente)",proj(DB["gerente"],["id_empleado"]))
    b=S.add("R2","π_{id_empleado}(recepcionista)",proj(DB["recepcionista"],["id_empleado"]))
    c=S.add("R3","R1 ∪ R2",union(a,b)); d=S.add("R4","empleado ⋈ R3",join(DB["empleado"],c))
    return S.add("R5","π_{id_empleado, nombre_pila, ap_paterno}(R4)",proj(d,["id_empleado","nombre_pila","ap_paterno"]))
@q("Q7","Intermedia","Veterinarios que también son gerentes (intersección)","Identificar a los empleados que son veterinarios y, al mismo tiempo, gerentes (especialización solapada).",
   "π_{id_empleado, nombre_pila, ap_paterno}( empleado ⋈ ( π_{id_empleado}(veterinario) ∩ π_{id_empleado}(gerente) ) )",
   "SELECT e.id_empleado,e.nombre_pila,e.ap_paterno FROM empleado e WHERE e.id_empleado IN (SELECT id_empleado FROM veterinario INTERSECT SELECT id_empleado FROM gerente)")
def q7(S):
    a=S.add("R1","π_{id_empleado}(veterinario)",proj(DB["veterinario"],["id_empleado"]))
    b=S.add("R2","π_{id_empleado}(gerente)",proj(DB["gerente"],["id_empleado"]))
    c=S.add("R3","R1 ∩ R2",inter(a,b)); d=S.add("R4","empleado ⋈ R3",join(DB["empleado"],c))
    return S.add("R5","π_{id_empleado, nombre_pila, ap_paterno}(R4)",proj(d,["id_empleado","nombre_pila","ap_paterno"]))
@q("Q8","Intermedia","Mascotas sin consultas (diferencia)","Mostrar el nombre de las mascotas que nunca han tenido una consulta.",
   "π_{nombre}( mascota ⋈ ( π_{id_mascota}(mascota) − π_{id_mascota}(consulta) ) )",
   "SELECT DISTINCT m.nombre FROM mascota m WHERE m.id_mascota NOT IN (SELECT id_mascota FROM consulta)")
def q8(S):
    a=S.add("R1","π_{id_mascota}(mascota)",proj(DB["mascota"],["id_mascota"]))
    b=S.add("R2","π_{id_mascota}(consulta)",proj(DB["consulta"],["id_mascota"]))
    c=S.add("R3","R1 − R2",diff(a,b)); d=S.add("R4","mascota ⋈ R3",join(DB["mascota"],c))
    return S.add("R5","π_{nombre}(R4)",proj(d,["nombre"]))
@q("Q9","Intermedia","Pares proveedor-medicamento que no se suministran (producto cartesiano y diferencia)","Obtener los pares proveedor-medicamento posibles que todavía no existen en los suministros, con sus nombres.",
   "π_{razon_social, nombre}( ( ( π_{id_proveedor}(proveedor) × π_{id_medicamento}(medicamento) ) − π_{id_proveedor, id_medicamento}(suministra) ) ⋈ π_{id_proveedor, razon_social}(proveedor) ⋈ π_{id_medicamento, nombre}(medicamento) )",
   "SELECT DISTINCT pr.razon_social,md.nombre FROM proveedor pr CROSS JOIN medicamento md WHERE NOT EXISTS (SELECT 1 FROM suministra s WHERE s.id_proveedor=pr.id_proveedor AND s.id_medicamento=md.id_medicamento)")
def q9(S):
    a=S.add("R1","π_{id_proveedor}(proveedor)",proj(DB["proveedor"],["id_proveedor"]))
    b=S.add("R2","π_{id_medicamento}(medicamento)",proj(DB["medicamento"],["id_medicamento"]))
    c=S.add("R3","R1 × R2",cross(a,b))
    d=S.add("R4","π_{id_proveedor, id_medicamento}(suministra)",proj(DB["suministra"],["id_proveedor","id_medicamento"]))
    e=S.add("R5","R3 − R4",diff(c,d))
    f=S.add("R6","R5 ⋈ π_{id_proveedor, razon_social}(proveedor) ⋈ π_{id_medicamento, nombre}(medicamento)",join(join(e,proj(DB["proveedor"],["id_proveedor","razon_social"])),proj(DB["medicamento"],["id_medicamento","nombre"])))
    return S.add("R7","π_{razon_social, nombre}(R6)",proj(f,["razon_social","nombre"]))
@q("Q10","Avanzada","Propietarios con mascotas de todas las especies dadas (división)","Listar los propietarios que tienen al menos una mascota de cada una de las especies Perro y Gato.",
   "π_{nombre_pila, ap_paterno}( propietario ⋈ ( π_{id_propietario, id_especie}(mascota) ÷ π_{id_especie}(σ_{nombre='Perro' ∨ nombre='Gato'}(especie)) ) )",
   "SELECT p.nombre_pila,p.ap_paterno FROM propietario p WHERE NOT EXISTS (SELECT 1 FROM especie e WHERE e.nombre IN ('Perro','Gato') AND NOT EXISTS (SELECT 1 FROM mascota m WHERE m.id_propietario=p.id_propietario AND m.id_especie=e.id_especie))")
def q10(S):
    a=S.add("R1","π_{id_propietario, id_especie}(mascota)",proj(DB["mascota"],["id_propietario","id_especie"]))
    b=S.add("R2","π_{id_especie}(σ_{nombre='Perro' ∨ nombre='Gato'}(especie))",proj(sel(DB["especie"],lambda t:t["nombre"] in("Perro","Gato")),["id_especie"]))
    c=S.add("R3","R1 ÷ R2",div(a,b)); d=S.add("R4","propietario ⋈ R3",join(DB["propietario"],c))
    return S.add("R5","π_{nombre_pila, ap_paterno}(R4)",proj(d,["nombre_pila","ap_paterno"]))
@q("Q11","Avanzada","Medicamentos surtidos por todos los proveedores (división)","Encontrar los medicamentos que son suministrados por todos los proveedores registrados.",
   "π_{nombre}( medicamento ⋈ ( π_{id_medicamento, id_proveedor}(suministra) ÷ π_{id_proveedor}(proveedor) ) )",
   "SELECT md.nombre FROM medicamento md WHERE NOT EXISTS (SELECT 1 FROM proveedor pr WHERE NOT EXISTS (SELECT 1 FROM suministra s WHERE s.id_medicamento=md.id_medicamento AND s.id_proveedor=pr.id_proveedor))")
def q11(S):
    a=S.add("R1","π_{id_medicamento, id_proveedor}(suministra)",proj(DB["suministra"],["id_medicamento","id_proveedor"]))
    b=S.add("R2","π_{id_proveedor}(proveedor)",proj(DB["proveedor"],["id_proveedor"]))
    c=S.add("R3","R1 ÷ R2",div(a,b)); d=S.add("R4","medicamento ⋈ R3",join(DB["medicamento"],c))
    return S.add("R5","π_{nombre}(R4)",proj(d,["nombre"]))
@q("Q12","Avanzada","Número de consultas por veterinario (agregación con agrupación)","Contar cuántas consultas ha realizado cada veterinario, mostrando su nombre.",
   "π_{nombre_pila, num_consultas}( ρ_{id_veterinario←id_empleado}(π_{id_empleado, nombre_pila}(empleado)) ⋈ _{id_veterinario}G_{count(folio) → num_consultas}(consulta) )",
   "SELECT e.nombre_pila,COUNT(c.folio) AS num_consultas FROM consulta c JOIN empleado e ON e.id_empleado=c.id_veterinario GROUP BY c.id_veterinario,e.nombre_pila")
def q12(S):
    a=S.add("R1","_{id_veterinario}G_{count(folio) → num_consultas}(consulta)",group(DB["consulta"],["id_veterinario"],[("count","folio","num_consultas")]))
    b=S.add("R2","ρ_{id_veterinario←id_empleado}(π_{id_empleado, nombre_pila}(empleado))",ren(proj(DB["empleado"],["id_empleado","nombre_pila"]),{"id_empleado":"id_veterinario"}))
    c=S.add("R3","R2 ⋈ R1",join(b,a))
    return S.add("R4","π_{nombre_pila, num_consultas}(R3)",proj(c,["nombre_pila","num_consultas"]))
@q("Q13","Avanzada","Estadísticas del inventario (agregación sin agrupación)","Obtener el número de medicamentos, su precio promedio y la existencia total.",
   "G_{count(id_medicamento) → num_medicamentos, avg(precio) → precio_promedio, sum(existencia) → existencia_total}(medicamento)",
   "SELECT COUNT(id_medicamento) AS num_medicamentos,AVG(precio) AS precio_promedio,SUM(existencia) AS existencia_total FROM medicamento")
def q13(S):
    return S.add("R1","G_{count(id_medicamento) → num_medicamentos, avg(precio) → precio_promedio, sum(existencia) → existencia_total}(medicamento)",
      group(DB["medicamento"],[],[("count","id_medicamento","num_medicamentos"),("avg","precio","precio_promedio"),("sum","existencia","existencia_total")]))
@q("Q14","Intermedia","Valor del inventario por medicamento (proyección generalizada)","Calcular el valor de inventario (existencia × precio) de cada medicamento.",
   "π_{nombre, existencia × precio → valor_inventario}(medicamento)",
   "SELECT DISTINCT nombre,existencia*precio AS valor_inventario FROM medicamento")
def q14(S):
    return S.add("R1","π_{nombre, existencia × precio → valor_inventario}(medicamento)",gproj(DB["medicamento"],[("nombre",lambda t:t["nombre"]),("valor_inventario",lambda t:t["existencia"]*t["precio"])]))
@q("Q15","Avanzada","Mascotas con su consulta, incluso sin ninguna (reunión externa izquierda)","Listar todas las mascotas con el folio de su consulta; las que no tienen consulta deben aparecer con folio nulo.",
   "π_{nombre, folio}( π_{id_mascota, nombre}(mascota) ⋈_L π_{id_mascota, folio}(consulta) )",
   "SELECT DISTINCT m.nombre,c.folio FROM mascota m LEFT JOIN consulta c ON c.id_mascota=m.id_mascota")
def q15(S):
    a=S.add("R1","π_{id_mascota, nombre}(mascota)",proj(DB["mascota"],["id_mascota","nombre"]))
    b=S.add("R2","π_{id_mascota, folio}(consulta)",proj(DB["consulta"],["id_mascota","folio"]))
    c=S.add("R3","R1 ⋈_L R2",ljoin(a,b))
    return S.add("R4","π_{nombre, folio}(R3)",proj(c,["nombre","folio"]))
@q("Q16","Avanzada","Roles administrativos de los empleados (reunión externa completa)","Mostrar, para cada empleado que es gerente o recepcionista, su departamento y su turno (nulos cuando no tiene ese rol).",
   "gerente ⋈_F recepcionista",
   "SELECT COALESCE(g.id_empleado,r.id_empleado) AS id_empleado,g.departamento,r.turno FROM gerente g FULL OUTER JOIN recepcionista r ON r.id_empleado=g.id_empleado")
def q16(S):
    return S.add("R1","gerente ⋈_F recepcionista",fjoin(DB["gerente"],DB["recepcionista"]))
@q("Q17","Avanzada","Gerentes y su turno de recepción (reunión externa derecha)","Mostrar a todos los gerentes con su turno de recepción, si también lo tienen.",
   "recepcionista ⋈_R gerente",
   "SELECT g.id_empleado,r.turno,g.departamento FROM recepcionista r RIGHT JOIN gerente g ON g.id_empleado=r.id_empleado")
def q17(S):
    return S.add("R1","recepcionista ⋈_R gerente",rjoin(DB["recepcionista"],DB["gerente"]))
# ------------------------------------------------------------------ ejecución y validación
def sqlite_db():
    db=sqlite3.connect(":memory:")
    for name,v in RAW.items():
        db.execute(f"CREATE TABLE {name} ({', '.join(v['attrs'])})")
        if v["rows"]: db.executemany(f"INSERT INTO {name} VALUES ({','.join('?'*len(v['attrs']))})",v["rows"])
    return db
def run_all(validate=True):
    out=[]; db=sqlite_db() if validate else None
    for qq in Q:
        S=Steps(); res=qq["fn"](S)
        sqlrel=None; ok=None
        if validate:
            cur=db.execute(qq["sql"]); cols=[d[0] for d in cur.description]; sqlrel=Rel(cols,cur.fetchall())
            # alinear columnas por nombre
            ok = set(cols)==set(res.attrs) and Rel(res.attrs,[tuple(dict(zip(cols,r))[a] for a in res.attrs) for r in sqlrel.rows]).key()==res.key()
        out.append(dict(q=qq,steps=S.l,result=res,sql_rows=len(sqlrel) if sqlrel else None,ok=ok))
    return out
def fmt(v):
    if v is None: return "NULL"
    if isinstance(v,float): return f"{v:.2f}"
    return str(v)
def show(R,title=""):
    w=[max(len(a),*(len(fmt(r[i])) for r in R.rows)) if R.rows else len(a) for i,a in enumerate(R.attrs)]
    line="+"+"+".join("-"*(x+2) for x in w)+"+"
    s=[title,line,"| "+" | ".join(a.ljust(w[i]) for i,a in enumerate(R.attrs))+" |",line]
    s+=["| "+" | ".join(fmt(v).ljust(w[i]) for i,v in enumerate(r))+" |" for r in R.rows]+[line,f"({len(R)} fila(s))"]
    return "\n".join(s)
if __name__=="__main__":
    init(sys.argv[1] if len(sys.argv)>1 else None)
    res=run_all(); bien=0
    for r in res:
        q=r["q"]; print("="*78); print(f"{q['id']} [{q['nivel']}] {q['titulo']}"); print("Requerimiento:",q["natural"]); print("Álgebra:",q["formula"]); print("SQL    :",q["sql"])
        for n,e,R in r["steps"]: print(show(R,f"\n{n} = {e}"))
        print(f"\nValidación contra SQL: {'COINCIDE' if r['ok'] else 'NO COINCIDE'}"); bien+=bool(r["ok"])
    print("="*78); print(f"Consultas validadas: {bien}/{len(res)}")
