type
  State* = tuple [current: bool, next: bool]
  Field* = seq[seq[State]]

proc sumNine(x: int, y: int, field: Field): int =
  for yIndex in y-1..y+1:
    if yIndex < 0 or yIndex >= len(field):
      continue
    for xIndex in x-1..x+1:
      if xIndex < 0 or xIndex >= len(field[yIndex]):
        continue
      result += (if field[yIndex][xIndex].current: 1 else: 0)

proc logic*(field: var Field) =
  for y in 0..<len(field):
    for x in 0..<len(field[y]):
      var sum: int = sumNine(x, y, field)
      case sum
      of 3:
        field[y][x].next = true
      of 4:
        field[y][x].next = field[y][x].current
      else:
        field[y][x].next = false

proc step*(field: var Field) =
  for y in 0..<len(field):
    for x in 0..<len(field[y]):
      field[y][x].current = field[y][x].next
