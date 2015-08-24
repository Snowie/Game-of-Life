import field

proc main() =
  const width = 10
  const height = 10

  var field: Field

  field = newSeq[seq[State]](width)

  for i in 0..<len(field):
    field[i] = newSeq[State](height)

  #A quick blinker to start us off
  field[1][2].current = true
  field[2][2].current = true
  field[3][2].current = true

  #Go through 5 generations
  for i in 0..5:
    #Figure out how the field will look on the next iteration
    field.logic()

    #Print the field
    for row in field:
      for cell in row:
        write(stdout, if cell.current: $1 else: $0)
      echo()
    echo("---------")

    #Move to the next generation
    field.step()

main()
