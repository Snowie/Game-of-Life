import field
import times
import sdl2

proc main() =
  const width = 200
  const height = 200

  var field: Field = loadFieldFromFile("test.txt")

  #Setup SDL
  var
    win: WindowPtr
    ren: RendererPtr
    evt = sdl2.defaultEvent
    runGame = true


  discard init(INIT_EVERYTHING)

  win = createWindow("Conway's Game Of Life", 100, 100, 1440, 900, SDL_WINDOW_SHOWN)
  let cellMod = min(1440 div len(field), 900 div len(field))

  if win == nil:
    echo("Create window failed! Error: ", getError())
    quit(1)

  ren = createRenderer(win, -1, Renderer_Accelerated)
  if ren == nil:
    echo("Create renderer failed! Error: ", getError())
    quit(1)

  var cells: seq[seq[Rect]]

  #Initiate an array of cells for drawing
  cells = newSeq[seq[Rect]](width)
  for i in 0..<len(cells):
    cells[i] = newSeq[Rect](height)

  #Place these cells
  for y in 0..<len(cells):
    for x in 0..<len(cells[y]):
      cells[y][x].x = cint(x*cellMod + 1)
      cells[y][x].y = cint(y*cellMod + 1)
      cells[y][x].w = cint(cellMod - 1)
      cells[y][x].h = cint(cellMod - 1)

  #Keep arrays of cells to use sdl2's fillrects
  var liveCells: array[200*200, Rect]

  var timeStart = epochtime()

  for i in 0..3_000:
    #Handle Events
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        runGame = false
        break

    if not runGame:
      break

    #Determine how the field will look for the next generation
    field.logic()

    ren.clear

    #Keep track of where to place things, we never clear livecells.
    var liveCellIndex = 0

    for y in 0..<len(field):
      for x in 0..<len(field[y]):
        if field[y][x].current:
          #Add a cell to the active array
          liveCells[liveCellIndex] = cells[y][x]
          inc(liveCellIndex)

    setDrawColor(ren, uint8(255), uint8(255), uint8(255))
    fillRects(ren, addr(liveCells[0]), cint(liveCellIndex))
    setDrawColor(ren, uint8(0), uint8(0), uint8(0))

    #Draw to the screen
    ren.present

    #Move the field's future to current
    field.step()

  var timeStop = epochtime()

  echo("Program time: ", timeStop-timeStart)
  echo("Dataset: ", 200*200)
  echo("Generations per second: ", 3000/(timeStop-timeStart))
  #Cleanup messy C libraries
  destroy ren
  destroy win
main()
