import field
import sdl2

proc main() =
  const width = 20
  const height = 20

  var field: Field = createField(width, height)

  #A quick blinker to start us off
  field[1][2].current = true
  field[2][2].current = true
  field[3][2].current = true

  #R pentomino
  field[1 + 8][3 + 8].current = true
  field[1 + 8][4 + 8].current = true
  field[2 + 8][2 + 8].current = true
  field[2 + 8][3 + 8].current = true
  field[3 + 8][3 + 8].current = true

  #Setup SDL
  var
    win: WindowPtr
    ren: RendererPtr
    evt = sdl2.defaultEvent
    runGame = true


  discard init(INIT_EVERYTHING)

  win = createWindow("Conway's Game Of Life", 100, 100, 1024, 768, SDL_WINDOW_SHOWN)
  if win == nil:
    echo("Create window failed! Error: ", getError())
    quit(1)

  ren = createRenderer(win, -1, Renderer_Accelerated or Renderer_PresentVsync)
  if ren == nil:
    echo("Create renderer failed! Error: ", getError())
    quit(1)

  var cells: seq[seq[Rect]]

  #Initiate an array of cells
  cells = newSeq[seq[Rect]](width)
  for i in 0..<len(cells):
    cells[i] = newSeq[Rect](height)

  #Place these cells
  for y in 0..<len(cells):
    for x in 0..<len(cells[y]):
      cells[y][x].x = cint(x*40 + 1)
      cells[y][x].y = cint(y*40 + 1)
      cells[y][x].w = cint(40 - 1)
      cells[y][x].h = cint(40 - 1)

  while runGame:
    #Handle Events
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        runGame = false
        break

    #Determine how the field will look for the next generation
    field.logic()
    delay(300)
    ren.clear
    for y in 0..<len(field):
      for x in 0..<len(field[y]):
        if field[y][x].current:
          #Set Color active
          setDrawColor(ren, uint8(255), uint8(255), uint8(255))
        else:
          #Set Color inactive
          setDrawColor(ren, uint8(0), uint8(0), uint8(0))
        #Draw the cell
        fillRect(ren, cells[y][x])

    #Draw to the screen
    ren.present

    #Move the field's future to current
    field.step()

  #Cleanup messy C libraries
  destroy ren
  destroy win
main()
