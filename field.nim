type
  State* = tuple [current: bool, next: bool]
  Field* = seq[seq[State]]

proc sumNine(x: int, y: int, field: Field): int =
  #The state of a cell can be described by the sum of itself and its neigbours

  #Loop through the rows surrounding it
  for yIndex in y-1..y+1:
    #Don't access bad indices
    if yIndex < 0 or yIndex >= len(field):
      continue

    #Loop through each cell in each row
    for xIndex in x-1..x+1:
      #Don't access bad indices
      if xIndex < 0 or xIndex >= len(field[yIndex]):
        continue

      #Add 1 to result if the cell is alive, else 0
      result += (if field[yIndex][xIndex].current: 1 else: 0)

proc logic*(field: var Field) =
  #Calculate what the field will look like next
  for y in 0..<len(field):
    for x in 0..<len(field[y]):

      #The future state of a cell can be described by the sum of itself
      #and its neighbours
      var sum: int = sumNine(x, y, field)
      case sum

      #If the sum is three, the cell will always live through
      of 3:
        field[y][x].next = true

      #If the sum is four, it will retain state
      of 4:
        field[y][x].next = field[y][x].current

      #Otherwise, it dies of some cause
      else:
        field[y][x].next = false

proc step*(field: var Field) =
  #Move the next state into the current state
  for y in 0..<len(field):
    for x in 0..<len(field[y]):
      field[y][x].current = field[y][x].next
