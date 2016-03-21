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

proc createField*(width: int, height: int): Field =
  #Create a helper function to make fields
  result = newSeq[seq[State]](width)
  for i in 0..<len(result):
    result[i] = newSeq[State](height)

proc saveToFile*(field: Field, filename: string) =
  #Save a field to a file
  var f: File
  if f.open(filename, fmWrite):
    for row in field:
      for cell in row:
        f.write(if cell.current: 'o' else: 'x')
      f.writeln("")
  else:
    echo("Failed to open file")

proc loadFieldFromFile*(filename: string): Field =
  #Load a field from a file
  var f: File
  if f.open(filename):
    var cells: seq[string] = newSeq[string]()

    #Load the cells into something usable
    for line in f.lines:
      cells.add(line)

    var field: Field = newSeq[seq[State]](len(cells))

    #Load the cells into the field
    for y in 0..<len(cells):
      field[y] = newSeq[State](len(cells[y]))
      for x in 0..<len(cells[y]):
        field[y][x].current = if cells[y][x] == 'o': true else: false
        field[y][x].next = false

    #Cleanup
    f.close()

    return field
  else:
    echo("Failed to open file!")
    return createField(0, 0)

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
