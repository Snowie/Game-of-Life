import field
import sdl2, sdl2/gfx

proc main() =
  const width = 10
  const height = 10

  var field: Field = createField(width, height)

  #A quick blinker to start us off
  field[1][2].current = true
  field[2][2].current = true
  field[3][2].current = true

  #Setup SDL
  var
    win: WindowPtr
    ren: RendererPtr
    evt = sdl2.defaultEvent
    runGame = true
    fpsman: FpsManager
  fpsman.init


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
  cells = newSeq[seq[Rect]](width)
  for i in 0..<len(cells):
    cells[i] = newSeq[Rect](height)

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

    let dt = fpsman.getFramerate() / 1000
    delay(300)
    field.logic()
    ren.clear
    for y in 0..<len(field):
      for x in 0..<len(field[y]):
        if field[y][x].current:
          #Set Color active
          setDrawColor(ren, uint8(255), uint8(255), uint8(255))
        else:
          #Set Color inactive
          setDrawColor(ren, uint8(0), uint8(0), uint8(0))
        #drawFillRect(ren, cells[y][x])
        fillRect(ren, cells[y][x])
    ren.present
    field.step()
    fpsman.delay

  #Cleanup messy C libraries
  destroy ren
  destroy win
main()
