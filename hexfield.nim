import math, hashes, tables, sets

type
  Point* = object
    x*: int
    y*: int
  hexTable = Table[Point, Hex]
  State = tuple [current: bool, next: bool]
  HexObj = object
    s*: State
    neighbours*: array[0..5, Hex]
    p*: Point
  Hex* = ref HexObj
proc hash*(p: Point): Hash =
  result = p.x.hash !& p.y.hash
  result = !$result

proc `==`*(u: Point, v: Point): bool =
  return (u.x == v.x and u.y == v.y)

proc hash*(h: Hex): Hash =
  return hash(h.p)

proc hexInitWalk(h: var Hex, hTable: var Table[Point, Hex], width: int, height: int, pnt: var Point) =
  #If we've gone out of bounds
  if pnt.x < 0 or pnt.x > width:
    return
  if pnt.y < 0 or pnt.y > height:
    return

  #Make a new hex here
  new(h)

  h.s.current = if random(2) == 1: true else: false
  h.p = pnt
  h.s.next = false

  hTable[pnt] = h
  #North
  pnt.x = pnt.x
  pnt.y -= 1
  if not hTable.hasKey(pnt):
    hexInitWalk(h.neighbours[0], hTable, width, height, pnt)
  else:
    h.neighbours[0] = hTable[pnt]

  pnt = h.p
  #North East
  pnt.x += 1
  pnt.y -= 1
  if not hTable.hasKey(pnt):
    hexInitWalk(h.neighbours[1], hTable, width, height, pnt)
  else:
    h.neighbours[1] = hTable[pnt]

  pnt = h.p
  #South East
  pnt.x += 1
  pnt.y += 1
  if not hTable.hasKey(pnt):
    hexInitWalk(h.neighbours[2], hTable, width, height, pnt)
  else:
    h.neighbours[2] = hTable[pnt]

  pnt = h.p
  #South
  pnt.x = pnt.x
  pnt.y += 1
  if not hTable.hasKey(pnt):
    hexInitWalk(h.neighbours[3], hTable, width, height, pnt)
  else:
    h.neighbours[3] = hTable[pnt]

  pnt = h.p
  #South West
  pnt.x -= 1
  pnt.y += 1
  if not hTable.hasKey(pnt):
    hexInitWalk(h.neighbours[4], hTable, width, height, pnt)
  else:
    h.neighbours[4] = hTable[pnt]

  pnt = h.p
  #North West
  pnt.x -= 1
  pnt.y -= 1
  if not hTable.hasKey(pnt):
    hexInitWalk(h.neighbours[5], hTable, width, height, pnt)
  else:
    h.neighbours[5] = hTable[pnt]

proc initHexRandomField*(width: int, height: int): Hex =
  randomize()
  var hTable: hexTable = initTable[Point, Hex]()
  var p: Point
  p.x = 0
  p.y = 0
  hexInitWalk(result, hTable, width, height, p)

proc sum6(h: Hex): int =
  if h == nil:
    result = 0
  else:
    result = if h.s.current: 1 else: 0

  for i in 0..<len(h.neighbours):
    if h.neighbours[i] != nil:
      if h.neighbours[i].s.current:
        result += 1

proc step(h: var Hex, hexSet: var HashSet[Hex]) =
  h.s.current = h.s.next
  h.s.next = false

  hexSet.incl(h)

  for i in 0..<len(h.neighbours):
    if h.neighbours[i] != nil:
      if not hexSet.contains(h.neighbours[i]):
        step(h.neighbours[i], hexSet)

proc step*(h: var Hex) =
  var hexSet: HashSet[Hex] = initSet[Hex]()
  step(h, hexSet)

proc logic(h: var Hex, hexSet: var HashSet[Hex]) =
  case sum6(h)
  of 2:
    h.s.next = true
  of 3:
    h.s.next = h.s.current
  of 4:
    h.s.next = h.s.current
  else:
    h.s.next = false

  hexSet.incl(h)

  for i in 0..<len(h.neighbours):
    if h.neighbours[i] != nil:
      if not hexSet.contains(h.neighbours[i]):
        logic(h.neighbours[i], hexSet)

proc logic*(h: var Hex) =
  var hexSet: HashSet[Hex] = initSet[Hex]()
  logic(h, hexSet)
