import field, times, sdl2

proc main() =
  var field: Field = loadFieldFromFile("../test.txt")

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
  cells = newSeq[seq[Rect]](len(field))
  for i in 0..<len(cells):
    cells[i] = newSeq[Rect](len(field[i]))

  #Place these cells
  for y in 0..<len(cells):
    for x in 0..<len(cells[y]):
      cells[y][x].x = cint(x*cellMod + 1)
      cells[y][x].y = cint(y*cellMod + 1)
      cells[y][x].w = cint(cellMod - 1)
      cells[y][x].h = cint(cellMod - 1)

  #Keep arrays of cells to use sdl2's fillrects
  var liveCells = newSeq[Rect](len(field) * len(field[0]))

  var timeStart = epochtime()

  var generations= 3_000

  for i in 0..generations:
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
  echo("Dataset: ", len(field) * len(field[0]))
  echo("Generations per second: ", float(generations)/(timeStop-timeStart))
  #Cleanup messy C libraries
  destroy ren
  destroy win
main()
