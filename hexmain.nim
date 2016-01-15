import hexfield, times, sdl2, sets

proc renderHexField(h: Hex, hexSet: var HashSet[hexfield.Point], ren: RendererPtr) =
  if h.s.current:
    var r: Rect
    r.x = cast[cint](h.p.x * 4 + 1)
    r.y = cast[cint](h.p.y * 4 + 1)
    r.w = 4
    r.h = 4
    setDrawColor(ren, uint8(255), uint8(255), uint8(255))
    fillRect(ren, r)
    #copy(ren, tex, nil, r
    setDrawColor(ren, uint8(0), uint8(0), uint8(0))

  hexSet.incl(h.p)

  for i in 0..<len(h.neighbours):
    if h.neighbours[i] == nil:
      continue
    if not hexSet.contains(h.neighbours[i].p):
      renderHexField(h.neighbours[i], hexSet, ren)

proc renderHexField(h: Hex, ren: RendererPtr) =
  var hexSet: HashSet[hexfield.Point] = initSet[hexfield.Point]()
  renderHexField(h, hexSet, ren)


proc main() =
  let width: int = 200
  let height: int = 200
  var field: Hex = initHexRandomField(width, height)

  #Setup SDL
  var
    win: WindowPtr
    ren: RendererPtr
    evt = sdl2.defaultEvent
    runGame = true


  discard init(INIT_EVERYTHING)

  win = createWindow("Conway's Game Of Life: Hex Edition", 100, 100, 1280, 720, SDL_WINDOW_SHOWN)
  let cellMod = min(1280 div cast[int](width), 720 div cast[int](height))

  if win == nil:
    echo("Create window failed! Error: ", getError())
    quit(1)

  ren = createRenderer(win, -1, Renderer_Accelerated)
  if ren == nil:
    echo("Create renderer failed! Error: ", getError())
    quit(1)

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

    setDrawColor(ren, uint8(0), uint8(0), uint8(0))
    renderHexField(field, ren)
    setDrawColor(ren, uint8(0), uint8(0), uint8(0))

    #Draw to the screen
    ren.present

    #Move the field's future to current
    field.step()

  var timeStop = epochtime()

  echo("Program time: ", timeStop-timeStart)
  echo("Dataset: ", width * height)
  echo("Generations per second: ", float(generations)/(timeStop-timeStart))
  #Cleanup messy C libraries
  destroy ren
  destroy win
main()
