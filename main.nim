import field

proc main() =
  const width = 10
  const height = 10

  var field: Field

  field = newSeq[seq[State]](width)

  for i in 0..<len(field):
    field[i] = newSeq[State](height)

  field[1][2].current = true
  field[2][2].current = true
  field[3][2].current = true

  for i in 0..5:
    field.logic()
    for row in field:
      for cell in row:
        write(stdout, if cell.current: $1 else: $0)
      echo()
    echo("---------")
    field.step()

main()
